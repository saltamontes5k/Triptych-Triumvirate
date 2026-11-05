# RoF2 housing — Manage-window investigation handoff

Written 2026-11-01 at the end of the probe session; companion to
[rof2-housing-findings.md](rof2-housing-findings.md) §19 (which carries the decode
history). This file is the operator's manual: how to rebuild and run the diagnostic
probe, where the IDA work stands, what is proven, what is open, and what to try next.
Target reader: another agent session or a human continuing the hunt.

## 1. The bug, precisely

- Menu **Manage Real Estate** (and `show=1` lot-marker inspections) produce no visible
  Manage window. The popup titled `ctxrealestatemana...` that appears is **the help/tips
  window showing page 76** (`help/tips/ctxrealestatemanage.html`) — the Manage window's
  OnShow opens it every time (see §4). It is not the bug; it masks the bug.
- The real Manage window: exists at UI load, SIDL piece loaded, all widgets found, full
  geometry 605x465, styles applied, Show succeeds, visible flag stays 1 — and it
  **renders zero pixels**. A frame capture 3 s after a forced Show contains no window.
  This is the open bug: a draw-path failure inside the client for this window only.
- The reported "plot window auto-closes" (started 2026-11-01) is most likely the same
  phenomenon on Plot Search — nothing draws, so it looks closed. Unconfirmed.

## 2. Proven working — do NOT re-test these

Server side (all live since the 2026-11-01 15:06 restart, committed `2af892d6`):

- Zone-in burst order definitions → zone context (estate id = plot) → plot objects →
  regions → inspection seeds → world item → owned list → **access list (0x485d)**.
- 0x485d layout: `u32 estateID, 7x (u32 groupID, u32 capabilityMask), u32 memberCount,
  per member (LP32 name, u32 groupID)`; tiers 0-6 match REMW_Groups_Combobox (6=Owner);
  masks sent 0xFFFFFFFF as labelled emulator policy.
- Inspection (0x796c reply) estate type now 4=personal / 8=guild (was hardcoded 8).
- `#housing areas 3` keys its 200-unit player box under `PlotRegionId` (900000+door) —
  the only key the resolver accepts (`def[+28] == area_id`).

Client side (verified live by the dinput8 probe, plot 19, Judy):

- RealEstate state manager: +140=19, +144=5, +148=19, **+152=19** (the eqstr-727 /
  Manage-refresh gate), +156=-1, +160=-1; plot map (mgr+4/+8) holds key 19;
  area hash holds {19, 900019}; scanpos = (y, x, z) swapped, matches player.
- Manage window singleton exists (piece non-null, first widget non-null), full geo
  {0,25,605,465}, style132=0x00010A4C, active406=0 → forced Show sets it to 1, and a
  6 s 150 ms poll saw **no 1→0 transition** (the window never hides).
- Runtime base that session was 0x650000 (vtable off_9F8600 at runtime 0xC48600):
  **client ASLR/relocation is ON. Every probe read must be
  `static - 0x400000 + (DWORD)GetModuleHandle(NULL)`.**

## 3. Ruled out — do not re-litigate

- Client XML/skin: complete stock `EQUI_RealEstateManageWnd.xml` in the active `default`
  skin; piece name exact; every `<Pieces>`/`<Pages>` ref resolves; every element/attr
  token exists in the parser's SIDL pool; `<Header>Header_X</Header>` refs to
  FrameTemplates work (MerchantWnd/Bazaar/Train render); file is in `EQUI.xml` include
  line 192; no piece-name collisions; all 12 `A_*` button templates exist.
- Empty `UIErrors.txt` during the failure proves the ctor bail-out path did NOT run
  (that path always logs "ScreenPiece %s referenced but not found in XML." via
  `sub_860B10` = the UIErrors writer; file is recreated each client launch).
- Window creation/registration identical to working PlotSearch (same `new` + ctor +
  `push 0,0,0` + `sub_5B9E30` pattern in `sub_4973F0`).
- 0x49df area ingest fills the SCANNED active hash (dispatcher case 0x4CA7A5 passes
  mgr+0x00, verified in disasm) — ingest target is not the bug.
- 0x485d/0x2aa6 data delivery and the +152==estate refresh gate are satisfied live.
- Bare-Screen XML test (main Screen stripped to a single Label) still rendered nothing
  → the failure is the window's own draw path, not TabBox/children/XML.
  (Backup of the pristine client file: `C:\EQS\shroudref\EQUI_RealEstateManageWnd.xml.orig`;
  the game-dir file was restored from it.)

## 4. Key IDA addresses (static, eqgame.i64, imagebase 0x400000)

IDA database: `C:\EQS\shroudref\ida\eqgame.i64` (client `eqgame.exe`).
Relaunch: `Start-Process 'C:\Program Files\IDA Professional 9.3\ida.exe' '"C:\EQS\shroudref\ida\eqgame.i64"'`
— poll ~35-45 s. Helper: `python C:\EQS\shroudref\ida\ida_mcp.py call <tool> '<json>'`
(endpoint http://127.0.0.1:13337/mcp). Tools that work well: `server_health`, `find`
(`{"targets":["..."],"type":"string"}`), `find_bytes` (`{"patterns":[".. .. .."],"limit":N}` —
little-endian pointer search), `get_string` (`{"addrs":[...]}`), `xrefs_to`,
`decompile` (`{"addr"}`), `disasm` (`{"addr","max_instructions"}`), `lookup_funcs`
(`{"queries":["0x..."]}`). Gotchas: `find_regex` needs a warm strings cache (use `find`);
`get_bytes`/`get_int` param quirks (use find_bytes + disasm instead); shell cwd resets
between Bash calls — use absolute paths.

| Item | Static addr | Notes |
|---|---|---|
| ManageWnd ctor | `sub_746620` | bails to bare shell iff piece lookup (+0x1E0) null |
| CSidlScreenWnd chain | `sub_85F120` → `sub_85ED50` → `sub_85E850` → `sub_870120` | +1E0 zeroed, then piece lookup on global SIDL mgr `dword_15D3D08` |
| UIErrors writer | `sub_860B10` | fopen "UIErrors.txt" "at" |
| Manage singleton | `dword_D1FCBC` | new 0x348 @ 0x49910f in `sub_4973F0` (window set) |
| PlotSearch singleton | `dword_D1FCC4` | new 0x250 @ 0x499223, ctor `sub_74B470` |
| Packet dispatcher | `sub_5B2500` / `sub_4C3250` | 0x2aa6→`sub_741670`; 0x485d→`sub_747ED0`+`sub_7465C0/F0`; apply→`sub_5B0D00`→`sub_7410F0` |
| Manage refresh gate | `sub_7465C0` / `sub_7465F0` | refresh only when RealEstate[+152] == access estate id |
| RE state mgr getter | `sub_5B3540` → `dword_E64570` | +4/+8 plot map, +12 count (<=0 forces +152=-1, skips scan), +136 tick, +140 zone, +144 kind, +148 under-feet, +152 plot id, +156/+160 |
| 1 Hz updater | `sub_5B0A10` (called `sub_53CCA0` @ 0x53dcb4) | spatial scan + walk |
| Area mgr | `dword_DCEE30` | +0 active buckets, +4 modulus, +8 count, +14 override (never scanned); ingest `sub_4B2AB0`, case 0x4CA7A5; scanner `sub_4B2F40`/`sub_4B3040`; resolver `sub_4B30F0`; inside test `sub_505BA0`/`sub_505F60`; walk `sub_5B00E0`/`sub_4D6790` |
| Show generic | `sub_865290` (vtable+216) | Show wrapper static `0x7409D0`: a2==1 → show, else hide |
| Manage OnShow | vtable+152 = static `0x740960` | **opens tips page 76**: `sub_776EF0(dword_F758C4, 76, 0)` |
| Manage CanShow | vtable+220 = static `0x749E50` | NOT yet decompiled — next lead |
| Other captured slots | vt+224=`0x7409A0`, vt+288=`0x8660E0`, vt+292=`0x411FB0`, vt+352=`0x868440`, vt+148=`0x864120` | runtime−0x250000 (that session's base delta); re-derive if base differs |
| Tips open-by-id | `sub_776EF0` | page stack push `sub_776410`; activate-by-index `sub_775FD0`; notify `sub_776FF0` |
| Context string table | 0xB503xx, 88-byte stride | `ctxrealestatemanage.html` @ 0xB51DCC; per-page Tips flag `byte_B503FC[88*page]` |
| RE command toggle | `sub_4E4E60` ("manage"/"trophies"/"plot") | routed from `sub_4D7230` cases 429/430/431 |

Field map of a SIDL window used by the probe: +0x1E0 (dword 120) piece pointer,
+96/100/104/108 geo rect (this[24..27]), +132 style dword, +406 visible flag,
+468 second visible byte, vtable+216 Show, +220 CanShow, +152 OnShow.

## 5. The diagnostic probe — how to rebuild and run

State right now:

- `C:\EQS\Release-NMS-Client\eqgame_dll\MQ2Pulse.cpp` is **probe-free** (git-restored;
  verify with `git status` / grep HousingDiag = 0 hits).
- `C:\EQS\Release-NMS-Client\Release\dinput8.dll` (19:21 Nov 1) = clean build, copied to
  `C:\Games\EQTriune\dinput8.new.dll`. **The game dir's live `dinput8.dll` is still the
  last probe build — swap in the clean one** (old known-good kept as `dinput8.old.dll`,
  Oct 15).
- Untracked helper `C:\EQS\Release-NMS-Client\build_eqgame_dll.bat`:
  MSBuild at `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe`,
  args `/p:Configuration=Release /p:Platform=Win32
  /p:WindowsTargetPlatformVersion=10.0.19041.0 /p:PlatformToolset=v143`
  (project defaults v142 + SDK 10.0.18362.0 are NOT installed — keep the overrides).

To re-arm the probe:

1. Add the hook in `MQ2Pulse.cpp`'s main pulse body, right after the LoN line
   (search `NMSLoNPulse`):
   `{ extern void NMSHousingDiagPulse(); NMSHousingDiagPulse(); }`
2. Add the consolidated source below (one block, before the pulse function is fine).
3. Build: `cd /c/EQS/Release-NMS-Client && cmd //c build_eqgame_dll.bat`
4. Deploy: close the client, copy `Release\dinput8.dll` over
   `C:\Games\EQTriune\dinput8.dll` (keep `.old` as revert).
5. In game: log in, zone into `neighborhood`, stand on the owned lot. Within ~15 s of
   plot recognition the probe fires the one-shot forced Show (window pops by itself),
   the game **freezes ~6 s** (the poll sleeps on the render thread — expected), and:
   - `C:\Games\EQTriune\NMS_housingdiag.log` gets one 5 s-cadence state line,
     a `vtslots=` line, poll transitions, `poll done`.
   - `C:\Games\EQTriune\NMS_housingdiag.bmp` gets the frame captured 3 s after Show.
6. Remove the probe before any release: `git -C C:\EQS checkout --
   Release-NMS-Client/eqgame_dll/MQ2Pulse.cpp`, rebuild, redeploy. **Never ship a probe
   build.**

Consolidated probe source (final state of the session, re-add verbatim; all client
derefs inside `__try/__except`; reads are base-relative):

```c
static void NMS_HousingDiagLog(const char* text)
{
	static char s_path[MAX_PATH] = {0};
	if (s_path[0] == 0)
	{
		char exePath[MAX_PATH] = {0};
		GetModuleFileNameA(NULL, exePath, MAX_PATH);
		char* lastSlash = strrchr(exePath, '\\');
		if (lastSlash) *(lastSlash + 1) = '\0';
		sprintf_s(s_path, sizeof(s_path), "%sNMS_housingdiag.log", exePath);
	}
	FILE* f = nullptr;
	if (fopen_s(&f, s_path, "a") == 0 && f) { fputs(text, f); fclose(f); }
}

static void NMS_HousingDiagWalk(DWORD buckets, DWORD modulus, char* buf, size_t bufSize, int* n)
{
	if (buckets && modulus)
	{
		int shown = 0;
		for (DWORD b = 0; b < modulus && shown < 12; ++b)
		{
			DWORD node = *(DWORD*)(buckets + 4 * b);
			while (node && shown < 12)
			{
				*n += sprintf_s(buf + *n, bufSize - *n, "%s%u", shown ? "," : "", *(DWORD*)(node + 4));
				++shown; node = *(DWORD*)(node + 8);
			}
		}
		if (shown >= 12) *n += sprintf_s(buf + *n, bufSize - *n, ",...");
		if (!shown)      *n += sprintf_s(buf + *n, bufSize - *n, "empty");
	}
	else
		*n += sprintf_s(buf + *n, bufSize - *n, "unmapped");
}

void NMSHousingDiagPulse()
{
	static DWORD s_nextAt = 0;
	DWORD now = GetTickCount();
	if (s_nextAt && now < s_nextAt) return;
	s_nextAt = now + 5000;
	if (gGameState != GAMESTATE_INGAME || !pLocalPlayer) return;

	const DWORD base    = (DWORD)GetModuleHandle(NULL);
	const DWORD reAddr  = *(DWORD*)(0xE64570 - 0x400000 + base);  // RE state mgr (sub_5B3540)
	const DWORD amAddr  = *(DWORD*)(0xDCEE30 - 0x400000 + base);  // area mgr
	const DWORD pcAddr  = *(DWORD*)(0xDD2630 - 0x400000 + base);  // scanner player ctx
	PSPAWNINFO   pSpawn = (PSPAWNINFO)pLocalPlayer;

	char buf[1600]; int n = 0;
	n += sprintf_s(buf + n, sizeof(buf) - n,
		"[housingdiag] t=%u spawn=(%.1f,%.1f,%.1f)", now, pSpawn->X, pSpawn->Y, pSpawn->Z);
	if (!reAddr) { n += sprintf_s(buf + n, sizeof(buf) - n, " re-state=null\n"); NMS_HousingDiagLog(buf); return; }

	__try {
		n += sprintf_s(buf + n, sizeof(buf) - n, " re={+140:%d +144:%d +148:%d +152:%d +156:%d +160:%d plotmap=",
			*(int*)(reAddr + 0x8C), *(int*)(reAddr + 0x90), *(int*)(reAddr + 0x94),
			*(int*)(reAddr + 0x98), *(int*)(reAddr + 0x9C), *(int*)(reAddr + 0xA0));
		NMS_HousingDiagWalk(*(DWORD*)(reAddr + 0x04), *(DWORD*)(reAddr + 0x08), buf, sizeof(buf), &n);
		n += sprintf_s(buf + n, sizeof(buf) - n, "}");
	} __except (EXCEPTION_EXECUTE_HANDLER) { n += sprintf_s(buf + n, sizeof(buf) - n, " re=<fault>"); }

	if (amAddr) { __try {
		n += sprintf_s(buf + n, sizeof(buf) - n, " areas={mod=%u n=%u ids=",
			*(DWORD*)(amAddr + 0x04), *(DWORD*)(amAddr + 0x08));
		NMS_HousingDiagWalk(*(DWORD*)(amAddr + 0x00), *(DWORD*)(amAddr + 0x04), buf, sizeof(buf), &n);
		n += sprintf_s(buf + n, sizeof(buf) - n, "}");
	} __except (EXCEPTION_EXECUTE_HANDLER) { n += sprintf_s(buf + n, sizeof(buf) - n, " areas=<fault>"); } }
	else n += sprintf_s(buf + n, sizeof(buf) - n, " areas=null");

	if (pcAddr) { __try {
		const float* sp = (const float*)(pcAddr + 0x284);
		n += sprintf_s(buf + n, sizeof(buf) - n, " scanpos=(%.1f,%.1f,%.1f)", sp[0], sp[1], sp[2]);
	} __except (EXCEPTION_EXECUTE_HANDLER) { n += sprintf_s(buf + n, sizeof(buf) - n, " scanpos=<fault>"); } }

	const DWORD manageWnd = *(DWORD*)(0xD1FCBC - 0x400000 + base);
	const DWORD plotWnd   = *(DWORD*)(0xD1FCC4 - 0x400000 + base);
	if (manageWnd) { __try {
		const DWORD vt = *(DWORD*)(manageWnd);
		n += sprintf_s(buf + n, sizeof(buf) - n, " mngwnd=%08X piece=%08X subwnd=%08X active406=%d vt54=%08X",
			manageWnd, *(DWORD*)(manageWnd + 0x1E0), *(DWORD*)(manageWnd + 0x258),
			*(BYTE*)(manageWnd + 406), (vt ? *(DWORD*)(vt + 216) : 0));
		n += sprintf_s(buf + n, sizeof(buf) - n, " geo={%d,%d,%d,%d} style132=%08X",
			*(int*)(manageWnd + 96), *(int*)(manageWnd + 100), *(int*)(manageWnd + 104),
			*(int*)(manageWnd + 108), *(DWORD*)(manageWnd + 132));
		const DWORD piece = *(DWORD*)(manageWnd + 0x1E0);
		if (piece)
			n += sprintf_s(buf + n, sizeof(buf) - n, " piece{p88=%08X p92=%08X p96=%d p100=%d p104=%d p108=%d p128=%08X p140=%08X}",
				*(DWORD*)(piece + 88), *(DWORD*)(piece + 92), *(int*)(piece + 96), *(int*)(piece + 100),
				*(int*)(piece + 104), *(int*)(piece + 108), *(DWORD*)(piece + 128), *(DWORD*)(piece + 140));
	} __except (EXCEPTION_EXECUTE_HANDLER) { n += sprintf_s(buf + n, sizeof(buf) - n, " mngwnd=<fault>"); } }
	else n += sprintf_s(buf + n, sizeof(buf) - n, " mngwnd=null");

	const DWORD tipsWnd = *(DWORD*)(0xD1FC8C - 0x400000 + base);   // tips/context window
	if (tipsWnd) { __try {
		n += sprintf_s(buf + n, sizeof(buf) - n, " tips{vis406=%d geo={%d,%d,%d,%d}}",
			*(BYTE*)(tipsWnd + 406), *(int*)(tipsWnd + 96), *(int*)(tipsWnd + 100),
			*(int*)(tipsWnd + 104), *(int*)(tipsWnd + 108));
	} __except (EXCEPTION_EXECUTE_HANDLER) { n += sprintf_s(buf + n, sizeof(buf) - n, " tips=<fault>"); } }

	if (plotWnd) { __try {
		const DWORD vt = *(DWORD*)(plotWnd);
		n += sprintf_s(buf + n, sizeof(buf) - n, " plotwnd{piece=%08X active406=%d vt54=%08X}",
			*(DWORD*)(plotWnd + 0x1E0), *(BYTE*)(plotWnd + 406), (vt ? *(DWORD*)(vt + 216) : 0));
	} __except (EXCEPTION_EXECUTE_HANDLER) { n += sprintf_s(buf + n, sizeof(buf) - n, " plotwnd=<fault>"); } }

	// One-shot forced Show + vtable dump + 6 s visibility poll.
	static bool  s_forcedShowDone = false;
	static DWORD s_captureAt      = 0;
	static int   s_captureTries   = 0;
	if (manageWnd && !s_forcedShowDone)
	{
		const int plotId = *(int*)(reAddr + 0x98);
		if (plotId != -1)
		{
			s_forcedShowDone = true;
			__try {
				const DWORD vt     = *(DWORD*)(manageWnd);
				const DWORD showFn = vt ? *(DWORD*)(vt + 216) : 0;
				BYTE before = *(BYTE*)(manageWnd + 406);
				n += sprintf_s(buf + n, sizeof(buf) - n, " FORCESHOW{vt=%08X slot216=%08X before406=%d ",
					vt, showFn, before);
				if (showFn)
				{
					char pbuf[512]; int pn = 0;
					pn += sprintf_s(pbuf + pn, sizeof(pbuf) - pn,
						"[housingdiag] vtslots={148:%08X 152:%08X 216:%08X 220:%08X 224:%08X 288:%08X 292:%08X 352:%08X}\n",
						*(DWORD*)(vt + 148), *(DWORD*)(vt + 152), *(DWORD*)(vt + 216), *(DWORD*)(vt + 220),
						*(DWORD*)(vt + 224), *(DWORD*)(vt + 288), *(DWORD*)(vt + 292), *(DWORD*)(vt + 352));
					NMS_HousingDiagLog(pbuf);

					typedef int(__thiscall* Show_t)(DWORD, int, int, int);
					Show_t show = (Show_t)showFn;
					show(manageWnd, 1, 1, 1);
					n += sprintf_s(buf + n, sizeof(buf) - n, "after406=%d}", *(BYTE*)(manageWnd + 406));
					s_captureAt = GetTickCount() + 3000;

					BYTE last406 = 1;
					for (int poll = 0; poll < 40; ++poll)   // ~6 s; freezes render thread
					{
						Sleep(150);
						const BYTE cur = *(BYTE*)(manageWnd + 406);
						if (cur != last406)
						{
							pn = 0;
							pn += sprintf_s(pbuf + pn, sizeof(pbuf) - pn, "[housingdiag] poll 406:%d->%d\n", last406, cur);
							NMS_HousingDiagLog(pbuf);
							last406 = cur;
						}
					}
					NMS_HousingDiagLog("[housingdiag] poll done\n");
				}
				else n += sprintf_s(buf + n, sizeof(buf) - n, "nofn}");
			} __except (EXCEPTION_EXECUTE_HANDLER) {
				s_forcedShowDone = true;
				n += sprintf_s(buf + n, sizeof(buf) - n, " FORCESHOW=<fault>");
			}
		}
	}

	// Frame capture 3 s after the forced Show -> NMS_housingdiag.bmp.
	if (s_captureAt && now >= s_captureAt && s_captureTries < 5)
	{
		s_captureAt = 0; ++s_captureTries;
		do {
			if (!g_pDevice) break;                       // extern IDirect3DDevice9* g_pDevice;
			IDirect3DSurface9* rt = nullptr;
			if (FAILED(g_pDevice->GetRenderTarget(0, &rt)) || !rt) break;
			D3DSURFACE_DESC desc = {}; rt->GetDesc(&desc);
			IDirect3DSurface9* off = nullptr;
			if (SUCCEEDED(g_pDevice->CreateOffscreenPlainSurface(desc.Width, desc.Height, desc.Format,
					D3DPOOL_SYSTEMMEM, &off, nullptr)) && off)
			{
				if (SUCCEEDED(g_pDevice->GetRenderTargetData(rt, off)))
				{
					D3DLOCKED_RECT lr = {};
					if (SUCCEEDED(off->LockRect(&lr, nullptr, D3DLOCK_READONLY)))
					{
						if (desc.Format == D3DFMT_A8R8G8B8 || desc.Format == D3DFMT_X8R8G8B8)
						{
							static char s_bmpPath[MAX_PATH] = {0};
							if (s_bmpPath[0] == 0)
							{
								char exePath[MAX_PATH] = {0};
								GetModuleFileNameA(NULL, exePath, MAX_PATH);
								char* lastSlash = strrchr(exePath, '\\');
								if (lastSlash) *(lastSlash + 1) = '\0';
								sprintf_s(s_bmpPath, sizeof(s_bmpPath), "%sNMS_housingdiag.bmp", exePath);
							}
							const DWORD rowBytes = desc.Width * 4, imageBytes = rowBytes * desc.Height;
							BITMAPFILEHEADER fh = {}; fh.bfType = 0x4D42;
							fh.bfSize = sizeof(fh) + sizeof(BITMAPINFOHEADER) + imageBytes;
							fh.bfOffBits = sizeof(fh) + sizeof(BITMAPINFOHEADER);
							BITMAPINFOHEADER ih = {}; ih.biSize = sizeof(ih);
							ih.biWidth = (LONG)desc.Width; ih.biHeight = (LONG)desc.Height;
							ih.biPlanes = 1; ih.biBitCount = 32; ih.biCompression = BI_RGB;
							ih.biSizeImage = imageBytes;
							FILE* bf = nullptr;
							if (fopen_s(&bf, s_bmpPath, "wb") == 0 && bf)
							{
								fwrite(&fh, sizeof(fh), 1, bf);
								fwrite(&ih, sizeof(ih), 1, bf);
								for (LONG y = (LONG)desc.Height - 1; y >= 0; --y)   // top-down lock -> bottom-up BMP
									fwrite((const BYTE*)lr.pBits + y * lr.Pitch, rowBytes, 1, bf);
								fclose(bf);
							}
						}
						off->UnlockRect();
					}
				}
				off->Release();
			}
			rt->Release();
		} while (0);
	}

	n += sprintf_s(buf + n, sizeof(buf) - n, "\n");
	NMS_HousingDiagLog(buf);
}
```

Reading the output: healthy recognition looks like
`re={+140:19 +144:5 +148:19 +152:19 ... plotmap=19} areas={... ids=19,900019}
mngwnd=... piece=... geo={0,25,605,465} ... plotwnd{...}`. If `+152:-1` or
`plotmap=empty` the recognition chain broke; if FORCESHOW is missing, +152 never
resolved that session.

## 6. Open leads, in order

1. **Kill the tips popup first** — it masks the real window. The per-page flag is
   `byte_B503FC[88*76]`; it is seeded from the UI ini "Tips" section (see
   `sub_5435E0(value, "Tips", name)` calls around `sub_776FF0` / `sub_775FD0`). Find the
   key in `C:\Games\EQTriune\UI_Judy_Triptych.ini` / `defaults.ini` ("Tips" section,
   the manage-page entry — likely `ShowTips` style flags per context id), set it off,
   restart the client, press Manage, and look at what remains.
2. **Dump the window while YOU open it** — the probe should also log plotwnd/mngwnd
   state in the same pulse where the user has just clicked Manage/Plot Search: every
   dump so far read `active406=0` even while the user had Plot Search on screen, which
   is unexplained. Read both +406 and +468, plus the piece rect, in that moment.
3. **Decompile the draw-path gates**: `0x749E50` (CanShow, vt+220), `0x7409A0` (vt+224),
   `0x868440` (vt+352), `0x8660E0` (vt+288). Look for a context/page-state or rect test
   that our flow never satisfies.
4. **Detour the per-frame draw** (vtable slot the Show tail calls via +152, or the UI
   window-list draw loop) with a counter: does the Manage window's draw get CALLED and
   bail, or never get called? That splits "gate refuses" from "not in the draw list".
5. Compare against a known-good heavy SIDL window (MerchantWnd) under the same probe to
   find the differing field.
6. Server-side candidates only AFTER the draw gate is understood: a real escrow
   snapshot (0x2aa6 is parse-and-discard `sub_741670` today) and real 0x1cef entries —
   both documented as unimplemented by design (a guessed 0x1cef entry can crash).

## 7. Artifacts and state

- Commit `2af892d6` (content/xeru-custom): nms_housing.cpp fixes + findings §19.
- Server: running the new binary since 2026-11-01 15:06 (all fixes live).
- `C:\EQS\shroudref\EQUI_RealEstateManageWnd.xml.orig` — pristine client XML backup
  (game-dir copy already restored).
- `C:\Games\EQTriune\NMS_housingdiag.log` / `.bmp` — evidence from the last probe round.
- `C:\Games\EQTriune\dinput8.old.dll` — Oct 15 known-good; `dinput8.new.dll` — clean
  probeless build waiting to be swapped in; live `dinput8.dll` — last probe build.
- This file is uncommitted; commit or move it as desired. It contains nothing that
  violates the push-hygiene rules.

## 8. Draw-path map — 2026-11-04 static pass

Added after a full static sweep of the paint path plus one live field capture. 8.1 and 8.6 exist to
stop the next session re-running dead ends; 8.3 and 8.5 are the new instrument and the new procedure.

### 8.1 Correction to the §4 table, and a dead end

- The Manage CanShow slot is `vt+220 = static **0x747E50**`, not 0x749E50 (digits transposed).
  0x749E50 lands mid-body in `sub_749CD0` (a tab-page refresh routine), which is why "not yet
  decompiled" produced nonsense. The probe's runtime read `slot220=0x00997E50` was correct all
  along; only the transcription was wrong.
- **CanShow is satisfied and is a dead end.** `sub_747E50` reads `RE[+152]`, hashes it against the
  plot map at RE+4/+8, requires the hit's first dword to be non-null, then calls `loc_747740` and
  returns 1. On failure it emits eqstr 727 via `sub_51F1A0` and returns 0. Because OnShow
  (`sub_740960`) only runs *after* +406 is set, and OnShow is what raises the tips popup the operator
  sees, CanShow demonstrably returned 1 in the failing flow.

### 8.2 The paint chain (static, imagebase 0x400000)

- Frame driver `sub_53CCA0` calls `sub_877600` with `ecx = dword_15D3D00` (the UI manager). The call
  is guarded by `dword_D1F3B8 != 3` and one local flag.
- `sub_877600` walks the manager draw array at manager+0x14 (count) / manager+0x18 (`CXWnd*` array):
  - `Id(wnd)` is just `*(wnd+372)` — the **owner**. owner == 0 → eligible to draw; owner != 0 →
    eligible only if `*(wnd+0x120) >= 1000`, otherwise skipped for that frame.
  - then requires `wnd[406] != 0` **and** `(*(mgr->vt+0xC))(mgr, wnd)`.
  - then calls `sub_868A10(wnd)`. The whole loop is skipped when `*(mgr+0x104) != 0`.
- `sub_868A10(wnd)` — per-window draw, in order:
  1. `if (!wnd[406]) return 0;` — visible
  2. `if (wnd[34]) sub_8680B0(wnd, &clip);` — **recompute clip into wnd+136..+148**
  3. `if (wnd[431]) return 0;` — **clip is empty ⇒ nothing draws at all**
  4. `wnd[432]` (draw mode): == 1 → require `(vt+32)(wnd) >= 0`; == 2 → extra rect path; else straight on
  5. `vt+8 >= 0 && vt+12 >= 0`, a 0x200 ms hover/blink test, `sub_868BA0(wnd) >= 0`
  6. `(vt+16)(wnd)` — this is `DrawSelf`, and it is the `0x4A1780` (`return 0`) **stub** in both the
     Manage and Neighborhood vtables. It is not the painter; a successful vt+16 is not evidence of pixels.
- `sub_8680B0` computes clip = window rect ∩ owner rect (`sub_66F620`), else the window rect via
  `sub_8638D0`; then **sets `wnd[431]` = (all four clip components == -1)** and clears `wnd[34]`.
- `sub_868BA0` = draw children: walks `wnd+0x10` (first child) then `child[2]` (next sibling) with the
  same gates per child, plus `if (wnd[462]) return 0;` and the alpha handling — style&0x800 →
  global alpha = `wnd[25]`; `wnd[413]` → global alpha = alpha * `wnd[376]` / 255.
- `vt+8 = sub_86A000` paints the window's own frame/fill from the style bits at +132.
- Manage vtable = `off_9F8600`; byte offsets: 8→0x86A000, 12→0x4A1780 stub, 16→0x4A1780 stub,
  152→0x740960 OnShow, 216→0x7409D0 Show, 220→0x747E50 CanShow, 224→0x7409A0 (returns 1),
  288→0x8660E0 Move, 352→0x868440 invalidate/flush.
- **Manage vs Neighborhood vtable diff is only slots 1, 136, 140, 152, 196, 216, 220, 224, 360** — none
  of them a paint routine. The paint path is 100% shared, so the bug is *state at draw time*, not a
  wrong virtual.

### 8.3 New instrument: +34 and the clip rect are a built-in "was Draw ever called" probe

`sub_8680B0` clears +34 and writes +136..+148, so the object itself records whether the draw loop has
ever reached it:

| observation | meaning |
|---|---|
| `wnd[34] == 1` and clip == (0,0,0,0) | never drawn since the last invalidate |
| `wnd[34] == 0` and clip == window rect | Draw ran; clip == (0,25,605,465) for Manage |

Live baseline, 2026-11-04 14:30, client at char select with all four RealEstate windows created:

```
MANAGE vis=0 vis2=0 clipEMPTY=0 dirty34=1 alpha=255 fade=1 mode=1 noch=0 clip=(0,0,0,0) rect=(0,25,605,465) style=0x00010A4C owner=0
NEIGHB vis=0 vis2=0 clipEMPTY=0 dirty34=1 alpha=255 fade=1 mode=1 noch=0 clip=(0,0,0,0) rect=(246,369,926,725) style=0x00010A4C owner=0
PLOT   same shape, rect=(551,352,1051,587)
ITEMS  same shape, rect=(400,400,862,920)
```

At rest the four windows are **identical on every draw-relevant field**. The pre-show state does not
discriminate; whatever breaks only appears once the window is shown. That kills "alpha is 0",
"owner clips it away" and "wrong draw virtual" as at-rest explanations.

### 8.4 Who shows and who hides `dword_D1FCBC`

Show (`vt+216 = 0x7409D0` → `0x865290`):

- `sub_4E4E60` — the `manage` / `trophies` / `plot` / `items` command; `Show(visible == 0, 1, 1)`, a toggle.
- `sub_537D30` — auto-show when a nearby spawn has `[spawn+38] == 0xA1` and the player is inside
  `[playerCtx+79*4 float] + 20.0`, only when `!wnd[406]`. This is the expected "walk onto the lot" popup.
- `sub_5B2500` — packet opcode **17854 (0x45BE)** with a non-zero payload byte → `Show(1,1,1)`.

Hide:

- `sub_4E4E60` again (the toggle).
- **`sub_627760`** (vtable `0x9E2570`, a companion window's show/hide handler). On show it records
  `wnd[557] = Manage[406]`; on hide it runs `if (!wnd[557] && dword_D1FCBC) Show(Manage, 0, 1, 1)` —
  **it force-hides Manage when it closes, unless Manage was already up when it opened.** Besides the
  toggle this is the only explicit "hide Manage" site in the binary, and it can close the window a few
  seconds after it opens. Identifying the owner of vtable `0x9E2570` is the next static step.

### 8.5 Preferred procedure from here: an external sampler, not a DLL

`C:\EQS\tools\wndsampler.ps1` reads the live client through `ReadProcessMemory` only — **no rebuild,
no deploy, no client restart**, which removes the entire probe-build cycle from §5 from the loop. It
resolves the module base itself, re-resolves the window pointers every 60 ms and appends a line only
when state changes, so a one-frame visibility blip is caught.

Per window it reports `vis(+406) vis2(+468) clipEMPTY(+431) dirty34(+34) alpha(+376) fade(+413)
mode(+432) noch(+462) +288 clip rect rect style owner(+372) piece(+0x1E0) child(+0x10)`, plus
`drawlist=` — whether that window pointer is inside the manager array at `dword_15D3D00` +0x14/+0x18.

```
powershell -NoProfile -ExecutionPolicy Bypass -File C:\EQS\tools\wndsampler.ps1
# env WNDSCAN_SEC overrides the 2 h default; output goes to C:\EQS\tmp\wndscan.log
```

Run it, log in, stand on the owned lot, press Manage, then read the log:

- `drawlist=inlist@N/M` and dirty34 flipping 1→0 with a non-empty clip ⇒ **Draw is called**; the failure
  is inside the paint, so the next stop is `sub_868BA0` / `sub_86A000` with the clip values in hand.
- `drawlist=NOTINLIST` ⇒ the window never enters the draw array — a registration bug, not a paint bug.
  Then diff the `sub_5B9E30` registration against Neighborhood and find what fills manager+0x18.
- `vis` never observed at 1 ⇒ it is shown and re-hidden between frames; chase §8.4's hide path, the
  `sub_627760` companion first.

The old probe could not answer any of this: it sampled every 5 s from the render thread and had no
concept of the draw array, so a one-frame show/hide was invisible to it.

### 8.6 Ruled out by this pass

- CanShow (§8.1).
- Owner/parent clipping: `owner(+372) == 0` on all four windows, so the parent-clip branch of
  `sub_8680B0` is not taken at rest.
- Alpha 0 / faded out: `+376 == 255` and `+413 == 1` at rest, so the global alpha evaluates to 255.
- Wrong draw virtual: the paint vtables are identical between Manage and the working Neighborhood window.
- `vt+16` as the painter: it is the base `return 0` stub; do not detour it expecting pixels.
- The "second visible byte" (+468) is simply a copy of +406 — both are written by `0x865290`.

### 8.7 Live result, 2026-11-04 14:50-14:55 — the window is not invisible, it is closed

This section replaces the premise of §1. The Manage window renders correctly. What actually happens is
that the client hides it again within milliseconds of every show, so it is never visible at draw time.
Everything in §8.2-§8.6 about paint gates describes a path that is never reached for other reasons.

Evidence, in the order it was taken (all against the live client, read-only unless stated):

1. **State sampler** (`tools/wndsampler.ps1`, 60 ms, change-triggered): over ~5 minutes spanning the
   zone-in and the operator's click, **zero samples with `vis=1`**. Consistently
   `vis=0 dirty34=1 clip=(0,0,0,0) drawlist=inlist@776/1047` — in the draw array, never painted.
2. **CanShow evaluated live**: `RE+152=19`, table modulus 20011, `bucket[19]` head `0x30C03FA8`,
   node found at hop 0, `value=0x30E55400` non-null ⇒ `sub_747E50` returns 1. The show gate is open.
3. **Flash catcher** (`tools/flashcatcher.ps1`, max-rate poll of +406): exactly two transitions per
   click, each show/hide pair **1 ms apart** —
   `14:51:52.021 vis=1` → `14:51:52.022 vis=0`, and `14:52:06.154` → `14:52:06.155`.
   The window is shown and re-hidden inside a single millisecond.
4. **Forced visibility**: writing `+406=+468=1` from outside gets reverted in 0-104 ms, repeatedly
   (samples: 21, 3, 0, 4.97, 4, 2.06, 12, 5, 1, 42, 99, 104 ms) — a continuous or ~10 Hz re-hide,
   not a one-shot.
5. **The re-hide is Manage-specific.** The identical write to Neighborhood, Items and PlotSearch
   **sticks** (all three still visible after the 400 ms measurement window). Only `dword_D1FCBC` is
   killed.
6. **Rendering is fine.** Holding `vis=1` in a tight loop (26,776 writes over 2 s) produced
   `dirty34=0` and `clip=(0,25,605,465)` — i.e. `sub_8680B0` ran, the clip equals the full window
   rect, and the paint path executed normally. Nothing was clipped, faded or skipped.
7. **The hide does not go through `HideSelf`.** `0x740940` (`vt+360`, Manage-only) was patched live
   to `ret`; the re-hide continued unchanged (95, 3.97, 98 ms). The caller invokes Show(0)
   (`0x7409D0` → `0x865290`) directly. The byte was restored and verified afterwards.
8. **Only writer of +406 is `sub_865290`.** A full byte-pattern scan of image writes to `[reg+196h]`
   returns exactly 7 sites: `0x8653D5` (in `sub_865290`) and six in buff/spell-effect initialisers and
   item classes that only touch their own arrays. So the window cannot be "un-visible" except through
   a Show(0) call.
9. **Not the tips window.** `dword_F758C4` (`vt 0x9FCDD8`, rect `1560,358,1714,378` — matches the
   small ctx bar in the screenshot) had `vis=0` throughout the periods when Manage was being re-hidden.

Conclusion: the defect is a **Manage-only re-hide loop**, not a rendering defect. Two callers are known
to hide this window (`sub_4E4E60` toggle, `sub_627760` companion, and the latter's vtable
`0x9E2570` has no instance in session), but neither explains a continuous re-hide with no input, so a
third caller exists that reaches the window by a path that does not reference `dword_D1FCBC`.

Next steps, in order:

1. Identify the caller by hooking `0x7409D0` (or `0x865290`) in a probe build and logging the return
   address of every a2==0 call. This is the one measurement that ends the hunt; it needs a client
   restart, unlike everything in §8.5.
2. Cheap trigger tests before that: (a) rename `dinput8.dll` out of the way and try Manage — the
   addon hooks DirectInput, and two dispatches of one click would explain the 1 ms show/hide pair
   exactly, since `sub_4E4E60` is a toggle; (b) close every context/menu window first, then test,
   to see whether the re-hide needs menu state.
3. Only after the caller is known: decide whether the fix is client (XML/ini), addon (input), or
   server (a packet that drives the hide).

### 8.8 ROOT CAUSE — the Manage window is closed by its own per-frame update (2026-11-04 15:31)

Found with an in-process trace hook on `sub_865290` (the only writer of `+406`), capturing the
return address, the `a2` argument and `this`. Filtered to the Manage window, there is exactly one
hider:

```
MANAGE a2=0 caller static=0x00748212   -> inside sub_748180, Manage's vtable+196 virtual
```

`sub_748180` runs while the window is up and hides it when its estate check fails:

```c
if (*(BYTE*)(this + 406)) {                       // only while visible
  re  = sub_5B3540();                             // RealEstate state manager
  v3  = re[38];                                   // +0x98 = +152, the current plot id
  if (v3 == -1) { Show(this, 0, 1, 1); }          // hide
  ... plot map lookup for v3 ...
  if (!*v5 || !sub_5B41D0(*v5)) {                 // hide
      Show(this, 0, 1, 1);
      return sub_865F20(this);
  }
}
```

`sub_5B41D0` is the predicate `CanShow` (`sub_747E50`) does **not** check — that is the whole
discrepancy: `CanShow` only requires the plot-map entry to be non-null, so the window opens for one
frame, and then this updater closes it because the *estate record* fails validation:

```c
type = sub_7F4FA0(re + 0x74, estate[8]);          // definition-table lookup, 10 = not found
return (type == 4 && estate[11] && *(estate[11] + 8))   // personal plot: owner record present
    || (type == 8 && estate[9] != -1);                  // guild plot: guild id set
```

with `sub_7F6270(x) == (x == 4)`, `sub_7F6280(x) == (x == 8)`, and `sub_7F4FA0` walking the table
at `RE+0x74` (bucket at +4, modulus at +8, node key at +0x6C, type at +0x3C, default 10).

Consequences that match every observation:

- **Neighborhood**: plot id resolves and the entry exists (so `CanShow` passes), but the definition
  lookup does not yield 4 or 8, or the owner/guild field is unset, so the updater hides the window
  within a frame or two. Foreground showed exactly that: visible 1 ms, then `+406 = 0`, and forcing
  `+406 = 1` gets reverted in 0-104 ms.
- **Veeshan's Peak**: there is no housing state, the updater never runs, so the window stays open
  indefinitely. The operator confirmed this behaviour in play.
- Plot Search uses the same pattern, which is why it "auto-closes" only in a neighborhood.

Next step is a one-shot live evaluation, not more reverse engineering: `tools/predeval_manage_predicate.ps1`
reproduces the whole predicate from outside the process and prints the definition id, the resolved
type, `estate[+0x24]`, and the `estate[+0x2C]` owner pointer, so it names the exact field the server
must populate. Run it while standing on the owned lot.

The fix will be server-side in `nms_housing.cpp` — the 0x796c inspection reply and/or the state that
builds the client's estate record has to make `sub_5B41D0` true. Nothing in the client XML, the skin
or the draw path is implicated; §8.2-§8.7 stand as proof that rendering was never the problem.

#### 8.8.1 Confirmed against live data (2026-11-04 15:36)

`tools/predeval_manage_predicate.ps1` reproduced the predicate from outside the process while the
operator stood on the owned lot:

```
plot(RE+152)=19   estate=0x44D532C0
  estate+0x20 (definition id) = 519
  estate+0x24 (guild_id)      = -1
  estate+0x2C (owner record)  = 0
  definition 519 resolves to type = 8
  PREDICATE sub_5B41D0 = False
```

`+0x20/+0x24` are exactly `EstateSnapshot::definition_id` and `EstateSnapshot::guild_id`
(`nms_housing.cpp` 1702-1718, serialized at 1720-1747). The check fails on the type-8 branch because
`guild_id == 0xFFFFFFFF`.

#### 8.8.2 Why the data is inconsistent

`nms_housing.cpp` 447-453 defines the estate kinds, and 1894 registers **every** plot with
`kRealEstateKindPlot = 8`:

```
kRealEstateKindNeighborhood = 5
kRealEstateKindHouse        = 4
kRealEstateKindPlot         = 8
```

Meanwhile the single-plot inspection reply (line 888) sends `plot_type == 1 ? 8 : 4` — i.e. 4 for a
personal plot. The client validates the Manage gate against the **definition** type (8), not the
inspection type, and its type-8 branch demands a guild id. A personal plot has none, so the snapshot
writes `0xFFFFFFFF` (line 2009) and the window is closed every frame.

In Veeshan's Peak there is no housing state, so `sub_748180` never runs and the window stays open —
matching the operator's observation exactly.


#### 8.8.4 Applied 2026-11-04 15:47 (built, not yet live)

Option 2 shipped, plus the unrelated exterior-visibility fix the operator reported (another player
zoned in could not see the house):

- `SendRealEstateInspection` and `SendRealEstatePlotObjects`: `guild_id` is now **0** rather than
  `0xFFFFFFFF` when a plot has no guild, so the client's `sub_5B41D0` type-8 branch
  (`guild_id != -1`) passes. `0xFFFFFFFF` was our own convention; the client reads it as "absent".
- `SendRealEstateExteriors`: the ownership filter came off the query, so every client entering a
  neighbourhood receives every placed building, not only its own. Previously a house was visible
  only to its owner, which is why a summoned character arrived to an empty lot.

Option 1 (registering personal plots as `kRealEstateKindHouse`) was **not** applied: its branch in
`sub_5B41D0` requires `estate[+0x2C]` to be a non-null owner record with a non-zero field at +8, and
the live object had `+0x2C == 0`. Changing the type without seeding that record would only move the
failure, so the change was kept to the single dword that the client actually tests.

Build: `rebuild_server.bat` green, `Build/bin/Release/zone.exe` relinked 15:47; zones restarted 16:05
and the operator confirmed the Manage window now stays up and paints. **Verified live.**

Known cosmetic side effect: the estate now presents as a *guild* estate, because the client's model
is house(`kRealEstateKindHouse` 4) = personal-with-owner-record and plot(`kRealEstateKindPlot` 8) =
guild, and we deliberately satisfied the type-8 branch. Making the label read "personal" means
switching the definition to 4 *and* getting the client to fill `estate[+0x2C]` (an owner record with
a non-zero field at +8), which was null in every live sample. That is the next piece of work if the
label matters; it does not affect whether the window works.

#### 8.8.3 Fix options

1. **Make the definition type match the inspection type.** In the owned-plot loop (line 1894), set
   `plot.type = plot_type == 1 ? kRealEstateKindPlot : kRealEstateKindHouse`, so a personal plot is
   registered as 4. The type-4 branch then requires `estate[+0x2C]` (owner record) to be non-null
   with a non-zero field at +8 — currently 0, so this may need the owner/handle fields to seed it.
   Principled, but two variables move at once.
2. **Stop sending `0xFFFFFFFF` for "no guild".** Send 0 (`estate[+0x24] != -1`), at line 2009 and
   the matching field in the inspection reply (line 895). One dword, verifiable in seconds, but it
   tells the client the estate belongs to guild 0, which may surface in guild-oriented UI.

Fastest confirmation, no rebuild: patch the live estate record's `+0x24` to 0 with
`ReadProcessMemory`/`WriteProcessMemory` and force the window visible. If it then stays up and
paints, option 2 is proven and option 1 can be evaluated afterwards on its merits.




