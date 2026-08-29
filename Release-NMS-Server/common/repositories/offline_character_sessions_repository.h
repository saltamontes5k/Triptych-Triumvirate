#pragma once

#include "../../common/database.h"
#include "../../common/strings.h"

class OfflineCharacterSessionsRepository {
public:
	struct OfflineCharacterSession {
		uint64_t    id{0};
		uint32_t    account_id{0};
		uint32_t    character_id{0};
		std::string mode{};
		uint32_t    zone_id{0};
		int32_t     instance_id{0};
		uint32_t    entity_id{0};
		time_t      started_at{0};
	};

	static OfflineCharacterSession GetByAccountId(Database &db, uint32 account_id)
	{
		OfflineCharacterSession session{};
		auto results = db.QueryDatabase(
			fmt::format(
				"SELECT id, account_id, character_id, mode, zone_id, instance_id, entity_id, UNIX_TIMESTAMP(started_at) "
				"FROM offline_character_sessions WHERE account_id = {} LIMIT 1",
				account_id
			)
		);

		if (!results.Success() || results.RowCount() == 0) {
			return session;
		}

		auto row = results.begin();
		session.id           = row[0] ? strtoull(row[0], nullptr, 10) : 0;
		session.account_id   = row[1] ? Strings::ToUnsignedInt(row[1]) : 0;
		session.character_id = row[2] ? Strings::ToUnsignedInt(row[2]) : 0;
		session.mode         = row[3] ? row[3] : "";
		session.zone_id      = row[4] ? Strings::ToUnsignedInt(row[4]) : 0;
		session.instance_id  = row[5] ? Strings::ToInt(row[5]) : 0;
		session.entity_id    = row[6] ? Strings::ToUnsignedInt(row[6]) : 0;
		session.started_at   = row[7] ? Strings::ToUnsignedBigInt(row[7]) : 0;

		return session;
	}

	static bool ExistsByAccountId(Database &db, uint32 account_id)
	{
		return GetByAccountId(db, account_id).id != 0;
	}

	static bool Upsert(
		Database &db,
		uint32 account_id,
		uint32 character_id,
		const std::string &mode,
		uint32 zone_id,
		int32 instance_id,
		uint32 entity_id
	)
	{
		auto results = db.QueryDatabase(
			fmt::format(
				"INSERT INTO offline_character_sessions (account_id, character_id, mode, zone_id, instance_id, entity_id, started_at) "
				"VALUES ({}, {}, '{}', {}, {}, {}, NOW()) "
				"ON DUPLICATE KEY UPDATE character_id = VALUES(character_id), mode = VALUES(mode), zone_id = VALUES(zone_id), "
				"instance_id = VALUES(instance_id), entity_id = VALUES(entity_id), started_at = VALUES(started_at)",
				account_id,
				character_id,
				Strings::Escape(mode),
				zone_id,
				instance_id,
				entity_id
			)
		);

		return results.Success();
	}

	static bool DeleteByAccountId(Database &db, uint32 account_id)
	{
		return db.QueryDatabase(
			fmt::format("DELETE FROM offline_character_sessions WHERE account_id = {}", account_id)
		).Success();
	}

	static bool DeleteByCharacterId(Database &db, uint32 character_id)
	{
		return db.QueryDatabase(
			fmt::format("DELETE FROM offline_character_sessions WHERE character_id = {}", character_id)
		).Success();
	}

	static bool Truncate(Database &db)
	{
		return db.QueryDatabase("TRUNCATE TABLE offline_character_sessions").Success();
	}
};
