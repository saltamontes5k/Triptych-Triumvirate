// lon_service.h
//
// The Legends of Norrath card service. The card game (LegendsOfNorrath.dll, hosted by
// eqgame) speaks its own TCP protocol; on live a Sony service answered it. Here world
// answers it, and the server owns every card: collections, decks, packs, loot cards and
// scenario rewards all live in the lon_* tables (manifest v431).
//
// How a player reaches it: zone hands the client's dinput8 a one-time token
// (OP_NMSLoNSession, zone/client_packet.cpp) when the DLL reports in; the DLL passes the
// token to the card game as its --sessionID= and relays the card game's 127.0.0.1:15782
// connection to this service (Custom:LoNPort). The token is the only proof of identity --
// any other session string is refused.
//
// Protocol reference: research/eqlib_LoN/LoN_messages.txt (every message, field by field) and
// research/eqlib_LoN/LoN_service.md. Off unless Custom:LoNEnabled.

#pragma once

namespace LoNService {
	// Reads the rules, loads the card game's data files (Custom:LoNDataPath) and starts
	// listening. Does nothing when Custom:LoNEnabled is false or the data is missing.
	void Start();

	// Called from world's main loop: sends products bought elsewhere (lon_delivery) to
	// players who are connected right now.
	void Process();
}
