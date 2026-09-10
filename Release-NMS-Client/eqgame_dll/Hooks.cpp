// list of installed hooks at their address, if they are already patched in
#include <d3d9.h>
#include <Shlobj.h>
#include <fenv.h>
#include <fstream>
#include <time.h>


#include <algorithm>
#include <vector>
#include <iterator>
#include <map>
#include <string>

#include "RenderHooks.h"
#include "Hooks.h"

#include "MQ2Main.h"
#include "nms_disc_bands.h"

using namespace EQClasses;

extern bool isToggleSpellBookOnScribeEnabled;
extern uint32_t g_cauth_bitmask;
// NMS: true ONLY during a synchronous scribe trampoline call (set/cleared by
// NMS_BeginScribeSpoof / NMS_EndScribeSpoof). While true, GetSpellLevelNeeded
// returns 1 so the client-local scribe gate lets a not-yet-usable spell scribe.
// Scoped to the trampoline (not a wall-clock timer) so no UI repaint can ever
// observe the "1" and cache it -- that was the old "shows level 1 until zone" bug.
bool g_scribeInProgress = false;


std::vector<HookInfo> g_hooks;
extern uint32_t g_CharSelectBitmasks[250];

static const char* s_classIconNames[] = {
	"A_ClassAnim01", // Warrior
	"A_ClassAnim02", // Cleric
	"A_ClassAnim03", // Paladin
	"A_ClassAnim04", // Ranger
	"A_ClassAnim05", // Shadowknight
	"A_ClassAnim06", // Druid
	"A_ClassAnim07", // Monk
	"A_ClassAnim08", // Bard
	"A_ClassAnim09", // Rogue
	"A_ClassAnim10", // Shaman
	"A_ClassAnim11", // Necromancer
	"A_ClassAnim12", // Wizard
	"A_ClassAnim13", // Magician
	"A_ClassAnim14", // Enchanter
	"A_ClassAnim15", // Beastlord
	"A_ClassAnim16"  // Berserker
};

static const char* s_shortClassNames[] = {
	"Warrior", "Cleric", "Paladin", "Ranger", "Shadow Knight", "Druid", "Monk", "Bard",
	"Rogue", "Shaman", "Necromancer", "Wizard", "Magician", "Enchanter", "Beastlord", "Berserker"
};

void InstallHook(HookInfo hi)
{
	auto iter = std::find_if(g_hooks.begin(), g_hooks.end(),
		[&hi](const HookInfo & hookInfo)
		{
			return hi.name == hookInfo.name;
		});

	if (iter != g_hooks.end())
	{
		// hook already installed. Remove it.
		if (iter->address != 0)
		{
			RemoveDetour(iter->address);
		}
		g_hooks.erase(iter);
	}

	hi.patch(hi);
	g_hooks.push_back(hi);
}

template <typename T>
void InstallDetour(DWORD address, const T& detour, const T& trampoline, PCHAR name)
{
	HookInfo hookInfo;
	hookInfo.name = name;
	hookInfo.address = 0;
	hookInfo.patch = [&detour, &trampoline, address](HookInfo & hi)
	{
		hi.address = address;
		AddDetourf(hi.address, detour, trampoline, hi.name.c_str());
	};

	InstallHook(hookInfo);
}

DETOUR_TRAMPOLINE_EMPTY(void RenderHooks::ZoneRender_Injection_Trampoline());
DETOUR_TRAMPOLINE_EMPTY(HRESULT RenderHooks::Reset_Trampoline(D3DPRESENT_PARAMETERS* pPresentationParameters));
DETOUR_TRAMPOLINE_EMPTY(HRESULT RenderHooks::BeginScene_Trampoline());
DETOUR_TRAMPOLINE_EMPTY(HRESULT RenderHooks::EndScene_Trampoline());

// NMS: Hook to suppress duplicate client skillup messages
#define StringTable__getString_x 0x7D0660

using getString_t = char* (__fastcall*)(void*, void*, unsigned long, bool*);

DETOUR_TRAMPOLINE_EMPTY(
	char* __fastcall getString_Trampoline(void*, void*, unsigned long, bool*)
);

// NMS: ROF2 client RVA
// Needed for CanUseItems Hook
#define CharacterZoneClient__CanUseItem_x 0x44C430

using CanUseItem_t =
bool(__fastcall*)(void*, void*, const void*, bool, bool);

DETOUR_TRAMPOLINE_EMPTY(
	bool __fastcall CanUseItem_Trampoline(
		void*, void*, const void*, bool, bool)
);

// NMS: CanUseMemorizedSpellSlot Hook to unlock all 12 spell gems at level 1 (since Mnemonic Retention is auto-granted at level 1)
#define CharacterZoneClient__CanUseMemorizedSpellSlot_x 0x433BC0

using CanUseMemorizedSpellSlot_t = bool(__fastcall*)(void*, void*, int);

DETOUR_TRAMPOLINE_EMPTY(
	bool __fastcall CanUseMemorizedSpellSlot_Trampoline(void*, void*, int)
);

// NMS: Hook for PcZoneClient::CanEquipItem to fix yellow tint on items in inventory when player is not the correct race or deity
#define PcZoneClient__CanEquipItem_x 0x583550

using CanEquipItem_t =
bool(__fastcall*)(void*, void*, const void*, int, bool, bool);

DETOUR_TRAMPOLINE_EMPTY(
	bool __fastcall CanEquipItem_Trampoline(
		void*, void*, const void*, int, bool, bool)
);

// NMS: Hook for EQ_Spell::GetSpellLevelNeeded to allow multiclass characters to scribe and filter spells of all active archetypes
#define EQ_Spell__GetSpellLevelNeeded_x 0x4AF700

using GetSpellLevelNeeded_t = unsigned char(__fastcall*)(void*, void*, int);

DETOUR_TRAMPOLINE_EMPTY(
	unsigned char __fastcall GetSpellLevelNeeded_Trampoline(void*, void*, int)
);

// NMS: Hook for EQ_Character::GetUsableClasses to fix merchant 'Show only items I can use' filter
#define EQ_Character__GetUsableClasses_x 0x7B4CE0

using GetUsableClasses_t = int(__fastcall*)(void*, void*, bool, bool);

DETOUR_TRAMPOLINE_EMPTY(
	int __fastcall GetUsableClasses_Trampoline(void*, void*, bool, bool)
);

// NMS: EQ_Character::BardCastBard Hook to allow multiclass bards to cast non-bard spells without them toggling
#define EQ_Character__BardCastBard_x                               0x432960

using BardCastBard_t = int(__fastcall*)(const void*, void*, const void*, int);

DETOUR_TRAMPOLINE_EMPTY(
	int __fastcall BardCastBard_Trampoline(const void*, void*, const void*, int)
);

// NMS: CSkillMgr::IsAvailable Hook
#define CSkillMgr__IsAvailable_x                                   0x5BAE40
using IsAvailable_t = bool(__fastcall*)(void*, void*, int);
DETOUR_TRAMPOLINE_EMPTY(
	bool __fastcall CSkillMgr__IsAvailable_Trampoline(void*, void*, int)
);

// NMS: CharacterZoneClient::HasSkill Hook
#define CharacterZoneClient__HasSkill_x                            0x44A1B0
using HasSkill_t = bool(__fastcall*)(void*, void*, int);
DETOUR_TRAMPOLINE_EMPTY(
	bool __fastcall CharacterZoneClient__HasSkill_Trampoline(void*, void*, int)
);

// NMS: CTrackingWnd::SetTrackingList / CTrackingWnd::Activate Hooks.
// The Track Sort feature spoofs Ranger around the tracking window's
// OnProcessFrame/WndNotification vtable calls (MQ2Pulse.cpp), which covers
// picking a sort and keeping the combobox alive. But the LIST itself is
// sorted in SetTrackingList, called from the OP_Track packet handler every
// Track press and every 6s auto-update reply -- outside both vtable hooks --
// and it forces sort NORMAL when CHARINFO2->Class (+0x3374) != Ranger. That
// made the list revert to normal order on every refresh while the dropdown
// kept the picked value. Activate has the same problem on window open: it
// calls UpdateTrackingControls unspoofed, which zeroes the saved sort type.
#define CTrackingWnd__SetTrackingList_x                            0x77A930
using TrackSetList_t = void(__fastcall*)(void*, void*, void*, unsigned int);
DETOUR_TRAMPOLINE_EMPTY(
	void __fastcall CTrackingWnd__SetTrackingList_Trampoline(void*, void*, void*, unsigned int)
);

#define CTrackingWnd__Activate_x                                   0x77A6E0
using TrackActivate_t = void(__fastcall*)(void*, void*);
DETOUR_TRAMPOLINE_EMPTY(
	void __fastcall CTrackingWnd__Activate_Trampoline(void*, void*)
);

// NMS: ExecuteCmd Hook
#define __ExecuteCmd_x                                             0x4D7230
using ExecuteCmd_t = BOOL(__cdecl*)(DWORD, BOOL, PVOID);
DETOUR_TRAMPOLINE_EMPTY(
	BOOL __cdecl ExecuteCmd_Trampoline(DWORD, BOOL, PVOID)
);

// NMS: /alternateadv command-handler Hook -- makes the AA window's "/alt toggle <id>" work.
// This is the leaf handler out of EQ's __CommandList, NOT CEverQuest::InterpretCmd --
// MQ2's own command API already detours InterpretCmd (see MQ2CommandAPI.cpp
// InitializeMQ2Commands), so a second detour there fights with it and loses.
// Handler shape comes from the CMDLIST entry in EQData.h: void __cdecl(PSPAWNINFO, PCHAR).
#define cmd_alternateadv_handler_x                                 0x004F73E0
using EQCommandFn_t = void(__cdecl*)(PSPAWNINFO, PCHAR);
DETOUR_TRAMPOLINE_EMPTY(
	void __cdecl cmd_alternateadv_Trampoline(PSPAWNINFO, PCHAR)
);

// ============================================================
// NMS: Discipline / Skill reuse-timer system
// ------------------------------------------------------------
// Full decompiled spec: eqlib/include/eqlib/offsets/eqgame.h "Section 40".
// The stock RoF2 client stores disc reuse timers in a FIXED 20-slot array
// indexed by CARecastTimerID (spell +0x198 == DB spells_new.EndurTimerIndex).
// Native GetDisciplineReuseTimer/SetDisciplineReuseTimer/doCombatAbility all
// gate on index < 0x14 (20); anything >= 20 is silently dropped. With only 20
// slots (our data already uses 1..19) classes MUST share timers. The fix is to
// replace the array with an unbounded map so discs reassigned to keys >= 20
// (banded per class) each get their own cooldown: keys 0..19 stay 100%
// native (untouched), keys >= 20 are governed by g_discTimers below. This makes
// the change ZERO-regression until disc EndurTimerIndex values are reassigned
// to the >= 20 range. Timers are absolute UNIX SECONDS (native uses __time32,
// so units match). Single-threaded: every touch point (doCombatAbility, the CA
// window refresh, and the future server-packet handler) runs on the game's
// main thread, so no locking is needed.
// ============================================================
#define NMS_GetDisciplineReuseTimer_x                             0x57F810
#define NMS_SetDisciplineReuseTimer_x                             0x57F7F0
#define NMS_doCombatAbility_x                                     0x5808C0
static const int NMS_DISC_NATIVE_SLOTS = 20;   // native array size: keys 0..19

// CARecastTimerID -> ready time (unix seconds). Empty until a disc is used /
// the server pushes a timer; a missing key means "ready now".
static std::map<int, int> g_discTimers;
static inline int NMS_NowSec() { return (int)_time32(nullptr); }

// GetDisciplineReuseTimer: int __stdcall(int index)  [asm: MOV EAX,[ESP+4]; RET 4]
using GetDiscReuse_t = int(__stdcall*)(int);
DETOUR_TRAMPOLINE_EMPTY(
	int __stdcall NMS_GetDisciplineReuseTimer_Trampoline(int)
);

// SetDisciplineReuseTimer: void __stdcall(int index, int readyTime)  [asm: RET 8]
// Called by the packet processor (0x4C3250) when OP_DisciplineTimer arrives from the
// server, i.e. this is the SERVER-authoritative timer feed.
using SetDiscReuse_t = void(__stdcall*)(int, int);
DETOUR_TRAMPOLINE_EMPTY(
	void __stdcall NMS_SetDisciplineReuseTimer_Trampoline(int, int)
);

// doCombatAbility: bool __thiscall(int spellID, int dummy)  [asm: MOV EBP,ECX]
using DoCombatAbility_t = bool(__fastcall*)(void*, void*, int, int);
DETOUR_TRAMPOLINE_EMPTY(
	bool __fastcall NMS_doCombatAbility_Trampoline(void*, void*, int, int)
);

// Public entry for authoritative timer sets (server OP_DisciplineTimer, phase 2)
// and zone/logout clears. Kept here so it shares g_discTimers + the main thread.
void NMSDiscTimers_SetTimer(int timerKey, int durationSec)
{
	if (timerKey >= 0)
		g_discTimers[timerKey] = NMS_NowSec() + durationSec;
}
void NMSDiscTimers_ClearAll() { g_discTimers.clear(); }

// Write the full banded CARecastTimerID back into each disc after the native
// client wraps them (mod 20) at load. Without this, WAR '23' and MNK '143' both
// collapse to '3' and re-collide; with it, the >=20 map shim keeps them apart.
void NMSDiscTimers_ApplyBands()
{
	if (!pSpellMgr) return;
	for (int i = 0; i < g_discBandCount; ++i)
	{
		PSPELL sp = GetSpellByID(g_discBandTable[i].spellID);
		if (sp) sp->CARecastTimerID = g_discBandTable[i].banded;
	}
}

// Called each game pulse: (re)apply the bands whenever they aren't in effect —
// first spell load, and after any reload that re-wraps them. Cheap probe first.
void NMSDiscTimers_MaintainBands()
{
	if (gGameState != GAMESTATE_INGAME || !pSpellMgr) return;
	PSPELL probe = GetSpellByID(4514); // Mighty Strike -> banded 23
	if (probe && probe->CARecastTimerID != 23)
		NMSDiscTimers_ApplyBands();
}

// NMS: CInvSlot::UpdateItem hook to fix yellow tint
#define CInvSlot__UpdateItem_x 0x694D20

// CInvSlot::HandleRButtonUp - fires when player right-clicks any inventory slot.
// RVA for RoF2: 0x697250
#define CInvSlot__HandleRButtonUp_x 0x697250

struct CInvSlotWnd_Hook {
	BYTE pad[0x2a0]; // Offset to BGTintRollover in rof2
	DWORD BGTintRollover;
	DWORD BGTintNormal;
};


struct CInvSlot_Hook {
	BYTE pad[0x04]; // Offset to pInvSlotWnd in rof2 (after vtable)
	CInvSlotWnd_Hook* pInvSlotWnd;
};

using UpdateItem_t = void(__fastcall*)(CInvSlot_Hook*, void*);

DETOUR_TRAMPOLINE_EMPTY(
	void __fastcall CInvSlot__UpdateItem_Trampoline(CInvSlot_Hook*, void*)
);

// HandleRButtonUp: void __fastcall CInvSlot::HandleRButtonUp(CXPoint*)
using HandleRButtonUp_t = void(__fastcall*)(void*, void*, void*);

DETOUR_TRAMPOLINE_EMPTY(
	void __fastcall CInvSlot__HandleRButtonUp_Trampoline(void*, void*, void*)
);

// CListWnd::GetItemIcon detour
#define CListWnd__GetItemIcon_x 0x853860

using GetItemIcon_t = class CTextureAnimation* (__fastcall*)(CListWnd*, void*, int, int);

DETOUR_TRAMPOLINE_EMPTY(
	class CTextureAnimation* __fastcall CListWnd__GetItemIcon_Trampoline(CListWnd*, void*, int, int)
);

// // CListWnd::GetItemText detour
#define CListWnd__GetItemText_x 0x853710
using GetItemText_t = class CXStr* (__fastcall*)(CListWnd*, void*, CXStr*, int, int);

DETOUR_TRAMPOLINE_EMPTY(
	class CXStr* __fastcall CListWnd__GetItemText_Trampoline(CListWnd*, void*, CXStr*, int, int)
);

// CListWnd::SetColumnJustification detour to fix text alignment
#define CListWnd__SetColumnJustification_x 0x853F10
using SetColumnJustification_t = void(__fastcall*)(CListWnd*, void*, int, int);

DETOUR_TRAMPOLINE_EMPTY(
	void __fastcall CListWnd__SetColumnJustification_Trampoline(CListWnd*, void*, int, int)
);

// NMS: CMerchantWnd::DisplayBuyOrSellPrice - enable Sell button for bags, suppress garbage price.
#define CMerchantWnd__DisplayBuyOrSellPrice_x 0x6EF750
#define CXWND_ENABLED_OFFSET 0x01a

using DisplayBuyOrSellPrice_t = void(__fastcall*)(void*, void*, const void*, bool);

DETOUR_TRAMPOLINE_EMPTY(
	void __fastcall CMerchantWnd__DisplayBuyOrSellPrice_Trampoline(void*, void*, const void*, bool)
);

// NMS: CMerchantWnd::SelectBuySellSlot - fires when player places item in the sell slot.
// We use it to set g_bagInSellSlot BEFORE DisplayBuyOrSellPrice fires (bag fires items-first).
#define CMerchantWnd__SelectBuySellSlot_x 0x6EFA00

using SelectBuySellSlot_t = void(__fastcall*)(void*, void*, int, void*);

DETOUR_TRAMPOLINE_EMPTY(
	void __fastcall CMerchantWnd__SelectBuySellSlot_Trampoline(void*, void*, int, void*)
);

// NMS: ItemBase::IsEmpty - detour to make client think our bulk sell bag is empty
#define ItemBase__IsEmpty_x 0x7B22A0

using IsEmpty_t = bool(__fastcall*)(void*, void*);

DETOUR_TRAMPOLINE_EMPTY(
	bool __fastcall ItemBase__IsEmpty_Trampoline(void*, void*)
);



// Global: true when a bag is currently in the merchant sell slot.
static bool g_bagInSellSlot = false;
static bool g_bagIsSellable = false;

static PCONTENTS g_pBagContents = nullptr;
static BYTE g_origNoDrop = 0;

static void RestoreBagNoDropState()
{
	if (g_pBagContents && !IsBadReadPtr(g_pBagContents, 0x100)) {
		__try {
			_ITEMINFO* pInfo = GetItemFromContents(g_pBagContents);
			if (pInfo && !IsBadReadPtr(pInfo, 0x150)) {
				pInfo->NoDrop = g_origNoDrop;
			}
		} __except (EXCEPTION_EXECUTE_HANDLER) {}
	}
	g_pBagContents = nullptr;
}

static void __fastcall CListWnd__SetColumnJustification_Detour(CListWnd* pList, void* pEdx, int col, int justify)
{
	if (pList && (col == 2 || col == 3)) {
		CXMLData* pXml = pList->GetXMLData();
		char szScreenID[256] = { 0 };
		if (pXml) GetCXStr(pXml->ScreenID.Ptr, szScreenID, 256);
		if (szScreenID[0] != 0 && _stricmp(szScreenID, "Character_List") == 0) {
			justify = 0; // Force Left Justify
		}
	}
	CListWnd__SetColumnJustification_Trampoline(pList, pEdx, col, justify);
}

static _ITEMINFO* GetItemInfoFromListRowData(uint32_t data)
{
	if (data == 0) return nullptr;

	if (!IsBadReadPtr((const void*)data, sizeof(_CONTENTS)))
	{
		_CONTENTS* pContents = (_CONTENTS*)data;
		_ITEMINFO* pInfo = nullptr;
		__try {
			pInfo = GetItemFromContents(pContents);
		} __except (EXCEPTION_EXECUTE_HANDLER) {
			pInfo = nullptr;
		}
		if (pInfo && !IsBadReadPtr(pInfo, sizeof(_ITEMINFO)))
		{
			return pInfo;
		}
	}

	if (!IsBadReadPtr((const void*)data, sizeof(void*)))
	{
		DWORD ptr = *(DWORD*)data;
		if (ptr && !IsBadReadPtr((const void*)ptr, sizeof(_CONTENTS)))
		{
			_CONTENTS* pContents = (_CONTENTS*)ptr;
			_ITEMINFO* pInfo = nullptr;
			__try {
				pInfo = GetItemFromContents(pContents);
			} __except (EXCEPTION_EXECUTE_HANDLER) {
				pInfo = nullptr;
			}
			if (pInfo && !IsBadReadPtr(pInfo, sizeof(_ITEMINFO)))
			{
				return pInfo;
			}
		}
	}

	if (!IsBadReadPtr((const void*)data, sizeof(_ITEMINFO)))
	{
		_ITEMINFO* pInfo = (_ITEMINFO*)data;
		if (pInfo->Name[0] >= 32 && pInfo->Name[0] <= 126)
		{
			return pInfo;
		}
	}

	return nullptr;
}

static PSPELL FindSpellFromItemName(const char* szItemName)
{
	if (!szItemName || szItemName[0] == 0) return nullptr;

	static std::map<std::string, PSPELL> s_spellCache;
	std::string nameStr(szItemName);

	std::map<std::string, PSPELL>::iterator it = s_spellCache.find(nameStr);
	if (it != s_spellCache.end()) {
		return it->second;
	}

	// Helper to clean a spell name by keeping only alphanumeric characters in lowercase
	auto cleanNameFn = [](const char* name) -> std::string {
		std::string cleaned;
		if (!name) return cleaned;
		for (const char* p = name; *p != '\0'; ++p) {
			if (isalnum((unsigned char)*p)) {
				cleaned += tolower((unsigned char)*p);
			}
		}
		return cleaned;
	};

	static std::map<std::string, PSPELL> s_cleanSpellMap;
	static bool s_cleanSpellMapInitialized = false;
	if (!s_cleanSpellMapInitialized) {
		s_cleanSpellMapInitialized = true;
		for (DWORD id = 1; id < TOTAL_SPELL_COUNT; id++) {
			PSPELL sp = GetSpellByID(id);
			if (sp && sp->Name && sp->Name[0] != '\0') {
				std::string clean = cleanNameFn(sp->Name);
				
				bool isPlayerSpell = false;
				for (int c = 0; c < 16; c++) {
					if (sp->Level[c] > 0 && sp->Level[c] < 255) {
						isPlayerSpell = true;
						break;
					}
				}

				std::map<std::string, PSPELL>::iterator existing = s_cleanSpellMap.find(clean);
				if (existing == s_cleanSpellMap.end()) {
					s_cleanSpellMap[clean] = sp;
				} else if (isPlayerSpell) {
					bool existingIsPlayer = false;
					for (int c = 0; c < 16; c++) {
						if (existing->second->Level[c] > 0 && existing->second->Level[c] < 255) {
							existingIsPlayer = true;
							break;
						}
					}
					if (!existingIsPlayer) {
						s_cleanSpellMap[clean] = sp;
					}
				}
			}
		}
	}

	// 1. Try fuzzy clean name match first (prioritizing player spells and handling punctuation)
	std::string cleanedInput = cleanNameFn(szItemName);
	if (_strnicmp(szItemName, "Spell: ", 7) == 0) {
		cleanedInput = cleanNameFn(szItemName + 7);
	} else if (_strnicmp(szItemName, "Song: ", 6) == 0) {
		cleanedInput = cleanNameFn(szItemName + 6);
	} else if (_strnicmp(szItemName, "Ancient: ", 9) == 0) {
		cleanedInput = cleanNameFn(szItemName + 9);
	} else if (_strnicmp(szItemName, "Tome: ", 6) == 0) {
		cleanedInput = cleanNameFn(szItemName + 6);
	} else if (_strnicmp(szItemName, "Tome of ", 8) == 0) {
		cleanedInput = cleanNameFn(szItemName + 8);
	}

	std::map<std::string, PSPELL>::iterator itClean = s_cleanSpellMap.find(cleanedInput);
	if (itClean != s_cleanSpellMap.end()) {
		s_spellCache[nameStr] = itClean->second;
		return itClean->second;
	}

	// 2. Native GetSpellByName fallback
	PSPELL pSpell = GetSpellByName((char*)szItemName);
	if (pSpell) {
		s_spellCache[nameStr] = pSpell;
		return pSpell;
	}

	if (_strnicmp(szItemName, "Spell: ", 7) == 0) {
		pSpell = GetSpellByName((char*)(szItemName + 7));
		if (pSpell) {
			s_spellCache[nameStr] = pSpell;
			return pSpell;
		}
	}
	if (_strnicmp(szItemName, "Song: ", 6) == 0) {
		pSpell = GetSpellByName((char*)(szItemName + 6));
		if (pSpell) {
			s_spellCache[nameStr] = pSpell;
			return pSpell;
		}
	}
	if (_strnicmp(szItemName, "Ancient: ", 9) == 0) {
		pSpell = GetSpellByName((char*)(szItemName + 9));
		if (pSpell) {
			s_spellCache[nameStr] = pSpell;
			return pSpell;
		}
	}
	if (_strnicmp(szItemName, "Tome: ", 6) == 0) {
		pSpell = GetSpellByName((char*)(szItemName + 6));
		if (pSpell) {
			s_spellCache[nameStr] = pSpell;
			return pSpell;
		}
	}
	if (_strnicmp(szItemName, "Tome of ", 8) == 0) {
		pSpell = GetSpellByName((char*)(szItemName + 8));
		if (pSpell) {
			s_spellCache[nameStr] = pSpell;
			return pSpell;
		}
	}

	s_spellCache[nameStr] = nullptr;
	return nullptr;
}

// NMS: Resolve the spell-scroll at (pList,row) and, if it is one, write its multiclass-min
// level ("--" if no class can use it) into pOut. Returns true if the row is a spell scroll
// (pOut was written), false otherwise (caller leaves the native cell/text untouched).
// Shared by the merchant Lvl populate (UpdateList) and the Bazaar Lvl display (GetItemText).
static bool NMS_ComputeSpellRowLvl(CListWnd* pList, void* pEdx, int row, const char* szScreenID, CXStr* pOut)
{
	extern uint32_t g_cauth_bitmask;
	if (!pList || !pOut) return false;

	uint32_t data = pList->GetItemData(row);

	// Item name (col 1) drives the fast cached spell lookup.
	CXStr strItemName("");
	CListWnd__GetItemText_Trampoline(pList, pEdx, &strItemName, row, 1);
	char szItemName[128] = { 0 };
	GetCXStr(strItemName.Ptr, szItemName, 128);

	PSPELL pSpell = FindSpellFromItemName(szItemName);
	if (!pSpell) {
		_ITEMINFO* pInfo = nullptr;
		// Merchant slot-array lookup (ItemList only)
		CMerchantWnd* pMerchantWindow = (ppMerchantWnd && *ppMerchantWnd) ? *ppMerchantWnd : nullptr;
		if (pMerchantWindow && szScreenID && (_stricmp(szScreenID, "ItemList") == 0 || _stricmp(szScreenID, "MW_ItemList") == 0)) {
			EQUIStructs::EQMERCHWINDOW* pMerch = (EQUIStructs::EQMERCHWINDOW*)pMerchantWindow;
			if (!IsBadReadPtr(pMerch, sizeof(EQUIStructs::EQMERCHWINDOW)) && pMerch->pMerchOther) {
				EQUIStructs::merch_other* pOther = pMerch->pMerchOther;
				if (!IsBadReadPtr(pOther, sizeof(EQUIStructs::merch_other)) && pOther->pMerchData) {
					EQUIStructs::merchdata* pData = pOther->pMerchData;
					if (!IsBadReadPtr(pData, sizeof(EQUIStructs::merchdata)) && pData->pMerchArray) {
						struct EQUIStructs::_CONTENTSARRAY* pArray = pData->pMerchArray;
						if (!IsBadReadPtr(pArray, sizeof(struct EQUIStructs::_CONTENTSARRAY)) && data < pData->MerchSlots) {
							_CONTENTS* pContents = pArray->Array[data];
							if (pContents && !IsBadReadPtr(pContents, sizeof(_CONTENTS))) {
								pInfo = GetItemFromContents(pContents);
							}
						}
					}
				}
			}
		}
		if (!pInfo) pInfo = GetItemInfoFromListRowData(data);
		if (pInfo && (pInfo->Type == ITEMTYPE_BOOK || pInfo->ItemType == 20) && pInfo->Scroll.SpellID != 0) {
			pSpell = GetSpellByID(pInfo->Scroll.SpellID);
		}
	}

	if (!pSpell) return false;

	BYTE minLvl = 255;
	// 1. lowest level among the player's active multiclasses
	if (g_cauth_bitmask != 0) {
		for (int i = 0; i < 16; i++)
			if (g_cauth_bitmask & (1 << i)) { BYTE lvl = pSpell->Level[i]; if (lvl > 0 && lvl < minLvl) minLvl = lvl; }
	}
	// 2. fallback: lowest level across ALL classes if none of the player's can use it
	if (minLvl == 255) {
		for (int i = 0; i < 16; i++) { BYTE lvl = pSpell->Level[i]; if (lvl > 0 && lvl < minLvl) minLvl = lvl; }
	}

	if (minLvl < 255) {
		char szLvl[16];
		sprintf_s(szLvl, "%d", minLvl);
		SetCXStr(&pOut->Ptr, szLvl);
	} else {
		SetCXStr(&pOut->Ptr, "--");
	}
	return true;
}

static class CXStr* __fastcall CListWnd__GetItemText_Detour(CListWnd* pList, void* pEdx, CXStr* pOut, int row, int col)
{
	if (pList && row >= 0) {
		__try {
			CXMLData* pXml = pList->GetXMLData();
			char szScreenID[256] = { 0 };
			if (pXml) GetCXStr(pXml->ScreenID.Ptr, szScreenID, 256);

			if (szScreenID[0] != 0 && _stricmp(szScreenID, "Character_List") == 0) {
				if (col < 3) {
					SetCXStr(&pOut->Ptr, "");
					return pOut;
				}
				if (col == 3) {
					// Force Left Justification every time text is requested
					pList->SetColumnJustification(3, 0);

					CXStr strName("");
					CXStr strLevel("");
					CListWnd__GetItemText_Trampoline(pList, pEdx, &strName, row, 2);
					CListWnd__GetItemText_Trampoline(pList, pEdx, &strLevel, row, 3);
					
					char szName[64] = {0}, szLevel[16] = {0};
					GetCXStr(strName.Ptr, szName, 64);
					GetCXStr(strLevel.Ptr, szLevel, 16);
					
					char szCombined[128];
					if (szName[0] != 0) {
						sprintf(szCombined, "%s (%s)", szName, szLevel);
					} else {
						sprintf(szCombined, "%s", szLevel);
					}
					
					SetCXStr(&pOut->Ptr, szCombined);
					return pOut;
				}
			}
			else if (szScreenID[0] != 0 &&
			((_stricmp(szScreenID, "BZR_ItemList") == 0 || _stricmp(szScreenID, "BZR_BazaarItemList") == 0) && col == 8)
		) {
				// Bazaar Lvl column (col 8): compute the multiclass-min level for spell scrolls
				// at display time. (The merchant's col 7 is handled by the UpdateList populate,
				// which writes the level into the real cell so native display + native sort both work.)
				CXStr* pResult = CListWnd__GetItemText_Trampoline(pList, pEdx, pOut, row, col);
				NMS_ComputeSpellRowLvl(pList, pEdx, row, szScreenID, pOut);
				return pResult;
			}
		}
		__except (EXCEPTION_EXECUTE_HANDLER) {}
	}
	return CListWnd__GetItemText_Trampoline(pList, pEdx, pOut, row, col);
}

// -----------------------------------------------------------------------
// Merchant Lvl column (multiclass)
//
// The native spell merchant is hard-keyed to the player's single VISIBLE class, so a
// multiclass toon sees "--" for its real classes' spells. Fix: after the list is (re)built,
// write the multiclass-min level into the REAL col-7 cell (in the UpdateList hook below).
// Real cell data => the native column DISPLAYS it AND native Sort orders by it, so no per-cell
// GetItemText override and no CListWnd::Sort hook are needed. (The Bazaar Lvl column is still
// computed at display time in GetItemText via the shared NMS_ComputeSpellRowLvl helper.)
// -----------------------------------------------------------------------
using UpdateList_t = void(__fastcall*)(void*, void*);
DETOUR_TRAMPOLINE_EMPTY(void __fastcall CMerchantWnd__UpdateList_Trampoline(void*, void*));

static void __fastcall CMerchantWnd__UpdateList_Detour(void* pHandler, void* pEdx)
{
	// Rebuild the list first.
	CMerchantWnd__UpdateList_Trampoline(pHandler, pEdx);

	// Then overwrite each spell-scroll's Lvl cell (col 7) with the multiclass-min level, so the
	// native column displays it AND native Sort orders by it. Non-spell rows (tomes/gear) keep
	// their native RequiredLevel cell. Values are space-padded so the native string-compare
	// sort is numerically correct (" 1" < " 9" < "55").
	__try {
		CMerchantWnd* pMerchWnd = (ppMerchantWnd && *ppMerchantWnd) ? *ppMerchantWnd : nullptr;
		if (!pMerchWnd) return;
		CListWnd* pList = (CListWnd*)((CSidlScreenWnd*)pMerchWnd)->GetChildItem((PCHAR)"ItemList");
		if (!pList) return;

		typedef void(__fastcall* SetItemText_t)(CListWnd*, void*, int, int, CXStr*);
		SetItemText_t fnSet = (SetItemText_t)(CListWnd__SetItemText_x - 0x400000 + (DWORD)GetModuleHandle(NULL));
		const int LVL_COL = 7;

		for (int row = 0; row < 10000; row++) {
			uint32_t rowData = pList->GetItemData(row);
			if (rowData == 0xFFFFFFFF) break;

			CXStr cxLvl("");
			if (!NMS_ComputeSpellRowLvl(pList, nullptr, row, "ItemList", &cxLvl))
				continue; // non-spell row: leave the native RequiredLevel cell untouched

			char szLvl[8] = { 0 };
			GetCXStr(cxLvl.Ptr, szLvl, sizeof(szLvl));
			if (szLvl[0] != 0 && szLvl[0] != '-') {
				char szPadded[8];
				sprintf_s(szPadded, "%3d", atoi(szLvl));
				SetCXStr(&cxLvl.Ptr, szPadded);
			}
			fnSet(pList, nullptr, row, LVL_COL, &cxLvl);
		}
	} __except(EXCEPTION_EXECUTE_HANDLER) {}
}


struct CharSelectInfo {
	char Name[64];
	uint32_t Classes;
	uint32_t OriginalClass;
};
extern CharSelectInfo g_CharSelectInfo[250];
extern uint32_t g_CharSelectCount;

static class CTextureAnimation* __fastcall CListWnd__GetItemIcon_Detour(CListWnd* pList, void* pEdx, int row, int col)
{
	if (pList && col < 3 && row >= 0) { 
		__try {
			CXMLData* pXml = pList->GetXMLData();
			char szScreenID[256] = { 0 };
			if (pXml) GetCXStr(pXml->ScreenID.Ptr, szScreenID, 256);

			if (szScreenID[0] != 0 && _stricmp(szScreenID, "Character_List") == 0) {
				// Use Name-based lookup for reliability
				CXStr strName("");
				CListWnd__GetItemText_Trampoline(pList, pEdx, &strName, row, 2); // Logical Name is in Col 2
				char szName[64] = {0};
				GetCXStr(strName.Ptr, szName, 64);
				
				uint32_t bitmask = 0;
				if (szName[0] != 0) {
					for (uint32_t i = 0; i < g_CharSelectCount; i++) {
						if (_stricmp(g_CharSelectInfo[i].Name, szName) == 0) {
							bitmask = g_CharSelectInfo[i].Classes;
							break;
						}
					}
				}

				CSidlManager** ppSidlMgr = (CSidlManager**)pinstCSidlManager;
				if (bitmask != 0 && ppSidlMgr && *ppSidlMgr) {
					int foundCount = 0;
					for (int i = 0; i < 16; i++) {
						if (bitmask & (1 << i)) {
							if (foundCount == col) {
								typedef CTextureAnimation* (__thiscall* FindAnim_t)(CSidlManager*, CXStr*);
								FindAnim_t pFindAnim = (FindAnim_t)CSidlManager__FindAnimation1;

								char szIconName[64];
								sprintf(szIconName, "%sIcon", s_shortClassNames[i]);

								CXStr strIcon(szIconName);
								CTextureAnimation* pAnim = pFindAnim(*ppSidlMgr, &strIcon);
								
								if (pAnim) return pAnim;
								break;
							}
							foundCount++;
						}
					}
				}
			}
		}
		__except (EXCEPTION_EXECUTE_HANDLER) {}
	}

	return CListWnd__GetItemIcon_Trampoline(pList, pEdx, row, col);
}

// Flag set by the right-click hook; consumed by Heartbeat() the next game frame
// to call Show() outside of the hook's call stack (avoids re-entrancy freeze).
bool g_pendingSpellBookShow = false;
// Set when we open the spell book via scribe; cleared when player stands up.
bool g_spellBookOpenedByScribe = false;

// Scribe timer: defers the actual trampoline call (server scribing) until
// SCRIBE_DURATION_MS milliseconds after the right-click.
#define SCRIBE_DURATION_MS  100   // 100 ms instead of 1500 ms

struct CXPoint2 { int x; int y; };

static void*    g_pendingScribeThis  = nullptr;
static void*    g_pendingScribeEdx   = nullptr;
static CXPoint2 g_pendingScribePoint = {0, 0};
static DWORD    g_scribeEndTick      = 0;
bool            g_scribeTimerActive  = false;
static bool     g_scribeTimerFiring  = false;
static BYTE     g_pendingScribeTargetClass = 0;

// NMS: Scribe class/level spoof helper. The client's local scribe gate checks the
// player's *visible* class+level (via GetSpellLevelNeeded / CanUseItem) and would
// refuse to scribe a spell that class can't yet use. We briefly spoof
// Class=targetClass, Level=100 around the scribe trampoline so the gate passes;
// the server does the real eligibility check. The save/spoof/restore was identical
// at all three scribe call sites, so it lives here.
struct ScribeSpoofState {
    BYTE  spawnClass;
    BYTE  spawnLevel;
    DWORD ci2Class;
    DWORD ci2Level;
    bool  hasChar2;
};

static ScribeSpoofState NMS_BeginScribeSpoof(BYTE targetClass)
{
    g_scribeInProgress = true;   // active only until the paired NMS_EndScribeSpoof
    ScribeSpoofState s = {};
    if (!pLocalPlayer)
        return s;

    s.spawnClass = ((PSPAWNINFO)pLocalPlayer)->Class;
    s.spawnLevel = ((PSPAWNINFO)pLocalPlayer)->Level;

    PCHARINFO2 pCharInfo2 = GetCharInfo2();
    if (pCharInfo2) {
        s.ci2Class = pCharInfo2->Class;
        s.ci2Level = pCharInfo2->Level;
        s.hasChar2 = true;
    }

    ((PSPAWNINFO)pLocalPlayer)->Level = 100;
    if (s.hasChar2)
        pCharInfo2->Level = 100;

    if (targetClass != 0) {
        ((PSPAWNINFO)pLocalPlayer)->Class = targetClass;
        if (s.hasChar2)
            pCharInfo2->Class = targetClass;
    }

    return s;
}

static void NMS_EndScribeSpoof(const ScribeSpoofState& s)
{
    g_scribeInProgress = false;
    if (!pLocalPlayer)
        return;

    ((PSPAWNINFO)pLocalPlayer)->Class = s.spawnClass;
    ((PSPAWNINFO)pLocalPlayer)->Level = s.spawnLevel;

    if (s.hasChar2) {
        PCHARINFO2 pCharInfo2 = GetCharInfo2();
        if (pCharInfo2) {
            pCharInfo2->Class = s.ci2Class;
            pCharInfo2->Level = s.ci2Level;
        }
    }
}

// Called from Heartbeat() every frame. Fires the deferred trampoline when
// the timer has expired and pLocalPlayer is still valid.
void FirePendingScribeIfReady()
{
    if (!g_scribeTimerActive)
        return;
    if (GetTickCount() < g_scribeEndTick)
        return;

    g_scribeTimerActive = false;

    // Safety: bail if player went away during the timer wait.
    if (!g_pendingScribeThis || !pLocalPlayer)
        return;

    // Spoof class/level so the client-local scribe gate passes; server does the real check.
    ScribeSpoofState spoof = NMS_BeginScribeSpoof(g_pendingScribeTargetClass);

    g_scribeTimerFiring = true;
    CInvSlot__HandleRButtonUp_Trampoline(g_pendingScribeThis, g_pendingScribeEdx, &g_pendingScribePoint);
    g_scribeTimerFiring = false;

    NMS_EndScribeSpoof(spoof);

    g_pendingScribeThis = nullptr;
    g_pendingScribeTargetClass = 0;
}



static char* __fastcall getString_Detour(void* pThis, void* pEdx, unsigned long id, bool* pBool)
{
	if (id == 1060) {
		if (pBool) *pBool = true;
		return ""; // Suppress built-in client-side skillup message
	}
	if (id == 3146) {
		if (pBool) *pBool = true;
		return ""; // Suppress native XML compatibility warning message on login
	}
	return getString_Trampoline(pThis, pEdx, id, pBool);
}

static bool __fastcall CanUseItem_Detour(
	void* pThis,
	void* pEdx,
	const void* pItem,
	bool bUseRequiredLvl,
	bool bOutput)
{
	return true;
}

// NMS: CanUseMemorizedSpellSlot Detour to unlock all 12 spell slots at level 1 (since Mnemonic Retention is auto-granted at level 1)
static bool __fastcall CanUseMemorizedSpellSlot_Detour(
	void* pThis,
	void* pEdx,
	int gem)
{
	return gem < 12;
}

// NMS: Hook for PcZoneClient::CanEquipItem to fix yellow tint on items in inventory when player is not the correct race or deity
static bool __fastcall CanEquipItem_Detour(
	void* pThis,
	void* pEdx,
	const void* pItem,
	int slotid,
	bool bOutputDebug,
	bool bUseRequiredLevel)
{
	return true;
}

// Helper to check if a scroll matching the given spell ID is currently on the cursor
static bool IsCursorScrollMatchingSpellID(DWORD spellID)
{
	PCHARINFO2 pChar2 = GetCharInfo2();
	if (pChar2 && pChar2->pInventoryArray) {
		PCONTENTS pCursor = pChar2->pInventoryArray->Inventory.Cursor;
		if (pCursor) {
			_ITEMINFO* pItemInfo = GetItemFromContents(pCursor);
			if (pItemInfo && pItemInfo->ItemType == 20) { // Spell scroll
				if (pItemInfo->Scroll.SpellID == spellID) {
					return true;
				}
			}
		}
	}
	return false;
}

// NMS: Hook for EQ_Spell::GetSpellLevelNeeded to allow multiclass characters to scribe and filter spells of all active archetypes
static unsigned char __fastcall GetSpellLevelNeeded_Detour(
	void* pThis,
	void* pEdx,
	int classID)
{
	extern bool g_scribeInProgress;
	extern uint32_t g_cauth_bitmask;

	// Override the reported level to 1 only while a scribe trampoline is running,
	// or while the exact spell being queried is the scroll on the cursor (the
	// self-clearing state trigger). Both are scoped -- no lingering wall-clock window.
	bool overrideActive = g_scribeInProgress;
	if (pThis && IsCursorScrollMatchingSpellID(((EQ_Spell*)pThis)->Data.ID))
	{
		overrideActive = true;
	}

	unsigned char result = 255;

	if (overrideActive)
	{
		// Scribing override is active! Return 1 for any spell this character can eventually learn.
		if (g_cauth_bitmask != 0 && pLocalPlayer)
		{
			BYTE playerPrimaryClass = ((PSPAWNINFO)pLocalPlayer)->Class;
			if (classID == playerPrimaryClass)
			{
				unsigned char minLevel = 255;
				for (int i = 0; i < 16; i++)
				{
					if (g_cauth_bitmask & (1 << i))
					{
						unsigned char levelNeeded = GetSpellLevelNeeded_Trampoline(pThis, pEdx, i + 1);
						if (levelNeeded < minLevel)
						{
							minLevel = levelNeeded;
						}
					}
				}
				if (minLevel < 255) {
					result = 1;
				}
				else {
					result = minLevel;
				}
			}
		}
		if (result == 255) {
			unsigned char reqLevel = GetSpellLevelNeeded_Trampoline(pThis, pEdx, classID);
			if (reqLevel < 255) {
				result = 1;
			}
			else {
				result = reqLevel;
			}
		}
	}
	else
	{
		// Normal path: return real spell levels!
		if (g_cauth_bitmask != 0 && pLocalPlayer)
		{
			BYTE playerPrimaryClass = ((PSPAWNINFO)pLocalPlayer)->Class;
			if (classID == playerPrimaryClass || (classID >= 1 && classID <= 16 && (g_cauth_bitmask & (1 << (classID - 1)))))
			{
				unsigned char minLevel = 255;
				for (int i = 0; i < 16; i++)
				{
					if (g_cauth_bitmask & (1 << i))
					{
						unsigned char levelNeeded = GetSpellLevelNeeded_Trampoline(pThis, pEdx, i + 1);
						if (levelNeeded < minLevel)
						{
							minLevel = levelNeeded;
						}
					}
				}
				result = minLevel;
			}
			else
			{
				result = 255; // Not in the active bitmask
			}
		}
		else
		{
			result = GetSpellLevelNeeded_Trampoline(pThis, pEdx, classID);
		}
	}

	return result;
}

// NMS: Hook for EQ_Character::GetUsableClasses
// Fixes the merchant 'Show only items I can use' checkbox for multiclass characters.
// Called twice per item: bArg1=1 (display/render), bArg1=0 (checkbox filter).
// The merchant shows an item only if: GetUsableClasses(bArg1=0) & primaryClassBit != 0
static int __fastcall GetUsableClasses_Detour(
	void* pThis,
	void* pEdx,
	bool bArg1,
	bool bArg2)
{
	int result = GetUsableClasses_Trampoline(pThis, pEdx, bArg1, bArg2);

	// Only intercept the checkbox filter call (bArg1=0).
	// bArg1=1 is the display/render call - pass through unchanged.
	if (!bArg1)
	{
		extern uint32_t g_cauth_bitmask;
		if (g_cauth_bitmask != 0 && pLocalPlayer)
		{
			BYTE primaryClass = ((PSPAWNINFO)pLocalPlayer)->Class;
			int primaryBit = (1 << (primaryClass - 1));

			// result == 0 means no class restriction (all classes can use)
			// result & g_cauth_bitmask != 0 means at least one of player's classes matches
			bool canUse = (result == 0) || ((result & (int)g_cauth_bitmask) != 0);
			if (canUse)
			{
				// Force show for all classes so the merchant filter passes
				return 0xFFFF;
			}
			else
			{
				// Strip primary class bit so merchant check fails => item hidden
				int hideResult = result & ~primaryBit;
				if (hideResult == 0) return 1; // avoid returning 0 (undefined native behavior)
				return hideResult;
			}
		}
	}

	return result;
}

// NMS: EQ_Character::BardCastBard Hook
// Forces the client to treat non-bard spells normally (preventing double-click song toggling / casting interruption)
static int __fastcall BardCastBard_Detour(
	const void* pThis,
	void* pEdx,
	const void* pSpell,
	int caster_class)
{
	if (!pSpell) {
		return 0;
	}

	PSPELL spell = (PSPELL)pSpell;

	// Level[7] corresponds to class Bard (index 7).
	// If it is 255 (0xFF), the spell is not a bard song.
	if (spell->Level[7] == 255) {
		return 0;
	}

	return BardCastBard_Trampoline(pThis, pEdx, pSpell, caster_class);
}

BYTE GetSpoofClassForSkill(int skillId)
{
	extern uint32_t g_cauth_bitmask;
	
	// Rogue skills: Backstab (8), Hide (29), Sneak (42), Pick Pockets (48), Safe Fall (39), Disarm Traps (17), Intimidation (71)
	if (skillId == 8 || skillId == 29 || skillId == 42 || skillId == 48 || skillId == 39 || skillId == 17 || skillId == 71) {
		if (g_cauth_bitmask & 0x100u) return 9; // Rogue
	}
	// Kick
	if (skillId == 30) {
		if (g_cauth_bitmask & 0x01u) return 1; // Warrior
		if (g_cauth_bitmask & 0x40u) return 7; // Monk
		if (g_cauth_bitmask & 0x08u) return 4; // Ranger
		if (g_cauth_bitmask & 0x4000u) return 15; // Beastlord
		if (g_cauth_bitmask & 0x8000u) return 16; // Berserker
	}
	// Bash
	if (skillId == 10) {
		if (g_cauth_bitmask & 0x01u) return 1; // Warrior
		if (g_cauth_bitmask & 0x04u) return 3; // Paladin
		if (g_cauth_bitmask & 0x10u) return 5; // Shadowknight
		if (g_cauth_bitmask & 0x02u) return 2; // Cleric
	}
	// Frenzy
	if (skillId == 74) {
		if (g_cauth_bitmask & 0x8000u) return 16; // Berserker
	}
	// Taunt
	if (skillId == 73) {
		if (g_cauth_bitmask & 0x01u) return 1; // Warrior
		if (g_cauth_bitmask & 0x04u) return 3; // Paladin
		if (g_cauth_bitmask & 0x10u) return 5; // Shadowknight
		if (g_cauth_bitmask & 0x08u) return 4; // Ranger
	}
	// Monk Special Attacks: Dragon Punch (21), Eagle Strike (23), Flying Kick (26), Round Kick (38), Tiger Claw (52)
	if (skillId == 21 || skillId == 23 || skillId == 26 || skillId == 38 || skillId == 52) {
		if (g_cauth_bitmask & 0x40u) return 7; // Monk
	}
	return 0;
}

// NMS: CSkillMgr::IsAvailable Detour
static bool __fastcall CSkillMgr__IsAvailable_Detour(void* pThis, void* pEdx, int skillId)
{
	extern bool g_forceSkillAvailable;
	if (g_forceSkillAvailable) {
		return true;
	}

	PCHARINFO2 pCI2 = GetCharInfo2();
	if (pCI2 && skillId >= 0 && skillId < 100)
	{
		if (pCI2->Skill[skillId] == 0xFFFFFFFF)
		{
			return false;
		}
	}

	extern uint32_t g_cauth_bitmask;
	if (skillId == 53) // Tracking
	{
		if (g_cauth_bitmask != 0)
		{
			bool canTrack = (g_cauth_bitmask & 0xA8u) != 0; // Ranger (Bit 3), Druid (Bit 5), Bard (Bit 7)
			if (!canTrack) return false;
		}
	}

	BYTE spoofClass = GetSpoofClassForSkill(skillId);
	if (spoofClass > 0 && pLocalPlayer)
	{
		PSPAWNINFO pPlayer = (PSPAWNINFO)pLocalPlayer;
		BYTE savedClass = pPlayer->Class;
		BYTE savedCI2Class = pCI2 ? (BYTE)pCI2->Class : 0;
		pPlayer->Class = spoofClass;
		if (pCI2) pCI2->Class = spoofClass;

		bool result = CSkillMgr__IsAvailable_Trampoline(pThis, pEdx, skillId);

		pPlayer->Class = savedClass;
		if (pCI2) pCI2->Class = savedCI2Class;
		return result;
	}
	return CSkillMgr__IsAvailable_Trampoline(pThis, pEdx, skillId);
}

// NMS: CTrackingWnd::SetTrackingList Detour — the OP_Track packet path.
// Parses the server's track reply into the window's TrackingHit array, then
// sorts it with a hard "class != Ranger -> NORMAL" gate (reads CHARINFO2->Class
// at +0x3374). This runs on every Track press and every 6s auto-update reply,
// OUTSIDE the OnProcessFrame/WndNotification vtable spoofs in MQ2Pulse.cpp, so
// without this detour the list reverted to normal order on every refresh while
// the sort dropdown kept the picked value. Same Ranger spoof, same gate.
static void __fastcall CTrackingWnd__SetTrackingList_Detour(void* pThis, void* pEdx, void* data, unsigned int len)
{
	PCHARINFO2 pCI2 = GetCharInfo2();
	if (pLocalPlayer && pCI2 && (g_cauth_bitmask & 0x08u)) // Ranger (Bit 3)
	{
		PSPAWNINFO pPlayer = (PSPAWNINFO)pLocalPlayer;
		BYTE savedClass = pPlayer->Class;
		DWORD savedCI2Class = pCI2->Class;
		pPlayer->Class = 4; // Ranger
		pCI2->Class = 4;

		CTrackingWnd__SetTrackingList_Trampoline(pThis, pEdx, data, len);

		pPlayer->Class = savedClass;
		pCI2->Class = savedCI2Class;
		return;
	}
	CTrackingWnd__SetTrackingList_Trampoline(pThis, pEdx, data, len);
}

// NMS: CTrackingWnd::Activate Detour — window open. Activate calls
// UpdateTrackingControls before the first spoofed OnProcessFrame runs; for a
// non-Ranger visible class that zeroes the saved sort type + filter mask, so
// the picked sort was lost every time the window was reopened. Same spoof.
static void __fastcall CTrackingWnd__Activate_Detour(void* pThis, void* pEdx)
{
	PCHARINFO2 pCI2 = GetCharInfo2();
	if (pLocalPlayer && pCI2 && (g_cauth_bitmask & 0x08u)) // Ranger (Bit 3)
	{
		PSPAWNINFO pPlayer = (PSPAWNINFO)pLocalPlayer;
		BYTE savedClass = pPlayer->Class;
		DWORD savedCI2Class = pCI2->Class;
		pPlayer->Class = 4; // Ranger
		pCI2->Class = 4;

		CTrackingWnd__Activate_Trampoline(pThis, pEdx);

		pPlayer->Class = savedClass;
		pCI2->Class = savedCI2Class;
		return;
	}
	CTrackingWnd__Activate_Trampoline(pThis, pEdx);
}

// NMS: GetDisciplineReuseTimer Detour
// Keys >= 20 are served from g_discTimers (unbounded); keys 0..19 fall through
// to the native 20-slot array unchanged. The Combat Abilities window greys each
// disc button by calling this with the spell's CARecastTimerID, so returning the
// map value here is what makes reassigned (>=20) discs display their cooldown.
static int __stdcall NMS_GetDisciplineReuseTimer_Detour(int timerKey)
{
	if (timerKey >= NMS_DISC_NATIVE_SLOTS)   // -1 / <20 take the native path
	{
		auto it = g_discTimers.find(timerKey);
		return it != g_discTimers.end() ? it->second : 0;   // 0 == ready
	}
	return NMS_GetDisciplineReuseTimer_Trampoline(timerKey);
}

// NMS: SetDisciplineReuseTimer Detour — SERVER-AUTHORITATIVE feed.
// The server enforces disc reuse on the banded timer and pushes OP_DisciplineTimer
// (banded id + duration); the native packet handler routes it here as
// SetDisciplineReuseTimer(bandedId, readyTime). Native drops ids >= 20 (20-slot array),
// so we store them in the map. This overrides the client's optimistic estimate with the
// server's authoritative ready-time (readyTime is absolute unix seconds, same as our map).
static void __stdcall NMS_SetDisciplineReuseTimer_Detour(int timerKey, int readyTime)
{
	if (timerKey >= NMS_DISC_NATIVE_SLOTS)
		g_discTimers[timerKey] = readyTime;
	else
		NMS_SetDisciplineReuseTimer_Trampoline(timerKey, readyTime);
}

// NMS: doCombatAbility Detour
// For discs whose CARecastTimerID >= 20: block if still on cooldown (our map),
// otherwise run the ability and stamp map[key] = now + recast. Keys 0..19 are
// left entirely to the native path (which sets its own 20-slot timer), so
// existing discs behave exactly as before.
static bool __fastcall NMS_doCombatAbility_Detour(void* pThis, void* pEdx, int spellID, int dummy)
{
	PSPELL sp = GetSpellByID(spellID);
	if (sp)
	{
		int key = (int)sp->CARecastTimerID;
		if (key >= NMS_DISC_NATIVE_SLOTS)
		{
			int now = NMS_NowSec();
			auto it = g_discTimers.find(key);
			if (it != g_discTimers.end() && now < it->second)
			{
				WriteChatf("%s will be ready in %d seconds.", sp->Name, it->second - now);
				return false;   // still on cooldown -> block (matches native)
			}
			bool ok = NMS_doCombatAbility_Trampoline(pThis, pEdx, spellID, dummy);
			if (ok)
				g_discTimers[key] = now + (int)(sp->RecastTime / 1000);
			return ok;
		}
	}
	return NMS_doCombatAbility_Trampoline(pThis, pEdx, spellID, dummy);
}

// NMS: CharacterZoneClient::HasSkill Detour
static bool __fastcall CharacterZoneClient__HasSkill_Detour(void* pThis, void* pEdx, int skillId)
{
	PCHARINFO2 pCI2 = GetCharInfo2();
	if (pCI2 && skillId >= 0 && skillId < 100)
	{
		if (pCI2->Skill[skillId] == 0xFFFFFFFF)
		{
			return false;
		}
	}

	extern uint32_t g_cauth_bitmask;
	if (skillId == 53) // Tracking
	{
		if (g_cauth_bitmask != 0)
		{
			bool canTrack = (g_cauth_bitmask & 0xA8u) != 0; // Ranger (Bit 3), Druid (Bit 5), Bard (Bit 7)
			if (!canTrack) return false;
		}
	}

	BYTE spoofClass = GetSpoofClassForSkill(skillId);
	if (spoofClass > 0 && pLocalPlayer)
	{
		PSPAWNINFO pPlayer = (PSPAWNINFO)pLocalPlayer;
		BYTE savedClass = pPlayer->Class;
		BYTE savedCI2Class = pCI2 ? (BYTE)pCI2->Class : 0;
		pPlayer->Class = spoofClass;
		if (pCI2) pCI2->Class = spoofClass;

		bool result = CharacterZoneClient__HasSkill_Trampoline(pThis, pEdx, skillId);

		pPlayer->Class = savedClass;
		if (pCI2) pCI2->Class = savedCI2Class;
		return result;
	}
	return CharacterZoneClient__HasSkill_Trampoline(pThis, pEdx, skillId);
}

// NMS: ExecuteCmd Detour
static BOOL __cdecl ExecuteCmd_Detour(DWORD cmdId, BOOL isDown, PVOID pData)
{
	extern uint32_t g_cauth_bitmask;
	extern BYTE g_savedClass;
	extern bool g_overrideActive;

	static bool s_commandsPopulated = false;
	if (!s_commandsPopulated && GetGameState() == GAMESTATE_INGAME && EQMappableCommandList)
	{
		bool hasValidCommand = false;
		for (int i = 0; i < nEQMappableCommands; i++) {
			if (EQMappableCommandList[i] != nullptr && (DWORD)EQMappableCommandList[i] <= (DWORD)__AC1_Data) {
				szEQMappableCommands[i] = EQMappableCommandList[i];
				hasValidCommand = true;
			}
		}
		if (hasValidCommand) {
			s_commandsPopulated = true;
			OutputDebugStringA("[NMS-ExecuteCmd] Lazily populated szEQMappableCommands from EQMappableCommandList\n");
		}
	}

	const char* szCmdName = nullptr;
	if (cmdId < nEQMappableCommands) {
		szCmdName = szEQMappableCommands[cmdId];
	}

	char dbg[256];
	sprintf_s(dbg, "[NMS-ExecuteCmd] cmdId=%u (%s), isDown=%d\n", cmdId, szCmdName ? szCmdName : "null", isDown);
	OutputDebugStringA(dbg);

	bool isCasterCommand = false;
	if (szCmdName) {
		if (strstr(szCmdName, "CAST") || 
			strstr(szCmdName, "SPELL") || 
			strstr(szCmdName, "BOOK") || 
			strstr(szCmdName, "SIT") ||
			strstr(szCmdName, "STAND")) 
		{
			isCasterCommand = true;
		}
	}

	if (isCasterCommand && pLocalPlayer)
	{
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

			BOOL result = ExecuteCmd_Trampoline(cmdId, isDown, pData);

			pPlayer->Class = savedClass;
			if (pCI2) pCI2->Class = savedCI2Class;
			return result;
		}
	}

	return ExecuteCmd_Trampoline(cmdId, isDown, pData);
}

// NMS: Case-insensitive compare of a (ptr,len) token against a literal.
// Hand-rolled rather than _strnicmp so the comparison stays portable.
static bool NMS_TokenEquals(const char* tok, size_t len, const char* literal)
{
	if (strlen(literal) != len)
		return false;

	for (size_t i = 0; i < len; ++i)
	{
		if (tolower((unsigned char)tok[i]) != tolower((unsigned char)literal[i]))
			return false;
	}
	return true;
}

// NMS: Advance past spaces/tabs, then return the next whitespace-delimited token.
static const char* NMS_NextToken(const char*& p, size_t& len)
{
	while (*p == ' ' || *p == '\t')
		++p;

	const char* start = p;
	while (*p && *p != ' ' && *p != '\t')
		++p;

	len = (size_t)(p - start);
	return start;
}

// NMS: /alternateadv Detour -- make "/alt toggle <id>" actually work.
//
// Every AA description in dbstr_us.txt carries the stock Live prefix
// "[/alt toggle <id>]" (Shadow Curse -> "[/alt toggle 17792]"), but no EQ client
// and no EQEmu server ever implemented a "toggle" subcommand. RoF2's own handler
// rejects it with "Format: /alternateadv <on|off|list>", so the AA window is telling
// every player to run a command that answers with an unrelated error. The real thing
// is our server-side chat command "#alttoggle <id>" (zone/gm_commands/alttoggle.cpp).
//
// Hooking the leaf handler (rather than the dispatcher) means EQ has already resolved
// the alias and abbreviation for us -- /alt, /alte, /alternateadv all arrive here --
// so there is no spelling list to keep in sync.
//
// We claim the whole "toggle" subcommand and never call the trampoline for it, so the
// native handler can't print its format line, then re-dispatch as "/say #alttoggle <id>".
// The server pulls '#' commands out of the say channel in Client::ChannelMessageReceived
// and consumes them without broadcasting, so nothing is echoed to other players.
// Every other form (on/off/list/activate) falls through to the trampoline untouched.
static void __cdecl cmd_alternateadv_Detour(PSPAWNINFO pChar, PCHAR szLine)
{
	if (szLine)
	{
		const char* p = szLine;

		// EQ hands leaf handlers the argument text ("toggle 249"). Tolerate a full
		// line ("/alt toggle 249") too, so we are not betting on that convention.
		while (*p == ' ' || *p == '\t')
			++p;

		if (*p == '/')
		{
			size_t skipLen = 0;
			NMS_NextToken(p, skipLen);
		}

		size_t subLen = 0;
		const char* subTok = NMS_NextToken(p, subLen);

		if (NMS_TokenEquals(subTok, subLen, "toggle"))
		{
			size_t idLen = 0;
			const char* idTok = NMS_NextToken(p, idLen);

			// Cap the length so the id can never overflow the buffer below.
			bool numeric = (idLen > 0 && idLen <= 10);
			for (size_t i = 0; i < idLen && numeric; ++i)
			{
				if (idTok[i] < '0' || idTok[i] > '9')
					numeric = false;
			}

			if (!numeric)
			{
				WriteChatf("Usage: /alt toggle <AA Id>");
				return;
			}

			if (ppEverQuest && pEverQuest)
			{
				char redirect[64];
				sprintf_s(redirect, sizeof(redirect), "/say #alttoggle %.*s", (int)idLen, idTok);
				pEverQuest->InterpretCmd((EQPlayer*)pChar, redirect);
			}
			return;
		}
	}

	cmd_alternateadv_Trampoline(pChar, szLine);
}


// NMS: Safe recursive walker using IsBadReadPtr (avoids MSVC SEH nesting issues).
// Offsets: pNextSiblingWnd=0x08, pFirstChildWnd=0x10, Enabled=0x01a
static CXWnd* NMS_FindWndByScreenID(void* pWnd, const char* screenID, int depth = 0)
{
	if (!pWnd || depth > 30) return nullptr;
	if (IsBadReadPtr(pWnd, 0x20)) return nullptr;

	__try {
		CXMLData* pXml = ((CXWnd*)pWnd)->GetXMLData();
		if (pXml && !IsBadReadPtr(pXml, 16)) {
			char szID[256] = { 0 };
			GetCXStr(pXml->ScreenID.Ptr, szID, 256);
			if (szID[0] && !_stricmp(szID, screenID))
				return (CXWnd*)pWnd;
		}
	} __except (EXCEPTION_EXECUTE_HANDLER) {}

	void* pChild   = *(void**)((DWORD)pWnd + 0x10);
	void* pSibling = *(void**)((DWORD)pWnd + 0x08);

	CXWnd* found = NMS_FindWndByScreenID(pChild,   screenID, depth + 1);
	if (found) return found;
	return          NMS_FindWndByScreenID(pSibling, screenID, depth + 1);
}

// NMS: CMerchantWnd::SelectBuySellSlot detour
static void __fastcall CMerchantWnd__SelectBuySellSlot_Detour(void* pThis, void* pEdx, int slot, void* pAnim)
{
	CMerchantWnd__SelectBuySellSlot_Trampoline(pThis, pEdx, slot, pAnim);
}

// NMS: ItemBase::IsEmpty detour - tricks client into thinking bulk sell bag is empty
static bool __fastcall ItemBase__IsEmpty_Detour(void* pThis, void* pEdx)
{
	__try {
		if (pThis && !IsBadReadPtr(pThis, 0x100)) {
			PCONTENTS pContents = (PCONTENTS)pThis;
			_ITEMINFO* pInfo = GetItemFromContents(pContents);
			if (pInfo && pInfo->Type == ITEMTYPE_PACK) {
				if (g_bagInSellSlot && g_bagIsSellable && pContents == g_pBagContents) {
					OutputDebugStringA("[NMS] ItemBase::IsEmpty called for sellable bag. Returning TRUE (tricked)!");
					return true;
				}
			}
		}
	} __except (EXCEPTION_EXECUTE_HANDLER) {}

	return ItemBase__IsEmpty_Trampoline(pThis, pEdx);
}

// NMS: CMerchantWnd::DisplayBuyOrSellPrice detour
static void __fastcall CMerchantWnd__DisplayBuyOrSellPrice_Detour(void* pThis, void* pEdx, const void* pItem, bool bBuy)
{
	bool isBag = false;
	bool isSellable = false;

	if (!bBuy && pItem)
	{
		__try {
			if (!IsBadReadPtr(pItem, 4)) {
				PCONTENTS pContents = *(PCONTENTS*)pItem;
				if (pContents && !IsBadReadPtr(pContents, 4)) {
					_ITEMINFO* pInfo = GetItemFromContents(pContents);
					if (pInfo && pInfo->Type == ITEMTYPE_PACK) {
						isBag = true;
						
						// Filter by name: Syncrosatchels are No-Drop bags we DON'T want to bypass
						if (strstr(pInfo->Name, "Syncrosatchel") == nullptr) {
							isSellable = true;
							
							// If we clicked a different bag, restore the previous one first
							if (g_pBagContents != nullptr && g_pBagContents != pContents) {
								RestoreBagNoDropState();
							}

							if (g_pBagContents == nullptr) {
								g_pBagContents = pContents;
								g_origNoDrop = pInfo->NoDrop;
								
								// Set tradeable so client Sell button is enabled and clickable!
								pInfo->NoDrop = 1;
							}
						}
					}
				}
			}
		} __except (EXCEPTION_EXECUTE_HANDLER) {}
	}

	g_bagInSellSlot = isBag;
	g_bagIsSellable = isSellable;

	// If we are not looking at a sellable bag (switched tabs, cleared slot, or selected non-bag), restore state!
	if (!g_bagInSellSlot || !g_bagIsSellable) {
		RestoreBagNoDropState();
	}

	char dbg[64]; sprintf_s(dbg, "[NMS] DisplayPrice bBuy=%d flag=%d sellable=%d", (int)bBuy, (int)g_bagInSellSlot, (int)g_bagIsSellable);
	OutputDebugStringA(dbg);

	if (!bBuy && g_bagInSellSlot)
	{
		__try {
			DWORD pMerchAddr = *(DWORD*)(0xD1FCA4 - 0x400000 + baseAddress);
			if (pMerchAddr && !IsBadReadPtr((void*)pMerchAddr, 0x20)) {
				// 1. Set Sell button state based on sellable flag
				CXWnd* pSellBtn = NMS_FindWndByScreenID((void*)pMerchAddr, "MW_Sell_Button");
				if (pSellBtn) *(BYTE*)((DWORD)pSellBtn + CXWND_ENABLED_OFFSET) = g_bagIsSellable ? 1 : 0;

				// 2. Set Price Label
				CXWnd* pPriceLabel = NMS_FindWndByScreenID((void*)pMerchAddr, "MW_SelectedPriceLabel");
				if (pPriceLabel) {
					*(BYTE*)((DWORD)pPriceLabel + 0x196) = 1; // Ensure visible
					CXStr str(g_bagIsSellable ? "Bulk Sell" : "Cannot Sell");
					pPriceLabel->SetWindowTextA(str);
				}
			}
		} __except (EXCEPTION_EXECUTE_HANDLER) {}

		// Skip trampoline to prevent garbage price from being calculated/displayed in chat
		return;
	}

	CMerchantWnd__DisplayBuyOrSellPrice_Trampoline(pThis, pEdx, pItem, bBuy);
}

// NMS: Hook for PcZoneClient::CanEquipItem to fix yellow tint on items in inventory when player is not the correct race or deity
static void __fastcall CInvSlot__UpdateItem_Detour(CInvSlot_Hook* pThis, void* pEdx)
{
	CInvSlot__UpdateItem_Trampoline(pThis, pEdx);

	if (pThis && pThis->pInvSlotWnd)
	{
		// Replace ONLY the yellow "can't use" tint (0xFFFFFF00) with white -- the false
		// positive this hook exists for. Every other tint must be left alone: 0xFF000096
		// blue is the hotbutton's NORMAL background (repainted ~150ms by the slot refresh
		// at 0x69A6A0), and the old unconditional white-write here fought that repaint,
		// strobing hotbar buttons blue<->clear whenever anything drove UpdateItem (item
		// held on cursor, bag traffic, boxing). Red/green item-compare tints are native too.
		if (pThis->pInvSlotWnd->BGTintNormal == 0xFFFFFF00)
			pThis->pInvSlotWnd->BGTintNormal = 0xFFFFFFFF;
		if (pThis->pInvSlotWnd->BGTintRollover == 0xFFFFFF00)
			pThis->pInvSlotWnd->BGTintRollover = 0xFFFFFFFF;
	}
}

// NMS:
// Hook CInvSlot::HandleRButtonUp for the scroll-scribe path.
// Open the spell book via InterpretCmd BEFORE the trampoline runs so EQ's own
// code sets 0x196 correctly — no direct memory writes, no window state corruption.
static void __fastcall CInvSlot__HandleRButtonUp_Detour(void* pThis, void* pEdx, void* pPoint)
{
	// Timer replay path: bypass book/sit logic, go straight to trampoline.
	if (g_scribeTimerFiring)
	{
		CInvSlot__HandleRButtonUp_Trampoline(pThis, pEdx, pPoint);
		return;
	}

	if (isToggleSpellBookOnScribeEnabled
		&& ppEverQuest && pEverQuest
		&& pLocalPlayer)
	{
		// Filter: Only trigger for Spell Scrolls (20) or Combat Tomes (31)
		// We use the exact assembly method identified in CE:
		// mov eax,[ecx] / mov edx,[eax+08] / call edx / movzx eax,byte ptr [eax+1D4h]
		PCONTENTS pContents = nullptr;
		((CInvSlot*)pThis)->GetItemBase(&pContents);

		bool isScribeable = false;
		_ITEMINFO* pItemInfo = nullptr;
		if (pContents) {
			__try {
				pItemInfo = GetItemFromContents(pContents);
				if (pItemInfo) {
					BYTE itemType = pItemInfo->ItemType;
					if (itemType == 20 || itemType == 31) {
						isScribeable = true;
					}
				}
			} __except (EXCEPTION_EXECUTE_HANDLER) {}
		}

		// Only apply our custom sit, book, and timer logic if it's a scribeable item
		if (isScribeable)
		{
			// Extract target class from item info, prioritizing player's active classes
			BYTE targetClass = 0;
			if (pItemInfo) {
				DWORD classesBitmask = pItemInfo->Classes;
				DWORD overlappingClasses = classesBitmask & g_cauth_bitmask;
				DWORD activeMask = (overlappingClasses != 0) ? overlappingClasses : classesBitmask;
				for (int i = 0; i < 16; i++) {
					if (activeMask & (1 << i)) {
						targetClass = i + 1;
						break;
					}
				}
			}

			// Identify if this is a combat ability tome or melee discipline (which can also be itemtype 20 scroll)
			bool isTome = false;
			if (pItemInfo) {
				BYTE itemType = pItemInfo->ItemType;
				isTome = (itemType == 31) ||
					((itemType == 20) && (
						strstr(pItemInfo->Name, "Tome") ||
						strstr(pItemInfo->Name, "tome") ||
						strstr(pItemInfo->Name, "Skill") ||
						strstr(pItemInfo->Name, "skill") ||
						strstr(pItemInfo->Name, "Discipline") ||
						strstr(pItemInfo->Name, "discipline")
					));
			}

			// 1. Instant path for combat tomes/skills: learn instantly with closed spellbook!
			if (isTome)
			{
				ScribeSpoofState spoof = NMS_BeginScribeSpoof(targetClass);

				// Spoof itemtype as Tome (31) so the native client learns it
				// instantly without opening the spellbook or sitting the player.
				BYTE originalItemType = pItemInfo->ItemType;
				pItemInfo->ItemType = 31;

				CInvSlot__HandleRButtonUp_Trampoline(pThis, pEdx, pPoint);

				pItemInfo->ItemType = originalItemType;

				NMS_EndScribeSpoof(spoof);
				return;
			}

			// 2. Instant path: if spellbook is already open, scribe instantly!
			if (ppSpellBookWnd && pSpellBookWnd && *((BYTE*)pSpellBookWnd + 0x196))
			{
				ScribeSpoofState spoof = NMS_BeginScribeSpoof(targetClass);

				CInvSlot__HandleRButtonUp_Trampoline(pThis, pEdx, pPoint);

				NMS_EndScribeSpoof(spoof);
				return;
			}

			// 3. Delayed path: open spellbook first, then fire in 100ms
			pEverQuest->InterpretCmd(pLocalPlayer, "/book");

			g_pendingSpellBookShow = true;
			g_pendingScribeThis = pThis;
			g_pendingScribeEdx = pEdx;
			g_pendingScribeTargetClass = targetClass;
			if (pPoint) g_pendingScribePoint = *(CXPoint2*)pPoint;
			g_scribeEndTick = GetTickCount() + SCRIBE_DURATION_MS;
			g_scribeTimerActive = true;
			return;
		}
	}

	CInvSlot__HandleRButtonUp_Trampoline(pThis, pEdx, pPoint);
}

bool InstallD3D9Hooks()
{
	bool success = false;

	g_d3d9Module = GetModuleHandle("d3d9.dll");

	if (g_d3d9Module)
	{
		HRESULT hRes;
		IDirect3D9Ex* d3d9ex;

		if (SUCCEEDED(hRes = Direct3DCreate9Ex(D3D_SDK_VERSION, &d3d9ex)))
		{
			D3DPRESENT_PARAMETERS pp;
			ZeroMemory(&pp, sizeof(pp));
			pp.Windowed = 1;
			pp.SwapEffect = D3DSWAPEFFECT_FLIP;
			pp.BackBufferFormat = D3DFMT_A8R8G8B8;
			pp.BackBufferCount = 1;
			pp.PresentationInterval = D3DPRESENT_INTERVAL_IMMEDIATE;

			int round = fegetround();

			IDirect3DDevice9Ex* deviceEx;

			if (SUCCEEDED(hRes = d3d9ex->CreateDeviceEx(
				D3DADAPTER_DEFAULT,
				D3DDEVTYPE_NULLREF,
				0,
				D3DCREATE_HARDWARE_VERTEXPROCESSING | D3DCREATE_NOWINDOWCHANGES,
				&pp, NULL, &deviceEx)))
			{
				success = true;

				DWORD* d3dDevice_vftable = *(DWORD**)deviceEx;

				InstallDetour(
					d3dDevice_vftable[0x29],
					&RenderHooks::BeginScene_Detour,
					&RenderHooks::BeginScene_Trampoline,
					"d3dDevice_BeginScene");

				InstallDetour(
					d3dDevice_vftable[0x2a],
					&RenderHooks::EndScene_Detour,
					&RenderHooks::EndScene_Trampoline,
					"d3dDevice_EndScene");

				// -------------------------------
				// NMS: StringTable::getString hook to suppress duplicate client-side messages
				// -------------------------------
				DWORD getStringAddr =
					StringTable__getString_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					getStringAddr,
					(getString_t)getString_Detour,
					(getString_t)getString_Trampoline,
					"StringTable::getString");

				// -------------------------------
				// NMS: CanUseItem gameplay hook
				// -------------------------------
				DWORD canUseItemAddr =
					CharacterZoneClient__CanUseItem_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					canUseItemAddr,
					(CanUseItem_t)CanUseItem_Detour,
					(CanUseItem_t)CanUseItem_Trampoline,
					"EQ_Character::CanUseItem");

				// -------------------------------
				// NMS: CanUseMemorizedSpellSlot gameplay hook
				// -------------------------------
				DWORD canUseMemAddr =
					CharacterZoneClient__CanUseMemorizedSpellSlot_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					canUseMemAddr,
					(CanUseMemorizedSpellSlot_t)CanUseMemorizedSpellSlot_Detour,
					(CanUseMemorizedSpellSlot_t)CanUseMemorizedSpellSlot_Trampoline,
					"CharacterZoneClient::CanUseMemorizedSpellSlot");

				// -------------------------------
				// NMS: Hook for PcZoneClient::CanEquipItem to fix yellow tint on items in inventory when player is not the correct race or deity
				// -------------------------------
				DWORD canEquipItemAddr =
					PcZoneClient__CanEquipItem_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					canEquipItemAddr,
					(CanEquipItem_t)CanEquipItem_Detour,
					(CanEquipItem_t)CanEquipItem_Trampoline,
					"PcZoneClient::CanEquipItem");

				// -------------------------------
				// NMS: EQ_Spell::GetSpellLevelNeeded hook
				// -------------------------------
				DWORD getSpellLvlNeededAddr =
					EQ_Spell__GetSpellLevelNeeded_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					getSpellLvlNeededAddr,
					(GetSpellLevelNeeded_t)GetSpellLevelNeeded_Detour,
					(GetSpellLevelNeeded_t)GetSpellLevelNeeded_Trampoline,
					"EQ_Spell::GetSpellLevelNeeded"
				);

				// -------------------------------
				// NMS: CInvSlot::UpdateItem hook
				// -------------------------------
				DWORD updateItemAddr =
					CInvSlot__UpdateItem_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					updateItemAddr,
					(UpdateItem_t)CInvSlot__UpdateItem_Detour,
					(UpdateItem_t)CInvSlot__UpdateItem_Trampoline,
					"CInvSlot::UpdateItem");

				// -------------------------------
				// CInvSlot::HandleRButtonUp - force spell book open on scroll scribe
				// -------------------------------
				DWORD handleRButtonUpAddr =
					CInvSlot__HandleRButtonUp_x
					- 0x400000
					+ baseAddress;


				InstallDetour(
					handleRButtonUpAddr,
					(HandleRButtonUp_t)CInvSlot__HandleRButtonUp_Detour,
					(HandleRButtonUp_t)CInvSlot__HandleRButtonUp_Trampoline,
					"CInvSlot::HandleRButtonUp");


				// -------------------------------
				// CListWnd::GetItemIcon - multiclass character select icons
				// -------------------------------
				DWORD getItemIconAddr =
					CListWnd__GetItemIcon_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					getItemIconAddr,
					(GetItemIcon_t)CListWnd__GetItemIcon_Detour,
					(GetItemIcon_t)CListWnd__GetItemIcon_Trampoline,
					"CListWnd::GetItemIcon");

				// -------------------------------
				// CListWnd::GetItemText - shift name/level columns
				// -------------------------------
				DWORD getItemTextAddr =
					CListWnd__GetItemText_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					getItemTextAddr,
					(GetItemText_t)CListWnd__GetItemText_Detour,
					(GetItemText_t)CListWnd__GetItemText_Trampoline,
					"CListWnd::GetItemText");


				// -------------------------------
				// CMerchantWnd::PurchasePageHandler::UpdateList
				// Re-sort by Lvl after spell merchants rebuild their list
				// -------------------------------
				{
					DWORD updateListAddr =
						CMerchantWnd__PurchasePageHandler__UpdateList_x
						- 0x400000
						+ baseAddress;

					InstallDetour(
						updateListAddr,
						(UpdateList_t)CMerchantWnd__UpdateList_Detour,
						(UpdateList_t)CMerchantWnd__UpdateList_Trampoline,
						"CMerchantWnd::UpdateList");
				}


				// -------------------------------
				// CListWnd::SetColumnJustification - fix alignment
				// -------------------------------
				DWORD setJustifyAddr =
					CListWnd__SetColumnJustification_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					setJustifyAddr,
					(SetColumnJustification_t)CListWnd__SetColumnJustification_Detour,
					(SetColumnJustification_t)CListWnd__SetColumnJustification_Trampoline,
					"CListWnd::SetColumnJustification");

				// -------------------------------
				// NMS: CMerchantWnd::DisplayBuyOrSellPrice - enable Sell button for bags
				// -------------------------------
				DWORD displayPriceAddr =
					CMerchantWnd__DisplayBuyOrSellPrice_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					displayPriceAddr,
					(DisplayBuyOrSellPrice_t)CMerchantWnd__DisplayBuyOrSellPrice_Detour,
					(DisplayBuyOrSellPrice_t)CMerchantWnd__DisplayBuyOrSellPrice_Trampoline,
					"CMerchantWnd::DisplayBuyOrSellPrice");

				// NMS: CMerchantWnd::SelectBuySellSlot - detect bag in sell slot before price fires
				DWORD selectSlotAddr =
					CMerchantWnd__SelectBuySellSlot_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					selectSlotAddr,
					(SelectBuySellSlot_t)CMerchantWnd__SelectBuySellSlot_Detour,
					(SelectBuySellSlot_t)CMerchantWnd__SelectBuySellSlot_Trampoline,
					"CMerchantWnd::SelectBuySellSlot");

				// NMS: ItemBase::IsEmpty - trick client into thinking bulk sell bag is empty
				DWORD isEmptyAddr =
					ItemBase__IsEmpty_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					isEmptyAddr,
					(IsEmpty_t)ItemBase__IsEmpty_Detour,
					(IsEmpty_t)ItemBase__IsEmpty_Trampoline,
					"ItemBase::IsEmpty");

				// -------------------------------
				// NMS: EQ_Character::GetUsableClasses - merchant 'Show only items I can use' filter
				// -------------------------------
				DWORD getUsableClassesAddr =
					EQ_Character__GetUsableClasses_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					getUsableClassesAddr,
					(GetUsableClasses_t)GetUsableClasses_Detour,
					(GetUsableClasses_t)GetUsableClasses_Trampoline,
					"EQ_Character::GetUsableClasses");

				// -------------------------------
				// NMS: EQ_Character::BardCastBard hook
				// -------------------------------
				DWORD bardCastBardAddr =
					EQ_Character__BardCastBard_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					bardCastBardAddr,
					(BardCastBard_t)BardCastBard_Detour,
					(BardCastBard_t)BardCastBard_Trampoline,
					"EQ_Character::BardCastBard");

				// -------------------------------
				// NMS: CSkillMgr::IsAvailable hook
				// -------------------------------
				DWORD isAvailableAddr =
					CSkillMgr__IsAvailable_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					isAvailableAddr,
					(IsAvailable_t)CSkillMgr__IsAvailable_Detour,
					(IsAvailable_t)CSkillMgr__IsAvailable_Trampoline,
					"CSkillMgr::IsAvailable");

				// -------------------------------
				// NMS: Discipline/Skill reuse-timer system
				// GetDisciplineReuseTimer -> map for keys >= 20 (UI grey path);
				// doCombatAbility -> enforce + stamp cooldowns for keys >= 20.
				// -------------------------------
				InstallDetour(
					NMS_GetDisciplineReuseTimer_x - 0x400000 + baseAddress,
					(GetDiscReuse_t)NMS_GetDisciplineReuseTimer_Detour,
					(GetDiscReuse_t)NMS_GetDisciplineReuseTimer_Trampoline,
					"EQ::GetDisciplineReuseTimer");

				InstallDetour(
					NMS_SetDisciplineReuseTimer_x - 0x400000 + baseAddress,
					(SetDiscReuse_t)NMS_SetDisciplineReuseTimer_Detour,
					(SetDiscReuse_t)NMS_SetDisciplineReuseTimer_Trampoline,
					"EQ::SetDisciplineReuseTimer");

				InstallDetour(
					NMS_doCombatAbility_x - 0x400000 + baseAddress,
					(DoCombatAbility_t)NMS_doCombatAbility_Detour,
					(DoCombatAbility_t)NMS_doCombatAbility_Trampoline,
					"EQ_Character::doCombatAbility");

				// -------------------------------
				// NMS: CharacterZoneClient::HasSkill hook
				// -------------------------------
				DWORD hasSkillAddr =
					CharacterZoneClient__HasSkill_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					hasSkillAddr,
					(HasSkill_t)CharacterZoneClient__HasSkill_Detour,
					(HasSkill_t)CharacterZoneClient__HasSkill_Trampoline,
					"CharacterZoneClient::HasSkill");

				// -------------------------------
				// NMS: Track Sort — spoof Ranger around the two tracking-window
				// paths the MQ2Pulse vtable hooks can't reach: the OP_Track
				// packet path (SetTrackingList re-sorts with a class gate on
				// every Track press / auto-update reply) and window Activate
				// (zeroes the saved sort type via UpdateTrackingControls).
				// -------------------------------
				InstallDetour(
					CTrackingWnd__SetTrackingList_x - 0x400000 + baseAddress,
					(TrackSetList_t)CTrackingWnd__SetTrackingList_Detour,
					(TrackSetList_t)CTrackingWnd__SetTrackingList_Trampoline,
					"CTrackingWnd::SetTrackingList");

				InstallDetour(
					CTrackingWnd__Activate_x - 0x400000 + baseAddress,
					(TrackActivate_t)CTrackingWnd__Activate_Detour,
					(TrackActivate_t)CTrackingWnd__Activate_Trampoline,
					"CTrackingWnd::Activate");

				// -------------------------------
				// NMS: ExecuteCmd hook
				// -------------------------------
				DWORD executeCmdAddr =
					__ExecuteCmd_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					executeCmdAddr,
					(ExecuteCmd_t)ExecuteCmd_Detour,
					(ExecuteCmd_t)ExecuteCmd_Trampoline,
					"ExecuteCmd");

				// -------------------------------
				// NMS: /alternateadv hook -- "/alt toggle <id>" -> "#alttoggle <id>"
				// -------------------------------
				DWORD altAdvAddr =
					cmd_alternateadv_handler_x
					- 0x400000
					+ baseAddress;

				InstallDetour(
					altAdvAddr,
					(EQCommandFn_t)cmd_alternateadv_Detour,
					(EQCommandFn_t)cmd_alternateadv_Trampoline,
					"cmd_alternateadv");

				// -------------------------------
				// NMS: Sneak+Hide move-persist patch (Rogue multiclass) -- 2026-07-15
				// The RoF2 client's local move-break routine (FUN_0045daf0) breaks Hide on
				// movement with the gate: (Class != Rogue) OR (not sneaking). The class byte
				// it reads is CharacterZoneClient+0x3374; for a multiclass toon whose VISIBLE
				// class isn't Rogue that gate is always true, so Hide drops on every step --
				// this is the exact reason a server-side-only fix wasn't enough
				// for us (a real Rogue's client passes the check and never sends the cancel).
				//   0x0045EA0F: JNZ 0x45EA21   (75 10)  <- "class != Rogue -> break hide"
				// NOP it (90 90) so the gate falls through to the sneak check, leaving the
				// rule "break Hide on move only if NOT sneaking" -- which only hide+sneak
				// (Rogue) toons can trigger. Static 2-byte patch: no spoof, no per-frame code;
				// reads none of the UI/casting class fields (SPAWNINFO 0xEB8 / CHARINFO2 0x4C),
				// so no mana-bar/casting side effects. Server stays catapultam's clean version.
				{
					extern void PatchA(LPVOID address, const void* dwValue, SIZE_T dwBytes);
					static const unsigned char kNops[2] = { 0x90, 0x90 };
					PatchA((LPVOID)(0x0045EA0F - 0x400000 + baseAddress), kNops, 2);
				}






				deviceEx->Release();
			}

			fesetround(round);
			d3d9ex->Release();
		}
	}

	return success;
}

static void RemoveDetours()
{
	for (size_t i = 0; i < g_hooks.size(); ++i)
	{
		if (g_hooks[i].address != 0)
		{
			RemoveDetour(g_hooks[i].address);
			g_hooks[i].address = 0;
		}
	}
}

void ShutdownHooks()
{
	if (!g_hooksInstalled)
		return;

	RemoveDetours();

	g_hooksInstalled = false;
	g_hooks.clear();

	// Release our Direct3D device before freeing the dx9 library
	if (g_pDevice)
	{
		g_pDevice->Release();
		g_pDevice = nullptr;
	}

	if (g_d3d9Module)
	{
		FreeLibrary(g_d3d9Module);
		g_d3d9Module = 0;
	}


}
