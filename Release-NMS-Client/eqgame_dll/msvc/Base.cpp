#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#pragma comment (lib, "d3d10.lib")

#include <iostream>
#include <vector>
#include <string>
#include <io.h>
#include <stdlib.h>
#include <stdio.h>
#include "Base.h"
#include "CPatcher.h"

#define CONSOLE_TITLE "dinput8-hook"

Base* Base::gInstance = NULL;
Base* Base::GetInstance()
{
	if (gInstance == NULL) gInstance = new Base;
	return gInstance;
}

Base::Base()
{
	HANDLE hModule = GetModuleHandle(NULL);
	dwCodeSize = Utils::GetSizeOfCode(hModule);
	dwCodeOffset = Utils::OffsetToCode(hModule);
	dwEntryPoint = (DWORD)hModule + dwCodeOffset;
}

void Base::InitHooks()
{
	Utils::AllocateConsole(CONSOLE_TITLE);
	Log_Clear();
}

void CallHook::initialize(const char* pOriginalCode, PBYTE place)
{
	pPlace = place;
	memcpy(bOriginalCode, pPlace, sizeof(bOriginalCode));
	pOriginal = place + sizeof(bOriginalCode) + *(ptrdiff_t*)(bOriginalCode + 1);
}

int CallHook::installHook(void(*hookToInstall)(), bool unprotect)
{
	DWORD d = 0;
	if (unprotect && !VirtualProtect(pPlace + 1, sizeof(ptrdiff_t), PAGE_READWRITE, &d)) return 0;
	*(ptrdiff_t*)(pPlace + 1) = (PBYTE)hookToInstall - pPlace - sizeof(bOriginalCode);
	if (unprotect) VirtualProtect(pPlace + 1, sizeof(ptrdiff_t), d, &d);
	return 1;
}

int CallHook::releaseHook(bool unprotect)
{
	DWORD d = 0;
	if (unprotect && !VirtualProtect(pPlace + 1, sizeof(ptrdiff_t), PAGE_READWRITE, &d)) return 0;
	memcpy(pPlace + 1, bOriginalCode + 1, sizeof(bOriginalCode) - 1);
	if (unprotect) VirtualProtect(pPlace + 1, sizeof(ptrdiff_t), d, &d);
	return 1;
}

void PointerHook::initialize(PVOID* place)
{
	pPlace = place;
	pOriginal = NULL;
}

int PointerHook::installHook(void(*hookToInstall)(), bool unprotect)
{
	DWORD d = 0;
	if (pOriginal) return 0;
	if (unprotect && !VirtualProtect(pPlace, sizeof(PVOID), PAGE_READWRITE, &d)) return 0;
	pOriginal = *pPlace;
	*pPlace = (PVOID)hookToInstall;
	if (unprotect) VirtualProtect(pPlace, sizeof(PVOID), d, &d);
	return 1;
}

int PointerHook::releaseHook(bool unprotect)
{
	DWORD d = 0;
	if (!pOriginal) return 0;
	if (unprotect && !VirtualProtect(pPlace, sizeof(PVOID), PAGE_READWRITE, &d)) return 0;
	*pPlace = pOriginal;
	pOriginal = NULL;
	if (unprotect) VirtualProtect(pPlace, sizeof(PVOID), d, &d);
	return 1;
}

void StompHook::initialize(const char* pOriginalCode, BYTE countBytes, PBYTE place)
{
	pPlace = place;
	bCountBytes = countBytes < sizeof(bOriginalCode) ? countBytes : sizeof(bOriginalCode);
	memcpy(bOriginalCode, pPlace, bCountBytes);
}

int StompHook::installHook(void(*hookToInstall)(), bool useJump, bool unprotect)
{
	DWORD d = 0;
	if (unprotect && !VirtualProtect(pPlace, bCountBytes, PAGE_READWRITE, &d)) return 0;
	memset(pPlace, 0x90U, bCountBytes);
	pPlace[0] = useJump ? 0xE9U : 0xE8U;
	*(ptrdiff_t*)(pPlace + 1) = (PBYTE)hookToInstall - pPlace - 5;
	if (unprotect) VirtualProtect(pPlace, bCountBytes, d, &d);
	return 1;
}

int StompHook::releaseHook(bool unprotect)
{
	DWORD d = 0;
	if (unprotect && !VirtualProtect(pPlace, bCountBytes, PAGE_READWRITE, &d)) return 0;
	memcpy(pPlace, bOriginalCode, bCountBytes);
	if (unprotect) VirtualProtect(pPlace, bCountBytes, d, &d);
	return 1;
}

