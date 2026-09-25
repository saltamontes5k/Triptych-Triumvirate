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

#ifndef EQEMU_BASE_FABLED_NPCS_REPOSITORY_H
#define EQEMU_BASE_FABLED_NPCS_REPOSITORY_H

#include "../../database.h"
#include "../../strings.h"
#include <ctime>

class BaseFabledNpcsRepository {
public:
	struct FabledNpcs {
		uint32_t    npc_id;
		std::string era;
		uint8_t     level;
		float       hp_mult;
		float       min_hit_mult;
		float       max_hit_mult;
		uint32_t    npc_spells_id;
		std::string special_abilities_append;
		uint8_t     chance;
		int8_t      enabled;
	};

	static std::string PrimaryKey()
	{
		return std::string("npc_id");
	}

	static std::vector<std::string> Columns()
	{
		return {
			"npc_id",
			"era",
			"level",
			"hp_mult",
			"min_hit_mult",
			"max_hit_mult",
			"npc_spells_id",
			"special_abilities_append",
			"chance",
			"enabled",
		};
	}

	static std::vector<std::string> SelectColumns()
	{
		return {
			"npc_id",
			"era",
			"level",
			"hp_mult",
			"min_hit_mult",
			"max_hit_mult",
			"npc_spells_id",
			"special_abilities_append",
			"chance",
			"enabled",
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
		return std::string("fabled_npcs");
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

	static FabledNpcs NewEntity()
	{
		FabledNpcs e{};

		e.npc_id                   = 0;
		e.era                      = "";
		e.level                    = 0;
		e.hp_mult                  = -1;
		e.min_hit_mult             = -1;
		e.max_hit_mult             = -1;
		e.npc_spells_id            = 0;
		e.special_abilities_append = "";
		e.chance                   = 0;
		e.enabled                  = 1;

		return e;
	}

	static FabledNpcs GetFabledNpcs(
		const std::vector<FabledNpcs> &fabled_npcss,
		int fabled_npcs_id
	)
	{
		for (auto &fabled_npcs : fabled_npcss) {
			if (fabled_npcs.npc_id == fabled_npcs_id) {
				return fabled_npcs;
			}
		}

		return NewEntity();
	}

	static FabledNpcs FindOne(
		Database& db,
		int fabled_npcs_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {} = {} LIMIT 1",
				BaseSelect(),
				PrimaryKey(),
				fabled_npcs_id
			)
		);

		auto row = results.begin();
		if (results.RowCount() == 1) {
			FabledNpcs e{};

			e.npc_id                   = row[0] ? static_cast<uint32_t>(strtoul(row[0], nullptr, 10)) : 0;
			e.era                      = row[1] ? row[1] : "";
			e.level                    = row[2] ? static_cast<uint8_t>(strtoul(row[2], nullptr, 10)) : 0;
			e.hp_mult                  = row[3] ? strtof(row[3], nullptr) : -1;
			e.min_hit_mult             = row[4] ? strtof(row[4], nullptr) : -1;
			e.max_hit_mult             = row[5] ? strtof(row[5], nullptr) : -1;
			e.npc_spells_id            = row[6] ? static_cast<uint32_t>(strtoul(row[6], nullptr, 10)) : 0;
			e.special_abilities_append = row[7] ? row[7] : "";
			e.chance                   = row[8] ? static_cast<uint8_t>(strtoul(row[8], nullptr, 10)) : 0;
			e.enabled                  = row[9] ? static_cast<int8_t>(atoi(row[9])) : 1;

			return e;
		}

		return NewEntity();
	}

	static int DeleteOne(
		Database& db,
		int fabled_npcs_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"DELETE FROM {} WHERE {} = {}",
				TableName(),
				PrimaryKey(),
				fabled_npcs_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int UpdateOne(
		Database& db,
		const FabledNpcs &e
	)
	{
		std::vector<std::string> v;

		auto columns = Columns();

		v.push_back(columns[0] + " = " + std::to_string(e.npc_id));
		v.push_back(columns[1] + " = '" + Strings::Escape(e.era) + "'");
		v.push_back(columns[2] + " = " + std::to_string(e.level));
		v.push_back(columns[3] + " = " + std::to_string(e.hp_mult));
		v.push_back(columns[4] + " = " + std::to_string(e.min_hit_mult));
		v.push_back(columns[5] + " = " + std::to_string(e.max_hit_mult));
		v.push_back(columns[6] + " = " + std::to_string(e.npc_spells_id));
		v.push_back(columns[7] + " = '" + Strings::Escape(e.special_abilities_append) + "'");
		v.push_back(columns[8] + " = " + std::to_string(e.chance));
		v.push_back(columns[9] + " = " + std::to_string(e.enabled));

		auto results = db.QueryDatabase(
			fmt::format(
				"UPDATE {} SET {} WHERE {} = {}",
				TableName(),
				Strings::Implode(", ", v),
				PrimaryKey(),
				e.npc_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static FabledNpcs InsertOne(
		Database& db,
		FabledNpcs e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.npc_id));
		v.push_back("'" + Strings::Escape(e.era) + "'");
		v.push_back(std::to_string(e.level));
		v.push_back(std::to_string(e.hp_mult));
		v.push_back(std::to_string(e.min_hit_mult));
		v.push_back(std::to_string(e.max_hit_mult));
		v.push_back(std::to_string(e.npc_spells_id));
		v.push_back("'" + Strings::Escape(e.special_abilities_append) + "'");
		v.push_back(std::to_string(e.chance));
		v.push_back(std::to_string(e.enabled));

		auto results = db.QueryDatabase(
			fmt::format(
				"{} VALUES ({})",
				BaseInsert(),
				Strings::Implode(",", v)
			)
		);

		if (results.Success()) {
			e.npc_id = results.LastInsertedID();
			return e;
		}

		e = NewEntity();

		return e;
	}

	static int InsertMany(
		Database& db,
		const std::vector<FabledNpcs> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.npc_id));
			v.push_back("'" + Strings::Escape(e.era) + "'");
			v.push_back(std::to_string(e.level));
			v.push_back(std::to_string(e.hp_mult));
			v.push_back(std::to_string(e.min_hit_mult));
			v.push_back(std::to_string(e.max_hit_mult));
			v.push_back(std::to_string(e.npc_spells_id));
			v.push_back("'" + Strings::Escape(e.special_abilities_append) + "'");
			v.push_back(std::to_string(e.chance));
			v.push_back(std::to_string(e.enabled));

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

	static std::vector<FabledNpcs> All(Database& db)
	{
		std::vector<FabledNpcs> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{}",
				BaseSelect()
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			FabledNpcs e{};

			e.npc_id                   = row[0] ? static_cast<uint32_t>(strtoul(row[0], nullptr, 10)) : 0;
			e.era                      = row[1] ? row[1] : "";
			e.level                    = row[2] ? static_cast<uint8_t>(strtoul(row[2], nullptr, 10)) : 0;
			e.hp_mult                  = row[3] ? strtof(row[3], nullptr) : -1;
			e.min_hit_mult             = row[4] ? strtof(row[4], nullptr) : -1;
			e.max_hit_mult             = row[5] ? strtof(row[5], nullptr) : -1;
			e.npc_spells_id            = row[6] ? static_cast<uint32_t>(strtoul(row[6], nullptr, 10)) : 0;
			e.special_abilities_append = row[7] ? row[7] : "";
			e.chance                   = row[8] ? static_cast<uint8_t>(strtoul(row[8], nullptr, 10)) : 0;
			e.enabled                  = row[9] ? static_cast<int8_t>(atoi(row[9])) : 1;

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static std::vector<FabledNpcs> GetWhere(Database& db, const std::string &where_filter)
	{
		std::vector<FabledNpcs> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {}",
				BaseSelect(),
				where_filter
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			FabledNpcs e{};

			e.npc_id                   = row[0] ? static_cast<uint32_t>(strtoul(row[0], nullptr, 10)) : 0;
			e.era                      = row[1] ? row[1] : "";
			e.level                    = row[2] ? static_cast<uint8_t>(strtoul(row[2], nullptr, 10)) : 0;
			e.hp_mult                  = row[3] ? strtof(row[3], nullptr) : -1;
			e.min_hit_mult             = row[4] ? strtof(row[4], nullptr) : -1;
			e.max_hit_mult             = row[5] ? strtof(row[5], nullptr) : -1;
			e.npc_spells_id            = row[6] ? static_cast<uint32_t>(strtoul(row[6], nullptr, 10)) : 0;
			e.special_abilities_append = row[7] ? row[7] : "";
			e.chance                   = row[8] ? static_cast<uint8_t>(strtoul(row[8], nullptr, 10)) : 0;
			e.enabled                  = row[9] ? static_cast<int8_t>(atoi(row[9])) : 1;

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
		const FabledNpcs &e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.npc_id));
		v.push_back("'" + Strings::Escape(e.era) + "'");
		v.push_back(std::to_string(e.level));
		v.push_back(std::to_string(e.hp_mult));
		v.push_back(std::to_string(e.min_hit_mult));
		v.push_back(std::to_string(e.max_hit_mult));
		v.push_back(std::to_string(e.npc_spells_id));
		v.push_back("'" + Strings::Escape(e.special_abilities_append) + "'");
		v.push_back(std::to_string(e.chance));
		v.push_back(std::to_string(e.enabled));

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
		const std::vector<FabledNpcs> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.npc_id));
			v.push_back("'" + Strings::Escape(e.era) + "'");
			v.push_back(std::to_string(e.level));
			v.push_back(std::to_string(e.hp_mult));
			v.push_back(std::to_string(e.min_hit_mult));
			v.push_back(std::to_string(e.max_hit_mult));
			v.push_back(std::to_string(e.npc_spells_id));
			v.push_back("'" + Strings::Escape(e.special_abilities_append) + "'");
			v.push_back(std::to_string(e.chance));
			v.push_back(std::to_string(e.enabled));

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

#endif //EQEMU_BASE_FABLED_NPCS_REPOSITORY_H
