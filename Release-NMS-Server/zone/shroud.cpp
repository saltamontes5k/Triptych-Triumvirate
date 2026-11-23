/*	EQEmu: Everquest Server Emulator
	Copyright (C) 2001-2024 EQEmu Development Team (http://eqemulator.net)

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; version 2 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY except by those people which sell it, which
	are required to give you total support for your newly bought product;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR
	A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#include "../common/global_define.h"
#include "../common/classes.h"
#include "../common/eqemu_logsys.h"
#include "../common/eq_constants.h"
#include "../common/eq_packet_structs.h"
#include "../common/memory_buffer.h"
#include "../common/races.h"
#include "../common/rulesys.h"
#include "../common/strings.h"
#include "../common/shroud/wire.h"

#include <fmt/format.h>

#include <cstring>
#include <string>
#include <vector>

#include "aa.h"
#include "client.h"
#include "entity.h"
#include "merc.h"
#include "mob.h"
#include "zone.h"
#include "zonedb.h"

extern Zone* zone;

namespace {

// NMS: shroud flow diagnostics. 0 = compile out all shroud runtime logging
// (leave 0 for release builds).
#ifndef NMS_SHROUD_DIAG
#define NMS_SHROUD_DIAG 0
#endif

#if NMS_SHROUD_DIAG
static void ShroudDiag(const char *fmt, ...) {
  FILE *f = fopen("C:\\EQS\\shroud_dump\\server_shroud.log", "a");
  if (!f)
    return;
  SYSTEMTIME st;
  GetLocalTime(&st);
  fprintf(f, "[%02d:%02d:%02d.%03d] ", st.wHour, st.wMinute, st.wSecond,
          st.wMilliseconds);
  va_list args;
  va_start(args, fmt);
  vfprintf(f, fmt, args);
  va_end(args);
  fprintf(f, "\n");
  fclose(f);
}
#else
#define ShroudDiag(...) ((void)0)
#endif

} // namespace (file-local diag helpers above)

// A form change is a same-zone reload, not a transform packet: the client
// leaves and re-enters, and Handle_Connect_OP_ZoneEntry applies the shroud state
// to m_pp BEFORE serializing the zone-in profile, so the form (or the restored
// real character) is what the client builds from.
//
// Why the safe-coords mode: the RoF2 client IGNORES a same-zone ZoneSolicited
// change — it assumes it is already there and never reconnects (observed live:
// request sent, client keeps playing). The safe-coords mode is the one it
// answers: it reports "unknown zone", the server resolves that to the current
// zone, and the client does a real zone-in. The price is that this mode lands
// the player on the zone's safe point, so stash the current spot first and let
// the zone-in path put it back (ShroudReturnPos bucket).
void Client::ReloadForShroudTransition(const char* why)
{
	// Quest-driven applies (the monster-mission controllers) can fire from a
	// spawn poll while the client is still connecting. Zoning then would race
	// the connect, so leave the state applied and let the caller's next poll
	// retry the transition.
	if (!Connected()) {
		LogInfo("Client [{}] shroud transition reload deferred: not connected yet ({})",
			GetCleanName(), why ? why : "form change");
		return;
	}

	SetBucket("ShroudReturnPos", fmt::format("{:.2f},{:.2f},{:.2f},{:.2f},{}",
		GetX(), GetY(), GetZ(), GetHeading(), static_cast<uint64_t>(std::time(nullptr))));

	LogInfo("Client [{}] shroud transition reload ({}) at ({:.2f}, {:.2f}, {:.2f})",
		GetCleanName(), why ? why : "form change", GetX(), GetY(), GetZ());

	// Exactly upstream's call (nsqemu client_spirit_shroud.cpp:733):
	//   MovePC(zone->GetZoneID(), zone->GetInstanceID(), x, y, z, heading, 1, EvacToSafeCoords)
	// The evac branch is the only zone-change the RoF2 client actually obeys for
	// a same-zone transfer: it sends a decoy zone id (1, or 2 when in zone 1)
	// precisely because the client ignores a request naming the zone it is
	// already in. ZoneSolicited and ZoneToSafeCoords both name the current zone
	// and were both observed to do nothing (no reconnect, no profile reload).
	MovePC(zone->GetZoneID(), GetInstanceID(), GetX(), GetY(), GetZ(), GetHeading(), 1,
		ZoneMode::EvacToSafeCoords);
}

namespace { // resume file-local helpers

// A single shroud form as authored in the `shrouds` table.
struct ShroudDefinition {
	uint32      id             = 0;
	std::string name;
	std::string progression    = "Shrouds";
	std::string branch         = "General";
	uint8       level          = 1;
	uint16      race           = 0;
	uint8       gender         = 2;
	uint8       class_id       = Class::Warrior;
	uint8       texture        = UINT8_MAX;
	uint8       helmet_texture = UINT8_MAX;
	float       size           = -1.0f;
	int32       hp             = 0;
	int32       mana           = 0;
	int32       endurance      = 0;
};

const char* SafeCol(const char* value, const char* fallback = "")
{
	return value ? value : fallback;
}

bool LoadShroud(uint32 shroud_id, ShroudDefinition& out)
{
	const std::string query = fmt::format(
		"SELECT `id`, `name`, `progression`, `branch`, `level`, `race`, `gender`, `class`, "
		"`texture`, `helmet_texture`, `size`, `hp`, `mana`, `endurance` "
		"FROM `shrouds` WHERE `id` = {} LIMIT 1",
		shroud_id
	);

	auto results = content_db.QueryDatabase(query);
	if (!results.Success() || results.RowCount() == 0) {
		return false;
	}

	auto row = results.begin();
	out.id             = Strings::ToUnsignedInt(row[0]);
	out.name           = SafeCol(row[1]);
	out.progression    = SafeCol(row[2], "Shrouds");
	out.branch         = SafeCol(row[3], "General");
	out.level          = static_cast<uint8>(Strings::ToInt(row[4], 1));
	out.race           = static_cast<uint16>(Strings::ToInt(row[5], 0));
	out.gender         = static_cast<uint8>(Strings::ToInt(row[6], 2));
	out.class_id       = static_cast<uint8>(Strings::ToInt(row[7], Class::Warrior));
	out.texture        = static_cast<uint8>(Strings::ToInt(row[8], UINT8_MAX));
	out.helmet_texture = static_cast<uint8>(Strings::ToInt(row[9], UINT8_MAX));
	out.size           = Strings::ToFloat(row[10], -1.0f);
	out.hp             = Strings::ToInt(row[11], 0);
	out.mana           = Strings::ToInt(row[12], 0);
	out.endurance      = Strings::ToInt(row[13], 0);
	return true;
}

std::vector<ShroudDefinition> LoadAllShrouds()
{
	std::vector<ShroudDefinition> shrouds;

	const std::string query =
		"SELECT `id`, `name`, `progression`, `branch`, `level`, `race`, `gender`, `class`, "
		"`texture`, `helmet_texture`, `size`, `hp`, `mana`, `endurance` "
		"FROM `shrouds` ORDER BY `progression`, `branch`, `level`, `id`";

	auto results = content_db.QueryDatabase(query);
	if (!results.Success()) {
		// Log once: a missing `shrouds` table would otherwise spam on every hail.
		static bool logged_failure = false;
		if (!logged_failure) {
			logged_failure = true;
			LogError("Shrouds: could not query the `shrouds` table; shroud forms are unavailable.");
		}
		return shrouds;
	}

	for (auto row = results.begin(); row != results.end(); ++row) {
		ShroudDefinition d;
		d.id             = Strings::ToUnsignedInt(row[0]);
		d.name           = SafeCol(row[1]);
		d.progression    = SafeCol(row[2], "Shrouds");
		d.branch         = SafeCol(row[3], "General");
		d.level          = static_cast<uint8>(Strings::ToInt(row[4], 1));
		d.race           = static_cast<uint16>(Strings::ToInt(row[5], 0));
		d.gender         = static_cast<uint8>(Strings::ToInt(row[6], 2));
		d.class_id       = static_cast<uint8>(Strings::ToInt(row[7], Class::Warrior));
		d.texture        = static_cast<uint8>(Strings::ToInt(row[8], UINT8_MAX));
		d.helmet_texture = static_cast<uint8>(Strings::ToInt(row[9], UINT8_MAX));
		d.size           = Strings::ToFloat(row[10], -1.0f);
		d.hp             = Strings::ToInt(row[11], 0);
		d.mana           = Strings::ToInt(row[12], 0);
		d.endurance      = Strings::ToInt(row[13], 0);

		// Quest props are not forms a player may pick. The seven shroud ids below
		// are applied by the monster-mission controllers (Cake Defense, Dwarven
		// Wedding, Boat Lesson, King of the Monsters, Midnight Snack, Derelict
		// Space Station, Pottery Trial) and are stripped again by the zone-in
		// cleanup in global_player.pl whenever the player leaves that expedition.
		// Offering them in the keeper's window only produces the stuck-model state:
		// the form is applied, the reload zones, the connect cleanup silently
		// unshrouds, and the client keeps the model with nothing to remove.
		constexpr uint32 kQuestPropFirstId = 500;
		constexpr uint32 kQuestPropLastId  = 506;
		if (d.id >= kQuestPropFirstId && d.id <= kQuestPropLastId) {
			continue;
		}

		shrouds.push_back(d);
	}

	return shrouds;
}

// Builds the 0x07-delimited PROGRESSION/BRANCH/TEMPLATE tree the client's
// Shrouds page consumes. RE-VERIFIED against the RoF2 client binary
// (Release #630, May 10 2013): the selection-window parser (eqgame+0x414320,
// dispatched from the shroud manager thunk at eqgame+0x414A90) reads a 12-byte
// header (triggerNPCID, numShroudBankItems -- which must be 0 or the client
// refuses the window and sends 0x11CD -- and a third dword), then treats the
// rest as a NUL-terminated token stream split on 0x07 (the delimiter is the
// third argument of the client's ReadToken, eqgame+0x416EF0).
//
// PROGRESSION <id> <name> <id2>
// BRANCH <id> <name> <str> <id2>   (the client atoi()s the 4th field and
//                                  counts it when it equals 100; EQS writes
//                                  "100" there)
// TEMPLATE <name> <level> <id> <bool>
std::string BuildShroudTree(const std::vector<ShroudDefinition>& shrouds)
{
	const char sep = '\a';
	std::string out;

	std::string current_progression;
	std::string current_branch;

	// Every PROGRESSION / BRANCH / TEMPLATE record carries sequential node IDs
	// (the "unknown integer" fields). The reference layout walks a single
	// counter across the whole tree: 1,2 for the progression, 3,4 for the
	// branch, then the template id. The client keys its tree nodes off these,
	// so they must be unique and monotonic.
	uint32 next_id = 1;

	for (size_t i = 0; i < shrouds.size(); ++i) {
		const auto& d = shrouds[i];

		if (d.progression != current_progression) {
			current_progression = d.progression;
			current_branch.clear();

			out += "PROGRESSION";
			out += sep;
			out += std::to_string(next_id++);
			out += sep;
			out += current_progression;
			out += sep;
			out += std::to_string(next_id++);
			out += sep;
		}

		if (d.branch != current_branch) {
			current_branch = d.branch;

			out += "BRANCH";
			out += sep;
			out += std::to_string(next_id++);
			out += sep;
			out += current_branch;
			out += sep;
			out += std::to_string(next_id++);
			out += sep;
			out += "100";
			out += sep;
		}

		out += "TEMPLATE";
		out += sep;
		out += d.name;
		out += sep;
		out += std::to_string(d.level);
		out += sep;
		out += std::to_string(d.id);
		out += sep;
		out += "1";
		out += sep;
	}

	return out;
}

// Builds the OP_ShroudRespondStats payload body for one template. RE-VERIFIED
// against the RoF2 client binary: OP_ShroudRespondStats is dispatched to
// eqgame+0x413C10, which reads two leading dwords (the first is handed to the
// UI update; the second must be nonzero for the payload to be parsed) and then
// passes data+8 to the token deserializer at eqgame+0x5CA570. That parser
// splits the stream on '^' (0x5E) -- NOT NUL -- and expects:
//   id ^ name ^ description(<=4000) ^ 12 integers ^ abilityCount
//   ^ (abilityField ^ abilityField) x abilityCount ^ equipCount
//   ^ (equipField) x equipCount
// Integers accept decimal or 0x-prefixed hex. The 12 integers are stored at
// template+0xFEC..0x1020 (class animation, level, hp, mana, endurance and the
// seven stats as sent by EQS's shrouds table).
std::string BuildShroudStatsBlob(const ShroudDefinition& def, Client* client)
{
	// The client's field reader (eqgame+0x413C10 -> eqgame+0x5CA570) splits on
	// '^' (0x5E); a trailing delimiter after the last field is harmless.
	const char sep = '^';

	auto token = [](const std::string& s, char delimiter) {
		std::string t = s;
		t.push_back(delimiter);
		return t;
	};

	// Live-like mode: list THIS template's shroud abilities as two-field entries
	// {key, dbstr title_sid}. The set comes from the content mapping
	// (`shroud_abilities` for this progression/branch/level) -- NOT from every
	// shroud-category row in the zone. The selection window previews whichever
	// template was clicked, so the list must not depend on the form the client is
	// currently wearing, and it must not be the whole shroud band either: that is
	// what made almost every form advertise the same abilities.
	//
	// The key idiom is decoded only partially: the window renders names from
	// field 2 either way, and the AA window's matcher may key by ability id or by
	// rank id, so both key forms are emitted. The entry cap (62 over both forms)
	// is left as it was, but an ability-id entry is always preferred over its
	// redundant rank-id mirror, so a 33-ability template still lists all 33.
	std::vector<std::pair<uint32, uint32>> abilities;
	if (client && (RuleI(Custom, ShroudLiveMode) & 4) && zone) {
		const std::string ability_query = fmt::format(
			"SELECT `aa_id` FROM `shroud_abilities` "
			"WHERE `progression` = '{}' AND (`branch` = '' OR `branch` = '{}') AND `min_level` <= {} "
			"GROUP BY `aa_id` ORDER BY MIN(`display_order`)",
			Strings::Replace(def.progression, "'", "''"),
			Strings::Replace(def.branch, "'", "''"),
			static_cast<uint32>(def.level)
		);

		// Resolve every mapped ability first. Emitting an ability-id entry for all
		// of them and only then spending the remaining budget on the rank-id
		// mirrors means the largest templates (33 abilities) still list all 33
		// instead of losing their tail to the entry cap.
		std::vector<std::pair<uint32, uint32>> wanted; // {ability id, first rank id}
		auto results = content_db.QueryDatabase(ability_query);
		if (results.Success()) {
			for (auto row = results.begin(); row != results.end(); ++row) {
				auto* ability = zone->GetAlternateAdvancementAbility(Strings::ToUnsignedInt(row[0]));
				if (!ability || !ability->first) {
					continue;
				}
				wanted.emplace_back(ability->id, ability->first_rank_id);
			}
		}

		const std::size_t cap = 62;
		for (const auto& entry : wanted) {
			if (abilities.size() >= cap) {
				break;
			}
			auto* ability = zone->GetAlternateAdvancementAbility(entry.first);
			const uint32 title_sid = static_cast<uint32>(ability->first->title_sid);
			abilities.emplace_back(ability->id, title_sid); // ability-id key form
		}
		for (std::size_t i = 0; i < wanted.size() && abilities.size() < cap; ++i) {
			auto* ability = zone->GetAlternateAdvancementAbility(wanted[i].first);
			const uint32 title_sid = static_cast<uint32>(ability->first->title_sid);
			abilities.emplace_back(wanted[i].second, title_sid); // rank-id key form
		}
	}

	std::string blob;
	blob += token(std::to_string(def.id), sep);
	blob += token(def.name, sep);
	blob += token(fmt::format("Shroud form of {}", def.name), sep);

	blob += token(std::to_string(def.class_id), sep); // class animation id
	blob += token(std::to_string(def.level), sep);
	blob += token(std::to_string(def.hp), sep);
	blob += token(std::to_string(def.mana), sep);
	blob += token(std::to_string(def.endurance), sep);
	blob += token("100", sep); // strength
	blob += token("100", sep); // stamina
	blob += token("100", sep); // charisma
	blob += token("100", sep); // dexterity
	blob += token("100", sep); // intelligence
	blob += token("100", sep); // agility
	blob += token("100", sep); // wisdom

	blob += token(std::to_string(abilities.size()), sep);
	for (const auto& entry : abilities) {
		blob += token(std::to_string(entry.first), sep);
		blob += token(std::to_string(entry.second), sep);
	}
	blob += "0"; // equipment array count (terminates the stream)

	return blob;
}

} // namespace

// Builds and queues OP_ShroudRespondStats for one template. Sent both on the
// client's request (template click in the selection window) and unprompted
// after a transform / zone-in re-apply -- the client's monster ability window
// renders the applied template's parsed data, so the push after apply is what
// populates it without another selection-window visit.
static void SendShroudRespondStats(Client *client, const ShroudDefinition &def)
{
	const std::string blob = BuildShroudStatsBlob(def, client);

	auto* outapp = new EQApplicationPacket(OP_ShroudRespondStats, 8 + static_cast<uint32>(blob.length()));
	auto* header = reinterpret_cast<uint32*>(outapp->pBuffer);
	header[0] = def.id; // template id (handed to the client's UI update)
	header[1] = 1;      // payload present -- must be nonzero or the client skips parsing
	memcpy(outapp->pBuffer + 8, blob.data(), blob.length());

	client->FastQueuePacket(&outapp);
}

// Builds and queues OP_ShroudProgress (0x541D): the client's dispatcher clears
// the Monster-Alt progression list (manager+0x1C) and parses the payload as a
// 0x07-delimited token stream whose records are
//   PROGRESSION <f1:int> <f2:str> <f3:str> <f4:int> <f5:int> <f6:str> <f7:str> <f8:int>
// validated against the leading u32 count ("Monster Alt: did not receive the
// number..." on mismatch). Decoded display path (eqgame+0x693080): the window
// finds the record whose f1 == the current template's progression id and
// renders "Progression: <f3>", then "All monster classes in this progression
// are available." when f4 == f5, else "Next Monster Class: <f8>% (<f6>
// completed)". No match -> the window renders blank. The sweep below probes
// candidate progression ids; the name that appears on screen identifies the
// id the client matched.
static void SendShroudProgress(Client *client, const ShroudDefinition &def)
{
	if (!zone || !(RuleI(Custom, ShroudLiveMode) & 4)) {
		return;
	}

	const char sep = '\a';
	std::string tokens;
	uint32 count = 0;

	for (uint32 pid = 1; pid <= 6; ++pid) {
		tokens += "PROGRESSION";
		tokens += sep;
		tokens += std::to_string(pid);      // f1 int: progression id (match key)
		tokens += sep;
		tokens += "f2probe";                // f2 str
		tokens += sep;
		tokens += fmt::format("Progression{}", pid); // f3 str: displayed name
		tokens += sep;
		tokens += "1";                      // f4 int
		tokens += sep;
		tokens += "1";                      // f5 int (f4 == f5 -> "all available")
		tokens += sep;
		tokens += "completed";              // f6 str
		tokens += sep;
		tokens += "f7probe";                // f7 str
		tokens += sep;
		tokens += "50";                     // f8 int: percent
		tokens += sep;
		++count;
	}

	auto* outapp = new EQApplicationPacket(OP_ShroudProgress, 4 + tokens.length() + 1);
	auto* body   = reinterpret_cast<uint32*>(outapp->pBuffer);
	body[0] = count; // expected record count -- validated by the client
	if (!tokens.empty()) {
		memcpy(outapp->pBuffer + 4, tokens.c_str(), tokens.length());
	}
	outapp->pBuffer[4 + tokens.length()] = '\0';

	client->FastQueuePacket(&outapp);
}

// 0x006E (eqgame+0x413BC0): {u32,u32} straight to a UI notification (type 4)
// -- sent as a presumed monster-points display refresh. NOTE: 0x2507 was
// identified as the shroud-BANK item receive (item-object insert, same
// machinery as numShroudBankItems) -- do not send it without a real item
// serialization.
static void SendShroudPointsPackets(Client *client, uint32 shroud_id)
{
	if (!(RuleI(Custom, ShroudLiveMode) & 4) || shroud_id == 0) {
		return;
	}

	const uint32 points = client->GetShroudPoints();
	const uint32 spent  = client->GetShroudPointsSpent();

	auto* state_pkt = new EQApplicationPacket(OP_ShroudStateUpdate, 8);
	reinterpret_cast<uint32*>(state_pkt->pBuffer)[0] = points;
	reinterpret_cast<uint32*>(state_pkt->pBuffer)[1] = spent;
	client->FastQueuePacket(&state_pkt);
}

bool Client::OpenShroudWindow(Mob* npc)
{
	return OpenShroudWindowFor(npc, {});
}

bool Client::OpenShroudWindowFor(Mob* npc, const std::vector<uint32>& ids)
{
	// The native RoF2 window replaces the quest-built one when the native
	// protocol is enabled; the quest path below stays authoritative otherwise.
	if (RuleB(Custom, EnableSpiritShrouds) && ClientVersion() == EQ::versions::ClientVersion::RoF2) {
		// Same scoping on the spirit path: a mission hands its own ids through,
		// a keeper passes none and gets the catalog.
		OpenSpiritShroudsFor(ids);
		return true;
	}

	if (!RuleB(Custom, ShroudsEnabled)) {
		Message(Chat::Yellow, "Shrouds are not enabled on this server.");
		return false;
	}

	auto shrouds = LoadAllShrouds();
	if (!ids.empty()) {
		// Mission scope: keep only the forms the caller offered, and drop the
		// rest of the catalog. Unknown ids are ignored (the quest carries the
		// ids, the server owns which forms exist).
		std::erase_if(shrouds, [&ids](const ShroudDefinition& d) {
			return std::find(ids.begin(), ids.end(), d.id) == ids.end();
		});
		if (shrouds.empty()) {
			LogError("Shroud window: none of the [{}] requested form ids exist", ids.size());
			Message(Chat::Yellow, "Those forms are unavailable right now.");
			return false;
		}
	}

	if (shrouds.empty()) {
		Message(Chat::Yellow, "The shroud forms are unavailable right now.");
		return false;
	}

	const std::string tree = BuildShroudTree(shrouds);
	const uint32 length   = static_cast<uint32>(tree.length());

	auto* outapp = new EQApplicationPacket(OP_ShroudSelectionWindow, sizeof(ShroudSelectionWindow) + length + 1);
	auto* window = reinterpret_cast<ShroudSelectionWindow*>(outapp->pBuffer);

	window->triggerNPCID       = npc ? npc->GetID() : 0;
	window->numShroudBankItems = 0;
	window->unknown008         = 0;

	if (length > 0) {
		memcpy(window->shroudSelectionTreeString, tree.c_str(), length);
	}
	window->shroudSelectionTreeString[length] = '\0';

	LogInfo("Shroud window opened for [{}] (npc [{}]): [{}] forms, tree [{}] bytes",
		GetCleanName(), window->triggerNPCID, shrouds.size(), length);

	FastQueuePacket(&outapp);
	return true;
}

// Defined below (next to the other monster-point helpers); ApplyShroud grants the
// form's pool, so it needs the declaration up here.
static uint32 ShroudMonsterPointsForLevel(uint32 level);

void Client::ApplyShroud(uint32 shroud_id)
{
	// Native Spirit Shroud forms own the shroud machinery exclusively while
	// active; remove the native form first (Select 0 at the keeper).
	if (IsSpiritShrouded()) {
		Message(Chat::Red, "Remove your Spirit Shroud form before using the quest shrouds.");
		return;
	}

	ShroudDefinition def;
	if (!LoadShroud(shroud_id, def)) {
		Message(Chat::Red, "That shroud (%u) could not be found.", shroud_id);
		return;
	}

	// Live rule: you may shroud down to a lower level, never up. Compare
	// against the base character level when switching shrouds (GetLevel is
	// the shroud's level while transformed).
	const uint32 base_level = (m_shrouded && m_shroud_saved_valid)
		? m_shroud_saved_pp.level
		: static_cast<uint32>(GetLevel());
	if (def.level > base_level) {
		Message(Chat::Red, "You cannot shroud to a level higher than your own.");
		return;
	}

	if (!m_shrouded) {
		m_shroud_saved_pp          = m_pp;
		m_shroud_saved_valid       = true;
		m_shroud_saved_texture     = texture;
		m_shroud_saved_helmtexture = helmtexture;
		m_shroud_saved_size        = size;
		SaveShroudSnapshot(shroud_id);
	}

	// Mark shrouded before touching the profile so a save during the transform
	// (or afterwards) restores the real profile instead of persisting the shroud.
	m_shrouded  = true;
	m_shroud_id = shroud_id;

	// Shrouded players may not use mercenaries: suspend any active merc so it
	// despawns and stays suspended until the shroud is removed.
	Merc* active_merc = GetMerc();
	if (active_merc && GetMercenaryID()) {
		active_merc->Suspend();
		Message(Chat::Red, "Your mercenary is suspended while shrouded.");
		Log(Logs::General, Logs::Mercenaries, "ApplyShroud suspended active merc for %s.", GetName());
	}

	// Live-like mode: a fresh monster-point grant per shroud apply and any
	// purchases from a previous session are dropped. The form's catalog rows
	// are BOUGHT with those points -- they are deliberately not pre-granted.
	// The client's monster AA pane (eqgame pane builder -> gate 0x4A40F0 ->
	// sub_4A3D70) only lists a row whose ability the player does not already
	// own, so auto-granting every catalog rank up front (Project M style)
	// left the pane permanently empty with nothing to buy.
	const bool live_mode = (RuleI(Custom, ShroudLiveMode) & 4) != 0;
	if (live_mode) {
		ShroudPurgeOwnedAAs();
		ShroudGrantPoints(ShroudMonsterPointsForLevel(static_cast<uint32>(def.level)), shroud_id, def.level);
		// Restore what this form already had bought (character_shroud_aa is keyed
		// by form and survives camping out), charging the freshly granted pool so
		// the player keeps their spread instead of respending it.
		ShroudReapplyPurchases(true);
	}

	// Keep the profile in sync so a later reset-to-base picks the shroud race.
	m_pp.race   = def.race;
	m_pp.gender = def.gender;
	m_pp.class_ = def.class_id;
	m_pp.level  = def.level;

	// The form's own class skills (a rogue shroud's Pick Lock, a warrior shroud's
	// Bash/Kick, ...) come with the shroud and are not monster-point purchases.
	ShroudApplyClassSkills(def.class_id, def.level);

	// Which guide abilities this form/level may see (gates the AA pane and caps
	// the ranks it can buy).
	LoadShroudAbilityCaps(def.progression, def.branch, def.level);

	// Put the shroud form on the mob BEFORE serializing the spawn: the client
	// re-adds its self spawn from this block, so it must carry the shroud
	// appearance (otherwise the client keeps the old race/model).
	race           = def.race;
	gender         = def.gender;
	class_         = def.class_id;
	texture        = def.texture;
	helmtexture    = def.helmet_texture;
	if (def.size > 0.0f) {
		size = def.size;
	}
	ShroudDiag("ApplyShroud id=%u def(race=%u gender=%u class=%u lvl=%u) "
	           "m_pp(race=%u gender=%u class=%u lvl=%u)",
	           shroud_id, def.race, def.gender, def.class_id, def.level,
	           m_pp.race, m_pp.gender, m_pp.class_, m_pp.level);
	SetLevel(def.level);
	// Re-base XP into the form's level. m_shroud_saved_pp keeps the real XP,
	// so nothing is lost on unshroud; without this the first kill runs the
	// SetEXP level-up loop back up to the real level.
	m_pp.exp = GetEXPForLevel(def.level);
	CalcBonuses();
	SetMaxHP();
	SendHPUpdate();

	// The form is applied to m_pp above; the reload below makes the client
	// build it from the zone-in profile. No spawn re-send, no illusion packet,
	// no AA resend: the connect sequence sends all of that from the profile.
	m_pp.cur_hp    = GetHP();
	m_pp.mana      = current_mana;
	m_pp.endurance = current_endurance;

	ShroudDiag("ApplyShroud reload: mob(race=%u gender=%u class=%u lvl=%u "
	           "texture=%u helm=%u size=%.1f) def.size=%.1f",
	           race, gender, class_, level, texture, helmtexture, size, def.size);

	Message(Chat::Yellow, "You take on the form of %s.", def.name.c_str());

	LogInfo(
		"Client [{}] shrouded as [{}] (id [{}])",
		GetCleanName(),
		def.name,
		def.id
	);

	ReloadForShroudTransition("enter shroud");
}

void Client::RemoveShroud(bool send_updates)
{
	// A native spirit form rides the same saved-profile fields but owns extra
	// state this function never touched (template, spirit_shroud_state row,
	// starter items) -- leaving it armed resurrected the form on the next
	// zone-in. Route to the native restore; by the time it hands back through
	// RemoveShroud below, the template is cleared, so old-engine bodies run.
	if (m_spirit_shroud_template) {
		RestoreNativeShroud(send_updates);
		return;
	}

	LogInfo("RemoveShroud requested for [{}]: shrouded [{}] shroud_id [{}] saved_valid [{}] send_updates [{}] live_mode [{}]",
		GetCleanName(), m_shrouded, m_shroud_id, m_shroud_saved_valid, send_updates,
		(RuleI(Custom, ShroudLiveMode) & 4) != 0);

	if (!m_shrouded) {
		return;
	}

	if (m_shroud_saved_valid) {
		m_pp = m_shroud_saved_pp;
		m_shroud_saved_valid = false;
	}

	m_shrouded  = false;
	m_shroud_id = 0;

	// The guide-content gate belongs to the form; drop it with the form.
	ClearShroudAbilityCaps();

	ClearShroudSnapshot();

	// Live-like mode: the monster-point session ends on unshroud — pool and
	// purchases are wiped (runs even when the client packets are suppressed).
	if (RuleI(Custom, ShroudLiveMode) & 4) {
		ShroudEndSession();
	}
	if (!send_updates) {
		return;
	}

	// Put the real identity back on the mob; the reload below makes the client
	// rebuild the character from the zone-in profile, so the appearance comes
	// from the spawn the connect sequence sends, not from a transform packet.
	race        = m_pp.race;
	gender      = m_pp.gender;
	class_      = m_pp.class_;
	texture     = m_shroud_saved_texture;
	helmtexture = m_shroud_saved_helmtexture;
	if (m_shroud_saved_size > 0.0f) {
		size = m_shroud_saved_size;
	}

	SetLevel(m_pp.level);
	CalcBonuses();
	SetMaxHP();
	SendHPUpdate();

	m_pp.cur_hp    = GetHP();
	m_pp.mana      = current_mana;
	m_pp.endurance = current_endurance;

	ShroudDiag("RemoveShroud reload: mob(race=%u gender=%u class=%u lvl=%u texture=%u helm=%u size=%.1f)",
	           race, gender, class_, level, texture, helmtexture, size);

	Message(Chat::Yellow, "You return to your natural form.");

	ReloadForShroudTransition("leave shroud");
}

void Client::SaveShroudSnapshot(uint32 shroud_id, bool native_template)
{
	if (!m_shroud_saved_valid) {
		return;
	}

	const PlayerProfile_Struct& p = m_shroud_saved_pp;
	const std::string query = fmt::format(
		"REPLACE INTO `character_shroud_snapshot` "
		"(`character_id`,`shroud_id`,`race`,`gender`,`class`,`level`,`texture`,`helmet_texture`,`size`,`native_template`) "
		"VALUES ({},{},{},{},{},{},{},{},{},{})",
		CharacterID(),
		shroud_id,
		p.race,
		p.gender,
		p.class_,
		p.level,
		m_shroud_saved_texture,
		m_shroud_saved_helmtexture,
		m_shroud_saved_size,
		native_template ? 1 : 0
	);

	database.QueryDatabase(query);
}

void Client::ClearShroudSnapshot()
{
	const std::string query = fmt::format(
		"DELETE FROM `character_shroud_snapshot` WHERE `character_id` = {}",
		CharacterID()
	);

	database.QueryDatabase(query);
}

// ---------------------------------------------------------------------
// Live-like monster points / shroud AAs (Custom:ShroudLiveMode bit 4).
//
// The pool is separate from m_pp.aapoints so the ShroudPersistGuard and
// SaveAA never see it. Purchases are recorded in character_shroud_aa and
// mirrored into the in-memory aa_ranks map (category 3/4 entries) so the
// existing ownership/bonus/display plumbing works unchanged; the map is
// purged on unshroud (session reset) and SaveAA skips category 3/4.
// ---------------------------------------------------------------------

// Every aa_id the shroud content references. The guide content reuses existing
// classic AA lines (Innate Agility 3, Combat Agility 34, Mental Clarity 224, ...),
// which live outside any id band, so "is this shroud content" cannot be answered
// from the id alone -- the mapping table is the authority. Loaded once per zone
// process on first use.
static const std::unordered_set<uint32> &ShroudContentIds()
{
	static std::unordered_set<uint32> ids;
	static bool loaded = false;

	if (!loaded) {
		loaded = true;
		auto results = content_db.QueryDatabase("SELECT DISTINCT `aa_id` FROM `shroud_abilities`");
		if (results.Success()) {
			for (auto row = results.begin(); row != results.end(); ++row) {
				const uint32 id = Strings::ToUnsignedInt(row[0]);
				if (id) {
					ids.insert(id);
				}
			}
		}
		LogInfo("[Shroud] content lines referenced by shroud_abilities: [{}]", ids.size());
	}

	return ids;
}

bool Client::IsShroudAA(const AA::Ability *ability)
{
	if (!ability) {
		return false;
	}

	// Dedicated shroud-only lines: the classic shroud categories, the hand-made
	// 90100-90199 test band, and the 91000+ catalog band. The content mapping
	// ALSO references real classic AA lines for a form's granted passives
	// (Mystical Attuning 334, Mental Clarity 224, Combat Agility 34, Divine Aura
	// 7108, ...); those are normal AAs. Treating them as shroud-only hid them
	// from every unshrouded client (the AA window is built from
	// CanUseAlternateAdvancementRank) and let a shroud session collide with the
	// real owned rank under the same aa_ranks key. The mapping still drives the
	// form's own display/cap set via IsShroudAbilityForCurrentForm /
	// ShroudAbilityMaxRank.
	if (ability->category == AACategory::ShroudPassive
		|| ability->category == AACategory::ShroudActive
		|| SpiritShroud::NativeAbility(ability->id)) {
		return true;
	}

	return ability->id >= 90100;
}

// A shroud's skills belong to the form, not to the player wearing it. The guide
// is explicit about this: the skill tab "will not be posted" because a shroud's
// skills "are at max or 75 percent of max for the level subtype shroud", and the
// class basics are filled in for free (a rogue shroud can Pick Lock, a warrior
// shroud can Bash/Kick, a berserker shroud can Frenzy). Without this the client
// kept the character's own class skills inside a different form, so those
// class-gated actions were missing entirely.
// Build the current form's ability set from the guide mapping: every aa_id whose
// branch rule applies at this form's level, with the highest max_rank the guide
// grants for it at or below that level. This is what gates the monster AA pane
// (the client lists a row only when the server marks its "shroud" byte) and caps
// how many ranks of a line the form may buy.
void Client::LoadShroudAbilityCaps(const std::string &progression, const std::string &branch, uint8 level)
{
	m_shroud_ability_caps.clear();

	// Rows with an empty branch are the original hand-made test content and apply
	// to every branch of their progression.
	const std::string query = fmt::format(
		"SELECT `aa_id`, MAX(`max_rank`) FROM `shroud_abilities` "
		"WHERE `progression` = '{}' AND (`branch` = '' OR `branch` = '{}') AND `min_level` <= {} "
		"GROUP BY `aa_id`",
		Strings::Replace(progression, "'", "''"),
		Strings::Replace(branch, "'", "''"),
		static_cast<uint32>(level)
	);

	auto results = content_db.QueryDatabase(query);
	if (results.Success()) {
		for (auto row = results.begin(); row != results.end(); ++row) {
			m_shroud_ability_caps[Strings::ToUnsignedInt(row[0])] = Strings::ToUnsignedInt(row[1]);
		}
	}

	LogInfo(
		"Shroud [{}] / [{}] level [{}]: [{}] abilities available (content lines [{}])",
		progression, branch, level, m_shroud_ability_caps.size(), ShroudContentIds().size()
	);
}

void Client::ClearShroudAbilityCaps()
{
	m_shroud_ability_caps.clear();
}

bool Client::IsShroudAbilityForCurrentForm(uint32 aa_id) const
{
	return m_shroud_ability_caps.find(aa_id) != m_shroud_ability_caps.end();
}

uint32 Client::ShroudAbilityMaxRank(uint32 aa_id) const
{
	const auto it = m_shroud_ability_caps.find(aa_id);
	return it == m_shroud_ability_caps.end() ? 0 : it->second;
}

void Client::ShroudApplyClassSkills(uint8 shroud_class, uint8 shroud_level)
{
	for (uint32 skill_id = 0; skill_id <= static_cast<uint32>(EQ::skills::HIGHEST_SKILL); ++skill_id) {
		const auto skill = static_cast<EQ::skills::SkillType>(skill_id);

		// Skill caps are class- and level-gated, so a form only ever receives the
		// skills its own class can train at its shroud level (Pick Lock for rogues,
		// Bash/Kick for warriors, ...); everything else is explicitly zeroed so the
		// player's own class skills cannot leak into a different form.
		//
		// Written straight into the profile rather than via Client::SetSkill, which
		// persists every value to character_skills and spams the skill-up channel.
		// m_pp is restored from the pre-shroud copy on unshroud and the values ride
		// the OP_Shroud profile block, so the database is never touched.
		m_pp.skills[skill_id] = MaxSkillOriginal(skill, shroud_class, shroud_level);
	}
}

void Client::ShroudPurgeOwnedAAs()
{
	if (!zone) {
		return;
	}

	std::vector<uint32> purge;
	for (const auto &entry : aa_ranks) {
		if (entry.second.first == 0) {
			continue;
		}
		auto *ability = zone->GetAlternateAdvancementAbility(entry.first);
		if (IsShroudAA(ability)) {
			purge.push_back(entry.first);
		}
	}

	for (uint32 ability_id : purge) {
		aa_ranks.erase(ability_id);
	}
}

// Monster points granted by a shroud form, from the live Spirit Shroud guide's
// per-level "Abilities: N monster points" line (thedruidsgrove.org thread 17045).
// Forms below level 20 grant none -- their starting abilities are free basics --
// and the ladder then runs 32/36/40/45/50/55 for levels 20-45, 78 at 50, 84 at 55,
// 91 at 60 and 97 at 65. The guide stops at 65, so 70 is extrapolated along its
// own increments. Its per-form totals differ a little (a level 65 shroud ranges
// from 97 to 136 depending on the form), so this is the documented baseline and
// Custom:ShroudMonsterPointScale scales it.
//
// Levels 5-15 get a small starter pool instead of the guide's zero: in live those
// forms' abilities are free basics, which this catalog models as AA rows instead,
// so a low-level form would otherwise have nothing it could ever buy.
static uint32 ShroudMonsterPointsForLevel(uint32 level)
{
	static const struct { uint32 level; uint32 points; } k_grants[] = {
		{ 20,  32 }, { 25,  36 }, { 30,  40 }, { 35,  45 }, { 40,  50 },
		{ 45,  55 }, { 50,  78 }, { 55,  84 }, { 60,  91 }, { 65,  97 },
		{ 70, 104 },
	};

	constexpr uint32 k_starter_points = 10;

	uint32 points = k_starter_points;
	for (const auto &grant : k_grants) {
		if (level >= grant.level) {
			points = grant.points;
		}
	}

	const int scale = RuleI(Custom, ShroudMonsterPointScale);
	if (scale != 100) {
		// 0 (or a negative value) is a meaningful setting, not "unset": it grants
		// no monster points at all, i.e. the guide's strict values, where a
		// low-level form's basics are free rather than bought.
		points = (scale <= 0)
			? 0
			: static_cast<uint32>((points * static_cast<uint64>(scale)) / 100);
	}

	return points;
}

void Client::ShroudGrantPoints(uint32 points, uint32 shroud_id, uint32 level)
{
	m_shroud_points       = points;
	m_shroud_points_spent = 0;

	const std::string query = fmt::format(
		"REPLACE INTO `character_shroud_points` "
		"(`character_id`,`points_available`,`points_spent`,`shroud_id`,`granted_level`) "
		"VALUES ({},{},0,{},{})",
		CharacterID(),
		m_shroud_points,
		shroud_id,
		level
	);

	database.QueryDatabase(query);
	Message(Chat::Yellow, "You receive %u monster points.", m_shroud_points);
}

void Client::ShroudSavePoints()
{
	const std::string query = fmt::format(
		"UPDATE `character_shroud_points` SET `points_available` = {}, `points_spent` = {} WHERE `character_id` = {}",
		m_shroud_points,
		m_shroud_points_spent,
		CharacterID()
	);

	database.QueryDatabase(query);
}

void Client::ShroudLoadPoints()
{
	m_shroud_points       = 0;
	m_shroud_points_spent = 0;

	const std::string query = fmt::format(
		"SELECT `points_available`,`points_spent` FROM `character_shroud_points` WHERE `character_id` = {} LIMIT 1",
		CharacterID()
	);

	auto results = database.QueryDatabase(query);
	if (!results.Success() || results.RowCount() == 0) {
		return;
	}

	auto row = results.begin();
	m_shroud_points       = Strings::ToUnsignedInt(row[0]);
	m_shroud_points_spent = Strings::ToUnsignedInt(row[1]);
}

void Client::ShroudEndSession()
{
	database.QueryDatabase(fmt::format(
		"DELETE FROM `character_shroud_points` WHERE `character_id` = {}",
		CharacterID()
	));
	// character_shroud_aa is deliberately kept: it is the per-form record of what
	// was bought, so camping out and re-shrouding the same form restores the
	// spread instead of making the player spend the points again.

	m_shroud_points       = 0;
	m_shroud_points_spent = 0;

	ShroudPurgeOwnedAAs();
}

void Client::ShroudReapplyPurchases(bool spend)
{
	if (!zone) {
		return;
	}

	const std::string query = fmt::format(
		"SELECT `aa_id`,`value` FROM `character_shroud_aa` "
		"WHERE `character_id` = {} AND `shroud_id` = {}",
		CharacterID(),
		m_shroud_id
	);

	auto results = database.QueryDatabase(query);
	if (!results.Success() || results.RowCount() == 0) {
		if (spend) {
			LogInfo(
				"Shroud form [{}] for [{}]: no stored purchases; pool {} monster points granted.",
				m_shroud_id, GetCleanName(), m_shroud_points
			);
		}
		return;
	}

	// Pool as freshly granted (ApplyShroud grants immediately before this call).
	const uint32 granted  = m_shroud_points;
	uint32       restored = 0;

	for (auto row = results.begin(); row != results.end(); ++row) {
		const uint32 aa_id  = Strings::ToUnsignedInt(row[0]);
		const uint32 value  = Strings::ToUnsignedInt(row[1]);

		auto *ability = zone->GetAlternateAdvancementAbility(aa_id);
		if (!IsShroudAA(ability) || value == 0 || !ability->first) {
			continue;
		}

		++restored;
		if (!spend) {
			// Zone-in within an existing session: the persisted pool already
			// reflects these purchases, so only re-own the ranks.
			SetAA(ability->first_rank_id, value, 0);
			continue;
		}

		// Fresh shroud apply: the pool was just re-granted, so charge the restored
		// spread against it exactly as the original purchases did.
		for (auto *rank = ability->first; rank && rank->current_value <= static_cast<int>(value);
			 rank = rank->next) {
			FinishAlternateAdvancementPurchase(rank, false, false);
		}
	}

	// A form can be repriced after something was bought for it (the point ladder
	// or Custom:ShroudMonsterPointScale changing), leaving a restored spread that
	// costs more than the form's current grant. The ranks stay owned -- they were
	// already paid for -- but the spend is reported against the pool, so the
	// window can never show more points spent than the form granted.
	if (spend && m_shroud_points_spent > granted) {
		m_shroud_points_spent = granted;
		ShroudSavePoints();
	}

	// One line per apply/zone-in: enough to tell from the log alone whether a
	// re-shroud restored the spread (and whether the grant covered it).
	LogInfo(
		"Shroud form [{}] for [{}]: restored [{}] stored purchase(s) from character_shroud_aa{}; "
		"pool [{}] available / [{}] spent (grant [{}]).",
		m_shroud_id,
		GetCleanName(),
		restored,
		spend ? "" : " (own-only, zone-in)",
		m_shroud_points,
		m_shroud_points_spent,
		granted
	);
}

// Note for anyone revisiting auto-grant: pre-granting the whole catalog (Project
// M style) made the client's monster AA pane list nothing, because a row is only
// listed while its ability is unowned. The form's rows are bought with monster
// points instead -- see ApplyShroud and ShroudReapplyPurchases. The retired
// implementation was removed along with its stale 3-column `character_shroud_aa`
// write, which would have filed records under shroud_id 0 (invisible to the
// per-form read) now that the table is keyed by form.

// Called once on zone-in. If the character has a persisted shroud, re-apply it:
// shrouds survive zoning/relogging and are only removed at the Shroudkeeper. A
// legacy row with shroud_id 0 (written before persistence existed) is cleared.
// Rows flagged native_template re-apply through the native Spirit Shroud
// protocol path (spirit_shroud_templates) instead of the quest catalog.
void Client::LoadAndApplyShroudState()
{
	const std::string query = fmt::format(
		"SELECT `shroud_id`,`race`,`gender`,`class`,`level`,`texture`,`helmet_texture`,`size`,`native_template` "
		"FROM `character_shroud_snapshot` WHERE `character_id` = {} LIMIT 1",
		CharacterID()
	);

	auto results = database.QueryDatabase(query);
	if (!results.Success() || results.RowCount() == 0) {
		return;
	}

	auto row = results.begin();
	const uint32 shroud_id = Strings::ToUnsignedInt(row[0]);
	const bool native_template = results.ColumnCount() > 8 && Strings::ToInt(row[8], 0) != 0;

	// m_pp still holds the real character here; the Save() guard writes this
	// while shrouded, so capture it before the form is applied.
	m_shroud_saved_pp          = m_pp;
	m_shroud_saved_valid       = true;
	m_shroud_saved_texture     = static_cast<uint8>(Strings::ToInt(row[5], UINT8_MAX));
	m_shroud_saved_helmtexture = static_cast<uint8>(Strings::ToInt(row[6], UINT8_MAX));
	m_shroud_saved_size        = Strings::ToFloat(row[7], -1.0f);

	if (shroud_id == 0) {
		// Legacy repair row: the profile is already real, nothing to re-apply.
		m_shroud_saved_valid = false;
		ClearShroudSnapshot();
		return;
	}

	if (native_template) {
		ReapplyNativeShroud(shroud_id);
		return;
	}

	ShroudDefinition def;
	if (!LoadShroud(shroud_id, def)) {
		LogError(
			"Character [{}] has a persisted shroud [{}] that no longer exists; clearing.",
			GetCleanName(),
			shroud_id
		);
		m_shroud_saved_valid = false;
		ClearShroudSnapshot();
		return;
	}

	m_shrouded  = true;
	m_shroud_id = shroud_id;

	// Live-like mode: the point pool survives zone/relog for this session, and
	// the abilities the player bought for this form are re-applied from
	// character_shroud_aa BEFORE CalcBonuses so passives apply on zone-in.
	if (RuleI(Custom, ShroudLiveMode) & 4) {
		ShroudLoadPoints();
		ShroudReapplyPurchases(false);
	}

	m_pp.race   = def.race;
	m_pp.gender = def.gender;
	m_pp.class_ = def.class_id;
	m_pp.level  = def.level;

	// Same form-owned class skills as ApplyShroud: a zone-in has to re-grant them
	// because the profile that loaded is the real character's.
	ShroudApplyClassSkills(def.class_id, def.level);

	// Rebuild this form's guide-content gate for the new zone process.
	LoadShroudAbilityCaps(def.progression, def.branch, def.level);

	race        = def.race;
	gender      = def.gender;
	class_      = def.class_id;
	texture     = def.texture;
	helmtexture = def.helmet_texture;
	if (def.size > 0.0f) {
		size = def.size;
	}

	SetLevel(def.level);
	// Re-base XP into the form's level. m_shroud_saved_pp keeps the real XP,
	// so nothing is lost on unshroud; without this the first kill runs the
	// SetEXP level-up loop back up to the real level.
	m_pp.exp = GetEXPForLevel(def.level);
	CalcBonuses();
	SetMaxHP();

	// No packet to defer any more: this runs before the zone-in profile is
	// serialized, so the client builds the form from the profile itself.
	LogInfo(
		"Client [{}] has a persisted shroud [{}]; form applied to the zone-in profile",
		GetCleanName(),
		shroud_id
	);
}

// Zone-in extras for a character that logs in already wearing a form: the
// profile carries the class/level/AA, but the shroud UI packets (progress,
// monster points, the template's stat blob) are not profile fields and are not
// re-sent by the connect sequence. Called once from CompleteConnect after the
// bulk sends; the runtime transform used to carry these, and it is gone.
// ---------------------------------------------------------------------------
// Form inventory view.
//
// The legacy strip was a transform-packet trick: the OP_Shroud extras carried an
// empty inventory so the client showed no gear. The form is applied by the
// zone-in profile now, which ships the real items, so a transformed character
// would wear its own equipment and bank. Send the form's own loadout instead --
// the native catalog's spirit_shroud_starter_equipment, matched by
// progression/branch/level for legacy forms -- and send nothing else: no
// possessions, no bank, no bags. The unshroud reload re-sends the real
// inventory from the database. A form with no authored loadout arrives bare,
// which is the intended "the form brings its own gear" model.
// ---------------------------------------------------------------------------
uint32 Client::ShroudInventoryTemplateId() const
{
	if (m_spirit_shroud_template) {
		return m_spirit_shroud_template;
	}

	if (!m_shroud_id) {
		return 0;
	}

	ShroudDefinition def;
	if (!LoadShroud(m_shroud_id, def)) {
		return 0;
	}

	const std::string query = fmt::format(
		"SELECT `id` FROM `spirit_shroud_templates` "
		"WHERE `progression_name`='{}' AND `branch_name`='{}' AND `level`={} LIMIT 1",
		Strings::Replace(def.progression, "'", "''"),
		Strings::Replace(def.branch, "'", "''"),
		def.level
	);
	auto results = content_db.QueryDatabase(query);
	if (!results.Success() || results.RowCount() == 0) {
		return 0;
	}

	return Strings::ToUnsignedInt((*results.begin())[0], 0);
}

// The body lives in a free function so the SEH frame below carries no C++
// objects (MSVC forbids unwinding objects in a __try function).
static void SendShroudInventoryViewInner(Client *c)
{
	EQ::OutBuffer ob;

	const uint32 template_id = c->ShroudInventoryTemplateId();
	if (template_id) {
		const std::string query = fmt::format(
			"SELECT `slot_id`,`item_id` FROM `spirit_shroud_starter_equipment` "
			"WHERE `template_id`={} ORDER BY `slot_id`",
			template_id
		);
		auto results = content_db.QueryDatabase(query);
		if (results.Success()) {
			for (auto row = results.begin(); row != results.end(); ++row) {
				const int16 slot = static_cast<int16>(Strings::ToInt(row[0], 0));
				const uint32 item_id = Strings::ToUnsignedInt(row[1]);
				if (slot <= 0 || item_id == 0) {
					continue;
				}

				const EQ::ItemData* data = database.GetItem(item_id);
				if (!data) {
					continue;
				}

				EQ::ItemInstance inst(data, 1);
				inst.Serialize(ob, slot);
			}
		}
	}

	auto outapp = new EQApplicationPacket(OP_CharInventory);
	outapp->size    = ob.size();
	outapp->pBuffer = ob.detach();
	c->QueuePacket(outapp);
	safe_delete(outapp);
}

// The filtered form-inventory view is cosmetic: the real loadout is enforced by
// IssueNativeStarterItems. A fault here used to kill the zone during the
// shrouded zone-in (Handle_Connect_OP_ZoneEntry) and left the character unable
// to log back in -- the form state re-applies before the crash, so every
// reconnect hit the same fault. Contained to a logged skip; the client simply
// misses the form-inventory packet.
// Logging lives in its own function: an SEH function may construct no
// unwinding objects anywhere (C2712).
static void SendShroudInventoryViewFaulted(unsigned long long code)
{
	LogF(Logs::General, Logs::Crash, "Shroud inventory view faulted (code [0x{:X}]); the form-inventory packet was skipped",
		code);
}

void Client::SendShroudInventoryView()
{
	// The handler scope may not construct objects (C2712), so the code is
	// captured in the filter expression and logged after the SEH frame.
	DWORD seh_code = 0;
	__try {
		SendShroudInventoryViewInner(this);
	} __except (seh_code = GetExceptionCode(), EXCEPTION_EXECUTE_HANDLER) {
		;
	}
	if (seh_code) {
		SendShroudInventoryViewFaulted(seh_code);
	}
}

void Client::SendShroudZoneInState()
{
	if (!m_shrouded) {
		return;
	}

	if (IsSpiritShrouded()) {
		SendSpiritShroudProgress();
		// Do NOT send OP_ClearAA here. The zone-in profile that this runs after
		// already carries the form's AA array (ReapplyNativeShroud/SetAA), and
		// OP_ClearAA arrives *after* that profile, wiping the ownership the
		// client just received -- the AA window then lists nothing at all, owned
		// or trainable. The table send below refreshes the definitions; the
		// profile is the authority for what the form owns.
		uint32 owned_entries = 0;
		for (const auto &aa : m_pp.aa_array) {
			if (aa.AA) {
				++owned_entries;
			}
		}
		LogInfo("[SHROUD-AA] zone-in form [{}] profile AA entries [{}] pool [{}] spent [{}]",
			m_spirit_shroud_template, owned_entries, m_pp.aapoints, m_pp.aapoints_spent);
		// The client keeps its AA list across the same-zone reload, and a row is
		// never evicted by omitting it or by re-sending it with a zero class mask
		// (that only greys it). Drop the list first, then advertise the form's
		// ranks alone, so the window holds exactly the form's kit.
		SendClearPlayerAA();
		SendAlternateAdvancementTable();
		SendAlternateAdvancementPoints();
		SendAlternateAdvancementStats();
		// The shroud window's purchase button reads the state-update points
		// packet (the old-engine branch below sends it for quest forms); the
		// native pool lives in the AA points fields while transformed. Without
		// this the window believes the monster pool is empty and the buy click
		// never leaves the client.
		auto *shroud_points = new EQApplicationPacket(OP_ShroudStateUpdate, 8);
		reinterpret_cast<uint32 *>(shroud_points->pBuffer)[0] = m_pp.aapoints;
		reinterpret_cast<uint32 *>(shroud_points->pBuffer)[1] = m_pp.aapoints_spent;
		FastQueuePacket(&shroud_points);
		return;
	}

	ShroudDefinition def;
	if (!LoadShroud(m_shroud_id, def)) {
		return;
	}

	Message(Chat::Yellow, "You are still shrouded as %s.", def.name.c_str());

	if (RuleI(Custom, ShroudLiveMode) & 4) {
		SendAlternateAdvancementTable();
		SendAlternateAdvancementPoints();
		SendAlternateAdvancementStats();
		SendShroudRespondStats(this, def);
		SendShroudProgress(this, def);
		SendShroudPointsPackets(this, def.id);
	}
}

void Client::Handle_OP_Shroud(const EQApplicationPacket* app)
{
	LogInfo(
		"Client [{}] sent OP_Shroud (size [{}])",
		GetCleanName(),
		app->size
	);
}

void Client::Handle_OP_ShroudSelect(const EQApplicationPacket* app)
{
	// Native protocol owns this wire value when enabled; the quest path keeps
	// it otherwise.
	if (RuleB(Custom, EnableSpiritShrouds) && ClientVersion() == EQ::versions::ClientVersion::RoF2) {
		Handle_OP_SpiritShroudSelect(app);
		return;
	}

	if (app->size < sizeof(uint32)) {
		LogError(
			"OP_ShroudSelect from [{}] too small (size [{}])",
			GetCleanName(),
			app->size
		);
		return;
	}

	// Payload layout is unverified for RoF2: treat the first dword as the
	// shroud id, and log the raw size so a capture can confirm.
	const uint32 shroud_id = *reinterpret_cast<const uint32*>(app->pBuffer);

	LogInfo(
		"Client [{}] OP_ShroudSelect shroud_id [{}] size [{}]",
		GetCleanName(),
		shroud_id,
		app->size
	);

	// Leave the client's "transformation in progress" modal before any path that
	// can zone it (ApplyShroud/RemoveShroud now reload).
	SendShroudSelectComplete();

	if (shroud_id == 0) {
		RemoveShroud();
		return;
	}

	// Shrouding on is gated by the rule; removal (id 0, above) never is, so a
	// player who is already shrouded can always revert.
	if (!RuleB(Custom, ShroudsEnabled)) {
		Message(Chat::Yellow, "Shrouds are not enabled on this server.");
		return;
	}

	ApplyShroud(shroud_id);
}

void Client::Handle_OP_ShroudSelectCancel(const EQApplicationPacket* app)
{
	// Native protocol owns this wire value when enabled.
	if (RuleB(Custom, EnableSpiritShrouds) && ClientVersion() == EQ::versions::ClientVersion::RoF2) {
		Handle_OP_SpiritShroudCancel(app);
		return;
	}

	LogInfo("Client [{}] OP_ShroudSelectCancel (size [{}])", GetCleanName(), app->size);
	RemoveShroud();
}

void Client::Handle_OP_ShroudRequestStats(const EQApplicationPacket* app)
{
	// Native protocol owns this wire value when enabled.
	if (RuleB(Custom, EnableSpiritShrouds) && ClientVersion() == EQ::versions::ClientVersion::RoF2) {
		Handle_OP_SpiritShroudRequest(app);
		return;
	}

	if (!RuleB(Custom, ShroudsEnabled)) {
		return;
	}

	uint32 requested_id = 0;
	if (app->size >= sizeof(uint32)) {
		requested_id = *reinterpret_cast<const uint32*>(app->pBuffer);
	}

	LogInfo(
		"Client [{}] OP_ShroudRequestStats: size [{}] requested_id [{}]",
		GetCleanName(),
		app->size,
		requested_id
	);

	ShroudDefinition def;
	if (!LoadShroud(requested_id, def)) {
		return;
	}

	SendShroudRespondStats(this, def);
}


