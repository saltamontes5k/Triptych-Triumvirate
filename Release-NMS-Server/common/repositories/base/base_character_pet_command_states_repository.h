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

#ifndef EQEMU_BASE_CHARACTER_PET_COMMAND_STATES_REPOSITORY_H
#define EQEMU_BASE_CHARACTER_PET_COMMAND_STATES_REPOSITORY_H

#include "../../database.h"
#include "../../strings.h"
#include <ctime>

class BaseCharacterPetCommandStatesRepository {
public:
	struct CharacterPetCommandStates {
		int32_t character_id;
		int8_t  pet_class;
		int8_t  command_id;
		int8_t  command_state;
	};

	static std::string PrimaryKey()
	{
		return std::string("character_id");
	}

	static std::vector<std::string> Columns()
	{
		return {
			"character_id",
			"pet_class",
			"command_id",
			"command_state",
		};
	}

	static std::vector<std::string> SelectColumns()
	{
		return {
			"character_id",
			"pet_class",
			"command_id",
			"command_state",
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
		return std::string("character_pet_command_states");
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

	static CharacterPetCommandStates NewEntity()
	{
		CharacterPetCommandStates e{};

		e.character_id  = 0;
		e.pet_class     = 0;
		e.command_id    = 0;
		e.command_state = 0;

		return e;
	}

	static CharacterPetCommandStates GetCharacterPetCommandStates(
		const std::vector<CharacterPetCommandStates> &character_pet_command_statess,
		int character_pet_command_states_id
	)
	{
		for (auto &character_pet_command_states : character_pet_command_statess) {
			if (character_pet_command_states.character_id == character_pet_command_states_id) {
				return character_pet_command_states;
			}
		}

		return NewEntity();
	}

	static CharacterPetCommandStates FindOne(
		Database& db,
		int character_pet_command_states_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {} = {} LIMIT 1",
				BaseSelect(),
				PrimaryKey(),
				character_pet_command_states_id
			)
		);

		auto row = results.begin();
		if (results.RowCount() == 1) {
			CharacterPetCommandStates e{};

			e.character_id  = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.pet_class     = row[1] ? static_cast<int8_t>(atoi(row[1])) : 0;
			e.command_id    = row[2] ? static_cast<int8_t>(atoi(row[2])) : 0;
			e.command_state = row[3] ? static_cast<int8_t>(atoi(row[3])) : 0;

			return e;
		}

		return NewEntity();
	}

	static int DeleteOne(
		Database& db,
		int character_pet_command_states_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"DELETE FROM {} WHERE {} = {}",
				TableName(),
				PrimaryKey(),
				character_pet_command_states_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static int UpdateOne(
		Database& db,
		const CharacterPetCommandStates &e
	)
	{
		std::vector<std::string> v;

		auto columns = Columns();

		v.push_back(columns[0] + " = " + std::to_string(e.character_id));
		v.push_back(columns[1] + " = " + std::to_string(e.pet_class));
		v.push_back(columns[2] + " = " + std::to_string(e.command_id));
		v.push_back(columns[3] + " = " + std::to_string(e.command_state));

		auto results = db.QueryDatabase(
			fmt::format(
				"UPDATE {} SET {} WHERE {} = {}",
				TableName(),
				Strings::Implode(", ", v),
				PrimaryKey(),
				e.character_id
			)
		);

		return (results.Success() ? results.RowsAffected() : 0);
	}

	static CharacterPetCommandStates InsertOne(
		Database& db,
		CharacterPetCommandStates e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.character_id));
		v.push_back(std::to_string(e.pet_class));
		v.push_back(std::to_string(e.command_id));
		v.push_back(std::to_string(e.command_state));

		auto results = db.QueryDatabase(
			fmt::format(
				"{} VALUES ({})",
				BaseInsert(),
				Strings::Implode(",", v)
			)
		);

		if (results.Success()) {
			e.character_id = results.LastInsertedID();
			return e;
		}

		e = NewEntity();

		return e;
	}

	static int InsertMany(
		Database& db,
		const std::vector<CharacterPetCommandStates> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.character_id));
			v.push_back(std::to_string(e.pet_class));
			v.push_back(std::to_string(e.command_id));
			v.push_back(std::to_string(e.command_state));

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

	static std::vector<CharacterPetCommandStates> All(Database& db)
	{
		std::vector<CharacterPetCommandStates> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{}",
				BaseSelect()
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			CharacterPetCommandStates e{};

			e.character_id  = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.pet_class     = row[1] ? static_cast<int8_t>(atoi(row[1])) : 0;
			e.command_id    = row[2] ? static_cast<int8_t>(atoi(row[2])) : 0;
			e.command_state = row[3] ? static_cast<int8_t>(atoi(row[3])) : 0;

			all_entries.push_back(e);
		}

		return all_entries;
	}

	static std::vector<CharacterPetCommandStates> GetWhere(Database& db, const std::string &where_filter)
	{
		std::vector<CharacterPetCommandStates> all_entries;

		auto results = db.QueryDatabase(
			fmt::format(
				"{} WHERE {}",
				BaseSelect(),
				where_filter
			)
		);

		all_entries.reserve(results.RowCount());

		for (auto row = results.begin(); row != results.end(); ++row) {
			CharacterPetCommandStates e{};

			e.character_id  = row[0] ? static_cast<int32_t>(atoi(row[0])) : 0;
			e.pet_class     = row[1] ? static_cast<int8_t>(atoi(row[1])) : 0;
			e.command_id    = row[2] ? static_cast<int8_t>(atoi(row[2])) : 0;
			e.command_state = row[3] ? static_cast<int8_t>(atoi(row[3])) : 0;

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
		const CharacterPetCommandStates &e
	)
	{
		std::vector<std::string> v;

		v.push_back(std::to_string(e.character_id));
		v.push_back(std::to_string(e.pet_class));
		v.push_back(std::to_string(e.command_id));
		v.push_back(std::to_string(e.command_state));

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
		const std::vector<CharacterPetCommandStates> &entries
	)
	{
		std::vector<std::string> insert_chunks;

		for (auto &e: entries) {
			std::vector<std::string> v;

			v.push_back(std::to_string(e.character_id));
			v.push_back(std::to_string(e.pet_class));
			v.push_back(std::to_string(e.command_id));
			v.push_back(std::to_string(e.command_state));

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

#endif //EQEMU_BASE_CHARACTER_PET_COMMAND_STATES_REPOSITORY_H
