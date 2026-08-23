/**
 * @file multi_pet.h
 * @brief MultiPet mod — tracks multiple simultaneous pets for NMS multiclass
 *        characters and populates XTarget slots so secondary pets show HP bars.
 *
 * Pet identification is server-authoritative: OP_PetList (0x1341) carries the
 * server's petids vector, and that list is the ONLY thing that adds or removes a
 * tracked pet. The server resends on every pet-list change and on zone-in.
 *
 * This replaced a client-side MasterID scan (spawn offset 0x38C, matched against
 * the local player, rescanned every 120 pulses). That scan was a stand-in for a
 * server packet that had never been implemented, and it was the cause of the
 * "pet window sometimes only shows one pet" bug: any transient where a pet's
 * MasterID read 0 dropped it from the window until the next scan tick. Do not
 * reintroduce it as a fallback — two sources of truth is what produced the bug.
 * If no OP_PetList has arrived, the extra gauges stay hidden rather than guess.
 *
 * Spawn resolution: OnAddSpawn/OnRemoveSpawn maintain a SpawnID→pointer map.
 * A despawn only NULLs the cached pointer (the server despawns/respawns pets
 * routinely); the entry itself survives until the server says otherwise.
 * XTarget: Writes secondary pets into AutoHater slots that have no target.
 * Commands: /pets (list), /petcycle (rotate UI pet), /petdebug (diagnostics).
 *
 * @date 2026-02-14
 *
 * @copyright Copyright (c) 2026
 */

#pragma once

#include <cstdint>
#include <unordered_map>
#include <vector>

struct TrackedPet
{
    uint32_t    spawnID   = 0;
    uint32_t    classID   = 0;      // summoning class, EQ ids (necro 11, mage 13)
    void*       pSpawn    = nullptr;
    char        name[64]  = {};
};

class MultiPet {

public:
    const char* GetName() const;
    bool        Initialize();
    void        Shutdown();
    void        OnPulse();
    bool        OnIncomingMessage(uint32_t opcode, const void* buffer, uint32_t size);
    void        OnAddSpawn(void* pSpawn);
    void        OnRemoveSpawn(void* pSpawn);
    void        OnSetGameState(int gameState);


    // Public so static command handlers can access
    void ListPets();
    void CyclePet();
    void DebugSpawns();

    // Accessor for other mods (e.g. PetWindow)
    static MultiPet* GetInstance();
    const std::vector<TrackedPet>& GetTrackedPets() const { return m_pets; }

    void ClearAllTracking();
    void ResolvePetSpawns();
    void RebuildSpawnMap();

    bool HavePetList() const { return m_havePetList; }

    // Tracked secondary pets — populated exclusively from OP_PetList
    std::vector<TrackedPet>  m_pets;

    // SpawnID → spawn pointer map (populated via OnAddSpawn/OnRemoveSpawn)
    std::unordered_map<uint32_t, void*>  m_spawnMap;

    uint32_t m_localSpawnID  = 0;   // cached local player SpawnID (detect zone)
    bool     m_needsResolve  = false; // set when pet list arrives, cleared after resolving
    bool     m_havePetList   = false; // true once the server has sent us a list
};
