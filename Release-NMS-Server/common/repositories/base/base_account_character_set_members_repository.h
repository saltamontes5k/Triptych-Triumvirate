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

#ifndef EQEMU_BASE_ACCOUNT_CHARACTER_SET_MEMBERS_REPOSITORY_H
#define EQEMU_BASE_ACCOUNT_CHARACTER_SET_MEMBERS_REPOSITORY_H

#include "../../database.h"
#include "../../strings.h"
#include <ctime>

class BaseAccountCharacterSetMembersRepository {
public:
	struct AccountCharacterSetMembers {
		int32_t account_id;
		int32_t set_id;
		int32_t character_id;
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
			"character_id",
		};
	}

	static std::vector<std::string> SelectColumns()
	{
		return {
			"account_id",
			"set_id",
			"character_id",
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
		return std::string("account_character_set_members");
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

	static AccountCharacterSetMembers NewEntity()
	{
		AccountCharacterSetMembers e{};

		e.account_id   = 0;
		e.set_id       = 0;
		e.character_id = 0;

		return e;
	}

	static AccountCharacterSetMembers GetAccountCharacterSetMembers(
		const std::vector<AccountCharacterSetMembers> &account_character_set_memberss,
		int account_character_set_members_id
	)
	{
		for (auto &account_character_set_members : account_character_set_memberss) {
			if (account_character_set_members.account_id == account_character_set_members_id) {
				return account_character_set_members;
			}
		}

		return NewEntity();
	}

	static AccountCharacterSetMembers FindOne(
		Database& db,
		int account_character_set_members_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {} = {} LIMIT 1",
				BaseSelect(),
				PrimaryKey(),
				account_character_set_members_id
			)
		);

		auto row = results.begin();
		if (results.RowCount() == 1) {
			AccountCharacterSetMembers e{};

			e.account_id   = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.set_id       = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.character_id = row[2] ? static_cast<int32_t>(atoi(row[2])) : 0;

			return e;
		}

		return NewEntity();
	}

	static int DeleteOne(
		Database& db,
		int account_character_set_members_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"DELETE FROM {} WHERE {} = {}",
				TableName(),
				PrimaryKey(),
				account_character_set_members_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int UpdateOne(
		Database& db,
		const AccountCharacterSetMembers &e
	)
	{
		std::vector<std::string> v;

		auto columns = Columns();

		v.push_back(columns[0] + " = " + std::to_string(e.account_id));
		v.push_back(columns[1] + " = " + std::to_string(e.set_id));
		v.push_back(columns[2] + " = " + std::to_string(e.character_id));

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

	static AccountCharacterSetMembers InsertOne(
		Database& db,
		AccountCharacterSetMembers e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.account_id));
		v.push_back(std::to_string(e.set_id));
		v.push_back(std::to_string(e.character_id));

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
		const std::vector<AccountCharacterSetMembers> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.account_id));
			v.push_back(std::to_string(e.set_id));
			v.push_back(std::to_string(e.character_id));

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

	static std::vector<AccountCharacterSetMembers> All(Database& db)
	{
		std::vector<AccountCharacterSetMembers> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{}",
				BaseSelect()
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			AccountCharacterSetMembers e{};

			e.account_id   = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.set_id       = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.character_id = row[2] ? static_cast<int32_t>(atoi(row[2])) : 0;

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static std::vector<AccountCharacterSetMembers> GetWhere(Database& db, const std::string &where_filter)
	{
		std::vector<AccountCharacterSetMembers> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {}",
				BaseSelect(),
				where_filter
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			AccountCharacterSetMembers e{};

			e.account_id   = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.set_id       = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.character_id = row[2] ? static_cast<int32_t>(atoi(row[2])) : 0;

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
		const AccountCharacterSetMembers &e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.account_id));
		v.push_back(std::to_string(e.set_id));
		v.push_back(std::to_string(e.character_id));

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
		const std::vector<AccountCharacterSetMembers> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.account_id));
			v.push_back(std::to_string(e.set_id));
			v.push_back(std::to_string(e.character_id));

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

#endif //EQEMU_BASE_ACCOUNT_CHARACTER_SET_MEMBERS_REPOSITORY_H
