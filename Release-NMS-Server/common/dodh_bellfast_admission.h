#pragma once

// EQS adaptation of the authored Bellfast (Corathus) shared-task admission
// gate. Both earned-prerequisite queries read tables EQS already ships; a
// missing faction row or missing completion archive denies the request.

#include "dodh_admission_support.h"

#include <cstdint>
#include <vector>

namespace DodhBellfastAdmission {

inline constexpr uint32_t Mines = 920270;
inline constexpr uint32_t Caverns = 920271;
inline constexpr uint32_t Korlach = 920273;
inline constexpr uint32_t Bellfast = 365286;
inline constexpr uint32_t Spawn = 103435;
inline constexpr uint32_t Corathus = 365;
inline constexpr uint32_t Expedition = 1050;
inline constexpr int MinimumFaction = 200;
inline constexpr int MinimumAverageLevel = 68;

inline constexpr bool Managed(uint32_t task)
{
	return task >= Mines && task <= Korlach;
}

inline constexpr bool Requester(uint32_t zone_id, uint32_t version, uint32_t instance,
                                uint32_t npc_type, uint32_t spawn)
{
	return zone_id == Corathus && !version && !instance && npc_type == Bellfast && spawn == Spawn;
}

inline bool EarnedPrerequisites(Database &db, uint32_t task, uint32_t requester)
{
	if (!Managed(task) || !requester) {
		return false;
	}

	const auto faction = db.QueryDatabase(fmt::format(
		"SELECT 1 FROM faction_values WHERE char_id={} AND faction_id={} AND current_value>={}",
		requester, Expedition, MinimumFaction), false);
	if (!faction.Success() || faction.RowCount() != 1) {
		return false;
	}

	// The documented 68+ Mines offer follows 68+ Caverns. Keep the chain
	// acyclic and use only the requester's acknowledged completion archive.
	if (task != Mines) {
		return true;
	}

	const auto archived = db.QueryDatabase(fmt::format(
		"SELECT 1 FROM completed_shared_tasks occurrence "
		"JOIN completed_shared_task_members member ON member.shared_task_id=occurrence.id "
		"WHERE member.character_id={} AND occurrence.task_id={} "
		"AND UNIX_TIMESTAMP(occurrence.completion_time)>0 LIMIT 1",
		requester, Caverns), false);
	return archived.Success() && archived.RowCount() == 1;
}

inline bool MinimumAverageLevelMet(Database &db, const std::vector<uint32_t> &character_ids)
{
	return DodhAdmissionSupport::MeetsAverageLevel(db, MinimumAverageLevel, character_ids);
}

} // namespace DodhBellfastAdmission
