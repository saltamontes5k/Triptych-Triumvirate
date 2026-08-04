#ifndef EQEMU_ACCOUNT_CHARACTER_SET_MEMBERS_REPOSITORY_H
#define EQEMU_ACCOUNT_CHARACTER_SET_MEMBERS_REPOSITORY_H

#include "../database.h"
#include "../strings.h"
#include "base/base_account_character_set_members_repository.h"

class AccountCharacterSetMembersRepository : public BaseAccountCharacterSetMembersRepository {
public:

	static std::vector<AccountCharacterSetMembers> GetAccountSetMembership(Database& db, uint32 account_id) {
		return GetWhere(db, fmt::format("account_id = {}", account_id));
	}

	static int RemoveCharacterFromAllSets(Database& db, uint32 character_id) {
		return DeleteWhere(db, fmt::format("character_id = {}", character_id));
	}

	static std::vector<uint32> GetCharacterIDsForSet(Database& db, uint32 set_id) {
		auto m = GetWhere(db, fmt::format("set_id = {}", set_id));
		std::vector<uint32> character_ids;

		for (const auto& member : m) {
			character_ids.emplace_back(member.character_id);
		}

		return character_ids;
	}

};

#endif //EQEMU_ACCOUNT_CHARACTER_SET_MEMBERS_REPOSITORY_H