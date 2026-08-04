#pragma once
/*****************************************************************************
MQ2Main.dll: MacroQuest2's extension DLL for EverQuest
Copyright (C) 2002-2003 Plazmic, 2003-2005 Lax

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License, version 2, as published by
the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
******************************************************************************/

#define VersionString "September 23, 2004"
#define DebugHeader "[Edge]"
#define LoadedString "Edge Extensions Loaded."
#define ToUnloadString "Edge Unloading..."
#define UnloadedString "Edge Unloaded."

#define WIN32_LEAN_AND_MEAN
#define _WIN32_WINNT 0x510
#define DIRECTINPUT_VERSION 0x800


// uncomment this line to turn off the single-line benchmark macro
// #define DISABLE_BENCHMARKS

#pragma warning(disable:4530)
#pragma warning(disable:4786)

// Windows Header Files:
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <io.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <winsock.h>
#include <math.h>
#include <map>
#include <string>
#include <vector>
#include <algorithm>
#include <chrono>
#include <random>
using namespace std;

#define PLUGIN_API 

#if !defined(ISXEQ) && !defined(ISXEQ_LEGACY)
// MQ2
#include <dinput.h>
#include "..\Detours\inc\detours.h" 
#include "..\Blech\Blech.h"
#elif !defined(ISXEQ_LEGACY)
// ISXEQ
#ifndef MQ2PLUGIN
#include "ISXEQ\ISXEQ.h"
#else
#pragma pack(push)
#pragma pack(4)
#include <isxdk.h>
#pragma pack(pop)
#include "ISXEQ\ISXEQServices.h"
#endif
#define PMQ2TYPEMEMBER PLSTYPEMEMBER
#define PMQ2TYPEMETHOD PLSTYPEMETHOD
#define MQ2Type LSType
#define MQ2TYPEVAR LSTYPEVAR

#else
// ISXEQ_LEGACY
#include <winthreading.h>
#include <Index.h>
#include "..\Dxsdk81\include\dinput.h"
#include "..\Blech\Blech.h"
#endif
#include "eqgame.h"

#ifdef ISXEQ_LEGACY
#define LEGACY_API extern
#define LEGACY_VAR extern
#else
#define LEGACY_API EQLIB_API
#define LEGACY_VAR EQLIB_VAR
#endif

#ifdef EQLIB_EXPORTS
#define EQLIB_API extern "C" __declspec(dllexport)
#define EQLIB_VAR extern "C" __declspec(dllexport)
#define EQLIB_OBJECT __declspec(dllexport)
#else
#define EQLIB_API extern "C" __declspec(dllimport)
#define EQLIB_VAR extern "C" __declspec(dllimport)
#define EQLIB_OBJECT __declspec(dllimport)
#endif

#ifdef MQ2PLUGIN
#define FromPlugin 1
#else
#define FromPlugin 0
#endif

// Lax/Blech event support *READY*
#define USEBLECHEVENTS


// reroute malloc/free
EQLIB_API VOID *MQ2Malloc(size_t size);
EQLIB_API VOID MQ2Free(VOID *memblock);
/*
#ifdef MQ2PLUGIN
#define malloc(x) MQ2Malloc(x)
#define free(x) MQ2Free(x)
#else
#ifdef DEBUG_ALLOC
#define malloc(x) MQ2Malloc(x)
#define free(x) MQ2Free(x)
#endif
#endif
*/
#ifdef DEBUG_ALLOC
extern DWORD CountMallocs;
extern DWORD CountFrees;
#endif

#ifndef ISXEQ
#define FUNCTION_AT_ADDRESS(function,offset) __declspec(naked) function\
{\
    __asm{mov eax, offset};\
    __asm{jmp eax};\
}

#define FUNCTION_AT_VARIABLE_ADDRESS(function,variable) __declspec(naked) function\
{\
    __asm{mov eax, [variable]};\
    __asm{jmp eax};\
}

#define FUNCTION_AT_VIRTUAL_ADDRESS(function,virtualoffset) __declspec(naked) function\
{\
    __asm{mov eax, [ecx]};\
    __asm{lea eax, [eax+virtualoffset]};\
    __asm{mov eax, [eax]};\
    __asm{jmp eax};\
}
#endif

#define PreserveRegisters(code) \
{\
    __asm {push eax};\
    __asm {push ebx};\
    __asm {push ecx};\
    __asm {push edx};\
    __asm {push esi};\
    __asm {push edi};\
    code;\
    __asm {pop edi};\
    __asm {pop esi};\
    __asm {pop edx};\
    __asm {pop ecx};\
    __asm {pop ebx};\
    __asm {pop eax};\
}

#define SetWndNotification(thisclass) \
{\
    int (thisclass::*pfWndNotification)(CXWnd *pWnd, unsigned int Message, void *unknown)=&thisclass::WndNotification;\
    SetvfTable(34,*(DWORD*)&pfWndNotification);\
}

#ifndef ISXEQ
#ifdef ISXEQ_LEGACY
#define EzDetour(offset,detour,trampoline)
#define DETOUR_TRAMPOLINE_EMPTY(blah)
#else
#define EzDetour(offset,detour,trampoline) AddDetourf((DWORD)offset,detour,trampoline)
#endif
#endif

#ifndef DOUBLE
typedef double DOUBLE;
#endif
#ifndef THIS_
#define THIS_                   INTERFACE FAR* This,
#endif

// DEBUGGING
//#ifndef DEBUG_TRY
//#define DEBUG_TRY
//#endif
#ifdef DEBUG_TRY
#define DebugTry(x) DebugSpew("Trying %s",#x);x;DebugSpew("%s complete",#x)
#else
#define DebugTry(x) x
#endif

#ifndef ISXEQ
#define MakeLower(yourstring) transform (yourstring.begin(),yourstring.end(), yourstring.begin(), tolower);
#endif

#define MAX_VARNAME 64
#define MAX_STRING            2048

#define IsNaN(x) (x != x)
#include <d3d9.h>
#include "EQData.h"
#include "EQUIStructs.h"

#include <fenv.h>
#include <winternl.h>
#include <tchar.h>
#include <Psapi.h>
#include <d3dx9math.h>

#pragma comment(lib, "d3d9.lib")
#pragma comment(lib, "D3dx9.lib")

//class CXMLData *GetXMLData(class CXWnd *pWnd)

#include "EQClasses.h"

#include "MQ2Prototypes.h"
#include "MQ2Internal.h"
#include "MQ2Globals.h"

/* SPAWN HANDLING */
EQLIB_API VOID InitializeMQ2Spawns();
EQLIB_API VOID ShutdownMQ2Spawns();
EQLIB_API VOID UpdateMQ2SpawnSort();
EQLIB_API BOOL SetNameSpriteState(PSPAWNINFO pSpawn, bool Show);
EQLIB_API BOOL IsTargetable(PSPAWNINFO pSpawn);

/* WINDOWS */
EQLIB_API VOID InitializeMQ2Windows();
EQLIB_API VOID ShutdownMQ2Windows();
EQLIB_API void RemoveXMLFile(const char *filename);
EQLIB_API void AddXMLFile(const char *filename);
EQLIB_API bool SendWndClick(PCHAR WindowName, PCHAR ScreenID, PCHAR ClickNotification);
EQLIB_API bool SendWndNotification(PCHAR WindowName, PCHAR ScreenID, DWORD Notification, VOID *Data=0);
EQLIB_API void AddWindow(char *WindowName, CXWnd **ppWindow);
EQLIB_API void RemoveWindow(char *WindowName);
EQLIB_API CXWnd *FindMQ2Window(PCHAR Name);
EQLIB_API CXWnd *GetParentWnd(class CXWnd const * pWnd);

EQLIB_API bool SendListSelect(PCHAR WindowName, PCHAR ScreenID, DWORD Value);
EQLIB_API bool SendWndClick2(CXWnd *pWnd, PCHAR ClickNotification);

/* CHAT HOOK */
EQLIB_API VOID InitializeChatHook();
EQLIB_API VOID ShutdownChatHook();
EQLIB_API VOID dsp_chat_no_events(const char *,int,bool,bool=1);
PLUGIN_API VOID InitializeFloatingTextPlugin(VOID);

PLUGIN_API VOID OnDPSCleanUI(VOID);
PLUGIN_API VOID OnDPSReloadUI(VOID);
PLUGIN_API VOID DPSShutdownPlugin(VOID);
PLUGIN_API DWORD OnDPSIncomingChat(PCHAR Line, DWORD Color);
PLUGIN_API VOID OnDPSPulse(VOID);

/* DETOURING API */
EQLIB_API VOID InitializeMQ2Detours();
EQLIB_API VOID ShutdownMQ2Detours();
#ifndef ISXEQ
#ifdef ISXEQ_LEGACY
#define RemoveDetour(address)
#define AddDetour __noop
#define AddDetourf __noop
#else
EQLIB_API BOOL AddDetour(DWORD address, PBYTE pfDetour=0, PBYTE pfTrampoline=0, DWORD Count=20);
EQLIB_API VOID AddDetourf(DWORD address, ...);
EQLIB_API VOID RemoveDetour(DWORD address);
#endif
#else
#define RemoveDetour EzUnDetour
#endif

/* PLUGIN HANDLING */
EQLIB_API VOID WriteChatf(PCHAR Format, ...);
EQLIB_API VOID WriteChatColor(PCHAR Line, DWORD Color=USERCOLOR_DEFAULT, DWORD Filter=0);
#ifndef ISXEQ
#endif
EQLIB_API VOID OnAddSpawn(PSPAWNINFO pNewSpawn);
PLUGIN_API VOID OnRemoveSpawn(PSPAWNINFO pSpawn);
// Deleted InitializeDPSPlugin
PLUGIN_API VOID OnDPSBeginZone(VOID);
PLUGIN_API VOID OnFloatingTextManagerBeginZone();
PLUGIN_API VOID OnFloatingTextManagerEndZone();
PLUGIN_API VOID OnDPSEndZone(VOID);
PLUGIN_API BOOL OnLabelReceivePPPacket(VOID);
EQLIB_API VOID PulsePlugins();
EQLIB_API BOOL PluginsIncomingChat(PCHAR Line, DWORD Color);
EQLIB_API VOID PluginsCleanUI();
EQLIB_API VOID PluginsReloadUI();
EQLIB_API VOID PluginsSetGameState(DWORD GameState);
EQLIB_API VOID PluginsDrawHUD();
EQLIB_API VOID PluginsAddGroundItem(PGROUNDITEM pNewGroundItem);
EQLIB_API VOID PluginsRemoveGroundItem(PGROUNDITEM pGroundItem);
EQLIB_API VOID PluginsBeginZone(VOID); 
EQLIB_API VOID PluginsEndZone(VOID); 

/* DIRECT INPUT */
#ifndef ISXEQ
#endif

/* CLEAN UI */
EQLIB_API VOID InitializeDisplayHook();
EQLIB_API VOID ShutdownDisplayHook();
EQLIB_API VOID DrawHUD();

/* COMMAND HANDLING */
LEGACY_API VOID InitializeMQ2Commands();
LEGACY_API VOID InitializeMapPlugin();
PLUGIN_API VOID SetMapGameState(DWORD GameState);

// Removed Legacy EdgeDPS methods
PLUGIN_API VOID SetEdgeDPSGameState(DWORD GameState);
PLUGIN_API BOOL OnRecvEdgeDPSPacket(DWORD Type, PVOID Packet, DWORD Size);
PLUGIN_API BOOL OnRecvServerAuthStatLabelPacket(DWORD Type, PVOID Packet, DWORD Size);
LEGACY_API VOID InitializeMQ2ItemDisplay();
LEGACY_API VOID InitializeMQ2Labels();
LEGACY_API VOID ShutdownMQ2Commands();
LEGACY_API VOID AddCommand(PCHAR Command, fEQCommand Function, BOOL EQ=0, BOOL Parse=1, BOOL InGame=0);
LEGACY_API VOID AddAlias(PCHAR ShortCommand, PCHAR LongCommand);
LEGACY_API BOOL RemoveAlias(PCHAR ShortCommand);
LEGACY_API VOID AddSubstitute(PCHAR Original, PCHAR Substitution);
LEGACY_API BOOL RemoveSubstitute(PCHAR Original);
LEGACY_API BOOL RemoveCommand(PCHAR Command);
LEGACY_API VOID DoTimedCommands();
LEGACY_API VOID TimedCommand(PCHAR Command, DWORD msDelay);

/* MACRO COMMANDS */
LEGACY_API VOID DumpStack                           (PSPAWNINFO,PCHAR);
LEGACY_API VOID EndMacro                            (PSPAWNINFO,PCHAR);
LEGACY_API VOID Echo                                (PSPAWNINFO,PCHAR);


/* MACRO PARSING */
#ifdef USEBLECHEVENTS
void __stdcall EventBlechCallback(unsigned int ID, void * pData, PBLECHVALUE pValues);
#endif
#define PMP_ERROR_BADPARM 10000
LEGACY_API PCHAR ParseMacroParameter(PSPAWNINFO pChar, PCHAR szOriginal);
#ifndef ISXEQ
LEGACY_API VOID FailIf(PSPAWNINFO pChar, PCHAR szCommand, PMACROBLOCK pStartLine, BOOL All=FALSE);
LEGACY_API VOID InitializeParser();
LEGACY_API VOID ShutdownParser();

LEGACY_API VOID InitializeMQ2DataTypes();
LEGACY_API VOID ShutdownMQ2DataTypes();
LEGACY_API VOID InitializeMQ2Data();
LEGACY_API VOID ShutdownMQ2Data();
LEGACY_API BOOL ParseMacroData(PCHAR szOriginal);
LEGACY_API BOOL ParseMacroVariables(PCHAR szOriginal);
LEGACY_API BOOL AddMQ2Data(PCHAR szName, fMQData Function);
LEGACY_API BOOL RemoveMQ2Data(PCHAR szName);
LEGACY_API MQ2Type *FindMQ2DataType(PCHAR szName);
LEGACY_API PMQ2DATAITEM FindMQ2Data(PCHAR szName);
LEGACY_API PDATAVAR FindMQ2DataVariable(PCHAR szName);
LEGACY_API BOOL ParseMQ2DataPortion(PCHAR szOriginal, MQ2TYPEVAR &Result);
#endif


/* MOUSE */
EQLIB_API BOOL IsMouseWaiting(VOID);
EQLIB_API BOOL IsMouseWaitingForButton();

/* KEY BINDS */
EQLIB_API BOOL PressMQ2KeyBind(PCHAR name, BOOL Hold);
EQLIB_API BOOL SetMQ2KeyBind(PCHAR name, BOOL Alternate, KeyCombo &Combo);
EQLIB_API BOOL AddMQ2KeyBind(PCHAR name, fMQExecuteCmd Function);
EQLIB_API BOOL RemoveMQ2KeyBind(PCHAR name);
EQLIB_API BOOL GetMQ2KeyBind(PCHAR name, BOOL Alt, KeyCombo &Combo);

/* PULSING */
EQLIB_API VOID InitializeMQ2Pulse();
EQLIB_API VOID ShutdownMQ2Pulse();

/* OTHER IMPORTED FROM EQ */
EQLIB_API int CastRay(PSPAWNINFO,float y,float x,float z);
EQLIB_API unsigned long GetFastTime(void);
EQLIB_API char * __stdcall GetXtargetType(DWORD type);
EQLIB_API DWORD EQGetTime();

/* UTILITIES */
EQLIB_API VOID ConvertCR(PCHAR Text);
EQLIB_API VOID DrawHUDText(PCHAR Text, DWORD X, DWORD Y, DWORD Argb, DWORD Size);
EQLIB_API VOID FixStringTable();
EQLIB_API VOID DebugSpew(PCHAR szFormat, ...);
EQLIB_API VOID DebugSpewAlways(PCHAR szFormat, ...);
EQLIB_API VOID DebugSpewNoFile(PCHAR szFormat, ...);
#ifndef ISXEQ
LEGACY_API PSTR GetNextArg(PCSTR szLine, DWORD dwNumber = 1, BOOL CSV = FALSE, CHAR Separator = 0);
LEGACY_API PSTR GetArg(PSTR szDest, PCSTR szSrc, DWORD dwNumber, BOOL LeaveQuotes = FALSE, BOOL ToParen = FALSE, BOOL CSV = FALSE, CHAR Separator = 0, BOOL AnyNonAlphaNum = FALSE);
#endif
LEGACY_API VOID AddCustomEvent(PEVENTLIST pEList, PCHAR szLine);
EQLIB_API FLOAT DistanceToSpawn(PSPAWNINFO pChar, PSPAWNINFO pSpawn);
EQLIB_API PCHAR GetEQPath(PCHAR szBuffer);

#define DoCommand(pspawninfo,commandtoexecute) HideDoCommand(pspawninfo,commandtoexecute,FromPlugin)
LEGACY_API VOID HideDoCommand(PSPAWNINFO pChar, PCHAR szLine, BOOL delayed);
#define EzCommand(commandtoexecute) DoCommand((PSPAWNINFO)pLocalPlayer,commandtoexecute)

EQLIB_API VOID AppendCXStr(PCXSTR *cxstr, PCHAR text); 
EQLIB_API VOID SetCXStr(PCXSTR *cxstr, PCHAR text); 
EQLIB_API DWORD GetCXStr(PCXSTR pCXStr, PCHAR szBuffer, DWORD maxlen=MAX_STRING);
EQLIB_API DWORD MQToSTML(PCHAR in, PCHAR out, DWORD maxlen=MAX_STRING, DWORD ColorOverride=0xFFFFFF);
EQLIB_API VOID StripMQChat(PCHAR in, PCHAR out);
EQLIB_API VOID STMLToPlainText(PCHAR in, PCHAR out);
EQLIB_API PCHAR GetSubFromLine(PMACROBLOCK pLine, PCHAR szSub);
EQLIB_API PCHAR GetFilenameFromFullPath(PCHAR Filename);
EQLIB_API BOOL CompareTimes(PCHAR RealTime, PCHAR ExpectedTime);
EQLIB_API VOID AddFilter(PCHAR szFilter, DWORD Length, PBOOL pEnabled);
EQLIB_API VOID DefaultFilters(VOID);
EQLIB_API PCHAR ConvertHotkeyNameToKeyName(PCHAR szName);
LEGACY_API VOID CheckChatForEvent(PCHAR szMsg);
EQLIB_API VOID ConvertItemTags(CXStr &cxstr, BOOL Tag=TRUE);
EQLIB_API BOOL ParseKeyCombo(PCHAR text, KeyCombo &Dest);
EQLIB_API PCHAR DescribeKeyCombo(KeyCombo &Combo, PCHAR szDest);
EQLIB_API int FindInvSlotForContents(PCONTENTS pContents);
EQLIB_API int FindInvSlot(PCHAR Name, BOOL Exact);
EQLIB_API int FindNextInvSlot(PCHAR Name, BOOL Exact);
EQLIB_API int FindMappableCommand(const char *name);

EQLIB_API int GetLanguageIDByName(PCHAR szName);
EQLIB_API PCHAR GetSpellNameByID(DWORD dwSpellID);
EQLIB_API PSPELL GetSpellByName(PCHAR szName);
EQLIB_API struct  _ITEMINFO *GetItemFromContents(struct _CONTENTS *c);
#include "MQ2Inlines.h"


#ifdef ISXEQ
#define GETMEMBER() GetMember(LSVARPTR VarPtr, PCHAR Member, int argc, char *argv[], LSTYPEVAR &Dest)
#define GETMETHOD() GetMethod(LSVARPTR &VarPtr, PCHAR Method, int argc, char *argv[])
#define DECLAREGETMETHOD() bool GETMETHOD()
#else
#define GETMEMBER() GetMember(MQ2VARPTR VarPtr, PCHAR Member, PCHAR Index, MQ2TYPEVAR &Dest)
#define DECLAREGETMETHOD()
#define INHERITDIRECT(X)
#define INHERITINDIRECT(X,Y,Z)
#endif

#include "MQ2DataTypes.h"

#ifndef ISXEQ
LEGACY_API PMACROBLOCK AddMacroLine(PCHAR szLine);
#endif

template<typename T>
T Clamp(const T& value, const T& lower, const T& upper)
{
	return max(lower, min(value, upper));
}

EQLIB_API PCHAR GetLightForSpawn(PSPAWNINFO pSpawn);
EQLIB_API DWORD GetSpellDuration(PSPELL pSpell, PSPAWNINFO pSpawn);
EQLIB_API DWORD GetDeityTeamByID(DWORD DeityID);
EQLIB_API DWORD ConColor(PSPAWNINFO pSpawn);
EQLIB_API PCHAR GetGuildByID(DWORD GuildID);
EQLIB_API DWORD GetGuildIDByName(PCHAR szGuild);
EQLIB_API PCONTENTS GetEnviroContainer();
EQLIB_API PEQCONTAINERWINDOW FindContainerForContents(PCONTENTS pContents);
EQLIB_API FLOAT FindSpeed(PSPAWNINFO pSpawn);
EQLIB_API BOOL IsNamed(PSPAWNINFO pSpawn);
EQLIB_API VOID GetItemLinkHash(PCONTENTS Item, PCHAR Buffer);
EQLIB_API VOID GetItemLink(PCONTENTS Item, PCHAR Buffer);
EQLIB_API VOID SendEQMessage(DWORD PacketType, PVOID pData, DWORD Length);
EQLIB_API PCHAR GetLoginName();
EQLIB_API FLOAT DistanceToPoint(PSPAWNINFO pSpawn, FLOAT xLoc, FLOAT yLoc);
EQLIB_API PCHAR ShowSpellSlotInfo(PSPELL pSpell, PCHAR szBuffer);
EQLIB_API VOID SlotValueCalculate(PCHAR szBuff, PSPELL pSpell, int i, double mp);
EQLIB_API PCHAR GetSpellEffectName(DWORD EffectID, PCHAR szBuffer);
EQLIB_API VOID GetGameDate(int* Month, int* Day, int* Year);
EQLIB_API VOID GetGameTime(int* Hour, int* Minute, int* Night);
LEGACY_API VOID SyntaxError(PCHAR szFormat, ...);
LEGACY_API VOID MacroError(PCHAR szFormat, ...);
LEGACY_API VOID FatalError(PCHAR szFormat, ...);
#ifndef ISXEQ
LEGACY_API VOID MQ2DataError(PCHAR szFormat, ...);
#endif
EQLIB_API void DisplayOverlayText(PCHAR szText, DWORD dwColor, DWORD dwTransparency, DWORD msFadeIn, DWORD msFadeOut, DWORD msHold);

EQLIB_API bool GetShortBuffID(PSPELLBUFF pBuff, DWORD &nID);
EQLIB_API bool GetBuffID(PSPELLBUFF pBuff, DWORD &nID);
EQLIB_API PCHAR GetLDoNTheme(DWORD LDTheme);
EQLIB_API bool BuffStackTest(PSPELL aSpell, PSPELL bSpell);
EQLIB_API DWORD GetItemTimer(PCONTENTS pItem);
EQLIB_API PCONTENTS GetItemContentsBySlotID(DWORD dwSlotID);
EQLIB_API PCONTENTS GetItemContentsByName(CHAR *ItemName);
EQLIB_API bool LoH_HT_Ready(); 

/* MQ2DATAVARS */
#ifndef ISXEQ
LEGACY_API PCHAR GetFuncParam(PCHAR szMacroLine, DWORD ParamNum, PCHAR szParamName, PCHAR szParamType);
LEGACY_API PDATAVAR FindMQ2DataVariable(PCHAR Name);
LEGACY_API BOOL AddMQ2DataVariable(PCHAR Name, PCHAR Index, MQ2Type *pType, PDATAVAR *ppHead, PCHAR Default);
LEGACY_API BOOL AddMQ2DataVariableFromData(PCHAR Name, PCHAR Index, MQ2Type *pType, PDATAVAR *ppHead, MQ2TYPEVAR Default); 
LEGACY_API PDATAVAR *FindVariableScope(PCHAR Name);
LEGACY_API BOOL DeleteMQ2DataVariable(PCHAR Name);
LEGACY_API VOID ClearMQ2DataVariables(PDATAVAR *ppHead);
LEGACY_API VOID NewDeclareVar(PSPAWNINFO pChar, PCHAR szLine);
LEGACY_API VOID NewDeleteVarCmd(PSPAWNINFO pChar, PCHAR szLine);
LEGACY_API VOID NewVarset(PSPAWNINFO pChar, PCHAR szLine);
LEGACY_API VOID NewVarcalc(PSPAWNINFO pChar, PCHAR szLine);
LEGACY_API VOID NewVardata(PSPAWNINFO pChar, PCHAR szLine);

LEGACY_API VOID DropTimers(VOID);
#endif

/*                 */

LEGACY_API BOOL LoadCfgFile(PCHAR Filename, BOOL Delayed=FromPlugin);
EQLIB_API PCHAR GetFriendlyNameForGroundItem(PGROUNDITEM pItem, PCHAR szName);
EQLIB_API VOID ClearSearchSpawn(PSEARCHSPAWN pSearchSpawn);
EQLIB_API PSPAWNINFO NthNearestSpawn(PSEARCHSPAWN pSearchSpawn, DWORD Nth, PSPAWNINFO pOrigin, BOOL IncludeOrigin=FALSE);
EQLIB_API DWORD CountMatchingSpawns(PSEARCHSPAWN pSearchSpawn, PSPAWNINFO pOrigin, BOOL IncludeOrigin=FALSE);
EQLIB_API PSPAWNINFO SearchThroughSpawns(PSEARCHSPAWN pSearchSpawn, PSPAWNINFO pChar);
EQLIB_API BOOL SpawnMatchesSearch(PSEARCHSPAWN pSearchSpawn, PSPAWNINFO pChar, PSPAWNINFO pSpawn);
LEGACY_API PCHAR ParseSearchSpawnArgs(PCHAR szArg, PCHAR szRest, PSEARCHSPAWN pSearchSpawn);
#ifndef ISXEQ
LEGACY_API VOID ParseSearchSpawn(PCHAR Buffer, PSEARCHSPAWN pSearchSpawn);
#else
LEGACY_API VOID ParseSearchSpawn(int BeginInclusive, int EndExclusive,char *argv[], SEARCHSPAWN &SearchSpawn);
#endif
EQLIB_API PCHAR FormatSearchSpawn(PCHAR Buffer, PSEARCHSPAWN pSearchSpawn);
EQLIB_API BOOL IsPCNear(PSPAWNINFO pSpawn, FLOAT Radius);
EQLIB_API BOOL IsInGroup(PSPAWNINFO pSpawn);
EQLIB_API BOOL IsInRaid(PSPAWNINFO pSpawn);
EQLIB_API BOOL IsAlert(PSPAWNINFO pChar, PSPAWNINFO pSpawn, DWORD List);
EQLIB_API PALERT GetAlert(DWORD Id);
EQLIB_API VOID AddNewAlertList(DWORD Id, PALERT pAlert);
EQLIB_API VOID FreeAlerts(DWORD List);
EQLIB_API BOOL GetClosestAlert(PSPAWNINFO pSpawn, DWORD List);
EQLIB_API BOOL IsAlert(PSPAWNINFO pChar, PSPAWNINFO pSpawn, DWORD List);
EQLIB_API BOOL CheckAlertForRecursion(PALERT pAlert,DWORD AlertNumber);
EQLIB_API VOID WriteFilterNames(VOID);
EQLIB_API VOID SetDisplaySWhoFilter(PBOOL bToggle, PCHAR szFilter, PCHAR szToggle);
EQLIB_API PCHAR GetModel(PSPAWNINFO pSpawn, DWORD Slot);
EQLIB_API PCHAR GetFriendlyNameForGroundItem(PGROUNDITEM pItem, PCHAR szName);
EQLIB_API VOID RewriteSubstitutions(VOID);
EQLIB_API VOID RewriteAliases(VOID);
EQLIB_API DWORD FindSpellListByName(PCHAR szName);
EQLIB_API FLOAT StateHeightMultiplier(DWORD StandState);
EQLIB_API DWORD WINAPI thrMsgBox(LPVOID lpParameter);
extern VOID SuperWhoDisplay(PSPAWNINFO pChar, PSEARCHSPAWN pSearchSpawn, DWORD Color);
LEGACY_API int pWHOSORTCompare(const void *A, const void *B);
extern VOID SuperWhoDisplay(PSPAWNINFO pSpawn, DWORD Color);

EQLIB_API VOID        OverwriteTable          (DWORD Address);
#ifndef ISXEQ
LEGACY_API DWORD      Include                 (PCHAR szFile);
#endif
EQLIB_API PCHAR       GetFullZone             (DWORD ZoneID);
EQLIB_API DWORD       GetZoneID               (PCHAR ZoneShortName);
EQLIB_API PCHAR       GetShortZone            (DWORD ZoneID);
EQLIB_API PCHAR       CleanupName             (PCHAR szName, BOOL Article = TRUE, BOOL ForWhoList = TRUE);
//EQLIB_API VOID        SwapSWho                (PSWHOSORT pSWho1, PSWHOSORT pSWho2);
//EQLIB_API VOID        SortSWho                (PSWHOSORT pSWhoSort, DWORD SpawnCount, DWORD SortBy = 0);
//EQLIB_API VOID        SuperWhoFindPets        (PSPAWNINFO pChar, WORD SpawnID);
//EQLIB_API VOID        SuperWhoDisplay         (PSPAWNINFO pChar, PSEARCHSPAWN pFilter, PSPAWNINFO psTarget, WORD Padding = 0, DWORD Color = 0);
EQLIB_API FLOAT       DistanceToSpawn3D       (PSPAWNINFO pChar, PSPAWNINFO pSpawn);
EQLIB_API FLOAT       EstimatedDistanceToSpawn(PSPAWNINFO pChar, PSPAWNINFO pSpawn);
EQLIB_API VOID        CmdFov                  (PSPAWNINFO pChar, PCHAR szLine);
#ifndef ISXEQ
LEGACY_API PMACROBLOCK AddMacroLine           (PCHAR szLine);
#endif
EQLIB_API VOID        FreeAlertList           (PALERTLIST pAlertList);
EQLIB_API DWORD WINAPI InsertCommands         (LPVOID lpParameter);
EQLIB_API VOID        UpdateMonitoredSpawns   (VOID);
EQLIB_API PCHAR       GetModel                (PSPAWNINFO pSpawn, DWORD Slot);
//EQLIB_API PSPAWNINFO  GetPet                  (DWORD OwnerID);
//EQLIB_API BOOL        IfCompare               (PCHAR szCond);
EQLIB_API bool        PlayerHasAAAbility      (DWORD AAIndex);
EQLIB_API PCHAR       GetAANameByIndex        (DWORD AAIndex);
EQLIB_API DWORD       GetAAIndexByName        (PCHAR AAName);
EQLIB_API DWORD       GetAAIndexByID          (DWORD ID);
EQLIB_API DWORD       GetSkillIDFromName      (PCHAR name);
EQLIB_API char*		  GetSkillNameFromID(DWORD ID);
EQLIB_API bool        InHoverState();
EQLIB_API DWORD       GetGameState(VOID);
EQLIB_API float       GetMeleeRange(class EQPlayer *,class EQPlayer *);
EQLIB_API DWORD       GetSpellGemTimer(DWORD nGem);
EQLIB_API bool        HasExpansion(DWORD nExpansion);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Functions that were built into commands and people used DoCommand to execute                  //

EQLIB_API void AttackRanged(EQPlayer *pRangedTarget=pTarget);
EQLIB_API VOID UseAbility(char *sAbility);
//                                                                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////


LEGACY_API BOOL Calculate(PCHAR szFormula, DOUBLE& Dest);


#ifndef ISXEQ
#include "MQ2TopLevelObjects.h"
#include "MQ2Commands.h"
#else
#include "ISXEQ\ISXEQUtilities.h"
#include "ISXEQ\ISXEQCommands.h"
#define TOPLEVELOBJECT(name,funcname) extern bool funcname(int argc, char *argv[], LSTYPEVAR &Ret);
#include "ISXEQ\ISXEQTopLevelObjects.h"
#undef TOPLEVELOBJECT
#endif
// OTHER SHIT

#define LIGHT_COUNT     13
#define MAX_COMBINES    52
#define MAX_ITEMTYPES   56

#define GAMESTATE_CHARSELECT    1
#define GAMESTATE_CHARCREATE    2
#define GAMESTATE_SOMETHING     4
#define GAMESTATE_INGAME        5
#define GAMESTATE_PRECHARSELECT -1
#define GAMESTATE_LOGGINGIN     253
#define GAMESTATE_UNLOADING     255

#define XWM_LCLICK              1
#define XWM_LMOUSEUP            2
#define XWM_RCLICK              3
#define XWM_HITENTER            6
#define XWM_NEWVALUE            14
#define XWM_UNKNOWN             19
#define XWM_MOUSEOVER           21
#define XWM_HISTORY             22
#define XWM_LCLICKHOLD          23
#define XWM_LINK                27

#define XKF_SHIFT               1
#define XKF_CTRL                2
#define XKF_LALT                4
#define XKF_RALT                8

#define MAX_ITEM4xx             416

#define MAX_WEAPONS             0x000000ff

#ifndef ISXEQ
#define MQ2AUTH(z) EQLIB_API VOID z(DWORD x);
#endif

EQLIB_API VOID memchecks_tramp(PCHAR,DWORD,PVOID,DWORD,BOOL); 
EQLIB_API VOID memchecks(PCHAR,DWORD,PVOID,DWORD,BOOL);

enum { CLISTTARGET, CLISTMAXDMG, SINGLE };
enum { NOTOTAL, TOTALABOVE, TOTALSECOND, TOTALBOTTOM };

static int Coloring[] = {
   {0},   //unk
   {13},   //war
   {4},   //clr
   {10},   //pal
   {11},   //rng
   {13},   //shd
   {5},   //dru
   {8},   //mnk
   {2},   //brd
   {12},   //rog
   {14},   //shm
   {9},   //nec
   {14},   //wiz
   {7},   //mag
   {6},   //enc
   {3},   //bst
   {15},   //ber
};

struct EntDamage {
	int Total;
	time_t First;
	time_t Last;
	int AddTime;
};

void         DestroyDPSWindow();
void         CreateDPSWindow();
void         CreateDPSWindow();
void         DestroyDPSWindow();
template <unsigned int _EntSize, unsigned int _MobSize>bool SplitStringOtherHitOther(PCHAR Line, CHAR(&EntName)[_EntSize], CHAR(&MobName)[_MobSize], int *Damage);
template <unsigned int _EntSize, unsigned int _MobSize>bool SplitStringDOT(PCHAR Line, CHAR(&EntName)[_EntSize], CHAR(&MobName)[_MobSize], int *Damage);
template <unsigned int _EntSize, unsigned int _MobSize>bool SplitStringNonMelee(PCHAR Line, CHAR(&EntName)[_EntSize], CHAR(&MobName)[_MobSize], int *Damage);
void         HandleYouHitOther(PCHAR Line);
void         HandleOtherHitOther(PCHAR Line);
void         HandleNonMelee(PCHAR Line);
void         HandleDOT(PCHAR Line);
void		 ListSwitch(PSPAWNINFO Switcher);
void         TargetSwitch();
void         CheckActive();
void         DPSAdvCmd(PSPAWNINFO pChar, PCHAR szLine);
#ifdef DPSDEV
void         DPSTestCmd(PSPAWNINFO pChar, PCHAR szLine);
#endif

class DPSMob {
public:
	class DPSEntry {
	public:
		char Name[64];
		bool DoSort;
		bool Pets;
		bool CheckPetName;
		bool UsingPetName;
		int SpawnType;
		int Class;
		bool Mercenary;
		EntDamage Damage;
		DPSMob *Parent;
		PSPAWNINFO Spawn;
		DPSEntry *Master;

		DPSEntry();
		DPSEntry(char EntName[64], DPSMob *pParent);
		void      Init();
		void      AddDamage(int aDamage);
		int         GetDPS();
		void      Sort();
		void      GetSpawn();
		bool      CheckMaster();
	};

	char Name[64];
	char Tag[8];
	int SpawnType;
	PSPAWNINFO Spawn;
	bool Active;
	bool InActive;
	bool Dead;
	bool PetName;
	bool Mercenary;
	EntDamage Damage;
	DPSEntry *LastEntry;
	std::vector<DPSEntry*> EntList;

	DPSMob();
	DPSMob::DPSMob(PCHAR MobName, size_t MobLen);
	void      Init();
	void      AddDamage(int aDamage);
	void      GetSpawn();
	bool      IsPet();
	DPSEntry   *GetEntry(char EntName[64], bool Create = true);
};

inline bool ValidIngame(bool bCheckDead)
{
	// CTD prevention function
	return (GetGameState() == GAMESTATE_INGAME && GetCharInfo()->pSpawn && GetCharInfo2() && GetCharInfo() && GetCharInfo()->Stunned != 3);
}


class CDPSAdvWnd : public CCustomWnd {
public:
	CTabWnd *Tabs;
	CListWnd *LTopList;
	CComboWnd *CMobList;
	CCheckBoxWnd *CShowMeTop;
	CCheckBoxWnd *CShowMeMin;
	CTextEntryWnd *TShowMeMin;
	CCheckBoxWnd *CClearAfterCombatBox;
	CCheckBoxWnd *CLiveUpdate;
	int WndNotification(CXWnd *pWnd, unsigned int Message, void *unknown);
	void SaveSetting(PCHAR Key, PCHAR Value, ...);
};

typedef struct FormattedMessage_Struct
{
	DWORD unknown0;
	DWORD string_id;
	DWORD Filters;
	char Buffers[0];
} FormattedMessage_Struct, *pFormattedMessage_Struct;

typedef struct EdgeDamage_Struct
{
	/* 00 */	uint16_t	target;
	/* 02 */	uint16_t	source;
	/* 04 */	uint8_t	type; //slashing, etc. 231 (0xE7) for spells, skill
	/* 05 */	uint16_t	spellid;
	/* 07 */	int64_t damage;
				uint8_t hitType;
} EdgeDamage_Struct, *pEdgeDamage_Struct;

typedef struct Death_Struct
{
	/*000*/	DWORD	spawn_id;
	/*004*/ DWORD	killer_id;
	/*008*/	DWORD	corpseid;	// was corpseid
	/*012*/	DWORD	bindzoneid;
	/*016*/	DWORD	spell_id;
	/*020*/	DWORD	attack_skill;
	/*024*/	int32_t	damage;
	/*028*/	DWORD	unknown028;
} Death_Struct, *pDeath_Struct;

typedef struct DeleteSpawn_Struct
{
	/*000*/	DWORD	spawn_id;
	/*004*/	BYTE	bDisappear;
} DeleteSpawn_Struct, *pDeleteSpawn_Struct;

#define OP_CombatAction 0x1337
#define OP_Death 0x6517
#define OP_DeleteSpawn 0x7280

MaterialType GetMitigationTextureType(MaterialType material);
