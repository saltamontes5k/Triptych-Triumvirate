// nms_housing_trophies.cpp -- RoF2 personal housing trophies (free v1).
// See nms_housing_trophies.h for the subsystem overview. Wire layouts and the state
// machine are ports of nightstalker6669/EQEmu develop (trophy_anchor_wire.h,
// trophy_benefits.h, client_housing_trophies.cpp); the eligibility backend is our
// nms_house_item placement table instead of their custody bridge.

#include "nms_housing_trophies.h"

#include "client.h"
#include "zonedb.h"

#include "../common/rulesys.h"
#include "../common/strings.h"

#include "fmt/format.h"

#include <cstring>
#include <map>
#include <vector>

namespace {

// ------------------------------------------------------------------
// Wire (port of upstream Housing::TrophyAnchorWire; little-endian DWORDs).
// ------------------------------------------------------------------

constexpr size_t kSelectionSize = 12; // slot, benefit_id, tier
constexpr size_t kBenefitsSize  = 84; // enabled + ids[10] + tiers[10] as TWO arrays
constexpr size_t kTimerSize     = 4;  // remaining_ms

uint32_t ReadU32(const uint8_t *p)
{
	return uint32_t(p[0]) | (uint32_t(p[1]) << 8) | (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24);
}

int32_t ReadS32(const uint8_t *p)
{
	return static_cast<int32_t>(ReadU32(p));
}

void AppendU32(std::vector<uint8_t> &out, uint32_t v)
{
	for (unsigned shift = 0; shift < 32; shift += 8) {
		out.push_back(uint8_t(v >> shift));
	}
}

struct TrophyTier {
	uint32_t minimum_level = 0;
	uint32_t favor_cost    = 0;
	uint32_t stat_item_id  = 0;
};

struct TrophyDef {
	uint32_t                id             = 0;
	uint32_t                placed_item_id = 0;
	std::string             name;
	std::vector<TrophyTier> tiers;
	bool                    eligible = false; // a placed, owned source row exists right now
};

using TrophyCatalog = std::map<uint32_t, TrophyDef>;

struct TrophyView {
	bool     enabled         = false;
	uint32_t ids[NmsHousingTrophies::kWireSlots];
	int32_t  tiers[NmsHousingTrophies::kWireSlots];
	uint32_t stat_item_slots[NmsHousingTrophies::kWireSlots] = {};
	std::vector<uint32_t> stat_items;
};

// ------------------------------------------------------------------
// State machine (port of upstream Housing::TrophyBenefits; free tier only).
// ------------------------------------------------------------------

bool DefValid(const TrophyDef &def)
{
	if (def.id == NmsHousingTrophies::kEmptyBenefit || !def.placed_item_id || def.name.empty() ||
	    def.tiers.empty() || def.tiers.size() > NmsHousingTrophies::kWireSlots) {
		return false;
	}
	uint32_t prior_level = 0;
	for (const auto &tier : def.tiers) {
		if (!tier.stat_item_id || !tier.minimum_level || tier.minimum_level < prior_level ||
		    tier.minimum_level > 255) {
			return false;
		}
		prior_level = tier.minimum_level;
	}
	return true;
}

// Prune every selection the current catalogue / eligibility / level / capacity refuses.
// Port of TrophyBenefits::Revalidate; paid tiers are refused outright (paid_authorized
// is hardwired false until the billing follow-up exists -- never grant one for free).
void Revalidate(TrophyView &view, const TrophyCatalog &catalog, uint32_t level)
{
	uint32_t count = 0;
	bool     paid  = false;

	for (uint32_t i = 0; i < NmsHousingTrophies::kWireSlots; ++i) {
		const uint32_t id   = view.ids[i];
		const int32_t  tier = view.tiers[i];

		if (id == NmsHousingTrophies::kEmptyBenefit) {
			view.tiers[i] = -1;
			continue;
		}

		auto found = catalog.find(id);
		if (count >= NmsHousingTrophies::kCapacity || found == catalog.end() ||
		    !DefValid(found->second) || !found->second.eligible || tier < 0 ||
		    static_cast<size_t>(tier) >= found->second.tiers.size() ||
		    level < found->second.tiers[tier].minimum_level) {
			view.ids[i]   = NmsHousingTrophies::kEmptyBenefit;
			view.tiers[i] = -1;
			continue;
		}

		++count;
		paid = paid || found->second.tiers[tier].favor_cost != 0;
	}

	// Paid favor accounting is not implemented (billing follow-up). Any paid tier or an
	// empty selection forces the activation off, exactly like upstream.
	if ((paid) || !count) {
		view.enabled = false;
	}

	view.stat_items.clear();
	memset(view.stat_item_slots, 0, sizeof(view.stat_item_slots));
	if (view.enabled) {
		for (uint32_t i = 0; i < NmsHousingTrophies::kWireSlots; ++i) {
			if (view.ids[i] == NmsHousingTrophies::kEmptyBenefit) {
				continue;
			}
			auto found = catalog.find(view.ids[i]);
			if (found == catalog.end()) {
				continue;
			}
			const uint32_t stat_item = found->second.tiers[view.tiers[i]].stat_item_id;
			view.stat_item_slots[i] = stat_item;
			view.stat_items.push_back(stat_item);
		}
	}
}

// Returns true when the client's requested selection was applied (and persisted by the
// caller). Port of TrophyBenefits::Select; an edit always clears the activation.
bool SelectApplies(TrophyView &view, const TrophyCatalog &catalog, uint32_t level,
                   uint32_t slot, uint32_t benefit_id, int32_t tier)
{
	if (slot >= NmsHousingTrophies::kWireSlots) {
		return false;
	}

	if (benefit_id == NmsHousingTrophies::kEmptyBenefit) {
		if (tier != -1) {
			return false;
		}
		view.ids[slot]   = NmsHousingTrophies::kEmptyBenefit;
		view.tiers[slot] = -1;
		return true;
	}

	auto found = catalog.find(benefit_id);
	if (found == catalog.end() || !DefValid(found->second) || !found->second.eligible ||
	    tier < 0 || static_cast<size_t>(tier) >= found->second.tiers.size() ||
	    level < found->second.tiers[tier].minimum_level) {
		return false;
	}

	for (uint32_t i = 0; i < NmsHousingTrophies::kWireSlots; ++i) {
		if (i != slot && view.ids[i] == benefit_id) {
			return false; // one benefit per character, like upstream's distinct_benefit key
		}
	}

	uint32_t count = 0;
	for (uint32_t i = 0; i < NmsHousingTrophies::kWireSlots; ++i) {
		count += (view.ids[i] != NmsHousingTrophies::kEmptyBenefit && i != slot) ? 1 : 0;
	}
	if (count + 1 > NmsHousingTrophies::kCapacity) {
		return false;
	}

	view.ids[slot]   = benefit_id;
	view.tiers[slot] = tier;
	return true;
}

bool ToggleApplies(TrophyView &view, const TrophyCatalog &catalog, uint32_t level, bool enable)
{
	Revalidate(view, catalog, level);
	if (!enable) {
		view.enabled = false;
		return true;
	}

	bool any = false;
	for (uint32_t i = 0; i < NmsHousingTrophies::kWireSlots; ++i) {
		if (view.ids[i] == NmsHousingTrophies::kEmptyBenefit) {
			continue;
		}
		any = true;
		auto found = catalog.find(view.ids[i]);
		if (found == catalog.end() || found->second.tiers[view.tiers[i]].favor_cost != 0) {
			return false; // a paid tier cannot activate without the billing layer
		}
	}
	if (!any) {
		return false;
	}

	view.enabled = true;
	Revalidate(view, catalog, level);
	return true;
}

// ------------------------------------------------------------------
// Persistence + eligibility.
// ------------------------------------------------------------------

bool LoadCatalog(Client *c, TrophyCatalog &out)
{
	auto rows = database.QueryDatabase(fmt::format(
		"SELECT b.benefit_id, b.placed_item_id, b.name, b.min_level, b.favor_cost, b.stat_item_id, "
		"       EXISTS(SELECT 1 FROM nms_house_item h JOIN nms_plot p ON p.door_id = h.door_id "
		"              WHERE h.item_id = b.placed_item_id AND h.container = -1 AND h.stowed = 0 "
		"                AND p.owner_char_id = {}) AS eligible "
		"FROM nms_housing_trophy_benefits b",
		c->CharacterID()
	));

	if (!rows.Success()) {
		return false;
	}

	for (auto row : rows) {
		TrophyDef def;
		def.id             = Strings::ToUnsignedInt(row[0]);
		def.placed_item_id = Strings::ToUnsignedInt(row[1]);
		def.name           = row[2] ? row[2] : "";
		TrophyTier tier;
		tier.minimum_level = Strings::ToUnsignedInt(row[3]);
		tier.favor_cost    = Strings::ToUnsignedInt(row[4]);
		tier.stat_item_id  = Strings::ToUnsignedInt(row[5]);
		def.tiers.push_back(tier);
		def.eligible = row[6] && Strings::ToUnsignedInt(row[6]) != 0;
		out[def.id]  = std::move(def);
	}

	return true;
}

void LoadState(Client *c, TrophyView &view)
{
	for (uint32_t i = 0; i < NmsHousingTrophies::kWireSlots; ++i) {
		view.ids[i]   = NmsHousingTrophies::kEmptyBenefit;
		view.tiers[i] = -1;
	}

	auto enabled = database.QueryDatabase(fmt::format(
		"SELECT enabled FROM nms_housing_trophy_state WHERE character_id = {} LIMIT 1",
		c->CharacterID()
	));
	view.enabled = enabled.Success() && enabled.RowCount() && Strings::ToUnsignedInt(enabled.begin()[0]) != 0;

	auto selections = database.QueryDatabase(fmt::format(
		"SELECT slot, benefit_id, tier FROM nms_housing_trophy_selections "
		"WHERE character_id = {} ORDER BY slot",
		c->CharacterID()
	));

	if (!selections.Success()) {
		return;
	}

	for (auto row : selections) {
		const uint32_t slot = Strings::ToUnsignedInt(row[0]);
		if (slot >= NmsHousingTrophies::kWireSlots) {
			continue; // the CHECK keeps this empty; belt and braces for hand-edited rows
		}
		view.ids[slot]   = Strings::ToUnsignedInt(row[1]);
		view.tiers[slot] = static_cast<int32_t>(Strings::ToInt(row[2]));
	}
}

void PersistSelections(Client *c, const TrophyView &view)
{
	// Selections rewrite wholesale: small, and it enforces distinct_benefit for free.
	database.QueryDatabase(fmt::format(
		"DELETE FROM nms_housing_trophy_selections WHERE character_id = {}",
		c->CharacterID()
	));

	for (uint32_t slot = 0; slot < NmsHousingTrophies::kWireSlots; ++slot) {
		if (view.ids[slot] == NmsHousingTrophies::kEmptyBenefit) {
			continue;
		}
		database.QueryDatabase(fmt::format(
			"INSERT INTO nms_housing_trophy_selections (character_id, slot, benefit_id, tier) "
			"VALUES ({}, {}, {}, {})",
			c->CharacterID(), slot, view.ids[slot], view.tiers[slot]
		));
	}
}

void PersistEnabled(Client *c, bool enable)
{
	database.QueryDatabase(fmt::format(
		"INSERT INTO nms_housing_trophy_state (character_id, enabled, revision) "
		"VALUES ({}, {}, 1) "
		"ON DUPLICATE KEY UPDATE enabled = VALUES(enabled), revision = revision + 1",
		c->CharacterID(), enable ? 1 : 0
	));
}

// ------------------------------------------------------------------
// Client sync.
// ------------------------------------------------------------------

bool Ready(Client *c)
{
	return c && c->Connected() && c->ClientDataLoaded() &&
	       c->ClientVersion() == EQ::versions::ClientVersion::RoF2 &&
	       RuleB(Custom, HousingTrophies);
}

void QueueBytes(Client *c, EmuOpcode opcode, const std::vector<uint8_t> &bytes)
{
	EQApplicationPacket packet(opcode, bytes.size());
	if (!bytes.empty()) {
		memcpy(packet.pBuffer, bytes.data(), bytes.size());
	}
	c->QueuePacket(&packet);
}

// Port of upstream TrophyStatItem::Send: one full item body per filled slot, typed as a
// personal trophy packet. The RoF2 encoder rewrites the tag to the ordinary tribute item
// packet and types the slot as the client's trophy-tribute row.
void SendStatItems(Client *c, const uint32_t stat_item_slots[NmsHousingTrophies::kWireSlots])
{
	for (uint32_t i = 0; i < NmsHousingTrophies::kWireSlots; ++i) {
		if (!stat_item_slots[i]) {
			continue;
		}
		EQ::ItemInstance *inst = database.CreateItem(stat_item_slots[i], 1);
		if (!inst) {
			LogError("[Housing] trophy stat item [{}] failed to load for [{}]",
			         stat_item_slots[i], c->GetName());
			continue;
		}
		c->SendItemPacket(static_cast<int16>(i), inst, ItemPacketPersonalTrophy);
		safe_delete(inst);
	}
}

// Port of upstream Sync: timer (0 remaining -- free tier has no paid clock), the 84-byte
// benefits snapshot, an empty-window marker while inactive, then the stat items.
// Packet work only: callers own the m_housing_trophy_sent flag (friendship does not
// reach anonymous-namespace helpers).
void Sync(Client *c, const TrophyView &view)
{
	std::vector<uint8_t> timer;
	AppendU32(timer, 0);
	QueueBytes(c, OP_RealEstateTrophyTimer, timer);

	std::vector<uint8_t> benefits;
	AppendU32(benefits, view.enabled ? 1 : 0);
	for (uint32_t i = 0; i < NmsHousingTrophies::kWireSlots; ++i) {
		AppendU32(benefits, view.ids[i]);
	}
	for (uint32_t i = 0; i < NmsHousingTrophies::kWireSlots; ++i) {
		AppendU32(benefits, static_cast<uint32_t>(view.tiers[i]));
	}
	QueueBytes(c, OP_RealEstateTrophyList, benefits);

	if (!view.enabled) {
		QueueBytes(c, OP_RealEstateTrophyClear, {});
	}

	SendStatItems(c, view.stat_item_slots);
}

} // namespace

namespace NmsHousingTrophies {

void Refresh(Client *c, bool notify)
{
	if (!c) {
		return;
	}

	std::vector<uint32_t> prior = c->m_housing_trophy_stat_items;
	c->m_housing_trophy_stat_items.clear();

	if (Ready(c)) {
		TrophyCatalog catalog;
		if (!LoadCatalog(c, catalog)) {
			LogError("[Housing] trophy catalogue query failed for [{}]", c->GetName());
			return;
		}

		TrophyView view;
		LoadState(c, view);
		Revalidate(view, catalog, c->GetLevel());

		c->m_housing_trophy_stat_items = view.stat_items;
		if (notify) {
			Sync(c, view);
			c->m_housing_trophy_sent = true;
		}
	} else if (c->m_housing_trophy_sent && c->Connected()) {
		QueueBytes(c, OP_RealEstateTrophyClear, {});
		c->m_housing_trophy_sent = false;
	}

	if (prior != c->m_housing_trophy_stat_items) {
		c->CalcBonuses();
		c->SendHPUpdate(true);
	}
}

void Invalidate(Client *c)
{
	if (!c) {
		return;
	}

	c->m_housing_trophy_stat_items.clear();
	if (c->m_housing_trophy_sent && c->Connected()) {
		QueueBytes(c, OP_RealEstateTrophyClear, {});
	}
	c->m_housing_trophy_sent  = false;
	c->m_housing_trophy_dirty = true;
	c->CalcBonuses();
	c->SendHPUpdate(true);
}

void ClientProcess(Client *c)
{
	if (!c || !c->Connected() || !c->ClientDataLoaded()) {
		return;
	}

	if (!RuleB(Custom, HousingTrophies)) {
		if (!c->m_housing_trophy_stat_items.empty()) {
			Invalidate(c);
		}
		return;
	}

	if (c->m_housing_trophy_dirty) {
		c->m_housing_trophy_dirty = false;
		Refresh(c, false);
	}
}

void OnSourceRemoved(Client *c, uint32_t item_id)
{
	if (!c || !Ready(c)) {
		return;
	}

	// Only a trophy source cares; everything else pays one indexed SELECT per pickup.
	auto source = database.QueryDatabase(fmt::format(
		"SELECT 1 FROM nms_housing_trophy_benefits WHERE placed_item_id = {} LIMIT 1",
		item_id
	));

	if (source.Success() && source.RowCount()) {
		Invalidate(c);
	}
}

} // namespace NmsHousingTrophies

// ------------------------------------------------------------------
// Packet handlers (registered in client_packet.cpp; log-only entries removed).
// ------------------------------------------------------------------

// 0x51a9 C2S, empty body: the client opened the trophy window.
void Client::Handle_OP_RealEstateTrophyOpen(const EQApplicationPacket *app)
{
	LogInfo("[Housing] trophy window open from [{}]", GetName());

	if (!app || app->size != 0 || !Ready(this)) {
		return;
	}

	const auto now = std::chrono::steady_clock::now();
	if (m_housing_trophy_open_last != std::chrono::steady_clock::time_point{} &&
	    now - m_housing_trophy_open_last < std::chrono::seconds(1)) {
		return;
	}
	m_housing_trophy_open_last = now;

	NmsHousingTrophies::Refresh(this, true);
}

// 0x4b65 C2S, 12 bytes: slot, benefit_id, tier.
void Client::Handle_OP_RealEstateTrophy(const EQApplicationPacket *app)
{
	LogInfo("[Housing] trophy select from [{}] ({} bytes)", GetName(), app ? app->size : 0);

	if (!app || app->size != kSelectionSize || !Ready(this)) {
		return;
	}

	const uint32_t slot       = ReadU32(app->pBuffer);
	const uint32_t benefit_id = ReadU32(app->pBuffer + 4);
	const int32_t  tier       = ReadS32(app->pBuffer + 8);

	if (slot >= NmsHousingTrophies::kWireSlots) {
		return;
	}

	TrophyCatalog catalog;
	if (!LoadCatalog(this, catalog)) {
		return;
	}

	TrophyView view;
	LoadState(this, view);

	if (SelectApplies(view, catalog, GetLevel(), slot, benefit_id, tier)) {
		view.enabled = false; // an edit never retains the activation, like upstream
		Revalidate(view, catalog, GetLevel());
		PersistSelections(this, view);
		PersistEnabled(this, false);

		const std::vector<uint32_t> prior = m_housing_trophy_stat_items;
		m_housing_trophy_stat_items = view.stat_items;
		Sync(this, view);
		m_housing_trophy_sent = true;
		if (prior != m_housing_trophy_stat_items) {
			CalcBonuses();
			SendHPUpdate(true);
		}
	} else {
		// Refused: re-read the current state so the window shows the truth.
		NmsHousingTrophies::Refresh(this, true);
	}
}

// 0x756a C2S, 4 bytes: enable flag (0/1).
void Client::Handle_OP_RealEstateTrophyToggle(const EQApplicationPacket *app)
{
	LogInfo("[Housing] trophy toggle from [{}] ({} bytes)", GetName(), app ? app->size : 0);

	if (!app || app->size != kTimerSize || !Ready(this)) {
		return;
	}

	const uint32_t enable = ReadU32(app->pBuffer);
	if (enable > 1) {
		return;
	}

	TrophyCatalog catalog;
	if (!LoadCatalog(this, catalog)) {
		return;
	}

	TrophyView view;
	LoadState(this, view);

	if (ToggleApplies(view, catalog, GetLevel(), enable != 0)) {
		PersistEnabled(this, view.enabled);
		m_housing_trophy_stat_items = view.stat_items;
		Sync(this, view);
		m_housing_trophy_sent = true;
		CalcBonuses();
		SendHPUpdate(true);
	} else {
		Message(Chat::Red, "The selected trophy benefits are not available.");
		QueueBytes(this, OP_RealEstateTrophyClear, {});
	}
}
