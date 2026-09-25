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

#ifndef EQEMU_BASE_FABLED_SEASON_REPOSITORY_H
#define EQEMU_BASE_FABLED_SEASON_REPOSITORY_H

#include "../../database.h"
#include "../../strings.h"
#include <ctime>

class BaseFabledSeasonRepository {
public:
	struct FabledSeason {
		int32_t     id;
		int8_t      active;
		int64_t     start_epoch;
		int64_t     end_epoch;
		uint8_t     scope_kind;
		std::string scope_value;
		uint8_t     chance;
		uint8_t     loot_tier;
		std::string set_by;
		int64_t     set_at;
	};

	static std::string PrimaryKey()
	{
		return std::string("id");
	}

	static std::vector<std::string> Columns()
	{
		return {
			"id",
			"active",
			"start_epoch",
			"end_epoch",
			"scope_kind",
			"scope_value",
			"chance",
			"loot_tier",
			"set_by",
			"set_at",
		};
	}

	static std::vector<std::string> SelectColumns()
	{
		return {
			"id",
			"active",
			"start_epoch",
			"end_epoch",
			"scope_kind",
			"scope_value",
			"chance",
			"loot_tier",
			"set_by",
			"set_at",
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
		return std::string("fabled_season");
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

	static FabledSeason NewEntity()
	{
		FabledSeason e{};

		e.id          = 0;
		e.active      = 0;
		e.start_epoch = 0;
		e.end_epoch   = 0;
		e.scope_kind  = 0;
		e.scope_value = "";
		e.chance      = 50;
		e.loot_tier   = 2;
		e.set_by      = "";
		e.set_at      = 0;

		return e;
	}

	static FabledSeason GetFabledSeason(
		const std::vector<FabledSeason> &fabled_seasons,
		int fabled_season_id
	)
	{
		for (auto &fabled_season : fabled_seasons) {
			if (fabled_season.id == fabled_season_id) {
				return fabled_season;
			}
		}

		return NewEntity();
	}

	static FabledSeason FindOne(
		Database& db,
		int fabled_season_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {} = {} LIMIT 1",
				BaseSelect(),
				PrimaryKey(),
				fabled_season_id
			)
		);

		auto row = results.begin();
		if (results.RowCount() == 1) {
			FabledSeason e{};

			e.id          = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.active      = row[1] ? static_cast<int8_t>(atoi(row[1])) : 0;
			e.start_epoch = row[2] ? strtoll(row[2], nullptr, 10) : 0;
			e.end_epoch   = row[3] ? strtoll(row[3], nullptr, 10) : 0;
			e.scope_kind  = row[4] ? static_cast<uint8_t>(strtoul(row[4], nullptr, 10)) : 0;
			e.scope_value = row[5] ? row[5] : "";
			e.chance      = row[6] ? static_cast<uint8_t>(strtoul(row[6], nullptr, 10)) : 50;
			e.loot_tier   = row[7] ? static_cast<uint8_t>(strtoul(row[7], nullptr, 10)) : 2;
			e.set_by      = row[8] ? row[8] : "";
			e.set_at      = row[9] ? strtoll(row[9], nullptr, 10) : 0;

			return e;
		}

		return NewEntity();
	}

	static int DeleteOne(
		Database& db,
		int fabled_season_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"DELETE FROM {} WHERE {} = {}",
				TableName(),
				PrimaryKey(),
				fabled_season_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int UpdateOne(
		Database& db,
		const FabledSeason &e
	)
	{
		std::vector<std::string> v;

		auto columns = Columns();

		v.push_back(columns[0] + " = " + std::to_string(e.id));
		v.push_back(columns[1] + " = " + std::to_string(e.active));
		v.push_back(columns[2] + " = " + std::to_string(e.start_epoch));
		v.push_back(columns[3] + " = " + std::to_string(e.end_epoch));
		v.push_back(columns[4] + " = " + std::to_string(e.scope_kind));
		v.push_back(columns[5] + " = '" + Strings::Escape(e.scope_value) + "'");
		v.push_back(columns[6] + " = " + std::to_string(e.chance));
		v.push_back(columns[7] + " = " + std::to_string(e.loot_tier));
		v.push_back(columns[8] + " = '" + Strings::Escape(e.set_by) + "'");
		v.push_back(columns[9] + " = " + std::to_string(e.set_at));

		auto results = db.QueryDatabase(
			fmt::format(
				"UPDATE {} SET {} WHERE {} = {}",
				TableName(),
				Strings::Implode(", ", v),
				PrimaryKey(),
				e.id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static FabledSeason InsertOne(
		Database& db,
		FabledSeason e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.id));
		v.push_back(std::to_string(e.active));
		v.push_back(std::to_string(e.start_epoch));
		v.push_back(std::to_string(e.end_epoch));
		v.push_back(std::to_string(e.scope_kind));
		v.push_back("'" + Strings::Escape(e.scope_value) + "'");
		v.push_back(std::to_string(e.chance));
		v.push_back(std::to_string(e.loot_tier));
		v.push_back("'" + Strings::Escape(e.set_by) + "'");
		v.push_back(std::to_string(e.set_at));

		auto results = db.QueryDatabase(
			fmt::format(
				"{} VALUES ({})",
				BaseInsert(),
				Strings::Implode(",", v)
			)
		);

		if (results.Success()) {
			e.id = results.LastInsertedID();
			return e;
		}

		e = NewEntity();

		return e;
	}

	static int InsertMany(
		Database& db,
		const std::vector<FabledSeason> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.id));
			v.push_back(std::to_string(e.active));
			v.push_back(std::to_string(e.start_epoch));
			v.push_back(std::to_string(e.end_epoch));
			v.push_back(std::to_string(e.scope_kind));
			v.push_back("'" + Strings::Escape(e.scope_value) + "'");
			v.push_back(std::to_string(e.chance));
			v.push_back(std::to_string(e.loot_tier));
			v.push_back("'" + Strings::Escape(e.set_by) + "'");
			v.push_back(std::to_string(e.set_at));

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

	static std::vector<FabledSeason> All(Database& db)
	{
		std::vector<FabledSeason> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{}",
				BaseSelect()
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			FabledSeason e{};

			e.id          = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.active      = row[1] ? static_cast<int8_t>(atoi(row[1])) : 0;
			e.start_epoch = row[2] ? strtoll(row[2], nullptr, 10) : 0;
			e.end_epoch   = row[3] ? strtoll(row[3], nullptr, 10) : 0;
			e.scope_kind  = row[4] ? static_cast<uint8_t>(strtoul(row[4], nullptr, 10)) : 0;
			e.scope_value = row[5] ? row[5] : "";
			e.chance      = row[6] ? static_cast<uint8_t>(strtoul(row[6], nullptr, 10)) : 50;
			e.loot_tier   = row[7] ? static_cast<uint8_t>(strtoul(row[7], nullptr, 10)) : 2;
			e.set_by      = row[8] ? row[8] : "";
			e.set_at      = row[9] ? strtoll(row[9], nullptr, 10) : 0;

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static std::vector<FabledSeason> GetWhere(Database& db, const std::string &where_filter)
	{
		std::vector<FabledSeason> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {}",
				BaseSelect(),
				where_filter
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			FabledSeason e{};

			e.id          = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.active      = row[1] ? static_cast<int8_t>(atoi(row[1])) : 0;
			e.start_epoch = row[2] ? strtoll(row[2], nullptr, 10) : 0;
			e.end_epoch   = row[3] ? strtoll(row[3], nullptr, 10) : 0;
			e.scope_kind  = row[4] ? static_cast<uint8_t>(strtoul(row[4], nullptr, 10)) : 0;
			e.scope_value = row[5] ? row[5] : "";
			e.chance      = row[6] ? static_cast<uint8_t>(strtoul(row[6], nullptr, 10)) : 50;
			e.loot_tier   = row[7] ? static_cast<uint8_t>(strtoul(row[7], nullptr, 10)) : 2;
			e.set_by      = row[8] ? row[8] : "";
			e.set_at      = row[9] ? strtoll(row[9], nullptr, 10) : 0;

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
		const FabledSeason &e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.id));
		v.push_back(std::to_string(e.active));
		v.push_back(std::to_string(e.start_epoch));
		v.push_back(std::to_string(e.end_epoch));
		v.push_back(std::to_string(e.scope_kind));
		v.push_back("'" + Strings::Escape(e.scope_value) + "'");
		v.push_back(std::to_string(e.chance));
		v.push_back(std::to_string(e.loot_tier));
		v.push_back("'" + Strings::Escape(e.set_by) + "'");
		v.push_back(std::to_string(e.set_at));

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
		const std::vector<FabledSeason> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.id));
			v.push_back(std::to_string(e.active));
			v.push_back(std::to_string(e.start_epoch));
			v.push_back(std::to_string(e.end_epoch));
			v.push_back(std::to_string(e.scope_kind));
			v.push_back("'" + Strings::Escape(e.scope_value) + "'");
			v.push_back(std::to_string(e.chance));
			v.push_back(std::to_string(e.loot_tier));
			v.push_back("'" + Strings::Escape(e.set_by) + "'");
			v.push_back(std::to_string(e.set_at));

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

#endif //EQEMU_BASE_FABLED_SEASON_REPOSITORY_H
