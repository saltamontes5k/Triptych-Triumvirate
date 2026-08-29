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
#pragma once

#include "base/base_trader_repository.h"

#include "../../common/item_data.h"
#include "../../common/races.h"
#include "items_repository.h"
#include "../../common/shareddb.h"
#include "../../common/strings.h"

#include "../cereal/include/cereal/archives/binary.hpp"
#include "../cereal/include/cereal/types/string.hpp"

class TraderRepository : public BaseTraderRepository {
public:
	static constexpr uint32 TRADER_CONVERT_ID = 4000000000;
	static constexpr uint8 ACTIVE_TRANSACTION_NONE = 0;
	static constexpr uint8 ACTIVE_TRANSACTION_PENDING = 1;
	static constexpr uint8 ACTIVE_TRANSACTION_PROCESSING = 2;

	struct DistinctTraders_Struct {
		uint32      trader_id;
		uint32      zone_id;
		uint32      zone_instance_id;
		uint32      entity_id;
		std::string trader_name;
	};

	struct BulkTraders_Struct {
		uint32                              count{0};
		uint32                              name_length{0};
		std::vector<DistinctTraders_Struct> traders{};
	};

	struct BazaarTraderSearch_Struct {
		Trader      trader;
		std::string trader_name;
		std::string name;
		bool        stackable;
		uint32      icon;
		uint32      stats;
	};

	struct WelcomeData_Struct {
		uint32 count_of_traders;
		uint32 count_of_items;
	};

	static std::vector<BazaarSearchResultsFromDB_Struct>
	GetBazaarSearchResults(
		SharedDatabase &db,
		BazaarSearchCriteria_Struct search,
		uint32 char_zone_id,
		int32 char_zone_instance_id
	);

	static BulkTraders_Struct GetDistinctTraders(
		Database &db,
		uint32 char_zone_instance_id,
		uint32 max_results = std::numeric_limits<uint32>::max()
		)
	{
		BulkTraders_Struct                  all_entries{};
		std::vector<DistinctTraders_Struct> distinct_traders;
		MySQLRequestResult                  results;

		if (RuleB(Bazaar, UseAlternateBazaarSearch)) {
			results = db.QueryDatabase(fmt::format(
				"SELECT DISTINCT(t.character_id), t.char_zone_id, t.char_zone_instance_id, t.char_entity_id, c.name "
				"FROM trader AS t "
				"JOIN character_data AS c ON t.character_id = c.id "
				"WHERE t.char_zone_instance_id = {} "
				"ORDER BY t.char_zone_instance_id ASC "
				"LIMIT {}",
				char_zone_instance_id,
				max_results)
			);
		}
		else {
			results = db.QueryDatabase(
				fmt::format(
					"SELECT DISTINCT(t.character_id), t.char_zone_id, t.char_zone_instance_id, t.char_entity_id, c.name "
					"FROM trader AS t "
					"JOIN character_data AS c ON t.character_id = c.id "
					"ORDER BY t.char_zone_instance_id ASC "
					"LIMIT {}",
					max_results)
			);
		}

		distinct_traders.reserve(results.RowCount());

		for (auto row: results) {
			DistinctTraders_Struct e{};

			e.trader_id        = Strings::ToInt(row[0]);
			e.zone_id          = Strings::ToInt(row[1]);
			e.zone_instance_id = Strings::ToInt(row[2]);
			e.entity_id        = Strings::ToInt(row[3]);
			e.trader_name      = row[4] ? row[4] : "";
			all_entries.name_length += e.trader_name.length() + 1;

			all_entries.traders.push_back(e);
		}
		all_entries.count = results.RowCount();
		return all_entries;
	}

	static WelcomeData_Struct GetWelcomeData(Database &db)
	{
		WelcomeData_Struct e{};

		auto results = db.QueryDatabase("SELECT COUNT(DISTINCT character_id), count(character_id) FROM trader;");

		if (!results.RowCount()) {
			return e;
		}

		auto r = results.begin();
		e.count_of_traders = Strings::ToInt(r[0]);
		e.count_of_items   = Strings::ToInt(r[1]);
		return e;
	}

	static int UpdateItem(Database &db, uint32 character_id, uint32 new_price, uint32 item_id, uint32 item_charges)
	{
		std::vector<BaseTraderRepository::Trader> items{};
		if (item_charges == 0) {
			items = GetWhere(
				db,
				fmt::format(
					"character_id = {} AND item_id = {}",
					character_id,
					item_id
				)
			);
		}
		else {
			items = GetWhere(
				db,
				fmt::format(
					"character_id = {} AND item_id = {} AND item_charges = {}",
					character_id,
					item_id,
					item_charges
				)
			);
		}

		if (items.empty()) {
			return 0;
		}

		for (auto &i: items) {
			i.item_cost    = new_price;
			i.listing_date = time(nullptr);
		}

		return ReplaceMany(db, items);
	}

	static Trader GetTraderItem(Database &db, uint32 trader_id, uint32 item_id, uint32 item_cost)
	{
		Trader item{};

		auto query   = fmt::format(
			"SELECT t.character_id, t.item_id, t.item_unique_id, t.item_charges, t.item_cost, t.slot_id, t.char_entity_id FROM trader AS t "
			"WHERE t.char_entity_id = {} AND t.item_id = {} AND t.item_cost = {} "
			"LIMIT 1;",
			trader_id,
			item_id,
			item_cost
		);
		auto results = db.QueryDatabase(query);

		if (results.RowCount() == 0) {
			return item;
		}

		auto row               = results.begin();
		item.character_id      = Strings::ToInt(row[0]);
		item.item_id           = Strings::ToInt(row[1]);
		item.item_unique_id    = row[2] ? row[2] : "";
		item.item_charges      = Strings::ToInt(row[3]);
		item.item_cost         = Strings::ToInt(row[4]);
		item.slot_id           = Strings::ToInt(row[5]);
		item.char_entity_id    = Strings::ToInt(row[6]);

		return item;
	}

	static int UpdateQuantity(Database &db, const std::string &item_unique_id, int16 quantity)
	{
		const auto trader_item = GetWhere(
			db,
			fmt::format("`item_unique_id` = '{}' ", item_unique_id)
		);

		if (trader_item.empty() || trader_item.size() > 1) {
			return 0;
		}

		auto m         = trader_item[0];
		m.item_charges = quantity;
		m.listing_date = time(nullptr);

		return UpdateOne(db, m);
	}

	static std::vector<Trader> UpdatePrice(Database &db, const std::string &item_unique_id, uint32 price)
	{
		std::vector<Trader> all_entries{};
		auto target_listing = GetWhere(
			db,
			fmt::format("`item_unique_id` = '{}' LIMIT 1", item_unique_id)
		);

		if (target_listing.empty()) {
			return all_entries;
		}

		auto target = target_listing.front();

		const auto query = fmt::format(
			"UPDATE trader SET `item_cost` = {}, `listing_date` = FROM_UNIXTIME({}) WHERE `character_id` = {} AND "
			"`item_unique_id` = '{}'",
			price,
			time(nullptr),
			target.character_id,
			item_unique_id
		);

		auto results = db.QueryDatabase(query);
		if (results.RowsAffected() == 0) {
			return all_entries;
		}

		all_entries = GetWhere(
			db,
			fmt::format(
				"`character_id` = {} AND `item_unique_id` = '{}'",
				target.character_id,
				item_unique_id
			)
		);

		return all_entries;
	}

	static bool UpdateEntityId(Database &db, uint32 character_id, uint32 old_entity_id, uint32 new_entity_id)
	{
		if (!character_id || !old_entity_id || !new_entity_id) {
			return false;
		}

		auto results = GetWhere(
			db,
			fmt::format("`character_id` = {} AND `char_entity_id` = {}", character_id, old_entity_id)
		);

		if (results.empty()) {
			return false;
		}

		for (auto &entry : results) {
			entry.char_entity_id = new_entity_id;
		}

		return ReplaceMany(db, results);
	}

	static Trader GetItemByItemUniqueNumber(Database &db, std::string &item_unique_id)
	{
		Trader     e{};
		const auto trader_item = GetWhere(
			db,
			fmt::format("`item_unique_id` = '{}' LIMIT 1", item_unique_id)
		);

		if (trader_item.empty()) {
			return e;
		}

		return trader_item.at(0);
	}

	static Trader GetItemByItemUniqueNumber(Database &db, const char* item_unique_id)
	{
		Trader     e{};
		const auto trader_item = GetWhere(
			db,
			fmt::format("`item_unique_id` = '{}' LIMIT 1", item_unique_id)
		);

		if (trader_item.empty()) {
			return e;
		}

		return trader_item.at(0);
	}

	static int UpdateActiveTransaction(Database &db, uint32 id, bool status)
	{
		auto e = FindOne(db, id);
		if (!e.id) {
			return 0;
		}

		e.active_transaction = status == true ? ACTIVE_TRANSACTION_PENDING : ACTIVE_TRANSACTION_NONE;
		e.listing_date       = time(nullptr);

		return UpdateOne(db, e);
	}

	static bool StartActiveTransaction(Database &db, uint64 id, const std::string &item_unique_id)
	{
		if (!id || item_unique_id.empty()) {
			return false;
		}

		auto results = db.QueryDatabase(fmt::format(
			"UPDATE {} SET `active_transaction` = {}, `listing_date` = FROM_UNIXTIME({}) "
			"WHERE `id` = {} AND `item_unique_id` = '{}' AND `active_transaction` = {}",
			TableName(),
			ACTIVE_TRANSACTION_PENDING,
			time(nullptr),
			id,
			Strings::Escape(item_unique_id),
			ACTIVE_TRANSACTION_NONE
		));

		return results.Success() && results.RowsAffected() == 1;
	}

	static bool StartActiveTransactionProcessing(Database &db, uint64 id, const std::string &item_unique_id)
	{
		if (!id || item_unique_id.empty()) {
			return false;
		}

		auto results = db.QueryDatabase(fmt::format(
			"UPDATE {} SET `active_transaction` = {} "
			"WHERE `id` = {} AND `item_unique_id` = '{}' AND `active_transaction` = {}",
			TableName(),
			ACTIVE_TRANSACTION_PROCESSING,
			id,
			Strings::Escape(item_unique_id),
			ACTIVE_TRANSACTION_PENDING
		));

		return results.Success() && results.RowsAffected() == 1;
	}

	static std::string GetActiveTransactionWhereFilter(uint64 id, const std::string &item_unique_id)
	{
		return fmt::format(
			"`id` = {} AND `item_unique_id` = '{}' AND `active_transaction` <> {}",
			id,
			Strings::Escape(item_unique_id),
			ACTIVE_TRANSACTION_NONE
		);
	}

	static Trader GetActiveTransaction(Database &db, uint64 id, const std::string &item_unique_id)
	{
		Trader e{};
		const auto trader_item = GetWhere(
			db,
			fmt::format("{} LIMIT 1", GetActiveTransactionWhereFilter(id, item_unique_id))
		);

		if (trader_item.empty()) {
			return e;
		}

		return trader_item.at(0);
	}

	static int DeleteMany(Database &db, const std::vector<Trader> &entries)
	{
		std::vector<std::string> delete_ids;

		for (auto const &e: entries) {
			delete_ids.push_back(std::to_string(e.id));
		}

		if (delete_ids.empty()) {
			return 0;
		}

		return DeleteWhere(db, fmt::format("`id` IN({})", Strings::Implode(",", delete_ids)));
	}

	static DistinctTraders_Struct GetTraderByItemUniqueNumber(Database &db, std::string &item_unique_id)
	{
		DistinctTraders_Struct trader{};

		auto query = fmt::format(
			"SELECT t.id, t.character_id, t.char_zone_id, t.char_zone_instance_id, t.char_entity_id, c.name "
			"FROM trader AS t "
			"JOIN character_data AS c ON c.id = t.character_id "
			"WHERE t.item_unique_id = '{}' LIMIT 1",
			item_unique_id
		);

		auto results = db.QueryDatabase(query);

		if (results.RowCount() == 0) {
			return trader;
		}

		auto        row    = results.begin();
		trader.trader_id        = Strings::ToUnsignedInt(row[1]);
		trader.zone_id          = Strings::ToUnsignedInt(row[2]);
		trader.zone_instance_id = Strings::ToUnsignedInt(row[3]);
		trader.entity_id        = Strings::ToUnsignedInt(row[4]);
		trader.trader_name      = row[5] ? row[5] : "";

		return trader;
	}

	static std::vector<BazaarTraderSearch_Struct> GetBazaarTraderDetails(
		Database &db,
		const std::string &search_criteria_trader,
		const std::string &name,
		const std::string &field_criteria_items,
		const std::string &where_criteria_items,
		uint32 max_results
		)
	{
		std::vector<BazaarTraderSearch_Struct> all_entries{};

		auto query = BuildBazaarTraderDetailsQuery(
			search_criteria_trader,
			name,
			field_criteria_items,
			where_criteria_items,
			max_results
		);

		auto results = db.QueryDatabase(query);

		if (results.RowCount() == 0) {
			return all_entries;
		}

		all_entries.reserve(results.RowCount());
		for (auto row = results.begin(); row != results.end(); ++row) {
			BazaarTraderSearch_Struct e{};

			e.trader.id                    = row[0] ? strtoull(row[0], nullptr, 10) : 0;
			e.trader.character_id          = row[1] ? static_cast<uint32_t>(strtoul(row[1], nullptr, 10)) : 0;
			e.trader.item_id               = row[2] ? static_cast<uint32_t>(strtoul(row[2], nullptr, 10)) : 0;
			e.trader.item_unique_id        = row[3] ? row[3] : std::string("");
			e.trader.augment_one           = row[4] ? static_cast<uint32_t>(strtoul(row[4], nullptr, 10)) : 0;
			e.trader.augment_two           = row[5] ? static_cast<uint32_t>(strtoul(row[5], nullptr, 10)) : 0;
			e.trader.augment_three         = row[6] ? static_cast<uint32_t>(strtoul(row[6], nullptr, 10)) : 0;
			e.trader.augment_four          = row[7] ? static_cast<uint32_t>(strtoul(row[7], nullptr, 10)) : 0;
			e.trader.augment_five          = row[8] ? static_cast<uint32_t>(strtoul(row[8], nullptr, 10)) : 0;
			e.trader.augment_six           = row[9] ? static_cast<uint32_t>(strtoul(row[9], nullptr, 10)) : 0;
			e.trader.item_charges          = row[10] ? static_cast<int32_t>(atoi(row[10])) : 0;
			e.trader.item_cost             = row[11] ? static_cast<uint32_t>(strtoul(row[11], nullptr, 10)) : 0;
			e.trader.slot_id               = row[12] ? static_cast<uint8_t>(strtoul(row[12], nullptr, 10)) : 0;
			e.trader.char_entity_id        = row[13] ? static_cast<uint32_t>(strtoul(row[13], nullptr, 10)) : 0;
			e.trader.char_zone_id          = row[14] ? static_cast<uint32_t>(strtoul(row[14], nullptr, 10)) : 0;
			e.trader.char_zone_instance_id = row[15] ? static_cast<int32_t>(atoi(row[15])) : 0;
			e.trader.active_transaction    = row[16] ? static_cast<uint8_t>(strtoul(row[16], nullptr, 10)) : 0;
			e.trader_name                  = row[17] ? row[17] : std::string("");
			e.name                         = row[18] ? row[18] : std::string("");
			e.stackable                    = row[19] ? atoi(row[19]) != 0 : false;
			e.icon                         = row[20] ? static_cast<uint32_t>(strtoul(row[20], nullptr, 10)) : 0;
			e.stats                        = row[21] ? static_cast<uint32_t>(strtoul(row[21], nullptr, 10)) : 0;

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static std::string BuildBazaarTraderDetailsQuery(
		const std::string &search_criteria_trader,
		const std::string &name,
		const std::string &field_criteria_items,
		const std::string &where_criteria_items,
		uint32 max_results
	)
	{
		auto query = fmt::format(
			"SELECT trader.id, trader.character_id, trader.item_id, trader.item_unique_id, trader.augment_one, "
			"trader.augment_two, trader.augment_three, trader.augment_four, trader.augment_five, trader.augment_six, "
			"trader.item_charges, trader.item_cost, trader.slot_id, trader.char_entity_id, trader.char_zone_id, "
			"trader.char_zone_instance_id, trader.active_transaction, c.`name`, items.`name`, items.stackable, items.icon, {} "
			"FROM `trader` "
			"INNER JOIN character_data AS c ON trader.character_id = c.id "
			"INNER JOIN items ON trader.item_id = items.id "
			"WHERE {} AND items.`name` LIKE '%{}%' AND {} "
			"ORDER BY trader.character_id ASC",
			field_criteria_items,
			search_criteria_trader,
			Strings::Escape(name),
			where_criteria_items
		);

		if (max_results >= 1) {
			query += fmt::format(" LIMIT {}", max_results);
		}

		return query;
	}

	static Trader GetAccountZoneIdAndInstanceIdByAccountId(Database &db, uint32 account_id)
	{
		auto trader_query = fmt::format(
			"SELECT t.id, t.character_id, t.char_zone_id, t.char_zone_instance_id "
			"FROM trader AS t "
			"WHERE t.character_id IN(SELECT c.id FROM character_data AS c WHERE c.account_id = {}) "
			"LIMIT 1;",
			account_id
		);

		auto buyer_query = fmt::format(
			"SELECT t.id, t.char_id, t.char_zone_id, t.char_zone_instance_id "
			"FROM buyer AS t "
			"WHERE t.char_id IN(SELECT c.id FROM character_data AS c WHERE c.account_id = {}) "
			"LIMIT 1;",
			account_id
		);

		Trader e{};

		auto trader_results = db.QueryDatabase(trader_query);
		auto buyer_results  = db.QueryDatabase(buyer_query);
		if (trader_results.RowCount() == 0 && buyer_results.RowCount() == 0) {
			return e;
		}

		MySQLRequestRow row;
		if (trader_results.RowCount() > 0) {
			row = trader_results.begin();
		}

		if (buyer_results.RowCount() > 0) {
			row = buyer_results.begin();
		}

		e.id                    = row[0] ? strtoull(row[0], nullptr, 10) : 0;
		e.character_id          = row[1] ? static_cast<uint32_t>(strtoul(row[1], nullptr, 10)) : 0;
		e.char_zone_id          = row[2] ? static_cast<uint32_t>(strtoul(row[2], nullptr, 10)) : 0;
		e.char_zone_instance_id = row[3] ? static_cast<int32_t>(atoi(row[3])) : 0;

		return e;
	}
};
