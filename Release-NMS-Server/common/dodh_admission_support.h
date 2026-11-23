#pragma once

// EQS-native helpers for the authored Depths of Darkhollow shared-task
// admission gates. EQS has no shared_task_admission.h / shared_task_average.h,
// so the small amount of shared parsing and group-average logic lives here.
// Every helper fails closed: an absent row, a failed query, or malformed data
// can never be read as "eligible".

#include "database.h"

#include <charconv>
#include <cstdint>
#include <fmt/format.h>
#include <optional>
#include <set>
#include <string>
#include <string_view>
#include <vector>

namespace DodhAdmissionSupport {

// Strict unsigned parse. NULL, empty, partial and negative values are rejected.
inline std::optional<uint64_t> ParseNumber(const char *value)
{
	if (!value || !*value) {
		return std::nullopt;
	}

	const std::string_view text(value);
	uint64_t number = 0;
	const auto result = std::from_chars(text.data(), text.data() + text.size(), number);
	if (result.ec != std::errc{} || result.ptr != text.data() + text.size()) {
		return std::nullopt;
	}
	return number;
}

// Fresh database levels cover offline members. A missing, duplicate, zero-id
// or unreadable member can never establish an average, so the caller denies.
inline bool MeetsAverageLevel(Database &db, uint32_t minimum, const std::vector<uint32_t> &ids)
{
	if (minimum < 1 || minimum > 255 || ids.empty()) {
		return false;
	}

	const std::set<uint32_t> unique(ids.begin(), ids.end());
	if (unique.size() != ids.size() || unique.count(0)) {
		return false;
	}

	std::string list;
	for (size_t i = 0; i < ids.size(); ++i) {
		if (i) {
			list += ',';
		}
		list += std::to_string(ids[i]);
	}

	auto rows = db.QueryDatabase(fmt::format(
		"SELECT COUNT(*),COUNT(level),SUM(level),MIN(level),MAX(level) "
		"FROM character_data WHERE id IN ({})", list), false);
	if (!rows.Success() || rows.RowCount() != 1) {
		return false;
	}

	auto row = rows.begin();
	const auto count = ParseNumber(row[0]);
	const auto known = ParseNumber(row[1]);
	const auto total = ParseNumber(row[2]);
	const auto low   = ParseNumber(row[3]);
	const auto high  = ParseNumber(row[4]);
	if (!count || !known || !total || !low || !high || *count != ids.size() || *known != *count ||
	    *low < 1 || *high > 255 || *total < *count) {
		return false;
	}

	return *total >= *count * minimum;
}

} // namespace DodhAdmissionSupport
