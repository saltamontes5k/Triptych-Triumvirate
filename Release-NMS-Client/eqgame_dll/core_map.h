#pragma once

#include "MQ2Main.h"

char __fastcall DisableCMapViewWnd_Trampoline(char* pThis);
char __fastcall DisableCMapViewWnd_Detour(char* pThis) { return 0;  }
DETOUR_TRAMPOLINE_EMPTY(char __fastcall DisableCMapViewWnd_Trampoline(char* pThis));
// Hooks to CMapViewWnd::AboutToShow
void DisableCMapViewWnd() { EzDetour((((DWORD)0x006CF4A0 - 0x400000) + baseAddress), DisableCMapViewWnd_Detour, DisableCMapViewWnd_Trampoline); };
