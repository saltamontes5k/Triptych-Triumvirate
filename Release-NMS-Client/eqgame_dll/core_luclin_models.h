#pragma once

#include "MQ2Main.h"

unsigned int __cdecl DisableLuclinModels_Trampoline(char* lpAppName, char* lpKeyName, char* lpDefault, char* lpReturnedString, size_t nSize, char* lpFileName);
unsigned int __cdecl DisableLuclinModels_Detour(char* lpAppName, char* lpKeyName, char* lpDefault, char* lpReturnedString, size_t nSize, char* lpFileName)
{
	// lpAppName should be "Defaults"
	if (strcmp(lpAppName, "Defaults")) return DisableLuclinModels_Trampoline(lpAppName, lpKeyName, lpDefault, lpReturnedString, nSize, lpFileName);

	// compare Name and find luclin in it
	if (strstr(lpKeyName, "UseLuclin")) {
		strncpy(lpReturnedString, "FALSE", 5);
		return strlen(lpReturnedString);
	}

	return DisableLuclinModels_Trampoline(lpAppName, lpKeyName, lpDefault, lpReturnedString, nSize, lpFileName);
}
DETOUR_TRAMPOLINE_EMPTY(unsigned int __cdecl DisableLuclinModels_Trampoline(char* lpAppName, char* lpKeyName, char* lpDefault, char* lpReturnedString, size_t nSize, char* lpFileName));
// Hooks to GetINIFile
void DisableLuclinModels() { EzDetour((((DWORD)0x00860EF0 - 0x400000) + baseAddress), DisableLuclinModels_Detour, DisableLuclinModels_Trampoline); }
