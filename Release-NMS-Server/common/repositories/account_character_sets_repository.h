#ifndef EQEMU_ACCOUNT_CHARACTER_SETS_REPOSITORY_H
#define EQEMU_ACCOUNT_CHARACTER_SETS_REPOSITORY_H

#include "../database.h"
#include "../strings.h"
#include "base/base_account_character_sets_repository.h"
#include "account_character_set_members_repository.h"
#include "account_character_set_limits_repository.h"

class AccountCharacterSetsRepository : public BaseAccountCharacterSetsRepository {
public:

	static std::vector<AccountCharacterSets> GetAccountCharacterSets(Database& db, int32_t account_id) {
		return GetWhere(
			db,
			fmt::format("account_id = {} ORDER BY set_name", account_id)
		);
	}

};

#endif //EQEMU_ACCOUNT_CHARACTER_SETS_REPOSITORY_H