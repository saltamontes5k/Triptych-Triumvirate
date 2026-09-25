// #fabled GM command. See Release-NMS-Deploy/FABLED-ENCOUNTERS.md §6.7.
//
// All writes go to the single fabled_season row (player DB, id = 1) and are then pushed through
// world (ZoneFabled::NotifyWorldChanged) so every zone receives the same state. This file never
// touches zone->fabled directly except to read it for `status` and to promote one NPC for `force`.
#include <cstring>
#include <ctime>
#include <iomanip>
#include <sstream>
#include <string>

#include "../client.h"
#include "../zone.h"
#include "../npc.h"
#include "../fabled.h"
#include "../../common/rulesys.h"
#include "../../common/strings.h"
#include "../../common/zone_store.h"
#include "../../common/repositories/fabled_season_repository.h"

namespace {

const char *const kFabledEras[] = { "Classic", "RoK", "SoV", "SoL", "PoP" };

// Client::Message is printf-style; anything that echoes GM-typed text goes through "%s".
void Say(Client *c, uint32 type, const std::string &text)
{
	c->Message(type, "%s", text.c_str());
}

void SendFabledUsage(Client *c)
{
	c->Message(Chat::White, "Usage: #fabled on [scope] [duration] [chance] - Start a season now");
	c->Message(Chat::White, "Usage: #fabled schedule [scope] [YYYY-MM-DD] [YYYY-MM-DD] [chance] - Start/end at server-local midnight (start day inclusive, end day exclusive)");
	c->Message(Chat::White, "Usage: #fabled off - End the season everywhere now");
	c->Message(Chat::White, "Usage: #fabled status - Show the season row and this zone's view of it");
	c->Message(Chat::White, "Usage: #fabled force - Promote the targeted NPC now (must be on the roster; ignores season and chance)");
	c->Message(Chat::White, "  scope: all | era:[Classic|RoK|SoV|SoL|PoP] | zone:[shortname] (default all)");
	c->Message(Chat::White, "  duration: [n]m | [n]h | [n]d | [n]w (default open-ended)");
	c->Message(Chat::White, "  chance: 1-100 (default rule Custom:FabledDefaultChance)");
}

// "all" | "era:<name>" | "zone:<short>" -> kind/value. Returns false and fills error on a bad token.
bool ParseFabledScope(const std::string &token, uint8_t &kind, std::string &value, std::string &error)
{
	if (Strings::EqualFold(token, "all")) {
		kind  = FabledScope_All;
		value = "";
		return true;
	}

	const auto colon = token.find(':');
	if (colon == std::string::npos) {
		error = fmt::format("Bad scope '{}'.", token);
		return false;
	}

	const std::string head = Strings::ToLower(token.substr(0, colon));
	const std::string tail = token.substr(colon + 1);
	if (tail.empty()) {
		error = fmt::format("Scope '{}' has no value.", token);
		return false;
	}

	if (head == "era") {
		for (const char *era : kFabledEras) {
			if (Strings::EqualFold(tail, era)) {
				kind  = FabledScope_Era;
				value = era; // canonical spelling, matches fabled_npcs.era
				return true;
			}
		}
		error = fmt::format("Unknown era '{}'. Use Classic, RoK, SoV, SoL or PoP.", tail);
		return false;
	}

	if (head == "zone") {
		const std::string short_name = Strings::ToLower(tail);
		if (short_name.size() >= 32 || ZoneID(short_name) == 0) {
			error = fmt::format("Unknown zone short name '{}'.", tail);
			return false;
		}
		kind  = FabledScope_Zone;
		value = short_name;
		return true;
	}

	error = fmt::format("Bad scope '{}'. Use all, era:<name> or zone:<shortname>.", token);
	return false;
}

bool IsAllDigits(const std::string &s)
{
	if (s.empty()) {
		return false;
	}
	for (const char ch : s) {
		if (!isdigit(static_cast<unsigned char>(ch))) {
			return false;
		}
	}
	return true;
}

// <digits>[mhdw]. Strings::TimeToSeconds knows s/m/h/d/y but not w, so weeks are handled here.
bool LooksLikeDuration(const std::string &s)
{
	if (s.size() < 2) {
		return false;
	}
	const char unit = static_cast<char>(tolower(static_cast<unsigned char>(s.back())));
	if (unit != 'm' && unit != 'h' && unit != 'd' && unit != 'w') {
		return false;
	}
	return IsAllDigits(s.substr(0, s.size() - 1));
}

int64_t ParseFabledDuration(const std::string &s)
{
	const char unit = static_cast<char>(tolower(static_cast<unsigned char>(s.back())));
	if (unit == 'w') {
		return static_cast<int64_t>(Strings::ToUnsignedInt(s.substr(0, s.size() - 1))) * 7 * 86400;
	}
	return static_cast<int64_t>(Strings::TimeToSeconds(s));
}

// YYYY-MM-DD -> server-local midnight epoch. Returns false on a malformed date.
bool ParseLocalMidnight(const std::string &s, int64_t &out)
{
	if (s.size() != 10 || s[4] != '-' || s[7] != '-') {
		return false;
	}

	std::tm tm{};
	std::istringstream ss(s);
	ss >> std::get_time(&tm, "%Y-%m-%d");
	if (ss.fail()) {
		return false;
	}

	tm.tm_hour  = 0;
	tm.tm_min   = 0;
	tm.tm_sec   = 0;
	tm.tm_isdst = -1; // let the C library decide DST for that local date

	const time_t t = mktime(&tm);
	if (t == static_cast<time_t>(-1)) {
		return false;
	}

	out = static_cast<int64_t>(t);
	return true;
}

std::string FormatLocalTime(int64_t epoch)
{
	if (epoch <= 0) {
		return "open-ended";
	}

	const time_t t   = static_cast<time_t>(epoch);
	const std::tm *l = std::localtime(&t);
	if (!l) {
		return std::to_string(epoch);
	}

	char buf[32];
	if (std::strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M", l) == 0) {
		return std::to_string(epoch);
	}
	return buf;
}

std::string FormatScope(uint8_t kind, const std::string &value)
{
	switch (kind) {
		case FabledScope_Era:
			return fmt::format("era:{}", value);
		case FabledScope_Zone:
			return fmt::format("zone:{}", value);
		default:
			return "all";
	}
}

// Loads the season row, or a fresh id=1 entity if the seed row is missing.
FabledSeasonRepository::FabledSeason LoadSeasonRow()
{
	auto e = FabledSeasonRepository::FindOne(database, 1);
	if (e.id != 1) {
		e           = FabledSeasonRepository::NewEntity();
		e.id        = 1;
		e.loot_tier = 2;
	}
	return e;
}

// Writes the row and tells world to re-read and broadcast. Returns false if the write failed.
bool SaveSeasonRow(Client *c, FabledSeasonRepository::FabledSeason &e)
{
	e.set_by = c->GetCleanName();
	e.set_at = static_cast<int64_t>(std::time(nullptr));

	if (FabledSeasonRepository::ReplaceOne(database, e) == 0) {
		c->Message(Chat::Red, "Failed to write the fabled_season row; nothing was changed.");
		return false;
	}

	ZoneFabled::NotifyWorldChanged(c->GetCleanName());
	return true;
}

} // namespace

void command_fabled(Client *c, const Seperator *sep)
{
	const auto arguments = sep->argnum;
	if (!arguments || !strcasecmp(sep->arg[1], "help")) {
		SendFabledUsage(c);
		return;
	}

	const bool is_on       = !strcasecmp(sep->arg[1], "on");
	const bool is_schedule = !strcasecmp(sep->arg[1], "schedule");
	const bool is_off      = !strcasecmp(sep->arg[1], "off");
	const bool is_status   = !strcasecmp(sep->arg[1], "status");
	const bool is_force    = !strcasecmp(sep->arg[1], "force");
	if (!is_on && !is_schedule && !is_off && !is_status && !is_force) {
		SendFabledUsage(c);
		return;
	}

	const int64_t now = static_cast<int64_t>(std::time(nullptr));

	if (is_on) {
		// on [scope] [duration] [chance] — every token optional, detected by shape.
		uint8_t     scope_kind  = FabledScope_All;
		std::string scope_value;
		int64_t     duration    = 0;
		int         chance      = 0;
		bool        seen_scope = false, seen_duration = false, seen_chance = false;

		for (int i = 2; i <= arguments; ++i) {
			const std::string token = sep->arg[i];
			std::string       error;

			if (Strings::EqualFold(token, "all") || token.find(':') != std::string::npos) {
				if (seen_scope || !ParseFabledScope(token, scope_kind, scope_value, error)) {
					Say(c, Chat::Red, error.empty() ? std::string("Scope given twice.") : error);
					return;
				}
				seen_scope = true;
			} else if (IsAllDigits(token)) {
				chance = Strings::ToInt(token);
				if (seen_chance || chance < 1 || chance > 100) {
					c->Message(Chat::Red, "Chance must be a single value from 1 to 100.");
					return;
				}
				seen_chance = true;
			} else if (LooksLikeDuration(token)) {
				duration = ParseFabledDuration(token);
				if (seen_duration || duration <= 0) {
					c->Message(Chat::Red, "Duration must be a single value like 30m, 6h, 3d or 2w.");
					return;
				}
				seen_duration = true;
			} else {
				Say(c, Chat::Red, fmt::format("Unrecognised token '{}'.", token));
				SendFabledUsage(c);
				return;
			}
		}

		if (!seen_chance) {
			// Read only here, at command time; the live value is stored in the row.
			chance = RuleI(Custom, FabledDefaultChance);
			if (chance < 1 || chance > 100) {
				Say(c, Chat::Red, fmt::format("Rule Custom:FabledDefaultChance is {}; it must be 1-100. Give a chance explicitly.", chance));
				return;
			}
		}

		auto e = LoadSeasonRow();
		e.active      = 1;
		e.start_epoch = now;
		e.end_epoch   = duration > 0 ? now + duration : 0;
		e.scope_kind  = scope_kind;
		e.scope_value = scope_value;
		e.chance      = static_cast<uint8_t>(chance);

		if (!SaveSeasonRow(c, e)) {
			return;
		}

		Say(
			c,
			Chat::Yellow,
			fmt::format(
				"Fabled season started: scope {}, chance {}%, ends {}.",
				FormatScope(e.scope_kind, e.scope_value),
				e.chance,
				e.end_epoch ? FormatLocalTime(e.end_epoch) : "never (open-ended)"
			)
		);
		return;
	}

	if (is_schedule) {
		// schedule [scope] <YYYY-MM-DD> <YYYY-MM-DD> [chance]
		if (arguments < 3) {
			SendFabledUsage(c);
			return;
		}

		int         i          = 2;
		uint8_t     scope_kind = FabledScope_All;
		std::string scope_value;
		std::string error;

		const std::string first = sep->arg[i];
		if (Strings::EqualFold(first, "all") || first.find(':') != std::string::npos) {
			if (!ParseFabledScope(first, scope_kind, scope_value, error)) {
				Say(c, Chat::Red, error);
				return;
			}
			++i;
		}

		if (i + 1 > arguments) {
			c->Message(Chat::Red, "Schedule needs a start date and an end date (YYYY-MM-DD).");
			return;
		}

		int64_t start_epoch = 0, end_epoch = 0;
		if (!ParseLocalMidnight(sep->arg[i], start_epoch)) {
			Say(c, Chat::Red, fmt::format("Bad start date '{}'. Use YYYY-MM-DD.", sep->arg[i]));
			return;
		}
		if (!ParseLocalMidnight(sep->arg[i + 1], end_epoch)) {
			Say(c, Chat::Red, fmt::format("Bad end date '{}'. Use YYYY-MM-DD.", sep->arg[i + 1]));
			return;
		}
		if (end_epoch <= start_epoch) {
			c->Message(Chat::Red, "End date must be after the start date (the end day itself is excluded).");
			return;
		}
		if (end_epoch <= now) {
			c->Message(Chat::Red, "That schedule is already over.");
			return;
		}
		i += 2;

		int chance = 0;
		if (i <= arguments) {
			const std::string token = sep->arg[i];
			chance = IsAllDigits(token) ? Strings::ToInt(token) : 0;
			if (chance < 1 || chance > 100 || i + 1 <= arguments) {
				c->Message(Chat::Red, "Chance must be a single value from 1 to 100 and the last token.");
				return;
			}
		} else {
			chance = RuleI(Custom, FabledDefaultChance);
			if (chance < 1 || chance > 100) {
				Say(c, Chat::Red, fmt::format("Rule Custom:FabledDefaultChance is {}; it must be 1-100. Give a chance explicitly.", chance));
				return;
			}
		}

		auto e = LoadSeasonRow();
		e.active      = 1;
		e.start_epoch = start_epoch;
		e.end_epoch   = end_epoch;
		e.scope_kind  = scope_kind;
		e.scope_value = scope_value;
		e.chance      = static_cast<uint8_t>(chance);

		if (!SaveSeasonRow(c, e)) {
			return;
		}

		Say(
			c,
			Chat::Yellow,
			fmt::format(
				"Fabled season scheduled: scope {}, chance {}%, from {} until {} (local).",
				FormatScope(e.scope_kind, e.scope_value),
				e.chance,
				FormatLocalTime(e.start_epoch),
				FormatLocalTime(e.end_epoch)
			)
		);
		return;
	}

	if (is_off) {
		auto e = LoadSeasonRow();
		if (!e.active) {
			c->Message(Chat::White, "The Fabled season is already off.");
			return;
		}

		e.active    = 0;
		e.end_epoch = now;

		if (!SaveSeasonRow(c, e)) {
			return;
		}

		c->Message(Chat::Yellow, "Fabled season ended. Fableds already up stay until killed or their spawn point cycles.");
		return;
	}

	if (is_status) {
		const auto e = FabledSeasonRepository::FindOne(database, 1);
		if (e.id != 1) {
			c->Message(Chat::Red, "The fabled_season row (id 1) is missing; run the v63 migration.");
		} else {
			Say(
				c,
				Chat::White,
				fmt::format(
					"Season row: {} | scope {} | chance {}% | loot tier {}",
					e.active ? "ACTIVE" : "inactive",
					FormatScope(e.scope_kind, e.scope_value),
					e.chance,
					e.loot_tier
				)
			);

			std::string remaining;
			if (!e.active) {
				remaining = "n/a";
			} else if (e.start_epoch > now) {
				remaining = fmt::format("starts in {}", Strings::SecondsToTime(static_cast<int>(e.start_epoch - now)));
			} else if (e.end_epoch == 0) {
				remaining = "open-ended";
			} else if (e.end_epoch > now) {
				remaining = Strings::SecondsToTime(static_cast<int>(e.end_epoch - now));
			} else {
				remaining = "expired (world will mark it inactive)";
			}

			Say(
				c,
				Chat::White,
				fmt::format(
					"Window: {} -> {} | remaining: {}",
					FormatLocalTime(e.start_epoch),
					FormatLocalTime(e.end_epoch),
					remaining
				)
			);

			Say(
				c,
				Chat::White,
				fmt::format(
					"Set by {} at {}.",
					e.set_by.empty() ? "(nobody)" : e.set_by,
					e.set_at ? FormatLocalTime(e.set_at) : "-"
				)
			);
		}

		const auto &fs = zone->fabled;
		Say(
			c,
			Chat::White,
			fmt::format(
				"This zone ({}): enabled {} | in window {} | eligible {} of {} roster rows | cached scope {} chance {}%",
				zone->GetShortName(),
				fs.Enabled() ? "yes" : "no",
				fs.InWindow(now) ? "yes" : "no",
				fs.EligibleCount(),
				fs.RosterCount(),
				FormatScope(fs.Season().scope_kind, fs.Season().scope_value),
				fs.Season().chance
			)
		);
		return;
	}

	if (is_force) {
		Mob *target = c->GetTarget();
		if (!target || !target->IsNPC()) {
			c->Message(Chat::Red, "Target an NPC first.");
			return;
		}

		NPC *npc = target->CastToNPC();
		if (npc->IsFabled()) {
			Say(c, Chat::White, fmt::format("{} is already Fabled.", npc->GetCleanName()));
			return;
		}

		const FabledNpcRow *row = zone->fabled.Find(npc->GetNPCTypeID());
		if (!row) {
			Say(
				c,
				Chat::Red,
				fmt::format(
					"{} (npc_type {}) is not on the roster for this zone's current scope.",
					npc->GetCleanName(),
					npc->GetNPCTypeID()
				)
			);
			return;
		}

		npc->SetFabled(row);
		npc->ApplyFabled(true);

		Say(
			c,
			Chat::Yellow,
			fmt::format(
				"Promoted {} to {} (level {}).",
				npc->GetOrigName(),
				npc->GetCleanName(),
				npc->GetLevel()
			)
		);
		return;
	}
}
