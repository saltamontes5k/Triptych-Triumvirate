// nms_lon_link.h -- connects the Legends of Norrath card game to our server.
//
// The card game (LegendsOfNorrath.dll, loaded by eqgame when the player opens it) talks to
// a hard-coded Sony gateway. Three pieces make it talk to world's card service instead
// (NMS-Server world/lon_service.cpp):
//   1. eqgame loads it with LoadLibraryExA (call at 0x7A1785 through import slot 0x9C0274).
//      We wrap that import; when the card game's DLL loads, its gateway host literal (RVA
//      0x62B8D8, "lvsccg-02-01.station.sony.com") becomes "127.0.0.1" before its
//      Initialize runs.
//   2. A relay on 127.0.0.1:15782 forwards every card-game connection to the host and port
//      the zone server sent (OP_NMSLoNSession).
//   3. That packet's one-time token becomes the card game's --sessionID= (eqgame buffer
//      0xF800D0), which is how the card service knows which account this is.
//
// URLs: the card game asks its host to open URLs through eqgame's callback table (0xF8034C
// slot 0 = open URL, slot 1 = open URL + POST; live opened them in EQ's own web window
// "TcgWebWnd", whose Gecko browser is dead). Both slots are replaced just before the card
// game's Initialize copies the table: a Sony help / forum / ratings / website URL opens the
// server's address for that button when it is ON; every other URL (including the Buy/store
// button) is dropped.

#pragma once

#include <cstddef>

#include "nms_lon_audio.h"   // the card game's soundtrack (sounds.rcc)

namespace NMSLoN {
	// Once, from InitHooks: wraps eqgame's LoadLibraryExA import. `base` = eqgame's base.
	void Install(unsigned long base);

	// OP_NMSLoNSession (0x141C): {char token[36]; char host[128]; uint32 port; uint32 linkButtons;}
	// then an optional tail: uint32 'NMSU', 4 x (uint16 len + bytes) = the help, forums, leaderboards
	// and website addresses (Custom:LoNLinkButtons / Custom:LoN*Url). linkButtons bits: 1 Help, 2 EULA,
	// 4 Forums, 8 Leaderboards, 16 Website; 0 (and every older server) = all five greyed out.
	void OnSession(const char *buf, size_t size);

	// The token to put in --sessionID=, or nullptr before the server has sent one.
	const char *Token();

	// Every frame, with GetModuleHandleA("LegendsOfNorrath.dll") (nullptr when it is not loaded):
	// puts the casual PvP host patches into each new copy of the card game (vtable slots of EQGame
	// and its SetupGame command; research/lon_pvp_build_spec.md 1.3). They do nothing
	// until world's SetupGame names this client the host. Unknown LoN build = nothing patched.
	// Also P8: the navigator's Help / Review EULA / Forums / Leaderboards / Website menu items are
	// greyed while their switch is off (research/lon_home_screen_and_links.md 1.4).
	void PvPHostPulse(void *lon);

}
