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

#ifndef EQEMU_BASE_NMS_WAYPOINTS_DEFAULT_REPOSITORY_H
#define EQEMU_BASE_NMS_WAYPOINTS_DEFAULT_REPOSITORY_H

#include "../../database.h"
#include "../../strings.h"
#include <ctime>

class BaseNmsWaypointsDefaultRepository {
public:
	struct NmsWaypointsDefault {
		int32_t  id;
		int32_t  waypoint_id;
		int32_t  race_id;
		uint32_t class_mask;
		int32_t  min_level;
		int32_t  max_level;
	};

	static std::string PrimaryKey()
	{
		return std::string("id");
	}

	static std::vector<std::string> Columns()
	{
		return {
			"id",
			"waypoint_id",
			"race_id",
			"class_mask",
			"min_level",
			"max_level",
		};
	}

	static std::vector<std::string> SelectColumns()
	{
		return {
			"id",
			"waypoint_id",
			"race_id",
			"class_mask",
			"min_level",
			"max_level",
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
		return std::string("nms_waypoints_default");
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

	static NmsWaypointsDefault NewEntity()
	{
		NmsWaypointsDefault e{};

		e.id          = 0;
		e.waypoint_id = 0;
		e.race_id     = 0;
		e.class_mask  = 65535;
		e.min_level   = 1;
		e.max_level   = 255;

		return e;
	}

	static NmsWaypointsDefault GetNmsWaypointsDefault(
		const std::vector<NmsWaypointsDefault> &nms_waypoints_defaults,
		int nms_waypoints_default_id
	)
	{
		for (auto &nms_waypoints_default : nms_waypoints_defaults) {
			if (nms_waypoints_default.id == nms_waypoints_default_id) {
				return nms_waypoints_default;
			}
		}

		return NewEntity();
	}

	static NmsWaypointsDefault FindOne(
		Database& db,
		int nms_waypoints_default_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {} = {} LIMIT 1",
				BaseSelect(),
				PrimaryKey(),
				nms_waypoints_default_id
			)
		);

		auto row = results.begin();
		if (results.RowCount() == 1) {
			NmsWaypointsDefault e{};

			e.id          = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.waypoint_id = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.race_id     = row[2] ? static_cast<int32_t>(atoi(row[2])) : 0;
			e.class_mask  = row[3] ? static_cast<uint32_t>(strtoul(row[3], nullptr, 10)) : 65535;
			e.min_level   = row[4] ? static_cast<int32_t>(atoi(row[4])) : 1;
			e.max_level   = row[5] ? static_cast<int32_t>(atoi(row[5])) : 255;

			return e;
		}

		return NewEntity();
	}

	static int DeleteOne(
		Database& db,
		int nms_waypoints_default_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"DELETE FROM {} WHERE {} = {}",
				TableName(),
				PrimaryKey(),
				nms_waypoints_default_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int UpdateOne(
		Database& db,
		const NmsWaypointsDefault &e
	)
	{
		std::vector<std::string> v;

		auto columns = Columns();

		v.push_back(columns[1] + " = " + std::to_string(e.waypoint_id));
		v.push_back(columns[2] + " = " + std::to_string(e.race_id));
		v.push_back(columns[3] + " = " + std::to_string(e.class_mask));
		v.push_back(columns[4] + " = " + std::to_string(e.min_level));
		v.push_back(columns[5] + " = " + std::to_string(e.max_level));

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

	static NmsWaypointsDefault InsertOne(
		Database& db,
		NmsWaypointsDefault e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.id));
		v.push_back(std::to_string(e.waypoint_id));
		v.push_back(std::to_string(e.race_id));
		v.push_back(std::to_string(e.class_mask));
		v.push_back(std::to_string(e.min_level));
		v.push_back(std::to_string(e.max_level));

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
		const std::vector<NmsWaypointsDefault> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.id));
			v.push_back(std::to_string(e.waypoint_id));
			v.push_back(std::to_string(e.race_id));
			v.push_back(std::to_string(e.class_mask));
			v.push_back(std::to_string(e.min_level));
			v.push_back(std::to_string(e.max_level));

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

	static std::vector<NmsWaypointsDefault> All(Database& db)
	{
		std::vector<NmsWaypointsDefault> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{}",
				BaseSelect()
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			NmsWaypointsDefault e{};

			e.id          = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.waypoint_id = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.race_id     = row[2] ? static_cast<int32_t>(atoi(row[2])) : 0;
			e.class_mask  = row[3] ? static_cast<uint32_t>(strtoul(row[3], nullptr, 10)) : 65535;
			e.min_level   = row[4] ? static_cast<int32_t>(atoi(row[4])) : 1;
			e.max_level   = row[5] ? static_cast<int32_t>(atoi(row[5])) : 255;

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static std::vector<NmsWaypointsDefault> GetWhere(Database& db, const std::string &where_filter)
	{
		std::vector<NmsWaypointsDefault> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {}",
				BaseSelect(),
				where_filter
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			NmsWaypointsDefault e{};

			e.id          = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.waypoint_id = row[1] ? static_cast<int32_t>(atoi(row[1])) : 0;
			e.race_id     = row[2] ? static_cast<int32_t>(atoi(row[2])) : 0;
			e.class_mask  = row[3] ? static_cast<uint32_t>(strtoul(row[3], nullptr, 10)) : 65535;
			e.min_level   = row[4] ? static_cast<int32_t>(atoi(row[4])) : 1;
			e.max_level   = row[5] ? static_cast<int32_t>(atoi(row[5])) : 255;

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
		const NmsWaypointsDefault &e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.id));
		v.push_back(std::to_string(e.waypoint_id));
		v.push_back(std::to_string(e.race_id));
		v.push_back(std::to_string(e.class_mask));
		v.push_back(std::to_string(e.min_level));
		v.push_back(std::to_string(e.max_level));

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
		const std::vector<NmsWaypointsDefault> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.id));
			v.push_back(std::to_string(e.waypoint_id));
			v.push_back(std::to_string(e.race_id));
			v.push_back(std::to_string(e.class_mask));
			v.push_back(std::to_string(e.min_level));
			v.push_back(std::to_string(e.max_level));

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

#endif //EQEMU_BASE_NMS_WAYPOINTS_DEFAULT_REPOSITORY_H
