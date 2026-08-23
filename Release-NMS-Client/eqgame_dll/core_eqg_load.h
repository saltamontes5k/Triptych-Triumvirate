#pragma once

#include "MQ2Main.h"
#include <fstream>
#include "core_log.h"

static std::map<std::string, std::string> configPaths;
static std::map<std::string, std::string> eqgOverrides;


std::string stripDirPrefix(std::string& path) {
	CHAR currentDir[MAX_PATH] = { 0 };
	GetCurrentDirectory(MAX_PATH, currentDir);
	std::string currentDirStr(currentDir);
	size_t pos = path.find(currentDirStr);
	if (pos != std::string::npos) {
		path.erase(pos, currentDirStr.length());
		// Remove leading backslash if present
		if (!path.empty() && path[0] == '\\') {
			path.erase(0, 1);
		}
	}
	pos = path.find(".\\");
	if (pos != std::string::npos) {
		path.erase(pos, 2);
	}
	std::transform(path.begin(), path.end(), path.begin(), ::tolower);
	return path;
}

bool pathLookup(std::string& path) {
	stripDirPrefix(path);

	auto it = eqgOverrides.find(path);
	if (it == eqgOverrides.end()) {
		return false;
	}

	auto it2 = configPaths.find(it->second);
	if (it2 == configPaths.end()) {
		return false;
	}

	std::string pathStr = it2->second + "\\" + path;
	if (!_FileExists(pathStr.c_str())) {
		return false;
	}
	path = pathStr;
	return true;
}

static uintptr_t __fastcall Graphics_FileLoad_Trampoline(uintptr_t This, uintptr_t Reg, const char* src);
static uintptr_t __fastcall Graphics_FileLoad(uintptr_t This, uintptr_t Reg, const char* filename) {

	std::string path(filename);
	if (pathLookup(path)) {
		SimpleLog("Routed FileLoad: %s", path.c_str());
		return Graphics_FileLoad_Trampoline(This, Reg, path.c_str());
	}
	// SimpleLog("Using original FileLoad: %s", filename);
	return Graphics_FileLoad_Trampoline(This, Reg, filename);	
}

DETOUR_TRAMPOLINE_EMPTY(static uintptr_t __fastcall Graphics_FileLoad_Trampoline(uintptr_t This, uintptr_t Reg, const char* src));

static uintptr_t __fastcall Graphics_EQGLoad_Trampoline(uintptr_t This, uintptr_t Reg, const char* src, int flag, uintptr_t ptr, const char** strlist);
static uintptr_t __fastcall Graphics_EQGLoad(uintptr_t This, uintptr_t Reg, const char* filename, int flag, uintptr_t ptr, const char** strlist) {	
	std::string path(filename);
	if (pathLookup(path)) {
		SimpleLog("Routed EQGLoad: %s", path.c_str());
		return Graphics_EQGLoad_Trampoline(This, Reg, path.c_str(), flag, ptr, strlist);
	}
	SimpleLog("Using original EQGLoad: %s", filename);
	return Graphics_EQGLoad_Trampoline(This, Reg, filename, flag, ptr, strlist);
}

DETOUR_TRAMPOLINE_EMPTY(static uintptr_t __fastcall Graphics_EQGLoad_Trampoline(uintptr_t This, uintptr_t Reg, const char* src, int flag, uintptr_t ptr, const char** strlist));

static uintptr_t __cdecl Graphics_FileOpen_Trampoline(const char* filename, int a2, int a3, int a4, uintptr_t a5, int a6);
static uintptr_t __cdecl Graphics_FileOpen(const char* filename, int a2, int a3, int a4, uintptr_t a5, int a6) {
	std::string path(filename);
	if (pathLookup(path)) {
		DebugSpew("Routed FileOpen: %s", path.c_str());
		return Graphics_FileOpen_Trampoline(path.c_str(), a2, a3, a4, a5, a6);
	}
	DebugSpew("Using original FileOpen: %s", filename);
	return Graphics_FileOpen_Trampoline(filename, a2, a3, a4, a5, a6);
}

DETOUR_TRAMPOLINE_EMPTY(static uintptr_t __cdecl Graphics_FileOpen_Trampoline(const char* filename, int a2, int a3, int a4, uintptr_t a5, int a6));


void InjectEQGOrderLoading() {
	SimpleLog("Injecting EQG Order Loading. eqGraphicsAddress: 0x%X, baseAddress: 0x%X", eqGraphicsAddress, baseAddress);
	EzDetour(eqGraphicsAddress + (DWORD)0xBE140, Graphics_FileLoad, Graphics_FileLoad_Trampoline);
	EzDetour(eqGraphicsAddress + (DWORD)0x66230, Graphics_EQGLoad, Graphics_EQGLoad_Trampoline);
	EzDetour(baseAddress + (DWORD)0x121BFC, Graphics_FileOpen, Graphics_FileOpen_Trampoline);

	auto dirsPath = "dirs.ini";
	if (!_FileExists(dirsPath)) {
		SimpleLog("dirs.ini not found");
		return;
	}
	std::ifstream file(dirsPath);
	if (!file.is_open()) {
		SimpleLog("dirs.ini failed to open");
		SimpleLog("Reason: %s (errno: %d)", std::strerror(errno), errno);
		return;
	}
	std::string line;
	while (std::getline(file, line)) {
		auto pos = line.find("=");
		if (pos == std::string::npos) {
			continue;
		}
		auto key = line.substr(0, pos);
		auto value = line.substr(pos + 1);
		if (key.empty() || value.empty()) {
			continue;
		}
		SimpleLog("Dirs: %s -> %s", key.c_str(), value.c_str());
		configPaths[key] = value;
	}

	dirsPath = "dirs_override.ini";
	if (!_FileExists(dirsPath)) {
		SimpleLog("dirs_override.ini not found");
	}
	else {
		file = std::ifstream(dirsPath);
		if (!file.is_open()) {
			SimpleLog("dirs_override.ini failed to open");
			SimpleLog("Reason: %s (errno: %d)", std::strerror(errno), errno);
		}
		else {
			while (std::getline(file, line)) {
				auto pos = line.find("=");
				if (pos == std::string::npos) {
					continue;
				}
				auto key = line.substr(0, pos);
				auto value = line.substr(pos + 1);
				if (key.empty() || value.empty()) {
					continue;
				}
				SimpleLog("Dirs Override: %s -> %s", key.c_str(), value.c_str());
				configPaths[key] = value;
			}
		}
	}


	auto it = configPaths.find("ls");
	if (it == configPaths.end()) {
		configPaths["ls"] = "ls";
	}

	auto eqgPath = "eqg.ini";
	if (_FileExists(eqgPath)) {
		file = std::ifstream(eqgPath);
		if (!file.is_open()) {
			SimpleLog("eqg.ini failed to open");
			SimpleLog("Reason: %s (errno: %d)", std::strerror(errno), errno);
			return;
		}
		else {
			while (std::getline(file, line)) {
				auto pos = line.find("=");
				if (pos == std::string::npos) {
					continue;
				}
				auto key = line.substr(0, pos);
				auto value = line.substr(pos + 1);
				if (key.empty() || value.empty()) {
					continue;
				}

				SimpleLog("EQG override %s -> %s", key.c_str(), value.c_str());
				eqgOverrides[key] = value;
			}
		}
	}

	eqgPath = "eqg_override.ini";
	if (!_FileExists(eqgPath)) {
		SimpleLog("eqg_override.ini not found");
	}
	else {
		file = std::ifstream(eqgPath);
		if (!file.is_open()) {
			SimpleLog("eqg_override.ini failed to open");
			SimpleLog("Reason: %s (errno: %d)", std::strerror(errno), errno);
		}
		else {
			while (std::getline(file, line)) {
				auto pos = line.find("=");
				if (pos == std::string::npos) {
					continue;
				}
				auto key = line.substr(0, pos);
				auto value = line.substr(pos + 1);
				if (key.empty() || value.empty()) {
					continue;
				}
				std::transform(key.begin(), key.end(), key.begin(), ::tolower);
				std::transform(value.begin(), value.end(), value.begin(), ::tolower);
				SimpleLog("EQG override %s -> %s", key.c_str(), value.c_str());
				eqgOverrides[key] = value;
			}
		}
	}

}
