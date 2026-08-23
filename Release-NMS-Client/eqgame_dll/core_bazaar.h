#pragma once

#include "MQ2Main.h"

char __fastcall DisableCBazaarSearchWnd_Trampoline(char* pThis);
char __fastcall DisableCBazaarSearchWnd_Detour(char* pThis) { return 0; }
DETOUR_TRAMPOLINE_EMPTY(char __fastcall DisableCBazaarSearchWnd_Trampoline(char* pThis));
// Hooks to CBazaarSearchWnd::AboutToShow
void DisableCBazaarSearchWnd() { EzDetour((((DWORD)0x00636670 - 0x400000) + baseAddress), DisableCBazaarSearchWnd_Detour, DisableCBazaarSearchWnd_Trampoline); };
