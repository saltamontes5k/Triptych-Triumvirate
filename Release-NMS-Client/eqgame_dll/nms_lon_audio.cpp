// nms_lon_audio.cpp -- the card game's soundtrack, played out of the client's sounds.rcc.
//
// The 2013 LegendsOfNorrath.dll that every RoF2 client ships has no audio code at all:
// it never references an audio API and never loads its Ogg decoders. The tracks and
// effects are Sony's, so they must not be redistributed with the server or the DLL.
// Both problems have one answer -- the client already carries all of it inside
//   <game>\LegendsOfNorrath\sounds.rcc
// a Qt "qres" archive whose 82 payloads are Ogg Vorbis with every byte XOR 0x73
// (22 music_*.ogg, 60 snd_*.ogg). We read that archive in place, decode with the
// bundled stb_vorbis (public domain) and play through waveOut. Nothing is written to
// disk and nothing has to ship beside dinput8.dll.
//
// State machine:
//   card game opens                       -> startup theme (music_startup.ogg), then lobby loop
//   single-player game begins (0x1E7 / 1) -> startup/lobby stop, a random playmat theme loops
//   game ends (0x1E7 / 2)                 -> playmat stops; victory/defeat one-shot, or
//                                            straight back to the lobby on any other result
//   the one-shot finishes                 -> lobby loop
//   card game closes                      -> everything stops
//
// THREADING: MusicPulse() runs every frame on eqgame's render thread, while the frame
// sniffer that reports game begin/end runs on the relay's worker thread (nms_lon_link.cpp
// PumpThread). Every entry point is therefore a request, not an action: GameMusicBegin/
// GameMusicEnd post an interlocked flag and SfxPlay queues a name under a critical
// section, and only MusicPulse touches the archive, the decoders or waveOut. That keeps
// the whole engine single-threaded.

#include <windows.h>
#include <mmsystem.h>

#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <map>
#include <memory>
#include <string>
#include <utility>
#include <vector>

#include "nms_lon_audio.h"
#include "nms_vorbis.h"

#pragma comment(lib, "winmm.lib")

namespace {

	// ---- logging ---------------------------------------------------------------
	// The debugger always; <game>\Logs\LoNSound.log only for problems, so a client
	// that plays nothing can be diagnosed after the fact without spamming the log.
	std::string LogPath()
	{
		char exe[MAX_PATH];
		DWORD n = GetModuleFileNameA(nullptr, exe, MAX_PATH);
		if (n == 0 || n >= MAX_PATH) return "LoNSound.log";
		std::string p(exe);
		size_t slash = p.find_last_of("\\/");
		if (slash == std::string::npos) return "LoNSound.log";
		p.resize(slash);
		p += "\\Logs";
		CreateDirectoryA(p.c_str(), nullptr);
		p += "\\LoNSound.log";
		return p;
	}

	void LogLine(bool toFile, const char *fmt, va_list ap)
	{
		char line[512];
		_vsnprintf_s(line, sizeof(line), _TRUNCATE, fmt, ap);
		OutputDebugStringA("[NMS LoN audio] ");
		OutputDebugStringA(line);
		OutputDebugStringA("\n");
		if (!toFile) return;
		FILE *f = nullptr;
		if (fopen_s(&f, LogPath().c_str(), "ab") != 0 || !f) return;
		SYSTEMTIME t;
		GetLocalTime(&t);
		fprintf(f, "%04u-%02u-%02u %02u:%02u:%02u %s\r\n", t.wYear, t.wMonth, t.wDay, t.wHour, t.wMinute, t.wSecond, line);
		fclose(f);
	}

	void LogInfo(const char *fmt, ...)
	{
		va_list ap; va_start(ap, fmt); LogLine(false, fmt, ap); va_end(ap);
	}

	void LogWarn(const char *fmt, ...)
	{
		va_list ap; va_start(ap, fmt); LogLine(true, fmt, ap); va_end(ap);
	}

	std::string GameDir()
	{
		char exe[MAX_PATH];
		DWORD n = GetModuleFileNameA(nullptr, exe, MAX_PATH);
		if (n == 0 || n >= MAX_PATH) return std::string();
		std::string p(exe);
		size_t slash = p.find_last_of("\\/");
		if (slash == std::string::npos) return std::string();
		p.resize(slash);
		return p;
	}

	// ---- sounds.rcc (Qt "qres" archive) ----------------------------------------
	//
	// Layout: 20-byte header ('qres', version, treeOffset, dataOffset, nameOffset, all
	// big-endian), then the payload data, then the name block, then the node tree --
	// the tree is the LAST block, so the entry count is (fileSize - treeOffset) / 14.
	// A node is nameOffset(4) flags(2) country(2) language(2) dataOffset(4); flags bit 1
	// marks zlib compression (this client stores none) and bit 2 a directory. A name is
	// uint16 length, uint32 hash, then length UTF-16BE characters. A payload is a uint32
	// big-endian size followed by that many bytes, every byte XOR 0x73.
	//
	// Only the header, names and tree stay in memory (a few KB); payloads are read on
	// demand, so the 34 MB archive costs nothing until a track actually plays.
	struct RccEntry {
		unsigned offset;      // from dataOffset
		bool     compressed;  // flags bit 0
	};

	unsigned Be32(const unsigned char *p) { return ((unsigned) p[0] << 24) | ((unsigned) p[1] << 16) | ((unsigned) p[2] << 8) | (unsigned) p[3]; }
	unsigned Be16(const unsigned char *p) { return ((unsigned) p[0] << 8) | (unsigned) p[1]; }

	class RccArchive {
	public:
		RccArchive() {}
		~RccArchive() { if (m_fp) fclose(m_fp); }

		bool Load(const char *path);
		bool Extract(const char *name, std::vector<unsigned char> &out);
		unsigned Entries() const { return (unsigned) m_files.size(); }
		bool Loaded() const { return m_fp != nullptr; }

	private:
		RccArchive(const RccArchive &);
		RccArchive &operator=(const RccArchive &);

		FILE *m_fp = nullptr;
		unsigned m_dataOffset = 0;
		unsigned m_fileSize = 0;
		std::map<std::string, RccEntry> m_files;
	};

	bool RccArchive::Load(const char *path)
	{
		FILE *fp = nullptr;
		if (fopen_s(&fp, path, "rb") != 0 || !fp) return false;

		_fseeki64(fp, 0, SEEK_END);
		const __int64 size = _ftelli64(fp);
		_fseeki64(fp, 0, SEEK_SET);
		if (size < 20) { fclose(fp); return false; }

		unsigned char hdr[20];
		if (fread(hdr, 1, sizeof(hdr), fp) != sizeof(hdr) || memcmp(hdr, "qres", 4) != 0) { fclose(fp); return false; }

		const unsigned treeOff = Be32(hdr + 8), dataOff = Be32(hdr + 12), nameOff = Be32(hdr + 16);
		if (treeOff > (unsigned) size || nameOff > treeOff || dataOff > (unsigned) size) { fclose(fp); return false; }

		const size_t namesLen = (size_t) (treeOff - nameOff);
		const size_t treeLen  = (size_t) size - treeOff;
		std::vector<unsigned char> names(namesLen), tree(treeLen);
		if (namesLen) { _fseeki64(fp, nameOff, SEEK_SET); if (fread(names.data(), 1, namesLen, fp) != namesLen) { fclose(fp); return false; } }
		if (treeLen)  { _fseeki64(fp, treeOff, SEEK_SET); if (fread(tree.data(), 1, treeLen, fp) != treeLen) { fclose(fp); return false; } }

		for (size_t i = 0, count = treeLen / 14; i < count; ++i) {
			const unsigned char *node = tree.data() + i * 14;
			const unsigned nameIdx = Be32(node + 0);
			const unsigned flags   = Be16(node + 4);
			if (flags & 2) continue;                                     // directory
			if ((size_t) nameIdx + 6 > namesLen) continue;
			const unsigned len = Be16(names.data() + nameIdx);
			if ((size_t) nameIdx + 6 + (size_t) len * 2 > namesLen) continue;
			std::string name;
			name.reserve(len);
			for (unsigned c = 0; c < len; ++c) name.push_back((char) Be16(names.data() + nameIdx + 6 + c * 2));
			RccEntry e;
			e.offset = Be32(node + 10);
			e.compressed = (flags & 1) != 0;
			m_files[name] = e;
		}

		if (m_files.empty()) { fclose(fp); return false; }

		m_fp = fp;
		m_dataOffset = dataOff;
		m_fileSize = (unsigned) size;
		return true;
	}

	bool RccArchive::Extract(const char *name, std::vector<unsigned char> &out)
	{
		if (!m_fp) return false;
		std::map<std::string, RccEntry>::const_iterator it = m_files.find(name);
		if (it == m_files.end()) return false;
		const RccEntry &e = it->second;

		const unsigned long long pos = (unsigned long long) m_dataOffset + e.offset;
		if (pos + 4 > m_fileSize) return false;
		if (_fseeki64(m_fp, (__int64) pos, SEEK_SET) != 0) return false;

		unsigned char sz[4];
		if (fread(sz, 1, 4, m_fp) != 4) return false;
		const unsigned size = Be32(sz);

		if (e.compressed) {
			// This client stores all 82 payloads uncompressed. We deliberately do not
			// link an inflate implementation for a case that never occurs here.
			LogWarn("sounds.rcc entry %s is zlib-compressed; not supported", name);
			return false;
		}

		const unsigned long long body = pos + 4;
		if (body + size > m_fileSize) return false;

		out.resize(size);
		if (size && fread(out.data(), 1, size, m_fp) != size) { out.clear(); return false; }
		for (unsigned i = 0; i < size; ++i) out[i] = (unsigned char) (out[i] ^ 0x73);
		return true;
	}

	// ---- waveOut stream --------------------------------------------------------
	// Decodes Ogg Vorbis straight from memory and queues PCM into waveOut buffers that
	// are refilled from MusicPulse() each frame. One device per stream, so Windows mixes
	// the music with any overlapping effects.
	class Stream {
	public:
		Stream() {}
		~Stream() { Close(); }

		bool Open(const std::vector<unsigned char> &ogg, bool loop, int volume);
		void Pulse();
		void Close();
		bool Finished() const { return m_ended && m_queued == 0; }

	private:
		Stream(const Stream &);
		Stream &operator=(const Stream &);

		enum { kBuffers = 4, kFrames = 4096 };

		bool Fill(int i);
		void Submit(int i);

		HWAVEOUT                   m_wo = nullptr;
		WAVEHDR                    m_hdr[kBuffers];
		std::vector<short>         m_pcm[kBuffers];
		bool                       m_queuedFlag[kBuffers];
		unsigned                   m_queued = 0;
		stb_vorbis                *m_v = nullptr;
		std::vector<unsigned char> m_ogg;
		int                        m_channels = 0;
		int                        m_rate = 0;
		int                        m_volume = 1000;
		bool                       m_loop = false;
		bool                       m_ended = false;
	};

	bool Stream::Open(const std::vector<unsigned char> &ogg, bool loop, int volume)
	{
		m_loop = loop;
		m_volume = volume;
		m_ogg = ogg;

		int err = 0;
		m_v = stb_vorbis_open_memory(m_ogg.data(), (int) m_ogg.size(), &err, nullptr);
		if (!m_v) { LogWarn("stb_vorbis_open_memory failed (%d)", err); return false; }

		const stb_vorbis_info info = stb_vorbis_get_info(m_v);
		m_channels = info.channels;
		m_rate = (int) info.sample_rate;
		if (m_channels < 1 || m_channels > 2 || m_rate < 1000) {
			LogWarn("unusable stream: %d channel(s), %d Hz", m_channels, m_rate);
			Close();
			return false;
		}

		WAVEFORMATEX wf;
		memset(&wf, 0, sizeof(wf));
		wf.wFormatTag = WAVE_FORMAT_PCM;
		wf.nChannels = (WORD) m_channels;
		wf.nSamplesPerSec = (DWORD) m_rate;
		wf.wBitsPerSample = 16;
		wf.nBlockAlign = (WORD) (m_channels * 2);
		wf.nAvgBytesPerSec = (DWORD) (m_rate * wf.nBlockAlign);

		memset(m_hdr, 0, sizeof(m_hdr));
		memset(m_queuedFlag, 0, sizeof(m_queuedFlag));
		if (waveOutOpen(&m_wo, WAVE_MAPPER, &wf, 0, 0, CALLBACK_NULL) != MMSYSERR_NOERROR) {
			m_wo = nullptr;
			Close();
			return false;
		}

		for (int i = 0; i < kBuffers; ++i) {
			if (!Fill(i)) break;
			Submit(i);
		}
		if (m_queued == 0) { Close(); return false; }
		return true;
	}

	bool Stream::Fill(int i)
	{
		if (!m_v) return false;
		std::vector<short> &buf = m_pcm[i];
		buf.resize((size_t) kFrames * m_channels);

		int got = stb_vorbis_get_samples_short_interleaved(m_v, m_channels, buf.data(), (int) buf.size());
		if (got == 0 && m_loop) {
			stb_vorbis_seek_start(m_v);
			got = stb_vorbis_get_samples_short_interleaved(m_v, m_channels, buf.data(), (int) buf.size());
		}
		if (got == 0) { m_ended = true; return false; }

		if (m_volume < 1000) {
			const size_t n = (size_t) got * m_channels;
			for (size_t s = 0; s < n; ++s) buf[s] = (short) ((int) buf[s] * m_volume / 1000);
		}

		WAVEHDR &h = m_hdr[i];
		h.lpData = (LPSTR) buf.data();
		h.dwBufferLength = (DWORD) ((size_t) got * m_channels * sizeof(short));
		return true;
	}

	void Stream::Submit(int i)
	{
		if (!m_wo) return;
		WAVEHDR &h = m_hdr[i];
		h.dwBytesRecorded = 0;
		h.dwUser = 0;
		h.dwFlags = 0;
		h.dwLoops = 0;
		if (waveOutPrepareHeader(m_wo, &h, sizeof(WAVEHDR)) != MMSYSERR_NOERROR) return;
		if (waveOutWrite(m_wo, &h, sizeof(WAVEHDR)) != MMSYSERR_NOERROR) {
			waveOutUnprepareHeader(m_wo, &h, sizeof(WAVEHDR));
			return;
		}
		m_queuedFlag[i] = true;
		++m_queued;
	}

	void Stream::Pulse()
	{
		if (!m_wo) return;
		for (int i = 0; i < kBuffers; ++i) {
			if (!m_queuedFlag[i]) continue;
			if ((m_hdr[i].dwFlags & WHDR_DONE) == 0) continue;
			waveOutUnprepareHeader(m_wo, &m_hdr[i], sizeof(WAVEHDR));
			m_queuedFlag[i] = false;
			--m_queued;
			if (!m_ended && Fill(i)) Submit(i);
		}
	}

	void Stream::Close()
	{
		if (m_wo) {
			waveOutReset(m_wo);
			for (int i = 0; i < kBuffers; ++i) {
				if (m_queuedFlag[i]) {
					waveOutUnprepareHeader(m_wo, &m_hdr[i], sizeof(WAVEHDR));
					m_queuedFlag[i] = false;
				}
			}
			waveOutClose(m_wo);
			m_wo = nullptr;
		}
		if (m_v) { stb_vorbis_close(m_v); m_v = nullptr; }
		for (int i = 0; i < kBuffers; ++i) m_pcm[i].clear();
		m_ogg.clear();
		m_queued = 0;
		m_ended = false;
	}

	// ---- engine ----------------------------------------------------------------
	const char *kStartup  = "music_startup.ogg";
	const char *kLobby    = "music_lobby_loop.ogg";
	const char *kPlaymat  = "music_playmat_%02u.ogg";
	const char *kVictory  = "music_victory.ogg";
	const char *kDefeat   = "music_defeat.ogg";

	const int    kMusicVolume  = 600;   // of 1000, matching the old MCI layer
	const int    kJingleVolume = 700;
	const int    kSfxVolume    = 900;
	const size_t kMaxSfx       = 8;     // overlapping effects; extras are dropped
	const size_t kMaxSfxQueued = 32;    // requests waiting for the next frame

	RccArchive              g_rcc;
	bool                    g_rccTried = false;
	HMODULE                 g_cardGame = nullptr;
	std::unique_ptr<Stream> g_music;    // startup/lobby loop or playmat loop
	std::unique_ptr<Stream> g_jingle;   // one-shot startup/victory/defeat
	std::vector<std::unique_ptr<Stream> > g_sfx;
	bool                    g_jingleActive = false;   // the one-shot hands back to the lobby
	bool                    g_inGame = false;

	// cross-thread requests (relay worker -> render thread)
	volatile LONG           g_reqBegin = 0;
	volatile LONG           g_reqEnd = 0;        // result + 1; 0 = none
	std::vector<std::string> g_sfxPending;       // under SfxLock

	CRITICAL_SECTION *SfxLock()
	{
		// Function-local statics are initialised once, thread-safely (C++11).
		static CRITICAL_SECTION cs;
		static const bool once = (InitializeCriticalSection(&cs), true);
		(void) once;
		return &cs;
	}

	bool Archive()
	{
		if (!g_rccTried) {
			g_rccTried = true;
			const std::string path = GameDir() + "\\LegendsOfNorrath\\sounds.rcc";
			if (g_rcc.Load(path.c_str())) LogInfo("sounds.rcc loaded (%u entries)", g_rcc.Entries());
			else LogWarn("sounds.rcc not usable: %s", path.c_str());
		}
		return g_rcc.Loaded();
	}

	std::unique_ptr<Stream> OpenTrack(const char *name, bool loop, int volume)
	{
		if (!Archive()) return std::unique_ptr<Stream>();
		std::vector<unsigned char> ogg;
		if (!g_rcc.Extract(name, ogg) || ogg.empty()) { LogWarn("no sounds.rcc entry %s", name); return std::unique_ptr<Stream>(); }
		std::unique_ptr<Stream> s(new Stream());
		if (!s->Open(ogg, loop, volume)) { LogWarn("could not play %s", name); return std::unique_ptr<Stream>(); }
		return s;
	}

	// Closing whatever is playing is what keeps one track from bleeding into the next.
	void PlayMusic(const char *name, bool loop, int volume)
	{
		if (g_music) { g_music->Close(); g_music.reset(); }
		g_music = OpenTrack(name, loop, volume);
	}

	void StopMusic()
	{
		if (g_music) { g_music->Close(); g_music.reset(); }
	}

	bool PlayJingle(const char *name)
	{
		if (g_jingle) { g_jingle->Close(); g_jingle.reset(); }
		g_jingle = OpenTrack(name, false, kJingleVolume);
		g_jingleActive = (g_jingle != nullptr);
		return g_jingleActive;
	}

	void OpenCardGame()
	{
		if (g_inGame) return;   // a game report beat the load transition; leave it alone
		LogInfo("card game opened");
		// The client opened on its startup theme and only then handed over to the lobby
		// loop; reproduce that, falling back to the lobby if the track is unavailable.
		if (!PlayJingle(kStartup)) PlayMusic(kLobby, true, kMusicVolume);
	}

	void DoGameBegin()
	{
		g_inGame = true;
		g_jingleActive = false;
		if (g_jingle) { g_jingle->Close(); g_jingle.reset(); }
		char name[40];
		_snprintf_s(name, sizeof(name), _TRUNCATE, kPlaymat, (unsigned) (GetTickCount() % 16) + 1);
		PlayMusic(name, true, kMusicVolume);   // also stops the startup/lobby loop
	}

	void DoGameEnd(unsigned result)
	{
		g_inGame = false;
		StopMusic();                           // the playmat theme
		if (result == 1)      { if (!PlayJingle(kVictory)) PlayMusic(kLobby, true, kMusicVolume); }
		else if (result == 2) { if (!PlayJingle(kDefeat))  PlayMusic(kLobby, true, kMusicVolume); }
		else                  PlayMusic(kLobby, true, kMusicVolume);
	}

	void StartSfx(const char *name)
	{
		if (g_sfx.size() >= kMaxSfx) return;   // drop rather than pile up
		std::unique_ptr<Stream> s = OpenTrack(name, false, kSfxVolume);
		if (s) g_sfx.push_back(std::move(s));
	}

	void DrainSfx()
	{
		for (;;) {
			std::string name;
			CRITICAL_SECTION *cs = SfxLock();
			EnterCriticalSection(cs);
			const bool any = !g_sfxPending.empty();
			if (any) { name = g_sfxPending.front(); g_sfxPending.erase(g_sfxPending.begin()); }
			LeaveCriticalSection(cs);
			if (!any) break;
			StartSfx(name.c_str());
		}
	}

} // namespace

namespace NMSLoN {

	void MusicPulse(void *lonModule)
	{
		HMODULE lon = (HMODULE) lonModule;

		// Requests came from the relay thread; everything below runs on the render thread.
		const bool begin = InterlockedExchange(&g_reqBegin, 0) != 0;
		const LONG endReq = InterlockedExchange(&g_reqEnd, 0);
		if (begin) DoGameBegin();
		if (endReq) DoGameEnd((unsigned) (endReq - 1));

		DrainSfx();

		// A finished startup/victory/defeat one-shot hands the music back to the lobby.
		if (g_jingle) {
			g_jingle->Pulse();
			if (g_jingle->Finished()) {
				g_jingle->Close();
				g_jingle.reset();
				if (g_jingleActive) {
					g_jingleActive = false;
					PlayMusic(kLobby, true, kMusicVolume);
				}
			}
		}

		if (g_music) {
			g_music->Pulse();
			if (g_music->Finished()) { g_music->Close(); g_music.reset(); }
		}

		for (size_t i = 0; i < g_sfx.size(); ) {
			g_sfx[i]->Pulse();
			if (g_sfx[i]->Finished()) { g_sfx[i]->Close(); g_sfx.erase(g_sfx.begin() + i); }
			else ++i;
		}

		if (lon == g_cardGame) return;
		g_cardGame = lon;
		if (lon) {
			OpenCardGame();
		} else {
			g_inGame = false;
			if (g_jingle) { g_jingle->Close(); g_jingle.reset(); }
			g_jingleActive = false;
			StopMusic();
			for (size_t i = 0; i < g_sfx.size(); ++i) g_sfx[i]->Close();
			g_sfx.clear();
		}
	}

	// Called from the relay's worker thread: post, do not touch the engine.
	void GameMusicBegin()
	{
		InterlockedExchange(&g_reqBegin, 1);
	}

	void GameMusicEnd(unsigned result)
	{
		InterlockedExchange(&g_reqEnd, (LONG) result + 1);
	}

	void SfxPlay(const char *rccName)
	{
		if (!rccName || !*rccName) return;
		CRITICAL_SECTION *cs = SfxLock();
		EnterCriticalSection(cs);
		if (g_sfxPending.size() < kMaxSfxQueued) g_sfxPending.push_back(std::string(rccName));
		LeaveCriticalSection(cs);
	}

} // namespace NMSLoN
