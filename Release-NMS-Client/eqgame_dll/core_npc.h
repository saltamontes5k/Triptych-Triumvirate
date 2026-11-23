#pragma once

#include "MQ2Main.h"
#include "core_models.h"
#include "_options.h"
#include "core_log.h"

// AllLuclinPcModelsOff governs "classic mode" for races without their own UseLuclin keys
// (froglok 330, drakkin 522). Read raw instead of calling the client's toggle function:
// at table-build time the server feature bits behind the missing-key default may not
// have arrived yet.
static bool RetroRaces_ClassicMasterOff() {
	char buf[8] = {0};
	GetPrivateProfileStringA("Defaults", "AllLuclinPcModelsOff", "FALSE", buf, sizeof(buf), ".\\eqclient.ini");
	return buf[0] == 'T' || buf[0] == 't' || buf[0] == '1';
}

char* __fastcall InjectCustomNPCs_Trampoline(char* pThis, char* pPtr, int raceID, int genderID, const char* modelName, int raceMask, int dbStrID);
char* __fastcall InjectCustomNPCs_Detour(char*pThis, char* pPtr, int raceID, int genderID, const char* modelName, int raceMask, int dbStrID)
{


	if (!raceID) return InjectCustomNPCs_Trampoline(pThis, pPtr, raceID, genderID, modelName, raceMask, dbStrID);
	if (areRetroRacesEnabled) {
		// Retro Races: swap the model code the race table registers for select races,
		// but only when the client is in classic/old-models mode for that race.
		// vah shir 130 KEM/KEF -> CPM/CPF (kerran) keys off its own UseLuclinVahShirMale/Female;
		// drakkin 522 DKM/DKF -> SRW (sarnak) and froglok 330 FRM/FRF -> FRO (classic froglok,
		// which also fixes old-models froglok visibility) have no per-race keys, so the
		// AllLuclinPcModelsOff master governs them.
		const char* retroModel = nullptr;
		bool retro = false;
		if (raceID == 130) {
			retroModel = (genderID == 1) ? "CPF" : "CPM";
			char buf[8] = {0};
			GetPrivateProfileStringA("Defaults", (genderID == 1) ? "UseLuclinVahShirFemale" : "UseLuclinVahShirMale",
				"TRUE", buf, sizeof(buf), ".\\eqclient.ini");
			bool ownKeyOff = !(buf[0] == 'T' || buf[0] == 't' || buf[0] == '1');
			// The stock client special-cases race 130 BEFORE the master switch, but a player
			// who sets AllLuclinPcModelsOff=TRUE expects every race old-school - honor both.
			retro = ownKeyOff || RetroRaces_ClassicMasterOff();
		}
		else if (raceID == 522) {
			retroModel = "SRW";
			retro = RetroRaces_ClassicMasterOff();
		}
		else if (raceID == 330) {
			retroModel = "FRO";
			retro = RetroRaces_ClassicMasterOff();
		}
		if (retroModel && retro) {
			SimpleLog("Retro Races: race %d gender %d model %s -> %s", raceID, genderID, modelName, retroModel);
			return InjectCustomNPCs_Trampoline(pThis, pPtr, raceID, genderID, retroModel, raceMask, dbStrID);
		}
	}
	if (areCustomNPCsEnabled && raceID == 1) { // Trigger on Human load (very early)
		for (auto&& npc : NPCs) {
			char* modelNameUpper = _strdup(npc.modelName);
			SimpleLog("Injecting custom race: %d Model: %s Mask: %d (This=0x%p, Ptr=0x%p)", npc.raceID, modelNameUpper, npc.raceMask, pThis, pPtr);
			InjectCustomNPCs_Trampoline(pThis, pPtr, npc.raceID, npc.genderID, modelNameUpper, npc.raceMask, npc.dbStrID);
		}
	}
	// Log every race load to see what's happening
	// SimpleLog("Client loaded race: %d (%s) ModelPtr=0x%p", raceID, modelName ? modelName : "NULL", modelName);
	return InjectCustomNPCs_Trampoline(pThis, pPtr, raceID, genderID, modelName, raceMask, dbStrID);
}
DETOUR_TRAMPOLINE_EMPTY(char* __fastcall InjectCustomNPCs_Trampoline(char* pThis, char* pPtr, int raceID, int genderID, const char* modelName, int raceMask, int dbStrID));
// Hooks to CRaceGenderInfoManager::AddRaceGender
void InjectCustomNPCs() { EzDetour((((DWORD)0x0050A440 - 0x400000) + baseAddress), InjectCustomNPCs_Detour, InjectCustomNPCs_Trampoline); };
//signed int __thiscall CRaceGenderInfoManager::AddRaceGender(signed int* this, int a2, int a3, const char* a4, int a5, int a6)


char* __stdcall InjectCustomOldAnimations_Trampoline(char* pOriginalModel, char* pReplacementModel, char isReplaced);
char* __stdcall InjectCustomOldAnimations_Detour(char* pOriginalModel, char* pReplacementModel, char isReplaced) {
	// SimpleLog("Animation Request: Original='%s' CurrentReplacement='%s'", pOriginalModel, pReplacementModel);
	for (auto&& anim : CustomAnimations) {
		if (anim.originalName && pOriginalModel && _stricmp(pOriginalModel, anim.originalName) == 0) {
			strcpy(pReplacementModel, anim.replacementName);
			SimpleLog("Injecting custom animation mapping: %s => %s", anim.originalName, anim.replacementName);
			isReplaced = 0x0;
			return &isReplaced;
		}
	}
	SimpleLog("Client requested animation tag: %s (Current Replacement: %s)", pOriginalModel, pReplacementModel);
	auto ret = InjectCustomOldAnimations_Trampoline(pOriginalModel, pReplacementModel, isReplaced);
	return ret;
}
DETOUR_TRAMPOLINE_EMPTY(char* __stdcall InjectCustomOldAnimations_Trampoline(char* pOriginalModel, char* pReplacementModel, char isReplaced));
// Hooks to GetAlternateAnimTag
void InjectCustomOldAnimations() { EzDetour((((DWORD)0x00406a60 - 0x400000) + baseAddress), InjectCustomOldAnimations_Detour, InjectCustomOldAnimations_Trampoline); };
//char __stdcall ActorAnimation::GetAlternateAnimTag(char* a2, char* a3, bool a4)
