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
