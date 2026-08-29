#pragma once

#include "../../common/database.h"
#include "../../common/strings.h"
#include "../../common/item_instance.h"

class ItemUniqueIdReservationsRepository {
public:
	static bool Reserve(Database &db, const std::string &item_unique_id)
	{
		if (item_unique_id.empty()) {
			return false;
		}

		auto results = db.QueryDatabase(
			fmt::format(
				"INSERT IGNORE INTO item_unique_id_reservations (item_unique_id, reserved_at) VALUES ('{}', NOW())",
				Strings::Escape(item_unique_id)
			)
		);

		return results.Success() && results.RowsAffected() == 1;
	}

	static bool Exists(Database &db, const std::string &item_unique_id)
	{
		if (item_unique_id.empty()) {
			return false;
		}

		auto results = db.QueryDatabase(
			fmt::format(
				"SELECT 1 FROM item_unique_id_reservations WHERE item_unique_id = '{}' LIMIT 1",
				Strings::Escape(item_unique_id)
			)
		);

		return results.Success() && results.RowCount() == 1;
	}

	static bool EnsureReserved(Database &db, const std::string &item_unique_id)
	{
		if (item_unique_id.empty()) {
			return false;
		}

		return Reserve(db, item_unique_id) || Exists(db, item_unique_id);
	}

	static std::string ReserveNew(Database &db, uint32 max_attempts = 64)
	{
		for (uint32 attempt = 0; attempt < max_attempts; ++attempt) {
			auto candidate = EQ::UniqueHashGenerator::generate();
			auto results   = db.QueryDatabase(
				fmt::format(
					"INSERT INTO item_unique_id_reservations (item_unique_id, reserved_at) VALUES ('{}', NOW())",
					Strings::Escape(candidate)
				)
			);

			if (results.Success()) {
				return candidate;
			}

			if (results.ErrorNumber() != 1062) {
				LogError(
					"Failed reserving item_unique_id [{}] (attempt {}): ({}) {}",
					candidate,
					attempt + 1,
					results.ErrorNumber(),
					results.ErrorMessage()
				);
				break;
			}
		}

		return {};
	}

	static bool PopulateFromTable(Database &db, const std::string &table_name, const std::string &column_name)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"INSERT IGNORE INTO item_unique_id_reservations (item_unique_id, reserved_at) "
				"SELECT DISTINCT {1}, NOW() FROM {0} WHERE {1} IS NOT NULL AND {1} <> ''",
				table_name,
				column_name
			)
		);

		return results.Success();
	}
};
