#include "StdAfx.h"
#include <WinSock2.h>
#include "Utils.h"

#ifndef BASE_H
#define BASE_H

class Base
{
public:
	static Base* GetInstance();
	static Base* gInstance;

	void InitHooks();
	DWORD dwCodeSize;
	DWORD dwCodeOffset;
	DWORD dwEntryPoint;

private:
	Base();
};

struct CallHook {
	BYTE bOriginalCode[5];
	PBYTE pPlace;
	PVOID pOriginal;

	void initialize(const char* pOriginalCode, PBYTE place);
	int installHook(void(*hookToInstall)(), bool unprotect);
	int releaseHook(bool unprotect);
};

struct PointerHook {
	PVOID* pPlace;
	PVOID pOriginal;

	void initialize(PVOID* place);
	int installHook(void(*hookToInstall)(), bool unprotect);
	int releaseHook(bool unprotect);
};

struct StompHook {
	BYTE bOriginalCode[15];
	BYTE bCountBytes;
	PBYTE pPlace;

	void initialize(const char* pOriginalCode, BYTE countBytes, PBYTE place);
	int installHook(void(*hookToInstall)(), bool useJump, bool unprotect);
	int releaseHook(bool unprotect);
};

#endif
