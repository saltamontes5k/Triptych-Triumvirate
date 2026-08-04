#ifndef EQEMU_CHARACTER_PET_NAME_REPOSITORY_H
#define EQEMU_CHARACTER_PET_NAME_REPOSITORY_H

#include "../database.h"
#include "../strings.h"
#include "base/base_character_pet_name_repository.h"

class CharacterPetNameRepository : public BaseCharacterPetNameRepository
{
public:
	// Custom extended repository methods here
	static std::string GetPetName(
		Database &db,
		int character_id,
		int class_id,
		std::string default_name = "") {
		std::string query = fmt::format(
			"SELECT name FROM {} WHERE character_id = {} AND class_id = {} LIMIT 1",
			TableName(),
			character_id,
			class_id);

		auto results = db.QueryDatabase(query);

		if (results.Success() && results.RowCount() > 0) {
			auto row = results.begin();
			// Since we know there's at least one row, we can just check if row[0] is null
			if (row[0]) {
				return row[0];
			}
		}

		return default_name;
	}

	static int SetPetName(
		Database &db,
		int character_id,
		int class_id,
		const std::string &name) {
		CharacterPetName e = NewEntity();
		e.character_id = character_id;
		e.class_id = class_id; // Now this can safely handle larger values since class_id is int32_t
		e.name = name;

		return ReplaceOne(db, e);
	}
};

#endif // EQEMU_CHARACTER_PET_NAME_REPOSITORY_H