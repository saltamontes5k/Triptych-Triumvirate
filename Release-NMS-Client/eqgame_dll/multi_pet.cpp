/**
 * @file multi_pet.cpp
 * @brief Implementation of MultiPet mod — tracks multiple simultaneous pets
 *        for NMS multiclass characters (server-authoritative via OP_PetList).
 *
 * Pet identification: Server sends OP_PetList (0x1341) with all pet SpawnIDs.
 * Spawn resolution: OnAddSpawn/OnRemoveSpawn maintain a SpawnID→pointer map.
 * Commands: /pets (list), /petcycle (rotate UI pet), /petdebug (diagnostics).
 *
 * @date 2026-02-14
 *
 * @copyright Copyright (c) 2026
 */
// clang-format off

// clang-format on
#include <Windows.h>

#include "MQ2Main.h"     // pLocalPlayer, pLocalPC, GetGameState(), AddCommand/RemoveCommand, WriteChatColor/WriteChatf
#include "multi_pet.h"

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <vector>


// ---------------------------------------------------------------------------
// Spawn field offsets (verified from eqlib + /petscan)
// ---------------------------------------------------------------------------
static constexpr uint32_t OFF_SPAWN_NAME = 0x0A4; // PlayerBase::Name (char[64])
static constexpr uint32_t OFF_SPAWN_ID = 0x148; // PlayerBase::SpawnID (uint32)
static constexpr uint32_t OFF_SPAWN_PET_ID =
    0x2B4; // PlayerZoneClient::PetID (int)
static constexpr uint32_t OFF_SPAWN_NEXT =
    0x04; // TListNode<PlayerClient>::m_pNext

// _SPAWNINFO linked list next pointer offset
// (verified: _SPAWNINFO::pPrev at 0x0004, pNext at 0x0008)
static constexpr uint32_t OFF_SPAWN_LIST_NEXT = 0x0008;

// Opcodes
static constexpr uint32_t OP_PetList = 0x1341;

// ---------------------------------------------------------------------------
// Static instance pointer for command callbacks and cross-mod access
// ---------------------------------------------------------------------------
static MultiPet *s_instance = nullptr;

MultiPet *MultiPet::GetInstance() { return s_instance; }

// ---------------------------------------------------------------------------
// Spawn field helpers
// ---------------------------------------------------------------------------
static inline uint32_t GetSpawnID(void *pSpawn) {
  return *reinterpret_cast<uint32_t *>(reinterpret_cast<uintptr_t>(pSpawn) +
                                       OFF_SPAWN_ID);
}

static inline const char *GetSpawnName(void *pSpawn) {
  return reinterpret_cast<const char *>(reinterpret_cast<uintptr_t>(pSpawn) +
                                        OFF_SPAWN_NAME);
}

static inline int GetPetID(void *pSpawn) {
  return *reinterpret_cast<int *>(reinterpret_cast<uintptr_t>(pSpawn) +
                                  OFF_SPAWN_PET_ID);
}

static inline void SetPetID(void *pSpawn, int petID) {
  *reinterpret_cast<int *>(reinterpret_cast<uintptr_t>(pSpawn) +
                           OFF_SPAWN_PET_ID) = petID;
}

// ---------------------------------------------------------------------------
// Local player helper
// ---------------------------------------------------------------------------

static inline void* GetLocalPlayer() {
    __try {
        if (!pinstLocalPlayer || !pLocalPlayer) return nullptr;
        if (reinterpret_cast<uintptr_t>(pLocalPlayer) < 0x10000 || reinterpret_cast<uintptr_t>(pLocalPlayer) >= 0x7FFF0000) return nullptr;
        return (void*)pLocalPlayer;
    } __except (EXCEPTION_EXECUTE_HANDLER) {
        return nullptr;
    }
}

// ---------------------------------------------------------------------------
// Class name table for pet display
// ---------------------------------------------------------------------------
static inline void* GetSpawnList() {
    __try {
        if (!ppSpawnManager || !pSpawnManager) return nullptr;
        return (void*)pSpawnList;
    } __except (EXCEPTION_EXECUTE_HANDLER) {
        return nullptr;
    }
}

static const char *GetClassName(uint32_t classID) {
  switch (classID) {
  case 1:
    return "Warrior";
  case 2:
    return "Cleric";
  case 3:
    return "Paladin";
  case 4:
    return "Ranger";
  case 5:
    return "Shadow Knight";
  case 6:
    return "Druid";
  case 7:
    return "Monk";
  case 8:
    return "Bard";
  case 9:
    return "Rogue";
  case 10:
    return "Shaman";
  case 11:
    return "Necromancer";
  case 12:
    return "Wizard";
  case 13:
    return "Magician";
  case 14:
    return "Enchanter";
  case 15:
    return "Beastlord";
  case 16:
    return "Berserker";
  default:
    return "Unknown";
  }
}

// ---------------------------------------------------------------------------
// Command handlers
// ---------------------------------------------------------------------------

static VOID CmdPets(PSPAWNINFO /*pChar*/, PCHAR /*szLine*/)
{
    if (s_instance) s_instance->ListPets();
}

static VOID CmdPetCycle(PSPAWNINFO /*pChar*/, PCHAR /*szLine*/)
{
    if (s_instance) s_instance->CyclePet();
}

static VOID CmdPetDebug(PSPAWNINFO /*pChar*/, PCHAR /*szLine*/)
{
    if (s_instance) s_instance->DebugSpawns();
}


// ---------------------------------------------------------------------------
// IMod interface
// ---------------------------------------------------------------------------

const char *MultiPet::GetName() const { return "MultiPet"; }

bool MultiPet::Initialize() {

  s_instance = this;

  AddCommand("/pets", CmdPets);
  AddCommand("/petcycle", CmdPetCycle);
  AddCommand("/petdebug", CmdPetDebug);

  return true;
}

void MultiPet::Shutdown() {
  ClearAllTracking();

  RemoveCommand("/pets");
  RemoveCommand("/petcycle");
  RemoveCommand("/petdebug");


  s_instance = nullptr;

}

void MultiPet::OnSetGameState(int gameState) {
  if (gameState != 5) {
    ClearAllTracking();
  }
}

// ---------------------------------------------------------------------------
// Spawn map — track ALL spawns by SpawnID for later lookup
// ---------------------------------------------------------------------------

void MultiPet::OnAddSpawn(void *pSpawn) {
  if (!pSpawn)
    return;
  uint32_t spawnID = GetSpawnID(pSpawn);
  if (spawnID == 0)
    return;

  m_spawnMap[spawnID] = pSpawn;

  // The server decides who our pets are; all we do here is bind the pointer if
  // this spawn is one the server already told us about.
  if (m_needsResolve)
    ResolvePetSpawns();
}

void MultiPet::OnRemoveSpawn(void *pSpawn) {
  if (!pSpawn)
    return;
  uint32_t spawnID = GetSpawnID(pSpawn);

  m_spawnMap.erase(spawnID);

  // Do NOT drop the pet from m_pets here. ConfigurePetWindow despawns and
  // immediately respawns the focused pet on a timer, so a despawn is routine and
  // says nothing about ownership. Erasing on despawn is what made pets vanish from
  // the window: the server's petids never changed, so no new OP_PetList was sent
  // and nothing put the pet back. Just release the stale pointer and re-resolve
  // when the spawn returns. Only OP_PetList removes entries.
  auto it = std::find_if(
      m_pets.begin(), m_pets.end(),
      [spawnID](const TrackedPet &p) { return p.spawnID == spawnID; });

  if (it != m_pets.end()) {
    it->pSpawn = nullptr;
    m_needsResolve = true;
  }
}

// ---------------------------------------------------------------------------
// OnPulse — zone-change detection + spawn-pointer resolution
// ---------------------------------------------------------------------------

void MultiPet::OnPulse()
{
    if (GetGameState() != GAMESTATE_INGAME)
        return;

    auto* pLocal = GetLocalPlayer();
    if (!pLocal)
        return;

    uint32_t currentLocalID = GetSpawnID(pLocal);

    // Detect SpawnID change (zone transition)
    if (m_localSpawnID != 0 && m_localSpawnID != currentLocalID)
    {
        ClearAllTracking();
    }

    m_localSpawnID = currentLocalID;

    // Rebuild spawn map if empty (zone-in or late DLL load), then bind any pets the
    // server has already told us about. No scanning — the list itself comes from
    // OP_PetList and nowhere else.
    if (m_spawnMap.empty())
    {
        RebuildSpawnMap();
        m_needsResolve = true;
    }

    // Bind pointers for pets whose spawn has not arrived yet (or came back after a
    // despawn). Cheap: a no-op once everything is resolved.
    if (m_needsResolve)
        ResolvePetSpawns();

}



// ---------------------------------------------------------------------------
// OP_PetList handler — server tells us which spawns are our pets
// ---------------------------------------------------------------------------

bool MultiPet::OnIncomingMessage(uint32_t opcode, const void* buffer, uint32_t size)
{
    if (opcode == OP_PetList)
    {
        // Packet: [uint32 count] per pet: [uint32 spawnID] [uint32 classID]
        if (size < 4 || !buffer)
            return false;

        const uint8_t* buf = static_cast<const uint8_t*>(buffer);

        uint32_t count = 0;
        memcpy(&count, buf, 4);

        // Validate count against the KNOWN size instead of computing an expected
        // size from count: this is a 32-bit build, so `4 + count * 8` wraps for a
        // huge count (e.g. 0x20000000 * 8 == 0), the old check passed, and the
        // parse loop read far out of bounds. Derived from `size`, the bound cannot
        // overflow. Also cap at the server's absolute pet limit as sanity.
        if (count > (size - 4) / 8 || count > 64) {
            return false;
        }

        m_pets.clear();

        // Track EVERY pet the server lists, including the one currently in the
        // native pet window. Which pet is "the UI pet" changes whenever the player
        // switches focus, and no OP_PetList accompanies that (petids is unchanged) —
        // so excluding it here bakes in a stale exclusion: after a focus switch the
        // new UI pet showed twice and the old one vanished. PetWindow filters the
        // UI pet out at render time instead, fresh every frame.
        uint32_t offset = 4;
        for (uint32_t i = 0; i < count; ++i)
        {
            uint32_t petSpawnID = 0;
            uint32_t petClassID = 0;

            memcpy(&petSpawnID, buf + offset, 4);
            offset += 4;
            memcpy(&petClassID, buf + offset, 4);
            offset += 4;

            TrackedPet pet;
            pet.spawnID = petSpawnID;
            pet.classID = petClassID;
            pet.pSpawn = nullptr;
            pet.name[0] = '\0';

            // Try to resolve spawn pointer immediately
            auto mapIt = m_spawnMap.find(petSpawnID);
            if (mapIt != m_spawnMap.end())
            {
                pet.pSpawn = mapIt->second;
                strncpy_s(pet.name, GetSpawnName(pet.pSpawn), _TRUNCATE);
            }

            m_pets.push_back(pet);
        }

        m_havePetList  = true;
        m_needsResolve = true;

        // Adopt the current local SpawnID NOW. OnPulse treats a SpawnID change as a
        // zone transition and wipes all tracking; if this packet lands after zone-in
        // but before the first in-game pulse, that wipe would destroy the list we
        // just applied -- and with stable pets the server has no reason to resend.
        // Claiming the new SpawnID here makes the arrival order irrelevant.
        if (void* pLocalNow = GetLocalPlayer())
            m_localSpawnID = GetSpawnID(pLocalNow);

        // The spawn map may predate this zone (it only rebuilds when empty, and
        // OnRemoveSpawn may not have fired for every old entry during the zone
        // switch). Resolving pets against stale pointers is how crashes happen, so
        // rebuild from the live spawn list before binding.
        RebuildSpawnMap();
        ResolvePetSpawns();

        return false; // Suppress — custom opcode, don't pass to client
    }

    return true;
}


// ---------------------------------------------------------------------------
// Resolve pet spawn pointers from the spawn map
// ---------------------------------------------------------------------------

void MultiPet::ResolvePetSpawns() {
  bool allResolved = true;

  for (auto &pet : m_pets) {
    if (pet.pSpawn)
      continue; // Already resolved

    // Look the spawn up in the map rather than walking the spawn list. This runs
    // every pulse while anything is unresolved, and a pet the server has listed but
    // that has not spawned locally keeps it unresolved indefinitely -- an O(n) list
    // walk per pet per frame is not acceptable there. OnAddSpawn/OnRemoveSpawn and
    // RebuildSpawnMap keep the map current, so this is equivalent and O(1).
    auto it = m_spawnMap.find(pet.spawnID);

    if (it != m_spawnMap.end() && it->second) {
      pet.pSpawn = it->second;
      strncpy_s(pet.name, GetSpawnName(pet.pSpawn), _TRUNCATE);
    } else {
      allResolved = false;
    }
  }

  if (allResolved)
    m_needsResolve = false;
}

// ---------------------------------------------------------------------------
// MasterID-based pet detection
// ---------------------------------------------------------------------------

void MultiPet::RebuildSpawnMap()
{
    m_spawnMap.clear();
    void* pSpawn = GetSpawnList();
    while (pSpawn)
    {
        if (reinterpret_cast<uintptr_t>(pSpawn) < 0x10000 || reinterpret_cast<uintptr_t>(pSpawn) >= 0x7FFF0000) break;
        uint32_t sid = GetSpawnID(pSpawn);
        if (sid != 0)
        {
            m_spawnMap[sid] = pSpawn;
        }
        pSpawn = *reinterpret_cast<void**>(reinterpret_cast<uintptr_t>(pSpawn) + OFF_SPAWN_LIST_NEXT);
    }
}




// ---------------------------------------------------------------------------
// Clear all tracking state
// ---------------------------------------------------------------------------

void MultiPet::ClearAllTracking() {
  m_pets.clear();
  m_spawnMap.clear();
  m_localSpawnID = 0;
  m_needsResolve = false;

  // Drop the "server has told us" flag too, so the extra gauges stay hidden until
  // the new zone's OP_PetList lands rather than briefly showing a stale list.
  m_havePetList = false;
}

// ---------------------------------------------------------------------------
// /pets command
// ---------------------------------------------------------------------------

void MultiPet::ListPets() {
    void* pLocal = GetLocalPlayer();
    if (!pLocal)
        return;

    if (!m_havePetList || m_pets.empty()) {
        WriteChatColor("You have no pets.", CONCOLOR_YELLOW);
        return;
    }

    int uiPetID = GetPetID(pLocal);

    char buf[256];
    sprintf_s(buf, "You have %u pet(s):", (uint32_t)m_pets.size());
    WriteChatColor(buf, CONCOLOR_YELLOW);

    for (size_t i = 0; i < m_pets.size(); ++i) {
        const auto& pet = m_pets[i];
        const char* marker = (pet.spawnID == static_cast<uint32_t>(uiPetID)) ? " (pet window)" : "";
        const char* cls = (pet.classID > 0) ? GetClassName(pet.classID) : "";
        if (cls[0])
            sprintf_s(buf, "  %u: %s [%s]%s", (uint32_t)(i + 1), pet.name[0] ? pet.name : "(spawning)", cls, marker);
        else
            sprintf_s(buf, "  %u: %s%s", (uint32_t)(i + 1), pet.name[0] ? pet.name : "(spawning)", marker);
        WriteChatColor(buf, CONCOLOR_GREEN);
    }
}



// ---------------------------------------------------------------------------
// /petcycle command
// ---------------------------------------------------------------------------

void MultiPet::CyclePet() {
    void* pLocal = GetLocalPlayer();
    if (!pLocal || m_pets.empty())
        return;

    int uiPetID = GetPetID(pLocal);

    // m_pets is the server-authoritative list and contains EVERY pet, including
    // the one currently in the native window -- cycling is just "find the current
    // UI pet in the list and step to the next entry". NO list mutation here: the
    // old version erased the new UI pet from m_pets, permanently removing it from
    // the gauges (the server has no reason to resend a list that did not change).
    size_t currentIndex = m_pets.size();  // sentinel: not found
    for (size_t i = 0; i < m_pets.size(); ++i) {
        if (m_pets[i].spawnID == static_cast<uint32_t>(uiPetID)) {
            currentIndex = i;
            break;
        }
    }

    // Unknown/stale UI pet -> start from the first pet
    size_t nextIndex = (currentIndex >= m_pets.size()) ? 0 : (currentIndex + 1) % m_pets.size();

    SetPetID(pLocal, static_cast<int>(m_pets[nextIndex].spawnID));
}





// ---------------------------------------------------------------------------
// /petdebug command
// ---------------------------------------------------------------------------

void MultiPet::DebugSpawns() {
    void* pLocal = GetLocalPlayer();
    if (!pLocal) {
        WriteChatColor("MultiPet Debug: No local player.", CONCOLOR_RED);
        return;
    }

    uint32_t localID = GetSpawnID(pLocal);
    int uiPetID = GetPetID(pLocal);

    char buf[256];
    sprintf_s(buf, "MultiPet Debug: localID=%u  uiPetID=%d  havePetList=%d  trackedPets=%u",
        localID, uiPetID, m_havePetList ? 1 : 0, (uint32_t)m_pets.size());
    WriteChatColor(buf, CONCOLOR_YELLOW);

    // Tracked pets (server-authoritative list)
    for (size_t i = 0; i < m_pets.size(); ++i) {
        const auto& pet = m_pets[i];
        sprintf_s(buf, "  Pet[%u]: spawnID=%u name='%s' classID=%u pSpawn=0x%08X",
            (uint32_t)i, pet.spawnID, pet.name, pet.classID, (uint32_t)(uintptr_t)pet.pSpawn);
        WriteChatColor(buf, CONCOLOR_GREEN);
    }

    // A listed-but-unresolved pet that IS in the live spawn list means the
    // resolve path failed -- that is the one state worth shouting about.
    int totalSpawns = 0;
    void* sp = GetSpawnList();
    while (sp) {
        if (reinterpret_cast<uintptr_t>(sp) < 0x10000 || reinterpret_cast<uintptr_t>(sp) >= 0x7FFF0000) break;
        totalSpawns++;
        uint32_t sid = GetSpawnID(sp);

        for (const auto& pp : m_pets) {
            if (!pp.pSpawn && pp.spawnID == sid) {
                sprintf_s(buf, "  URGENT: unresolved pet %u IS in the spawn list (pSpawn=0x%08X) - resolve bug", sid, (uint32_t)(uintptr_t)sp);
                WriteChatColor(buf, CONCOLOR_RED);
            }
        }
        sp = *reinterpret_cast<void**>(reinterpret_cast<uintptr_t>(sp) + OFF_SPAWN_LIST_NEXT);
    }

    sprintf_s(buf, "  Total spawns iterated: %d  spawnMap=%u", totalSpawns, (uint32_t)m_spawnMap.size());
    WriteChatColor(buf, CONCOLOR_GREY);
}

