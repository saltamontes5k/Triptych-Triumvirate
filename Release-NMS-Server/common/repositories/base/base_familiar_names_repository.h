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

#ifndef EQEMU_BASE_FAMILIAR_NAMES_REPOSITORY_H
#define EQEMU_BASE_FAMILIAR_NAMES_REPOSITORY_H

#include "../../database.h"
#include "../../strings.h"
#include <ctime>

class BaseFamiliarNamesRepository {
public:
	struct FamiliarNames {
		int32_t     spell_id;
		std::string name_list;
		int32_t     size_mod;
	};

	static std::string PrimaryKey()
	{
		return std::string("spell_id");
	}

	static std::vector<std::string> Columns()
	{
		return {
			"spell_id",
			"name_list",
			"size_mod",
		};
	}

	static std::vector<std::string> SelectColumns()
	{
		return {
			"spell_id",
			"name_list",
			"size_mod",
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
		return std::string("familiar_names");
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

	static FamiliarNames NewEntity()
	{
		FamiliarNames e{};

		e.spell_id  = 0;
		e.name_list = "";
		e.size_mod  = -1;

		return e;
	}

	static FamiliarNames GetFamiliarNames(
		const std::vector<FamiliarNames> &familiar_namess,
		int familiar_names_id
	)
	{
		for (auto &familiar_names : familiar_namess) {
			if (familiar_names.spell_id == familiar_names_id) {
				return familiar_names;
			}
		}

		return NewEntity();
	}

	static FamiliarNames FindOne(
		Database& db,
		int familiar_names_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {} = {} LIMIT 1",
				BaseSelect(),
				PrimaryKey(),
				familiar_names_id
			)
		);

		auto row = results.begin();
		if (results.RowCount() == 1) {
			FamiliarNames e{};

			e.spell_id  = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.name_list = row[1] ? row[1] : "";
			e.size_mod  = row[2] ? static_cast<int32_t>(atoi(row[2])) : -1;

			return e;
		}

		return NewEntity();
	}

	static int DeleteOne(
		Database& db,
		int familiar_names_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"DELETE FROM {} WHERE {} = {}",
				TableName(),
				PrimaryKey(),
				familiar_names_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int UpdateOne(
		Database& db,
		const FamiliarNames &e
	)
	{
		std::vector<std::string> v;

		auto columns = Columns();

		v.push_back(columns[0] + " = " + std::to_string(e.spell_id));
		v.push_back(columns[1] + " = '" + Strings::Escape(e.name_list) + "'");
		v.push_back(columns[2] + " = " + std::to_string(e.size_mod));

		auto results = db.QueryDatabase(
			fmt::format(
				"UPDATE {} SET {} WHERE {} = {}",
				TableName(),
				Strings::Implode(", ", v),
				PrimaryKey(),
				e.spell_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static FamiliarNames InsertOne(
		Database& db,
		FamiliarNames e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.spell_id));
		v.push_back("'" + Strings::Escape(e.name_list) + "'");
		v.push_back(std::to_string(e.size_mod));

		auto results = db.QueryDatabase(
			fmt::format(
				"{} VALUES ({})",
				BaseInsert(),
				Strings::Implode(",", v)
			)
		);

		if (results.Success()) {
			e.spell_id = results.LastInsertedID();
			return e;
		}

		e = NewEntity();

		return e;
	}

	static int InsertMany(
		Database& db,
		const std::vector<FamiliarNames> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.spell_id));
			v.push_back("'" + Strings::Escape(e.name_list) + "'");
			v.push_back(std::to_string(e.size_mod));

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

	static std::vector<FamiliarNames> All(Database& db)
	{
		std::vector<FamiliarNames> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{}",
				BaseSelect()
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			FamiliarNames e{};

			e.spell_id  = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.name_list = row[1] ? row[1] : "";
			e.size_mod  = row[2] ? static_cast<int32_t>(atoi(row[2])) : -1;

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static std::vector<FamiliarNames> GetWhere(Database& db, const std::string &where_filter)
	{
		std::vector<FamiliarNames> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {}",
				BaseSelect(),
				where_filter
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			FamiliarNames e{};

			e.spell_id  = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.name_list = row[1] ? row[1] : "";
			e.size_mod  = row[2] ? static_cast<int32_t>(atoi(row[2])) : -1;

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
		const FamiliarNames &e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.spell_id));
		v.push_back("'" + Strings::Escape(e.name_list) + "'");
		v.push_back(std::to_string(e.size_mod));

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
		const std::vector<FamiliarNames> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.spell_id));
			v.push_back("'" + Strings::Escape(e.name_list) + "'");
			v.push_back(std::to_string(e.size_mod));

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

#endif //EQEMU_BASE_FAMILIAR_NAMES_REPOSITORY_H
