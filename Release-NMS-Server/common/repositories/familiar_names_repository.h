#ifndef EQEMU_FAMILIAR_NAMES_REPOSITORY_H
#define EQEMU_FAMILIAR_NAMES_REPOSITORY_H

#include "../database.h"
#include "../strings.h"
#include "base/base_familiar_names_repository.h"

class FamiliarNamesRepository : public BaseFamiliarNamesRepository
{
public:
	static std::vector<std::string> GetFamiliarNamesBySpellID(Database &db, int spell_id) {
		auto familiar_names = FindOne(db, spell_id);
		if (familiar_names.spell_id == 0) {
			return std::vector<std::string>();
		}

		return Strings::Split(familiar_names.name_list, ' ');
	}

	static std::string GetRandomFamiliarName(Database &db, int spell_id, std::string default_name) {
		auto names = GetFamiliarNamesBySpellID(db, spell_id);
		if (names.empty()) {
			return default_name;
		}

		size_t index = static_cast<size_t>(rand()) % names.size();
		return names[index];
	}

	static int GetFamiliarSizeMod(
		Database &db,
		int spell_id) {
		auto entity = FindOne(db, spell_id);
		if (entity.spell_id == 0) {
			return 0;
		}

		return entity.size_mod;
	}

	static FamiliarNames GetRandomFamiliarInfo(Database &db, int spell_id, std::string default_name) {
		auto familiar = FindOne(db, spell_id);
		if (familiar.spell_id == 0) {
			// Return entity with default values
			FamiliarNames default_familiar = NewEntity();
			default_familiar.spell_id = spell_id;
			default_familiar.name_list = default_name;
			default_familiar.size_mod = 0;
			return default_familiar;
		}

		// Split the name list
		auto names = Strings::Split(familiar.name_list, ' ');
		if (names.empty()) {
			// If name list is empty, use default name
			familiar.name_list = default_name;
			return familiar;
		}

		// Get a random name
		size_t index = static_cast<size_t>(rand()) % names.size();
		std::string random_name = names[index];

		// Create new entity with single random name
		FamiliarNames result = familiar;
		result.name_list = random_name;

		return result;
	}
};

#endif // EQEMU_FAMILIAR_NAMES_REPOSITORY_H