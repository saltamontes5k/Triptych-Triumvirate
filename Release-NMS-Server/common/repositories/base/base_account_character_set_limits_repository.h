/**
 * DO NOT MODIFY THIS FILE
 *
 * This repository was automatically generated and is NOT to be modified directly.
 * Any repository modifications are meant to be made to the repository extending the base.
 * Any modifications to base repositories are to be made by the generator only
 *
 * @generator ./utils/scripts/generators/repository-generator.pl
 * @docs https://docs.eqemu.io/developer/repositories
 */

#ifndef EQEMU_BASE_ACCOUNT_CHARACTER_SET_LIMITS_REPOSITORY_H
#define EQEMU_BASE_ACCOUNT_CHARACTER_SET_LIMITS_REPOSITORY_H

#include "../../database.h"
#include "../../strings.h"
#include <ctime>

class BaseAccountCharacterSetLimitsRepository {
public:
	struct AccountCharacterSetLimits {
		int32_t account_id;
		int32_t eom_sets;
		int32_t bonus_sets;
		int32_t default_set;
		int32_t eom_slots;
		int32_t bonus_slots;
	};

	static std::string PrimaryKey()
	{
		return std::string("account_id");
	}

	static std::vector<std::string> Columns()
	{
		return {
			"account_id",
			"eom_sets",
			"bonus_sets",
			"default_set",
			"eom_slots",
			"bonus_slots",
		};
	}

	static std::vector<std::string> SelectColumns()
	{
		return {
			"account_id",
			"eom_sets",
			"bonus_sets",
			"default_set",
			"eom_slots",
			"bonus_slots",
		};
	}

	static std::string ColumnsRaw()
	{
		return std::string(Strings::Implode(", ", Columns()));
	}

	static std::string SelectColumnsRaw()
	{
		return std::string(Strings::Implode(", ", SelectColumns()));
	}

	static std::string TableName()
	{
		return std::string("account_character_set_limits");
	}

	static std::string BaseSelect()
	{
		return fmt::format(
			"SELECT {} FROM {}",
			SelectColumnsRaw(),
			TableName()
		);
	}

	static std::string BaseInsert()
	{
		return fmt::format(
			"INSERT INTO {} ({}) ",
			TableName(),
			ColumnsRaw()
		);
	}

	static AccountCharacterSetLimits NewEntity()
	{
		AccountCharacterSetLimits e{};

		e.account_id  = 0;
		e.eom_sets    = 0;
		e.bonus_sets  = 0;
		e.default_set = 0;
		e.eom_slots   = 0;
		e.bonus_slots = 0;

		return e;
	}

	static AccountCharacterSetLimits GetAccountCharacterSetLimits(
		const std::vector<AccountCharacterSetLimits> &account_character_set_limitss,
		int account_character_set_limits_id
	)
	{
		for (auto &account_character_set_limits : account_character_set_limitss) {
			if (account_character_set_limits.account_id == account_character_set_limits_id) {
				return account_character_set_limits;
			}
		}

		return NewEntity();
	}

	static AccountCharacterSetLimits FindOne(
		Database& db,
		int account_character_set_limits_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {} = {} LIMIT 1",
				BaseSelect(),
				PrimaryKey(),
				account_character_set_limits_id
			)
		);

		auto row = results.begin();
		if (results.RowCount() == 1) {
			AccountCharacterSetLimits e{};

			e.account_id  = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.eom_sets    = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.bonus_sets  = row[2] ? static_cast<int32_t>(atoi(row[2])) : 0;
			e.default_set = row[3] ? static_cast<int32_t>(atoi(row[3])) : 0;
			e.eom_slots   = row[4] ? static_cast<int32_t>(atoi(row[4])) : 0;
			e.bonus_slots = row[5] ? static_cast<int32_t>(atoi(row[5])) : 0;

			return e;
		}

		return NewEntity();
	}

	static int DeleteOne(
		Database& db,
		int account_character_set_limits_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"DELETE FROM {} WHERE {} = {}",
				TableName(),
				PrimaryKey(),
				account_character_set_limits_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int UpdateOne(
		Database& db,
		const AccountCharacterSetLimits &e
	)
	{
		std::vector<std::string> v;

		auto columns = Columns();

		v.push_back(columns[0] + " = " + std::to_string(e.account_id));
		v.push_back(columns[1] + " = " + std::to_string(e.eom_sets));
		v.push_back(columns[2] + " = " + std::to_string(e.bonus_sets));
		v.push_back(columns[3] + " = " + std::to_string(e.default_set));
		v.push_back(columns[4] + " = " + std::to_string(e.eom_slots));
		v.push_back(columns[5] + " = " + std::to_string(e.bonus_slots));

		auto results = db.QueryDatabase(
			fmt::format(
				"UPDATE {} SET {} WHERE {} = {}",
				TableName(),
				Strings::Implode(", ", v),
				PrimaryKey(),
				e.account_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static AccountCharacterSetLimits InsertOne(
		Database& db,
		AccountCharacterSetLimits e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.account_id));
		v.push_back(std::to_string(e.eom_sets));
		v.push_back(std::to_string(e.bonus_sets));
		v.push_back(std::to_string(e.default_set));
		v.push_back(std::to_string(e.eom_slots));
		v.push_back(std::to_string(e.bonus_slots));

		auto results = db.QueryDatabase(
			fmt::format(
				"{} VALUES ({})",
				BaseInsert(),
				Strings::Implode(",", v)
			)
		);

		if (results.Success()) {
			e.account_id = results.LastInsertedID();
			return e;
		}

		e = NewEntity();

		return e;
	}

	static int InsertMany(
		Database& db,
		const std::vector<AccountCharacterSetLimits> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.account_id));
			v.push_back(std::to_string(e.eom_sets));
			v.push_back(std::to_string(e.bonus_sets));
			v.push_back(std::to_string(e.default_set));
			v.push_back(std::to_string(e.eom_slots));
			v.push_back(std::to_string(e.bonus_slots));

			insert_chunks.push_back("(" + Strings::Implode(",", v) + ")");
		}

		std::vector<std::string> v;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} VALUES {}",
				BaseInsert(),
				Strings::Implode(",", insert_chunks)
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static std::vector<AccountCharacterSetLimits> All(Database& db)
	{
		std::vector<AccountCharacterSetLimits> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{}",
				BaseSelect()
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			AccountCharacterSetLimits e{};

			e.account_id  = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.eom_sets    = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.bonus_sets  = row[2] ? static_cast<int32_t>(atoi(row[2])) : 0;
			e.default_set = row[3] ? static_cast<int32_t>(atoi(row[3])) : 0;
			e.eom_slots   = row[4] ? static_cast<int32_t>(atoi(row[4])) : 0;
			e.bonus_slots = row[5] ? static_cast<int32_t>(atoi(row[5])) : 0;

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static std::vector<AccountCharacterSetLimits> GetWhere(Database& db, const std::string &where_filter)
	{
		std::vector<AccountCharacterSetLimits> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {}",
				BaseSelect(),
				where_filter
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			AccountCharacterSetLimits e{};

			e.account_id  = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.eom_sets    = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.bonus_sets  = row[2] ? static_cast<int32_t>(atoi(row[2])) : 0;
			e.default_set = row[3] ? static_cast<int32_t>(atoi(row[3])) : 0;
			e.eom_slots   = row[4] ? static_cast<int32_t>(atoi(row[4])) : 0;
			e.bonus_slots = row[5] ? static_cast<int32_t>(atoi(row[5])) : 0;

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static int DeleteWhere(Database& db, const std::string &where_filter)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"DELETE FROM {} WHERE {}",
				TableName(),
				where_filter
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int Truncate(Database& db)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"TRUNCATE TABLE {}",
				TableName()
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int64 GetMaxId(Database& db)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"SELECT COALESCE(MAX({}), 0) FROM {}",
				PrimaryKey(),
				TableName()
			)
		);

		return (results.Success() && results.begin()[0] ? strtoll(results.begin()[0], nullptr, 10) : 0);
	}

	static int64 Count(Database& db, const std::string &where_filter = "")
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"SELECT COUNT(*) FROM {} {}",
				TableName(),
				(where_filter.empty() ? "" : "WHERE " + where_filter)
			)
		);

		return (results.Success() && results.begin()[0] ? strtoll(results.begin()[0], nullptr, 10) : 0);
	}

	static std::string BaseReplace()
	{
		return fmt::format(
			"REPLACE INTO {} ({}) ",
			TableName(),
			ColumnsRaw()
		);
	}

	static int ReplaceOne(
		Database& db,
		const AccountCharacterSetLimits &e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.account_id));
		v.push_back(std::to_string(e.eom_sets));
		v.push_back(std::to_string(e.bonus_sets));
		v.push_back(std::to_string(e.default_set));
		v.push_back(std::to_string(e.eom_slots));
		v.push_back(std::to_string(e.bonus_slots));

		auto results = db.QueryDatabase(
			fmt::format(
				"{} VALUES ({})",
				BaseReplace(),
				Strings::Implode(",", v)
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int ReplaceMany(
		Database& db,
		const std::vector<AccountCharacterSetLimits> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.account_id));
			v.push_back(std::to_string(e.eom_sets));
			v.push_back(std::to_string(e.bonus_sets));
			v.push_back(std::to_string(e.default_set));
			v.push_back(std::to_string(e.eom_slots));
			v.push_back(std::to_string(e.bonus_slots));

			insert_chunks.push_back("(" + Strings::Implode(",", v) + ")");
		}

		std::vector<std::string> v;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} VALUES {}",
				BaseReplace(),
				Strings::Implode(",", insert_chunks)
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}
};

#endif //EQEMU_BASE_ACCOUNT_CHARACTER_SET_LIMITS_REPOSITORY_H
