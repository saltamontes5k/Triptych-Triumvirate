// NMS Fabled season — world owner. See Release-NMS-Deploy/FABLED-ENCOUNTERS.md §6.3.
//
// World holds the single authoritative copy of the `fabled_season` row (player DB, id = 1) and
// pushes it to zones as ServerFabledSeason_Struct. Zones never poll: they request it once on boot
// (ServerFabledSeasonUpdate_Struct action 0) and receive a broadcast whenever a GM changes the
// row (action 1) or the world tick expires the season. Zones stop promoting on their own by
// comparing the cached start/end epochs; the tick here is bookkeeping (DB flag + emote) only.
#ifndef EQEMU_WORLD_FABLED_SEASON_H
#define EQEMU_WORLD_FABLED_SEASON_H

#include "../common/types.h"
#include "../common/servertalk.h"
#include "../common/repositories/fabled_season_repository.h"

#include <mutex>

class ZoneServer;

// Threading: HandleZoneUpdate runs on the world network thread (zone connections), while Load /
// Broadcast / Tick run on the main loop. Every public method takes m_mutex; the *Locked privates
// require the caller to hold it.
class WorldFabledSeason {
public:
	static WorldFabledSeason* Instance()
	{
		static WorldFabledSeason instance;
		return &instance;
	}

	// Read the row (seeding the default inactive row if missing) into memory. Called at boot and on
	// every zone-reported change.
	void Load();

	// POD copy of the in-memory row for the wire.
	ServerFabledSeason_Struct ToStruct() const;

	// Send the current state to one zone / to every connected zone.
	void SendTo(ZoneServer *zs);
	void Broadcast();

	// ServerOP_FabledSeasonUpdate from a zone (see servertalk.h for the action values).
	void HandleZoneUpdate(ZoneServer *from, const ServerFabledSeasonUpdate_Struct *u);

	// Once a minute from world/main.cpp: expire the season in the DB when end_epoch passes, and
	// fire the one-time start/end world emotes.
	void Tick();

private:
	WorldFabledSeason() = default;
	~WorldFabledSeason() = default;
	WorldFabledSeason(const WorldFabledSeason&) = delete;
	WorldFabledSeason& operator=(const WorldFabledSeason&) = delete;

	// True when the row says active and the current time is inside [start_epoch, end_epoch).
	bool IsLiveNow(int64 now) const;

	// Internals: m_mutex must be held.
	void LoadLocked();
	ServerFabledSeason_Struct ToStructLocked() const;
	void SendToLocked(ZoneServer *zs);
	void BroadcastLocked();
	void EmoteStart();
	void EmoteEnd();

	FabledSeasonRepository::FabledSeason m_row{};
	mutable std::mutex m_mutex;
	bool  m_loaded          = false;
	bool  m_start_announced = false; // reset whenever Load() sees a different start_epoch
	int64 m_announced_start = 0;     // the start_epoch m_start_announced refers to
};

#endif // EQEMU_WORLD_FABLED_SEASON_H
