#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace EQ::RewardSelection {

enum class Source : uint8_t {
	Unknown     = 0,
	Achievement = 1,
	Task        = 2,
	General     = 3
};

enum class RewardType : uint8_t {
	Item                 = 0,
	Experience           = 1,
	AlternateAdvancement = 2,
	Copper               = 3,
	AlternateCurrency    = 4,
	Title                = 5
};

enum class ExperienceMode : uint32_t {
	Default    = 0,
	NormalOnly = 1
};

struct Reward {
	uint64_t    entry_id = 0;
	RewardType  type = RewardType::Item;
	uint32_t    data_id = 0;
	uint64_t    amount = 0;
	std::string description;
};

struct Option {
	uint32_t            option_id = 0;
	uint32_t            wire_option_id = 0;
	uint32_t            sequence = 0;
	std::string         label;
	bool                common_to_all = false;
	uint8_t             flags = 0;
	// Bitmask of player classes that may see/claim this option. 0xFFFF is "any".
	uint32_t            class_mask = 65535;
	std::vector<Reward> rewards;
};

// Content eligibility uses the character's permanent class bits, never a shroud
// class. A triple-class character carries the union of its three class bits, so
// an option is eligible when any one of those classes is in its mask.
inline bool OptionEligibleForClass(const Option &option, uint32_t character_classes)
{
	return character_classes != 0 && (option.class_mask & character_classes) != 0;
}

struct Set {
	uint32_t            reward_set_id = 0;
	std::string         title;
	std::vector<Option> options;
};

// RoF2 uses UINT32_MAX for a claim when the option list has no selectable rows.
// Reserve this nonzero token for durable, authenticated common-only claims.
inline constexpr uint32_t CommonOnlySelection = UINT32_MAX;

inline bool IsCommonOnly(const Set &set)
{
	if (set.options.empty()) {
		return false;
	}
	for (const auto &option : set.options) {
		if (!option.common_to_all) {
			return false;
		}
	}
	return true;
}

inline bool ValidCanonicalSelection(const Set &set, uint32_t id)
{
	if (IsCommonOnly(set)) {
		return id == CommonOnlySelection;
	}
	if (!id || id == CommonOnlySelection) {
		return false;
	}
	for (const auto &option : set.options) {
		if (!option.common_to_all && option.option_id == id) {
			return true;
		}
	}
	return false;
}

// Authenticate channel, pending ID, set ID and session before calling.
// The set must already be filtered for this character's eligibility.
inline uint32_t ResolveWireSelection(const Set &set, uint32_t wire_id)
{
	if (IsCommonOnly(set)) {
		return wire_id == CommonOnlySelection ? CommonOnlySelection : 0;
	}
	if (!wire_id || wire_id == CommonOnlySelection) {
		return 0;
	}
	for (const auto &option : set.options) {
		if (!option.common_to_all && option.wire_option_id == wire_id) {
			return option.option_id;
		}
	}
	return 0;
}

// Both RoF2 reward-manager opcodes use this action field.
enum class Action : uint32_t {
	List = 0,
	InspectItem = 1,
	Claim = 3,
	TaskView = 4,
	AchievementView = 5,
	Pending = 6,
	Bulk = 7
};

} // namespace EQ::RewardSelection
