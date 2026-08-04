#pragma once
#include <string>
#include <functional>
#include <vector>


struct HookInfo
{
	std::string name;
	DWORD address = 0;

	std::function<void(HookInfo&)> patch = nullptr;
};

extern bool InstallD3D9Hooks();
extern void RemoveDetours();
extern bool g_hooksInstalled;
extern void ShutdownHooks();
extern void FirePendingScribeIfReady();