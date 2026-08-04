#pragma once

#include "MQ2Main.h"
#include "core_models.h"
#include "_options.h"

// For thiscall convention functions, we need to use this typedef approach
typedef signed int (__fastcall *tIsShield)(void* pThis, void* edx, signed int itemID);
tIsShield InjectIsShield_Trampoline = nullptr;

// Define the detour function - use __fastcall and ignore the edx parameter to match thiscall
signed int __fastcall InjectIsShield_Detour(void* pThis, void* edx, signed int itemID) {
    for (auto&& shieldID : Shields) {
        if (itemID != shieldID) {
            continue;
        }
        return 1;
    }

    if (areDefaultShieldsIgnored) {
        return 0;
    }
    return InjectIsShield_Trampoline(pThis, nullptr, itemID);
}

// Modify your injection function
void InjectCustomShields() {
    DWORD targetAddress = baseAddress + (0x00489D70 - 0x400000);
    
    // Store the original function pointer and set up the detour
    *(PBYTE*)&InjectIsShield_Trampoline = DetourFunction((PBYTE)targetAddress, (PBYTE)InjectIsShield_Detour);
}