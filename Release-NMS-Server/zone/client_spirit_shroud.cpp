// Native RoF2 Spirit Shroud protocol service.
//
// Ported from nightstalker6669/EQEmu rof2-spirit-shrouds (commit e7cb5dc,
// GPLv3) and adapted to this server:
//   * opcode names follow our patch_RoF2.conf harvest -- the alias table is in
//     reference/nsqemu-spirit-shrouds/AUDIT-EQS.md (their OP_SpiritShroud* are
//     the same wire values as our OP_Shroud* family);
//   * storage is re-keyed to the character without the upstream
//     session/escrow machinery (no shroud_original_* swap, no sessions);
//   * enter/restore ride the proven shroud snapshot path (zone/shroud.cpp)
//     instead of the upstream row-swap engine: the original profile stays
//     persisted via the ordinary Save guard and the form is in-memory;
//   * catalog storage lives in the content database (spirit_shroud_templates
//     family), ledgers in the player database (spirit_shroud_* state family).
// Gated by Custom:EnableSpiritShrouds; the legacy quest shroud path
// (Custom:ShroudsEnabled / zone/shroud.cpp) is untouched.

#include "client.h"
#include "entity.h"
#include "merc.h"
#include "npc.h"
#include "zone.h"
#include "groups.h"
#include "raids.h"
#include "aa.h"
#include "aa_ability.h"
#include "zonedb.h"
#include "../common/rulesys.h"
#include "../common/eqemu_config.h"
#include "../common/eqemu_logsys.h"
#include "../common/shroud/catalog.h"
#include "../common/shroud/aa_preview.h"
#include "../common/shroud/ability_cast.h"
#include "../common/shroud/experience.h"
#include "../common/shroud/starter_inventory.h"
#include "../common/shroud/resource_baseline.h"
#include "../common/patches/rof2.h"
#include "../common/opcodemgr.h"

#include <algorithm>
#include <array>
#include <cmath>
#include <cstring>
#include <ctime>
#include <limits>
#include <map>
#include <memory>
#include <optional>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>

extern Zone *zone;

// zone/shroud.cpp: builds and queues the OP_Shroud self-transform (spawn
// block + profile block); the native path reuses it unchanged.
void SendShroudTransform(Client *client, const PlayerProfile_Struct &profile, float size);

namespace {

using SpiritShroud::Bytes;
using SpiritShroud::Template;
using SpiritShroud::Put32;
using SpiritShroud::Put64;
using SpiritShroud::Text;
using SpiritShroud::Token;
using SpiritShroud::Read32;

// Builds a native serialized item preview (ordinary RoF2 ItemPtr, no
// ItemPacket type dword).
std::unique_ptr<EQ::ItemInstance> CreateShroudItem(Client &c, uint32 item_id, int16 charges = 1)
{
	return std::unique_ptr<EQ::ItemInstance>(database.CreateItem(item_id, charges));
}

auto Q(Database &db, const std::string &sql)
{
	if (db.GetStatus() != DBcore::Connected) {
		throw std::runtime_error("shroud database disconnected");
	}
	auto r = db.QueryDatabase(sql, false);
	if (!r.Success()) {
		throw std::runtime_error("shroud storage query failed: " + r.ErrorMessage());
	}
	return r;
}

uint64_t N(const char *text)
{
	if (!text || !*text) {
		throw std::runtime_error("shroud null number");
	}
	std::string s(text);
	size_t end = 0;
	auto v = std::stoull(s, &end);
	if (end != s.size() || s[0] == '-') {
		throw std::runtime_error("shroud invalid number");
	}
	return v;
}

std::string S(uint64_t n) { return std::to_string(n); }

void Send(Client &c, EmuOpcode opcode, const Bytes &b)
{
	EQApplicationPacket p(opcode, b.size());
	if (!b.empty()) {
		std::memcpy(p.pBuffer, b.data(), b.size());
	}
	c.QueuePacket(&p);
}

// The keeper is the NPC the native menu was opened from; every protocol
// message is bound to it while the 120-second menu window lasts.
bool Keeper(Client &c, uint32_t expected = 0)
{
	auto *npc = c.GetTarget();
	if (!zone || !npc || !npc->IsNPC() || (expected && expected != npc->GetID())) {
		return false;
	}
	return c.CalculateDistance(npc->GetX(), npc->GetY(), npc->GetZ()) <= 40.0f;
}

// Catalog from the content database (spirit_shroud_templates family).
std::vector<Template> Catalog(uint32_t only_id = 0, bool include_disabled = false)
{
	auto rows = Q(content_db,
		"SELECT id,progression_id,branch_id,level,race,class_id,gender,hp,mana,endurance,base_stat,unlock_xp,"
		"name,description,progression_name,branch_name,content_version,verified,test_only,evidence_ref,"
		"monster_points,entitlement_key,COALESCE(stat_str,base_stat),COALESCE(stat_sta,base_stat),"
		"COALESCE(stat_cha,base_stat),COALESCE(stat_dex,base_stat),COALESCE(stat_int,base_stat),"
		"COALESCE(stat_agi,base_stat),COALESCE(stat_wis,base_stat),native_hp,native_mana,native_endurance,"
		"native_hp_regen,native_mana_regen_sitting,native_mana_regen_standing,native_endurance_regen,"
		"native_cold,native_fire,native_magic,native_disease,native_poison,native_additional_resist,"
		"native_corruption,native_ac,native_attack,native_unarmed_damage,native_unarmed_delay,"
		"resource_maxima,model_size FROM spirit_shroud_templates" +
		std::string(only_id ? " WHERE id=" + S(only_id) : (include_disabled ? "" : " WHERE enabled=1")) +
		" ORDER BY progression_id,branch_id,level,id LIMIT 1001");
	if (rows.RowCount() > 1000) {
		throw std::runtime_error("shroud catalog too large");
	}

	auto presentation_columns = Q(content_db,
		"SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() "
		"AND TABLE_NAME='spirit_shroud_abilities' AND COLUMN_NAME IN "
		"('display_rank','display_max_rank','display_total_cost')");
	const bool has_presentations = N((*presentation_columns.begin())[0]) == 3;

	std::vector<Template> out;
	for (auto r = rows.begin(); r != rows.end(); ++r) {
		Template t;
		uint32_t *values[] = {
			&t.id, &t.progression, &t.branch, &t.level, &t.race, &t.class_id, &t.gender,
			&t.hp, &t.mana, &t.endurance, &t.stat, &t.unlock_xp
		};
		for (unsigned i = 0; i < 12; ++i) {
			auto n = N(r[i]);
			if (n > UINT32_MAX) {
				throw std::runtime_error("shroud catalog overflow");
			}
			*values[i] = uint32_t(n);
		}
		t.name             = r[12] ? r[12] : "";
		t.description      = r[13] ? r[13] : "";
		t.progression_name = r[14] ? r[14] : "";
		t.branch_name      = r[15] ? r[15] : "";
		t.content_version  = uint32_t(N(r[16]));
		t.verified         = N(r[17]) != 0;
		t.test_only        = N(r[18]) != 0;
		t.evidence_ref     = r[19] ? r[19] : "";
		t.monster_points   = uint32_t(N(r[20]));
		t.entitlement_key  = r[21] ? r[21] : "";
		for (unsigned i = 0; i < 7; ++i) {
			auto v = N(r[22 + i]);
			if (v > 1000) {
				throw std::runtime_error("shroud attribute overflow");
			}
			t.attributes[i] = uint32_t(v);
		}
		t.has_native_stats = true;
		for (unsigned i = 0; i < SpiritShroud::NativeStatCount; ++i) {
			if (!r[29 + i]) {
				t.has_native_stats = false;
				continue;
			}
			auto v = N(r[29 + i]);
			if (v > 1000000) {
				throw std::runtime_error("shroud native baseline overflow");
			}
			t.native_stats[i] = uint32_t(v);
		}
		t.has_native_resources = t.has_native_stats;
		t.resource_maxima      = N(r[47]) != 0;
		t.model_size           = r[48] ? std::stof(r[48]) : 0.0f;

		if (t.resource_maxima) {
			auto base = zone->GetBaseData(uint8_t(t.level), uint8_t(t.class_id));
			if (base.level != t.level) {
				throw std::runtime_error("shroud class base data missing");
			}
			auto terms = SpiritShroud::ResourceContributions(
				t.attributes, t.hp, t.mana, t.endurance, t.class_id,
				base.hp_fac, base.mana_fac, base.end_fac);
			t.native_stats[SpiritShroud::HP]       = terms[0];
			t.native_stats[SpiritShroud::Mana]     = terms[1];
			t.native_stats[SpiritShroud::Endurance] = terms[2];
			// Unmeasured combat baselines remain the emulator defaults. Do not
			// interpret Live displayed AC/attack as native contributions.
			if (!t.has_native_stats) {
				for (auto field : { SpiritShroud::Cold, SpiritShroud::Fire, SpiritShroud::Magic }) {
					t.native_stats[field] = 25;
				}
				for (auto field : { SpiritShroud::Disease, SpiritShroud::Poison,
					SpiritShroud::AdditionalResist, SpiritShroud::Corruption }) {
					t.native_stats[field] = 15;
				}
				t.native_stats[SpiritShroud::HPRegen]        = static_cast<uint32_t>(base.hp_regen);
				t.native_stats[SpiritShroud::EnduranceRegen] = static_cast<uint32_t>(base.end_regen);
			}
			t.has_native_resources = true;
		}

		auto aa = Q(content_db,
			"SELECT a.rank_id,r.title_sid,a.free_grant" +
			std::string(has_presentations ? ",a.display_rank,a.display_max_rank,a.display_total_cost" : "") +
			" FROM spirit_shroud_abilities a LEFT JOIN aa_ranks r ON r.id=a.rank_id WHERE a.template_id=" +
			S(t.id) + " ORDER BY a.rank_id LIMIT 301");
		if (aa.RowCount() > 300) {
			throw std::runtime_error("shroud AA count too large");
		}
		for (auto row = aa.begin(); row != aa.end(); ++row) {
			auto rank  = N(row[0]);
			auto title = N(row[1]);
			if (rank > INT32_MAX || title > INT32_MAX) {
				throw std::runtime_error("shroud AA overflow");
			}
			t.abilities.push_back(uint32_t(rank));
			t.ability_names.push_back(uint32_t(title));
			if (N(row[2])) {
				t.free_abilities.push_back(uint32_t(rank));
			}
			if (has_presentations && N(row[3])) {
				auto current = N(row[3]);
				auto maximum = N(row[4]);
				auto cost    = N(row[5]);
				if (current > 1000 || maximum > 1000 || cost > 1000000) {
					throw std::runtime_error("shroud rank presentation overflow");
				}
				t.rank_presentations.push_back({uint32_t(rank), uint32_t(current), uint32_t(maximum), uint32_t(cost)});
			}
		}

		auto equipment = Q(content_db,
			"SELECT DISTINCT e.item_id,i.name FROM spirit_shroud_starter_equipment e "
			"LEFT JOIN items i ON i.id=e.item_id WHERE e.template_id=" + S(t.id) +
			" ORDER BY e.item_id LIMIT 51");
		for (auto item = equipment.begin(); item != equipment.end(); ++item) {
			auto id = N(item[0]);
			if (id > UINT32_MAX || !item[1]) {
				throw std::runtime_error("shroud equipment definition missing");
			}
			t.equipment.push_back({uint32_t(id), item[1]});
		}

		SpiritShroud::Validate(t);
		for (const auto &item : t.rank_presentations) {
			if (!SpiritShroud::CapturedPresentation(t, zone->GetAlternateAdvancementRank(item.rank_id))) {
				throw std::runtime_error("invalid compressed shroud rank adapter");
			}
		}
		out.push_back(std::move(t));
	}
	return out;
}

bool Offered(Client &c, const Template &t)
{
	if (!SpiritShroud::Offered(t, RuleB(Custom, AllowTestSpiritShrouds))) {
		return false;
	}
	// Retained templates remain restorable; only new entry uses progression gates.
	if (!t.test_only) {
		auto branch = Q(content_db,
			"SELECT b.unlock_xp FROM spirit_shroud_branch_progression b "
			"JOIN spirit_shroud_progression_definitions d ON d.progression_id=b.progression_id "
			"AND d.definition_version=b.definition_version WHERE b.progression_id=" +
			S(t.progression) + " AND b.branch_id=" + S(t.branch));
		if (branch.RowCount() != 1 || !branch.begin()[0]) {
			return false;
		}
		auto progress = Q(database,
			"SELECT experience FROM spirit_shroud_progress WHERE character_id=" +
			S(c.CharacterID()) + " AND progression_id=" + S(t.progression));
		const auto xp = progress.RowCount() ? N(progress.begin()[0]) : 0;
		if (xp < N(branch.begin()[0]) || xp < t.unlock_xp) {
			return false;
		}
	}
	if (t.entitlement_key.empty()) {
		return true;
	}
	auto owned = Q(database,
		"SELECT character_id FROM spirit_shroud_entitlements WHERE character_id=" +
		S(c.CharacterID()) + " AND entitlement_key='" + database.Escape(t.entitlement_key) + "'");
	return owned.RowCount() == 1;
}

uint64_t Progress(Database &db, uint32_t character, uint32_t progression)
{
	auto r = Q(db,
		"SELECT experience FROM spirit_shroud_progress WHERE character_id=" + S(character) +
		" AND progression_id=" + S(progression));
	return r.RowCount() ? N(r.begin()[0]) : 0;
}

constexpr const char *ExperienceColumns =
	"normal_exp,aa_exp,aa_points,aa_spent,level,level2,skill_points,percent_to_aa,aa_unit,max_level,thresholds_json";

template<typename Row>
SpiritShroud::ExperienceState ReadExperience(Row row)
{
	SpiritShroud::ExperienceState state;
	state.normal = N(row[0]);
	state.aa     = N(row[1]);
	uint32_t *fields[] = {
		&state.aa_points, &state.aa_spent, &state.level, &state.level2, &state.skill_points,
		&state.percent_to_aa, &state.aa_unit, &state.max_level
	};
	for (unsigned i = 0; i < std::size(fields); ++i) {
		auto value = N(row[i + 2]);
		if (value > UINT32_MAX) {
			throw std::runtime_error("shroud experience overflow");
		}
		*fields[i] = uint32_t(value);
	}
	if (!row[10] || std::char_traits<char>::length(row[10]) > 4096) {
		throw std::runtime_error("shroud thresholds missing");
	}
	auto thresholds = nlohmann::json::parse(row[10]);
	if (!thresholds.is_array() || thresholds.size() > 128) {
		throw std::runtime_error("shroud thresholds malformed");
	}
	for (const auto &value : thresholds) {
		if (!value.is_number_unsigned() || value.template get<uint64_t>() > UINT32_MAX) {
			throw std::runtime_error("shroud threshold overflow");
		}
		state.thresholds.push_back(value.template get<uint32_t>());
	}
	SpiritShroud::ValidateExperience(state);
	return state;
}

std::string ExperienceValues(Database &db, const SpiritShroud::ExperienceState &state)
{
	return S(state.normal) + "," + S(state.aa) + "," + S(state.aa_points) + "," + S(state.aa_spent) + "," +
		S(state.level) + "," + S(state.level2) + "," + S(state.skill_points) + "," + S(state.percent_to_aa) + "," +
		S(state.aa_unit) + "," + S(state.max_level) + ",'" +
		db.Escape(nlohmann::json(state.thresholds).dump()) + "'";
}

void CaptureOriginalExperience(Client &c, SpiritShroud::ExperienceState &experience)
{
	experience.normal     = c.GetEXP();
	experience.aa         = c.GetAAXP();
	experience.aa_points  = c.GetAAPoints();
	experience.aa_spent   = c.GetSpentAA();
	experience.level      = c.GetLevel();
	experience.level2     = c.GetPP().level2;
	experience.skill_points = c.GetPP().points;
	experience.percent_to_aa = c.GetLevel() > 50
		? std::min<uint32_t>(100, static_cast<uint32_t>(c.GetAAPercent()))
		: 0;
	experience.aa_unit    = c.GetRequiredAAExperience();
	auto maximum = RuleI(Character, MaxExpLevel);
	if (maximum < 1) {
		maximum = RuleI(Character, MaxLevel);
	}
	if (c.GetClientMaxLevel()) {
		maximum = c.GetClientMaxLevel();
	}
	// Never delevel an original character which already exceeds a changed cap.
	experience.max_level = std::max<int>(c.GetLevel(), maximum);
	if (!experience.max_level || experience.max_level > 126) {
		throw std::runtime_error("shroud original level cap invalid");
	}
	experience.thresholds.push_back(0);
	for (uint32_t level = 1; level <= experience.max_level + 1; ++level) {
		experience.thresholds.push_back(c.GetEXPForLevel(level));
	}
	SpiritShroud::ValidateExperience(experience);
}

} // namespace

// ------------------------------------------------------------------
// Native protocol handlers
// ------------------------------------------------------------------

void Client::OpenSpiritShrouds()
{
	if (!zone || m_spirit_shroud_transition || IsDead() || IsEngaged()) {
		return;
	}
	if (ClientVersion() != EQ::versions::ClientVersion::RoF2) {
		return;
	}
	try {
		if (IsSpiritShrouded()) {
			Message(Chat::Yellow, "You are already shrouded. Ask your keeper to remove the form.");
			return;
		}
		auto bank = Q(database,
			"SELECT slot_id FROM spirit_shroud_bank_inventory WHERE character_id=" +
			S(CharacterID()) + " LIMIT 1");
		if (bank.RowCount()) {
			Message(Chat::Yellow, "Empty your shroud bank before choosing another form.");
			return;
		}
		auto all = Catalog();
		if (all.empty()) {
			Message(Chat::Yellow, "No Spirit Shroud forms have been configured.");
			return;
		}
		std::string tree;
		uint32_t last_p = 0;
		uint32_t last_b = 0;
		for (auto &t : all) {
			if (t.level > GetLevel() || !Offered(*this, t)) {
				continue;
			}
			auto xp = Progress(database, CharacterID(), t.progression);
			if (last_p != t.progression) {
				tree += Token("PROGRESSION", '\a') + Token(S(t.progression), '\a') +
					Token(t.progression_name, '\a') + Token("Spirit Shroud progression", '\a');
				last_p = t.progression;
				last_b = 0;
			}
			if (last_b != t.branch) {
				tree += Token("BRANCH", '\a') + Token(S(t.branch), '\a') +
					Token(t.branch_name, '\a') + Token(t.description, '\a') + Token("100", '\a');
				last_b = t.branch;
			}
			tree += Token("TEMPLATE", '\a') + Token(t.name, '\a') + Token(S(t.level), '\a') +
				Token(S(t.id), '\a') + Token(xp >= t.unlock_xp ? "1" : "0", '\a');
		}
		if (tree.empty()) {
			Message(Chat::Yellow, "No verified Spirit Shroud forms are available.");
			return;
		}
		m_spirit_shroud_keeper     = GetTarget() ? GetTarget()->GetID() : 0;
		m_spirit_shroud_menu_until = uint64_t(std::time(nullptr)) + 120;
		Bytes out;
		Put32(out, m_spirit_shroud_keeper);
		Put32(out, 0);
		Put32(out, 0);
		Text(out, tree);
		Send(*this, OP_ShroudSelectionWindow, out);
	} catch (const std::exception &error) {
		LogError("Spirit Shroud catalog unavailable for character [{}]: [{}]", CharacterID(), error.what());
		Message(Chat::Red, "Spirit Shroud storage is unavailable. Your character has not changed.");
	}
}

void Client::Handle_OP_SpiritShroudRequest(const EQApplicationPacket *p)
{
	if (!RuleB(Custom, EnableSpiritShrouds) || !p || p->size != 4 || !Keeper(*this, m_spirit_shroud_keeper) ||
		uint64_t(std::time(nullptr)) > m_spirit_shroud_menu_until) {
		return;
	}
	try {
		auto id = Read32(p->pBuffer);
		for (auto &t : Catalog()) {
			if (t.id == id && Offered(*this, t) && t.level <= GetLevel()) {
				auto preview = SpiritShroud::SelectionAbilities(t, [](uint32_t rank) {
					return zone->GetAlternateAdvancementRank(rank);
				});
				Send(*this, OP_ShroudRespondStats, SpiritShroud::Details(t, &preview));
				return;
			}
		}
	} catch (const std::exception &error) {
		LogError("Spirit Shroud details rejected for character [{}]: [{}]", CharacterID(), error.what());
	}
}

void Client::Handle_OP_SpiritShroudSelect(const EQApplicationPacket *p)
{
	if (!RuleB(Custom, EnableSpiritShrouds) || !p || p->size != 4) {
		return;
	}
	if (uint64_t(std::time(nullptr)) <= m_spirit_shroud_menu_until &&
		Keeper(*this, m_spirit_shroud_keeper)) {
		ChangeSpiritShroud(Read32(p->pBuffer));
	}
	if (!m_spirit_shroud_transition && ClientVersion() == EQ::versions::ClientVersion::RoF2) {
		// RoF2 enters a modal item-operation wait before sending 0x1cd0. Its
		// empty 0x7786 completion clears that wait on a rejected/rolled-back
		// choice.
		const uint16 wire = (eqs && eqs->GetOpcodeManager())
			? eqs->GetOpcodeManager()->EmuToEQ(OP_SpiritShroudComplete)
			: 0;
		if (wire) {
			EQApplicationPacket finished(OP_Unknown, 0);
			finished.SetOpcodeBypass(wire);
			QueuePacket(&finished);
		}
	}
}

void Client::Handle_OP_SpiritShroudCancel(const EQApplicationPacket *p)
{
	if (p && p->size == 0) {
		m_spirit_shroud_keeper     = 0;
		m_spirit_shroud_menu_until = 0;
	}
}

void Client::Handle_OP_SpiritShroudPreview(const EQApplicationPacket *p)
{
	// Preview is bound to the offered template and its advertised ranks.
	if (!RuleB(Custom, EnableSpiritShrouds) || !p || p->size != 8 ||
		uint64_t(std::time(nullptr)) > m_spirit_shroud_menu_until ||
		!Keeper(*this, m_spirit_shroud_keeper)) {
		return;
	}
	if (p->GetOpcode() == OP_SpiritShroudEquipmentRequest) {
		const auto template_id = Read32(p->pBuffer);
		const auto item_id     = Read32(p->pBuffer + 4);
		try {
			for (const auto &t : Catalog()) {
				if (t.id != template_id || !Offered(*this, t) || t.level > GetLevel()) {
					continue;
				}
				auto allowed = std::find_if(t.equipment.begin(), t.equipment.end(),
					[&](const auto &item) { return item.item_id == item_id; });
				if (allowed == t.equipment.end()) {
					return;
				}
				auto item = CreateShroudItem(*this, item_id, 1);
				if (!item) {
					return;
				}
				auto serialized = RoF2::SerializeShroudPreviewItem(*item);
				if (!serialized) {
					return;
				}
				Bytes body;
				Put32(body, template_id);
				Put32(body, item_id);
				body.insert(body.end(), serialized->begin(), serialized->end());
				Send(*this, OP_ShroudPointsUpdate, body);
				return;
			}
		} catch (const std::exception &error) {
			LogError("Spirit Shroud equipment preview rejected for character [{}]: [{}]", CharacterID(), error.what());
		}
		return;
	}
	if (p->GetOpcode() != OP_SpiritShroudAbilityRequest) {
		return;
	}
	int32_t requested = int32_t(Read32(p->pBuffer));
	if (requested == INT32_MIN) {
		return;
	}
	auto template_id = uint32_t(requested < 0 ? -requested : requested);
	auto rank_id     = Read32(p->pBuffer + 4);
	try {
		for (auto &t : Catalog()) {
			if (t.id != template_id || !Offered(*this, t) || t.level > GetLevel() ||
				std::find(t.abilities.begin(), t.abilities.end(), rank_id) == t.abilities.end()) {
				continue;
			}
			auto *rank = zone->GetAlternateAdvancementRank(rank_id);
			if (!rank || !rank->base_ability) {
				return;
			}
			SendAlternateAdvancementRank(rank->base_ability->id, rank->current_value, &t);
			Bytes ready;
			Put32(ready, template_id);
			Put32(ready, rank_id);
			Send(*this, OP_ShroudStateUpdate, ready);
			return;
		}
	} catch (const std::exception &error) {
		LogError("Spirit Shroud ability preview rejected for character [{}]: [{}]", CharacterID(), error.what());
	}
}

// The client's modal item-operation wait is cleared by an empty C->S 0x7786
// only after it applied a transform; the server answer refreshes the resource
// displays. No completion state machine is kept on this server: the enter path
// is in-memory and the ordinary save guard keeps the real profile persisted.
void Client::Handle_OP_SpiritShroudComplete(const EQApplicationPacket *packet)
{
	if (!RuleB(Custom, EnableSpiritShrouds) || !packet || packet->size ||
		ClientVersion() != EQ::versions::ClientVersion::RoF2) {
		return;
	}
	UpdateWho();
	m_spirit_shroud_resource_refreshes = IsSpiritShrouded() ? 3 : 0;
	LogInfo("Spirit Shroud completion for character [{}], template [{}]", CharacterID(), m_spirit_shroud_template);
	SendHPUpdate(true);
	SendManaUpdate();
	SendEnduranceUpdate();
	if (IsSpiritShrouded()) {
		SendSpiritShroudProgress();
	}
}

bool Client::ProcessSpiritShroudCompletion()
{
	// Reserved for a future transactional enter; nothing to fence today.
	return true;
}

// ------------------------------------------------------------------
// In-memory AA helpers
// ------------------------------------------------------------------

namespace {

bool IsNativeStarterMarker(const EQ::ItemInstance *item, uint32_t template_id)
{
	if (!item) {
		return false;
	}
	const auto metadata = SpiritShroud::ReadStarterMetadata(item->GetCustomDataString());
	return metadata.session && *metadata.session == S(template_id);
}

} // namespace

// Mirror the ownership map into the profile array the compact profile block
// and the AA packets read (same shape as ResetAA's rebuild).
void Client::ShroudRebuildAAArray()
{
	uint32_t slot_id = 0;
	memset(&m_pp.aa_array[0], 0, sizeof(AA_Array) * MAX_PP_AA_ARRAY);
	for (const auto &rank_value : aa_ranks) {
		if (rank_value.second.first == 0) {
			continue;
		}
		if (slot_id >= MAX_PP_AA_ARRAY) {
			LogError("Native shroud AA rebuild for [{}] exceeded the profile AA array capacity",
				GetCleanName());
			break;
		}
		m_pp.aa_array[slot_id].AA      = rank_value.first;
		m_pp.aa_array[slot_id].value   = rank_value.second.first;
		m_pp.aa_array[slot_id].charges = rank_value.second.second;
		++slot_id;
	}
}

// Rebuild the ownership map from the profile array (restore path).
void Client::ShroudRebuildRanksFromPP()
{
	aa_ranks.clear();
	for (uint32_t slot = 0; slot < MAX_PP_AA_ARRAY; ++slot) {
		const auto &entry = m_pp.aa_array[slot];
		if (!entry.AA || !entry.value) {
			continue;
		}
		aa_ranks[entry.AA] = std::make_pair(int(entry.value), uint32_t(entry.charges));
	}
}

// ------------------------------------------------------------------
// Enter / restore
// ------------------------------------------------------------------

void Client::ChangeSpiritShroud(uint32_t id)
{
	if ((id && !RuleB(Custom, EnableSpiritShrouds)) ||
		ClientVersion() != EQ::versions::ClientVersion::RoF2 ||
		!Keeper(*this, m_spirit_shroud_keeper) || m_spirit_shroud_transition) {
		return;
	}
	if ((id && (IsSpiritShrouded() || m_shrouded)) || (!id && !IsSpiritShrouded())) {
		return;
	}
	if (IsDead() || GetHP() <= 0 || IsCasting() || HasActiveSong() || IsMezzed() || IsStunned() ||
		IsEngaged() || GetAggroCount() ||
		(GetPet() && (!GetPet()->IsNPC() || GetPet()->IsCharmed() || GetPet()->IsEngaged())) ||
		IsTrader() || IsBuyer() || IsLooting() || GetTradeskillObject() ||
		(trade && trade->state != TradeNone) || !GetInv().CursorEmpty() ||
		m_pp.copper_cursor || m_pp.silver_cursor || m_pp.gold_cursor || m_pp.platinum_cursor) {
		Message(Chat::Yellow,
			"Leave combat, stop casting or singing, release any charmed pet, close trading, and empty "
			"your item and coin cursor before changing forms.");
		return;
	}
	// Suspend through the existing lifecycle before taking the snapshot.
	if (auto *merc = GetMerc()) {
		if (GetMercenaryID() && !merc->Suspend()) {
			Message(Chat::Red, "Your mercenary could not be suspended; your form has not changed.");
			return;
		}
	}

	m_spirit_shroud_transition = true;
	try {
		if (id) {
			EnterNativeShroud(id);
		} else {
			RestoreNativeShroud();
		}
		m_spirit_shroud_transition = false;
	} catch (const std::exception &error) {
		m_spirit_shroud_transition = false;
		LogError("Spirit Shroud transition failed for character [{}]: [{}]", CharacterID(), error.what());
		Message(Chat::Red, "Your form has not changed. Check your Spirit Shroud storage.");
	}
}

void Client::EnterNativeShroud(uint32_t template_id)
{
	auto all = Catalog(template_id);
	if (all.size() != 1) {
		throw std::runtime_error("shroud template missing");
	}
	const Template &t = all.front();
	if (!Offered(*this, t) || t.level > GetLevel()) {
		throw std::runtime_error("shroud template not available");
	}
	if (Progress(database, CharacterID(), t.progression) < t.unlock_xp) {
		throw std::runtime_error("shroud template progression locked");
	}
	if (IsSpiritShrouded() || m_shrouded) {
		throw std::runtime_error("shroud state changed");
	}

	// Snapshot the real profile (same mechanism as the quest path: the ordinary
	// save guard keeps the original persisted, the form is in-memory only).
	m_shroud_saved_pp          = m_pp;
	m_shroud_saved_valid       = true;
	m_shroud_saved_texture     = texture;
	m_shroud_saved_helmtexture = helmtexture;
	m_shroud_saved_size        = size;
	SaveShroudSnapshot(t.id, true);

	m_shrouded            = true;
	m_shroud_id           = 0; // native forms are keyed by m_spirit_shroud_template
	m_shroud_zonein_pending = false;
	m_spirit_shroud_template  = t.id;
	m_spirit_shroud_definition = std::make_shared<const Template>(t);
	m_spirit_shroud_aa_ranks.clear();
	for (auto rank_id : t.abilities) {
		m_spirit_shroud_aa_ranks.insert(rank_id);
	}
	m_pp.shroud_native_stats_valid   = t.has_native_stats;
	m_pp.shroud_native_resources_valid = t.has_native_resources || t.has_native_stats;
	std::copy(t.native_stats.begin(), t.native_stats.end(), m_pp.shroud_native_stats);

	// The form owns ONLY its monster ranks: the real AA set returns from the
	// snapshot on restore (and on every zone-in from the persisted profile).
	aa_ranks.clear();
	memset(&m_pp.aa_array[0], 0, sizeof(AA_Array) * MAX_PP_AA_ARRAY);

	uint64_t allocated_spent = 0;
	auto allocations = Q(database,
		"SELECT ability_id,rank_id,paid_points FROM spirit_shroud_allocations WHERE character_id=" +
		S(CharacterID()) + " AND template_id=" + S(t.id));
	for (auto row = allocations.begin(); row != allocations.end(); ++row) {
		const auto ability_id = N(row[0]);
		const auto rank_id    = N(row[1]);
		allocated_spent += N(row[2]);
		auto *rank = zone->GetAlternateAdvancementRank(rank_id);
		if (rank && rank->base_ability && rank->base_ability->id == ability_id) {
			SetAA(ability_id, rank->current_value, 0);
		}
	}

	for (auto rank_id : t.abilities) {
		auto *rank = zone->GetAlternateAdvancementRank(rank_id);
		if (!rank || !rank->base_ability || rank->cost < 0 ||
			(rank->base_ability->category != AACategory::ShroudPassive &&
				rank->base_ability->category != AACategory::ShroudActive) ||
			rank->level_req > t.level ||
			!(rank->base_ability->classes & (1U << t.class_id))) {
			throw std::runtime_error("invalid shroud AA definition");
		}
		if (std::find(t.free_abilities.begin(), t.free_abilities.end(), rank_id) == t.free_abilities.end()) {
			continue; // paid ranks restore from allocations only
		}
		SetAA(rank->base_ability->id, rank->current_value, 0);
	}
	ShroudRebuildAAArray();

	// The form's pool is the real AA pool while transformed (upstream model):
	// monster points are aapoints, purchases charge aapoints_spent.
	m_pp.aapoints      = t.monster_points;
	m_pp.aapoints_spent = (allocated_spent > t.monster_points)
		? uint32_t(t.monster_points)
		: uint32_t(allocated_spent);
	m_pp.aapoints = (m_pp.aapoints > m_pp.aapoints_spent)
		? m_pp.aapoints - m_pp.aapoints_spent
		: 0;

	// Class/level profile mung (mirrors the quest path; the snapshot holds the
	// real values). Carried coins stay with the original wallet: the form
	// starts with an empty purse and its earned coins return on restore.
	m_pp.race   = t.race;
	m_pp.gender = t.gender;
	m_pp.class_ = t.class_id;
	m_pp.level  = t.level;
	m_pp.level2 = t.level;
	m_pp.exp    = GetEXPForLevel(t.level);
	m_pp.STR    = t.attributes[0];
	m_pp.STA    = t.attributes[1];
	m_pp.CHA    = t.attributes[2];
	m_pp.DEX    = t.attributes[3];
	m_pp.INT    = t.attributes[4];
	m_pp.AGI    = t.attributes[5];
	m_pp.WIS    = t.attributes[6];
	m_pp.copper   = 0;
	m_pp.silver   = 0;
	m_pp.gold     = 0;
	m_pp.platinum = 0;

	// The form's spellbook: only its template spells, nothing memorized.
	memset(&m_pp.spell_book[0], 0, sizeof(m_pp.spell_book));
	memset(&m_pp.mem_spells[0], 0, sizeof(m_pp.mem_spells));
	auto spells = Q(content_db,
		"SELECT slot_id,spell_id FROM spirit_shroud_spells WHERE template_id=" + S(t.id) +
		" ORDER BY slot_id LIMIT 600");
	for (auto row = spells.begin(); row != spells.end(); ++row) {
		const auto spell_id = N(row[1]);
		if (spell_id < SPDAT_RECORDS) {
			m_pp.spell_book[spell_id / 32] |= (1U << (spell_id % 32));
		}
	}

	ShroudApplyClassSkills(t.class_id, t.level);

	// Pending original-profile XP ledger (settles on restore).
	SpiritShroud::ExperienceState experience;
	CaptureOriginalExperience(*this, experience);
	Q(database,
		"REPLACE INTO spirit_shroud_experience_state(character_id," + std::string(ExperienceColumns) +
		") VALUES (" + S(CharacterID()) + "," + ExperienceValues(database, experience) + ")");

	Q(database,
		"INSERT INTO spirit_shroud_state(character_id) VALUES (" + S(CharacterID()) +
		") ON DUPLICATE KEY UPDATE character_id=character_id");
	Q(database,
		"UPDATE spirit_shroud_state SET template_id=" + S(t.id) + ",revision=revision+1 WHERE character_id=" +
		S(CharacterID()));
	auto state = Q(database,
		"SELECT revision FROM spirit_shroud_state WHERE character_id=" + S(CharacterID()));
	m_spirit_shroud_revision = state.RowCount() ? N(state.begin()[0]) : 0;

	IssueNativeStarterItems(t);

	// Appearance + transform (same order as the quest path).
	if (t.model_size > 0.0f) {
		size = t.model_size;
	}
	race        = t.race;
	gender      = t.gender;
	class_      = t.class_id;
	SetLevel(t.level);
	CalcBonuses();
	SetMaxHP();
	SendHPUpdate();

	m_pp.cur_hp    = GetHP();
	m_pp.mana      = current_mana;
	m_pp.endurance = current_endurance;
	SendShroudTransform(this, m_pp, t.model_size);
	SendHPUpdate();

	AppearanceStruct appearance{};
	appearance.race_id        = t.race;
	appearance.gender_id      = t.gender;
	appearance.texture        = 0;
	appearance.helmet_texture = 0;
	appearance.size           = t.model_size;
	appearance.send_effects   = true;
	SendIllusionPacket(appearance);

	SendAlternateAdvancementTable();
	SendAlternateAdvancementPoints();
	SendAlternateAdvancementStats();
	SendSpiritShroudProgress();
	m_spirit_shroud_resource_refreshes = 3;

	Message(Chat::Yellow, "You take on the form of %s.", t.name.c_str());
	LogInfo("Client [{}] entered native Spirit Shroud form [{}] (template [{}])",
		GetCleanName(), t.name, t.id);
}

void Client::RestoreNativeShroud()
{
	if (!IsSpiritShrouded() || !m_shroud_saved_valid) {
		throw std::runtime_error("shroud state changed");
	}
	const auto template_id = m_spirit_shroud_template;

	// Earned coins return with the player: add the form's carried coins to the
	// snapshot wallet before the restore overwrites m_pp.
	m_shroud_saved_pp.copper   += m_pp.copper;
	m_shroud_saved_pp.silver   += m_pp.silver;
	m_shroud_saved_pp.gold     += m_pp.gold;
	m_shroud_saved_pp.platinum += m_pp.platinum;

	// Temporary starter supplies disappear; earned contents of starter bags
	// promote to free main-inventory roots.
	RemoveNativeStarterItems(template_id);

	// Settle the pending original-profile XP ledger into the restored profile.
	auto pending = Q(database,
		"SELECT " + std::string(ExperienceColumns) + ",settled_at FROM spirit_shroud_experience_state "
		"WHERE character_id=" + S(CharacterID()));
	if (pending.RowCount() == 1 && !pending.begin()[11]) {
		auto experience = ReadExperience(pending.begin());
		const uint64_t restored_exp  = m_shroud_saved_pp.exp;
		const uint64_t restored_aa   = m_shroud_saved_pp.expAA;
		const uint64_t restored_aap  = m_shroud_saved_pp.aapoints;
		const uint64_t restored_pts  = m_shroud_saved_pp.points;
		if (experience.normal > restored_exp) {
			m_shroud_saved_pp.exp = uint32_t(std::min<uint64_t>(experience.normal, UINT32_MAX));
		}
		if (experience.aa > restored_aa) {
			m_shroud_saved_pp.expAA = uint32_t(std::min<uint64_t>(experience.aa, UINT32_MAX));
		}
		if (experience.aa_points > restored_aap) {
			m_shroud_saved_pp.aapoints = experience.aa_points;
		}
		if (experience.skill_points > restored_pts) {
			m_shroud_saved_pp.points = experience.skill_points;
		}
		if (experience.level > m_shroud_saved_pp.level) {
			m_shroud_saved_pp.level  = experience.level;
			m_shroud_saved_pp.level2 = experience.level2 ? experience.level2 : experience.level;
		}
		Q(database,
			"UPDATE spirit_shroud_experience_state SET settled_at=" + S(uint64_t(std::time(nullptr))) +
			" WHERE character_id=" + S(CharacterID()) + " AND settled_at IS NULL");
		Message(Chat::Experience,
			"Your earned experience returns with you as the form is removed.");
	}

	// Ownership returns from the snapshot (the restore below copies the saved
	// profile over m_pp; the server-side map follows it here).
	ShroudRebuildRanksFromPP();

	m_spirit_shroud_template    = 0;
	m_spirit_shroud_definition.reset();
	m_spirit_shroud_aa_ranks.clear();
	m_pp.shroud_native_stats_valid    = false;
	m_pp.shroud_native_resources_valid = false;
	memset(&m_pp.shroud_native_stats[0], 0, sizeof(m_pp.shroud_native_stats));

	Q(database,
		"UPDATE spirit_shroud_state SET template_id=0,revision=revision+1 WHERE character_id=" +
		S(CharacterID()));

	// Core restore: real profile back onto m_pp + transform/illusion/AA resend.
	RemoveShroud();
	ClearShroudSnapshot();
	SendSpiritShroudProgress();
	LogInfo("Client [{}] restored from native Spirit Shroud form [{}]", GetCleanName(), template_id);
}

void Client::IssueNativeStarterItems(const Template &t)
{
	auto starters = Q(content_db,
		"SELECT slot_id,item_id FROM spirit_shroud_starter_equipment WHERE template_id=" + S(t.id) +
		" ORDER BY slot_id LIMIT 21");
	for (auto starter = starters.begin(); starter != starters.end(); ++starter) {
		const auto slot    = N(starter[0]);
		const auto item_id = N(starter[1]);
		if (slot >= uint64_t(EQ::invslot::slotCursor) || item_id > UINT32_MAX) {
			throw std::runtime_error("invalid shroud starter slot");
		}
		if (GetInv().GetItem(int16_t(slot))) {
			continue; // zone-in re-apply: already issued
		}
		std::unique_ptr<EQ::ItemInstance> item(database.CreateItem(uint32_t(item_id), 1));
		if (!item || item->IsStackable() || item->IsEvolving()) {
			throw std::runtime_error("unsupported shroud starter definition");
		}
		item->SetCustomData(SpiritShroud::StarterSessionKey, S(t.id));
		if (GetInv().PushItem(int16_t(slot), item.get()) != int16_t(slot)) {
			throw std::runtime_error("shroud starter slot occupied");
		}
		item.release();
	}
}

void Client::RemoveNativeStarterItems(uint32_t template_id)
{
	// Discard marked items; promote earned children of marked bags into free
	// general roots (temporary containers vanish, their contents do not).
	std::vector<int16_t> discard;
	std::vector<std::pair<int16_t, int16_t>> promote;
	for (int16_t slot = EQ::invslot::GENERAL_BEGIN; slot <= EQ::invslot::GENERAL_END; ++slot) {
		auto *item = GetInv().GetItem(slot);
		if (item && IsNativeStarterMarker(item, template_id)) {
			discard.push_back(slot);
			for (uint8_t bag_slot = EQ::invbag::SLOT_BEGIN; bag_slot <= EQ::invbag::SLOT_END; ++bag_slot) {
				auto *child = item->GetItem(bag_slot);
				if (!child) {
					continue;
				}
				int16_t destination = EQ::invslot::GENERAL_BEGIN;
				while (destination <= EQ::invslot::GENERAL_END && GetInv().GetItem(destination)) {
					++destination;
				}
				if (destination > EQ::invslot::GENERAL_END) {
					Message(Chat::Yellow, "Make room in your main inventory before removing this form; "
						"your earned items were kept in the shroud bank.");
					continue;
				}
				promote.emplace_back(EQ::InventoryProfile::CalcSlotId(slot, bag_slot), destination);
			}
		}
	}
	for (const auto &move : promote) {
		auto *child = GetInv().GetItem(move.first);
		if (child && !GetInv().GetItem(move.second)) {
			auto *promoted = GetInv().PopItem(move.first);
			if (promoted) {
				if (GetInv().PushItem(move.second, promoted) != move.second) {
					GetInv().PushItem(move.first, promoted); // best effort: put it back
				}
			}
		}
	}
	for (int16_t slot : discard) {
		auto *item = GetInv().GetItem(slot);
		if (item && IsNativeStarterMarker(item, template_id)) {
			auto *removed = GetInv().PopItem(slot);
			safe_delete(removed);
		}
	}
}

// ------------------------------------------------------------------
// Experience ledger
// ------------------------------------------------------------------

void Client::AwardSpiritShroudExperience(ExpSource source, uint64_t amount, uint8 conlevel,
	bool already_calculated, uint64_t aa_amount)
{
	if (!IsSpiritShrouded() || !m_spirit_shroud_definition || !IsEXPEnabled() ||
		(!amount && !aa_amount)) {
		return;
	}
	try {
		auto state = Q(database,
			"SELECT template_id,revision FROM spirit_shroud_state WHERE character_id=" + S(CharacterID()));
		if (state.RowCount() != 1 || N(state.begin()[0]) != m_spirit_shroud_template ||
			N(state.begin()[1]) != m_spirit_shroud_revision) {
			throw std::runtime_error("shroud experience session changed");
		}
		auto rows = Q(database,
			"SELECT " + std::string(ExperienceColumns) + " FROM spirit_shroud_experience_state "
			"WHERE character_id=" + S(CharacterID()) + " AND settled_at IS NULL");
		if (rows.RowCount() != 1) {
			throw std::runtime_error("shroud experience state unavailable; restore and enter again");
		}
		auto pending = ReadExperience(rows.begin());
		const auto before = pending;

		uint64_t normal = amount;
		uint64_t aa     = aa_amount;
		uint64_t progression = SpiritShroud::SaturatingAdd(amount, aa_amount);
		if (!already_calculated) {
			if (amount > UINT32_MAX) {
				throw std::runtime_error("shroud experience award too large");
			}
			CalculateSpiritShroudExperience(amount, conlevel,
				pending.level > 50 ? pending.percent_to_aa : 0,
				uint64_t(pending.aa_spent) + pending.aa_points, normal, aa, progression);
		}
		SpiritShroud::ApplyExperience(pending, normal, aa, RuleI(AA, UnusedAAPointCap));

		const uint64_t normal_delta = pending.normal - before.normal;
		const uint64_t aa_delta =
			uint64_t(pending.aa_points - before.aa_points) * pending.aa_unit + pending.aa - before.aa;

		auto progress = Q(database,
			"SELECT experience FROM spirit_shroud_progress WHERE character_id=" + S(CharacterID()) +
			" AND progression_id=" + S(m_spirit_shroud_definition->progression));
		const uint64_t previous_progress = progress.RowCount() ? N(progress.begin()[0]) : 0;
		const uint64_t next_progress = SpiritShroud::SaturatingAdd(previous_progress, progression);
		if (next_progress == previous_progress && !normal_delta && !aa_delta) {
			return;
		}
		Q(database,
			"INSERT INTO spirit_shroud_progress(character_id,progression_id,experience) VALUES (" +
			S(CharacterID()) + "," + S(m_spirit_shroud_definition->progression) + "," + S(next_progress) +
			") ON DUPLICATE KEY UPDATE experience=VALUES(experience)");
		Q(database,
			"UPDATE spirit_shroud_experience_state SET normal_exp=" + S(pending.normal) +
			",aa_exp=" + S(pending.aa) + ",aa_points=" + S(pending.aa_points) +
			",level=" + S(pending.level) + ",level2=" + S(pending.level2) +
			",skill_points=" + S(pending.skill_points) + " WHERE character_id=" + S(CharacterID()) +
			" AND settled_at IS NULL");
		Q(database,
			"INSERT INTO spirit_shroud_experience_events(character_id,event_key,source,"
			"progression_delta,normal_delta,aa_delta,created_at) VALUES (" + S(CharacterID()) +
			",UNHEX(REPLACE(UUID(),'-',''))," + S(uint32_t(source)) + "," +
			S(next_progress - previous_progress) + "," + S(normal_delta) + "," + S(aa_delta) + "," +
			S(uint64_t(std::time(nullptr))) + ")");
		if (uint64_t(std::time(nullptr)) > m_spirit_shroud_progress_sent + 5) {
			SendSpiritShroudProgress();
		}
		Message(Chat::Experience,
			"You gain Spirit Shroud experience. Your character's earned experience will be applied "
			"when you remove the shroud.");
	} catch (const std::exception &error) {
		LogError("Spirit Shroud experience rejected for character [{}]: [{}]", CharacterID(), error.what());
		Message(Chat::Red, "Your Spirit Shroud experience could not be saved; this award was withheld.");
	}
}

bool Client::HasSpiritShroudRank(uint32_t rank) const
{
	return IsSpiritShrouded() && m_spirit_shroud_aa_ranks.count(rank) != 0;
}

void Client::SendSpiritShroudProgress()
{
	if (!RuleB(Custom, EnableSpiritShrouds)) {
		return;
	}
	try {
		auto families = Q(content_db,
			"SELECT progression_id,name,completion_xp,branch_count,definition_version "
			"FROM spirit_shroud_progression_definitions ORDER BY progression_id");
		if (families.RowCount() > 64) {
			throw std::runtime_error("invalid shroud progression family count");
		}
		Bytes out;
		Put32(out, uint32_t(families.RowCount()));
		std::string text;
		for (auto row = families.begin(); row != families.end(); ++row) {
			const auto family  = N(row[0]);
			const auto count   = N(row[3]);
			const auto version = N(row[4]);
			if (!family || !row[1] || !count || count > 64 || !version) {
				throw std::runtime_error("invalid shroud progression definition");
			}
			const auto xp = Progress(database, CharacterID(), uint32_t(family));
			auto branches = Q(content_db,
				"SELECT branch_id,unlock_xp FROM spirit_shroud_branch_progression WHERE progression_id=" +
				S(family) + " AND definition_version=" + S(version) + " ORDER BY branch_id");
			if (branches.RowCount() != count) {
				throw std::runtime_error("incomplete shroud progression definition");
			}
			uint64_t unlocked = 0;
			for (auto branch = branches.begin(); branch != branches.end(); ++branch) {
				if (branch[1] && xp >= N(branch[1])) {
					++unlocked;
				}
			}
			uint64_t percentage = 0;
			std::string detail = "Spirit experience: " + S(xp);
			if (row[2] && N(row[2])) {
				const auto target = N(row[2]);
				percentage = xp >= target ? 100 : uint64_t(100.0L * xp / target);
				detail += " / " + S(target);
			} else {
				detail += " (completion threshold unmeasured)";
			}
			text += Token("PROGRESSION", '\a') + Token(S(family), '\a') + Token(row[1], '\a') +
				Token(detail, '\a') + Token(S(unlocked), '\a') + Token(S(count), '\a') +
				Token("", '\a') + Token("", '\a') + Token(S(percentage), '\a');
		}
		Text(out, text);
		Send(*this, OP_ShroudProgress, out);
		m_spirit_shroud_progress_sent = uint64_t(std::time(nullptr));
	} catch (const std::exception &error) {
		LogError("Spirit Shroud progress display unavailable: [{}]", error.what());
	}
}

void Client::PurchaseSpiritShroudRank(uint32_t rank_id, bool saved_set)
{
	if (!IsSpiritShrouded() || !m_spirit_shroud_definition || IsDead() || IsEngaged() || GetAggroCount()) {
		return;
	}
	auto *target = zone->GetAlternateAdvancementRank(rank_id);
	if (!target || !target->base_ability ||
		(target->base_ability->category != AACategory::ShroudPassive &&
			target->base_ability->category != AACategory::ShroudActive) ||
		!(target->base_ability->classes & (1U << GetClass())) || target->base_ability->grant_only ||
		target->base_ability->charges || !HasSpiritShroudRank(rank_id) ||
		target->current_value > target->base_ability->GetMaxLevel(this)) {
		return;
	}
	const auto root  = target->base_ability->first_rank_id;
	const auto owned = GetAA(root);
	if (owned >= uint32_t(target->current_value) || (!owned && aa_ranks.size() >= MAX_PP_AA_ARRAY)) {
		return;
	}
	std::vector<AA::Rank *> missing;
	for (auto *rank = target; rank && rank->current_value > int(owned); rank = rank->prev) {
		if (missing.size() >= 300 || rank->base_ability != target->base_ability ||
			!HasSpiritShroudRank(rank->id) || rank->level_req > GetLevel() || rank->cost < 0) {
			return;
		}
		missing.push_back(rank);
	}
	if (missing.empty() || (!saved_set && missing.size() != 1)) {
		return;
	}
	std::reverse(missing.begin(), missing.end());
	if (missing.front()->current_value != int(owned) + 1) {
		return;
	}
	uint64_t cost = 0;
	for (auto *rank : missing) {
		cost += uint64_t(rank->cost);
		if (cost > m_pp.aapoints) {
			return;
		}
		for (const auto &prereq : rank->prereqs) {
			auto *ability = zone->GetAlternateAdvancementAbility(prereq.first);
			if (!ability) {
				return;
			}
			auto have = ability->first_rank_id == root
				? uint32_t(rank->current_value) - 1
				: uint32_t(GetAA(ability->first_rank_id));
			if (have < uint32_t(prereq.second)) {
				return;
			}
		}
	}

	try {
		Q(database,
			"INSERT INTO spirit_shroud_allocations(character_id,template_id,ability_id,rank_id,paid_points) "
			"VALUES (" + S(CharacterID()) + "," + S(m_spirit_shroud_template) + "," +
			S(target->base_ability->id) + "," + S(target->id) + "," + S(cost) +
			") ON DUPLICATE KEY UPDATE rank_id=VALUES(rank_id),paid_points=paid_points+VALUES(paid_points)");
		m_pp.aapoints      -= uint32_t(cost);
		m_pp.aapoints_spent = (m_pp.aapoints_spent > UINT32_MAX - uint32_t(cost))
			? UINT32_MAX
			: m_pp.aapoints_spent + uint32_t(cost);
		SetAA(root, target->current_value, 0);
		CalcBonuses();
		SendAlternateAdvancementTable();
		SendAlternateAdvancementPoints();
		SendAlternateAdvancementStats();
		Message(Chat::Yellow, "You spend %u monster points.", uint32_t(cost));
	} catch (const std::exception &error) {
		LogError("Spirit Shroud purchase rejected for character [{}]: [{}]", CharacterID(), error.what());
		Message(Chat::Red, "Your Monster Point purchase was not applied.");
	}
}

bool Client::TrySpiritShroudAbility(uint32_t action, uint32_t ability)
{
	if (!IsSpiritShrouded()) {
		return false;
	}
	// Saved sets are local to the native client; Load sends existing action 7.
	if (action == 3 || action == 7) {
		PurchaseSpiritShroudRank(ability, action == 7);
		return true;
	}
	// The active pool belongs to this form; ordinary XP allocation is frozen.
	if (action != 0) {
		return true;
	}
	if (ability != 3577) {
		return false;
	}
	if (!HasSpiritShroudRank(3577) || !GetAA(3577) || IsDead() || IsEngaged() || GetAggroCount()) {
		return true;
	}
	// Spirit Sending: teleport back to the position saved in the snapshot.
	auto *rank = zone->GetAlternateAdvancementRank(3577);
	if (!rank || rank->spell_type <= 0 || rank->spell_type > pTimerAAEnd - pTimerAAStart) {
		return true;
	}
	const auto timer = rank->spell_type;
	if (!p_timers.Expired(&database, pTimerAAStart + timer, false)) {
		return true;
	}
	const auto &saved = m_shroud_saved_pp;
	p_timers.Start(pTimerAAStart + timer, 90);
	SendAlternateAdvancementTimer(timer, time(nullptr), time(nullptr) + 90);
	MovePC(saved.zone_id, saved.zoneInstance, saved.x, saved.y, saved.z, saved.heading, 1);
	return true;
}

bool Client::CompleteSpiritShroudReturn(uint32_t rank_id)
{
	// Each verified form may use its own class-bound Spirit Sending adapter.
	if (!IsSpiritShrouded() || m_spirit_shroud_transition || !HasSpiritShroudRank(rank_id) ||
		IsDead() || IsEngaged() || GetAggroCount()) {
		return false;
	}
	auto *rank = zone->GetAlternateAdvancementRank(rank_id);
	if (!rank || !rank->base_ability || rank->base_ability->category != AACategory::ShroudActive ||
		rank->spell != 7790 || !CanUseAlternateAdvancementRank(rank) ||
		GetAA(rank_id) < uint32_t(rank->current_value)) {
		return false;
	}
	try {
		auto result = Q(database,
			"SELECT template_id FROM spirit_shroud_state WHERE character_id=" + S(CharacterID()) +
			" AND template_id=" + S(m_spirit_shroud_template) + " AND revision=" +
			S(m_spirit_shroud_revision));
		if (result.RowCount() != 1) {
			throw std::runtime_error("shroud return state changed");
		}
		const auto &saved = m_shroud_saved_pp;
		if (!saved.zone_id || !std::isfinite(saved.x) || !std::isfinite(saved.y) ||
			!std::isfinite(saved.z) || !std::isfinite(saved.heading)) {
			throw std::runtime_error("shroud return destination invalid");
		}
		MovePC(saved.zone_id, saved.zoneInstance, saved.x, saved.y, saved.z, saved.heading, 1);
		return true;
	} catch (const std::exception &error) {
		LogError("Spirit Shroud return rejected for character [{}]: [{}]", CharacterID(), error.what());
		Message(Chat::Red, "Your shroud master cannot be reached right now.");
		return false;
	}
}

// ------------------------------------------------------------------
// Starter custody + form metadata
// ------------------------------------------------------------------

bool Client::IsSpiritShroudStarterItem(const EQ::ItemInstance *item) const
{
	if (!item || !IsSpiritShrouded() || !m_spirit_shroud_definition) {
		return false;
	}
	const auto *data = item->GetItem();
	if (!data || std::none_of(m_spirit_shroud_definition->equipment.begin(),
		    m_spirit_shroud_definition->equipment.end(),
		    [data](const auto &entry) { return entry.item_id == data->ID; })) {
		return false;
	}
	try {
		const auto marker = SpiritShroud::ReadStarterMetadata(item->GetCustomDataString());
		return marker.session && *marker.session == S(m_spirit_shroud_template);
	} catch (...) {
		return false;
	}
}

bool Client::CanTransferSpiritShroudItemTree(const EQ::ItemInstance *item) const
{
	if (!IsSpiritShrouded()) {
		return true;
	}
	if (IsSpiritShroudStarterItem(item)) {
		return false;
	}
	if (item) {
		for (uint8_t slot = EQ::invbag::SLOT_BEGIN; slot <= EQ::invbag::SLOT_END; ++slot) {
			if (!CanTransferSpiritShroudItemTree(item->GetItem(slot))) {
				return false;
			}
		}
	}
	return true;
}

float Client::SpiritShroudModelSize() const
{
	return m_spirit_shroud_definition ? m_spirit_shroud_definition->model_size : 0.0f;
}

std::optional<uint32_t> Client::SpiritShroudAbilityMinimumLevel(uint16_t spell_id, uint32_t rank_id) const
{
	if (!rank_id || !IsSpiritShrouded() || !zone) {
		return std::nullopt;
	}
	const auto *rank = zone->GetAlternateAdvancementRank(rank_id);
	return SpiritShroud::AbilityMinimumLevel(SpiritShroudDefinition(), rank, spell_id,
		GetAA(rank_id), GetClass(), GetLevel(), false);
}

// ------------------------------------------------------------------
// Zone-in state restore
// ------------------------------------------------------------------

bool Client::LoadSpiritShroudState()
{
	m_spirit_shroud_template    = 0;
	m_spirit_shroud_revision    = 0;
	m_spirit_shroud_definition.reset();
	m_spirit_shroud_aa_ranks.clear();
	m_pp.shroud_native_stats_valid    = false;
	m_pp.shroud_native_resources_valid = false;
	memset(&m_pp.shroud_native_stats[0], 0, sizeof(m_pp.shroud_native_stats));
	if (ClientVersion() != EQ::versions::ClientVersion::RoF2) {
		return true;
	}
	try {
		auto r = database.QueryDatabase(
			"SELECT template_id,revision FROM spirit_shroud_state WHERE character_id=" +
			S(CharacterID()), false);
		// Missing storage is only tolerable while the feature is disabled;
		// an enabled server with missing tables is a deployment error.
		if (!r.Success()) {
			if (r.ErrorNumber() == 1146 && !RuleB(Custom, EnableSpiritShrouds)) {
				return true;
			}
			LogError("Spirit Shroud state unreadable for character [{}]: [{}]", CharacterID(), r.ErrorMessage());
			return true; // ordinary profile loads; no native state applied
		}
		if (!r.RowCount()) {
			return true;
		}
		auto row   = r.begin();
		auto id    = N(row[0]);
		if (id > INT32_MAX) {
			throw std::runtime_error("shroud invalid active identity");
		}
		const auto revision = N(row[1]);
		if (!id) {
			return true; // not shrouded
		}
		auto definitions = Catalog(uint32_t(id), true);
		if (definitions.size() != 1) {
			throw std::runtime_error("shroud active template missing");
		}
		m_spirit_shroud_definition = std::make_shared<const Template>(std::move(definitions.front()));
		m_spirit_shroud_template   = uint32_t(id);
		m_spirit_shroud_revision   = revision;
		for (auto rank_id : m_spirit_shroud_definition->abilities) {
			m_spirit_shroud_aa_ranks.insert(rank_id);
		}
		m_pp.shroud_native_stats_valid      = m_spirit_shroud_definition->has_native_stats;
		m_pp.shroud_native_resources_valid  = m_spirit_shroud_definition->has_native_resources ||
			m_spirit_shroud_definition->has_native_stats;
		std::copy(m_spirit_shroud_definition->native_stats.begin(),
			m_spirit_shroud_definition->native_stats.end(), m_pp.shroud_native_stats);
		return true;
	} catch (const std::exception &error) {
		LogError("Spirit Shroud recovery refused for character [{}]: [{}]", CharacterID(), error.what());
		m_spirit_shroud_template = 0;
		m_spirit_shroud_definition.reset();
		m_spirit_shroud_aa_ranks.clear();
		return true; // the ordinary profile stays authoritative; never strand a login
	}
}

// Called from LoadAndApplyShroudState when the persisted snapshot row is a
// native form: the ordinary (real) profile has loaded, so the form is applied
// in memory exactly as entering it -- minus the ledger and starter writes,
// which survive in the database and inventory respectively.
void Client::ReapplyNativeShroud(uint32_t template_id)
{
	try {
		auto definitions = Catalog(template_id, true);
		if (definitions.size() != 1) {
			throw std::runtime_error("shroud active template missing");
		}
		const Template &t = definitions.front();

		m_shrouded                 = true;
		m_shroud_id                = 0;
		m_shroud_zonein_pending    = false;
		m_spirit_shroud_template   = t.id;
		m_spirit_shroud_definition = std::make_shared<const Template>(t);
		m_spirit_shroud_aa_ranks.clear();
		for (auto rank_id : t.abilities) {
			m_spirit_shroud_aa_ranks.insert(rank_id);
		}
		m_pp.shroud_native_stats_valid    = t.has_native_stats;
		m_pp.shroud_native_resources_valid = t.has_native_resources || t.has_native_stats;
		std::copy(t.native_stats.begin(), t.native_stats.end(), m_pp.shroud_native_stats);

		// The form owns only its monster ranks; the real set comes back from
		// the snapshot profile on restore.
		aa_ranks.clear();
		memset(&m_pp.aa_array[0], 0, sizeof(AA_Array) * MAX_PP_AA_ARRAY);
		uint64_t allocated_spent = 0;
		auto allocations = Q(database,
			"SELECT ability_id,rank_id,paid_points FROM spirit_shroud_allocations WHERE character_id=" +
			S(CharacterID()) + " AND template_id=" + S(t.id));
		for (auto row = allocations.begin(); row != allocations.end(); ++row) {
			allocated_spent += N(row[2]);
			auto *rank = zone->GetAlternateAdvancementRank(N(row[1]));
			if (rank && rank->base_ability && rank->base_ability->id == N(row[0])) {
				SetAA(rank->base_ability->id, rank->current_value, 0);
			}
		}
		for (auto rank_id : t.abilities) {
			auto *rank = zone->GetAlternateAdvancementRank(rank_id);
			if (rank && rank->base_ability &&
				std::find(t.free_abilities.begin(), t.free_abilities.end(), rank_id) != t.free_abilities.end()) {
				SetAA(rank->base_ability->id, rank->current_value, 0);
			}
		}
		ShroudRebuildAAArray();

		m_pp.aapoints       = t.monster_points;
		m_pp.aapoints_spent = (allocated_spent > t.monster_points)
			? uint32_t(t.monster_points)
			: uint32_t(allocated_spent);
		m_pp.aapoints = (m_pp.aapoints > m_pp.aapoints_spent)
			? m_pp.aapoints - m_pp.aapoints_spent
			: 0;

		m_pp.race   = t.race;
		m_pp.gender = t.gender;
		m_pp.class_ = t.class_id;
		m_pp.level  = t.level;
		m_pp.level2 = t.level;
		m_pp.exp    = GetEXPForLevel(t.level);
		m_pp.STR    = t.attributes[0];
		m_pp.STA    = t.attributes[1];
		m_pp.CHA    = t.attributes[2];
		m_pp.DEX    = t.attributes[3];
		m_pp.INT    = t.attributes[4];
		m_pp.AGI    = t.attributes[5];
		m_pp.WIS    = t.attributes[6];
		m_pp.copper   = 0;
		m_pp.silver   = 0;
		m_pp.gold     = 0;
		m_pp.platinum = 0;

		memset(&m_pp.spell_book[0], 0, sizeof(m_pp.spell_book));
		memset(&m_pp.mem_spells[0], 0, sizeof(m_pp.mem_spells));
		auto spells = Q(content_db,
			"SELECT slot_id,spell_id FROM spirit_shroud_spells WHERE template_id=" + S(t.id) +
			" ORDER BY slot_id LIMIT 600");
		for (auto row = spells.begin(); row != spells.end(); ++row) {
			const auto spell_id = N(row[1]);
			if (spell_id < SPDAT_RECORDS) {
				m_pp.spell_book[spell_id / 32] |= (1U << (spell_id % 32));
			}
		}

		ShroudApplyClassSkills(t.class_id, t.level);

		if (t.model_size > 0.0f) {
			size = t.model_size;
		}
		race        = t.race;
		gender      = t.gender;
		class_      = t.class_id;
		SetLevel(t.level);
		CalcBonuses();
		SetMaxHP();

		// The RoF2 client crashes if OP_Shroud arrives while it is still
		// building the zone; defer to the zone-settle path (same as the quest
		// path's deferred re-apply).
		m_shroud_zonein_pending = true;
		m_shroud_zonein_at      = Timer::GetTimeSeconds() + 3;

		LogInfo("Client [{}] re-applied native Spirit Shroud form [{}] (template [{}]) on zone-in",
			GetCleanName(), t.name, t.id);
	} catch (const std::exception &error) {
		LogError("Native Spirit Shroud re-apply refused for character [{}], template [{}]: [{}]",
			CharacterID(), template_id, error.what());
		m_spirit_shroud_template = 0;
		m_spirit_shroud_definition.reset();
		m_spirit_shroud_aa_ranks.clear();
		m_shroud_saved_valid = false;
		ClearShroudSnapshot();
	}
}

// ------------------------------------------------------------------
// Death / resurrection accounting
// ------------------------------------------------------------------

bool Client::RecordSpiritShroudDeath(uint32_t corpse_id, uint64_t requested_loss, uint64_t &applied_loss)
{
	applied_loss = 0;
	if (!IsSpiritShrouded() || !corpse_id) {
		return false;
	}
	try {
		auto rows = Q(database,
			"SELECT " + std::string(ExperienceColumns) + " FROM spirit_shroud_experience_state "
			"WHERE character_id=" + S(CharacterID()) + " AND settled_at IS NULL");
		if (rows.RowCount() != 1) {
			throw std::runtime_error("shroud death pending experience missing");
		}
		auto pending = ReadExperience(rows.begin());
		// The server's existing active-form death formula and configured level
		// floor choose the requested loss. Only the original pending normal-XP
		// domain is debited.
		applied_loss = SpiritShroud::ApplyDeathLoss(
			pending, std::min<uint64_t>(requested_loss, INT32_MAX), RuleB(Character, DeathKeepLevel));
		Q(database,
			"UPDATE spirit_shroud_experience_state SET normal_exp=" + S(pending.normal) +
			",level=" + S(pending.level) + " WHERE character_id=" + S(CharacterID()) +
			" AND settled_at IS NULL");
		Q(database,
			"REPLACE INTO spirit_shroud_corpse_state(corpse_id,character_id,applied_loss,refunded_loss,"
			"provenance_version,created_at) VALUES (" + S(corpse_id) + "," + S(CharacterID()) + "," +
			S(applied_loss) + ",0,1," + S(uint64_t(std::time(nullptr))) + ")");
		Q(database,
			"INSERT INTO spirit_shroud_experience_events(character_id,event_key,source,"
			"progression_delta,normal_delta,aa_delta,created_at) VALUES (" + S(CharacterID()) +
			",UNHEX(CONCAT(LPAD(HEX(" + S(m_spirit_shroud_revision) + "),16,'0'),LPAD(HEX(" +
			S(corpse_id) + "),8,'0'),LPAD(HEX(1),8,'0')))," + S(uint32_t(ExpSource::Death)) +
			",0,-" + S(applied_loss) + ",0," + S(uint64_t(std::time(nullptr))) + ")");
		return true;
	} catch (const std::exception &error) {
		LogError("Spirit Shroud death accounting rejected for character [{}], corpse [{}]: [{}]",
			CharacterID(), corpse_id, error.what());
		applied_loss = 0;
		return false;
	}
}

bool Client::CanAcceptSpiritShroudResurrection(uint32_t corpse_id)
{
	if (!IsSpiritShrouded()) {
		return true;
	}
	if (!corpse_id) {
		return false;
	}
	auto r = database.QueryDatabase(
		"SELECT p.corpse_id FROM spirit_shroud_corpse_state p JOIN character_corpses c "
		"ON c.id=p.corpse_id AND c.charid=p.character_id WHERE p.corpse_id=" + S(corpse_id) +
		" AND p.character_id=" + S(CharacterID()) + " AND p.provenance_version=1");
	return r.Success() && r.RowCount() == 1;
}

bool Client::SettleSpiritShroudResurrection(uint32_t corpse_id, uint32_t spell_id,
	uint64_t offered_loss, bool &handled)
{
	handled = false;
	// A normal corpse keeps its existing path. Missing optional storage is
	// also harmless to ordinary characters when the feature was never enabled.
	auto known = database.QueryDatabase(
		"SELECT provenance_version FROM spirit_shroud_corpse_state WHERE corpse_id=" + S(corpse_id));
	if (!known.Success()) {
		return !IsSpiritShrouded() && !RuleB(Custom, EnableSpiritShrouds);
	}
	if (!known.RowCount()) {
		return !IsSpiritShrouded();
	}
	handled = true;
	if (N(known.begin()[0]) != 1 || !corpse_id || PendingRezzXP < 0 ||
		PendingRezzDBID != corpse_id || PendingRezzSpellID != spell_id || !IsValidSpell(spell_id)) {
		return false;
	}
	int percent = -1;
	for (int slot = 0; slot < EFFECT_COUNT; ++slot) {
		if (spells[spell_id].effect_id[slot] == SE_Revive) {
			percent = spells[spell_id].base_value[slot];
			break;
		}
	}
	if (percent < 0 || percent > 100) {
		return false;
	}
	try {
		auto provenance = Q(database,
			"SELECT character_id,applied_loss,refunded_loss,rez_claimed_at FROM spirit_shroud_corpse_state "
			"WHERE corpse_id=" + S(corpse_id));
		if (provenance.RowCount() != 1 || N(provenance.begin()[0]) != CharacterID()) {
			throw std::runtime_error("shroud resurrection provenance missing or foreign");
		}
		const auto applied = N(provenance.begin()[1]);
		if (applied > INT32_MAX || N(provenance.begin()[2]) > applied) {
			throw std::runtime_error("shroud resurrection invalid debit");
		}
		auto body = Q(database,
			"SELECT charid,exp,is_rezzed,rezzable FROM character_corpses WHERE id=" + S(corpse_id));
		if (body.RowCount() != 1 || N(body.begin()[0]) != CharacterID()) {
			throw std::runtime_error("shroud resurrection corpse missing or foreign");
		}
		// Repeated acceptance and zero-XP corpse gates cannot credit twice.
		if (provenance.begin()[3]) {
			return true;
		}
		if (N(body.begin()[2]) || !N(body.begin()[3]) || N(body.begin()[1]) != applied ||
			offered_loss != applied) {
			throw std::runtime_error("shroud resurrection offer changed or expired");
		}
		if (IsSpiritShrouded()) {
			auto rows = Q(database,
				"SELECT " + std::string(ExperienceColumns) + " FROM spirit_shroud_experience_state "
				"WHERE character_id=" + S(CharacterID()) + " AND settled_at IS NULL");
			if (rows.RowCount() != 1) {
				throw std::runtime_error("shroud resurrection pending experience missing");
			}
			auto credited = ReadExperience(rows.begin());
			const auto refund = SpiritShroud::ApplyResurrection(
				credited, applied, uint32_t(percent), RuleI(AA, UnusedAAPointCap));
			Q(database,
				"UPDATE spirit_shroud_experience_state SET normal_exp=" + S(credited.normal) +
				",level=" + S(credited.level) + ",level2=" + S(credited.level2) +
				",skill_points=" + S(credited.skill_points) + " WHERE character_id=" +
				S(CharacterID()) + " AND settled_at IS NULL");
			Q(database,
				"UPDATE spirit_shroud_corpse_state SET refunded_loss=" + S(refund) + ",rez_claimed_at=" +
				S(uint64_t(std::time(nullptr))) + ",rez_spell_id=" + S(spell_id) +
				" WHERE corpse_id=" + S(corpse_id) + " AND rez_claimed_at IS NULL");
			Q(database,
				"UPDATE character_corpses SET exp=0,is_rezzed=1 WHERE id=" + S(corpse_id) +
				" AND charid=" + S(CharacterID()));
			return true;
		}
		// Already restored: credit the original profile directly.
		SpiritShroud::ExperienceState credited;
		credited.normal       = GetEXP();
		credited.aa           = GetAAXP();
		credited.aa_points    = GetAAPoints();
		credited.aa_spent     = GetSpentAA();
		credited.level        = GetLevel();
		credited.level2       = m_pp.level2;
		credited.skill_points = m_pp.points;
		credited.percent_to_aa = GetLevel() > 50
			? std::min<uint32_t>(100, uint32_t(GetAAPercent()))
			: 0;
		credited.aa_unit      = GetRequiredAAExperience();
		auto maximum = RuleI(Character, MaxExpLevel);
		if (maximum < 1) {
			maximum = RuleI(Character, MaxLevel);
		}
		if (GetClientMaxLevel()) {
			maximum = GetClientMaxLevel();
		}
		credited.max_level = std::max<int>(GetLevel(), maximum);
		if (!credited.max_level || credited.max_level > 126) {
			throw std::runtime_error("shroud resurrection level cap invalid");
		}
		credited.thresholds.push_back(0);
		for (uint32_t level = 1; level <= credited.max_level + 1; ++level) {
			credited.thresholds.push_back(GetEXPForLevel(level));
		}
		const auto refund = SpiritShroud::ApplyResurrection(
			credited, applied, uint32_t(percent), RuleI(AA, UnusedAAPointCap));
		if (refund) {
			SetEXP(ExpSource::Resurrection, credited.normal, credited.aa, true);
		}
		Q(database,
			"UPDATE spirit_shroud_corpse_state SET refunded_loss=" + S(refund) + ",rez_claimed_at=" +
			S(uint64_t(std::time(nullptr))) + ",rez_spell_id=" + S(spell_id) +
			" WHERE corpse_id=" + S(corpse_id) + " AND rez_claimed_at IS NULL");
		Q(database,
			"UPDATE character_corpses SET exp=0,is_rezzed=1 WHERE id=" + S(corpse_id) +
			" AND charid=" + S(CharacterID()));
		return true;
	} catch (const std::exception &error) {
		LogError("Spirit Shroud resurrection rejected for character [{}], corpse [{}]: [{}]",
			CharacterID(), corpse_id, error.what());
		Message(Chat::Red, "Your resurrection could not be settled. The corpse claim has not been acknowledged.");
		return false;
	}
}

// ------------------------------------------------------------------
// Shroud bank (minimal: open/list/preview; native retrieval stays a follow-up)
// ------------------------------------------------------------------

void Client::OpenSpiritShroudBank()
{
	if (!Keeper(*this) || IsSpiritShrouded() || m_spirit_shroud_transition) {
		return;
	}
	try {
		auto rows = Q(database,
			"SELECT slot_id,item_id,charges FROM spirit_shroud_bank_inventory WHERE character_id=" +
			S(CharacterID()) + " AND slot_id<" + S(uint64_t(EQ::invslot::slotCursor)) +
			" ORDER BY slot_id LIMIT 1001");
		if (rows.RowCount() > 1000) {
			throw std::runtime_error("shroud bank too large");
		}
		m_spirit_shroud_keeper     = GetTarget() ? GetTarget()->GetID() : 0;
		m_spirit_shroud_menu_until = uint64_t(std::time(nullptr)) + 120;
		Bytes open;
		Put32(open, 0);
		Put32(open, m_spirit_shroud_keeper);
		Send(*this, OP_SpiritShroudBank, open);
		Bytes list;
		Put32(list, 0);
		Put32(list, uint32_t(rows.RowCount()));
		for (auto r = rows.begin(); r != rows.end(); ++r) {
			const auto *item = database.GetItem(uint32_t(N(r[1])));
			if (!item) {
				throw std::runtime_error("shroud bank item definition missing");
			}
			Text(list, item->Name);
			Put32(list, item->Icon);
			Put64(list, N(r[0]) + 1);
			Put32(list, item->Stackable ? uint32_t(std::max<uint64_t>(1, N(r[2]))) : 1);
		}
		Send(*this, OP_SpiritShroudBankItems, list);
	} catch (const std::exception &error) {
		LogError("Spirit Shroud bank unavailable for character [{}]: [{}]", CharacterID(), error.what());
		Message(Chat::Red, "Your shroud bank is unavailable; its items remain stored.");
	}
}

void Client::Handle_OP_SpiritShroudBank(const EQApplicationPacket *p)
{
	if (!RuleB(Custom, EnableSpiritShrouds) || !p || p->size < 4 ||
		IsSpiritShrouded() || m_spirit_shroud_transition) {
		return;
	}
	auto action = Read32(p->pBuffer);
	if (action == 0 && p->size == 8 && Keeper(*this, Read32(p->pBuffer + 4))) {
		OpenSpiritShroudBank();
		return;
	}
	if (action == 5 && p->size == 24 && uint64_t(std::time(nullptr)) <= m_spirit_shroud_menu_until &&
		Keeper(*this, m_spirit_shroud_keeper)) {
		uint64_t key = Read32(p->pBuffer + 8) | (uint64_t(Read32(p->pBuffer + 12)) << 32);
		if (!key || key > 9000) {
			return;
		}
		try {
			auto rows = Q(database,
				"SELECT item_id,charges FROM spirit_shroud_bank_inventory WHERE character_id=" +
				S(CharacterID()) + " AND slot_id=" + S(key - 1));
			if (rows.RowCount() != 1) {
				return;
			}
			auto item = CreateShroudItem(*this, uint32_t(N(rows.begin()[0])), int16_t(N(rows.begin()[1])));
			if (item) {
				SendItemPacket(EQ::invslot::slotCursor, item.get(), ItemPacketViewLink);
			}
		} catch (const std::exception &error) {
			LogError("Spirit Shroud bank preview rejected for character [{}]: [{}]", CharacterID(), error.what());
		}
		return;
	}
	if (action != 2 || p->size != 16) {
		return;
	}
	// Native retrieval rides a staged transaction in the upstream engine; on
	// this server it stays a follow-up. The proven all-ones key declines the
	// request while completing the pending wait and leaves the row intact.
	const auto decline = [this]() {
		Bytes response;
		Put32(response, 2);
		Put32(response, 0);
		Put64(response, std::numeric_limits<uint64_t>::max());
		Send(*this, OP_SpiritShroudBank, response);
	};
	decline();
}
