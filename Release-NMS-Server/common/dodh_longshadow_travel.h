#pragma once

#include <array>
#include <cstdint>

namespace DodhLongshadowTravel {
struct Mission {
	uint32_t task;
	uint32_t zone;
	uint32_t version;
	uint32_t arrival;
	uint32_t outside_zone;
	uint32_t entrance_door;
	uint32_t entrance_switch;
	uint32_t exit_door;
	uint32_t exit_switch;
};

inline constexpr std::array Missions{
	Mission{920251, 354, 1, 0, 358, 16287, 1, 40021, 5},
	Mission{920252, 354, 5, 0, 358, 16287, 1, 40071, 5},
	Mission{920253, 363, 1, 1, 362, 16541, 4, 39249, 1},
	Mission{920254, 362, 1, 0, 358, 0, 0, 0, 0},
	Mission{920255, 363, 3, 0, 362, 16541, 4, 39251, 1},
	Mission{920270, 367, 1, 0, 365, 16617, 2, 39163, 1},
	Mission{920271, 360, 1, 1, 358, 16288, 3, 39133, 1},
	Mission{920272, 355, 1, 1, 354, 16231, 3, 40012, 1},
	Mission{920273, 349, 2, 2, 347, 16616, 20, 40008, 1}
};

inline constexpr const Mission* Find(uint32_t task)
{
	for (const auto &mission : Missions) {
		if (mission.task == task) {
			return &mission;
		}
	}
	return nullptr;
}

inline constexpr bool IsReturn(uint32_t task, uint32_t activity)
{
	return task == 920253 && activity == 4;
}

inline constexpr bool OrbDeath(uint32_t task, uint32_t activity)
{
	return task == 920252 && activity == 1;
}

inline constexpr bool BellfastApproach(uint32_t task, uint32_t activity)
{
	return (task == 920271 || task == 920272) && activity == 0;
}

inline constexpr bool NeranPublicActivity(uint32_t task, uint32_t activity)
{
	return task == 920273 && (activity == 0 || activity == 1);
}

inline constexpr bool OwnsActivity(uint32_t task, uint32_t activity)
{
	const auto *mission = Find(task);
	return (mission && mission->arrival == activity) || BellfastApproach(task, activity) ||
	       NeranPublicActivity(task, activity) || ((task == 920271 || task == 920272) && activity == 2) ||
	       (task == 920273 && activity == 3) || IsReturn(task, activity) || OrbDeath(task, activity) ||
	       (task == 920254 && (activity == 1 || activity == 2)) ||
	       (task == 920255 && (activity == 2 || activity == 3));
}

// Shared scope used by the authored travel/scene queries. Kept here as data only;
// the runtime replay hooks that consume it are not part of this pass.
inline constexpr const char* ScopeJoin =
	" JOIN shared_task_members m ON m.shared_task_id=live.id "
	" JOIN shared_task_dynamic_zones sd ON sd.shared_task_id=live.id "
	" JOIN dynamic_zones dz ON dz.id=sd.dynamic_zone_id AND dz.type=4 "
	" JOIN dynamic_zone_members dm ON dm.dynamic_zone_id=dz.id AND dm.character_id=m.character_id "
	" JOIN instance_list i ON i.id=dz.instance_id ";
} // namespace DodhLongshadowTravel
