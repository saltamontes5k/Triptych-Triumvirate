/*	EQEmu: EQEmulator

	Copyright (C) 2001-2026 EQEmu Development Team

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
#include "bazaar.h"

#include "item_instance.h"
#include "repositories/trader_repository.h"

#include "strings.h"
#include <limits>
#include <memory>

Bazaar::PurchaseQuantityValidation Bazaar::ValidatePurchaseQuantity(
	uint32 requested_quantity,
	bool is_stackable,
	int16 listed_charges
)
{
	const uint32 max_signed_quantity = static_cast<uint32>(std::numeric_limits<int32>::max());
	if (requested_quantity == 0 || requested_quantity > max_signed_quantity) {
		return {false, 0};
	}

	uint32 quantity = requested_quantity;
	if (!is_stackable) {
		if (quantity != 1) {
			return {false, 0};
		}

		return {true, quantity};
	}

	if (listed_charges <= 0) {
		return {false, 0};
	}

	const uint32 available_quantity = static_cast<uint32>(listed_charges);
	if (quantity > available_quantity) {
		quantity = available_quantity;
	}

	return {true, quantity};
}

int16 Bazaar::ResolvePurchaseItemCharges(
	uint32 purchase_quantity,
	bool is_stackable,
	int16 max_charges,
	int16 listed_charges
)
{
	// ItemInstance charges represent stack quantity for stackable items, even
	// when each item also has a click charge. Only non-stackable charged items
	// should retain the seller's remaining charges.
	if (!is_stackable && max_charges > 0) {
		return listed_charges;
	}

	return static_cast<int16>(purchase_quantity);
}

std::vector<std::unique_ptr<EQ::ItemInstance>> Bazaar::CreateBarterPurchaseItems(
	SharedDatabase &db,
	const EQ::ItemData *item,
	uint32 quantity
)
{
	std::vector<std::unique_ptr<EQ::ItemInstance>> items;
	if (!item || item->MaxCharges > 0 || quantity == 0 || (item->LoreFlag && quantity > 1)) {
		return items;
	}

	items.reserve(quantity);
	for (uint32 i = 0; i < quantity; ++i) {
		auto inst = std::unique_ptr<EQ::ItemInstance>(db.CreateItem(item, 1));
		if (!inst) {
			items.clear();
			return items;
		}

		items.emplace_back(std::move(inst));
	}

	return items;
}

bool Bazaar::ValidateBarterSellQuantity(uint32 requested_quantity, uint32 listed_quantity)
{
	return requested_quantity > 0 && requested_quantity <= listed_quantity;
}

Bazaar::TransactionValueValidation Bazaar::ValidateBuyLinePrice(
	uint32 unit_price,
	uint64 max_transaction_value
)
{
	return ValidateTransactionValue(unit_price, 1, max_transaction_value);
}

Bazaar::TransactionValueValidation Bazaar::ValidateTransactionValue(
	uint32 unit_price,
	uint32 quantity,
	uint64 max_transaction_value
)
{
	const uint64 total_cost = static_cast<uint64>(unit_price) * static_cast<uint64>(quantity);
	if (quantity == 0 || total_cost > max_transaction_value) {
		return {false, 0};
	}

	return {true, total_cost};
}

bool Bazaar::ValidatePurchasePrice(uint32 requested_price, uint32 listed_price)
{
	return listed_price > 0 && requested_price == listed_price;
}

void Bazaar::RecordAuditTrail(
	Database &db,
	const std::string &seller,
	const std::string &buyer,
	uint32 item_id,
	const std::string &item_name,
	uint32 quantity,
	uint64 total_cost,
	int transaction_type
)
{
	auto query = fmt::format(
		"INSERT INTO `trader_audit` "
		"(`time`, `seller`, `buyer`, `item_id`, `itemname`, `quantity`, `totalcost`, `trantype`) "
		"VALUES (NOW(), '{}', '{}', {}, '{}', {}, {}, {})",
		Strings::Escape(seller),
		Strings::Escape(buyer),
		item_id,
		Strings::Escape(item_name),
		quantity,
		total_cost,
		transaction_type
	);

	auto results = db.QueryDatabase(query);
	if (!results.Success()) {
		LogTrading("Audit write error: {} : {}", query, results.ErrorMessage());
	}
}

uint32 Bazaar::ResolvePurchaseFailureSubAction(uint32 sub_action)
{
	return sub_action == Success ? Failed : sub_action;
}

std::vector<BazaarSearchResultsFromDB_Struct>
Bazaar::GetSearchResults(
	Database &db,
	Database &content_db,
	BazaarSearchCriteria_Struct search,
	uint32 char_zone_id,
	int32 char_zone_instance_id
)
{
	(void) content_db;

	LogTrading(
		"Searching for items with search criteria - item_name [{}] min_cost [{}] max_cost [{}] min_level [{}] "
		"max_level [{}] max_results [{}] prestige [{}] augment [{}] trader_entity_id [{}] trader_id [{}] "
		"search_scope [{}] char_zone_id [{}], char_zone_instance_id [{}]",
		search.item_name,
		search.min_cost,
		search.max_cost,
		search.min_level,
		search.max_level,
		search.max_results,
		search.prestige,
		search.augment,
		search.trader_entity_id,
		search.trader_id,
		search.search_scope,
		char_zone_id,
		char_zone_instance_id
	);

	static std::map<uint8, uint32> item_slot_searches_new = {
		{EQ::invslot::slotCharm,       1},
		{EQ::invslot::slotEar1,        2},
		{EQ::invslot::slotHead,        4},
		{EQ::invslot::slotFace,        8},
		{EQ::invslot::slotEar2,        16},
		{EQ::invslot::slotNeck,        32},
		{EQ::invslot::slotShoulders,   64},
		{EQ::invslot::slotArms,        128},
		{EQ::invslot::slotBack,        256},
		{EQ::invslot::slotWrist1,      512},
		{EQ::invslot::slotWrist2,      1024},
		{EQ::invslot::slotRange,       2048},
		{EQ::invslot::slotHands,       4096},
		{EQ::invslot::slotPrimary,     8192},
		{EQ::invslot::slotSecondary,   16384},
		{EQ::invslot::slotFinger1,     32768},
		{EQ::invslot::slotFinger2,     65536},
		{EQ::invslot::slotChest,       131072},
		{EQ::invslot::slotLegs,        262144},
		{EQ::invslot::slotFeet,        524288},
		{EQ::invslot::slotWaist,       1048576},
		{EQ::invslot::slotPowerSource, 2097152},
		{EQ::invslot::slotAmmo,        4194304},
	};

	struct ItemSearchType {
		EQ::item::ItemType type;
		std::string        condition;
	};

	std::vector<ItemSearchType> item_search_types_new = {
		{EQ::item::ItemType::ItemTypeBook,                 " AND (items.itemclass = 2 or items.itemclass = 31)"},
		{EQ::item::ItemType::ItemTypeContainer,            " AND (items.itemclass = 1 or items.itemclass = 67)"},
		{EQ::item::ItemType::ItemTypeAllEffects,           " AND (items.scrolleffect > 0 && items.scrolleffect < 65000)"},
		{EQ::item::ItemType::ItemTypeUnknown9,             " AND items.worneffect = 998"},
		{EQ::item::ItemType::ItemTypeUnknown10,            " AND (items.worneffect >= 1298 && items.worneffect <= 1307)"},
		{EQ::item::ItemType::ItemTypeFocusEffect,          " AND items.focuseffect > 0"},
		{EQ::item::ItemType::ItemTypeArmor,                " AND items.itemtype = 10"},
		{EQ::item::ItemType::ItemType1HBlunt,              " AND items.itemtype = 3"},
		{EQ::item::ItemType::ItemType1HPiercing,           " AND items.itemtype = 2"},
		{EQ::item::ItemType::ItemType1HSlash,              " AND items.itemtype = 0"},
		{EQ::item::ItemType::ItemType2HBlunt,              " AND items.itemtype = 4"},
		{EQ::item::ItemType::ItemType2HSlash,              " AND items.itemtype = 1"},
		{EQ::item::ItemType::ItemTypeBow,                  " AND items.itemtype = 5"},
		{EQ::item::ItemType::ItemTypeShield,               " AND items.itemtype = 8"},
		{EQ::item::ItemType::ItemTypeMisc,                 " AND items.itemtype = 11"},
		{EQ::item::ItemType::ItemTypeFood,                 " AND items.itemtype = 14"},
		{EQ::item::ItemType::ItemTypeDrink,                " AND items.itemtype = 15"},
		{EQ::item::ItemType::ItemTypeLight,                " AND items.itemtype = 16"},
		{EQ::item::ItemType::ItemTypeCombinable,           " AND items.itemtype = 17"},
		{EQ::item::ItemType::ItemTypeBandage,              " AND items.itemtype = 18"},
		{EQ::item::ItemType::ItemTypeSmallThrowing,        " AND (items.itemtype = 19 OR items.itemtype = 7)"},
		{EQ::item::ItemType::ItemTypeSpell,                " AND items.itemtype = 20"},
		{EQ::item::ItemType::ItemTypePotion,               " AND items.itemtype = 21"},
		{EQ::item::ItemType::ItemTypeBrassInstrument,      " AND items.itemtype = 25"},
		{EQ::item::ItemType::ItemTypeWindInstrument,       " AND items.itemtype = 23"},
		{EQ::item::ItemType::ItemTypeStringedInstrument,   " AND items.itemtype = 24"},
		{EQ::item::ItemType::ItemTypePercussionInstrument, " AND items.itemtype = 26"},
		{EQ::item::ItemType::ItemTypeArrow,                " AND items.itemtype = 27"},
		{EQ::item::ItemType::ItemTypeJewelry,              " AND items.itemtype = 29"},
		{EQ::item::ItemType::ItemTypeNote,                 " AND items.itemtype = 32"},
		{EQ::item::ItemType::ItemTypeKey,                  " AND items.itemtype = 33"},
		{EQ::item::ItemType::ItemType2HPiercing,           " AND items.itemtype = 35"},
		{EQ::item::ItemType::ItemTypeAlcohol,              " AND items.itemtype = 38"},
		{EQ::item::ItemType::ItemTypeMartial,              " AND items.itemtype = 45"},
		{EQ::item::ItemType::ItemTypeAugmentation,         " AND items.itemtype = 54"},
		{EQ::item::ItemType::ItemTypeAlternateAbility,     " AND items.itemtype = 57"},
		{EQ::item::ItemType::ItemTypeCount,                " AND items.itemtype = 65"},
		{EQ::item::ItemType::ItemTypeCollectible,          " AND items.itemtype = 66"}
	};

	// item stat searches
	struct ItemStatSearch {
		std::string           query_string;
		EQ::skills::SkillType skill_type;
	};

	std::map<uint32, ItemStatSearch> item_stat_searches_new = {
		{STAT_AC,                  {" items.ac" ,          static_cast<EQ::skills::SkillType>(0)} },
		{STAT_AGI,                 {" items.aagi",         static_cast<EQ::skills::SkillType>(0)} },
		{STAT_CHA,                 {" items.acha",         static_cast<EQ::skills::SkillType>(0)} },
		{STAT_DEX,                 {" items.adex",         static_cast<EQ::skills::SkillType>(0)} },
		{STAT_INT,                 {" items.aint",         static_cast<EQ::skills::SkillType>(0)} },
		{STAT_STA,                 {" items.asta",         static_cast<EQ::skills::SkillType>(0)} },
		{STAT_STR,                 {" items.astr",         static_cast<EQ::skills::SkillType>(0)} },
		{STAT_WIS,                 {" items.awis",         static_cast<EQ::skills::SkillType>(0)} },
		{STAT_COLD,                {" items.cr",           static_cast<EQ::skills::SkillType>(0)} },
		{STAT_DISEASE,             {" items.dr",           static_cast<EQ::skills::SkillType>(0)} },
		{STAT_FIRE,                {" items.fr",           static_cast<EQ::skills::SkillType>(0)} },
		{STAT_MAGIC,               {" items.mr",           static_cast<EQ::skills::SkillType>(0)} },
		{STAT_POISON,              {" items.pr",           static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HP,                  {" items.hp",           static_cast<EQ::skills::SkillType>(0)} },
		{STAT_MANA,                {" items.mana",         static_cast<EQ::skills::SkillType>(0)} },
		{STAT_ENDURANCE,           {" items.endur",        static_cast<EQ::skills::SkillType>(0)} },
		{STAT_ATTACK,              {" items.attack",       static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HP_REGEN,            {" items.regen",        static_cast<EQ::skills::SkillType>(0)} },
		{STAT_MANA_REGEN,          {" items.manaregen",    static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HASTE,               {" items.haste",        static_cast<EQ::skills::SkillType>(0)} },
		{STAT_DAMAGE_SHIELD,       {" items.damageshield", static_cast<EQ::skills::SkillType>(0)} },
		{STAT_DS_MITIGATION,       {" items.dsmitigation", static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HEAL_AMOUNT,         {" items.healamt",      static_cast<EQ::skills::SkillType>(0)} },
		{STAT_SPELL_DAMAGE,        {" items.spelldmg",     static_cast<EQ::skills::SkillType>(0)} },
		{STAT_CLAIRVOYANCE,        {" items.clairvoyance", static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HEROIC_AGILITY,      {" items.heroic_agi",   static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HEROIC_CHARISMA,     {" items.heroic_cha",   static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HEROIC_DEXTERITY,    {" items.heroic_dex",   static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HEROIC_INTELLIGENCE, {" items.heroic_int",   static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HEROIC_STAMINA,      {" items.heroic_sta",   static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HEROIC_STRENGTH,     {" items.heroic_str",   static_cast<EQ::skills::SkillType>(0)} },
		{STAT_HEROIC_WISDOM,       {" items.heroic_wis",   static_cast<EQ::skills::SkillType>(0)} },
		{STAT_BASH,                {" items.skillmodvalue", EQ::skills::SkillBash}                },
		{STAT_BACKSTAB,            {" items.backstabdmg",   EQ::skills::SkillBackstab}            },
		{STAT_DRAGON_PUNCH,        {" items.skillmodvalue", EQ::skills::SkillDragonPunch}         },
		{STAT_EAGLE_STRIKE,        {" items.skillmodvalue", EQ::skills::SkillEagleStrike}         },
		{STAT_FLYING_KICK,         {" items.skillmodvalue", EQ::skills::SkillFlyingKick}          },
		{STAT_KICK,                {" items.skillmodvalue", EQ::skills::SkillKick}                },
		{STAT_ROUND_KICK,          {" items.skillmodvalue", EQ::skills::SkillRoundKick}           },
		{STAT_TIGER_CLAW,          {" items.skillmodvalue", EQ::skills::SkillTigerClaw}           },
		{STAT_FRENZY,              {" items.skillmodvalue", EQ::skills::SkillFrenzy}              },
	};

	bool        convert = false;
	std::string search_criteria_trader("TRUE");
	std::string field_criteria_items("FALSE");
	std::string where_criteria_items(" TRUE ");

	if (search.search_scope == NonRoFBazaarSearchScope) {
		search_criteria_trader.append(
			fmt::format(
				" AND trader.char_entity_id = {} AND trader.char_zone_id = {} AND trader.char_zone_instance_id = {}",
				search.trader_entity_id,
				Zones::BAZAAR,
				char_zone_instance_id
			)
		);
	}
	else if (search.search_scope == Local_Scope) {
		search_criteria_trader.append(fmt::format(
			" AND trader.char_zone_id = {} AND trader.char_zone_instance_id = {}",
			char_zone_id,
			char_zone_instance_id)
		);
	}
	else if (search.trader_id > 0) {
		if (RuleB(Bazaar, UseAlternateBazaarSearch)) {
			if (search.trader_id >= TraderRepository::TRADER_CONVERT_ID) {
				convert = true;
				search_criteria_trader.append(fmt::format(
					" AND trader.char_zone_id = {} AND trader.char_zone_instance_id = {}",
					Zones::BAZAAR,
					search.trader_id - TraderRepository::TRADER_CONVERT_ID)
				);
			}
			else {
				search_criteria_trader.append(fmt::format(" AND trader.character_id = {}", search.trader_id));
			}
		}
		else {
			search_criteria_trader.append(fmt::format(" AND trader.character_id = {}", search.trader_id));
		}
	}

	if (search.min_cost != 0) {
		search_criteria_trader.append(fmt::format(" AND trader.item_cost >= {}", search.min_cost * 1000));
	}
	if (search.max_cost != 0) {
		search_criteria_trader.append(fmt::format(" AND trader.item_cost <= {}", (uint64) search.max_cost * 1000));
	}

	if (search.slot != std::numeric_limits<uint32>::max()) {
		if (item_slot_searches_new.contains(search.slot)) {
			where_criteria_items.append(
				fmt::format(" AND items.slots & {0} = {0}", item_slot_searches_new[search.slot]));
		}
	}

	if (search.type != std::numeric_limits<uint32>::max()) {
		for (auto const &[type, condition]: item_search_types_new) {
			if (type == search.type) {
				where_criteria_items.append(condition);
				break;
			}
		}
	}

	if (search.race != std::numeric_limits<uint32>::max()) {
		where_criteria_items.append(
			fmt::format(" AND items.races & {0} = {0}", GetPlayerRaceBit(GetRaceIDFromPlayerRaceValue(search.race))));
	}

	if (search._class != std::numeric_limits<uint32>::max()) {
		where_criteria_items.append(fmt::format(" AND items.classes & {0} = {0}", GetPlayerClassBit(search._class)));
	}

	if (search.item_stat != std::numeric_limits<uint32>::max()) {
		if (item_stat_searches_new.contains(search.item_stat)) {
			field_criteria_items = fmt::format("{}", item_stat_searches_new[search.item_stat].query_string);
			if (item_stat_searches_new[search.item_stat].skill_type) {
				where_criteria_items.append(
					fmt::format(" AND items.skillmodtype = {} ", item_stat_searches_new[search.item_stat].skill_type));
			}
			else {
				where_criteria_items.append(
					fmt::format(" AND {} > 0 ", item_stat_searches_new[search.item_stat].query_string));
			}
		}
	}

	if (search.augment) {
		where_criteria_items.append(fmt::format(
			" AND (items.augslot1type = {0} OR "
			"items.augslot2type = {0} OR "
			"items.augslot3type = {0} OR "
			"items.augslot4type = {0} OR "
			"items.augslot5type = {0} OR "
			"items.augslot6type = {0})",
			search.augment)
		);
	}

	if (search.min_level != 1) {
		where_criteria_items.append(fmt::format(" AND items.reclevel >= {}", search.min_level));
	}

	if (search.max_level != 100) {
		where_criteria_items.append(fmt::format(" AND items.reclevel <= {}", search.max_level));
	}

	std::vector<BazaarSearchResultsFromDB_Struct> all_entries;

	auto const trader_results = TraderRepository::GetBazaarTraderDetails(
		db,
		search_criteria_trader,
		search.item_name,
		field_criteria_items,
		where_criteria_items,
		search.max_results
	);

	if (trader_results.empty()) {
		LogTradingDetail("Bazaar - No traders found in bazaar search.");
		return all_entries;
	}

	all_entries.reserve(trader_results.size());

	for (auto const &t: trader_results) {
		BazaarSearchResultsFromDB_Struct r{};
		r.count                   = 1;
		r.trader_id               = t.trader.character_id;
		r.item_unique_id          = t.trader.item_unique_id;
		r.cost                    = t.trader.item_cost;
		r.slot_id                 = t.trader.slot_id;
		r.charges                 = t.trader.item_charges;
		r.stackable               = t.stackable;
		r.icon_id                 = t.icon;
		r.trader_zone_id          = t.trader.char_zone_id;
		r.trader_zone_instance_id = t.trader.char_zone_instance_id;
		r.trader_entity_id        = t.trader.char_entity_id;
		r.item_name               = fmt::format("{:.63}\0", t.name);
		r.trader_name             = fmt::format("{:.63}\0", t.trader_name);
		r.item_stat               = t.stats;

		if (RuleB(Bazaar, UseAlternateBazaarSearch)) {
			if (convert ||
				char_zone_id != Zones::BAZAAR ||
				(char_zone_id == Zones::BAZAAR && r.trader_zone_instance_id != char_zone_instance_id)
				) {
				r.trader_id = TraderRepository::TRADER_CONVERT_ID + r.trader_zone_instance_id;
			}
		}

		all_entries.push_back(r);
	}

	LogTrading("Returning [{}] items from search results", all_entries.size());

	return all_entries;
}
