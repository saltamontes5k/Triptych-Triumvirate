// MQ2FloatingDamage.cpp : Defines the entry point for the DLL application.
//

// PLUGIN_API is only to be used for callbacks.  All existing callbacks at this time
// are shown below. Remove the ones your plugin does not use.  Always use Initialize
// and Shutdown for setup and cleanup, do NOT do it in DllMain.



#include <Shlobj.h>

#include <d3d9.h>

#include "../MQ2Plugin.h"

#include <memory.h>

#include <atomic>
#include <thread>
#include <functional>
#include <vector>

#include <fenv.h>
#include <winternl.h>
#include <tchar.h>
#include <Psapi.h>
#include <d3dx9math.h>

#include "TickCount.h"
#include "Hooks.h"
#include "DamageHook.h"
#include "FloatingTextManager.h"
#include "RenderHooks.h"

#pragma comment(lib, "d3d9.lib")
#pragma comment(lib, "D3dx9.lib")

using namespace std;

PreSetup("MQ2FloatingDamage");



FloatingTextManager* g_pFtm = new FloatingTextManager();

// have detours been installed already?
bool g_hooksInstalled = false;

// the handle to the graphics dll
HMODULE g_dx9Module = 0;




// the global direct3d device that we are "borrowing"
IDirect3DDevice9* g_pDevice = nullptr;

// represents whether the device has been acquired and is good to use.
bool g_deviceAcquired = false;

HMODULE g_d3d9Module = 0;
using D3D9CREATEEXPROC = HRESULT(WINAPI*)(UINT, IDirect3D9Ex**);

// Address of the Reset() function
DWORD g_resetDeviceAddress = 0;





void WorldToScreen(D3DXVECTOR3 world, D3DXVECTOR3* screen)
{
	D3DXMATRIX g_view, g_projection, g_world;
	D3DVIEWPORT9 g_viewPort;

	IDirect3DDevice9_GetTransform(g_pDevice, D3DTS_VIEW, &g_view);
	IDirect3DDevice9_GetTransform(g_pDevice, D3DTS_PROJECTION, &g_projection);
	IDirect3DDevice9_GetTransform(g_pDevice, D3DTS_WORLD, &g_world);
	IDirect3DDevice9_GetViewport(g_pDevice, &g_viewPort);

	D3DXVec3Project(screen, &world, &g_viewPort, &g_projection, &g_view, &g_world);
}




DETOUR_TRAMPOLINE_EMPTY(void MyCEverQuest::ReportSuccessfulHit_Tramp(EQSuccessfulHit2* pHit, unsigned char bOutputText, int ActualHeal));

char path[MAX_PATH];
HMODULE hm = NULL;


// Called once, when the plugin is to initialize
PLUGIN_API VOID InitializePlugin(VOID)
{
    DebugSpewAlways("Initializing MQ2FloatingDamage");


	if (GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
		GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
		(LPCSTR)& InitializePlugin, &hm) == 0)
	{
		int ret = GetLastError();
		fprintf(stderr, "GetModuleHandle failed, error = %d\n", ret);
		// Return or however you want to handle an error.
	}
	if (GetModuleFileName(hm, path, sizeof(path)) == 0)
	{
		int ret = GetLastError();
		fprintf(stderr, "GetModuleFileName failed, error = %d\n", ret);
		// Return or however you want to handle an error.
	}

	char* p = strrchr(path, '\\');
	if (p) p[0] = 0;

	WriteChatf("%s", path);

	//dd and melee
	EzDetourwName(CEverQuest__ReportSuccessfulHit, &MyCEverQuest::ReportSuccessfulHit_Detour, &MyCEverQuest::ReportSuccessfulHit_Tramp, "RSH");


	if (!InstallD3D9Hooks())
	{
		WriteChatf("Failed to install hooks..");
		return;
	}

	g_dx9Module = LoadLibraryA("EQGraphicsDX9.dll");
	g_hooksInstalled = true;


    //Add commands, MQ2Data items, hooks, etc.
    //AddCommand("/mycommand",MyCommand);
    //AddXMLFile("MQUI_MyXMLFile.xml");
    //bmMyBenchmark=AddMQ2Benchmark("My Benchmark Name");
}

// Called once, when the plugin is to shutdown
PLUGIN_API VOID ShutdownPlugin(VOID)
{
    DebugSpewAlways("Shutting down MQ2FloatingDamage");

	RemoveDetour(CEverQuest__ReportSuccessfulHit);

	ShutdownHooks();

    //Remove commands, MQ2Data items, hooks, etc.
    //RemoveMQ2Benchmark(bmMyBenchmark);
    //RemoveCommand("/mycommand");
    //RemoveXMLFile("MQUI_MyXMLFile.xml");
}

// Called after entering a new zone
PLUGIN_API VOID OnZoned(VOID)
{
    DebugSpewAlways("MQ2FloatingDamage::OnZoned()");
}

// Called once directly before shutdown of the new ui system, and also
// every time the game calls CDisplay::CleanGameUI()
PLUGIN_API VOID OnCleanUI(VOID)
{
    DebugSpewAlways("MQ2FloatingDamage::OnCleanUI()");
    // destroy custom windows, etc
}

// Called once directly after the game ui is reloaded, after issuing /loadskin
PLUGIN_API VOID OnReloadUI(VOID)
{
    DebugSpewAlways("MQ2FloatingDamage::OnReloadUI()");
    // recreate custom windows, etc
}



// Called every frame that the "HUD" is drawn -- e.g. net status / packet loss bar
PLUGIN_API VOID OnDrawHUD(VOID)
{
    // DONT leave in this debugspew, even if you leave in all the others
    //DebugSpewAlways("MQ2FloatingDamage::OnDrawHUD()");

	
	
}

// Called once directly after initialization, and then every time the gamestate changes
PLUGIN_API VOID SetGameState(DWORD GameState)
{
    //if (GameState==GAMESTATE_INGAME)
    // create custom windows if theyre not set up, etc
}


// This is called every time MQ pulses
PLUGIN_API VOID OnPulse(VOID)
{
    // DONT leave in this debugspew, even if you leave in all the others
    //DebugSpewAlways("MQ2FloatingDamage::OnPulse()");
}

// This is called every time WriteChatColor is called by MQ2Main or any plugin,
// IGNORING FILTERS, IF YOU NEED THEM MAKE SURE TO IMPLEMENT THEM. IF YOU DONT
// CALL CEverQuest::dsp_chat MAKE SURE TO IMPLEMENT EVENTS HERE (for chat plugins)
PLUGIN_API DWORD OnWriteChatColor(PCHAR Line, DWORD Color, DWORD Filter)
{
    return 0;
}

// This is called every time EQ shows a line of chat with CEverQuest::dsp_chat,
// but after MQ filters and chat events are taken care of.
PLUGIN_API DWORD OnIncomingChat(PCHAR Line, DWORD Color)
{
    return 0;
}

// This is called each time a spawn is added to a zone (inserted into EQ's list of spawns),
// or for each existing spawn when a plugin first initializes
// NOTE: When you zone, these will come BEFORE OnZoned
PLUGIN_API VOID OnAddSpawn(PSPAWNINFO pNewSpawn)
{
}

// This is called each time a spawn is removed from a zone (removed from EQ's list of spawns).
// It is NOT called for each existing spawn when a plugin shuts down.
PLUGIN_API VOID OnRemoveSpawn(PSPAWNINFO pSpawn)
{
}

// This is called each time a ground item is added to a zone
// or for each existing ground item when a plugin first initializes
// NOTE: When you zone, these will come BEFORE OnZoned
PLUGIN_API VOID OnAddGroundItem(PGROUNDITEM pNewGroundItem)
{
}

// This is called each time a ground item is removed from a zone
// It is NOT called for each existing ground item when a plugin shuts down.
PLUGIN_API VOID OnRemoveGroundItem(PGROUNDITEM pGroundItem)
{
}
