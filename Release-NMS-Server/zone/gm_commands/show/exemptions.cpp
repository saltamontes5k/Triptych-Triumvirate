#include "../../client.h"

void ShowExemptions(Client *c, const Seperator *sep)
{
	const std::string& query = SQL(
		WITH valid_chars AS (
			SELECT
				id,
				name,
				account_id,
				zone_id,
				zone_instance,
				level,
				race,
				class,
				last_login,
				(
					SELECT account_ip.ip
					FROM account_ip
					WHERE account_ip.accid = character_data.account_id
					ORDER BY account_ip.lastused DESC
					LIMIT 1
				) AS account_ip,
				ROW_NUMBER() OVER (PARTITION BY
					(SELECT account.name FROM account WHERE account.id = character_data.account_id LIMIT 1)
					ORDER BY last_login DESC
				) AS account_name_rank
			FROM character_data
			WHERE last_login > (UNIX_TIMESTAMP() - 600)
			AND zone_id != 151
		),
		shared_ips AS (
			SELECT account_ip
			FROM valid_chars
			GROUP BY account_ip
			HAVING COUNT(*) > 1
		)
		SELECT
			vc.name,
			vc.zone_id,
			vc.zone_instance,
			COALESCE(
				(
					SELECT guilds.name FROM guilds WHERE id = (
						(
							SELECT guild_id FROM guild_members WHERE char_id = vc.id
						)
					)
				),
				""
			) AS guild_name,
			vc.level,
			vc.race,
			vc.class,
			COALESCE(
				(
					SELECT account.status FROM account WHERE account.id = vc.account_id LIMIT 1
				),
				0
			) AS account_status,
			COALESCE(
				(
					SELECT account.name FROM account WHERE account.id = vc.account_id LIMIT 1
				),
				0
			) AS account_name,
			vc.account_ip
		FROM
			valid_chars vc
		WHERE
			vc.account_ip IN (SELECT account_ip FROM shared_ips)
			AND vc.account_name_rank = 1
		ORDER BY
			vc.account_ip, vc.name;
	);

	auto results = database.QueryDatabase(query);
	if (!results.Success() || !results.RowCount()) {
		return;
	}

	bool is_filtered = false;
	std::string search_criteria;
	std::stringstream discord_output;

	if (sep->arg[2]) {
		search_criteria = Strings::ToLower(sep->arg[2]);
	}

	uint32 found_count = 0;

	c->Message(Chat::Who, "Players in EverQuest:");
	c->Message(Chat::Who, "------------------------------");

	// Add header to Discord output
	discord_output << "```\n";
	discord_output << "Players in EverQuest:\n";
	discord_output << "------------------------------\n";

	for (auto row : results) {
		const std::string& player_name         = row[0];
		const uint32       zone_id             = Strings::ToUnsignedInt(row[1]);
		const std::string& zone_short_name     = ZoneName(zone_id);
		const std::string& zone_long_name      = ZoneLongName(zone_id);
		const uint8        zone_instance       = Strings::ToUnsignedInt(row[2]);
		const std::string& guild_name          = row[3];
		const uint8        player_level        = Strings::ToUnsignedInt(row[4]);
		const uint16       player_race         = Strings::ToUnsignedInt(row[5]);
		const uint8        player_class        = Strings::ToUnsignedInt(row[6]);
		const uint8        account_status      = Strings::ToUnsignedInt(row[7]);
		const std::string& account_name        = row[8];
		const std::string& account_ip          = row[9];
		const std::string& base_class_name     = GetClassIDName(player_class);
		const std::string& displayed_race_name = GetRaceIDName(player_race);

		if (!search_criteria.empty()) {
			is_filtered = true;

			const bool found = (
				Strings::Contains(Strings::ToLower(player_name), search_criteria) ||
				Strings::Contains(Strings::ToLower(zone_short_name), search_criteria) ||
				Strings::Contains(Strings::ToLower(displayed_race_name), search_criteria) ||
				Strings::Contains(Strings::ToLower(base_class_name), search_criteria) ||
				Strings::Contains(Strings::ToLower(guild_name), search_criteria) ||
				Strings::Contains(Strings::ToLower(account_name), search_criteria) ||
				Strings::Contains(Strings::ToLower(account_ip), search_criteria)
			);

			if (!found) {
				continue;
			}
		}

		std::string displayed_guild_name;
		if (!guild_name.empty()) {
			displayed_guild_name = Saylink::Silent(
				fmt::format(
					"#who \"{}\"",
					guild_name
				),
				fmt::format(
					"<{}>",
					guild_name
				)
			);
		}

		const std::string& goto_saylink = Saylink::Silent(
			fmt::format(
				"#goto {}",
				player_name
			),
			"Goto"
		);

		const std::string& summon_saylink = Saylink::Silent(
			fmt::format(
				"#summon {}",
				player_name
			),
			"Summon"
		);

		const std::string& display_class_name = GetClassIDName(player_class, player_level);

		const std::string& class_saylink = Saylink::Silent(
			fmt::format(
				"#who {}",
				base_class_name
			),
			display_class_name
		);

		const std::string& race_saylink = Saylink::Silent(
			fmt::format(
				"#who {}",
				displayed_race_name
			),
			displayed_race_name
		);

		const std::string& zone_saylink = Saylink::Silent(
			fmt::format(
				"#who {}",
				zone_short_name
			),
			zone_long_name
		);

		const std::string& account_saylink = Saylink::Silent(
			fmt::format(
				"#who {}",
				account_name
			),
			account_name
		);

		const std::string& account_ip_saylink = Saylink::Silent(
			fmt::format(
				"#who {}",
				account_ip
			),
			account_ip
		);

		const std::string& status_level = (
			account_status ?
			fmt::format(
				"* {} * ",
				AccountStatus::GetName(account_status)
			) :
			""
		);

		const std::string& version_string = (
			zone_instance ?
			fmt::format(
				" ({})",
				zone_instance
			) :
			""
		);

		// Format the message for chat
		std::string formatted_message = fmt::format(
			"{}[{} {} ({})] {} ({}) ({}) ({}) {} ZONE: {}{} ({} | {})",
			status_level,
			player_level,
			class_saylink,
			base_class_name,
			player_name,
			race_saylink,
			account_saylink,
			account_ip_saylink,
			displayed_guild_name,
			zone_saylink,
			version_string,
			goto_saylink,
			summon_saylink
		);

		c->Message(Chat::Who, formatted_message.c_str());

		// For Discord, we need a plain text version without saylinks
		std::string discord_message = fmt::format(
			"{}[{} {} ({})] {} ({}) ({}) ({}) {} ZONE: {}{}",
			status_level,
			player_level,
			display_class_name,
			base_class_name,
			player_name,
			displayed_race_name,
			account_name,
			account_ip,
			guild_name.empty() ? "" : fmt::format("<{}>", guild_name),
			zone_long_name,
			version_string
		);

		// Add to Discord output
		discord_output << discord_message << "\n";

		found_count++;
	}

	const std::string& filter_string = is_filtered ? " that match those filters" : "";

	const std::string& message = (
		found_count ?
		fmt::format(
			"There {} {} player{} in EverQuest{}.",
			found_count != 1 ? "are" : "is",
			found_count,
			found_count != 1 ? "s" : "",
			filter_string
		) :
		fmt::format(
			"There are no players in EverQuest{}.",
			filter_string
		)
	);

	c->Message(Chat::Who, message.c_str());

	// Add footer message to Discord output and close code block
	discord_output << "------------------------------\n";
	discord_output << message << "\n";
	discord_output << "```";

	// Send the complete output to Discord
	zone->SendDiscordMessage("ip-exempt", discord_output.str());
}