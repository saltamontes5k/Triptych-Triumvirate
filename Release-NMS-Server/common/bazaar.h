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

#include "item_instance.h"
#include "shareddb.h"

#include <memory>
#include <vector>

class Bazaar {
public:
	struct PurchaseQuantityValidation {
		bool   is_valid;
		uint32 quantity;
	};

	struct TransactionValueValidation {
		bool   is_valid;
		uint64 total_cost;
	};

	static PurchaseQuantityValidation ValidatePurchaseQuantity(
		uint32 requested_quantity,
		bool is_stackable,
		int16 listed_charges
	);

	static int16 ResolvePurchaseItemCharges(
		uint32 purchase_quantity,
		bool is_stackable,
		int16 max_charges,
		int16 listed_charges
	);

	static std::vector<std::unique_ptr<EQ::ItemInstance>> CreateBarterPurchaseItems(
		SharedDatabase &db,
		const EQ::ItemData *item,
		uint32 quantity
	);

	static bool ValidateBarterSellQuantity(uint32 requested_quantity, uint32 listed_quantity);

	static TransactionValueValidation ValidateBuyLinePrice(
		uint32 unit_price,
		uint64 max_transaction_value
	);

	static TransactionValueValidation ValidateTransactionValue(
		uint32 unit_price,
		uint32 quantity,
		uint64 max_transaction_value
	);

	static bool ValidatePurchasePrice(uint32 requested_price, uint32 listed_price);

	static void RecordAuditTrail(
		Database &db,
		const std::string &seller,
		const std::string &buyer,
		uint32 item_id,
		const std::string &item_name,
		uint32 quantity,
		uint64 total_cost,
		int transaction_type
	);

	static uint32 ResolvePurchaseFailureSubAction(uint32 sub_action);

	static std::vector<BazaarSearchResultsFromDB_Struct>
	GetSearchResults(Database &content_db, Database &db, BazaarSearchCriteria_Struct search, unsigned int char_zone_id, int char_zone_instance_id);

};
