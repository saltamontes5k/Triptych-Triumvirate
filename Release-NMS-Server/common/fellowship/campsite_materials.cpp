#include "campsite_materials.h"

#include "../database.h"

#include <stdexcept>
#include <string>

namespace Fellowship {
namespace Campsites {
namespace {

MySQLRequestResult Query(Database& db, const std::string& sql)
{
	if (db.GetStatus() != DBcore::Connected) {
		throw std::runtime_error("campsite material connection lost");
	}
	auto result = db.QueryDatabase(sql, false);
	if (!result.Success()) {
		throw std::runtime_error("campsite material query failed");
	}
	return result;
}

uint64_t Number(const char* text)
{
	if (!text) {
		throw std::runtime_error("campsite material row is missing a field");
	}
	return std::stoull(text);
}

}

bool ConsumeMaterialsUnderTransaction(Database& db, uint32_t character_id, uint32_t campsite_id,
	const std::array<int16_t, 2>& slots)
{
	try {
		const auto* definition = Lookup(campsite_id);
		if (!definition || !definition->implemented || !definition->kit_item_id ||
			!definition->lumber_item_id || !character_id) {
			return false;
		}
		if (slots[0] == slots[1] || slots[0] < 0 || slots[1] < 0) {
			return false;
		}

		auto transaction = Query(db, "SELECT @@in_transaction");
		if (transaction.RowCount() != 1 || !Number(transaction.begin()[0])) {
			return false;
		}

		const auto actor  = std::to_string(character_id);
		const auto recipe = RequiredMaterials(*definition);
		const std::string columns =
			"SELECT item_id,charges,augment_one,augment_two,augment_three,augment_four,"
			"augment_five,augment_six,item_unique_id,custom_data FROM inventory";

		std::array<uint64_t, 2> charges{};

		// Validate both rows completely before changing either one.
		for (size_t i = 0; i < recipe.size(); ++i) {
			const auto slot = std::to_string(slots[i]);
			auto rows = Query(db, columns + " WHERE character_id=" + actor +
				" AND slot_id=" + slot + " FOR UPDATE");
			if (rows.RowCount() != 1) {
				return false;
			}
			auto row = rows.begin();
			if (Number(row[0]) != recipe[i].item_id) {
				return false;
			}
			if (!row[1] || !(charges[i] = Number(row[1]))) {
				return false;
			}
			for (int augment = 2; augment <= 7; ++augment) {
				if (row[augment] && Number(row[augment])) {
					return false;
				}
			}
			if (row[8] && Number(row[8])) {
				return false;
			}
			if (row[9] && *row[9]) {
				return false;
			}

			auto item = Query(db, "SELECT itemtype,itemclass,stackable,charmfileid,evoitem FROM items WHERE id=" +
				std::to_string(recipe[i].item_id) + " FOR UPDATE");
			if (item.RowCount() != 1) {
				return false;
			}
			auto definition_row = item.begin();
			if (Number(definition_row[0]) != 58 || Number(definition_row[1]) != 0 ||
				Number(definition_row[2]) != 1 || Number(definition_row[3]) != 0 ||
				Number(definition_row[4]) != 0) {
				return false;
			}

			auto evolving = Query(db, "SELECT item_id FROM items_evolving_details WHERE item_id=" +
				std::to_string(recipe[i].item_id) + " LIMIT 1 FOR UPDATE");
			if (evolving.RowCount()) {
				return false;
			}
		}

		for (size_t i = 0; i < recipe.size(); ++i) {
			const auto where = " WHERE character_id=" + actor + " AND slot_id=" +
				std::to_string(slots[i]) + " AND item_id=" + std::to_string(recipe[i].item_id) +
				" AND charges=" + std::to_string(charges[i]);
			auto debit = Query(db, charges[i] == 1 ? "DELETE FROM inventory" + where
				: "UPDATE inventory SET charges=charges-1" + where);
			if (debit.RowsAffected() != 1) {
				throw std::runtime_error("campsite material debit changed");
			}
		}
		return true;
	} catch (...) {
		// The service treats any throw as a failure and rolls the transaction back.
		throw;
	}
}

}
}
