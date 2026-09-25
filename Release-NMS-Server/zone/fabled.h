/*
 * NMS Fabled season — zone-side cache and spawn-time promotion.
 *
 * Design: Release-NMS-Deploy/FABLED-ENCOUNTERS.md §6.
 *
 * Contract (do not change signatures without updating every user):
 *   - World owns the season (fabled_season row). Zones receive ServerFabledSeason_Struct on boot
 *     (after RequestFromWorld()) and on every change. Zones never poll and never read the row.
 *   - The roster (fabled_npcs, content DB) is loaded once at zone boot and on #reload fabled.
 *   - Hot path is Roll(): one bool when the season is off; otherwise time compare + hash probe.
 *   - No per-spawn DB access, no allocation on the hot path.
 */
#ifndef EQEMU_ZONE_FABLED_H
#define EQEMU_ZONE_FABLED_H

#include <cstdint>
#include <string>
#include <unordered_map>

#include "../common/servertalk.h"

class NPC;

struct FabledNpcRow {
	uint32_t    npc_id             = 0;
	std::string era;                          // Classic | RoK | SoV | SoL | PoP
	uint8_t     level              = 0;       // absolute target level, clamped to Character:MaxLevel at load
	float       hp_mult            = -1.0f;   // < 0 → derive from level delta (FabledDefaults)
	float       min_hit_mult       = -1.0f;
	float       max_hit_mult       = -1.0f;
	uint32_t    npc_spells_id      = 0;       // 0 → keep the NPC's own
	std::string special_abilities_append;     // appended to npc_types.special_abilities, may be empty
	uint8_t     chance             = 0;       // 0 → use season chance
	bool        enabled            = true;
};

// Derivation constants used when a row leaves a multiplier < 0. One place to tune.
namespace FabledDefaults {
	constexpr float HpPerLevel  = 0.35f; // hp_mult  = 1 + HpPerLevel  * delta
	constexpr float HitPerLevel = 0.15f; // hit_mult = 1 + HitPerLevel * delta
	constexpr char  NamePrefix[] = "The_Fabled_";
}

struct FabledSeasonState {
	bool        active      = false;
	uint8_t     scope_kind  = FabledScope_All;
	std::string scope_value;
	uint8_t     chance      = 50;
	uint8_t     loot_tier   = 2;
	int64_t     start_epoch = 0;
	int64_t     end_epoch   = 0;              // 0 = open-ended
};

class ZoneFabled {
public:
	// Boot / reload
	void LoadRoster();                                   // content_db → m_roster (all enabled rows), then RebuildEligible()
	void LoadSeasonFromDatabase();                       // boot only: one read of fabled_season so the first spawns do not race world's reply
	void ApplySeason(const ServerFabledSeason_Struct &s);// store season, recompute m_enabled and m_eligible
	void RequestFromWorld();                             // send ServerOP_FabledSeasonUpdate action=0
	static void NotifyWorldChanged(const char *set_by);  // send ServerOP_FabledSeasonUpdate action=1 after writing fabled_season

	// Hot path — called from Spawn2::Process before AddLootTable(). Returns the row when this spawn
	// is promoted, nullptr otherwise. Performs: enabled → time window → eligibility → chance roll.
	const FabledNpcRow *Roll(uint32_t npc_type_id) const;

	// Cold paths
	const FabledNpcRow *Find(uint32_t npc_type_id) const; // whole enabled roster, ignores season/scope (resume path, #fabled force)
	bool                Enabled() const { return m_enabled; }
	bool                InWindow(int64_t now) const;      // start <= now < end (end 0 = open)
	const FabledSeasonState &Season() const { return m_season; }
	size_t              EligibleCount() const { return m_eligible.size(); }
	size_t              RosterCount() const { return m_roster.size(); }

private:
	void RebuildEligible();                              // m_roster filtered by scope (era) → m_eligible

	FabledSeasonState                          m_season;
	bool                                       m_enabled = false; // season.active && scope matches this zone
	std::unordered_map<uint32_t, FabledNpcRow> m_roster;          // every enabled fabled_npcs row
	std::unordered_map<uint32_t, const FabledNpcRow *> m_eligible; // subset after scope filter; hot-path map
};

#endif // EQEMU_ZONE_FABLED_H
