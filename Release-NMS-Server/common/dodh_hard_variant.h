#pragma once

#include <array>
#include <cstdint>

namespace DodhHardVariant {

struct Mission {
	uint32_t normal_task;
	uint32_t hard_task;
};

inline constexpr std::array kMissions{
	Mission{920224, 920225}, // Deserting the Ranks
	Mission{920226, 920227}, // The Lost Gnomes
	Mission{920228, 920229}, // The Lost Notebook
	Mission{920230, 920231}, // Cavern Botany
	Mission{920232, 920233}, // The Search for Clues
	Mission{920234, 920235}, // Rescue Cicero!
	Mission{920241, 920259}, // Preemptive Strike
	Mission{920242, 920260}, // The Praetorian Guard
	Mission{920244, 920261}, // Flights of the Seeker
	Mission{920245, 920262}, // Into the Shadows
	Mission{920246, 920256}, // Hides You Seek
	Mission{920247, 920257}, // Sabotage!
	Mission{920248, 920258}, // Spies Like Them
	Mission{920249, 920263}, // The Last Migration
	Mission{920250, 920264}, // Last of the Legion
	Mission{920251, 920265}, // Freeing an Elder
	Mission{920252, 920266}, // The Orb of Subversion
	Mission{920253, 920267}, // A Plea for Help
	Mission{920254, 920268}, // Trailing Longshadow
	Mission{920255, 920269}, // Confronting a Traitor
};

inline constexpr uint32_t NormalTask(uint32_t task)
{
	for (const auto &mission : kMissions) {
		if (mission.hard_task == task) {
			return mission.normal_task;
		}
	}
	return task;
}

inline constexpr uint32_t HardTask(uint32_t normal_task)
{
	for (const auto &mission : kMissions) {
		if (mission.normal_task == normal_task) {
			return mission.hard_task;
		}
	}
	return 0;
}

} // namespace DodhHardVariant
