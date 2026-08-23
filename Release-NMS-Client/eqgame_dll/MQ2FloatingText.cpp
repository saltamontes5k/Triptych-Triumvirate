// MQ2FloatingText.cpp


#include "MQ2Main.h" 

#include <memory.h>

#include <atomic>
#include <thread>
#include <functional>
#include <vector>

#include "TickCount.h"
#include "Hooks.h"
#include "FloatingTextManager.h"
#include "RenderHooks.h"

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



PLUGIN_API VOID OnFloatingTextManagerBeginZone()
{
	g_pFtm->Cleanup();
}

PLUGIN_API VOID OnFloatingTextManagerEndZone()
{
	g_pFtm->Initialize();
}



void WorldToScreen(D3DXVECTOR3 world, D3DXVECTOR3* screen)
{
	D3DXMATRIX g_view, g_projection, g_world;
	D3DVIEWPORT9 g_viewPort;

	g_pDevice->GetTransform(D3DTS_VIEW, &g_view);
	g_pDevice->GetTransform(D3DTS_PROJECTION, &g_projection);
	g_pDevice->GetTransform(D3DTS_WORLD, &g_world);
	g_pDevice->GetViewport(&g_viewPort);

	D3DXVec3Project(screen, &world, &g_viewPort, &g_projection, &g_view, &g_world);
}

char path[MAX_PATH];
HMODULE hm = NULL;

extern bool isFtmPluginInit;
// Called once, when the plugin is to initialize
PLUGIN_API VOID InitializeFloatingTextPlugin(VOID)
{
	if (isFtmPluginInit)
		return;

	auto hGfxDll = GetModuleHandle("EQGraphicsDX9.dll");

	auto hd3dDll = GetModuleHandle("d3d9.dll");

	if (!hGfxDll || !hd3dDll)
		return;

	if (!InstallD3D9Hooks())
	{
		return;
	}
	g_dx9Module = LoadLibraryA("EQGraphicsDX9.dll");
	g_hooksInstalled = true;
	isFtmPluginInit = true;


	//Add commands, MQ2Data items, hooks, etc.
	//AddCommand("/mycommand",MyCommand);
	//AddXMLFile("MQUI_MyXMLFile.xml");
	//bmMyBenchmark=AddMQ2Benchmark("My Benchmark Name");
}
