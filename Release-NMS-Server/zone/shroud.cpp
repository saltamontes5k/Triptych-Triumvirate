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
// Shrouds page consumes. The exact grammar for RoF2 is not documented by any
// working server; this mirrors the format recovered from the zeklabs prototype
// and is expected to be tuned against a packet capture.
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

// Builds the OP_ShroudRespondStats payload body for one template. The client
// deserializer (eqgame+0x5CA570) reads a stream of NUL-terminated text tokens:
//   id, name, description, then 12 numeric template fields (class animation,
//   level, hp, mana, endurance, str, sta, cha, dex, int, agi, wis), then two
//   array counts (abilities, equipment). The packet is an 8-byte header
//   (count, flag) followed by this token stream.
std::string BuildShroudStatsBlob(const ShroudDefinition& def)
{
	auto token = [](const std::string& s) {
		std::string t = s;
		t.push_back('\0');
		return t;
	};

	std::string blob;
	blob += token(std::to_string(def.id));
	blob += token(def.name);
	blob += token(fmt::format("Shroud form of {}", def.name));

	blob += token(std::to_string(def.class_id)); // class animation id
	blob += token(std::to_string(def.level));
	blob += token(std::to_string(def.hp));
	blob += token(std::to_string(def.mana));
	blob += token(std::to_string(def.endurance));
	blob += token("100"); // strength
	blob += token("100"); // stamina
	blob += token("100"); // charisma
	blob += token("100"); // dexterity
	blob += token("100"); // intelligence
	blob += token("100"); // agility
	blob += token("100"); // wisdom

	blob += token("0"); // abilities array count
	blob += token("0"); // equipment array count

	return blob;
}

} // namespace

bool Client::OpenShroudWindow(Mob* npc)
{
	const auto shrouds = LoadAllShrouds();

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

	std::string printable = tree;
	for (auto& ch : printable) {
		if (ch == '\a') {
			ch = '|';
		}
	}
	LogInfo("Shroud window for [{}] (npc [{}]): [{}]", GetCleanName(), window->triggerNPCID, printable);

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

	if (!m_shrouded) {
		m_shroud_saved_pp    = m_pp;
		m_shroud_saved_valid = true;
		SaveShroudSnapshot();
	}

	// Mark shrouded before touching the profile so a save during the transform
	// (or afterwards) restores the real profile instead of persisting the shroud.
	m_shrouded  = true;
	m_shroud_id = shroud_id;

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

		NewSpawn_Struct ns{};
		FillSpawnStruct(&ns, this);
		auto* shroud_app = new EQApplicationPacket(OP_Shroud, sizeof(ShroudSelf_Struct));
		auto* shroud     = reinterpret_cast<ShroudSelf_Struct*>(shroud_app->pBuffer);
		shroud->spawn    = ns.spawn;
		shroud->profile  = m_pp;
		QueuePacket(shroud_app);
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

	ClearShroudSnapshot();

	if (!send_updates) {
		return;
	}

	// Reset the illusion to the character's base profile.
	AppearanceStruct appearance{};
	SendIllusionPacket(appearance);

	SetLevel(m_pp.level);
	CalcBonuses();
	SetMaxHP();
	SendHPUpdate();

	Message(Chat::Yellow, "You return to your natural form.");
}

void Client::SaveShroudSnapshot()
{
	if (!m_shroud_saved_valid) {
		return;
	}

	const PlayerProfile_Struct& p = m_shroud_saved_pp;
	const std::string query = fmt::format(
		"REPLACE INTO `character_shroud_snapshot` (`character_id`,`race`,`gender`,`class`,`level`) "
		"VALUES ({},{},{},{},{})",
		CharacterID(),
		p.race,
		p.gender,
		p.class_,
		p.level
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

bool Client::RestoreShroudSnapshot()
{
	const std::string query = fmt::format(
		"SELECT `race`,`gender`,`class`,`level` FROM `character_shroud_snapshot` WHERE `character_id` = {} LIMIT 1",
		CharacterID()
	);

	auto results = database.QueryDatabase(query);
	if (!results.Success() || results.RowCount() == 0) {
		return false;
	}

	auto row = results.begin();
	m_pp.race   = static_cast<uint16>(Strings::ToInt(row[0]));
	m_pp.gender = static_cast<uint8>(Strings::ToInt(row[1]));
	m_pp.class_ = static_cast<uint8>(Strings::ToInt(row[2]));
	m_pp.level  = static_cast<uint8>(Strings::ToInt(row[3]));

	race   = m_pp.race;
	gender = m_pp.gender;
	class_ = m_pp.class_;
	SetLevel(m_pp.level);

	ClearShroudSnapshot();

	LogInfo(
		"Restored shroud snapshot for [{}]: race [{}] class [{}] level [{}]",
		GetCleanName(),
		m_pp.race,
		m_pp.class_,
		m_pp.level
	);

	return true;
}

void Client::Handle_OP_Shroud(const EQApplicationPacket* app)
{
	Message(Chat::Yellow, "[shroud] recv OP_Shroud (size %u)", app->size);
	LogInfo(
		"Client [{}] sent OP_Shroud (size [{}])",
		GetCleanName(),
		app->size
	);
}

void Client::Handle_OP_ShroudSelect(const EQApplicationPacket* app)
{
	if (app->size < sizeof(uint32)) {
		Message(Chat::Yellow, "[shroud] recv OP_ShroudSelect too small (size %u)", app->size);
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

	Message(Chat::Yellow, "[shroud] recv OP_ShroudSelect id %u size %u", shroud_id, app->size);
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

	ApplyShroud(shroud_id);
}

void Client::Handle_OP_ShroudSelectCancel(const EQApplicationPacket* app)
{
	Message(Chat::Yellow, "[shroud] recv OP_ShroudSelectCancel (size %u)", app->size);
	LogInfo("Client [{}] OP_ShroudSelectCancel (size [{}])", GetCleanName(), app->size);
	RemoveShroud();
}

void Client::Handle_OP_ShroudRequestStats(const EQApplicationPacket* app)
{
	uint32 requested_id = 0;
	if (app->size >= sizeof(uint32)) {
		requested_id = *reinterpret_cast<const uint32*>(app->pBuffer);
	}

	Message(Chat::Yellow, "[shroud] recv OP_ShroudRequestStats id %u size %u", requested_id, app->size);
	LogInfo(
		"Client [{}] OP_ShroudRequestStats: size [{}] requested_id [{}]",
		GetCleanName(),
		app->size,
		requested_id
	);

	ShroudDefinition def;
	if (!LoadShroud(requested_id, def)) {
		Message(Chat::Red, "[shroud] no template for id %u", requested_id);
		return;
	}

	const std::string blob = BuildShroudStatsBlob(def);

	auto* outapp = new EQApplicationPacket(OP_ShroudRespondStats, 8 + static_cast<uint32>(blob.length()));
	auto* header = reinterpret_cast<uint32*>(outapp->pBuffer);
	header[0] = 1; // template count
	header[1] = 1; // has template payload
	memcpy(outapp->pBuffer + 8, blob.data(), blob.length());

	FastQueuePacket(&outapp);
}


