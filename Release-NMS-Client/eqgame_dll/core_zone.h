#pragma once

#include "MQ2Main.h"
#include "core_models.h"
#include "_options.h"

static vector<int> zonesToInject;
static bool isEndOfZones = false;
 
char* __fastcall InjectCustomZones_Trampoline(char* pThis, char* pPtr, unsigned __int32 zoneType, unsigned __int32 zoneID, char* zoneShortName, char* zoneLongName, unsigned __int32 eqStrID, __int32 zoneFlags2, __int32 x, __int32 y, __int32 z);
char* __fastcall InjectCustomZones_Detour(char* pThis, char* pPtr, unsigned __int32 zoneType, unsigned __int32 zoneID, char* zoneShortName, char* zoneLongName, unsigned __int32 eqStrID, __int32 zoneFlags2, __int32 x, __int32 y, __int32 z)
{ 
	if (!isEndOfZones) {
		for (auto&& zone : Zones) {
			if (zoneID != zone.zoneID) {
				continue;
			}
			zonesToInject.erase(std::remove(zonesToInject.begin(), zonesToInject.end(), zone.zoneID), zonesToInject.end());
			DebugSpew("replacing zone %s id %d", zone.zoneShortName, zone.zoneID);
			return InjectCustomZones_Trampoline(pThis, pPtr, zone.zoneType, zone.zoneID, zone.zoneShortName, zone.zoneLongName, zone.eqStrID, zone.zoneFlags2, zone.x, zone.y, zone.z);
		}
		DebugSpew("original zone %s id %d", zoneShortName, zoneID);
	}
	return InjectCustomZones_Trampoline(pThis, pPtr, zoneType, zoneID, zoneShortName, zoneLongName, eqStrID, zoneFlags2, x, y, z);
}

DETOUR_TRAMPOLINE_EMPTY(char* __fastcall InjectCustomZones_Trampoline(char* pThis, char* pPtr, unsigned __int32 zoneType, unsigned __int32 zoneID, char* zoneShortName, char* zoneLongName, unsigned __int32 eqStrID, __int32 zoneFlags2, __int32 x, __int32 y, __int32 z));


char* __fastcall InjectCustomZonesAdd_Trampoline(char* pThis, char* pPtr, unsigned __int32 zoneType, unsigned __int32 zoneID, char* zoneShortName, char* zoneLongName, unsigned __int32 eqStrID, __int32 zoneFlags2, __int32 x, __int32 y, __int32 z);
char* __fastcall InjectCustomZonesAdd_Detour(char* pThis, char* pPtr, unsigned __int32 zoneType, unsigned __int32 zoneID, char* zoneShortName, char* zoneLongName, unsigned __int32 eqStrID, __int32 zoneFlags2, __int32 x, __int32 y, __int32 z)
{
	if (!strcmp(zoneShortName, "interiorwalltest")) {
		DebugSpew("original zone %s id %d", zoneShortName, zoneID); // this is just to echo interiorwalltest
		DebugSpew("reached end of zone loading, now adding any custom zones");
		isEndOfZones = true;
		for (auto&& zoneID : zonesToInject) {
			for (auto&& zone : Zones) {
				if (zoneID != zone.zoneID) {
					continue;
				}
				DebugSpew("adding zone %s id %d", zone.zoneShortName, zone.zoneID);
				InjectCustomZonesAdd_Trampoline(pThis, pPtr, zone.zoneType, zone.zoneID, zone.zoneShortName, zone.zoneLongName, zone.eqStrID, zone.zoneFlags2, zone.x, zone.y, zone.z);
			}
		}
	}
	return InjectCustomZonesAdd_Trampoline(pThis, pPtr, zoneType, zoneID, zoneShortName, zoneLongName, eqStrID, zoneFlags2, x, y, z);
}

DETOUR_TRAMPOLINE_EMPTY(char* __fastcall InjectCustomZonesAdd_Trampoline(char* pThis, char* pPtr, unsigned __int32 zoneType, unsigned __int32 zoneID, char* zoneShortName, char* zoneLongName, unsigned __int32 eqStrID, __int32 zoneFlags2, __int32 x, __int32 y, __int32 z));

// Hooks to EQWorldData::AddZone
void InjectCustomZones() {
	for (auto&& zone : Zones) {
		zonesToInject.push_back(zone.zoneID);
	}
	isEndOfZones = false;
	EzDetour((((DWORD)0x007DC430 - 0x400000) + baseAddress), InjectCustomZonesAdd_Detour, InjectCustomZonesAdd_Trampoline);
	EzDetour((((DWORD)0X007DC290 - 0x400000) + baseAddress), InjectCustomZones_Detour, InjectCustomZones_Trampoline); 
};
//bool __thiscall sub_7DC430(_DWORD *this, int a2, int a3, char *a4, char *a5, int a6, int a7, int a8, int a9, int a10)
