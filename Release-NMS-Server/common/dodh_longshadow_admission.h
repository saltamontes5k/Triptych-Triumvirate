#pragma once

// EQS adaptation of the authored Longshadow (Stoneroot) shared-task admission
// gate. The completion-archive chain is read from the completion tables EQS
// already ships; no row means the prerequisite mission is not proven and the
// request is denied. Hard variants are credited to their normal mission.

#include "dodh_hard_variant.h"
#include "dodh_admission_support.h"

#include <algorithm>
#include <array>
#include <cstdint>

namespace DodhLongshadowAdmission {
constexpr uint32_t Freeing = 920251;
constexpr uint32_t Orb = 920252;
constexpr uint32_t Plea = 920253;
constexpr uint32_t Trailing = 920254;
constexpr uint32_t Traitor = 920255;
constexpr uint32_t Dustspirit = 358123;
constexpr uint32_t DustspiritSpawn = 102235;
constexpr uint32_t Stoneroot = 358;

inline constexpr bool Managed(uint32_t task)
{
	return task >= Freeing && task <= Traitor;
}

inline constexpr bool Requester(uint32_t zone, uint32_t version, uint32_t instance, uint32_t type, uint32_t spawn)
{
	return zone == Stoneroot && version == 0 && instance == 0 &&
	       type == Dustspirit && spawn == DustspiritSpawn;
}

inline bool EarnedPrerequisites(Database &db, uint32_t task, uint32_t requester)
{
	if (!Managed(task) || !requester) {
		return false;
	}
	if (task == Freeing) {
		return true;
	}

	auto completed = db.QueryDatabase(fmt::format(
		"SELECT DISTINCT c.task_id FROM completed_shared_tasks c "
		"JOIN completed_shared_task_members m ON m.shared_task_id=c.id "
		"WHERE m.character_id={} AND c.completion_time IS NOT NULL "
		"AND UNIX_TIMESTAMP(c.completion_time)>0 AND c.task_id IN ({},{},{},{},{},{},{},{})",
		requester, Freeing, Orb, Plea, Trailing, DodhHardVariant::HardTask(Freeing),
		DodhHardVariant::HardTask(Orb), DodhHardVariant::HardTask(Plea),
		DodhHardVariant::HardTask(Trailing)), false);
	if (!completed.Success()) {
		return false;
	}

	std::array<bool, Traitor - Freeing> earned{};
	for (auto row : completed) {
		const auto id = DodhAdmissionSupport::ParseNumber(row[0]);
		if (!id || *id > UINT32_MAX) {
			return false;
		}
		const auto normal = DodhHardVariant::NormalTask(uint32_t(*id));
		if (normal < Freeing || normal >= Traitor) {
			return false;
		}
		earned[normal - Freeing] = true;
	}
	return std::all_of(earned.begin(), earned.begin() + (task - Freeing), [](bool value) { return value; });
}
} // namespace DodhLongshadowAdmission
