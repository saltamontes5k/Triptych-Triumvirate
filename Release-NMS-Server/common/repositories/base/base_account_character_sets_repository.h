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

#ifndef EQEMU_BASE_ACCOUNT_CHARACTER_SETS_REPOSITORY_H
#define EQEMU_BASE_ACCOUNT_CHARACTER_SETS_REPOSITORY_H

#include "../../database.h"
#include "../../strings.h"
#include <ctime>

class BaseAccountCharacterSetsRepository {
public:
	struct AccountCharacterSets {
		int32_t     account_id;
		int32_t     set_id;
		std::string set_name;
		time_t      created_at;
	};

	static std::string PrimaryKey()
	{
		return std::string("account_id");
	}

	static std::vector<std::string> Columns()
	{
		return {
			"account_id",
			"set_id",
			"set_name",
			"created_at",
		};
	}

	static std::vector<std::string> SelectColumns()
	{
		return {
			"account_id",
			"set_id",
			"set_name",
			"UNIX_TIMESTAMP(created_at)",
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
		return std::string("account_character_sets");
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

	static AccountCharacterSets NewEntity()
	{
		AccountCharacterSets e{};

		e.account_id = 0;
		e.set_id     = 0;
		e.set_name   = "";
		e.created_at = std::time(nullptr);

		return e;
	}

	static AccountCharacterSets GetAccountCharacterSets(
		const std::vector<AccountCharacterSets> &account_character_setss,
		int account_character_sets_id
	)
	{
		for (auto &account_character_sets : account_character_setss) {
			if (account_character_sets.account_id == account_character_sets_id) {
				return account_character_sets;
			}
		}

		return NewEntity();
	}

	static AccountCharacterSets FindOne(
		Database& db,
		int account_character_sets_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {} = {} LIMIT 1",
				BaseSelect(),
				PrimaryKey(),
				account_character_sets_id
			)
		);

		auto row = results.begin();
		if (results.RowCount() == 1) {
			AccountCharacterSets e{};

			e.account_id = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.set_id     = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.set_name   = row[2] ? row[2] : "";
			e.created_at = strtoll(row[3] ? row[3] : "-1", nullptr, 10);

			return e;
		}

		return NewEntity();
	}

	static int DeleteOne(
		Database& db,
		int account_character_sets_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"DELETE FROM {} WHERE {} = {}",
				TableName(),
				PrimaryKey(),
				account_character_sets_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int UpdateOne(
		Database& db,
		const AccountCharacterSets &e
	)
	{
		std::vector<std::string> v;

		auto columns = Columns();

		v.push_back(columns[0] + " = " + std::to_string(e.account_id));
		v.push_back(columns[1] + " = " + std::to_string(e.set_id));
		v.push_back(columns[2] + " = '" + Strings::Escape(e.set_name) + "'");
		v.push_back(columns[3] + " = FROM_UNIXTIME(" + (e.created_at > 0 ? std::to_string(e.created_at) : "null") + ")");

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

	static AccountCharacterSets InsertOne(
		Database& db,
		AccountCharacterSets e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.account_id));
		v.push_back(std::to_string(e.set_id));
		v.push_back("'" + Strings::Escape(e.set_name) + "'");
		v.push_back("FROM_UNIXTIME(" + (e.created_at > 0 ? std::to_string(e.created_at) : "null") + ")");

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
		const std::vector<AccountCharacterSets> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.account_id));
			v.push_back(std::to_string(e.set_id));
			v.push_back("'" + Strings::Escape(e.set_name) + "'");
			v.push_back("FROM_UNIXTIME(" + (e.created_at > 0 ? std::to_string(e.created_at) : "null") + ")");

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

	static std::vector<AccountCharacterSets> All(Database& db)
	{
		std::vector<AccountCharacterSets> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{}",
				BaseSelect()
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			AccountCharacterSets e{};

			e.account_id = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.set_id     = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.set_name   = row[2] ? row[2] : "";
			e.created_at = strtoll(row[3] ? row[3] : "-1", nullptr, 10);

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static std::vector<AccountCharacterSets> GetWhere(Database& db, const std::string &where_filter)
	{
		std::vector<AccountCharacterSets> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {}",
				BaseSelect(),
				where_filter
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			AccountCharacterSets e{};

			e.account_id = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.set_id     = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.set_name   = row[2] ? row[2] : "";
			e.created_at = strtoll(row[3] ? row[3] : "-1", nullptr, 10);

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
		const AccountCharacterSets &e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.account_id));
		v.push_back(std::to_string(e.set_id));
		v.push_back("'" + Strings::Escape(e.set_name) + "'");
		v.push_back("FROM_UNIXTIME(" + (e.created_at > 0 ? std::to_string(e.created_at) : "null") + ")");

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
		const std::vector<AccountCharacterSets> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.account_id));
			v.push_back(std::to_string(e.set_id));
			v.push_back("'" + Strings::Escape(e.set_name) + "'");
			v.push_back("FROM_UNIXTIME(" + (e.created_at > 0 ? std::to_string(e.created_at) : "null") + ")");

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

#endif //EQEMU_BASE_ACCOUNT_CHARACTER_SETS_REPOSITORY_H
