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
#include "../common/races.h"
#include "../common/rulesys.h"
#include "../common/strings.h"

#include <fmt/format.h>

#include <cstring>
#include <string>
#include <vector>

#include "aa.h"
#include "client.h"
#include "entity.h"
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

// Builds and queues the OP_Shroud self-transform (spawn block + profile block).
// The spawn block is stamped with the target identity because FillSpawnStruct
// copies the mob's class_/size, which are stale for the frame in which a
// transform is applied -- that mismatch is what leaves the client's self-model
// lying in a broken pose and hides its gear/UI.
void SendShroudTransform(Client *client, const PlayerProfile_Struct &profile, float size)
{
	NewSpawn_Struct ns{};
	client->FillSpawnStruct(&ns, client);

	ns.spawn.race   = static_cast<uint16>(profile.race);
	ns.spawn.gender = static_cast<uint8>(profile.gender);
	ns.spawn.class_ = static_cast<uint8>(profile.class_);
	ns.spawn.level  = static_cast<uint8>(profile.level);
	if (size > 0.0f) {
		ns.spawn.size = size;
	}

	// Serialize the self spawn as a *player-type* spawn even when the shroud
	// form is a monster race. FillSpawnStruct marks the client's own spawn
	// NPC=10, which makes the RoF2 spawn writer take its monster-race branch
	// (a 60-byte tail with no equipment/tint block). The client parses its own
	// spawn with the same branch, so the re-added self actor is rebuilt without
	// the player equipment block and ends up broken: feigned/sideways pose,
	// hidden gear and hotbars, and failed zone transitions. Reporting NPC=0
	// keeps both the writer and the client on the player branch.
	ns.spawn.NPC = 0;

	auto *app = new EQApplicationPacket(OP_Shroud, sizeof(ShroudSelf_Struct));
	auto *shroud = reinterpret_cast<ShroudSelf_Struct *>(app->pBuffer);
	shroud->spawn   = ns.spawn;
	shroud->profile = profile;
	client->FillShroudTransformExtras(shroud);
	client->QueuePacket(app);
}

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
	if (!RuleB(Custom, ShroudsEnabled)) {
		Message(Chat::Yellow, "Shrouds are not enabled on this server.");
		return false;
	}

	const auto shrouds = LoadAllShrouds();
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

	LogInfo("Shroud window opened for [{}] (npc [{}])", GetCleanName(), window->triggerNPCID);

	FastQueuePacket(&outapp);
	return true;
}

// Defined below (next to the other monster-point helpers); ApplyShroud grants the
// form's pool, so it needs the declaration up here.
static uint32 ShroudMonsterPointsForLevel(uint32 level);

void Client::ApplyShroud(uint32 shroud_id)
{
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
	m_shroud_zonein_pending = false;

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

	AppearanceStruct appearance{};
	appearance.race_id        = def.race;
	appearance.gender_id      = def.gender;
	appearance.texture        = def.texture;
	appearance.helmet_texture = def.helmet_texture;
	appearance.size           = def.size;
	appearance.send_effects   = true;

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

	// Send OP_Shroud (spawn + profile). The RoF2 encoder serializes both; this
	// is what completes the client's transition.
	{
		m_pp.cur_hp    = GetHP();
		m_pp.mana      = current_mana;
		m_pp.endurance = current_endurance;

		SendShroudTransform(this, m_pp, def.size);
		ShroudDiag("ApplyShroud sent OP_Shroud: mob(race=%u gender=%u class=%u lvl=%u "
		           "texture=%u helm=%u size=%.1f) def.size=%.1f",
		           race, gender, class_, level, texture, helmtexture, size, def.size);
		// The client's spawn re-add resets its displayed HP to the wire
		// max_hp byte (100); refresh the real HP afterwards.
		SendHPUpdate();
	}

	// Apply the shroud appearance last so the profile load cannot overwrite it.
	SendIllusionPacket(appearance);

	// Live-like mode: refresh the AA window now that shroud AAs (categories
	// 3/4) are usable and the points pool has changed, and push the applied
	// template's stats so the monster ability window populates.
	if (live_mode) {
		SendAlternateAdvancementTable();
		SendAlternateAdvancementPoints();
		SendAlternateAdvancementStats();
		SendShroudRespondStats(this, def);
		SendShroudProgress(this, def);
		SendShroudPointsPackets(this, def.id);
	}

	Message(Chat::Yellow, "You take on the form of %s.", def.name.c_str());

	LogInfo(
		"Client [{}] shrouded as [{}] (id [{}])",
		GetCleanName(),
		def.name,
		def.id
	);
}

void Client::RemoveShroud(bool send_updates)
{
	if (!m_shrouded) {
		return;
	}

	if (m_shroud_saved_valid) {
		m_pp = m_shroud_saved_pp;
		m_shroud_saved_valid = false;
	}

	m_shrouded  = false;
	m_shroud_id = 0;
	m_shroud_zonein_pending = false;

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

	// Put the real identity and appearance back on the mob BEFORE serializing
	// the spawn: FillSpawnStruct copies these from the mob, so without this the
	// re-sent OP_Shroud still carries the shroud's model and the client keeps
	// the form (gear hidden) while the profile says otherwise.
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

	// Re-send OP_Shroud carrying the restored real profile. The client's
	// shroud apply (eqgame+0x4C2EA0) is the only verb that rewrites its
	// in-memory character profile; without it the client keeps the shroud's
	// class/race/level and every class-gated UI element (spell bar, combat
	// window, hotbars) stays broken until zone-in.
	m_pp.cur_hp    = GetHP();
	m_pp.mana      = current_mana;
	m_pp.endurance = current_endurance;

	SendShroudTransform(this, m_pp, m_shroud_saved_size);
	ShroudDiag("RemoveShroud sent OP_Shroud: mob(race=%u gender=%u class=%u lvl=%u texture=%u helm=%u size=%.1f)",
	           race, gender, class_, level, texture, helmtexture, size);

	// Stand up: the shroud/transform cycle can leave the client showing the
	// feign/lying state.
	SendAppearancePacket(AppearanceType::Animation, Animation::Standing);

	// Restore the illusion with the real appearance (a zeroed AppearanceStruct
	// does not reliably clear a monster-race form).
	AppearanceStruct appearance{};
	appearance.race_id        = m_pp.race;
	appearance.gender_id      = m_pp.gender;
	appearance.texture        = m_shroud_saved_texture;
	appearance.helmet_texture = m_shroud_saved_helmtexture;
	appearance.size           = m_shroud_saved_size;
	appearance.send_effects   = true;
	SendIllusionPacket(appearance);

	// Live-like mode: restore the real AA window (shroud ranks were purged).
	if (RuleI(Custom, ShroudLiveMode) & 4) {
		SendAlternateAdvancementTable();
		SendAlternateAdvancementPoints();
		SendAlternateAdvancementStats();
	}

	Message(Chat::Yellow, "You return to your natural form.");
}

void Client::SaveShroudSnapshot(uint32 shroud_id)
{
	if (!m_shroud_saved_valid) {
		return;
	}

	const PlayerProfile_Struct& p = m_shroud_saved_pp;
	const std::string query = fmt::format(
		"REPLACE INTO `character_shroud_snapshot` "
		"(`character_id`,`shroud_id`,`race`,`gender`,`class`,`level`,`texture`,`helmet_texture`,`size`) "
		"VALUES ({},{},{},{},{},{},{},{},{})",
		CharacterID(),
		shroud_id,
		p.race,
		p.gender,
		p.class_,
		p.level,
		m_shroud_saved_texture,
		m_shroud_saved_helmtexture,
		m_shroud_saved_size
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

	// Classic shroud categories, or any line the content mapping references, or
	// the original hand-made 90100-90199 test band.
	if (ability->category == AACategory::ShroudPassive
		|| ability->category == AACategory::ShroudActive) {
		return true;
	}

	const auto &content = ShroudContentIds();
	if (content.find(ability->id) != content.end()) {
		return true;
	}

	return ability->id >= 90100 && ability->id <= 90199;
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

// Stamps the live-like overrides (rule bits, monster points, owned shroud AA
// ranks) onto the transform packet so ENCODE(OP_Shroud) can write them into
// the 20472-byte profile block.
void Client::FillShroudTransformExtras(ShroudSelf_Struct *shroud)
{
	if (!shroud) {
		return;
	}

	// Transform packets sent while NOT shrouded (the unshroud re-send) must
	// carry a clean block: flag bits stamped while a rule was flipped on would
	// otherwise keep the client's spellbook/AA swap or inventory hidden after
	// the form is removed.
	shroud->live_mode = m_shrouded ? static_cast<uint32>(RuleI(Custom, ShroudLiveMode)) : 0;
	shroud->monster_points       = m_shroud_points;
	shroud->monster_points_spent = m_shroud_points_spent;

	shroud->shroud_aa_count = 0;
	if (!(shroud->live_mode & 4) || !zone) {
		return;
	}

	for (const auto &entry : aa_ranks) {
		if (entry.second.first == 0) {
			continue;
		}

		auto *ability = zone->GetAlternateAdvancementAbility(entry.first);
		if (!IsShroudAA(ability)) {
			continue;
		}

		// Emit BOTH id forms (ability id + first rank id): the client's
		// ownership checks for the profile block's AA array have only been
		// partially decoded, and the forms cost nothing at this scale.
		const uint32 id_forms[2]  = {static_cast<uint32>(ability->id), ability->first_rank_id};
		const uint32 rank_spell   = static_cast<uint32>(ability->first->spell);
		for (int f = 0; f < 2; ++f) {
			if (shroud->shroud_aa_count >= ShroudSelf_Struct::kMaxShroudAAs) {
				break;
			}
			const uint32 n              = shroud->shroud_aa_count++;
			shroud->shroud_aa_ids[n]    = id_forms[f];
			shroud->shroud_aa_values[n] = entry.second.first;
			shroud->shroud_aa_spells[n] = rank_spell;
		}
	}
}

// Called once on zone-in. If the character has a persisted shroud, re-apply it:
// shrouds survive zoning/relogging and are only removed at the Shroudkeeper. A
// legacy row with shroud_id 0 (written before persistence existed) is cleared.
void Client::LoadAndApplyShroudState()
{
	const std::string query = fmt::format(
		"SELECT `shroud_id`,`race`,`gender`,`class`,`level`,`texture`,`helmet_texture`,`size` "
		"FROM `character_shroud_snapshot` WHERE `character_id` = {} LIMIT 1",
		CharacterID()
	);

	auto results = database.QueryDatabase(query);
	if (!results.Success() || results.RowCount() == 0) {
		return;
	}

	auto row = results.begin();
	const uint32 shroud_id = Strings::ToUnsignedInt(row[0]);

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

	// The RoF2 client crashes if OP_Shroud arrives while it is still building
	// the zone (its self-spawn re-add dereferences a null local player).
	// Defer the packet send until Process() sees the zone settle.
	m_shroud_zonein_pending = true;
	m_shroud_zonein_at      = Timer::GetTimeSeconds() + 3;

	LogInfo(
		"Client [{}] has a persisted shroud [{}]; client re-apply deferred to zone settle",
		GetCleanName(),
		shroud_id
	);
}

// Delivers the current shroud state to this client (used by the deferred
// zone-in path). The mob appearance and profile were already put in place
// when the shroud was applied; this only sends the client-visible packets.
void Client::ResendShroudState()
{
	m_shroud_zonein_pending = false;

	// Live-like mode: re-mirror the session's purchases BEFORE the transform
	// so the profile block's AA array (written at transform time) carries the
	// owned shroud ranks. The connect sequence ran ClearAAs + the real-AA
	// reload after this shroud's points were loaded.
	if (RuleI(Custom, ShroudLiveMode) & 4) {
		ShroudReapplyPurchases(false);
	}

	m_pp.cur_hp    = GetHP();
	m_pp.mana      = current_mana;
	m_pp.endurance = current_endurance;

	SendShroudTransform(this, m_pp, size);
	SendHPUpdate();

	AppearanceStruct appearance{};
	appearance.race_id        = race;
	appearance.gender_id      = gender;
	appearance.texture        = texture;
	appearance.helmet_texture = helmtexture;
	appearance.size           = size;
	appearance.send_effects   = true;
	SendIllusionPacket(appearance);

	ShroudDefinition def;
	if (LoadShroud(m_shroud_id, def)) {
		Message(Chat::Yellow, "You are still shrouded as %s.", def.name.c_str());

		// Rebuild this form's guide-content gate *before* the AA table goes out.
		// Without this the marks still describe the previously worn form (or are
		// empty), and the client keeps those rows: that is how an Air Elemental
		// Illusionist ended up listing a Sporali's fungal lines after zoning while
		// shrouded.
		LoadShroudAbilityCaps(def.progression, def.branch, def.level);
	}

	// Live-like mode: purchases were re-mirrored above (before the transform);
	// refresh the AA window with the full shroud-aware data set.
	if (RuleI(Custom, ShroudLiveMode) & 4) {
		SendAlternateAdvancementTable();
		SendAlternateAdvancementPoints();
		SendAlternateAdvancementStats();
		if (def.id != 0) {
			SendShroudRespondStats(this, def);
			SendShroudProgress(this, def);
			SendShroudPointsPackets(this, def.id);
		}
	}

	LogInfo("Client [{}] re-applied persisted shroud [{}] after zone settle", GetCleanName(), m_shroud_id);
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
	LogInfo("Client [{}] OP_ShroudSelectCancel (size [{}])", GetCleanName(), app->size);
	RemoveShroud();
}

void Client::Handle_OP_ShroudRequestStats(const EQApplicationPacket* app)
{
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


