// nms_lon_link.cpp -- see nms_lon_link.h.
//
// Deliberately standalone: winsock2 must not meet the old <winsock.h> that MQ2Main.h pulls in.

#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <shellapi.h>

#include "nms_lon_link.h"

#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <string>

#pragma comment(lib, "ws2_32.lib")
// winmm (and the soundtrack) live in nms_lon_audio.cpp

namespace {

	const unsigned short kLocalPort = 15782;              // where the card game connects
	const DWORD          kIatLoadLibraryExA = 0x009C0274; // eqgame import slot (VA at image base 0x400000)
	const DWORD          kSessionBuffer     = 0x00F800D0; // eqgame "--sessionID=" buffer, 0x40 bytes
	const DWORD          kHostLiteralRva    = 0x0062B8D8; // in LegendsOfNorrath.dll
	const DWORD          kHostCallbacks     = 0x00F8034C; // eqgame: 8 callbacks handed to the card game
	const char           kSonyHost[]        = "lvsccg-02-01.station.sony.com";

	typedef HMODULE(WINAPI *LoadLibraryExA_t)(LPCSTR, HANDLE, DWORD);
	LoadLibraryExA_t g_realLoadLibraryExA = nullptr;
	DWORD            g_base = 0;

	CRITICAL_SECTION g_lock;
	bool             g_lockReady = false;
	std::string      g_token;
	std::string      g_host;
	unsigned short   g_port = 0;
	bool             g_relayStarted = false;

	// ---- the five navigator link buttons (research/lon_home_screen_and_links.md 1) ----
	// The server sends one ON/OFF bit per button (OP_NMSLoNSession offset 168, Custom:LoNLinkButtons)
	// and an address for the four that open a page (the v2 tail after byte 172). Default = all OFF:
	// the items are greyed (P8 below) and their Sony URLs are dropped, as before.
	enum : DWORD { kLinkHelp = 1, kLinkEula = 2, kLinkForums = 4, kLinkBoards = 8, kLinkWebsite = 16 };
	enum { kUrlHelp, kUrlForums, kUrlBoards, kUrlWebsite, kUrlCount };
	const DWORD    kLinkTailMagic = 0x55534D4E;   // 'NMSU' little-endian, = NMS_LONLINK_MAGIC (server)
	const unsigned kLinkUrlMax    = 255;          // = NMS_LONLINK_URL_MAX (server)
	volatile LONG  g_linkMask = 0;                // bits as sent; an old server sends 0 = all off
	std::string    g_linkUrl[kUrlCount];          // under g_lock; empty or a checked http(s) address

	bool StartsWithNoCase(const char *s, const char *prefix)
	{
		for (; *prefix; ++s, ++prefix) {
			char a = *s, b = *prefix;
			if (a >= 'A' && a <= 'Z') a = (char) (a - 'A' + 'a');
			if (a != b) return false;   // also stops at the end of s (a == 0, b != 0)
		}
		return true;
	}

	// Only an http(s) address with nothing ShellExecute could read as a path, a command or a switch:
	// printable ASCII, no spaces, no quotes. The text comes from the server.
	bool SafeWebUrl(const std::string &u)
	{
		if (u.size() < 9 || u.size() > kLinkUrlMax) return false;
		if (!StartsWithNoCase(u.c_str(), "http://") && !StartsWithNoCase(u.c_str(), "https://")) return false;
		for (unsigned char c : u) {
			if (c <= 0x20 || c >= 0x7F || c == '"' || c == '\'' || c == '<' || c == '>' || c == '\\' || c == '^' || c == '`') return false;
		}
		return true;
	}

	// Which button an incoming card-game URL belongs to, or -1 (lon_home_screen_and_links.md 1.6).
	int LinkOfUrl(const char *url)
	{
		if (!url) return -1;
		if (strstr(url, "legendsofnorrath") && strstr(url, "/d/ratings/")) return kUrlBoards;   // Leaderboards, View More
		if (strstr(url, "forums.station.sony.com/lon/")) return kUrlForums;
		if (strcmp(url, "http://legendsofnorrath.station.sony.com/") == 0 ||
		    strcmp(url, "http://legendsofnorrath.station.sony.com") == 0) return kUrlWebsite;
		if ((strstr(url, "station.sony.com") && strstr(url, "/help/") && strstr(url, ".vm")) ||
		    StartsWithNoCase(url, "help://")) return kUrlHelp;
		return -1;
	}

	DWORD LinkBit(int which)
	{
		switch (which) {
			case kUrlHelp:    return kLinkHelp;
			case kUrlForums:  return kLinkForums;
			case kUrlBoards:  return kLinkBoards;
			case kUrlWebsite: return kLinkWebsite;
			default:          return 0;
		}
	}

	// The configured address of a button that is ON, or "" (OFF, or no usable address).
	std::string LinkTarget(int which)
	{
		std::string out;
		if (which < 0 || which >= kUrlCount || !g_lockReady) return out;
		if (!((DWORD) g_linkMask & LinkBit(which))) return out;
		EnterCriticalSection(&g_lock);
		out = g_linkUrl[which];
		LeaveCriticalSection(&g_lock);
		return SafeWebUrl(out) ? out : std::string();
	}

	void __stdcall OpenUrlPost(const char *url, const char *post)
	{
		(void) post;
		// A Sony help / forum / ratings / website URL: the server's address when that button is ON.
		// Everything else is dropped: the store (goToStore, LoN RVA 0x3A7770, opens Sony's
		// csgPurchaseFlow / loginWithoutTicket pages -- hook your own shop here if you have one),
		// support FAQ, registration, links in the MOTD or news text.
		const std::string target = LinkTarget(LinkOfUrl(url));
		if (!target.empty()) {
			ShellExecuteA(nullptr, "open", target.c_str(), nullptr, nullptr, SW_SHOWNORMAL);
		}
	}

	void __stdcall OpenUrl(const char *url)
	{
		OpenUrlPost(url, nullptr);
	}

	// Slots 0 and 1 of eqgame's table; the card game copies the table in Initialize.
	void ReplaceUrlCallbacks()
	{
		if (!g_base) return;
		DWORD *table = (DWORD *) ((kHostCallbacks - 0x400000) + g_base);
		DWORD old = 0;
		if (VirtualProtect(table, 2 * sizeof(DWORD), PAGE_READWRITE, &old)) {
			table[0] = (DWORD) &OpenUrl;
			table[1] = (DWORD) &OpenUrlPost;
			VirtualProtect(table, 2 * sizeof(DWORD), old, &old);
		}
	}

	void Log(const char *fmt, const char *a = "", int b = 0)
	{
		char line[256];
		_snprintf_s(line, sizeof(line), _TRUNCATE, fmt, a, b);
		OutputDebugStringA(line);
	}

	// Point the card game's gateway at our local relay, before its Initialize copies it.
	void PatchGatewayHost(HMODULE lon)
	{
		char *lit = (char *) lon + kHostLiteralRva;
		if (memcmp(lit, kSonyHost, sizeof(kSonyHost)) != 0) {
			if (memcmp(lit, "127.0.0.1", 10) != 0) {
				Log("[NMS LoN] unknown LegendsOfNorrath.dll build -- gateway left alone\n");
			}
			return;
		}
		DWORD old = 0;
		if (VirtualProtect(lit, sizeof(kSonyHost), PAGE_READWRITE, &old)) {
			memset(lit, 0, sizeof(kSonyHost));
			memcpy(lit, "127.0.0.1", 10);
			VirtualProtect(lit, sizeof(kSonyHost), old, &old);
			Log("[NMS LoN] card game gateway -> 127.0.0.1\n");
		}
	}

	bool SameName(const char *a, const char *b)
	{
		for (; *a && *b; ++a, ++b) {
			char x = *a, y = *b;
			if (x >= 'A' && x <= 'Z') x = (char) (x - 'A' + 'a');
			if (y >= 'A' && y <= 'Z') y = (char) (y - 'A' + 'a');
			if (x != y) return false;
		}
		return *a == *b;
	}

	HMODULE WINAPI LoadLibraryExA_Wrap(LPCSTR name, HANDLE file, DWORD flags)
	{
		HMODULE h = g_realLoadLibraryExA(name, file, flags);
		if (h && name) {
			const char *slash = strrchr(name, '\\');
			const char *base  = slash ? slash + 1 : name;
			if (SameName(base, "LegendsOfNorrath.dll")) {
				PatchGatewayHost(h);
				ReplaceUrlCallbacks();
			}
		}
		return h;
	}

	void WriteSessionBuffer()
	{
		if (!g_base) {
			return;
		}
		char *buf = (char *) ((kSessionBuffer - 0x400000) + g_base);
		EnterCriticalSection(&g_lock);
		_snprintf_s(buf, 0x40, _TRUNCATE, "--sessionID=%s", g_token.c_str());
		LeaveCriticalSection(&g_lock);
	}

	// ---- relay: 127.0.0.1:15782 <-> host:port ---------------------------------
	// Frames of our own for world (the PvP result report) ride the card game's upstream socket. The
	// card game itself never sees them: they only go client -> world, and only between two of its
	// frames (each is a 4-byte big-endian length + body), never inside one.
	struct Pump {
		SOCKET      up = INVALID_SOCKET;
		std::string pending;   // our frames waiting for a frame boundary (under g_lock)
	};
	Pump *g_pumps[16] = {};   // every live relay connection (under g_lock)

	// LoN frame sniffing for the music layer: the client's single-player game reports
	// (AccountCommand_RecordSinglePlayerGame 0x1E7: AccountID, Activity 1 begin / 2 end,
	// GameType, Result 1 win / 2 lose, turns, game id, script) ride the client -> world
	// stream. Body = optional 12-byte preamble, then (classId, version) varints, then
	// fields. Varints: b0 carries extra-byte count and sign in the high nibble
	// (lon_service.cpp Reader::U).
	void LoNSniffFrame(const unsigned char *d, unsigned n)
	{
		struct V {
			const unsigned char *d; unsigned n, p; bool bad;
			unsigned U() {
				if (p >= n) { bad = true; return 0; }
				const unsigned char b0 = d[p++];
				const unsigned extra = (b0 >> 4) >> 1, neg = (b0 >> 4) & 1;
				unsigned mag = b0 & 0x0F, shift = 4;
				for (unsigned i = 0; i < extra && !bad; ++i) {
					if (p >= n) { bad = true; return 0; }
					mag |= (unsigned) d[p++] << shift;
					shift += 8;
					if (shift > 24) break;
				}
				return neg ? (unsigned) -(int) mag : mag;
			}
		} r = { d, n, 0, false };
		unsigned op = r.U();
		if (r.bad) return;
		if ((op == 0 || op >= 0x220) && n > 12) { r.p = 12; r.bad = false; op = r.U(); if (r.bad) return; }
		if (op != 0x1E7) return;
		// ReadHeader (lon_service.cpp): after the first (classId, version) pair the
		// client may repeat up to two more identical pairs for nested class levels --
		// missing them misreads the second pair as fields (activity read the leaf's
		// version and every report looked like a begin).
		unsigned ver = r.U();
		for (int i = 0; i < 2 && !r.bad; ++i) {
			const unsigned save = r.p;
			const unsigned a = r.U(), b = r.U();
			if (r.bad || a != op || b != ver) { r.p = save; r.bad = false; break; }
		}
		r.U();                    // AccountID
		const unsigned activity = r.U();
		r.U();                    // GameType
		const unsigned result = r.U();
		if (r.bad) return;
		if (activity == 1) {
			NMSLoN::GameMusicBegin();
		} else if (activity == 2) {
			NMSLoN::GameMusicEnd(result);
		}
	}

	// Where the card game's client -> world byte stream stands: inside a frame or between two.
	struct FrameTrack {
		unsigned char hdr[4] = {0, 0, 0, 0};
		int           have = 0;    // length bytes read so far
		unsigned long left = 0;    // body bytes still to come
		bool Boundary() const { return have == 0 && left == 0; }
		void Feed(const char *p, int n)
		{
			for (int i = 0; i < n;) {
				if (left) {
					const unsigned long take = (unsigned long) (n - i) < left ? (unsigned long) (n - i) : left;
					// capture the body (bounded) for the music sniffer
					if (!capFull) {
						const unsigned long room = (unsigned long) (sizeof(cap) - capLen);
						const unsigned long cp = take < room ? take : room;
						memcpy(cap + capLen, p + i, cp);
						capLen += (unsigned) cp;
						if (cp < take) capFull = true;
					}
					left -= take;
					i += (int) take;
					if (left == 0) {
						if (!capFull) LoNSniffFrame(cap, capLen);
						capLen = 0;
						capFull = false;
					}
					continue;
				}
				hdr[have++] = (unsigned char) p[i++];
				if (have == 4) {
					left = ((unsigned long) hdr[0] << 24) | ((unsigned long) hdr[1] << 16) | ((unsigned long) hdr[2] << 8) | hdr[3];
					have = 0;
					capLen = 0;
					capFull = false;
				}
			}
		}

		// bounded capture of the current frame body for LoNSniffFrame
		unsigned char cap[2048];
		unsigned       capLen = 0;
		bool           capFull = false;
	};

	bool SendAll(SOCKET s, const char *p, int n)
	{
		while (n > 0) {
			const int w = send(s, p, n, 0);
			if (w <= 0) return false;
			p += w;
			n -= w;
		}
		return true;
	}

	// Our queued frames, sent only at a frame boundary of the card game's own stream.
	bool FlushOurFrames(Pump &pump)
	{
		std::string out;
		EnterCriticalSection(&g_lock);
		out.swap(pump.pending);
		LeaveCriticalSection(&g_lock);
		return out.empty() || SendAll(pump.up, out.data(), (int) out.size());
	}

	// From the EQ main thread: one frame to every live relay connection (world reads it on the logged-in
	// one and ignores it on any other).
	void QueueToWorld(const std::string &frame)
	{
		if (!g_lockReady) return;
		EnterCriticalSection(&g_lock);
		for (Pump *p : g_pumps) {
			if (p && p->pending.size() + frame.size() <= 4096) p->pending += frame;
		}
		LeaveCriticalSection(&g_lock);
	}

	SOCKET ConnectUpstream()
	{
		std::string host;
		unsigned short port = 0;
		EnterCriticalSection(&g_lock);
		host = g_host;
		port = g_port;
		LeaveCriticalSection(&g_lock);
		if (host.empty() || !port) {
			return INVALID_SOCKET;
		}
		char portstr[16];
		_snprintf_s(portstr, sizeof(portstr), _TRUNCATE, "%u", (unsigned) port);
		addrinfo hints = {};
		hints.ai_family   = AF_INET;
		hints.ai_socktype = SOCK_STREAM;
		addrinfo *res = nullptr;
		if (getaddrinfo(host.c_str(), portstr, &hints, &res) != 0 || !res) {
			return INVALID_SOCKET;
		}
		SOCKET s = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
		if (s != INVALID_SOCKET && connect(s, res->ai_addr, (int) res->ai_addrlen) != 0) {
			closesocket(s);
			s = INVALID_SOCKET;
		}
		freeaddrinfo(res);
		return s;
	}

	DWORD WINAPI PumpThread(LPVOID arg)
	{
		SOCKET client = (SOCKET) (UINT_PTR) arg;
		SOCKET up = ConnectUpstream();
		if (up == INVALID_SOCKET) {
			Log("[NMS LoN] could not reach the card service\n");
			closesocket(client);
			return 0;
		}
		Pump pump;
		pump.up = up;
		EnterCriticalSection(&g_lock);
		for (Pump *&slot : g_pumps) {
			if (!slot) { slot = &pump; break; }   // full (16 connections): this one carries no reports
		}
		LeaveCriticalSection(&g_lock);
		FrameTrack track;   // the client -> world direction
		char buf[16384];
		for (;;) {
			fd_set rd;
			FD_ZERO(&rd);
			FD_SET(client, &rd);
			FD_SET(up, &rd);
			timeval tv = {1, 0};   // short: a queued report goes out within a second on a quiet link
			const int n = select(0, &rd, nullptr, nullptr, &tv);
			if (n < 0) {
				break;
			}
			if (n == 0) {
				if (track.Boundary() && !FlushOurFrames(pump)) break;
				continue;
			}
			SOCKET from = FD_ISSET(client, &rd) ? client : up;
			SOCKET to   = from == client ? up : client;
			const int got = recv(from, buf, sizeof(buf), 0);
			if (got <= 0) {
				break;
			}
			if (!SendAll(to, buf, got)) {
				break;
			}
			if (from == client) {
				track.Feed(buf, got);
				if (track.Boundary() && !FlushOurFrames(pump)) break;
			}
		}
		EnterCriticalSection(&g_lock);
		for (Pump *&slot : g_pumps) {
			if (slot == &pump) slot = nullptr;
		}
		LeaveCriticalSection(&g_lock);
		closesocket(up);
		closesocket(client);
		return 0;
	}

	DWORD WINAPI ListenThread(LPVOID)
	{
		SOCKET ls = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
		if (ls == INVALID_SOCKET) {
			return 0;
		}
		BOOL excl = TRUE;
		setsockopt(ls, SOL_SOCKET, SO_EXCLUSIVEADDRUSE, (const char *) &excl, sizeof(excl));
		sockaddr_in a = {};
		a.sin_family      = AF_INET;
		a.sin_port        = htons(kLocalPort);
		a.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
		if (bind(ls, (sockaddr *) &a, sizeof(a)) != 0 || listen(ls, 8) != 0) {
			Log("[NMS LoN] port 15782 is taken -- the card game will not reach our server\n");
			closesocket(ls);
			return 0;
		}
		for (;;) {
			SOCKET c = accept(ls, nullptr, nullptr);
			if (c == INVALID_SOCKET) {
				Sleep(100);
				continue;
			}
			HANDLE t = CreateThread(nullptr, 0, PumpThread, (LPVOID) (UINT_PTR) c, 0, nullptr);
			if (t) {
				CloseHandle(t);
			}
			else {
				closesocket(c);
			}
		}
	}

	// ---- casual PvP: the host's three patches (research/lon_pvp_build_spec.md 1.3) ----
	// World runs PvP as an ordinary network game on both clients. The host's EQGame becomes the
	// authority (Game+0x139 isServer) when world's SetupGame carries the marker 'NMSH' in its
	// Server ID for seat 1 -- live never sent that value, so a stock game never trips it. Each patch
	// is ONE vtable slot (EQGame / EQGameCommand_SetupGame only; skirmish, scenario and tutorial games
	// use EQMainController's own vtable and are untouched). All or none: every slot and every
	// original's first bytes are checked before anything is written. LoN unloads on close, taking
	// the patches with it; the pulse puts them into every new copy.
	const DWORD kPvPNetSvcGet  = 0x173D20;  // cdecl () -> NetworkService*
	const DWORD kPvPNetPump    = 0x175530;  // thiscall(netsvc): the network receive (runs received commands)
	const DWORD kPvPNetSend    = 0x173DC0;  // thiscall(netsvc, GameCommand*) -> bool, RET 4
	const DWORD kPvPOutboxIdx  = 0x0F0A00;  // thiscall(map* = game+0x12C, int *seat) -> vector*, RET 4
	const DWORD kPvPOutboxClr  = 0x0F1A00;  // thiscall(game, int keepSeat), RET 4
	const DWORD kPvPFlushOrig  = 0x0F4180;  // Game::flush, thiscall(game)
	const DWORD kPvPSetupOrig  = 0x2737E0;  // EQGameCommand_SetupGame::execute, thiscall(cmd)
	const DWORD kPvPDtorOrig   = 0x272BD0;  // EQGame scalar deleting dtor, thiscall(game, int flags), RET 4
	const DWORD kPvPSlotSetup  = 0x6416A0;  // SetupGame vtable 0x641664 + 0x3C (execute)
	const DWORD kPvPSlotFlush  = 0x64142C;  // EQGame vtable 0x64139C + 0x90 (flush)
	const DWORD kPvPSlotDtor   = 0x64139C;  // EQGame vtable + 0x00 (deleting dtor)
	const int   kPvPHostMarker = 0x4E4D5348; // 'NMSH' at SetupGame +0x28 (Server ID); = kHostMarker in world/lon_service.cpp
	// P4 (research/lon_pvp_host_black_screen.md 4): Game::addDisplayActionForPlayer
	// 0x100E1FD0 deletes every display action of an isServer game unless +0x304 (single player) is set,
	// so the host never got display action 0x60, which binds the game screen -> black board. NOP the
	// "isServer -> delete" jne: the host then posts for player 0 / its own seat like a skirmish master.
	// Replicas never reach the jump and skirmish/scenario/tutorial still delete there: stock-equivalent.
	// P5 (same doc, section 7): the four game-text posters (0x100E2310, 0x100E24B0, 0x100E2600,
	// 0x100E2760) post EVERY player's text on an isServer game without +0x304 -- the host saw seat 2's
	// "You draw <cards>". NOP their "isServer && !single player -> post" jne: the host then posts only
	// its own and all-player text. Guests skip it (je before), skirmish never takes it.
	// Each entry: the context bytes, ending with the 2-byte jne that becomes 90 90.
	struct PvPCodePatch { DWORD rva; BYTE len; BYTE bytes[23]; };
	const PvPCodePatch kPvPCode[] = {
		{0x0E2058,  9, {0x80, 0xBE, 0x39, 0x01, 0x00, 0x00, 0x00, 0x75, 0x23}},   // P4
		{0x0E233E, 19, {0x8A, 0x86, 0x39, 0x01, 0x00, 0x00, 0x84, 0xC0, 0x74, 0x09, 0x80, 0xBE, 0x04, 0x03, 0x00, 0x00, 0x01, 0x75, 0x30}},
		{0x0E24E9, 19, {0x8A, 0x87, 0x39, 0x01, 0x00, 0x00, 0x84, 0xC0, 0x74, 0x09, 0x80, 0xBF, 0x04, 0x03, 0x00, 0x00, 0x01, 0x75, 0x2C}},
		{0x0E262E, 23, {0x8A, 0x86, 0x39, 0x01, 0x00, 0x00, 0x84, 0xC0, 0x8B, 0x6C, 0x24, 0x20, 0x74, 0x09, 0x80, 0xBE, 0x04, 0x03, 0x00, 0x00, 0x01, 0x75, 0x2C}},
		{0x0E278F, 19, {0x8A, 0x86, 0x39, 0x01, 0x00, 0x00, 0x84, 0xC0, 0x74, 0x09, 0x80, 0xBE, 0x04, 0x03, 0x00, 0x00, 0x01, 0x75, 0x2C}},
	};

	BYTE    *g_pvpLon    = nullptr;   // the LoN copy the patches are in
	BYTE    *g_pvpFailed = nullptr;   // a copy whose checks failed (not retried)
	BYTE    *g_pvpHost   = nullptr;   // the EQGame we made the authority
	unsigned g_pvpSent   = 0;         // commands the host game sent to seat 2

	// The bundle's nms_paths.h does not exist in this tree: derive the log path from
	// eqgame's own directory (<game>\Logs\LoNPvP.log; the Logs folder already exists,
	// eqlog writes there -- create it anyway in case a client copy lacks it).
	std::string LoNLogPath()
	{
		char exe[MAX_PATH];
		DWORD n = GetModuleFileNameA(nullptr, exe, MAX_PATH);
		if (n == 0 || n >= MAX_PATH) return "LoNPvP.log";
		std::string p(exe);
		size_t slash = p.find_last_of("\\/");
		if (slash == std::string::npos) return "LoNPvP.log";
		p.resize(slash);
		p += "\\Logs";
		CreateDirectoryA(p.c_str(), nullptr);
		p += "\\LoNPvP.log";
		return p;
	}

	// Debugger output always; with toFile also <game>\Logs\LoNPvP.log -- written only by a hosted
	// PvP game or a failed install, never by ordinary card-game use.
	void PvPLog(bool toFile, const char *fmt, ...)
	{
		char line[512];
		va_list ap;
		va_start(ap, fmt);
		_vsnprintf_s(line, sizeof(line), _TRUNCATE, fmt, ap);
		va_end(ap);
		OutputDebugStringA("[NMS LoN PvP] ");
		OutputDebugStringA(line);
		OutputDebugStringA("\n");
		if (!toFile) return;
		FILE *f = nullptr;
		if (fopen_s(&f, LoNLogPath().c_str(), "ab") != 0 || !f) return;
		SYSTEMTIME t;
		GetLocalTime(&t);
		fprintf(f, "%04u-%02u-%02u %02u:%02u:%02u %s\r\n", t.wYear, t.wMonth, t.wDay, t.wHour, t.wMinute, t.wSecond, line);
		fclose(f);
	}

	// P1: become the master when world says so. cmd+4 PlayerID, cmd+8 mGame, cmd+0xC GameID,
	// cmd+0x28 Server ID. isServer is written directly -- NEVER through vtable+0x1B0, whose base
	// setter also clears the client-side game singleton.
	int __fastcall PvPSetupExec(BYTE *cmd, void *)
	{
		BYTE *game = *(BYTE **) (cmd + 8);
		if (game && *(int *) (cmd + 0x28) == kPvPHostMarker && *(int *) (cmd + 4) == 1) {
			game[0x139] = 1;
			g_pvpHost   = game;
			g_pvpSent   = 0;
			PvPLog(true, "P1 host role ON: game %p, GameID %d", game, *(int *) (cmd + 0xC));
		}
		return ((int(__thiscall *)(BYTE *)) (g_pvpLon + kPvPSetupOrig))(cmd);
	}

	// P2: Game::flush (0x100F4180) for the host game, with seat 2 in place of the local seat:
	// receive first (received guest input queues commands for seat 2), then send seat 2's queue,
	// then clear every queue (seat 1's = commands to ourselves, already applied).
	void __fastcall PvPHostFlush(BYTE *game, void *)
	{
		if (game != g_pvpHost) {
			((void(__thiscall *)(BYTE *)) (g_pvpLon + kPvPFlushOrig))(game);
			return;
		}
		void *net = ((void *(__cdecl *)()) (g_pvpLon + kPvPNetSvcGet))();
		((int(__thiscall *)(void *)) (g_pvpLon + kPvPNetPump))(net);
		if (game[0x108] != 1) return;   // GameStarted: the original sends nothing before it either
		int seat = 2;
		BYTE *vec = ((BYTE *(__thiscall *)(void *, int *)) (g_pvpLon + kPvPOutboxIdx))(game + 0x12C, &seat);
		unsigned n = 0;
		for (void **it = *(void ***) (vec + 4), **end = *(void ***) (vec + 8); it != end; ++it) {
			void *cmd = *it;
			net = ((void *(__cdecl *)()) (g_pvpLon + kPvPNetSvcGet))();
			((bool(__thiscall *)(void *, void *)) (g_pvpLon + kPvPNetSend))(net, cmd);
			if (cmd) (*(void(__thiscall **)(void *, int)) (*(void ***) cmd))(cmd, 1);   // scalar deleting dtor
			++n;
		}
		if (n && !g_pvpSent) PvPLog(true, "P2 first send to seat 2: %u command(s)", n);
		g_pvpSent += n;
		((void(__thiscall *)(BYTE *, int)) (g_pvpLon + kPvPOutboxClr))(game, 2);
		void **vt = *(void ***) game;
		((void(__thiscall *)(BYTE *)) vt[0x58 / 4])(game);   // the original's two tail calls
		((void(__thiscall *)(BYTE *)) vt[0x5C / 4])(game);
	}

	// P3: the Game dtor clears the singleton only when (!isServer || +0x304). +0x304 = "send
	// nothing", harmless on a dying game; without it the next LaunchGame reuses freed memory.
	void *__fastcall PvPHostDtor(BYTE *game, void *, int flags)
	{
		if (game && game == g_pvpHost) {
			game[0x304] = 1;
			g_pvpHost   = nullptr;
			PvPLog(true, "P3 host game %p destroyed (%u command(s) sent to seat 2)", game, g_pvpSent);
		}
		return ((void *(__thiscall *)(BYTE *, int)) (g_pvpLon + kPvPDtorOrig))(game, flags);
	}

	// ---- P6/P7: how a PvP game ended, reported by BOTH clients (host and guest) ----
	// A normal win is decided inside the games and nothing on the wire names the winner, so each client
	// tells world itself. Every ending of a network game goes through one of two EQGame virtuals (the
	// end-of-game text 0x102657B0 has only these callers): gameLostByPlayer (vt+0xAC, 0x1026F8B0:
	// avatar killed 0x11175, out of cards 0x11176, concede 1/4, RemovePlayer) and gameWonByPlayer
	// (vt+0xA8, 0x10269AC0: the quest win, loss type 0x11177). We wrap the two EQGame vtable slots only:
	// skirmish, scenario and tutorial games run EQMainController's own vtable and are untouched, and a
	// game whose MatchID (+0x60) is not one of world's PvP ids (2000000+) reports nothing.
	// The report is a frame only world reads (class 0x7F0, see QueueToWorld): the card game never sees it.
	const DWORD kPvPWonOrig    = 0x269AC0;  // EQGame::gameWonByPlayer, thiscall(game, int seat), RET 4
	const DWORD kPvPLostOrig   = 0x26F8B0;  // EQGame::gameLostByPlayer, thiscall(game, int seat, int lossType), RET 8
	const DWORD kPvPSlotWon    = 0x641444;  // EQGame vtable 0x64139C + 0xA8
	const DWORD kPvPSlotLost   = 0x641448;  // EQGame vtable 0x64139C + 0xAC
	const unsigned kPvPReportClass = 0x7F0; // world-only class, version 1, one header level
	const int   kPvPMatchMin   = 2000000;   // world's PvP / tournament game ids start here
	const int   kLossQuests    = 0x11177;

	void PutU(std::string &out, unsigned v)   // the card game's varint (lon_service.cpp Writer::U)
	{
		const unsigned inv = ~v;
		unsigned mag = v, neg = 0;
		if (inv < v) { mag = inv; neg = 1; }
		unsigned char b[5];
		unsigned cnt = 1, rest = mag >> 4;
		while (rest && cnt < 5) { b[cnt++] = (unsigned char) (rest & 0xFF); rest >>= 8; }
		b[0] = (unsigned char) ((mag & 0x0F) | ((((cnt - 1) * 2) + neg) << 4));
		out.append((const char *) b, cnt);
	}

	// kind 1 = seat lost (loss type), kind 2 = seat won. turns = the game's turn number (+0x2F4).
	void PvPReport(int match, int local, int kind, int seat, int lossType, int turns)
	{
		std::string body;
		PutU(body, kPvPReportClass); PutU(body, 1);
		PutU(body, (unsigned) match); PutU(body, (unsigned) local); PutU(body, (unsigned) kind);
		PutU(body, (unsigned) seat);  PutU(body, (unsigned) lossType); PutU(body, (unsigned) turns);
		// 4-byte length, then the 12-byte preamble every client frame carries (world strips it), then the body.
		const unsigned len = (unsigned) (12 + body.size());
		std::string frame;
		frame += (char) (len >> 24); frame += (char) (len >> 16); frame += (char) (len >> 8); frame += (char) len;
		frame.append(12, '\0');
		frame += body;
		QueueToWorld(frame);
		PvPLog(true, "result report: match %d, local seat %d, seat %d %s (loss type %#x), turn %d",
			match, local, seat, kind == 2 ? "won" : "lost", lossType, turns);
	}

	// A live PvP game: one of world's ids, started (+0x108), not over yet (+0x121), no fatal error (+0x1C4).
	bool PvPGameLive(BYTE *game, int &match)
	{
		if (!game) return false;
		match = *(int *) (game + 0x60);
		return match >= kPvPMatchMin && game[0x108] == 1 && game[0x121] == 0 && game[0x1C4] == 0;
	}

	void __fastcall PvPGameWon(BYTE *game, void *, int seat)
	{
		int match = 0;
		const bool live = PvPGameLive(game, match);
		const int local = live ? *(int *) (game + 0x128) : 0;
		const int turns = live ? *(int *) (game + 0x2F4) : 0;
		((void(__thiscall *)(BYTE *, int)) (g_pvpLon + kPvPWonOrig))(game, seat);
		if (live) PvPReport(match, local, 2, seat, kLossQuests, turns);
	}

	void __fastcall PvPGameLost(BYTE *game, void *, int seat, int lossType)
	{
		int match = 0;
		const bool live = PvPGameLive(game, match);
		const int local = live ? *(int *) (game + 0x128) : 0;
		const int turns = live ? *(int *) (game + 0x2F4) : 0;
		((void(__thiscall *)(BYTE *, int, int)) (g_pvpLon + kPvPLostOrig))(game, seat, lossType);
		if (live) PvPReport(match, local, 1, seat, lossType, turns);
	}

	bool PvPSlotOk(BYTE *lon, DWORD size, DWORD slot, DWORD orig, const BYTE *bytes, size_t n)
	{
		if (slot + 4 > size || orig + n > size) return false;
		return *(DWORD *) (lon + slot) == (DWORD) (lon + orig) && memcmp(lon + orig, bytes, n) == 0;
	}

	bool PvPWriteSlot(BYTE *lon, DWORD slot, const void *fn)
	{
		DWORD *p = (DWORD *) (lon + slot);
		DWORD old = 0;
		if (!VirtualProtect(p, sizeof(DWORD), PAGE_READWRITE, &old)) return false;
		*p = (DWORD) fn;
		VirtualProtect(p, sizeof(DWORD), old, &old);
		return true;
	}

	// P4/P5 check: the original context bytes, or this copy already patched (a reload at the same address).
	bool PvPCodeOk(BYTE *lon, DWORD size, const PvPCodePatch &c)
	{
		if (c.rva + c.len > size) return false;
		const BYTE *p = lon + c.rva;
		return memcmp(p, c.bytes, c.len) == 0 ||
		       (memcmp(p, c.bytes, c.len - 2) == 0 && p[c.len - 2] == 0x90 && p[c.len - 1] == 0x90);
	}

	// Code page: it must stay executable (PAGE_EXECUTE_READWRITE, never PAGE_READWRITE).
	bool PvPWriteCode(BYTE *lon, const PvPCodePatch &c)
	{
		BYTE *p = lon + c.rva + c.len - 2;
		if (p[0] == 0x90 && p[1] == 0x90) return true;
		DWORD old = 0;
		if (!VirtualProtect(p, 2, PAGE_EXECUTE_READWRITE, &old)) return false;
		p[0] = 0x90;
		p[1] = 0x90;
		VirtualProtect(p, 2, old, &old);
		FlushInstructionCache(GetCurrentProcess(), p, 2);
		return true;
	}

	// ---- P8: grey the navigator's link items whose switch is OFF (lon_home_screen_and_links.md 1.4) ----
	// EQNavigator vt+0x134 "update actions" (0x104712C0, __thiscall(nav), no stack args, plain RET) runs
	// before every Community / Misc menu popup (0x1046F900) and on the navigator's event 0x12, always
	// through the vtable. It re-enables Help (+0x90) and EULA (+0x8C) while connected and never touches
	// Forums (+0x7C), Leaderboards (+0x80) or Website (+0x84). The wrapper runs it, then greys each OFF item
	// with LoN's own unused helpers 0x10471220 disableAction / 0x10471270 enableAction (__stdcall(QAction*),
	// RET 4, ECX unused): QAction::setEnabled + the QWidgetAction's default widget setEnabled. A disabled
	// action fires nothing, and navigation.qss styles the disabled button grey. Its own all-or-none group:
	// a failed P1-P7 check does not stop P8, nor the other way round.
	const DWORD kNavSlotUpdate  = 0x649848;   // EQNavigator vtable 0x649714 + 0x134
	const DWORD kNavUpdateOrig  = 0x4712C0;
	const DWORD kNavDisableAct  = 0x471220;
	const DWORD kNavEnableAct   = 0x471270;
	const DWORD kNavActForums   = 0x7C;       // each a QWidgetAction* from 0x104718C0 (init 0x10472400)
	const DWORD kNavActBoards   = 0x80;
	const DWORD kNavActWebsite  = 0x84;
	const DWORD kNavActEula     = 0x8C;
	const DWORD kNavActHelp     = 0x90;

	BYTE *g_navLon    = nullptr;   // the LoN copy P8 is in
	BYTE *g_navFailed = nullptr;   // a copy whose checks failed (not retried)

	typedef void(__stdcall *NavActionFn)(void *action);

	// ON for the greying: the bit, and for the four page buttons also a usable address (an ON button
	// with no address would do nothing, so it stays grey).
	bool LinkOn(DWORD bit, int url)
	{
		if (!((DWORD) g_linkMask & bit)) return false;
		return url < 0 || !LinkTarget(url).empty();
	}

	void __fastcall NavUpdateActions(BYTE *nav, void *)
	{
		BYTE *lon = g_navLon;
		((void(__thiscall *)(BYTE *)) (lon + kNavUpdateOrig))(nav);
		if (!nav) return;
		const NavActionFn disable = (NavActionFn) (lon + kNavDisableAct);
		const NavActionFn enable  = (NavActionFn) (lon + kNavEnableAct);
		auto set = [&](DWORD off, bool on) {
			void *act = *(void **) (nav + off);
			if (act) (on ? enable : disable)(act);
		};
		set(kNavActForums,  LinkOn(kLinkForums, kUrlForums));
		set(kNavActBoards,  LinkOn(kLinkBoards, kUrlBoards));
		set(kNavActWebsite, LinkOn(kLinkWebsite, kUrlWebsite));
		if (!LinkOn(kLinkEula, -1))      set(kNavActEula, false);   // ON: LoN's own connected/disconnected rule
		if (!LinkOn(kLinkHelp, kUrlHelp)) set(kNavActHelp, false);
	}

	void NavPulse(BYTE *lon)
	{
		if (!lon) {
			g_navLon = g_navFailed = nullptr;
			return;
		}
		if (lon == g_navFailed) return;
		if (lon == g_navLon && *(DWORD *) (lon + kNavSlotUpdate) == (DWORD) &NavUpdateActions) return;   // in place
		g_navLon = nullptr;
		const IMAGE_DOS_HEADER *dos = (const IMAGE_DOS_HEADER *) lon;
		const IMAGE_NT_HEADERS32 *nt = (const IMAGE_NT_HEADERS32 *) (lon + dos->e_lfanew);
		const DWORD size = nt->OptionalHeader.SizeOfImage;
		// No relocated bytes in these: they hold for any load address.
		static const BYTE kUpdateBytes[]  = {0x83, 0xEC, 0x08, 0x53, 0x55, 0x56, 0x57, 0x8B, 0xF1, 0xE8};
		static const BYTE kDisableBytes[] = {0x56, 0x8B, 0x74, 0x24, 0x08, 0x6A, 0x00, 0x8B, 0xCE, 0xFF, 0x15};
		static const BYTE kEnableBytes[]  = {0x56, 0x8B, 0x74, 0x24, 0x08, 0x6A, 0x01, 0x8B, 0xCE, 0xFF, 0x15};
		static const BYTE kHelperTail[]   = {0x5F, 0x5E, 0xC2, 0x04, 0x00};   // pop edi; pop esi; ret 4 (+0x3F)
		const bool slot = PvPSlotOk(lon, size, kNavSlotUpdate, kNavUpdateOrig, kUpdateBytes, sizeof(kUpdateBytes));
		const bool helpers = kNavEnableAct + 0x44 <= size &&
			memcmp(lon + kNavDisableAct, kDisableBytes, sizeof(kDisableBytes)) == 0 &&
			memcmp(lon + kNavEnableAct, kEnableBytes, sizeof(kEnableBytes)) == 0 &&
			memcmp(lon + kNavDisableAct + 0x3F, kHelperTail, sizeof(kHelperTail)) == 0 &&
			memcmp(lon + kNavEnableAct + 0x3F, kHelperTail, sizeof(kHelperTail)) == 0;
		if (!slot || !helpers) {
			g_navFailed = lon;
			PvPLog(true, "link-button check failed at %p (slot %s, helpers %s) -- an unknown LoN build: P8 NOT installed",
				lon, slot ? "ok" : "BAD", helpers ? "ok" : "BAD");
			return;
		}
		g_navLon = lon;   // before the slot: the wrapper calls through it
		const bool w = PvPWriteSlot(lon, kNavSlotUpdate, (const void *) &NavUpdateActions);
		PvPLog(!w, w ? "P8 (link buttons) installed in LegendsOfNorrath.dll at %p" : "P8 install FAILED at %p (VirtualProtect)", lon);
	}

} // namespace

namespace NMSLoN {

	void PvPHostPulse(void *module)
	{
		BYTE *lon = (BYTE *) module;
		NavPulse(lon);   // P8, its own all-or-none group
		if (!lon) {
			g_pvpLon = g_pvpFailed = g_pvpHost = nullptr;
			return;
		}
		if (lon == g_pvpFailed) return;
		if (lon == g_pvpLon && *(DWORD *) (lon + kPvPSlotSetup) == (DWORD) &PvPSetupExec) return;   // in place

		// A new copy (or one reloaded at the same address): its games are new too.
		g_pvpLon  = nullptr;
		g_pvpHost = nullptr;
		const IMAGE_DOS_HEADER *dos = (const IMAGE_DOS_HEADER *) lon;
		const IMAGE_NT_HEADERS32 *nt = (const IMAGE_NT_HEADERS32 *) (lon + dos->e_lfanew);
		const DWORD size = nt->OptionalHeader.SizeOfImage;
		static const BYTE kSetupBytes[] = {0x64, 0xA1, 0x00, 0x00, 0x00, 0x00, 0x6A, 0xFF};
		static const BYTE kFlushBytes[] = {0x55, 0x8B, 0xEC, 0x6A, 0xFF, 0x68};
		static const BYTE kDtorBytes[]  = {0x56, 0x8B, 0xF1, 0xE8};
		const bool p1 = PvPSlotOk(lon, size, kPvPSlotSetup, kPvPSetupOrig, kSetupBytes, sizeof(kSetupBytes));
		const bool p2 = PvPSlotOk(lon, size, kPvPSlotFlush, kPvPFlushOrig, kFlushBytes, sizeof(kFlushBytes));
		const bool p3 = PvPSlotOk(lon, size, kPvPSlotDtor, kPvPDtorOrig, kDtorBytes, sizeof(kDtorBytes));
		// P6/P7: both start with the SEH prologue and their own handler address (unique to this build).
		static const BYTE kWonBytes[]  = {0x64, 0xA1, 0x00, 0x00, 0x00, 0x00, 0x6A, 0xFF, 0x68, 0x8B, 0xE7, 0x5A};
		static const BYTE kLostBytes[] = {0x64, 0xA1, 0x00, 0x00, 0x00, 0x00, 0x6A, 0xFF, 0x68, 0x34, 0xEC, 0x5A};
		const bool p6 = PvPSlotOk(lon, size, kPvPSlotWon, kPvPWonOrig, kWonBytes, sizeof(kWonBytes));
		const bool p7 = PvPSlotOk(lon, size, kPvPSlotLost, kPvPLostOrig, kLostBytes, sizeof(kLostBytes));
		bool code = true;
		for (const PvPCodePatch &c : kPvPCode) code = code && PvPCodeOk(lon, size, c);
		if (!p1 || !p2 || !p3 || !p6 || !p7 || !code) {
			g_pvpFailed = lon;
			PvPLog(true, "check failed at %p (P1 %s, P2 %s, P3 %s, P4/P5 %s, P6 %s, P7 %s) -- an unknown LoN build: PvP patches NOT installed",
				lon, p1 ? "ok" : "BAD", p2 ? "ok" : "BAD", p3 ? "ok" : "BAD", code ? "ok" : "BAD", p6 ? "ok" : "BAD", p7 ? "ok" : "BAD");
			return;
		}
		g_pvpLon = lon;   // before the slots: the replacements call through it
		bool w = true;
		for (const PvPCodePatch &c : kPvPCode) w = w && PvPWriteCode(lon, c);
		w = w && PvPWriteSlot(lon, kPvPSlotFlush, (const void *) &PvPHostFlush) &&
		         PvPWriteSlot(lon, kPvPSlotDtor, (const void *) &PvPHostDtor) &&
		         PvPWriteSlot(lon, kPvPSlotWon, (const void *) &PvPGameWon) &&
		         PvPWriteSlot(lon, kPvPSlotLost, (const void *) &PvPGameLost) &&
		         PvPWriteSlot(lon, kPvPSlotSetup, (const void *) &PvPSetupExec);
		PvPLog(!w, w ? "P1-P7 installed in LegendsOfNorrath.dll at %p" : "P1-P7 install FAILED at %p (VirtualProtect)", lon);
	}

	void Install(unsigned long base)
	{
		if (!g_lockReady) {
			InitializeCriticalSection(&g_lock);
			g_lockReady = true;
		}
		g_base = base;
		DWORD *slot = (DWORD *) ((kIatLoadLibraryExA - 0x400000) + base);
		DWORD old = 0;
		if (!VirtualProtect(slot, sizeof(DWORD), PAGE_READWRITE, &old)) {
			return;
		}
		g_realLoadLibraryExA = (LoadLibraryExA_t) *slot;
		*slot = (DWORD) &LoadLibraryExA_Wrap;
		VirtualProtect(slot, sizeof(DWORD), old, &old);
	}

	void OnSession(const char *buf, size_t size)
	{
		if (!g_lockReady || !buf || size < 172) {
			return;
		}
		char token[37] = {};
		char host[129] = {};
		memcpy(token, buf, 36);
		memcpy(host, buf + 36, 128);
		const unsigned int port = *(const unsigned int *) (buf + 164);

		// Link buttons: the bitmask at 168 (an old server sends 0 = all off), then the optional v2 tail:
		// uint32 'NMSU', then help, forums, leaderboards, website, each uint16 length + that many bytes (no
		// NUL), each at most 255. A short or malformed tail = no addresses (those buttons stay off).
		DWORD mask;
		memcpy(&mask, buf + 168, sizeof(mask));
		std::string urls[kUrlCount];
		size_t at = 172;
		DWORD magic = 0;
		if (size >= at + 4) memcpy(&magic, buf + at, 4);
		if (magic == kLinkTailMagic) {
			at += 4;
			bool ok = true;
			for (int i = 0; i < kUrlCount && ok; ++i) {
				unsigned short len = 0;
				if (size < at + 2) { ok = false; break; }
				memcpy(&len, buf + at, 2);
				at += 2;
				if (len > kLinkUrlMax || size < at + len) { ok = false; break; }
				urls[i].assign(buf + at, len);
				at += len;
			}
			if (!ok) for (std::string &u : urls) u.clear();
		}
		for (std::string &u : urls) if (!SafeWebUrl(u)) u.clear();
		InterlockedExchange(&g_linkMask, (LONG) (mask & 0x1F));

		EnterCriticalSection(&g_lock);
		for (int i = 0; i < kUrlCount; ++i) g_linkUrl[i] = urls[i];
		g_token = token;
		g_host  = host;
		g_port  = (unsigned short) port;
		const bool start = !g_relayStarted;
		g_relayStarted = true;
		LeaveCriticalSection(&g_lock);

		WriteSessionBuffer();
		if (start) {
			WSADATA wsa;
			WSAStartup(MAKEWORD(2, 2), &wsa);
			HANDLE t = CreateThread(nullptr, 0, ListenThread, nullptr, 0, nullptr);
			if (t) {
				CloseHandle(t);
			}
		}
	}

	const char *Token()
	{
		if (!g_lockReady) {
			return nullptr;
		}
		static std::string copy;
		EnterCriticalSection(&g_lock);
		copy = g_token;
		LeaveCriticalSection(&g_lock);
		return copy.empty() ? nullptr : copy.c_str();
	}

} // namespace NMSLoN
