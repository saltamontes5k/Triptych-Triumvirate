// /nmsloot personal loot offers. Ported from mukluk4/Modular-Options modules/loot-offers
// (which already carries voidforged 939a7501's Hailstone layer). Changes from the module
// file are marked "EQS:" below:
//   - no common/modules.h: the NMS loot-buff upgrade (DoUpgradeLoot) is unconditionally
//     available in this tree, so ApplyLootBuffToRolled is not #ifdef'd
//   - ExpireOffers delivers expired-but-claimable offers instead of deleting them
//   - corpse emptying requires every recipient to be offer-capable (mixed groups keep loot)

#include "../common/global_define.h"
#include "nms_loot_offers.h"
#include "nms_vault.h"

#include "../common/eq_constants.h"
#include "../common/emu_constants.h"
#include "../common/eq_packet.h"
#include "../common/eq_packet_structs.h"
#include "../common/eqemu_logsys.h"
#include "../common/item_data.h"
#include "../common/item_instance.h"
#include "../common/loot.h"
#include "../common/misc_functions.h"
#include "../common/mysql_request_row.h"
#include "../common/rulesys.h"
#include "../common/say_link.h"
#include "../common/strings.h"
#include "client.h"
#include "common.h"
#include "corpse.h"
#include "entity.h"
#include "groups.h"
#include "npc.h"
#include "raids.h"
#include "zone.h"
#include "zonedb.h"

#include <climits>
#include <algorithm>
#include <map>
#include <set>
#include <fmt/format.h>

extern ZoneDatabase database;
extern Zone *zone;

namespace {
	bool tables_checked = false;
	bool tables_ready = false;

	// Hailstone's NMS add-on: OP_PersonalLootList's show flag and the OP_PersonalLootAction actions it sends
	// (hailstone-nms nms_packets.h). Its window has only Keep and Sell; Sell on an offer worth nothing destroys it.
	constexpr uint32 kPersonalLootShow = 1;
	constexpr uint32 kPersonalLootKeep = 1, kPersonalLootSell = 3, kPersonalLootLootAll = 5,
		kPersonalLootSellAll = 6, kPersonalLootRefresh = 7, kPersonalLootInspect = 9,
		kPersonalLootSetDefer = 14, kPersonalLootSetReport = 15, kPersonalLootSetSellUnder = 16,
		kPersonalLootGetSettings = 17, kPersonalLootInspectItem = 18, kPersonalLootHistory = 19,
		kPersonalLootHello = 20;
	constexpr uint32 kPersonalLootMaxRows = 100;

	void SendPersonalLootList(Client *c, uint32 flags);

	// EQS: forward declarations - ExpireOffers' delivery path runs ahead of these definitions
	bool DeleteOffer(uint32 character_id, uint32 offer_id);
	bool SaveOffer(NmsLootOffer &offer, int expire_seconds);
	NmsLootOffer RowToOffer(MySQLRequestRow &row);
	const char *OfferSelectColumns();

	bool EnsureTables()
	{
		if (tables_checked) {
			return tables_ready;
		}
		auto table = database.QueryDatabase("SHOW TABLES LIKE 'character_nms_loot_offers'");
		// A failed QUERY is not a failed SCHEMA. Latching tables_checked before the answer
		// was known meant one transient DB error at first use disabled loot offers for the
		// whole life of the zone process, and hid a schema fix applied to a running server
		// until restart. Only a definitive answer is cached; a query failure retries.
		if (!table.Success()) {
			LogError("NmsLootOffers: table check query failed; will retry on next use");
			return false;
		}
		tables_checked = true;
		if (table.RowCount() == 0) {
			tables_ready = false;
			return tables_ready;
		}
		auto columns = database.QueryDatabase(
			"SELECT column_name, data_type, column_type FROM information_schema.columns "
			"WHERE table_schema = DATABASE() "
			"AND table_name = 'character_nms_loot_offers' "
			"AND column_name IN ('corpse_serial', 'instance_id', 'passed', 'passed_from')"
		);
		if (!columns.Success()) {
			tables_checked = false;
			LogError("NmsLootOffers: column check query failed; will retry on next use");
			return false;
		}
		tables_ready = false;
		if (columns.RowCount() < 4) {
			return tables_ready;
		}
		bool have_serial = false;
		bool have_instance = false;
		bool have_passed = false;
		bool have_passed_from = false;
		for (auto row = columns.begin(); row != columns.end(); ++row) {
			const std::string name = Strings::ToLower(row[0] ? row[0] : "");
			const std::string type = Strings::ToLower(row[1] ? row[1] : "");
			const std::string column_type = Strings::ToLower(row[2] ? row[2] : "");
			if (name == "corpse_serial") {
				have_serial = type == "bigint" && Strings::Contains(column_type, "unsigned");
			}
			else if (name == "instance_id") {
				have_instance = true;
			}
			else if (name == "passed") {
				have_passed = true;
			}
			else if (name == "passed_from") {
				have_passed_from = true;
			}
		}
		tables_ready = have_serial && have_instance && have_passed && have_passed_from;
		return tables_ready;
	}

	int RemainingExpireSeconds(const NmsLootOffer &offer)
	{
		return offer.expire_remaining > 0 ? offer.expire_remaining : 1;
	}

	// EQS: delivers expired-but-claimable offers instead of silently deleting them (the window's
	// countdown says "until the server delivers it anyway"). An expired offer drops into the
	// player's bags when they are in the offer's zone; offers from other zones (invisible since
	// they left) and rows of offline characters are reclaimed by the plain DELETE.
	void ExpireOffers(Client *c)
	{
		if (!EnsureTables()) {
			return;
		}
		const uint32 character_id = c ? c->CharacterID() : 0;
		if (!character_id) {
			return;
		}
		if (!c || !NmsLootOffersEnabled() || !zone) {
			database.QueryDatabase(fmt::format(
				"DELETE FROM character_nms_loot_offers WHERE character_id = {} AND expires_at < NOW()",
				character_id
			));
			return;
		}

		auto expired = database.QueryDatabase(fmt::format(
			"SELECT {} FROM character_nms_loot_offers WHERE character_id = {} AND passed = 0 AND expires_at < NOW()",
			OfferSelectColumns(),
			character_id
		));
		if (expired.Success()) {
			for (auto row = expired.begin(); row != expired.end(); ++row) {
				NmsLootOffer offer = RowToOffer(row);
				if (!offer.item_id) {
					continue; // final DELETE reclaims it
				}
				if (offer.zone_id != zone->GetZoneID() || offer.instance_id != zone->GetInstanceID()) {
					continue; // not visible from this zone; final DELETE reclaims it
				}
				if (!DeleteOffer(character_id, offer.id)) {
					continue;
				}
				if (NmsLootOfferApply(c, offer, NmsLootAction::Keep, "")) {
					continue; // delivered
				}
				// Could not deliver (lore conflict, full bags...). Keep the offer alive briefly;
				// the next sweep retries, and plain expiry still reclaims it afterwards.
				offer.id = 0;
				offer.passed = false;
				SaveOffer(offer, 60);
			}
		}
		database.QueryDatabase(fmt::format(
			"DELETE FROM character_nms_loot_offers WHERE character_id = {} AND expires_at < NOW() - INTERVAL 1 SECOND",
			character_id
		));
	}

	bool DeleteOffer(uint32 character_id, uint32 offer_id)
	{
		if (!EnsureTables() || !offer_id || !character_id) {
			return false;
		}
		auto results = database.QueryDatabase(fmt::format(
			"DELETE FROM character_nms_loot_offers WHERE id = {} AND character_id = {}",
			offer_id,
			character_id
		));
		return results.Success() && results.RowsAffected() > 0;
	}

	bool SaveOffer(NmsLootOffer &offer, int expire_seconds)
	{
		if (!EnsureTables() || !zone) {
			return false;
		}
		if (expire_seconds < 1) {
			expire_seconds = 1;
		}

		auto results = database.QueryDatabase(fmt::format(
			"INSERT INTO character_nms_loot_offers "
			"(character_id, zone_id, instance_id, corpse_id, corpse_serial, item_id, icon, charges, bonus, name, "
			"aug1, aug2, aug3, aug4, aug5, aug6, passed, passed_from, expires_at) "
			"VALUES ({}, {}, {}, {}, {}, {}, {}, {}, {}, '{}', {}, {}, {}, {}, {}, {}, {}, '{}', "
			"DATE_ADD(NOW(), INTERVAL {} SECOND))",
			offer.character_id,
			offer.zone_id ? offer.zone_id : zone->GetZoneID(),
			offer.instance_id,
			offer.corpse_id,
			offer.corpse_serial,
			offer.item_id,
			offer.icon,
			offer.charges,
			offer.bonus,
			Strings::Escape(offer.name),
			offer.aug[0],
			offer.aug[1],
			offer.aug[2],
			offer.aug[3],
			offer.aug[4],
			offer.aug[5],
			offer.passed ? 1 : 0,
			Strings::Escape(offer.passed_from),
			expire_seconds
		));
		if (!results.Success()) {
			return false;
		}
		offer.id = results.LastInsertedID();
		if (!offer.id) {
			return false;
		}
		offer.expire_remaining = expire_seconds;
		return true;
	}

	NmsLootOffer RowToOffer(MySQLRequestRow &row)
	{
		NmsLootOffer offer;
		offer.id = Strings::ToUnsignedInt(row[0]);
		offer.character_id = Strings::ToUnsignedInt(row[1]);
		offer.zone_id = Strings::ToUnsignedInt(row[2]);
		offer.instance_id = Strings::ToUnsignedInt(row[3]);
		offer.corpse_id = Strings::ToUnsignedInt(row[4]);
		offer.corpse_serial = Strings::ToUnsignedBigInt(row[5]);
		offer.item_id = Strings::ToUnsignedInt(row[6]);
		offer.icon = Strings::ToUnsignedInt(row[7]);
		offer.charges = static_cast<int16>(Strings::ToInt(row[8]));
		offer.bonus = static_cast<uint8>(Strings::ToInt(row[9]));
		offer.name = row[10] ? row[10] : "";
		for (int i = 0; i < 6; ++i) {
			offer.aug[i] = Strings::ToUnsignedInt(row[11 + i]);
		}
		offer.passed = Strings::ToInt(row[17]) != 0;
		offer.passed_from = row[18] ? row[18] : "";
		offer.expire_remaining = Strings::ToInt(row[19]);
		return offer;
	}

	const char *OfferSelectColumns()
	{
		return "id, character_id, zone_id, instance_id, corpse_id, corpse_serial, item_id, icon, charges, bonus, name, "
			"aug1, aug2, aug3, aug4, aug5, aug6, passed, passed_from, "
			"GREATEST(0, UNIX_TIMESTAMP(expires_at) - UNIX_TIMESTAMP(NOW()))";
	}

	bool LoadOfferById(uint32 character_id, uint32 offer_id, NmsLootOffer &out)
	{
		if (!EnsureTables() || !character_id || !offer_id) {
			return false;
		}

		auto results = database.QueryDatabase(fmt::format(
			"SELECT {} FROM character_nms_loot_offers "
			"WHERE id = {} AND character_id = {} AND passed = 0 AND expires_at >= NOW()",
			OfferSelectColumns(),
			offer_id,
			character_id
		));
		if (!results.Success() || results.RowCount() == 0) {
			return false;
		}

		out = RowToOffer(results.begin());
		return true;
	}

	std::vector<NmsLootOffer> LoadOffers(uint32 character_id, uint32 zone_id, uint32 corpse_id, uint64 corpse_serial)
	{
		std::vector<NmsLootOffer> out;
		if (!EnsureTables()) {
			return out;
		}

		std::string sql = fmt::format(
			"SELECT {} FROM character_nms_loot_offers WHERE character_id = {} AND expires_at >= NOW()",
			OfferSelectColumns(),
			character_id
		);
		if (zone_id) {
			sql += fmt::format(" AND zone_id = {} AND instance_id = {}", zone_id, zone ? zone->GetInstanceID() : 0);
		}
		if (corpse_id) {
			sql += fmt::format(" AND corpse_id = {}", corpse_id);
		}
		if (corpse_serial) {
			sql += fmt::format(" AND corpse_serial = {}", corpse_serial);
		}
		sql += " ORDER BY id";

		auto results = database.QueryDatabase(sql);
		if (!results.Success()) {
			return out;
		}

		for (auto row = results.begin(); row != results.end(); ++row) {
			out.push_back(RowToOffer(row));
		}
		return out;
	}

	void SendOffers(Client *c, const std::vector<NmsLootOffer> &offers, uint32 corpse_id)
	{
		if (!c) {
			return;
		}
		// Hailstone's window replaces its whole list with each packet, so it always gets every offer here
		if (c->GetNmsPersonalLootWindow()) {
			SendPersonalLootList(c, kPersonalLootShow);
			return;
		}

		std::vector<const NmsLootOffer *> active;
		active.reserve(offers.size());
		for (const auto &offer : offers) {
			if (!offer.passed) {
				active.push_back(&offer);
			}
		}
		if (active.empty()) {
			return;
		}

		uint32 count = static_cast<uint32>(active.size());
		if (count > 64) {
			count = 64;
		}
		int expire = RemainingExpireSeconds(*active.front());
		for (uint32 i = 0; i < count; ++i) {
			const int remain = RemainingExpireSeconds(*active[i]);
			if (remain < expire) {
				expire = remain;
			}
		}
		const uint32 size = sizeof(NmsLootOfferHeader_Struct) + (count * sizeof(NmsLootOfferEntry_Struct));
		auto outapp = new EQApplicationPacket(OP_NmsLootOffer, size);
		memset(outapp->pBuffer, 0, size);
		auto *header = reinterpret_cast<NmsLootOfferHeader_Struct *>(outapp->pBuffer);
		header->count = count;
		header->corpse_id = corpse_id;
		header->expire_seconds = static_cast<uint32>(expire);
		if (auto *corpse = entity_list.GetCorpseByID(static_cast<uint16>(corpse_id))) {
			strn0cpy(header->title, corpse->GetName(), sizeof(header->title));
		}

		auto *entries = reinterpret_cast<NmsLootOfferEntry_Struct *>(outapp->pBuffer + sizeof(NmsLootOfferHeader_Struct));
		for (uint32 i = 0; i < count; ++i) {
			entries[i].offer_id = active[i]->id;
			entries[i].icon = active[i]->icon;
			entries[i].charges = active[i]->charges;
			entries[i].item_id = active[i]->item_id;
			entries[i].bonus = active[i]->bonus;
			strn0cpy(entries[i].name, active[i]->name.c_str(), sizeof(entries[i].name));
			if (!active[i]->passed_from.empty()) {
				strn0cpy(entries[i].name2, active[i]->passed_from.c_str(), sizeof(entries[i].name2));
			}
		}

		c->QueuePacket(outapp);
		safe_delete(outapp);
	}

	EQ::ItemInstance *MakeLootItem(const NmsLootOffer &offer)
	{
		return database.CreateItem(
			offer.item_id,
			offer.charges,
			offer.aug[0],
			offer.aug[1],
			offer.aug[2],
			offer.aug[3],
			offer.aug[4],
			offer.aug[5]
		);
	}

	bool OfferHasAugments(const NmsLootOffer &offer)
	{
		for (int i = 0; i < 6; ++i) {
			if (offer.aug[i]) {
				return true;
			}
		}
		return false;
	}

	// What NmsLootOfferApply's Sell pays for this offer, 0 when it refuses to sell it
	uint64 OfferSellCopper(const NmsLootOffer &offer)
	{
		const auto *item = database.GetItem(offer.item_id);
		if (!item || item->Price == 0 || item->NoDrop == 0 || item->SummonedFlag || OfferHasAugments(offer)) {
			return 0;
		}
		const int16 qty = offer.charges > 0 ? offer.charges : 1;
		return static_cast<uint64>(item->Price) * static_cast<uint64>(qty);
	}

	void SendPersonalLootList(Client *c, uint32 flags)
	{
		if (!c || !zone) {
			return;
		}

		std::vector<NmsLootOffer> active;
		for (auto &offer : LoadOffers(c->CharacterID(), zone->GetZoneID(), 0, 0)) {
			if (!offer.passed && active.size() < kPersonalLootMaxRows) {
				active.push_back(std::move(offer));
			}
		}

		const uint32 count = static_cast<uint32>(active.size());
		const uint32 size = sizeof(PersonalLootListHeader_Struct) + (count * sizeof(PersonalLootRow_Struct));
		auto outapp = new EQApplicationPacket(OP_PersonalLootList, size);
		memset(outapp->pBuffer, 0, size);
		auto *header = reinterpret_cast<PersonalLootListHeader_Struct *>(outapp->pBuffer);
		header->flags = flags;
		header->count = count;

		auto *rows = reinterpret_cast<PersonalLootRow_Struct *>(outapp->pBuffer + sizeof(PersonalLootListHeader_Struct));
		for (uint32 i = 0; i < count; ++i) {
			const auto &offer = active[i];
			const auto *item = database.GetItem(offer.item_id);
			const uint32 charges = offer.charges > 0 ? static_cast<uint32>(offer.charges) : 0;
			rows[i].pending_id = offer.id;
			rows[i].item_id = offer.item_id;
			rows[i].icon = offer.icon;
			rows[i].quantity = item && item->Stackable ? std::max<uint32>(charges, 1) : 1;
			rows[i].charges = charges;
			rows[i].sell_value = static_cast<uint32>(std::min<uint64>(OfferSellCopper(offer), UINT32_MAX));
			rows[i].seconds_left = static_cast<uint32>(RemainingExpireSeconds(offer));
			rows[i].lore = item && item->LoreFlag ? 1 : 0;
			rows[i].no_drop = item && item->NoDrop == 0 ? 1 : 0;
			rows[i].augmented = OfferHasAugments(offer) ? 1 : 0;
			strn0cpy(rows[i].item_name, offer.name.c_str(), sizeof(rows[i].item_name));
			// The window's "from" column: who passed it, else the corpse it came from while that corpse is still here
			std::string from;
			if (!offer.passed_from.empty()) {
				from = fmt::format("passed by {}", offer.passed_from);
			}
			else if (auto *corpse = entity_list.GetCorpseByID(static_cast<uint16>(offer.corpse_id))) {
				if (corpse->GetNmsLootSerial() == offer.corpse_serial) {
					from = corpse->GetCleanName();
				}
			}
			strn0cpy(rows[i].npc_name, from.c_str(), sizeof(rows[i].npc_name));
		}

		c->QueuePacket(outapp);
		safe_delete(outapp);
	}

	void SendPersonalLootSettings(Client *c)
	{
		auto outapp = new EQApplicationPacket(OP_PersonalLootSettings, sizeof(PersonalLootSettings_Struct));
		memset(outapp->pBuffer, 0, outapp->size);
		auto *s = reinterpret_cast<PersonalLootSettings_Struct *>(outapp->pBuffer);
		s->flags = NmsLootOffersEnabled() ? 1 : 0;
		s->timeout_seconds = static_cast<uint32>(std::max(0, RuleI(Custom, NmsLootOfferExpireSeconds)));
		c->QueuePacket(outapp);
		safe_delete(outapp);
	}

	// No loot history is kept on this server: an empty one, so the History tab stops waiting
	void SendPersonalLootHistory(Client *c)
	{
		auto outapp = new EQApplicationPacket(OP_PersonalLootHistory, sizeof(uint32));
		memset(outapp->pBuffer, 0, outapp->size);
		c->QueuePacket(outapp);
		safe_delete(outapp);
	}

	// Claiming an offer discovers its item, as taking it off a corpse does (Corpse::LootCorpseItem)
	void DiscoverOfferItem(Client *c, uint32 item_id)
	{
		if (RuleB(Character, EnableDiscoveredItems) && c && !c->GetGM() && !c->IsDiscovered(item_id)) {
			c->DiscoverItem(item_id);
		}
	}

	bool OfferStillClaimable(Client *c, const NmsLootOffer &offer)
	{
		if (!c || !offer.item_id) {
			return false;
		}
		if (!zone || offer.zone_id != zone->GetZoneID() || offer.instance_id != zone->GetInstanceID()) {
			return false;
		}
		return true;
	}

	bool PutInBank(Client *c, EQ::ItemInstance *inst)
	{
		if (!c || !inst) {
			return false;
		}
		for (int16 slot = EQ::invslot::BANK_BEGIN; slot <= EQ::invslot::BANK_END; ++slot) {
			if (c->GetInv().GetItem(slot)) {
				continue;
			}
			if (c->PutItemInInventory(slot, *inst, true)) {
				return true;
			}
			auto *placed = c->GetInv().GetItem(slot);
			if (placed && inst->GetItem() && placed->GetItem()
				&& placed->GetItem()->ID == inst->GetItem()->ID) {
				return true;
			}
		}
		return false;
	}

	bool EligiblePassTarget(Client *from, Client *to, Corpse *corpse)
	{
		if (!from || !to || from == to) {
			return false;
		}
		if (from->GetGroup() && from->GetGroup()->IsGroupMember(to)) {
			return true;
		}
		if (from->GetRaid() && from->GetRaid()->IsRaidMember(to)) {
			return true;
		}
		if (corpse && corpse->CanPlayerLoot(static_cast<int>(to->CharacterID()))) {
			return true;
		}
		return false;
	}

	void ResendExistingOffers(Client *c, Corpse *corpse)
	{
		if (!c || !corpse || !zone) {
			return;
		}

		ExpireOffers(c);
		// Corpse entity ids are recycled from EntityList::free_ids, so the same corpse_id
		// names many different corpses over a zone's life. An offer is a personal roll that
		// deliberately outlives the corpse it came from, so the old "delete every row for
		// this corpse_id with a different serial" cleanup destroyed unclaimed loot the player
		// had never seen. Load every serial under this corpse_id instead: stale rows are shown
		// alongside the fresh ones in the same window, and expires_at still reclaims them.
		auto existing = LoadOffers(c->CharacterID(), zone->GetZoneID(), corpse->GetID(), 0);
		if (!existing.empty()) {
			SendOffers(c, existing, corpse->GetID());
		}
	}

	void CreateOffersFromItems(Client *c, Corpse *corpse, const LootItems &items)
	{
		if (!c || !corpse || !zone) {
			return;
		}

		const int expire_seconds = RuleI(Custom, NmsLootOfferExpireSeconds);
		std::vector<NmsLootOffer> created;
		for (auto *item : items) {
			if (!item || !item->item_id) {
				continue;
			}
			const auto *data = database.GetItem(item->item_id);
			if (!data) {
				continue;
			}

			NmsLootOffer offer;
			offer.character_id = c->CharacterID();
			offer.zone_id = zone->GetZoneID();
			offer.instance_id = zone->GetInstanceID();
			offer.corpse_id = corpse->GetID();
			offer.corpse_serial = corpse->GetNmsLootSerial();
			offer.item_id = item->item_id;
			offer.icon = data->Icon;
			offer.charges = static_cast<int16>(item->charges);
			offer.bonus = 0;
			offer.name = data->Name;
			offer.aug[0] = item->aug_1;
			offer.aug[1] = item->aug_2;
			offer.aug[2] = item->aug_3;
			offer.aug[3] = item->aug_4;
			offer.aug[4] = item->aug_5;
			offer.aug[5] = item->aug_6;

			// A stackable item this character already has unclaimed here grows that row instead of adding one
			const bool no_augs = !item->aug_1 && !item->aug_2 && !item->aug_3 && !item->aug_4 && !item->aug_5 && !item->aug_6;
			if (data->Stackable && data->StackSize > 1 && no_augs) {
				auto merged = database.QueryDatabase(fmt::format(
					"UPDATE character_nms_loot_offers SET charges = charges + {0}, "
					"expires_at = DATE_ADD(NOW(), INTERVAL {1} SECOND) "
					"WHERE character_id = {2} AND zone_id = {3} AND instance_id = {4} AND item_id = {5} AND passed = 0 "
					"AND expires_at >= NOW() AND aug1 = 0 AND aug2 = 0 AND aug3 = 0 AND aug4 = 0 AND aug5 = 0 AND aug6 = 0 "
					"AND charges + {0} <= {6} ORDER BY id LIMIT 1",
					std::max<int16>(offer.charges, 1), expire_seconds, offer.character_id, offer.zone_id,
					offer.instance_id, offer.item_id, data->StackSize
				));
				if (merged.Success() && merged.RowsAffected() > 0) {
					created.push_back(offer);
					continue;
				}
			}

			if (SaveOffer(offer, expire_seconds)) {
				created.push_back(offer);
			}
		}

		// The add-on replaces its Pending list with each packet, so always send every unclaimed offer
		if (!created.empty()) {
			SendOffers(c, LoadOffers(c->CharacterID(), zone->GetZoneID(), 0, 0), corpse->GetID());
		}
	}

	// The NMS loot buff upgrade (DoUpgradeLoot) - unconditionally available on this base
	void ApplyLootBuffToRolled(NPC *npc, Client *c, LootItems &items)
	{
		if (!npc || !database.LootBuffEnabled()) {
			return;
		}

		for (auto *item : items) {
			if (!item || !item->item_id) {
				continue;
			}
			const auto old_id = item->item_id;
			item->item_id = npc->DoUpgradeLoot(item->item_id);
			if (!c || item->item_id == old_id) {
				continue;
			}

			EQ::SayLinkEngine linker;
			linker.SetLinkType(EQ::saylink::SayLinkItemData);
			linker.SetItemData(database.GetItem(old_id));
			const auto old_item_lnk = linker.GenerateLink();
			linker.SetItemData(database.GetItem(item->item_id));
			const auto new_item_lnk = linker.GenerateLink();
			c->Message(
				Chat::Yellow,
				"Luck is with you! [%s] has become [%s].",
				old_item_lnk.c_str(),
				new_item_lnk.c_str()
			);
		}
	}

	void FreeLootItems(LootItems &items)
	{
		for (auto *item : items) {
			safe_delete(item);
		}
		items.clear();
	}

	void CollectPartyClientsInZone(Client *credit, std::vector<Client *> &out)
	{
		out.clear();
		if (!credit) {
			return;
		}

		std::set<Client *> unique;
		auto add = [&](Client *c) {
			if (c) {
				unique.insert(c);
			}
		};

		add(credit);
		if (auto *g = credit->GetGroup()) {
			for (const auto &m : g->members) {
				if (m && m->IsClient()) {
					add(m->CastToClient());
				}
			}
		}
		if (auto *r = credit->GetRaid()) {
			for (const auto &m : r->members) {
				if (m.is_bot) {
					continue;
				}
				if (m.member && m.member->IsClient()) {
					add(m.member->CastToClient());
				}
			}
		}

		out.assign(unique.begin(), unique.end());
	}

	bool CanAddSellCopper(Client *c, uint64 copper)
	{
		if (!c) {
			return false;
		}
		const int32 current_plat = c->GetPP().platinum;
		if (current_plat < 0) {
			return false;
		}
		const uint64 plat = copper / 1000;
		return plat <= static_cast<uint64>(INT32_MAX) - static_cast<uint64>(current_plat);
	}
}

void NmsLootOfferForgetCorpseItem(uint32 character_id, uint32 corpse_id, uint64 corpse_serial, const LootItem *item)
{
	// Rule first, then tables - the same order every other entry point in this file uses.
	// Without the rule check this ran on EVERY native corpse loot on a server that had
	// merely applied the migrations, issuing a blocking DELETE per item removed -
	// including the per-item loops in Corpse::RemoveItemByPercent and the bag content
	// loop - for a feature that was switched off. Stock loot must be untouched when the
	// rule is off. Rows written while the rule was on are left behind deliberately: they
	// carry expires_at and are reclaimed by ExpireOffers, and no offer is sent or
	// actioned while the rule is off, so a stale row is inert.
	if (!NmsLootOffersEnabled() || !EnsureTables() || !zone || !character_id || !corpse_id || !item || !item->item_id) {
		return;
	}
	// corpse_id alone is not a key: entity ids are recycled within a zone and repeat across
	// zones, so an unscoped DELETE revoked offers earned from a different corpse - or a
	// different zone entirely. Pin it to this zone, this instance and this exact corpse.
	database.QueryDatabase(fmt::format(
		"DELETE FROM character_nms_loot_offers WHERE character_id = {} AND zone_id = {} "
		"AND instance_id = {} AND corpse_id = {} AND corpse_serial = {} "
		"AND item_id = {} AND aug1 = {} AND aug2 = {} AND aug3 = {} AND aug4 = {} AND aug5 = {} AND aug6 = {}",
		character_id,
		zone->GetZoneID(),
		zone->GetInstanceID(),
		corpse_id,
		corpse_serial,
		item->item_id,
		item->aug_1,
		item->aug_2,
		item->aug_3,
		item->aug_4,
		item->aug_5,
		item->aug_6
	));
}

bool NmsLootOffersEnabled()
{
	return RuleB(Custom, NmsLootOffers);
}

bool NmsLootOfferTablesReady()
{
	return EnsureTables();
}

void NmsLootOfferOnCorpseOpen(Client *c, Corpse *corpse)
{
	if (!c || !corpse || !NmsLootOffersEnabled() || !EnsureTables() || !zone) {
		return;
	}
	if (!corpse->IsBeingLootedBy(c)) {
		return;
	}

	const auto loot_type = corpse->GetLootRequestType();
	if (loot_type != LootRequestType::AllowedPVE && loot_type != LootRequestType::GMAllowed) {
		return;
	}
	if (corpse->IsPlayerCorpse()) {
		return;
	}
	ResendExistingOffers(c, corpse);
}

// Upstream Modular-Options keys corpse emptying on the recipient count alone; it does
// not gate on whether every client can render an offer. Matching that is what makes a
// kill single-loot: with 2+ recipients the corpse's loot-table items are removed even
// when one of them is on a plain client. Do not reintroduce a capability gate here
// without also keeping that client's corpse loot off the capable players.
static bool EmptiesCorpseFor(size_t recipients)
{
	return (recipients >= 2 && RuleB(Custom, NmsLootEmptyGroupCorpse)) ||
		(recipients == 1 && RuleB(Custom, NmsLootEmptySoloCorpse));
}

// True when NmsLootOfferOnCorpseCreated will strip the corpse's loot-table items for this kill
bool NmsLootOfferEmptiesCorpse(Client *credit)
{
	if (!credit || !NmsLootOffersEnabled() || !EnsureTables() || !zone) {
		return false;
	}
	std::vector<Client *> recipients;
	CollectPartyClientsInZone(credit, recipients);
	return EmptiesCorpseFor(recipients.size());
}

// Remove the corpse's loot-table items and return an exact copy of every item that
// actually left the corpse. lootdrop_id != 0 is a table roll; quest/script-added items
// (Corpse::AddItem sets lootdrop_id 0) stay on the corpse. The copy keeps the item id,
// charges and augments, so the offers can hand out exactly what was removed.
LootItems RemoveCorpseLootTableItems(Corpse *corpse)
{
	LootItems removed;
	std::vector<LootItem *> table_items;
	for (auto *item : corpse->GetLootItems()) {
		if (item && item->lootdrop_id) {
			table_items.push_back(item);
		}
	}

	for (auto *item : table_items) {
		const uint32 item_id = item->item_id;
		auto *copy = new LootItem(*item);
		const uint32 before = corpse->CountItems();
		corpse->RemoveItem(item, false);
		if (corpse->CountItems() < before) {
			removed.push_back(copy);
		}
		else {
			safe_delete(copy);
			LogError(
				"NmsLootOffers: could not remove item [{}] from corpse [{}]",
				item_id,
				corpse->GetID()
			);
		}
	}

	if (corpse->IsEmpty()) {
		corpse->ResetDecayTimer();
	}
	return removed;
}

void NmsLootOfferOnCorpseCreated(Corpse *corpse, Client *credit, NPC *source)
{
	if (!corpse || !credit || !source || !NmsLootOffersEnabled() || !EnsureTables() || !zone) {
		return;
	}
	if (corpse->IsPlayerCorpse()) {
		return;
	}

	std::vector<Client *> recipients;
	CollectPartyClientsInZone(credit, recipients);
	const bool empties = EmptiesCorpseFor(recipients.size());

	// When the rule is on, take the actual loot-table items off the corpse first and
	// hand every recipient a copy of that exact set. Nothing is freshly re-rolled, and
	// an item that did not leave the corpse is not handed out. Quest-added items stay.
	LootItems removed;
	if (empties) {
		removed = RemoveCorpseLootTableItems(corpse);
		LogInfo(
			"NmsLootOffers: removed [{}] loot-table item(s) from corpse [{}] for [{}] recipient(s)",
			removed.size(),
			corpse->GetID(),
			recipients.size()
		);
	}

	for (auto *c : recipients) {
		if (empties) {
			CreateOffersFromItems(c, corpse, removed);
		}
		else {
			LootItems rolled;
			source->RollIndependentLoot(rolled);
			ApplyLootBuffToRolled(source, c, rolled);
			CreateOffersFromItems(c, corpse, rolled);
			FreeLootItems(rolled);
		}
	}
	FreeLootItems(removed);

	// The loot window has no coin: split the corpse's money among the group/raid in this zone (the
	// remainder goes to the credited player) so nobody has to open the corpse for it
	const uint64 coin = static_cast<uint64>(corpse->GetCopper()) + corpse->GetSilver() * 10ull +
		corpse->GetGold() * 100ull + corpse->GetPlatinum() * 1000ull;
	if (coin && !recipients.empty()) {
		const uint64 share = coin / recipients.size();
		const uint64 extra = coin % recipients.size();
		for (auto *c : recipients) {
			const uint64 amount = share + (c == credit ? extra : 0);
			if (!amount) {
				continue;
			}
			c->AddMoneyToPP(amount, true);
			c->Message(
				Chat::Yellow,
				fmt::format(
					"[NMS] You receive {}p {}g {}s {}c as your share of the coin.",
					amount / 1000, (amount / 100) % 10, (amount / 10) % 10, amount % 10
				).c_str()
			);
		}
		corpse->RemoveCash();
	}
}

void NmsLootOfferRestoreOnZoneIn(Client *c)
{
	if (!c || !NmsLootOffersEnabled() || !EnsureTables() || !zone) {
		return;
	}

	ExpireOffers(c);
	auto offers = LoadOffers(c->CharacterID(), zone->GetZoneID(), 0, 0);
	uint32 active = 0;
	for (const auto &offer : offers) {
		if (!offer.passed) {
			++active;
		}
	}
	if (!active) {
		return;
	}

	// One packet: the add-on replaces its Pending list with each one it gets
	SendOffers(c, offers, offers.front().corpse_id);
	c->Message(
		Chat::White,
		"[NMS] %u unclaimed loot items recovered from your last visit to this zone.",
		active
	);
}

void NmsLootOfferSweepExpired()
{
	// Zone boot insurance: rows whose owner never came back have nobody to deliver to, so
	// reclaim them. In-zone expiry delivers instead (ExpireOffers), so this only ever deletes
	// offers that expired while the character was offline or in another zone.
	if (!NmsLootOffersEnabled() || !EnsureTables()) {
		return;
	}
	database.QueryDatabase("DELETE FROM character_nms_loot_offers WHERE expires_at < NOW()");
}

// Takes the offer off the list and carries out the action; an offer the action could not finish is saved again.
// False when it was not carried out.
static bool DecideOffer(Client *c, NmsLootOffer match, NmsLootAction action, const std::string &pass_to)
{
	if (!DeleteOffer(c->CharacterID(), match.id)) {
		c->Message(Chat::White, "[NMS] That loot offer has expired.");
		return false;
	}

	if (NmsLootOfferApply(c, match, action, pass_to)) {
		return true;
	}
	if (match.expire_remaining <= 0) {
		return false;
	}
	match.id = 0;
	match.passed = false;
	if (SaveOffer(match, match.expire_remaining)) {
		std::vector<NmsLootOffer> one{match};
		SendOffers(c, one, match.corpse_id);
	}
	return false;
}

void NmsLootOfferHandleDecision(Client *c, const EQApplicationPacket *app)
{
	if (!c || !app || !NmsLootOffersEnabled() || !EnsureTables() || !zone) {
		return;
	}
	if (app->size != sizeof(NmsLootDecision_Struct)) {
		LogError(
			"Received OP_NmsLootDecision packet. Expected size {}, received size {}.",
			sizeof(NmsLootDecision_Struct),
			app->size
		);
		return;
	}

	const auto *in = reinterpret_cast<const NmsLootDecision_Struct *>(app->pBuffer);
	if (in->action == static_cast<uint32>(NmsLootAction::Refresh)) {
		// /nmsloot: resend this character's pending offers; no offer id and no decision.
		ExpireOffers(c);
		auto offers = LoadOffers(c->CharacterID(), zone->GetZoneID(), 0, 0);
		if (!offers.empty()) {
			SendOffers(c, offers, offers.front().corpse_id);
		}
		return;
	}
	if (!in->offer_id) {
		c->Message(Chat::White, "[NMS] That loot offer has expired.");
		return;
	}

	char pass_to[64] = {0};
	strn0cpy(pass_to, in->name, sizeof(pass_to));

	ExpireOffers(c);

	NmsLootOffer match;
	if (!LoadOfferById(c->CharacterID(), in->offer_id, match)) {
		c->Message(Chat::White, "[NMS] That loot offer has expired.");
		return;
	}
	if (in->item_id && in->item_id != match.item_id) {
		c->Message(Chat::White, "[NMS] That loot offer has expired.");
		return;
	}

	auto action = static_cast<NmsLootAction>(in->action);
	if (action == NmsLootAction::ReturnToPasser) {
		action = NmsLootAction::Pass;
	}
	if (action < NmsLootAction::Keep || action > NmsLootAction::Pass) {
		c->Message(Chat::Red, "[NMS] Unknown loot action.");
		return;
	}
	if (action == NmsLootAction::Pass && pass_to[0] == '\0') {
		c->Message(Chat::Red, "[NMS] Choose a player to pass that item to.");
		return;
	}

	DecideOffer(c, match, action, pass_to);
}

void NmsLootOfferHandlePersonalLootAction(Client *c, const EQApplicationPacket *app)
{
	if (!c || !app) {
		return;
	}
	if (app->size < sizeof(PersonalLootAction_Struct)) {
		LogError(
			"Received OP_PersonalLootAction packet. Expected size {}, received size {}.",
			sizeof(PersonalLootAction_Struct),
			app->size
		);
		return;
	}

	const auto *in = reinterpret_cast<const PersonalLootAction_Struct *>(app->pBuffer);
	const bool enabled = NmsLootOffersEnabled() && EnsureTables() && zone;
	switch (in->action) {
	case kPersonalLootHello:
		// Once per zone, a few seconds in: from now on this client gets OP_PersonalLootList, not OP_NmsLootOffer
		c->SetNmsPersonalLootWindow(true);
		SendPersonalLootSettings(c);
		SendPersonalLootHistory(c);
		if (enabled) {
			ExpireOffers(c);
			SendPersonalLootList(c, 0);
		}
		return;
	case kPersonalLootGetSettings:
		SendPersonalLootSettings(c);
		return;
	case kPersonalLootHistory:
		SendPersonalLootHistory(c);
		return;
	case kPersonalLootSetDefer:
	case kPersonalLootSetReport:
	case kPersonalLootSetSellUnder:
		// The add-on's per-character prefs would live client-side on the original NMS server; this
		// server has none, so the settings are answered unchanged. Documented limitation.
		c->Message(Chat::White, "[NMS] This server has no loot settings to change.");
		SendPersonalLootSettings(c);
		return;
	default:
		break;
	}
	if (!enabled) {
		return;
	}

	c->SetNmsPersonalLootWindow(true);
	ExpireOffers(c);
	switch (in->action) {
	case kPersonalLootRefresh:
		break;
	case kPersonalLootInspect:
	case kPersonalLootInspectItem: {
		EQ::ItemInstance *inst = nullptr;
		NmsLootOffer offer;
		if (in->action == kPersonalLootInspect) {
			if (LoadOfferById(c->CharacterID(), in->pending_id, offer)) {
				inst = MakeLootItem(offer);
			}
		}
		else if (in->item_id) {
			inst = database.CreateItem(in->item_id);
		}
		if (inst) {
			c->SendItemPacket(0, inst, ItemPacketViewLink);
			safe_delete(inst);
		}
		return;
	}
	case kPersonalLootKeep:
	case kPersonalLootSell: {
		NmsLootOffer offer;
		if (!LoadOfferById(c->CharacterID(), in->pending_id, offer)) {
			c->Message(Chat::White, "[NMS] That loot offer has expired.");
			break;
		}
		NmsLootAction action = NmsLootAction::Keep;
		if (in->action == kPersonalLootSell) {
			// The window labels an offer worth nothing "Destroy"
			action = OfferSellCopper(offer) ? NmsLootAction::Sell : NmsLootAction::Destroy;
		}
		DecideOffer(c, offer, action, "");
		break;
	}
	case kPersonalLootLootAll:
	case kPersonalLootSellAll: {
		uint32 left = 0;
		for (auto &offer : LoadOffers(c->CharacterID(), zone->GetZoneID(), 0, 0)) {
			if (offer.passed) {
				continue;
			}
			if (in->action == kPersonalLootSellAll && !OfferSellCopper(offer)) {
				// Sell All never destroys: an offer worth nothing stays for the player to decide
				++left;
				continue;
			}
			const bool keep = in->action == kPersonalLootLootAll;
			if (!DecideOffer(c, offer, keep ? NmsLootAction::Keep : NmsLootAction::Sell, "") && keep) {
				break; // full bags: the rest would fail the same way
			}
		}
		if (left) {
			c->Message(Chat::White, "[NMS] %u items with no sell value were left for you to keep or destroy.", left);
		}
		break;
	}
	default:
		return;
	}

	SendPersonalLootList(c, 0);
}

bool NmsLootOfferApply(Client *c, const NmsLootOffer &offer, NmsLootAction action, const std::string &pass_to)
{
	if (!c) {
		return false;
	}

	if (!OfferStillClaimable(c, offer)) {
		c->Message(Chat::White, "[NMS] That loot offer is no longer available.");
		return false;
	}

	const auto *item = database.GetItem(offer.item_id);
	const std::string item_name = offer.name.empty() && item ? item->Name : offer.name;
	const int16 qty = offer.charges > 0 ? offer.charges : 1;

	switch (action) {
	case NmsLootAction::Keep: {
		if (item && c->CheckLoreConflict(item)) {
			c->Message(Chat::White, "[NMS] Cannot loot %s - you already have one of this LORE item.", item_name.c_str());
			return false;
		}
		auto *inst = MakeLootItem(offer);
		if (!inst) {
			c->Message(Chat::Red, "[NMS] Could not create %s.", item_name.c_str());
			return false;
		}
		const int16 before = inst->GetCharges();
		const bool cursor_ok = c->GetInv().CursorSize() < EQ::invbag::CURSOR_BAG_COUNT;
		if (!c->AutoPutLootInInventory(*inst, false, cursor_ok)) {
			const int16 left = inst->GetCharges();
			if (left < before) {
				if (left > 0) {
					NmsLootOffer leftover = offer;
					leftover.id = 0;
					leftover.charges = left;
					if (SaveOffer(leftover, RemainingExpireSeconds(offer))) {
						std::vector<NmsLootOffer> one{leftover};
						SendOffers(c, one, leftover.corpse_id);
					}
				}
				DiscoverOfferItem(c, offer.item_id);
				c->Message(Chat::White, "[NMS] %s added to inventory.", item_name.c_str());
				safe_delete(inst);
				return true;
			}
			c->Message(Chat::Red, "[NMS] Your inventory is full.");
			safe_delete(inst);
			return false;
		}
		DiscoverOfferItem(c, offer.item_id);
		c->Message(Chat::White, "[NMS] %s added to inventory.", item_name.c_str());
		safe_delete(inst);
		return true;
	}
	case NmsLootAction::Sell: {
		if (!item || item->Price == 0 || item->NoDrop == 0 || item->SummonedFlag || OfferHasAugments(offer)) {
			c->Message(Chat::White, "[NMS] %s has no sell value - please pick another option.", item_name.c_str());
			return false;
		}
		const uint64 copper = static_cast<uint64>(item->Price) * static_cast<uint64>(qty);
		if (!CanAddSellCopper(c, copper)) {
			c->Message(Chat::Red, "[NMS] You cannot carry that much coin.");
			return false;
		}
		c->AddMoneyToPP(copper, true);
		c->Message(
			Chat::White,
			"[NMS] %s sold for %s.",
			item_name.c_str(),
			Strings::Money(copper / 1000, (copper / 100) % 10, (copper / 10) % 10, copper % 10).c_str()
		);
		return true;
	}
	case NmsLootAction::Tribute: {
		if (!item || item->Favor == 0 || item->NoDrop == 0 || OfferHasAugments(offer)) {
			c->Message(Chat::White, "[NMS Tribute] %s has no tribute value - please pick another option.", item_name.c_str());
			return false;
		}
		const int64 favor64 = static_cast<int64>(item->Favor) * static_cast<int64>(qty);
		if (favor64 <= 0 || favor64 > INT32_MAX) {
			c->Message(Chat::White, "[NMS Tribute] %s has no tribute value - please pick another option.", item_name.c_str());
			return false;
		}
		const int32 favor = static_cast<int32>(favor64);
		c->AddTributePoints(favor);
		c->Message(Chat::White, "[NMS] %s tributed for %d favor points.", item_name.c_str(), favor);
		return true;
	}
	case NmsLootAction::Bank: {
		if (!NmsVaultEnabled() || !NmsVaultTablesReady()) {
			c->Message(Chat::Red, "[NMS] Vault banking is not available.");
			return false;
		}
		auto *inst = MakeLootItem(offer);
		if (!inst) {
			return false;
		}
		if (!PutInBank(c, inst)) {
			c->Message(Chat::Red, "[NMS] Your bank is full.");
			safe_delete(inst);
			return false;
		}
		DiscoverOfferItem(c, offer.item_id);
		c->Message(Chat::White, "[NMS] %s added to your bank.", item_name.c_str());
		safe_delete(inst);
		return true;
	}
	case NmsLootAction::Vault: {
		auto *inst = MakeLootItem(offer);
		if (!inst) {
			return false;
		}
		if (NmsVaultIsArmoryItem(inst->GetID())) {
			c->Message(Chat::Red, "[NMS] The Armarium cannot be stored here.");
			safe_delete(inst);
			return false;
		}
		const int vault_slot = NmsVaultTryDepositInstance(c, inst);
		if (!vault_slot) {
			c->Message(Chat::Red, "[NMS] Your vault is full.");
			safe_delete(inst);
			return false;
		}
		DiscoverOfferItem(c, offer.item_id);
		c->Message(Chat::White, "[NMS] %s added to your vault.", item_name.c_str());
		safe_delete(inst);
		return true;
	}
	case NmsLootAction::Destroy:
		c->Message(Chat::White, "[NMS] Item destroyed.");
		return true;
	case NmsLootAction::Pass: {
		if (pass_to.empty()) {
			c->Message(Chat::Red, "[NMS] Choose a player to pass that item to.");
			return false;
		}
		if (!item || item->NoDrop == 0) {
			c->Message(Chat::Red, "[NMS] That item cannot be passed.");
			return false;
		}

		auto *other = entity_list.GetClientByName(pass_to.c_str());
		if (!other || other == c) {
			c->Message(Chat::Red, "[NMS] That player is not a valid pass target.");
			return false;
		}
		if (!EligiblePassTarget(c, other, nullptr)) {
			c->Message(Chat::Red, "[NMS] That player is not a valid pass target.");
			return false;
		}
		if (other->CheckLoreConflict(item)) {
			c->Message(Chat::Red, "[NMS] That player cannot receive this LORE item.");
			return false;
		}

		const int dest_expire = RemainingExpireSeconds(offer);
		NmsLootOffer tomb = offer;
		tomb.id = 0;
		tomb.character_id = c->CharacterID();
		tomb.passed = true;
		if (zone) {
			tomb.zone_id = zone->GetZoneID();
			tomb.instance_id = zone->GetInstanceID();
		}
		if (!SaveOffer(tomb, dest_expire)) {
			c->Message(Chat::Red, "[NMS] Could not pass %s.", item_name.c_str());
			return false;
		}

		NmsLootOffer dest = offer;
		dest.id = 0;
		dest.character_id = other->CharacterID();
		dest.passed = false;
		dest.passed_from = c->GetName();
		if (zone) {
			dest.zone_id = zone->GetZoneID();
			dest.instance_id = zone->GetInstanceID();
		}
		if (!SaveOffer(dest, dest_expire)) {
			DeleteOffer(c->CharacterID(), tomb.id);
			c->Message(Chat::Red, "[NMS] Could not pass %s.", item_name.c_str());
			return false;
		}

		std::vector<NmsLootOffer> one{dest};
		SendOffers(other, one, dest.corpse_id);
		other->Message(Chat::White, "[NMS] %s passed %s to you.", c->GetName(), item_name.c_str());
		return true;
	}
	default:
		c->Message(Chat::Red, "[NMS] Unknown loot action.");
		return false;
	}
}
