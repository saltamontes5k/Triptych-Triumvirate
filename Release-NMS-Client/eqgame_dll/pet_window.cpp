/**
 * @file pet_window.cpp
 * @brief PetWindow — multi-pet HP display in the Pet Info Window.
 *
 * Phase 1: Locate the live CPetInfoWnd by scanning CXWndManager's window list.
 * Phase 2: Walk child widget tree to find CGaugeWnd children "Pet 2"/"Pet 3".
 * Phase 3: Update gauge fill and name each pulse from MultiPet HP data.
 * Phase 4: Hook CSidlScreenWnd::WndNotification so clicking a gauge targets
 *           the corresponding secondary pet.
 *
 * Integration:
 *   Instantiate PetWindow and call Initialize() after MQ2 initializes.
 *   Call OnPulse() from Heartbeat() each frame.
 *   Call OnSetGameState() when the game state changes.
 *   Call Shutdown() on DLL unload.
 *
 * Requirements:
 *   The EQ UI XML for PetInfoWindow must contain two CGaugeWnd children
 *   named "Pet 2" and "Pet 3" for this system to display anything.
 */

#include <Windows.h>
#include "MQ2Main.h"
#include "pet_window.h"
#include "multi_pet.h"

#include <cstdint>
#include <cstring>

// ---------------------------------------------------------------------------
// CXWnd memory layout offsets (ROF2 client, May 10 2013)
//
// CXWnd inherits from TListNode<CXWnd> and TList<CXWnd>.
// MSVC lays out the vtable first when the base classes have no virtuals:
//   +0x00  vtable
//   +0x04  TListNode::m_pPrev  (prev sibling)
//   +0x08  TListNode::m_pNext  (next sibling)
//   +0x0C  TListNode::m_pList  (parent list)
//   +0x10  TList::m_pFirstNode (first child)
//   +0x14  TList::m_pLastNode  (last child)
//   +0x1A8 CXStr WindowText
//   +0x1DC CXStr SidlText      (CSidlScreenWnd only)
// ---------------------------------------------------------------------------
static constexpr uint32_t OFF_CXWND_VTABLE       = 0x00;
static constexpr uint32_t OFF_CXWND_NEXT_SIBLING = 0x08;
static constexpr uint32_t OFF_CXWND_FIRST_CHILD  = 0x10;
static constexpr uint32_t OFF_CXWND_WINDOWTEXT   = 0x1A8;
static constexpr uint32_t OFF_CXWND_DSHOW        = 0x196; // bool show
static constexpr uint32_t OFF_SIDL_TEXT          = 0x1DC;

// CXStr / CStrRep layout
static constexpr uint32_t OFF_CXSTR_REP_LEN  = 0x08;
static constexpr uint32_t OFF_CXSTR_REP_UTF8 = 0x14;

// CGaugeWnd vtable raw address (pre-ASLR, ROF2)
static constexpr uint32_t VFTABLE_CGaugeWnd = 0x9E87A8;

// CGaugeWnd field offsets (relative to object start)
static constexpr uint32_t OFF_GAUGE_LASTFRAMEVAL    = 0x1F8; // float  fill (0-1000)
static constexpr uint32_t OFF_GAUGE_LASTFRAMETARGET = 0x204; // int    fill target
static constexpr uint32_t OFF_GAUGE_TARGETVAL       = 0x238; // int    target value
static constexpr uint32_t OFF_GAUGE_USETARGETVAL    = 0x23C; // bool   use target

// Spawn HP offsets
static constexpr uint32_t OFF_SPAWN_HPMAX     = 0x02DC;
static constexpr uint32_t OFF_SPAWN_HPCURRENT = 0x02E4;
static constexpr uint32_t OFF_SPAWN_PET_ID    = 0x02B4; // PlayerZoneClient::PetID (matches multi_pet.cpp)

// LabelCache — game-maintained struct with XTarget HP percentages
// __LabelCache_x = 0xF74AB0 (raw, pre-ASLR)
// ExtendedTargetHPPct at +0x8F4: int[20] indexed by XTarget slot

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

static void CleanPetName(char* out, size_t outSize, const char* rawName)
{
    if (!rawName || !rawName[0]) {
        strncpy_s(out, outSize, "", _TRUNCATE);
        return;
    }
    strncpy_s(out, outSize, rawName, _TRUNCATE);
    int len = (int)strlen(out);
    while (len > 0 && out[len - 1] >= '0' && out[len - 1] <= '9')
        out[--len] = '\0';
}

static bool SafeReadUint32(uintptr_t addr, uint32_t& out)
{
    __try { out = *(uint32_t*)addr; return true; }
    __except (EXCEPTION_EXECUTE_HANDLER) { return false; }
}

static bool SafeReadPtr(uintptr_t addr, uintptr_t& out)
{
    __try { out = *(uintptr_t*)addr; return true; }
    __except (EXCEPTION_EXECUTE_HANDLER) { return false; }
}

static inline bool IsValidPtr(uintptr_t p)
{
    return p >= 0x10000 && p < 0x7FFF0000;
}

// Read a CXStr field (which is a CStrRep*). Returns the UTF-8 string or nullptr.
static const char* ReadCXStr(uintptr_t cxstrAddr)
{
    __try {
        uintptr_t repPtr = *(uintptr_t*)cxstrAddr;
        if (!IsValidPtr(repPtr))
            return nullptr;

        uint32_t len = *(uint32_t*)(repPtr + OFF_CXSTR_REP_LEN);
        if (len == 0 || len > 256)
            return nullptr;

        int refCount = *(int*)(repPtr + 0x00);
        if (refCount <= 0 || refCount > 10000)
            return nullptr;

        const char* str = (const char*)(repPtr + OFF_CXSTR_REP_UTF8);
        if (str[0] < 0x20 || str[0] > 0x7E)
            return nullptr;

        return str;
    }
    __except (EXCEPTION_EXECUTE_HANDLER) { return nullptr; }
}

static const char* ReadSidlName(void* wnd)
{
    if (!wnd || !IsValidPtr((uintptr_t)wnd))
        return nullptr;
    return ReadCXStr((uintptr_t)wnd + OFF_SIDL_TEXT);
}

static const char* ReadWindowText(void* wnd)
{
    if (!wnd || !IsValidPtr((uintptr_t)wnd))
        return nullptr;
    return ReadCXStr((uintptr_t)wnd + OFF_CXWND_WINDOWTEXT);
}

// ---------------------------------------------------------------------------
// Create a new CXStr (CStrRep*) to hold variable length text.
// ---------------------------------------------------------------------------
static void* CreateCXStr(const char* text)
{
    if (!text) text = "";
    int len = (int)strlen(text);
    
    // Allocate CStrRep matching EQ memory layout
    int allocSize = sizeof(int)*3 + len + 1; // refCount + alloc + len + data
    void* p = malloc(allocSize);
    if (!p) return nullptr;
    
    int* header = (int*)p;
    header[0] = 1;     // refCount = 1
    header[1] = len;   // alloc = len
    header[2] = len;   // len = len
    
    char* data = (char*)(p) + 12;
    memcpy(data, text, len + 1); // includes null terminator
    
    return p;
}

// ---------------------------------------------------------------------------
// Static singleton instance
// ---------------------------------------------------------------------------
static PetWindow* s_petWnd = nullptr;

PetWindow* PetWindow::GetInstance() { return s_petWnd; }

// ---------------------------------------------------------------------------
// WndNotification hook — intercept clicks on our secondary pet gauges
// ---------------------------------------------------------------------------
using WndNotification_t = int(__fastcall*)(void* thisPtr, void* edx,
                                           void* sender, uint32_t message,
                                           void* data);

static int __fastcall WndNotification_Trampoline(void* thisPtr, void* edx,
                                                  void* sender, uint32_t message,
                                                  void* data);

static bool ContainsKeyword(const char* str, const char* keyword) {
    if (!str || !keyword) return false;
    size_t str_len = strlen(str);
    size_t kw_len = strlen(keyword);
    if (str_len < kw_len) return false;
    for (size_t i = 0; i <= str_len - kw_len; ++i) {
        if (_strnicmp(str + i, keyword, kw_len) == 0) {
            return true;
        }
    }
    return false;
}

static int __fastcall WndNotification_Detour(void* thisPtr, void* edx,
                                               void* sender, uint32_t message,
                                               void* data)
{
    extern uint32_t g_cauth_bitmask;
    extern BYTE g_savedClass;
    extern BYTE g_savedCI2Class;
    extern bool g_overrideActive;

    bool isTargetWnd = false;
    if (pLocalPlayer) {
        if (thisPtr && (thisPtr == pCastSpellWnd || thisPtr == pSpellBookWnd)) {
            isTargetWnd = true;
            char dbg[256];
            sprintf_s(dbg, "[NMS-WndNotification] thisPtr=%p (Cast/Book), message=%d, sender=%p\n", thisPtr, message, sender);
            OutputDebugStringA(dbg);
        } else if (message == 1 /* XWM_LCLICK */ || message == 2 /* XWM_RCLICK */) {
            const char* thisSidl = ReadSidlName(thisPtr);
            const char* senderSidl = ReadSidlName(sender);
            const char* thisText = ReadWindowText(thisPtr);
            const char* senderText = ReadWindowText(sender);

            // Log details of mouse clicks
            char dbg[512];
            sprintf_s(dbg, "[NMS-WndNotification] Click: this=%p (%s, txt: %s), sender=%p (%s, txt: %s), msg=%u\n",
                      thisPtr, thisSidl ? thisSidl : "null", thisText ? thisText : "null",
                      sender, senderSidl ? senderSidl : "null", senderText ? senderText : "null", message);
            OutputDebugStringA(dbg);

            const char* keywords[] = { "book", "spell", "cast", "sit", "stand", "meditate", "mem" };
            for (const char* kw : keywords) {
                if (ContainsKeyword(thisSidl, kw) || ContainsKeyword(senderSidl, kw) ||
                    ContainsKeyword(thisText, kw) || ContainsKeyword(senderText, kw)) {
                    isTargetWnd = true;
                    break;
                }
            }

            if (isTargetWnd) {
                OutputDebugStringA("[NMS-WndNotification] Match: Restoring caster class during notification\n");
            }
        }
    }

    if (isTargetWnd && pLocalPlayer) {
        PSPAWNINFO pPlayer = (PSPAWNINFO)pLocalPlayer;
        PCHARINFO2 pCI2 = GetCharInfo2();
        BYTE savedClass = pPlayer->Class;
        BYTE savedCI2Class = pCI2 ? (BYTE)pCI2->Class : 0;

        auto isCasterClass = [](BYTE c) {
            return (c == 2 || c == 3 || c == 4 || c == 5 || c == 6 || 
                    c == 8 || c == 10 || c == 11 || c == 12 || c == 13 || 
                    c == 14 || c == 15);
        };

        BYTE baseClass = g_overrideActive ? g_savedClass : savedClass;
        BYTE targetClass = savedClass;

        if (isCasterClass(baseClass)) {
            targetClass = baseClass;
        } else {
            for (int i = 0; i < 16; i++) {
                BYTE c = i + 1;
                if ((g_cauth_bitmask & (1 << i)) && isCasterClass(c)) {
                    targetClass = c;
                    break;
                }
            }
        }

        if (isCasterClass(targetClass)) {
            pPlayer->Class = targetClass;
            if (pCI2) pCI2->Class = targetClass;

            int result = WndNotification_Trampoline(thisPtr, edx, sender, message, data);

            pPlayer->Class = savedClass;
            if (pCI2) pCI2->Class = savedCI2Class;
            return result;
        }
    }

    if (message == 1 /* XWM_LCLICK */) {
        if (s_petWnd && s_petWnd->HandleClick(sender))
            return 1; // handled — suppress default behavior
    }
    return WndNotification_Trampoline(thisPtr, edx, sender, message, data);
}

DETOUR_TRAMPOLINE_EMPTY(int __fastcall WndNotification_Trampoline(void* thisPtr,
                                                                    void* edx,
                                                                    void* sender,
                                                                    uint32_t message,
                                                                    void* data));

// ---------------------------------------------------------------------------
// /petwindebug command — re-scan for gauges on demand
// ---------------------------------------------------------------------------
static VOID CmdPetWinDebug(PSPAWNINFO /*pChar*/, PCHAR /*szLine*/)
{
    if (s_petWnd)
        s_petWnd->CreateGauge();
}

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

bool PetWindow::Initialize()
{
    s_petWnd = this;

    AddCommand("/petwindebug", CmdPetWinDebug);

    EzDetour(CSidlScreenWnd__WndNotification,
             WndNotification_Detour,
             WndNotification_Trampoline);

    return true;
}

void PetWindow::Shutdown()
{
    RemoveDetour(CSidlScreenWnd__WndNotification);
    RemoveCommand("/petwindebug");

    s_petWnd     = nullptr;
    m_petInfoWnd = nullptr;
    m_newGauge1  = nullptr;
    m_newGauge2  = nullptr;
}

void PetWindow::ResetUI()
{
    // Everything below points into EQ's pet info window, which EQ destroys on any UI
    // teardown. m_initialized is what gates the re-locate in OnPulse, so it MUST be
    // cleared too -- leaving it set is what let OnPulse keep writing to freed gauges.
    m_petInfoWnd = nullptr;
    m_newGauge1  = nullptr;
    m_newGauge2  = nullptr;
    m_initialized = false;
    m_initCounter = 0;
}

void PetWindow::OnSetGameState(int /*gameState*/)
{
    // Reset on any state change so we re-locate the window next pulse
    ResetUI();
}

void PetWindow::OnPulse()
{
    if (GetGameState() != GAMESTATE_INGAME)
        return;

    // Delayed init: wait ~1 second after zone-in for UI to load
    if (!m_initialized) {
        if (++m_initCounter < 60)
            return;

        m_initCounter = 0; // Throttle: try again in 60 frames if we return early/fail

        m_petInfoWnd = FindPetInfoWnd();
        if (!m_petInfoWnd)
            return;

        CreateGauge();

        if (m_newGauge1 && m_newGauge2) {
            m_initialized = true;
        }

        return;
    }

    // The single authoritative gauge list — shared with HandleClick so what a gauge
    // shows and what clicking it targets can never disagree. Empty until the server
    // has sent an OP_PetList: an empty gauge is better than a plausible guess.
    auto validPets = GetVisiblePets();

    // --- Pet 2 gauge (first secondary pet) ---
    if (m_newGauge1) {
        if (validPets.size() >= 1) {
            // NMS Hide Pet 2 Placeholder from UI
            if (!*(bool*)((uintptr_t)m_newGauge1 + OFF_CXWND_DSHOW))
                *(bool*)((uintptr_t)m_newGauge1 + OFF_CXWND_DSHOW) = true;

            int pct = 0;
            __try {
                int hpCur = *(int32_t*)((uintptr_t)validPets[0]->pSpawn + OFF_SPAWN_HPCURRENT);
                int hpMax = *(int32_t*)((uintptr_t)validPets[0]->pSpawn + OFF_SPAWN_HPMAX);
                pct = (hpMax > 0) ? (hpCur * 100 / hpMax) : 0;
            }
            __except (EXCEPTION_EXECUTE_HANDLER) {}
            char cleanName[64];
            CleanPetName(cleanName, sizeof(cleanName), validPets[0]->name);
            UpdateGauge(m_newGauge1, cleanName, pct);
        } else {
            // NMS Hide Pet 2 Placeholder from UI
            if (*(bool*)((uintptr_t)m_newGauge1 + OFF_CXWND_DSHOW))
                *(bool*)((uintptr_t)m_newGauge1 + OFF_CXWND_DSHOW) = false;

            UpdateGauge(m_newGauge1, "Pet 2", 0);
        }
    }

    // --- Pet 3 gauge (second secondary pet) ---
    if (m_newGauge2) {
        if (validPets.size() >= 2) {
            // NMS Hide Pet 3 Placeholder from UI
            if (!*(bool*)((uintptr_t)m_newGauge2 + OFF_CXWND_DSHOW))
                *(bool*)((uintptr_t)m_newGauge2 + OFF_CXWND_DSHOW) = true;

            int pct = 0;
            __try {
                int hpCur = *(int32_t*)((uintptr_t)validPets[1]->pSpawn + OFF_SPAWN_HPCURRENT);
                int hpMax = *(int32_t*)((uintptr_t)validPets[1]->pSpawn + OFF_SPAWN_HPMAX);
                pct = (hpMax > 0) ? (hpCur * 100 / hpMax) : 0;
            }
            __except (EXCEPTION_EXECUTE_HANDLER) {}
            char cleanName[64];
            CleanPetName(cleanName, sizeof(cleanName), validPets[1]->name);
            UpdateGauge(m_newGauge2, cleanName, pct);
        } else {
            // NMS Hide Pet 3 Placeholder from UI
            if (*(bool*)((uintptr_t)m_newGauge2 + OFF_CXWND_DSHOW))
                *(bool*)((uintptr_t)m_newGauge2 + OFF_CXWND_DSHOW) = false;

            UpdateGauge(m_newGauge2, "Pet 3", 0);
        }
    }
}

// ---------------------------------------------------------------------------
// Find CPetInfoWnd using the MQ2 global pPetInfoWnd (ppPetInfoWnd).
// This is the authoritative pointer maintained by the game and MQ2Globals.
// ---------------------------------------------------------------------------
void* PetWindow::FindPetInfoWnd()
{
    __try {
        if (!ppPetInfoWnd || !pPetInfoWnd)
            return nullptr;
        void* wnd = (void*)pPetInfoWnd;
        if (!IsValidPtr((uintptr_t)wnd))
            return nullptr;
        return wnd;
    } __except (EXCEPTION_EXECUTE_HANDLER) {
        return nullptr;
    }
}

// ---------------------------------------------------------------------------
// Walk pet window children and cache the "Pet 2" and "Pet 3" gauge pointers
// ---------------------------------------------------------------------------
void PetWindow::CreateGauge()
{
    if (!m_petInfoWnd)
        m_petInfoWnd = FindPetInfoWnd();

    if (!m_petInfoWnd) {
        return;
    }

    // Reset cached pointers before re-scanning
    m_newGauge1 = nullptr;
    m_newGauge2 = nullptr;

    // Find the gauges by their ScreenID directly
    m_newGauge1 = (void*)((CSidlScreenWnd*)m_petInfoWnd)->GetChildItem("Pet2HPGauge");
    m_newGauge2 = (void*)((CSidlScreenWnd*)m_petInfoWnd)->GetChildItem("Pet3HPGauge");
}

// ---------------------------------------------------------------------------
// Update a gauge widget with pet name and HP fill percentage (0-100)
// ---------------------------------------------------------------------------
void PetWindow::UpdateGauge(void* gauge, const char* petName, int hpPercent)
{
    if (!gauge)
        return;

    __try {
        if (hpPercent < 0)   hpPercent = 0;
        if (hpPercent > 100) hpPercent = 100;

        // CGaugeWnd fill scale is 0-1000 (CalcFillRect multiplies by 0.001f)
        int fillVal = hpPercent * 10;

        // Only update gauge if value changed
        if (*(int*)((uintptr_t)gauge + OFF_GAUGE_TARGETVAL) != fillVal) {
            *(float*)((uintptr_t)gauge + OFF_GAUGE_LASTFRAMEVAL)    = static_cast<float>(fillVal);
            *(int*)  ((uintptr_t)gauge + OFF_GAUGE_LASTFRAMETARGET) = fillVal;
            *(int*)  ((uintptr_t)gauge + OFF_GAUGE_TARGETVAL)       = fillVal;
            *(bool*) ((uintptr_t)gauge + OFF_GAUGE_USETARGETVAL)    = true;
        }

        // Update the WindowText (displayed pet name) in-place in the CStrRep buffer.
        uintptr_t repPtr = *(uintptr_t*)((uintptr_t)gauge + OFF_CXWND_WINDOWTEXT);
        int newLen = (int)strlen(petName);
        
        if (IsValidPtr(repPtr)) {
            char* currentData = (char*)(repPtr + OFF_CXSTR_REP_UTF8);
            if (strcmp(currentData, petName) != 0) {
                int alloc  = *(int*)(repPtr + 0x04); // CStrRep::alloc
                if (newLen < alloc) {
                    // Fits in existing buffer
                    memcpy(currentData, petName, newLen);
                    currentData[newLen] = '\0';
                    *(int*)(repPtr + OFF_CXSTR_REP_LEN) = newLen;
                } else {
                    // Need a bigger buffer, rewrite the windowtext pointer
                    void* newStr = CreateCXStr(petName);
                    if (newStr) {
                        *(void**)((uintptr_t)gauge + OFF_CXWND_WINDOWTEXT) = newStr;
                    }
                }
            }
        } else {
            // No buffer existed, make a new one
            void* newStr = CreateCXStr(petName);
            if (newStr) {
                *(void**)((uintptr_t)gauge + OFF_CXWND_WINDOWTEXT) = newStr;
            }
        }
    }
    __except (EXCEPTION_EXECUTE_HANDLER) {}
}

// ---------------------------------------------------------------------------
// Handle a click on one of our secondary pet gauges.
// Sets pTarget to the clicked pet so it becomes the active target.
// Returns true if handled, false to let the game process normally.
// ---------------------------------------------------------------------------
// SEH-only helper: no C++ objects in scope, so __try is always legal here.
static int ReadUIPetID()
{
    __try {
        if (pLocalPlayer)
            return *(int*)((uintptr_t)pLocalPlayer + OFF_SPAWN_PET_ID);
    }
    __except (EXCEPTION_EXECUTE_HANDLER) {}
    return 0;
}

std::vector<const TrackedPet*> PetWindow::GetVisiblePets()
{
    std::vector<const TrackedPet*> validPets;

    auto* multiPet = MultiPet::GetInstance();

    // No OP_PetList yet -> nothing authoritative to show, gauges stay empty.
    if (!multiPet || !multiPet->HavePetList())
        return validPets;

    // The tracked list contains ALL pets, including the one in the native pet
    // window. Filter that one out per call: which pet is focused changes when the
    // player clicks another pet, with no packet to tell us.
    const int uiPetID = ReadUIPetID();

    for (const auto& pet : multiPet->GetTrackedPets()) {
        if (static_cast<int>(pet.spawnID) == uiPetID)
            continue;
        // pSpawn is null while a pet is between despawn and respawn; it drops out
        // for those few frames and comes back once the pointer re-resolves.
        if (pet.pSpawn)
            validPets.push_back(&pet);
    }

    return validPets;
}

bool PetWindow::HandleClick(void* sender)
{
    if (!sender)
        return false;

    // Same list, same order, same filter as the display in OnPulse — the pet a
    // gauge targets is exactly the pet that gauge is showing.
    auto validPets = GetVisiblePets();

    if (sender == m_newGauge1 && validPets.size() >= 1) {
        pTarget = reinterpret_cast<EQPlayer*>(validPets[0]->pSpawn);
        return true;
    }

    if (sender == m_newGauge2 && validPets.size() >= 2) {
        pTarget = reinterpret_cast<EQPlayer*>(validPets[1]->pSpawn);
        return true;
    }

    return false;
}
