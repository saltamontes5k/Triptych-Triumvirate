// nms_lon_audio.h -- the card game's soundtrack, played out of the client's sounds.rcc.
//
// Nothing is shipped: LegendsOfNorrath\sounds.rcc already holds all 22 tracks and all
// 60 effects (Ogg Vorbis), so dinput8 decodes it in place instead of reading loose
// files next to the executable. See nms_lon_audio.cpp.
#pragma once

namespace NMSLoN {
	// Every frame on the render thread, with GetModuleHandleA("LegendsOfNorrath.dll")
	// (nullptr when it is not loaded). This is the only place the engine touches the
	// archive, the decoders or the audio device: it opens the card game on the startup
	// theme and hands over to the lobby loop, stops everything when it closes, consumes
	// the requests below, and returns a finished one-shot to the lobby.
	void MusicPulse(void *lonModule);

	// The relay's frame sniffer found AccountCommand_RecordSinglePlayerGame (0x1E7):
	// activity 1 = a game began, activity 2 = it ended (result 1 win / 2 lose, anything
	// else = back to the lobby). The sniffer runs on the relay's worker thread, so these
	// only post a request; MusicPulse performs it on the render thread.
	void GameMusicBegin();
	void GameMusicEnd(unsigned result);

	// A one-shot effect by its name in sounds.rcc, e.g. "snd_button.ogg" -- for the
	// EmitSound hook once the LoN.dll side is mapped. Safe to call from any thread (the
	// name is queued); overlapping effects are mixed and extras beyond a small cap drop.
	void SfxPlay(const char *rccName);
}
