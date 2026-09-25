// NMS Fabled season — world owner. See Release-NMS-Deploy/FABLED-ENCOUNTERS.md §6.3.
#include "fabled_season.h"

#include "../common/eqemu_logsys.h"
#include "../common/eq_constants.h"
#include "../common/emu_constants.h"
#include "../common/strings.h"
#include "worlddb.h"
#include "zonelist.h"
#include "zoneserver.h"

#include <ctime>
#include <fmt/format.h>

namespace {
	constexpr int32 FABLED_SEASON_ROW_ID = 1;

	const char *const FABLED_EMOTE_START =
		"The memories of Norrath's fabled heroes stir... The Fabled walk the land once more!";
	const char *const FABLED_EMOTE_END =
		"The memories of Norrath's fabled heroes fade back into legend.";
}

bool WorldFabledSeason::IsLiveNow(int64 now) const
{
	if (!m_row.active) {
		return false;
	}

	if (m_row.start_epoch > now) {
		return false;
	}

	if (m_row.end_epoch != 0 && now >= m_row.end_epoch) {
		return false;
	}

	return true;
}

void WorldFabledSeason::Load()
{
	std::lock_guard<std::mutex> guard(m_mutex);
	LoadLocked();
}

void WorldFabledSeason::LoadLocked()
{
	const int64 now = static_cast<int64>(std::time(nullptr));

	auto row = FabledSeasonRepository::FindOne(database, FABLED_SEASON_ROW_ID);
	if (row.id != FABLED_SEASON_ROW_ID) {
		// First boot on this DB (or the row was deleted by hand): seed the documented default.
		auto seed = FabledSeasonRepository::NewEntity();
		seed.id          = FABLED_SEASON_ROW_ID;
		seed.active      = 0;
		seed.start_epoch = 0;
		seed.end_epoch   = 0;
		seed.scope_kind  = FabledScope_All;
		seed.scope_value = "";
		seed.chance      = 50;
		seed.loot_tier   = 2;
		seed.set_by      = "world";
		seed.set_at      = now;

		// InsertOne only reports the auto-increment id; this PK is a fixed 1, so re-read to confirm.
		FabledSeasonRepository::InsertOne(database, seed);
		row = FabledSeasonRepository::FindOne(database, FABLED_SEASON_ROW_ID);

		if (row.id != FABLED_SEASON_ROW_ID) {
			LogError("[Fabled] Could not read or seed fabled_season row id [{}]; season stays inactive in memory", FABLED_SEASON_ROW_ID);
			row = seed;
		}
		else {
			LogInfo("[Fabled] Seeded default fabled_season row (inactive, chance [{}], loot_tier [{}])", seed.chance, seed.loot_tier);
		}
	}

	const bool start_changed = (row.start_epoch != m_announced_start);

	m_row = row;

	if (start_changed) {
		m_announced_start = m_row.start_epoch;
		// A season that was already running when world came up was announced by a previous
		// process; do not repeat it. Any other new start_epoch is announced by HandleZoneUpdate
		// (if it is already in the past) or by Tick (once it arrives).
		m_start_announced = (!m_loaded && m_row.start_epoch <= now);
	}

	m_loaded = true;

	LogInfo(
		"[Fabled] Season loaded: active [{}] start [{}] end [{}] scope_kind [{}] scope_value [{}] chance [{}] loot_tier [{}] set_by [{}]",
		m_row.active,
		m_row.start_epoch,
		m_row.end_epoch,
		m_row.scope_kind,
		m_row.scope_value,
		m_row.chance,
		m_row.loot_tier,
		m_row.set_by
	);
}

ServerFabledSeason_Struct WorldFabledSeason::ToStruct() const
{
	std::lock_guard<std::mutex> guard(m_mutex);
	return ToStructLocked();
}

ServerFabledSeason_Struct WorldFabledSeason::ToStructLocked() const
{
	ServerFabledSeason_Struct s{};

	s.active      = m_row.active ? 1 : 0;
	s.scope_kind  = m_row.scope_kind;
	s.chance      = m_row.chance;
	s.loot_tier   = m_row.loot_tier;
	s.start_epoch = m_row.start_epoch;
	s.end_epoch   = m_row.end_epoch;
	strn0cpy(s.scope_value, m_row.scope_value.c_str(), sizeof(s.scope_value));

	return s;
}

void WorldFabledSeason::SendTo(ZoneServer *zs)
{
	std::lock_guard<std::mutex> guard(m_mutex);
	SendToLocked(zs);
}

void WorldFabledSeason::SendToLocked(ZoneServer *zs)
{
	if (!zs) {
		return;
	}

	auto pack = new ServerPacket(ServerOP_FabledSeason, sizeof(ServerFabledSeason_Struct));
	*reinterpret_cast<ServerFabledSeason_Struct *>(pack->pBuffer) = ToStructLocked();
	zs->SendPacket(pack);
	safe_delete(pack);
}

void WorldFabledSeason::Broadcast()
{
	std::lock_guard<std::mutex> guard(m_mutex);
	BroadcastLocked();
}

void WorldFabledSeason::BroadcastLocked()
{
	auto pack = new ServerPacket(ServerOP_FabledSeason, sizeof(ServerFabledSeason_Struct));
	*reinterpret_cast<ServerFabledSeason_Struct *>(pack->pBuffer) = ToStructLocked();
	ZSList::Instance()->SendPacket(pack);
	safe_delete(pack);
}

void WorldFabledSeason::EmoteStart()
{
	ZSList::Instance()->SendEmoteMessageRaw(0, 0, AccountStatus::Player, Chat::Yellow, FABLED_EMOTE_START);
	m_start_announced = true;
}

void WorldFabledSeason::EmoteEnd()
{
	ZSList::Instance()->SendEmoteMessageRaw(0, 0, AccountStatus::Player, Chat::Yellow, FABLED_EMOTE_END);
}

void WorldFabledSeason::HandleZoneUpdate(ZoneServer *from, const ServerFabledSeasonUpdate_Struct *u)
{
	if (!u) {
		return;
	}

	// One lock for the whole action: the row read, the broadcast, and the announce flags must be
	// observed atomically against Tick() on the main loop.
	std::lock_guard<std::mutex> guard(m_mutex);

	switch (u->action) {
		case 0: {
			// Zone boot: reply to that zone only.
			if (!m_loaded) {
				LoadLocked();
			}
			SendToLocked(from);
			break;
		}
		case 1: {
			// A GM changed the row from a zone: re-read, push everywhere, announce the transition.
			const int64 now      = static_cast<int64>(std::time(nullptr));
			const bool  was_live = IsLiveNow(now);

			LoadLocked();

			LogInfo(
				"[Fabled] Season changed by [{}] from zone [{}] ({}) instance [{}]: active [{}] start [{}] end [{}] scope_kind [{}] scope_value [{}] chance [{}]",
				u->set_by,
				from ? from->GetZoneName() : "unknown",
				from ? from->GetZoneID() : 0,
				from ? from->GetInstanceID() : 0,
				m_row.active,
				m_row.start_epoch,
				m_row.end_epoch,
				m_row.scope_kind,
				m_row.scope_value,
				m_row.chance
			);

			BroadcastLocked();

			const bool is_live = IsLiveNow(now);
			if (is_live && !was_live) {
				EmoteStart();
			}
			else if (!is_live && was_live) {
				EmoteEnd();
			}
			else if (is_live) {
				// Re-configured mid-season (e.g. chance changed, start_epoch rewritten): already
				// announced, so Tick() must not repeat it.
				m_start_announced = true;
			}
			// active with start_epoch in the future: Tick() announces when the start arrives.
			break;
		}
		default: {
			LogError("[Fabled] Unknown ServerFabledSeasonUpdate action [{}] from zone [{}]", u->action, from ? from->GetZoneID() : 0);
			break;
		}
	}
}

void WorldFabledSeason::Tick()
{
	std::lock_guard<std::mutex> guard(m_mutex);

	if (!m_loaded || !m_row.active) {
		return;
	}

	const int64 now = static_cast<int64>(std::time(nullptr));

	// Expiry: zones already stopped promoting via their own time compare; this only flips the DB
	// flag so `#fabled status` and the next boot agree, then tells everyone.
	if (m_row.end_epoch != 0 && now >= m_row.end_epoch) {
		m_row.active = 0;
		m_row.set_by = "world (expired)";
		m_row.set_at = now;

		if (!FabledSeasonRepository::UpdateOne(database, m_row)) {
			LogError("[Fabled] Failed to write active=0 to fabled_season after end_epoch [{}] passed", m_row.end_epoch);
		}

		LogInfo("[Fabled] Season expired at [{}] (end_epoch [{}])", now, m_row.end_epoch);
		BroadcastLocked();

		// Only announce the end of a season that actually began.
		if (m_row.start_epoch <= now) {
			EmoteEnd();
		}
		return;
	}

	// Scheduled start arrived while world was running.
	if (!m_start_announced && m_row.start_epoch > 0 && now >= m_row.start_epoch) {
		LogInfo("[Fabled] Scheduled season started (start_epoch [{}])", m_row.start_epoch);
		EmoteStart();
	}
}
