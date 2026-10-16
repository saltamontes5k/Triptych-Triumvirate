#pragma once

#include "MQ2Main.h"

// RoF2 sizes the achievement window's pool of row windows from a per-category
// counter rather than from the catalog. Any list entry whose ordinal is >=
// that pool is silently dropped, and because the list never overflows the
// listbox also never grows a scrollbar, so a category with more than a
// handful of achievements renders as a short, unscrollable stub.
//
// Reversed layout (stock RoF2, imagebase 0x400000):
//   sub_403B90 (0x403B90) state handler:
//       pool = sub_402F50(manager);
//       sub_60F4C0(achievement_window, pool);   // materialise the row windows
//       sub_60EB20(achievement_window, category, 1);
//   sub_402F50 (0x402F50) max over categories of sub_402450(cat, 0), which
//       sums the three per-category counters at cat+0x44/0x48/0x4C.
//   sub_60F4C0 (0x60F4C0) stores the pool size at window+0x2AC.
//   sub_60DA30 (0x60DA30) builds a row only when ordinal < *(window+0x2AC).
//
// Force the pool large enough for the biggest custom category so every entry
// gets a row and the listbox overflows normally (scrollbar included).

#define ACHIEVEMENT_ROW_POOL_SIZE 256

int __fastcall AchievementRowPool_Trampoline(void* pThis);
int __fastcall AchievementRowPool_Detour(void* pThis) { return ACHIEVEMENT_ROW_POOL_SIZE; }
DETOUR_TRAMPOLINE_EMPTY(int __fastcall AchievementRowPool_Trampoline(void* pThis));

// Hooks the CAchievementsWnd row-window pool sizing (sub_402F50).
void EnableAchievementRowPoolFix() {
	EzDetour((((DWORD)0x00402F50 - 0x400000) + baseAddress), AchievementRowPool_Detour, AchievementRowPool_Trampoline);
}
