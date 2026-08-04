#pragma once

inline unsigned __int64 MQGetTickCount64(void)
{
	typedef unsigned long long (WINAPI * fGetTickCount64)(VOID);
	static fGetTickCount64 pGetTickCount64 = 0;

	if (!pGetTickCount64)
	{
		if (HMODULE h = GetModuleHandleA("kernel32.dll")) {
			if (pGetTickCount64 = (fGetTickCount64)GetProcAddress(h, "GetTickCount64")) {
				// Set address to this function for use as a canary value, rather than storing another global
				pGetTickCount64 = reinterpret_cast<fGetTickCount64>(&MQGetTickCount64);
			}
		}
	}
	if (pGetTickCount64 && pGetTickCount64 != reinterpret_cast<fGetTickCount64>(&MQGetTickCount64))
	{
		return pGetTickCount64();
	}
	return ::GetTickCount(); // Fall back to GetTickCount which always exists
}

