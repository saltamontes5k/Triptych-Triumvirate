// NMS Fabled season — zone implementation. See fabled.h and FABLED-ENCOUNTERS.md §6.
#include "fabled.h"

#include <algorithm>
#include <cstring>
#include <ctime>

#include "../common/global_define.h"
#include "../common/eqemu_logsys.h"
#include "../common/rulesys.h"
#include "../common/strings.h"
#include "../common/repositories/fabled_npcs_repository.h"
#include "../common/repositories/fabled_season_repository.h"

#include "worldserver.h"
#include "zone.h"
#include "zonedb.h"

extern Zone        *zone;
extern WorldServer  worldserver;

void ZoneFabled::LoadRoster()
{
	// Live NPCs keep a raw pointer to their roster row (NPC::GetFabledRow). unordered_map only
	// invalidates element addresses on erase, so a reload never erases: rows missing from the new
	// result set are disabled in place and dropped from m_eligible instead.
	for (auto &kv: m_roster) {
		kv.second.enabled = false;
	}

	const auto max_level = static_cast<uint8_t>(std::clamp<int>(RuleI(Character, MaxLevel), 1, 255));

	const auto rows = FabledNpcsRepository::GetWhere(content_db, "enabled = 1");
	m_roster.reserve(rows.size());

	for (const auto &e: rows) {
		FabledNpcRow &r = m_roster[e.npc_id];
		r.npc_id                   = e.npc_id;
		r.era                      = e.era;
		r.level                    = std::min<uint8_t>(e.level, max_level);
		r.hp_mult                  = e.hp_mult;
		r.min_hit_mult             = e.min_hit_mult;
		r.max_hit_mult             = e.max_hit_mult;
		r.npc_spells_id            = e.npc_spells_id;
		r.special_abilities_append = e.special_abilities_append;
		r.chance                   = e.chance;
		r.enabled                  = e.enabled != 0;
	}

	RebuildEligible();

	LogInfo("Loaded [{}] fabled roster rows, [{}] eligible in this zone", rows.size(), m_eligible.size());
}

void ZoneFabled::ApplySeason(const ServerFabledSeason_Struct &s)
{
	// scope_value is a fixed 32-byte field that may arrive without a terminator
	char scope_value[sizeof(s.scope_value) + 1];
	memcpy(scope_value, s.scope_value, sizeof(s.scope_value));
	scope_value[sizeof(s.scope_value)] = 0;

	m_season.active      = s.active != 0;
	m_season.scope_kind  = s.scope_kind;
	m_season.scope_value = scope_value;
	m_season.chance      = s.chance;
	m_season.loot_tier   = s.loot_tier;
	m_season.start_epoch = s.start_epoch;
	m_season.end_epoch   = s.end_epoch;

	m_enabled = m_season.active;
	if (m_enabled && m_season.scope_kind == FabledScope_Zone) {
		m_enabled = zone && Strings::EqualFold(m_season.scope_value, zone->GetShortName());
	}

	RebuildEligible();

	LogSpawns(
		"Fabled season applied: active [{}] scope_kind [{}] scope_value [{}] chance [{}] loot_tier [{}] start [{}] end [{}] -> enabled here [{}] eligible [{}]",
		m_season.active,
		m_season.scope_kind,
		m_season.scope_value,
		m_season.chance,
		m_season.loot_tier,
		m_season.start_epoch,
		m_season.end_epoch,
		m_enabled,
		m_eligible.size()
	);
}

void ZoneFabled::RebuildEligible()
{
	m_eligible.clear();

	const bool era_scoped = m_season.scope_kind == FabledScope_Era;

	for (const auto &[npc_id, row]: m_roster) {
		if (!row.enabled) {
			continue;
		}
		if (era_scoped && !Strings::EqualFold(row.era, m_season.scope_value)) {
			continue;
		}
		m_eligible[npc_id] = &row;
	}
}

void ZoneFabled::RequestFromWorld()
{
	auto pack = new ServerPacket(ServerOP_FabledSeasonUpdate, sizeof(ServerFabledSeasonUpdate_Struct));
	auto *u   = reinterpret_cast<ServerFabledSeasonUpdate_Struct *>(pack->pBuffer);

	u->action = 0;
	u->set_by[0] = 0;

	worldserver.SendPacket(pack);
	safe_delete(pack);
}

void ZoneFabled::NotifyWorldChanged(const char *set_by)
{
	auto pack = new ServerPacket(ServerOP_FabledSeasonUpdate, sizeof(ServerFabledSeasonUpdate_Struct));
	auto *u   = reinterpret_cast<ServerFabledSeasonUpdate_Struct *>(pack->pBuffer);

	u->action = 1;
	strn0cpy(u->set_by, set_by ? set_by : "", sizeof(u->set_by));

	worldserver.SendPacket(pack);
	safe_delete(pack);
}

bool ZoneFabled::InWindow(int64_t now) const
{
	return now >= m_season.start_epoch && (m_season.end_epoch == 0 || now < m_season.end_epoch);
}

// Hot path. Cost when the season is off: one bool.
const FabledNpcRow *ZoneFabled::Roll(uint32_t npc_type_id) const
{
	if (!m_enabled) {
		return nullptr;
	}

	if (!InWindow(static_cast<int64_t>(std::time(nullptr)))) {
		return nullptr;
	}

	const auto it = m_eligible.find(npc_type_id);
	if (it == m_eligible.end()) {
		return nullptr;
	}

	const FabledNpcRow *row    = it->second;
	const int           chance = row->chance ? row->chance : m_season.chance;

	if (zone->random.Int(1, 100) > chance) {
		return nullptr;
	}

	return row;
}

// Cold path. Searches the whole enabled roster, not the scope-filtered set: a resumed Fabled must
// stay Fabled even if the scope changed while the zone was suspended, and #fabled force is a test
// tool that deliberately ignores the season.
const FabledNpcRow *ZoneFabled::Find(uint32_t npc_type_id) const
{
	const auto it = m_roster.find(npc_type_id);
	if (it == m_roster.end() || !it->second.enabled) {
		return nullptr;
	}
	return &it->second;
}

// Boot only. World is the owner, but it writes fabled_season before every broadcast, so the row is
// always at least as new as world's memory. Reading it once here closes the window between a zone's
// first Spawn2::Process tick and the arrival of world's reply to RequestFromWorld().
void ZoneFabled::LoadSeasonFromDatabase()
{
	const auto e = FabledSeasonRepository::FindOne(database, 1);
	if (e.id != 1) {
		LogInfo("No fabled_season row yet; season stays inactive until world replies");
		return;
	}

	ServerFabledSeason_Struct s{};
	s.active      = e.active != 0 ? 1 : 0;
	s.scope_kind  = e.scope_kind;
	s.chance      = e.chance;
	s.loot_tier   = e.loot_tier;
	s.start_epoch = e.start_epoch;
	s.end_epoch   = e.end_epoch;
	strn0cpy(s.scope_value, e.scope_value.c_str(), sizeof(s.scope_value));

	ApplySeason(s);
}
