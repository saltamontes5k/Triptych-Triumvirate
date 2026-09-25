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
std::string BuildShroudStatsBlob(const ShroudDefinition& def)
{
	// The client's field reader (eqgame+0x413C10 -> eqgame+0x5CA570) splits on
	// '^' (0x5E); a trailing delimiter after the last field is harmless.
	const char sep = '^';

	auto token = [](const std::string& s, char delimiter) {
		std::string t = s;
		t.push_back(delimiter);
		return t;
	};

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

	blob += token("0", sep); // abilities array count
	blob += "0";             // equipment array count (terminates the stream)

	return blob;
}

} // namespace

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

	ClearShroudSnapshot();

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

	m_pp.race   = def.race;
	m_pp.gender = def.gender;
	m_pp.class_ = def.class_id;
	m_pp.level  = def.level;

	race        = def.race;
	gender      = def.gender;
	class_      = def.class_id;
	texture     = def.texture;
	helmtexture = def.helmet_texture;
	if (def.size > 0.0f) {
		size = def.size;
	}

	SetLevel(def.level);
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

	const std::string blob = BuildShroudStatsBlob(def);

	auto* outapp = new EQApplicationPacket(OP_ShroudRespondStats, 8 + static_cast<uint32>(blob.length()));
	auto* header = reinterpret_cast<uint32*>(outapp->pBuffer);
	header[0] = def.id; // template id (handed to the client's UI update)
	header[1] = 1;      // payload present -- must be nonzero or the client skips parsing
	memcpy(outapp->pBuffer + 8, blob.data(), blob.length());

	FastQueuePacket(&outapp);
}


