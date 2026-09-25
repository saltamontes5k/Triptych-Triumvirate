#include "database_update.h"

std::vector<ManifestEntry> manifest_entries_custom = {
	ManifestEntry{
		.version = 1,
		.description = "2025_05_16_new_database_check_test",
		.check = "SHOW TABLES LIKE 'new_table'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE `new_table`  (
  `id` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
);
)",
		.content_schema_update = false,
	},

	// Content schema tables
	ManifestEntry{
		.version = 2,
		.description = "2025_05_16_nms_waypoints_content_tables",
		.check = "SHOW TABLES LIKE 'nms_waypoints_categories'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE nms_waypoints_categories (
    id INT PRIMARY KEY,
    name VARCHAR(32) NOT NULL UNIQUE
);

CREATE TABLE nms_waypoints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shortname VARCHAR(32) UNIQUE NOT NULL,
    long_name VARCHAR(64) NOT NULL,
    category INT NOT NULL,
    x FLOAT NOT NULL,
    y FLOAT NOT NULL,
    z FLOAT NOT NULL,
    heading FLOAT NOT NULL,
    INDEX idx_nms_waypoints_shortname (shortname),
    INDEX idx_nms_waypoints_category (category)
);

CREATE TABLE nms_waypoints_default (
    id INT AUTO_INCREMENT PRIMARY KEY,
    waypoint_id INT NOT NULL,
    race_id INT NOT NULL DEFAULT 0,
    class_mask INT UNSIGNED NOT NULL DEFAULT 65535,
    min_level INT NOT NULL DEFAULT 1,
    max_level INT NOT NULL DEFAULT 255,
    UNIQUE KEY unique_default_waypoint (waypoint_id, race_id, class_mask, min_level),
    INDEX idx_nms_waypoints_default_race (race_id),
    INDEX idx_nms_waypoints_default_class (class_mask),
    INDEX idx_nms_waypoints_default_level (min_level, max_level)
);
)",
		.content_schema_update = true,
	},

	// PEQ schema tables
	ManifestEntry{
		.version = 3,
		.description = "2025_05_16_nms_waypoints_peq_tables",
		.check = "SHOW TABLES LIKE 'nms_waypoints_character'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE nms_waypoints_character (
    id INT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT UNSIGNED NOT NULL,
    waypoint_id INT NOT NULL,
    unlock_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_character_waypoint (character_id, waypoint_id),
    INDEX idx_nms_waypoints_character_id (character_id)
);

CREATE TABLE nms_waypoints_account (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_id BIGINT UNSIGNED NOT NULL,
    waypoint_id INT NOT NULL,
    unlock_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_account_waypoint (account_id, waypoint_id),
    INDEX idx_nms_waypoints_account_id (account_id)
);
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 4,
		.description = "2025_05_20_nms_zone_npc_update_range",
		.check = "SHOW COLUMNS FROM `zone` LIKE 'npc_update_range'",
		.condition = "empty",
		.match = "",
		.sql = R"(
ALTER TABLE `zone` ADD COLUMN `npc_update_range` int(11) NOT NULL DEFAULT 600 AFTER `npc_max_aggro_dist`;
)",
		.content_schema_update = true,
	},

	ManifestEntry{
		.version = 5,
		.description = "2025_05_20_nms_zone_max_movement_range",
		.check = "SHOW COLUMNS FROM `zone` LIKE 'max_movement_update_range'",
		.condition = "empty",
		.match = "",
		.sql = R"(
ALTER TABLE `zone` ADD COLUMN `max_movement_update_range` int(11) NOT NULL DEFAULT 600 AFTER `npc_update_range`;
)",
		.content_schema_update = true,
	},

	ManifestEntry{
		.version = 6,
		.description = "2025_05_20_nms_global_buffs",
		.check = "SHOW TABLES LIKE 'global_buffs'",
		.condition = "empty",
		.match = "",
		.sql = R"(
create table global_buffs(spell_id int(11) primary key, duration int(11));
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 7,
		.description = "2025_05_20_nms_account_kill_counts",
		.check = "SHOW TABLES LIKE 'account_kill_counts'",
		.condition = "empty",
		.match = "",
		.sql = R"(
create table account_kill_counts(account_id int(11) primary key, race_id int(11), count int(11));
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 8,
		.description = "2025_05_20_nms_character_pet_class_id",
		.check = "SHOW COLUMNS FROM `character_pet_name` LIKE 'class_id'",
		.condition = "empty",
		.match = "",
		.sql = R"(
	ALTER TABLE `character_pet_name`
		DROP PRIMARY KEY,
		ADD COLUMN `class_id` TINYINT(11) NOT NULL DEFAULT -1,
		ADD PRIMARY KEY (`character_id`, `class_id`);
	)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 9,
		.description = "2025_05_20_nms_account_alt_currency",
		.check = "SHOW TABLES LIKE 'account_alt_currency'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE `account_alt_currency` (
  `account_id` int(10) unsigned NOT NULL,
  `currency_id` int(10) unsigned NOT NULL,
  `amount` int(10) unsigned NOT NULL,
  PRIMARY KEY (`account_id`, `currency_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO account_alt_currency (account_id, currency_id, amount)
SELECT
  cd.account_id,
  cac.currency_id,
  SUM(cac.amount) AS amount
FROM character_alt_currency cac
JOIN character_data cd ON cd.id = cac.char_id
GROUP BY cd.account_id, cac.currency_id
ON DUPLICATE KEY UPDATE
  amount = VALUES(amount);
)",
		.content_schema_update = false,
	},

	// New familiar_names table
	ManifestEntry{
		.version = 10,
		.description = "2025_05_20_familiar_names_table",
		.check = "SHOW TABLES LIKE 'familiar_names'",
		.condition = "empty",
		.match = "",
		.sql = R"(
	CREATE TABLE `familiar_names` (
	  `spell_id` int(10) NOT NULL,
	  `name_list` text NOT NULL,
	  `size_mod` int(10) NOT NULL DEFAULT -1,
	  PRIMARY KEY (`spell_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
	)",
		.content_schema_update = true,
	},

	// Alter character_pet_name to change class_id from TINYINT to INT
	ManifestEntry{
		.version = 11,
		.description = "2025_05_20_modify_character_pet_name_class_id",
		.check = "SHOW COLUMNS FROM `character_pet_name` WHERE `Field` = 'class_id' AND `Type` LIKE 'tinyint%'",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
			ALTER TABLE `character_pet_name`
			MODIFY COLUMN `class_id` INT NOT NULL DEFAULT 0
			)",
		.content_schema_update = false,
	},

	// Add character_aa_disabled table
	ManifestEntry{
		.version = 12,
		.description = "2025_05_20_nms_character_aa_disabled",
		.check = "SHOW TABLES LIKE 'character_aa_disabled'",
		.condition = "empty",
		.match = "",
		.sql = R"(
	CREATE TABLE `character_aa_disabled` (
	`aa_id` int(10) NOT NULL,
	`character_id` int(10) NOT NULL,
	`disabled` tinyint(4) NOT NULL,
	PRIMARY KEY (`aa_id`,`character_id`),
	KEY `idx_character_id` (`character_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	)",
		.content_schema_update = false,
	},

	// Add table for pet command states
	ManifestEntry{
		.version = 13,
		.description = "2025_05_26_character_pet_command_states_table",
		.check = "SHOW TABLES LIKE 'character_pet_command_states'",
		.condition = "empty",
		.match = "",
		.sql = R"(
	CREATE TABLE `character_pet_command_states` (
	`character_id` int(10) NOT NULL,
	`pet_class` tinyint(4) NOT NULL,
	`command_id` tinyint(4) NOT NULL,
	`command_state` tinyint(4) NOT NULL,
	PRIMARY KEY (`character_id`,`pet_class`,`command_id`),
	KEY `idx_char_petclass` (`character_id`,`pet_class`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	)",
		.content_schema_update = false,
	},

	// Add character_dynamic_aa_timers table
	ManifestEntry{
		.version = 14,
		.description = "2025_05_27_character_dynamic_aa_timers_table",
		.check = "SHOW TABLES LIKE 'character_dynamic_aa_timers'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE `character_dynamic_aa_timers` (
  `character_id` int(10) NOT NULL,
  `aa_id` int(10) NOT NULL,
  `timer_id` int(10) NOT NULL,
  PRIMARY KEY (`character_id`,`aa_id`),
  UNIQUE KEY `character_id` (`character_id`,`timer_id`),
  KEY `aa_id` (`aa_id`),
  KEY `timer_id` (`timer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
)",
		.content_schema_update = false,
	},

/*
	// Create account_character_sets table
	ManifestEntry{
		.version = 15,
		.description = "2025_05_23_create_account_character_sets_table",
		.check = "SHOW TABLES LIKE 'account_character_sets'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE `account_character_sets` (
	`account_id` int(11) NOT NULL,
	`set_id` int(11) NOT NULL,
	`set_name` varchar(255) NOT NULL,
	`created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`account_id`, `set_id`),
	UNIQUE KEY `unique_account_set_name` (`account_id`, `set_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
)",
		.content_schema_update = false,
	},

	// Create account_character_set_members table
	ManifestEntry{
		.version = 16,
		.description = "2025_05_23_create_account_character_set_members_table",
		.check = "SHOW TABLES LIKE 'account_character_set_members'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE `account_character_set_members` (
	`account_id` int(11) NOT NULL,
	`set_id` int(11) NOT NULL,
	`character_id` int(11) NOT NULL,
	PRIMARY KEY (`account_id`, `set_id`, `character_id`),
	INDEX `idx_set_id` (`set_id`),
	INDEX `idx_character_id` (`character_id`),
	INDEX `idx_account_set` (`account_id`, `set_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
)",
		.content_schema_update = false,
	},

	// Create limits table
	ManifestEntry{
		.version = 17,
		.description = "2025_05_23_create_account_character_set_limits_table",
		.check = "SHOW TABLES LIKE 'account_character_set_limits'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE `account_character_set_limits` (
	`account_id` int(11) NOT NULL,
	`eom_sets` int(11) NOT NULL DEFAULT 0,
	`bonus_sets` int(11) NOT NULL DEFAULT 0,
	`default_set` int(11) NOT NULL DEFAULT 0,
	`eom_slots` int(11) NOT NULL DEFAULT 0,
	`bonus_slots` int(11) NOT NULL DEFAULT 0,
	PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
	)",
	},
*/

	ManifestEntry{
		.version = 18,
		.description = "2026_06_13_update_aa339_whitelist_and_logs.sql",
		.check = "SELECT `rule_value` FROM `rule_values` WHERE `rule_name` = 'Custom:AA339Whitelist'",
		.condition = "missing",
		.match = "aa516",
		.sql = R"(
-- Upsert, not UPDATE: on a DB where the rule row does not exist yet, a bare UPDATE matches
-- zero rows and silently does nothing (this bit us in production - see versions 30-32).
INSERT INTO rule_values (ruleset_id, rule_name, rule_value, notes)
VALUES (1, 'Custom:AA339Whitelist', '16121,16122,16123,16675,16676,16677,30887,30888,30889,aa545,aa516,aa861,aa8332,8165,8166,8167,8168,8169', 'AA339 whitelist')
ON DUPLICATE KEY UPDATE rule_value = VALUES(rule_value);

UPDATE logsys_categories 
SET log_to_file = 0 
WHERE log_category_description NOT IN ('Error', 'Warning', 'Crash', 'MySQL Error', 'QuestErrors');

-- 1. Create the Custom NPC (Female Vah Shir)
INSERT INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, hp_regen_rate, hp_regen_per_second, mana_regen_rate, loottable_id, merchant_id, STR, STA, DEX, AGI, _INT, WIS, CHA, npc_faction_id, face)
VALUES (1120001300, 'A_Beastlord_Spell_Merchant', 'Spells 51-60', 60, 130, 41, 1, 1000, 1000, 1, 1, 0, 7, 0, 0, 0, 0, 1120001300, 75, 75, 75, 75, 75, 75, 75, 0, 3)
ON DUPLICATE KEY UPDATE class=VALUES(class), race=VALUES(race), gender=VALUES(gender), texture=VALUES(texture), size=VALUES(size), face=VALUES(face);

-- 2. Populate the Level 51-60 Merchantlist (38 scrolls)
INSERT INTO merchantlist (merchantid, slot, item) VALUES
(1120001300, 1, 15063),  -- Spell: Resist Disease (51)
(1120001300, 2, 15046),  -- Spell: Ultravision (51)
(1120001300, 3, 7740),   -- Spell: Spirit of Wind (51)
(1120001300, 4, 19363),  -- Spell: Summon: Muzzle of Mardu (51)
(1120001300, 5, 19499),  -- Spell: Spiritual Radiance (52)
(1120001300, 6, 7722),   -- Spell: Aid of Khurenz (52)
(1120001300, 7, 15435),  -- Spell: Venom of the Snake (52)
(1120001300, 8, 15161),  -- Spell: Health (52)
(1120001300, 9, 7741),   -- Spell: Spirit of the Storm (53)
(1120001300, 10, 15167), -- Spell: Talisman of Tnarg (53)
(1120001300, 11, 15152), -- Spell: Deftness (53)
(1120001300, 12, 26957), -- Spell: Ice Shard (54)
(1120001300, 13, 19531), -- Spell: Spirit of Snow (54)
(1120001300, 14, 7723),  -- Spell: Spirit of Omakin (54)
(1120001300, 15, 15062), -- Spell: Resist Poison (54)
(1120001300, 16, 15153), -- Spell: Furious Strength (54)
(1120001300, 17, 15145), -- Spell: Chloroplast (55)
(1120001300, 18, 7724),  -- Spell: Sha's Restoration (55)
(1120001300, 19, 15163), -- Spell: Incapacitate (56)
(1120001300, 20, 7726),  -- Spell: Spirit of Zehkes (56)
(1120001300, 21, 15431), -- Spell: Shifting Shield (56)
(1120001300, 22, 19530), -- Spell: Spirit of Flame (56)
(1120001300, 23, 15157), -- Spell: Dexterity (57)
(1120001300, 24, 15158), -- Spell: Stamina (57)
(1120001300, 25, 15015), -- Spell: Greater Healing (57)
(1120001300, 26, 15049), -- Spell: Nullify Magic (58)
(1120001300, 27, 59617), -- Spell: Guard of Calliav (58)
(1120001300, 28, 7727),  -- Spell: Spirit of Khurenz (58)
(1120001300, 29, 15168), -- Spell: Talisman of Altuna (58)
(1120001300, 30, 15510), -- Spell: Blizzard Blast (59)
(1120001300, 31, 7729),  -- Spell: Spiritual Purity (59)
(1120001300, 32, 19507), -- Spell: Chloroblast (59)
(1120001300, 33, 7728),  -- Spell: Sha's Ferocity (59)
(1120001300, 34, 15170), -- Spell: Alacrity (60)
(1120001300, 35, 7730),  -- Spell: Spiritual Strength (60)
(1120001300, 36, 19537), -- Spell: Savagery (60)
(1120001300, 37, 7731),  -- Spell: Spirit of Khati Sha (60)
(1120001300, 38, 19538)
ON DUPLICATE KEY UPDATE item=VALUES(item);

-- 3. Create Spawngroups
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
VALUES ('fv_Beastlord_Spell_Merchant', 1, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
       ('ot_Beastlord_Spell_Merchant', 1, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0)
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 4. Link Spawngroups to Custom NPC
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES
((SELECT id FROM spawngroup WHERE name = 'fv_Beastlord_Spell_Merchant'), 1120001300, 100),
((SELECT id FROM spawngroup WHERE name = 'ot_Beastlord_Spell_Merchant'), 1120001300, 100)
ON DUPLICATE KEY UPDATE chance=VALUES(chance);

-- 5. Place in Zones (spawn2)
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation) VALUES
((SELECT id FROM spawngroup WHERE name = 'fv_Beastlord_Spell_Merchant'), 'firiona', 0, -3356.63, 388.16, 158.98, 87.75, 640, 0, 0, 0, 0, 1, 0),
((SELECT id FROM spawngroup WHERE name = 'ot_Beastlord_Spell_Merchant'), 'overthere', 0, 2341.93, 2809.66, -51.22, 195, 640, 0, 0, 0, 0, 1, 0)
ON DUPLICATE KEY UPDATE spawngroupID=VALUES(spawngroupID);

-- 6. Update Uggrig Skullchomper to be a Beastlord GM (Class 34)
UPDATE npc_types SET class = 34 WHERE id = 93152;

-- 7. Update Quegmor O`Cranic to be a Beastlord GM (Class 34) and move/ensure spawn
UPDATE npc_types SET class = 34 WHERE id = 84202;
UPDATE spawn2 SET x = -3311.55, y = 415.63, z = 158.89, heading = 373 WHERE id = 14745;
UPDATE spawnentry SET chance = 100 WHERE spawngroupID = 9696 AND npcID = 84202;
)",
		.content_schema_update = false,
	},
	ManifestEntry{
		.version = 19,
		.description = "2026_06_27_fix_broken_npc_factions.sql",
		.check = "SELECT npc_faction_id FROM npc_types WHERE id = 46016",
		.condition = "match",
		.match = "19471",
		.sql = R"(
UPDATE npc_types SET npc_faction_id = 929 WHERE id IN (46016, 46017, 46061, 46089);
UPDATE npc_types SET npc_faction_id = 79 WHERE id = 2000507;
UPDATE rule_values SET rule_value = '1.0' WHERE rule_name = 'Merchant:BuyCostMod';
UPDATE db_str SET value = 'This passive ability grants you a chance to have your damage over time spells hit for additional damage. Each level increases both the chance and amount of damage.' WHERE id = 15594 AND type = 4;
)",
		.content_schema_update = true,
	},
	ManifestEntry{
		.version = 20,
		.description = "2026_07_01_bazaar_spawn_sateal.sql",
		.check = "SELECT id FROM npc_types WHERE name = 'Sateal_Deirosap' AND lastname = 'Smithing Supplies'",
		.condition = "empty",
		.match = "",
		.sql = R"(
-- 1. Spawn Sateal Deirosap in Bazaar version 0 (Classic Bazaar)
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`)
VALUES (111116, 'bazaar', 0, -38.000000, -676.000000, 4.750000, 126.000000, 640, 0, 0, 0, 1);

-- 2. Update Sateal's title to "Smithing Supplies"
UPDATE `npc_types` SET `lastname` = 'Smithing Supplies' WHERE `name` = 'Sateal_Deirosap';

-- 3. Update Yekan's Quickening scroll base price to target 1p 4g final merchant price (667 copper base)
UPDATE items SET price = 667 WHERE id = 7719;
)",
		.content_schema_update = true,
	},

	ManifestEntry{
		.version = 21,
		.description = "2026_07_12_bazaar_aa_and_data_fixes.sql",
		.check = "SELECT 1",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
-- The Bazaar is a trade hub but was the only hub with combat enabled (cancombat = 1); PoK,
-- Nexus, Guild Lobby and Plane of Tranquility are all cancombat = 0. That let players kill
-- NPCs (and each other) in the Bazaar. Flag it safe like the other hubs (covers both version
-- rows). IsAttackAllowed() gates all melee on zone->CanDoCombat().
UPDATE `zone` SET `cancombat` = 0 WHERE `short_name` = 'bazaar';

-- Hastened Gathering ranks 4 and 5 (custom ranks 12899/12900) reduced Gather Mana to nothing.
--
-- SE_HastenedAASkill (SPA 264) reductions are FLAT SECONDS, and each Hastened Gathering rank carries
-- two effect slots: slot 1 targets Gather Mana (aa_ability 57, base recast 3600s) and slot 2 targets
-- Mana Draw (616), whose upgraded ranks are 8640s. The custom ranks were scaled for the 8640s target
-- -- 3456 is ~40% of 8640, but 96% of 3600. So rank 4 cut Gather Mana to 144s and rank 5 (-4320)
-- exceeded its base entirely, clamping the timer to 0 and making it free.
--
-- Slot 1 only ever affects Gather Mana (GetAlternateAdvancementCooldownReduction filters on
-- limit_value), so rescaling it leaves the Mana Draw side untouched. The vanilla ranks step +400/rank
-- against the 3600s base (400/800/1200); 1600/2000 continue that line, giving 33 and 27 minutes.
-- Vanilla ranks 471/472/473 are deliberately NOT touched -- they are correct.
--
-- Dormant when written (both ranks are level_req 80; the cap is well below that), fixed now so it
-- cannot surprise us at the next expansion bump.
UPDATE `aa_rank_effects` SET `base1` = 1600 WHERE `rank_id` = 12899 AND `slot` = 1 AND `base2` = 57;
UPDATE `aa_rank_effects` SET `base1` = 2000 WHERE `rank_id` = 12900 AND `slot` = 1 AND `base2` = 57;

-- aa_ranks 12900 pointed next_id at rank 12901, which does not exist. Harmless (the chain just ends)
-- but it leaves a dangling reference in the rank list.
UPDATE `aa_ranks` SET `next_id` = -1 WHERE `id` = 12900;

-- Move the Firiona Vie Beastlord trainer and spell merchant out of the drolvarg camp, into the city.
--
-- This REVERSES a placement made by v21's own predecessor. Version 18 (above, "7. Update Quegmor
-- O`Cranic to be a Beastlord GM") made Quegmor a Beastlord GM -- he is not one in stock PEQ -- and
-- parked him at (-3311.55, 415.63, z=158.89), then placed the new Beastlord Spell Merchant beside him
-- at (-3356.63, 388.16, z=158.98).
--
-- Those coordinates are the ABANDONED pre-revamp Firiona Vie outpost. Firiona Vie was revamped and the
-- outpost moved south to z = -76; roughly 30 drolvarg now spawn on the old site. Evidence the south is
-- the live city: it holds 64 of the zone's 68 doors, has ~4x the map geometry, contains the zone's safe
-- point (1440, -2392), and is where 28 of the 30 named city NPCs already stand.
--
-- So Beastlords were the only class that had to fight through a mob camp to train or buy spells -- and
-- this merchant carries ALL 38 Beastlord scrolls, making that camp the only source in the zone. Every
-- other class trains and buys in the city.
--
-- Why v18 chose those coordinates: the common Firiona Vie map packs still label the OLD outpost with
-- the city's NPC names (their geometry was updated after the revamp; their hand-maintained label files
-- never were). The map says "town" there. It is wrong, and it is almost certainly the original source
-- of this bug.
--
-- The two UPDATEs target differently ON PURPOSE -- do not "clean this up" into one style:
--   * Quegmor's spawn2 row is stock PEQ data, so id 14745 is identical on every server. v18 relies on
--     this exact assumption one entry above, so it is proven on real installs.
--   * The merchant's spawn2 row is INSERTed by v18, so its id comes from AUTO_INCREMENT and WILL differ
--     per server (it is 3388065 on dev -- meaningless anywhere else). It must be resolved through its
--     spawngroup name, exactly as v18 inserts it. A hardcoded id here would silently move the wrong
--     spawn, or nothing at all.
--
-- Ordering is safe either way: the manifest applies versions in ascending order, so on a fresh install
-- v18 creates these at the old coordinates and v21 immediately corrects them; on a server already past
-- v18, v21 corrects them in place.
UPDATE spawn2 SET x = 2794.85, y = -3350.75, z = -76.12, heading = 385.5
  WHERE id = 14745;
UPDATE spawn2 SET x = 2810.72, y = -3378.81, z = -76.12, heading = 380.75
  WHERE spawngroupID IN (SELECT id FROM spawngroup WHERE name = 'fv_Beastlord_Spell_Merchant');

-- Remove "Boomerang of Wonders" and its variants. Its model (idfile IT11383) exists in NO RoF2-era
-- client -- not even the newest reference client -- so it always rendered empty-handed. It is also
-- completely unreachable in-game: not in any loot table, merchant, tradeskill recipe, quest, or plugin,
-- and the Purveyor of Glamour cannot produce its glamour. The hand-in path needs the base item, which
-- is unobtainable; the random-glamour path (get_random_glamour) skips it because it is a RANGE-slot
-- (2048) item with itemtype 10, while that query only accepts range items with itemtype 5. So these
-- four rows are pure orphaned data. Deletes base (109036), Enchanted (1109036), Legendary (2109036)
-- and the Glamour ornament (704681).
DELETE FROM items WHERE id IN (109036, 1109036, 2109036, 704681);

-- Move the Bazaar safe point OUT of the PVP arena. Rebuilding the .map files activated the RoF2 client's
-- hardcoded arena PVP region (fun, intended), but the old safe point sat inside it -- so anyone returned
-- to the safe point (AFK camp, /unstuck, failed feign, some ports) landed flagged for PVP in the pit.
-- New spot is by the Shadowhaven entrance, well clear of the arena. Updates BOTH bazaar rows (v0 default
-- and v1 map_file_name='bazaar_old') so whichever version the server boots is safe.
UPDATE zone SET safe_x = -134.13, safe_y = -815.98, safe_z = 3.75, safe_heading = 70.25
  WHERE short_name = 'bazaar';
)",
		.content_schema_update = false,
	},

	// ------------------------------------------------------------------------------------------------
	// Version 22: REPAIR PASS for the v21 rollout.
	//
	// v21 originally shipped as one multi-statement entry whose check only tested its FIRST
	// statement. Any failure after statement 1 - such as a MariaDB-only collation on other
	// engines - killed world mid-update; on restart the check passed, the whole entry was
	// skipped, and custom_version was stamped past it with the rest of the payload silently missing.
	// This entry re-delivers the v19/v21 data payloads behind an always-run check, so a healthy
	// server converges to the same values and a half-applied server gets the missing pieces.
	//
	// RULES (see also the header of this file):
	//  * ONE entry per version. The runner queues one apply-round per matching entry, and each
	//    round runs EVERY entry of that version - two entries sharing a version each execute twice.
	//  * Universal SQL only. No MariaDB-only syntax (uca1400 collations, ADD COLUMN IF NOT EXISTS).
	//  * The check must guard the exact SQL in the same entry, never a neighbor's.
	//  * Additive/idempotent only in repairs - no DROP/TRUNCATE/DELETE of player data.
	// ------------------------------------------------------------------------------------------------

	// DATA RESYNC. Re-delivers every data payload from v19 and v21 that a half-applied server may
	// have lost. The check is "SELECT 1" so it always runs ONCE during the bump to this version -
	// that is safe precisely because every statement here is idempotent DML (INSERT IGNORE or an
	// UPDATE that converges to the same values) and cannot error on any schema state. A server
	// that already has all of it is rewritten to the identical values; a half-applied server gets
	// the missing pieces. NO DDL in this entry, ever - DDL belongs in its own guarded entry.
	//
	// Deliberately NOT re-delivered:
	//   * v21's DELETE of the Boomerang of Wonders items - destructive, each operator's call.
	//   * v18's AA339 whitelist - INSERT IGNORE only, so an operator's tuned value is respected.
	ManifestEntry{
		.version = 22,
		.description = "2026_07_19_resync_v19_v21_data_payload",
		.check = "SELECT 1",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
-- v21: Bazaar is a no-combat hub like PoK/Nexus/Guild Lobby/PoT (covers both version rows).
UPDATE `zone` SET `cancombat` = 0 WHERE `short_name` = 'bazaar';

-- v21: Hastened Gathering ranks 4/5 rescale (custom ranks 12899/12900, Gather Mana slot only -
-- base2 = 57). The old values were scaled against Mana Draw's 8640s base instead of Gather
-- Mana's 3600s, making rank 5 free. Vanilla ranks 471-473 are correct and untouched.
UPDATE `aa_rank_effects` SET `base1` = 1600 WHERE `rank_id` = 12899 AND `slot` = 1 AND `base2` = 57;
UPDATE `aa_rank_effects` SET `base1` = 2000 WHERE `rank_id` = 12900 AND `slot` = 1 AND `base2` = 57;

-- v21: rank 12900 pointed next_id at nonexistent 12901.
UPDATE `aa_ranks` SET `next_id` = -1 WHERE `id` = 12900;

-- v21: Firiona Vie Beastlord trainer + spell merchant out of the drolvarg camp, into the live
-- city (see the v21 entry for the full story). Quegmor's row is stock PEQ so id 14745 is the
-- same everywhere; the merchant's row is v18-inserted so it MUST resolve via spawngroup name
-- (its AUTO_INCREMENT id differs per server). IN, not =, so a duplicated group name can never
-- turn this into a fatal 1242 multi-row error.
UPDATE spawn2 SET x = 2794.85, y = -3350.75, z = -76.12, heading = 385.5
  WHERE id = 14745;
UPDATE spawn2 SET x = 2810.72, y = -3378.81, z = -76.12, heading = 380.75
  WHERE spawngroupID IN (SELECT id FROM spawngroup WHERE name = 'fv_Beastlord_Spell_Merchant');

-- v21: Bazaar safe point out of the PVP arena (both bazaar rows).
UPDATE zone SET safe_x = -134.13, safe_y = -815.98, safe_z = 3.75, safe_heading = 70.25
  WHERE short_name = 'bazaar';

-- v19 orphans: v19's check tests the npc faction its first statement fixes, so on any server
-- whose dump already carried faction 929 the WHOLE entry was skipped and these never applied.
UPDATE npc_types SET npc_faction_id = 929 WHERE id IN (46016, 46017, 46061, 46089);
UPDATE npc_types SET npc_faction_id = 79 WHERE id = 2000507;
UPDATE rule_values SET rule_value = '1.0' WHERE rule_name = 'Merchant:BuyCostMod';
UPDATE db_str SET value = 'This passive ability grants you a chance to have your damage over time spells hit for additional damage. Each level increases both the chance and amount of damage.' WHERE id = 15594 AND type = 4;
)",
		.content_schema_update = false,
	},

	// ------------------------------------------------------------------------------------------------
	// Versions 23-25: REPAIR PASS for the v18 rollout.
	//
	// Found 2026-07-19 on a community server: db_version.custom_version was stamped >= 18 while the
	// DATA predated v18 entirely (baseline dump cut in the window where version stamp and content
	// were out of sync on dev). The runner only evaluates entries ABOVE the stored version, so v18
	// was never looked at again - no Beastlord spell merchant, no scrolls, no spawns, GMs left at
	// stock class, whitelist without aa516. Discovered only because v22's FV-merchant move returned
	// zero rows. These re-deliver v18's payload behind checks that test the CONTENT (never the
	// version), so healthy servers no-op through all of them. Same recipe as the v22 resync above.
	//
	// Same rules as always: one entry per version, universal SQL only, checks guard their own SQL,
	// everything idempotent.
	// ------------------------------------------------------------------------------------------------

	// v18's Beastlord spell merchant NPC + all 38 scrolls (51-60).
	// The check tests the LAST merchantlist row, not the NPC: if a run dies between the two
	// statements, the check still reads missing and the whole entry re-runs (both statements are
	// ON DUPLICATE KEY idempotent), instead of the NPC's existence masking an empty merchant list.
	ManifestEntry{
		.version = 23,
		.description = "2026_07_19_repair_v18_beastlord_merchant_and_scrolls",
		.check = "SELECT item FROM merchantlist WHERE merchantid = 1120001300 AND slot = 38",
		.condition = "empty",
		.match = "",
		.sql = R"(
INSERT INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, hp_regen_rate, hp_regen_per_second, mana_regen_rate, loottable_id, merchant_id, STR, STA, DEX, AGI, _INT, WIS, CHA, npc_faction_id, face)
VALUES (1120001300, 'A_Beastlord_Spell_Merchant', 'Spells 51-60', 60, 130, 41, 1, 1000, 1000, 1, 1, 0, 7, 0, 0, 0, 0, 1120001300, 75, 75, 75, 75, 75, 75, 75, 0, 3)
ON DUPLICATE KEY UPDATE class=VALUES(class), race=VALUES(race), gender=VALUES(gender), texture=VALUES(texture), size=VALUES(size), face=VALUES(face);

INSERT INTO merchantlist (merchantid, slot, item) VALUES
(1120001300, 1, 15063),  -- Spell: Resist Disease (51)
(1120001300, 2, 15046),  -- Spell: Ultravision (51)
(1120001300, 3, 7740),   -- Spell: Spirit of Wind (51)
(1120001300, 4, 19363),  -- Spell: Summon: Muzzle of Mardu (51)
(1120001300, 5, 19499),  -- Spell: Spiritual Radiance (52)
(1120001300, 6, 7722),   -- Spell: Aid of Khurenz (52)
(1120001300, 7, 15435),  -- Spell: Venom of the Snake (52)
(1120001300, 8, 15161),  -- Spell: Health (52)
(1120001300, 9, 7741),   -- Spell: Spirit of the Storm (53)
(1120001300, 10, 15167), -- Spell: Talisman of Tnarg (53)
(1120001300, 11, 15152), -- Spell: Deftness (53)
(1120001300, 12, 26957), -- Spell: Ice Shard (54)
(1120001300, 13, 19531), -- Spell: Spirit of Snow (54)
(1120001300, 14, 7723),  -- Spell: Spirit of Omakin (54)
(1120001300, 15, 15062), -- Spell: Resist Poison (54)
(1120001300, 16, 15153), -- Spell: Furious Strength (54)
(1120001300, 17, 15145), -- Spell: Chloroplast (55)
(1120001300, 18, 7724),  -- Spell: Sha's Restoration (55)
(1120001300, 19, 15163), -- Spell: Incapacitate (56)
(1120001300, 20, 7726),  -- Spell: Spirit of Zehkes (56)
(1120001300, 21, 15431), -- Spell: Shifting Shield (56)
(1120001300, 22, 19530), -- Spell: Spirit of Flame (56)
(1120001300, 23, 15157), -- Spell: Dexterity (57)
(1120001300, 24, 15158), -- Spell: Stamina (57)
(1120001300, 25, 15015), -- Spell: Greater Healing (57)
(1120001300, 26, 15049), -- Spell: Nullify Magic (58)
(1120001300, 27, 59617), -- Spell: Guard of Calliav (58)
(1120001300, 28, 7727),  -- Spell: Spirit of Khurenz (58)
(1120001300, 29, 15168), -- Spell: Talisman of Altuna (58)
(1120001300, 30, 15510), -- Spell: Blizzard Blast (59)
(1120001300, 31, 7729),  -- Spell: Spiritual Purity (59)
(1120001300, 32, 19507), -- Spell: Chloroblast (59)
(1120001300, 33, 7728),  -- Spell: Sha's Ferocity (59)
(1120001300, 34, 15170), -- Spell: Alacrity (60)
(1120001300, 35, 7730),  -- Spell: Spiritual Strength (60)
(1120001300, 36, 19537), -- Spell: Savagery (60)
(1120001300, 37, 7731),  -- Spell: Spirit of Khati Sha (60)
(1120001300, 38, 19538)
ON DUPLICATE KEY UPDATE item=VALUES(item);
)",
		.content_schema_update = false,
	},

	// v18's spawn groups / entries / world placement for the merchant, both zones.
	// Every statement is INSERT ... SELECT ... WHERE NOT EXISTS (v18's ON DUPLICATE KEY UPDATE on
	// spawngroup was a NO-OP guard - spawngroup.name has no unique index, so a re-run duplicated
	// rows and then every name-subquery in later entries became a fatal 1242 multi-row error).
	// The Firiona Vie spawn goes DIRECTLY at the corrected city location (v22's coordinates) -
	// re-creating v18's drolvarg-camp placement just for v22 to have already run would plant the
	// merchant in the wrong spot with nothing left to move him.
	// Check = the LAST artifact created (overthere spawn2): any partial death re-runs the entry;
	// WHERE NOT EXISTS makes the re-run clean.
	ManifestEntry{
		.version = 24,
		.description = "2026_07_19_repair_v18_beastlord_merchant_spawns",
		.check = "SELECT s.id FROM spawn2 s WHERE s.spawngroupID IN (SELECT id FROM spawngroup WHERE name = 'ot_Beastlord_Spell_Merchant')",
		.condition = "empty",
		.match = "",
		.sql = R"(
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
SELECT 'fv_Beastlord_Spell_Merchant', 1, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM spawngroup WHERE name = 'fv_Beastlord_Spell_Merchant');

INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
SELECT 'ot_Beastlord_Spell_Merchant', 1, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM spawngroup WHERE name = 'ot_Beastlord_Spell_Merchant');

INSERT INTO spawnentry (spawngroupID, npcID, chance)
SELECT sg.id, 1120001300, 100 FROM spawngroup sg
WHERE sg.name = 'fv_Beastlord_Spell_Merchant'
  AND NOT EXISTS (SELECT 1 FROM spawnentry se WHERE se.spawngroupID = sg.id AND se.npcID = 1120001300);

INSERT INTO spawnentry (spawngroupID, npcID, chance)
SELECT sg.id, 1120001300, 100 FROM spawngroup sg
WHERE sg.name = 'ot_Beastlord_Spell_Merchant'
  AND NOT EXISTS (SELECT 1 FROM spawnentry se WHERE se.spawngroupID = sg.id AND se.npcID = 1120001300);

INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation)
SELECT sg.id, 'firiona', 0, 2810.72, -3378.81, -76.12, 380.75, 640, 0, 0, 0, 0, 1, 0 FROM spawngroup sg
WHERE sg.name = 'fv_Beastlord_Spell_Merchant'
  AND NOT EXISTS (SELECT 1 FROM spawn2 s WHERE s.spawngroupID = sg.id);

INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation)
SELECT sg.id, 'overthere', 0, 2341.93, 2809.66, -51.22, 195, 640, 0, 0, 0, 0, 1, 0 FROM spawngroup sg
WHERE sg.name = 'ot_Beastlord_Spell_Merchant'
  AND NOT EXISTS (SELECT 1 FROM spawn2 s WHERE s.spawngroupID = sg.id);
)",
		.content_schema_update = false,
	},

	// v18's remaining data payload, always-run-once (same pattern as v22): every statement is
	// idempotent DML that converges to the same values, so re-application is harmless and nothing
	// can be skipped by a half-applied state.
	ManifestEntry{
		.version = 25,
		.description = "2026_07_19_resync_v18_data_payload",
		.check = "SELECT 1",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
-- AA339 whitelist as an UPSERT - v18's bare UPDATE silently no-opped on servers where the rule row
-- did not exist, which is exactly how the whitelist ended up without aa516 in the wild.
INSERT INTO rule_values (ruleset_id, rule_name, rule_value, notes)
VALUES (1, 'Custom:AA339Whitelist', '16121,16122,16123,16675,16676,16677,30887,30888,30889,aa545,aa516,aa861,aa8332,8165,8166,8167,8168,8169', 'AA339 whitelist')
ON DUPLICATE KEY UPDATE rule_value = VALUES(rule_value);

-- Uggrig Skullchomper / Quegmor O`Cranic -> Beastlord GMs (class 34), as v18 intended.
UPDATE npc_types SET class = 34 WHERE id IN (93152, 84202);

-- Quegmor's spawn entry always up (v18 step 7). His spawn2 position move is v22's job.
UPDATE spawnentry SET chance = 100 WHERE spawngroupID = 9696 AND npcID = 84202;

-- Log noise reduction (v18 step 2).
UPDATE logsys_categories
SET log_to_file = 0
WHERE log_category_description NOT IN ('Error', 'Warning', 'Crash', 'MySQL Error', 'QuestErrors');
)",
		.content_schema_update = false,
	},

	// v26: Armour glamour NPC for the Bazaar - companion to weapon glamour Purveyor.
	// Creates npc_types 1120001110, spawngroup 5003550, spawn2 2141650.
	// Check: skip if NPC already exists.
	ManifestEntry{
		.version = 26,
		.description = "2026_08_26_bazaar_armour_glamour_npc",
		.check = "SELECT id FROM npc_types WHERE name = 'Purveyor_of_Armour_Glamour'",
		.condition = "empty",
		.match = "",
		.sql = R"(
INSERT INTO npc_types (
	id, name, lastname, level, race, class, bodytype, hp, mana,
	gender, texture, helmtexture, size, hp_regen_rate, mana_regen_rate,
	loottable_id, merchant_id, npc_faction_id,
	mindmg, maxdmg, attack_count, npcspecialattks, aggroradius,
	attack_speed, STR, STA, DEX, AGI, `_INT`, WIS, CHA,
	see_invis_undead, qglobal, AC, npc_aggro, spawn_limit,
	trackable, isbot, exclude, version, scalerate, isquest,
	face, spells, idfile,
	spellscale, healscale, exp_mod
) VALUES (
	1120001110, 'Purveyor_of_Armour_Glamour', 'Armour Ornaments', 70, 5, 1, 1, 43854, 0,
	1, 1, 0, 6, 0, 0,
	0, 0, -1,
	0, 0, 0, '', 0,
	0, 75, 75, 75, 75, 80, 75, 75,
	0, 0, 1, 0, 1,
	1, 0, 1, 1, 100, 1,
	28, 11113, 'IT10',
	100, 100, 100
);

INSERT INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
VALUES (5003550, 'bazaar-Purveyor_of_Armour_Glamour000', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0);

INSERT INTO spawnentry (spawngroupID, npcID, chance, condition_value_filter, min_time, max_time, min_expansion, max_expansion)
VALUES (5003550, 1120001110, 100, 1, 0, 0, -1, -1);

INSERT INTO spawn2 (
	id, spawngroupID, zone, version, x, y, z, heading,
	respawntime, variance, pathgrid, path_when_zone_idle,
	`_condition`, cond_value, animation, min_expansion, max_expansion
) VALUES (
	2141650, 5003550, 'bazaar', 0, 149.280000, -592.260000, 3.230000, 321.250000,
	1200, 0, 0, 0,
	0, 1, 0, -1, -1
);
)",
		.content_schema_update = false,
	},

	// ------------------------------------------------------------------
	// Offline Bazaar (offline trader / buyer / barter) - ported from the
	// chadw/EQEmu fork. item_unique_id provides a globally-unique item
	// instance identifier so offline transactions can be reconciled.
	// ------------------------------------------------------------------

	ManifestEntry{
		.version = 27,
		.description = "2026_08_29_account_offline_flag.sql",
		.check = "SHOW COLUMNS FROM `account` LIKE 'offline'",
		.condition = "empty",
		.match = "",
		.sql = R"(
ALTER TABLE `account`
	ADD COLUMN `offline` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 AFTER `time_creation`;
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 28,
		.description = "2026_08_29_trader_offline_schema.sql",
		.check = "SHOW COLUMNS FROM `trader` LIKE 'character_id'",
		.condition = "empty",
		.match = "",
		.sql = R"(
ALTER TABLE `trader`
	DROP KEY `idx_trader_char`,
	DROP KEY `idx_trader_item_sn`,
	CHANGE COLUMN `char_id` `character_id` int(11) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `aug_slot_1` `augment_one` int(10) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `aug_slot_2` `augment_two` int(10) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `aug_slot_3` `augment_three` int(10) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `aug_slot_4` `augment_four` int(10) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `aug_slot_5` `augment_five` int(10) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `aug_slot_6` `augment_six` int(10) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `item_sn` `item_unique_id` varchar(64) NULL DEFAULT NULL,
	ADD KEY `idx_trader_char` (`character_id`,`char_zone_id`,`char_zone_instance_id`),
	ADD KEY `idx_trader_item_unique_id` (`item_unique_id`);
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 29,
		.description = "2026_08_29_inventory_sharedbank_item_unique_id.sql",
		.check = "SHOW COLUMNS FROM `inventory` LIKE 'item_unique_id'",
		.condition = "empty",
		.match = "",
		.sql = R"(
ALTER TABLE `inventory`
	ADD COLUMN `item_unique_id` varchar(64) NULL DEFAULT NULL AFTER `guid`;

ALTER TABLE `sharedbank`
	ADD COLUMN `item_unique_id` varchar(64) NULL DEFAULT NULL AFTER `guid`;
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 30,
		.description = "2026_08_29_parcels_item_unique_id.sql",
		.check = "SHOW COLUMNS FROM `character_parcels` LIKE 'item_unique_id'",
		.condition = "empty",
		.match = "",
		.sql = R"(
ALTER TABLE `character_parcels`
	ADD COLUMN `item_unique_id` varchar(64) NULL DEFAULT NULL AFTER `aug_slot_6`,
	ADD COLUMN `evolve_amount` int(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `quantity`;

ALTER TABLE `character_parcels_containers`
	ADD COLUMN `item_unique_id` varchar(64) NULL DEFAULT NULL AFTER `item_id`,
	ADD COLUMN `evolve_amount` int(10) UNSIGNED NOT NULL DEFAULT 0 AFTER `quantity`;
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 31,
		.description = "2026_08_29_inventory_snapshots_item_unique_id.sql",
		.check = "SHOW COLUMNS FROM `inventory_snapshots` LIKE 'item_unique_id'",
		.condition = "empty",
		.match = "",
		.sql = R"(
ALTER TABLE `inventory_snapshots`
	CHANGE COLUMN `charid` `character_id` int(11) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `slotid` `slot_id` mediumint(7) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `itemid` `item_id` int(11) UNSIGNED DEFAULT 0,
	CHANGE COLUMN `augslot1` `augment_one` mediumint(7) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `augslot2` `augment_two` mediumint(7) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `augslot3` `augment_three` mediumint(7) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `augslot4` `augment_four` mediumint(7) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `augslot5` `augment_five` mediumint(7) UNSIGNED DEFAULT 0,
	CHANGE COLUMN `augslot6` `augment_six` mediumint(7) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `ornamenticon` `ornament_icon` int(11) UNSIGNED NOT NULL DEFAULT 0,
	CHANGE COLUMN `ornamentidfile` `ornament_idfile` int(11) UNSIGNED NOT NULL DEFAULT 0,
	ADD COLUMN `item_unique_id` varchar(64) NULL DEFAULT NULL;
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 32,
		.description = "2026_08_29_offline_bazaar_tables.sql",
		.check = "SHOW TABLES LIKE 'item_unique_id_reservations'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE `item_unique_id_reservations` (
	`item_unique_id` varchar(64) NOT NULL,
	`reserved_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`item_unique_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE `offline_character_sessions` (
	`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
	`account_id` int(10) unsigned NOT NULL DEFAULT 0,
	`character_id` int(10) unsigned NOT NULL DEFAULT 0,
	`mode` varchar(32) NOT NULL DEFAULT '',
	`zone_id` int(10) unsigned NOT NULL DEFAULT 0,
	`instance_id` int(11) NOT NULL DEFAULT 0,
	`entity_id` int(10) unsigned NOT NULL DEFAULT 0,
	`started_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	UNIQUE KEY `account_id` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE `character_offline_transactions` (
	`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
	`character_id` int(10) unsigned NOT NULL DEFAULT 0,
	`type` int(10) unsigned NOT NULL DEFAULT 0,
	`item_id` int(10) unsigned NOT NULL DEFAULT 0,
	`item_name` varchar(64) NOT NULL DEFAULT '',
	`quantity` int(11) NOT NULL DEFAULT 0,
	`price` bigint(20) unsigned NOT NULL DEFAULT 0,
	`buyer_name` varchar(64) NOT NULL DEFAULT '',
	PRIMARY KEY (`id`),
	KEY `idx_offline_transactions_character` (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 33,
		.description = "2026_08_29_character_illusions.sql",
		.check = "SHOW TABLES LIKE 'character_illusions'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE `character_illusions` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`character_id` INT NOT NULL,
	`spell_id` INT NOT NULL,
	`item_id` INT DEFAULT 0,
	`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB;
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 34,
		.description = "2026_09_08_npc_types_summon_timer_override",
		.check = "SHOW COLUMNS FROM `npc_types` LIKE 'summon_timer_override'",
		.condition = "empty",
		.match = "",
		.sql = R"(
ALTER TABLE `npc_types` ADD COLUMN `summon_timer_override` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0;
)",
		.content_schema_update = false,
	},

	// v35: Bazaar revamp - move Eryke Stremstin to the backrooms, rename the
	// greengrocer to Ambassador Terratoe (with a new hometown/faction quest),
	// and rename the Echo of Memory merchant to Caerulea.
	ManifestEntry{
		.version = 35,
		.description = "2026_09_12_bazaar_ambassador_terratoe",
		.check = "SELECT name FROM npc_types WHERE id = 151257",
		.condition = "missing",
		.match = "Ambassador_Terratoe",
		.sql = R"(
-- Eryke Stremstin (151053): ensure the epic spawn exists and relocate it to the backrooms.
-- Upsert so this works whether or not utils/sql/epic_missing_spawns.sql was applied.
INSERT INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
VALUES (912002, 'oow_epic_eryke_stremstin', 0, 0, 0, 0, 0, 0, 0, 15000, 0, 100, 0)
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (912002, 151053, 100)
ON DUPLICATE KEY UPDATE npcID = VALUES(npcID), chance = VALUES(chance);

INSERT INTO spawn2 (id, spawngroupID, zone, version, x, y, z, heading, respawntime, variance)
VALUES (912002, 912002, 'bazaar', 0, 275.0, 55.0, -47.0, 0.0, 640, 0)
ON DUPLICATE KEY UPDATE x = VALUES(x), y = VALUES(y), z = VALUES(z), heading = VALUES(heading);

-- Greengrocer -> Ambassador Terratoe, relocated to the backrooms.
UPDATE spawn2 SET x = 315.0, y = 22.0, z = -48.0, heading = 0.0 WHERE id = 3388070;
UPDATE npc_types SET name = 'Ambassador_Terratoe', lastname = '' WHERE id = 151257;

-- Echo of Memory merchant -> Caerulea. Keeps merchant_id 1000023 (still sells Echoes of Memory).
UPDATE npc_types SET name = 'Caerulea', lastname = '' WHERE id = 1120001186;
)",
		.content_schema_update = false,
	},

	// v36: Glamour backfill. Adds Glamour augments for base weapons/armour the
	// Purveyor could not produce (216 weapon + 14 armour), in free item ids
	// 990000-990229. Weapon glamours copy the base idfile/icon/slots/weight;
	// armour glamours copy idfile/icon/slots/material/herosforgemodel.
	// Check: skip if the first row of the block already exists.
	ManifestEntry{
		.version = 36,
		.description = "2026_09_12_glamour_backfill",
		.check = "SELECT id FROM items WHERE id = 990000 LIMIT 1",
		.condition = "empty",
		.match = "",
		.sql = R"(
INSERT INTO items (`id`,`Name`,`augtype`,`charmfile`,`charmfileid`,`classes`,`color`,`combateffects`,`focuseffect`,`icon`,`idfile`,`itemtype`,`lore`,`magic`,`nodrop`,`norent`,`races`,`sellrate`,`skillmodtype`,`slots`,`clickeffect`,`weight`,`UNK013`,`stacksize`,`proceffect`,`worneffect`,`scrolleffect`,`source`,`UNK120`,`UNK132`,`clickunk7`,`procunk7`,`wornunk7`,`focusunk7`,`scrollunk7`,`ldonsellbackrate`,`bardeffect`,`bardunk7`,`UNK231`,`UNK233`,`UNK234`) SELECT 989999 + ROW_NUMBER() OVER (ORDER BY id), CONCAT('Glamour - ''', Name, ''''), 524288, 'ITEMTransAugAll', '0', 65535, 4278190080, '0', -1, icon, idfile, 54, 'This ornament transforms the appearance of your weapon', 1, 1, 1, 65535, 1.0, -1, slots, -1, weight, 1, 1, -1, -1, -1, '13THFLOOR', -1, '00000000000000000000', -1, -1, -1, -1, -1, 70, -1, -1, -1, -256, 255 FROM items WHERE id IN (93889,93890,93891,93892,93894,93897,93898,93899,93900,93901,93903,94392,94393,94394,94395,94416,94417,94418,94420,94421,94422,94423,94424,94425,94427,94428,94432,94433,94434,94435,94436,94660,94785,94786,94787,94792,94793,94794,94795,94796,94797,94798,94799,94800,94801,94802,94803,94805,94807,94810,94811,94812,94936,98593,98615,98616,98617,98618,98621,98622,98625,98626,98627,98628,98631,98632,98633,98634,98636,98637,98856,98985,98986,98987,98990,98992,98993,98995,98996,98997,98998,98999,99000,99002,99003,99005,99011,99138,117085,117086,117105,117106,117107,117108,117109,117111,117112,117113,117114,117115,117118,117121,117126,117127,117128,117427,117428,117430,117431,117432,117433,117434,117435,117436,117438,117441,117442,117443,117444,117445,117446,117447,117448,117449,117450,117451,117452,117453,139698,139699,139722,139723,139730,139732,139735,140092,140093,140210,140214,140216,140217,140218,140221,140222,140223,140224,140227,140229,140231,140492,140493,140494,140609,140610,140611,140614,140615,140618,140619,140623,140624,140631,140893,140894,140895,141011,141012,141013,141015,141018,141019,141020,141021,141022,141023,141024,141025,141027,141031,141584,141586,141587,141590,141591,141592,141593,141596,141597,141598,141602,141604,141606,141607,141608,141609,141611,141612,146643,147028,147030,147032,147034,147039,147041,147044,147045,147292,147300,147304,147305,147306,147309,147401,147402,147409,147410);

INSERT INTO items (`id`,`Name`,`augrestrict`,`augtype`,`charmfile`,`charmfileid`,`classes`,`color`,`combateffects`,`focuseffect`,`icon`,`idfile`,`itemtype`,`magic`,`material`,`herosforgemodel`,`nodrop`,`norent`,`races`,`skillmodtype`,`slots`,`clickeffect`,`stacksize`,`proceffect`,`worneffect`,`scrolleffect`,`clickunk7`,`procunk7`,`wornunk7`,`focusunk7`,`scrollunk7`,`bardeffect`,`bardunk7`) SELECT 990215 + ROW_NUMBER() OVER (ORDER BY id), CONCAT('Glamour - ''', Name, ''''), 1, 1048576, CASE WHEN slots = 131072 THEN 'ArmorOrnLeaChestInfo' ELSE 'ArmorOrnLea-CloInfo' END, '0', 65535, 4278190080, '0', -1, icon, 'IT64', 54, 1, material, herosforgemodel, 1, 1, 65535, -1, slots, -1, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 FROM items WHERE id IN (18924,85374,85375,85376,85377,85378,85379,85394,85395,85396,85397,85398,85399,85400);
)",
		.content_schema_update = false,
	},

	// v37: The Recharger - Bazaar item recharge NPC. Recharges any expendable
	// charged item to full charges for a flat 2 Echo of Memory (EoM). Refuses
	// augmented items and items that are already fully charged.
	// Creates npc_types 1120001416, spawngroup 5003547, spawn2 2141652.
	// Check: skip if the NPC already exists.
	ManifestEntry{
		.version = 37,
		.description = "2026_09_12_bazaar_recharger_npc",
		.check = "SELECT id FROM npc_types WHERE name = 'The_Recharger'",
		.condition = "empty",
		.match = "",
		.sql = R"(
INSERT INTO npc_types (
	id, name, lastname, level, race, class, bodytype, hp, mana,
	gender, texture, helmtexture, size, hp_regen_rate, mana_regen_rate,
	loottable_id, merchant_id, npc_faction_id,
	mindmg, maxdmg, attack_count, npcspecialattks, special_abilities, aggroradius,
	attack_speed, attack_delay, STR, STA, DEX, AGI, `_INT`, WIS, CHA,
	see_invis_undead, qglobal, AC, npc_aggro, spawn_limit,
	trackable, isbot, exclude, version, scalerate, isquest,
	face, npc_spells_id, d_melee_texture1, d_melee_texture2,
	spellscale, healscale, exp_mod
) VALUES (
	1120001416, 'The_Recharger', '', 70, 6, 1, 1, 43854, 0,
	0, 1, 0, 6, 0, 0,
	0, 0, 0,
	0, 0, -1, '', '24,1^25,1^35,1^39,1', 0,
	0, 30, 75, 75, 75, 75, 80, 75, 75,
	0, 0, 0, 0, 0,
	1, 0, 1, 1, 100, 0,
	0, 0, 0, 0,
	100, 100, 100
);

INSERT INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
VALUES (5003547, 'bazaar-The_Recharger000', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0);

INSERT INTO spawnentry (spawngroupID, npcID, chance, condition_value_filter, min_time, max_time, min_expansion, max_expansion)
VALUES (5003547, 1120001416, 100, 1, 0, 0, -1, -1);

INSERT INTO spawn2 (
	id, spawngroupID, zone, version, x, y, z, heading,
	respawntime, variance, pathgrid, path_when_zone_idle,
	`_condition`, cond_value, animation, min_expansion, max_expansion
) VALUES (
	2141652, 5003547, 'bazaar', 0, 271.000000, -11.000000, -48.000000, 256.000000,
	1200, 0, 0, 0,
	0, 1, 0, -1, -1
);
)",
		.content_schema_update = false,
	},

	// v38: Move Ambassador Terratoe (npc 151257) in the Bazaar to 320, 22, -48.
	// Resolved via npc id (spawn2 id is auto-increment and differs per install).
	ManifestEntry{
		.version = 38,
		.description = "2026_09_12_move_ambassador_terratoe",
		.check = "SELECT s.id FROM spawn2 s JOIN spawngroup g ON g.id = s.spawngroupID JOIN spawnentry e ON e.spawngroupID = g.id WHERE e.npcID = 151257 AND s.x = 320 AND s.y = 22 AND s.z = -48",
		.condition = "empty",
		.match = "",
		.sql = R"(
UPDATE spawn2
JOIN spawngroup ON spawngroup.id = spawn2.spawngroupID
JOIN spawnentry ON spawnentry.spawngroupID = spawngroup.id
SET spawn2.x = 320.0, spawn2.y = 22.0, spawn2.z = -48.0
WHERE spawnentry.npcID = 151257 AND spawn2.zone = 'bazaar';
)",
		.content_schema_update = false,
	},

	// v39: Restore #Echo_of_Chardok (103161). The base import ships its chardok
	// spawn points and the 100% "Essence of Chardok" (69308) loot table, but the
	// npc_types row was missing, so the spawns pointed at a non-existent npc and
	// the essence branch of the Cipher of Veeshan quest (recipe 9716) was
	// unreachable. Check: skip if the npc already exists.
	ManifestEntry{
		.version = 39,
		.description = "2026_09_13_chardok_echo_of_chardok",
		.check = "SELECT id FROM npc_types WHERE id = 103161",
		.condition = "empty",
		.match = "",
		.sql = R"(
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, herosforgemodel, size, hp_regen_rate, hp_regen_per_second, mana_regen_rate, loottable_id, merchant_id, greed, alt_currency_id, npc_spells_id, npc_spells_effects_id, npc_faction_id, adventure_template_id, trap_template, mindmg, maxdmg, attack_count, npcspecialattks, special_abilities, aggroradius, assistradius, face, luclin_hairstyle, luclin_haircolor, luclin_eyecolor, luclin_eyecolor2, luclin_beardcolor, luclin_beard, drakkin_heritage, drakkin_tattoo, drakkin_details, armortint_id, armortint_red, armortint_green, armortint_blue, d_melee_texture1, d_melee_texture2, ammo_idfile, prim_melee_type, sec_melee_type, ranged_type, runspeed, MR, CR, DR, FR, PR, Corrup, PhR, see_invis, see_invis_undead, qglobal, AC, npc_aggro, spawn_limit, attack_speed, attack_delay, findable, STR, STA, DEX, AGI, `_INT`, WIS, CHA, see_hide, see_improved_hide, trackable, isbot, exclude, ATK, Accuracy, Avoidance, slow_mitigation, version, maxlevel, scalerate, private_corpse, unique_spawn_by_name, underwater, isquest, emoteid, spellscale, healscale, no_target_hotkey, raid_target, armtexture, bracertexture, handtexture, legtexture, feettexture, light, walkspeed, peqid, unique_, fixed, ignore_despawn, show_name, untargetable, charm_ac, charm_min_dmg, charm_max_dmg, charm_attack_delay, charm_accuracy_rating, charm_avoidance_rating, charm_atk, skip_global_loot, rare_spawn, stuck_behavior, model, flymode, always_aggro, exp_mod, heroic_strikethrough, faction_amount, keeps_sold_items, is_parcel_merchant, multiquest_enabled, npc_tint_id)
VALUES (103161,'#Echo_of_Chardok','',67,155,1,3,59412,0,2,0,0,0,6,25,0,0,14486,0,0,0,606,0,1444,0,0,150,750,-1,'SERNDf','1,1^2,1^5,1^8,1^13,1^14,1^15,1^16,1^17,1^21,1^31,1',60,85,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,'IT10',28,28,7,1.25,150,150,150,150,150,92,48,1,0,0,283,0,0,-22,18,0,215,215,215,215,215,215,215,0,0,1,0,1,100,0,0,0,0,0,100,0,0,0,0,0,100,100,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
 (8376,'chardok_89',0,0,0,0,0,0,0,15000,0,15285,0),
 (8452,'chardok_13',0,0,0,0,0,0,0,15000,0,9870,0),
 (12978,'chardok_188',0,0,0,0,0,0,0,15000,0,100,0);

INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance,condition_value_filter,min_time,max_time,min_expansion,max_expansion) VALUES
 (8376,103161,50,1,0,0,-1,-1),
 (8452,103161,50,1,0,0,-1,-1),
 (12978,103161,50,1,0,0,-1,-1);

INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,path_when_zone_idle,`_condition`,cond_value,animation,min_expansion,max_expansion) VALUES
 (21133,8376,'chardok',0,-329.0,-507.0,-138.63,234.0,640,0,0,0,0,1,0,-1,-1),
 (21003,8452,'chardok',0,166.0,415.0,-305.0,138.0,640,0,0,0,0,1,0,-1,-1),
 (21305,12978,'chardok',0,339.0,19.0,-273.5,130.0,640,0,0,0,0,1,0,-1,-1);
)",
		.content_schema_update = false,
	},

	// v40: Release the hard min_status lock on eras through Secrets of Faydwer
	// (expansion <= 14). Era access is meant to be enforced per-account by
	// NMS_progression_utils.pl (is_eligible_for_zone) + global_player.pl; the base
	// import's min_status = 255 blocked status-0 characters in CanEnterZone before
	// those gates could run, so the Tunat -> OoW unlock never took effect. Expansions
	// greater than 14 remain hard-locked at 255.
	ManifestEntry{
		.version = 40,
		.description = "2026_09_13_nms_expansion_zone_unlock",
		.check = "SELECT zoneidnumber FROM zone WHERE min_status = 255 AND expansion <= 14 LIMIT 1",
		.condition = "empty",
		.match = "",
		.sql = R"(
UPDATE zone SET min_status = 0 WHERE expansion <= 14 AND min_status = 255;
)",
		.content_schema_update = false,
	},

	// v41: Rename the "Echo of Memory" currency to "Triune of Fate" (alternate currency 6,
	// item 46779) and set the drop chance to 150.
	ManifestEntry{
		.version = 41,
		.description = "2026_09_13_rename_echo_of_memory_to_triune_of_fate",
		// Guard on the player-visible alt-currency label rather than on a rule row: this entry
		// is flagged as a content-schema update, so the check runs on the SAME connection the
		// SQL below runs on (db_str is a content table, rule_values is not). "missing" -> run
		// only while the label does not already say Triune. An absent db_str row also reads as
		// missing, which is right: the rest of the rename still has to happen.
		.check = "SELECT `value` FROM `db_str` WHERE `id` = 6 AND `type` = 17",
		.condition = "missing",
		.match = "Triune",
		.sql = R"(
-- Rename the "Echo of Memory" currency to "Triune of Fate", and set the drop chance to 150.
--
-- Apostrophes are escaped SQL-standard style by DOUBLING them (''), never with a backslash,
-- so these statements are correct with or without NO_BACKSLASH_ESCAPES.
--
-- This entry touches content tables (items, db_str, npc_types, spawngroup, saylink) and
-- rule_values / data_buckets, which are not content tables. It is flagged
-- content_schema_update = true, like the zone-table entries above: this deployment runs a
-- single database for both schemas. If the schemas are ever split, this entry has to be
-- split with them.

-- 1. The currency item. Alternate currency 6 maps to item 46779 (alternate_currency row).
--    The player-visible description text lives in `items`.`lore` varchar(80); the new text
--    below is 69 chars and pure ASCII.
UPDATE `items`
   SET `Name` = 'Triune of Fate',
       `lore` = 'Three tides turned in your favor, pressed into a single shining drop.'
 WHERE `id` = 46779;

-- 2. The alt-currency window label. Currency id 6, string types 17 and 18.
UPDATE `db_str` SET `value` = 'Triune of Fate' WHERE `id` = 6 AND `type` IN (17, 18);

-- 3. The merchant NPC. Live servers already renamed it to Caerulea (v35); this only catches
--    a database where the old name survived. Guarded so a Caerulea row is never touched.
UPDATE `npc_types` SET `name` = 'Caerulea', `lastname` = '' WHERE `id` = 1120001186 AND `name` = 'Echo of Memory';

-- 4. Internal spawngroup key. No apostrophe on purpose -- this is a lookup key, not player copy.
UPDATE `spawngroup` SET `name` = 'bazaar_Triune of Fate000_682659186' WHERE `id` = 5003654;

-- 5. The five rule renames.
--
--    rule_values is keyed on (ruleset_id, rule_name), so a bare "UPDATE ... SET rule_name = ..."
--    dies with a duplicate-key error on any server where BOTH the old and the new name already
--    exist in the same ruleset. Guard: delete the new-named row ONLY where the old-named row
--    also exists in that same ruleset, then rename.
--
--    Every statement keys on rule_name alone and joins on ruleset_id, never on a literal
--    ruleset id, so all rulesets migrate. Each row keeps its existing rule_value -- only the
--    drop chance changes, to 150.
--
--    The four Unlock* rules are deliberately NOT upserted: if a server never wrote them to
--    rule_values, the compiled default governs and inserting rows here would change behaviour.
--    The drop chance IS upserted below, because its value is changing on purpose.

DELETE `rv_new` FROM `rule_values` AS `rv_new`
 INNER JOIN `rule_values` AS `rv_old`
    ON `rv_old`.`ruleset_id` = `rv_new`.`ruleset_id`
   AND `rv_old`.`rule_name`  = 'Custom:EventEOMDropChance'
 WHERE `rv_new`.`rule_name` = 'Custom:TriuneOfFateDropChance';

UPDATE `rule_values`
   SET `rule_name`  = 'Custom:TriuneOfFateDropChance',
       `rule_value` = '150',
       `notes`      = 'Increase this value to make Triune of Fate drops more rare. Flat 1 in N roll per player, per kill.'
 WHERE `rule_name` = 'Custom:EventEOMDropChance';

DELETE `rv_new` FROM `rule_values` AS `rv_new`
 INNER JOIN `rule_values` AS `rv_old`
    ON `rv_old`.`ruleset_id` = `rv_new`.`ruleset_id`
   AND `rv_old`.`rule_name`  = 'Custom:EoMUnlockCharacterSets'
 WHERE `rv_new`.`rule_name` = 'Custom:TriuneOfFateUnlockCharacterSets';

UPDATE `rule_values`
   SET `rule_name` = 'Custom:TriuneOfFateUnlockCharacterSets',
       `notes`     = 'Maximum number of character sets which a player can unlock with Triune of Fate.'
 WHERE `rule_name` = 'Custom:EoMUnlockCharacterSets';

DELETE `rv_new` FROM `rule_values` AS `rv_new`
 INNER JOIN `rule_values` AS `rv_old`
    ON `rv_old`.`ruleset_id` = `rv_new`.`ruleset_id`
   AND `rv_old`.`rule_name`  = 'Custom:EoMUnlockCharacterSetCost'
 WHERE `rv_new`.`rule_name` = 'Custom:TriuneOfFateUnlockCharacterSetCost';

UPDATE `rule_values`
   SET `rule_name` = 'Custom:TriuneOfFateUnlockCharacterSetCost',
       `notes`     = 'Triune of Fate cost to unlock a character set'
 WHERE `rule_name` = 'Custom:EoMUnlockCharacterSetCost';

DELETE `rv_new` FROM `rule_values` AS `rv_new`
 INNER JOIN `rule_values` AS `rv_old`
    ON `rv_old`.`ruleset_id` = `rv_new`.`ruleset_id`
   AND `rv_old`.`rule_name`  = 'Custom:EoMUnlockCharacterSlots'
 WHERE `rv_new`.`rule_name` = 'Custom:TriuneOfFateUnlockCharacterSlots';

UPDATE `rule_values`
   SET `rule_name` = 'Custom:TriuneOfFateUnlockCharacterSlots',
       `notes`     = 'Maximum number of character slots which a player can unlock with Triune of Fate.'
 WHERE `rule_name` = 'Custom:EoMUnlockCharacterSlots';

DELETE `rv_new` FROM `rule_values` AS `rv_new`
 INNER JOIN `rule_values` AS `rv_old`
    ON `rv_old`.`ruleset_id` = `rv_new`.`ruleset_id`
   AND `rv_old`.`rule_name`  = 'Custom:EoMUnlockCharacterSlotCost'
 WHERE `rv_new`.`rule_name` = 'Custom:TriuneOfFateUnlockCharacterSlotCost';

UPDATE `rule_values`
   SET `rule_name` = 'Custom:TriuneOfFateUnlockCharacterSlotCost',
       `notes`     = 'Triune of Fate cost to unlock a character slot'
 WHERE `rule_name` = 'Custom:EoMUnlockCharacterSlotCost';

-- Force the new drop chance on every ruleset that already carried a new-named row (a server
-- that renamed by hand, or a ruleset the rename above did not reach).
UPDATE `rule_values` SET `rule_value` = '150' WHERE `rule_name` = 'Custom:TriuneOfFateDropChance';

-- Upsert for the same reason earlier migrations record: on a database where the rule row does
-- not exist at all, a bare UPDATE matches zero rows and silently does nothing. This guarantees
-- ruleset 1 ends up at 150 whether or not anything was there before.
INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES (1, 'Custom:TriuneOfFateDropChance', '150', 'Increase this value to make Triune of Fate drops more rare. Flat 1 in N roll per player, per kill.')
ON DUPLICATE KEY UPDATE `rule_value` = VALUES(`rule_value`), `notes` = VALUES(`notes`);

-- 6. Pending GM awards. The shipped dump has no such rows, but a live server may -- without
--    this they would be orphaned under a key nothing reads any more.
UPDATE `data_buckets` SET `key` = 'TriuneOfFate-Award' WHERE `key` = 'EoM-Award';

-- 7. Saylink cache. `saylink` maps an id to the phrase a clicked chat link makes the player
--    say; rows are created on demand from bracketed [text] in NPC dialogue. Stale rows are not
--    merely untidy: an old link in a player's chat window would still say "Echo of Memory".
--    Keyed on `phrase`, not on a literal id, because ids are assigned per server. `phrase` is
--    varchar(64) with a NON-unique index, so a plain UPDATE cannot collide.
UPDATE `saylink` SET `phrase` = 'Triune of Fate' WHERE `phrase` = 'Echo of Memory';
UPDATE `saylink` SET `phrase` = 'link_triune_of_fate' WHERE `phrase` = 'link_echo_of_memory';

-- Deliberately NOT touched: player_event_* telemetry rows. Those are historical records and
-- must keep the names the events were recorded under.
)",
		.content_schema_update = true,
	},

	// v42: Drakkin breath weapons embed their elemental resist debuff in effect slot 3, which
	// is the same slot the Malo line uses for SE_ResistMagic (and the analogous slot for the
	// other resist lines). Mob::CheckStackConflict only arbitrates when two spells carry the
	// same effect in the same slot (zone/spells.cpp), so a breath fired at an already-debuffed
	// target lost the arbitration and the whole ability was blocked ("did not take hold").
	// AlwaysStackSpells short-circuits that arbitration (zone/spells.cpp), so the breath lands
	// and both buffs persist regardless of who applied the debuff.
	//
	// Scope: every spell with the SE_CurrentHPOnce + SE_CurrentHP + slot-3 resist-debuff shape:
	//   - 11112-11201  the six Drakkin breath lineages (Atathus, Draton'ra, Osh'vir, Venesh,
	//                  Mysaphar, Keikolin)
	//   - 50009-50014  the custom rank-14/15 breath clones (tss_crescent_reach_quests.sql)
	//   - 7176, 7708, 8260, 11495  Diseased Spore, Diseased Sporeling, Spore Sting, Flaming Oil
	// Dedicated resist-debuff lines (Malosi/Malosini/etc.) are deliberately NOT added: they must
	// keep conflicting with each other.
	ManifestEntry{
		.version = 42,
		.description = "2026_09_13_drakkin_breath_always_stack",
		.check = "SELECT rule_value FROM rule_values WHERE rule_name = 'Spells:AlwaysStackSpells'",
		.condition = "missing",
		.match = "11112",
		.sql = R"(
-- Upsert, not UPDATE: on a DB where the rule row does not exist yet, a bare UPDATE matches
-- zero rows and silently does nothing.
UPDATE `rule_values`
   SET `rule_value` = '2750,3271,3272,3273,4521,4522,4523,4549,4550,4551,5933,5934,5935,6079,6080,6081,6499,7176,7708,8156,8157,8158,8216,8260,8406,8407,8408,11023,11103,11104,11105,11112,11113,11114,11115,11116,11117,11118,11119,11120,11121,11122,11123,11124,11125,11126,11127,11128,11129,11130,11131,11132,11133,11134,11135,11136,11137,11138,11139,11140,11141,11142,11143,11144,11145,11146,11147,11148,11149,11150,11151,11152,11153,11154,11155,11156,11157,11158,11159,11160,11161,11162,11163,11164,11165,11166,11167,11168,11169,11170,11171,11172,11173,11174,11175,11176,11177,11178,11179,11180,11181,11182,11183,11184,11185,11186,11187,11188,11189,11190,11191,11192,11193,11194,11195,11196,11197,11198,11199,11200,11201,11226,11227,11228,11232,11279,11297,11298,11299,11317,11495,11615,11616,11617,11642,11643,11644,16121,16203,36856,36869,36877,43002,50009,50010,50011,50012,50013,50014',
       `notes`      = 'Comma-Seperated list of spell IDs to always stack with every other spell, except themselves.'
 WHERE `rule_name` = 'Spells:AlwaysStackSpells';

INSERT INTO `rule_values` (`ruleset_id`, `rule_name`, `rule_value`, `notes`)
VALUES (1, 'Spells:AlwaysStackSpells', '2750,3271,3272,3273,4521,4522,4523,4549,4550,4551,5933,5934,5935,6079,6080,6081,6499,7176,7708,8156,8157,8158,8216,8260,8406,8407,8408,11023,11103,11104,11105,11112,11113,11114,11115,11116,11117,11118,11119,11120,11121,11122,11123,11124,11125,11126,11127,11128,11129,11130,11131,11132,11133,11134,11135,11136,11137,11138,11139,11140,11141,11142,11143,11144,11145,11146,11147,11148,11149,11150,11151,11152,11153,11154,11155,11156,11157,11158,11159,11160,11161,11162,11163,11164,11165,11166,11167,11168,11169,11170,11171,11172,11173,11174,11175,11176,11177,11178,11179,11180,11181,11182,11183,11184,11185,11186,11187,11188,11189,11190,11191,11192,11193,11194,11195,11196,11197,11198,11199,11200,11201,11226,11227,11228,11232,11279,11297,11298,11299,11317,11495,11615,11616,11617,11642,11643,11644,16121,16203,36856,36869,36877,43002,50009,50010,50011,50012,50013,50014', 'Comma-Seperated list of spell IDs to always stack with every other spell, except themselves.')
ON DUPLICATE KEY UPDATE `rule_value` = VALUES(`rule_value`), `notes` = VALUES(`notes`);
)",
		.content_schema_update = false,
	},

	// v43: Banker Yalon (bazaar, npc 12000149) - add the "Currency Conversion" lastname
	// subtitle. She is being repurposed as the Triune of Fate <-> platinum money changer
	// (quests/bazaar/12000149.pl); the lastname advertises the new role on her nameplate.
	// The cshome Banker_Yalon (26004) is deliberately untouched. Check: skip once the
	// lastname already reads correctly. Guard is NULL-safe (see the v44 repair pass:
	// `lastname <> '...'` alone evaluates UNKNOWN against a NULL lastname and no-ops).
	ManifestEntry{
		.version = 43,
		.description = "2026_09_13_banker_yalon_currency_conversion_lastname",
		.check = "SELECT lastname FROM npc_types WHERE id = 12000149 AND lastname = 'Currency Conversion'",
		.condition = "empty",
		.match = "",
		.sql = R"(
UPDATE npc_types SET lastname = 'Currency Conversion'
WHERE id = 12000149 AND (lastname IS NULL OR lastname <> 'Currency Conversion');
)",
		.content_schema_update = false,
	},

	// v44: REPAIR PASS for v43. On the dev server the v43 UPDATE silently no-opped: Yalon's
	// lastname was NULL, `lastname <> 'Currency Conversion'` evaluated to UNKNOWN, the row
	// never matched - and the runner stamped custom_version 43 anyway. This entry re-delivers
	// the update with the NULL-safe guard so a DB already stamped 43 converges; v43 is fixed
	// in place for imports that have not reached it yet.
	ManifestEntry{
		.version = 44,
		.description = "2026_09_13_banker_yalon_lastname_null_safe_resync",
		.check = "SELECT lastname FROM npc_types WHERE id = 12000149 AND lastname = 'Currency Conversion'",
		.condition = "empty",
		.match = "",
		.sql = R"(
UPDATE npc_types SET lastname = 'Currency Conversion'
WHERE id = 12000149 AND (lastname IS NULL OR lastname <> 'Currency Conversion');
)",
		.content_schema_update = false,
	},

	// v45: Greater Soul Gem. A Special-category AA that converts 50 unspent AA points into a
	// tradeable "Greater Soul Gem"; clicking the gem grants 50 AA. The AA rank's spell (50015)
	// is SE_Blank / self-target so it lands and fires the spell quest script
	// quests/global/spells/50015.pl, which does the AA check and summons the gem. The gem's
	// click spell (50016) fires quests/global/spells/50016.pl, which grants the AA; the server
	// then consumes one charge (Mob::GetItemSlotToConsumeCharge) and deletes the gem when the
	// stack is empty. itemtype 11 (Misc) + clicktype 3 (ItemEffectExpendable) + maxcharges 1 +
	// stacksize 20 mirrors the stock stackable elixirs. No class/race/level restriction on the
	// click. The ability itself is free to acquire (cost 0) and each use costs 50 AA.
	//
	// All inserts are idempotent (ON DUPLICATE KEY UPDATE); the check guards the whole payload
	// on the AA ability row, which is inserted after the spells/item it depends on.
	ManifestEntry{
		.version = 45,
		.description = "2026_09_18_greater_soul_gem",
		.check = "SELECT 1 FROM aa_ability WHERE id = 70006",
		.condition = "empty",
		.match = "",
		.sql = R"(
INSERT INTO `spells_new`
 (`id`,`name`,`cast_time`,`recast_time`,`buffdurationformula`,`buffduration`,`mana`,
  `targettype`,`goodEffect`,`resisttype`,`effectid1`,`effect_base_value1`,`formula1`,
  `icon`,`new_icon`,`spell_category`,
  `teleport_zone`,`you_cast`,`other_casts`,`cast_on_you`,`cast_on_other`,`spell_fades`,
  `typedescnum`,`effectdescnum`,
  `classes1`,`classes2`,`classes3`,`classes4`,`classes5`,`classes6`,`classes7`,`classes8`,
  `classes9`,`classes10`,`classes11`,`classes12`,`classes13`,`classes14`,`classes15`,`classes16`)
VALUES
 (50015,'Greater Soul Gem',0,0,0,0,0,6,1,0,254,0,100,2522,2522,56,
  '','','','','','',0,0,
  254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `spells_new`
 (`id`,`name`,`cast_time`,`recast_time`,`buffdurationformula`,`buffduration`,`mana`,
  `targettype`,`goodEffect`,`resisttype`,`effectid1`,`effect_base_value1`,`formula1`,
  `icon`,`new_icon`,`spell_category`,
  `teleport_zone`,`you_cast`,`other_casts`,`cast_on_you`,`cast_on_other`,`spell_fades`,
  `typedescnum`,`effectdescnum`,
  `classes1`,`classes2`,`classes3`,`classes4`,`classes5`,`classes6`,`classes7`,`classes8`,
  `classes9`,`classes10`,`classes11`,`classes12`,`classes13`,`classes14`,`classes15`,`classes16`)
VALUES
 (50016,'Greater Soul Gem Infusion',0,0,0,0,0,6,1,0,254,0,100,2522,2522,56,
  '','','','','','',0,0,
  254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,254)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `items`
 (`id`,`Name`,`lore`,`idfile`,`icon`,`itemtype`,`slots`,`classes`,`races`,
  `nodrop`,`norent`,`attuneable`,`magic`,`clicktype`,`clickeffect`,`clicklevel`,`clicklevel2`,
  `casttime`,`recastdelay`,`maxcharges`,`stackable`,`stacksize`,`weight`,`price`,`sellrate`,`size`,`charmfileid`)
VALUES
 (7000001,'Greater Soul Gem','A gem of concentrated experience, ready to be shattered.','IT11489',2104,11,0,65535,65535,
  1,1,0,0,3,50016,0,0,0,0,1,1,20,1,0,0,1,'0')
ON DUPLICATE KEY UPDATE `Name` = VALUES(`Name`);

INSERT INTO `aa_ability`
 (`id`,`name`,`category`,`classes`,`races`,`drakkin_heritage`,`deities`,`status`,`type`,`charges`,
  `grant_only`,`first_rank_id`,`enabled`,`reset_on_death`,`auto_grant_enabled`)
VALUES
 (70006,'Greater Soul Gem',-1,65535,65535,127,131071,0,4,0,0,90046,1,0,0)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `aa_ranks`
 (`id`,`upper_hotkey_sid`,`lower_hotkey_sid`,`title_sid`,`desc_sid`,`cost`,`level_req`,`spell`,
  `spell_type`,`recast_time`,`expansion`,`prev_id`,`next_id`)
VALUES
 (90046,910000001,910000001,910000001,910000001,0,1,50015,40001,0,0,-1,-1)
ON DUPLICATE KEY UPDATE `spell` = VALUES(`spell`);

INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
 (910000001,1,'Greater Soul Gem'),
 (910000001,2,'Greater Soul'),
 (910000001,3,'Gem'),
 (910000001,4,'Consumes 50 unspent AA points to create a Greater Soul Gem. The gem is tradeable, and using it grants 50 AA points to whoever uses it.')
ON DUPLICATE KEY UPDATE `value` = VALUES(`value`);
)",
		.content_schema_update = true,
	},

	// v46: REPAIR for v45. The Greater Soul Gem AA was minted with ability id 70006 and rank id
	// 90046, both >= the RoF2 client's AA id ceiling. The client defines NUM_ALT_ABILITIES as
	// 0xC34F (49,999) and only indexes AltAdvManager ability ids 0..49,998 (see the client's
	// GetAltAbility loops), so any AA above that is silently dropped and never appears in the AA
	// window. Re-id the ability/rank to 45000/45001 (both below the ceiling and unused). The old
	// rows are safe to delete: an AA that never displayed can never have been purchased or
	// activated, so no player data references them. Spells, the gem item, and the db_str SID
	// (910000001) are unchanged. Idempotent: guarded on the new ability id being absent.
	ManifestEntry{
		.version = 46,
		.description = "2026_09_18_greater_soul_gem_aa_id_fix",
		.check = "SELECT 1 FROM aa_ability WHERE id = 45000",
		.condition = "empty",
		.match = "",
		.sql = R"(
DELETE FROM `aa_ranks` WHERE `id` = 90046;
DELETE FROM `aa_ability` WHERE `id` = 70006;

INSERT INTO `aa_ability`
 (`id`,`name`,`category`,`classes`,`races`,`drakkin_heritage`,`deities`,`status`,`type`,`charges`,
  `grant_only`,`first_rank_id`,`enabled`,`reset_on_death`,`auto_grant_enabled`)
VALUES
 (45000,'Greater Soul Gem',-1,65535,65535,127,131071,0,4,0,0,45001,1,0,0)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `first_rank_id` = VALUES(`first_rank_id`);

INSERT INTO `aa_ranks`
 (`id`,`upper_hotkey_sid`,`lower_hotkey_sid`,`title_sid`,`desc_sid`,`cost`,`level_req`,`spell`,
  `spell_type`,`recast_time`,`expansion`,`prev_id`,`next_id`)
VALUES
 (45001,910000001,910000001,910000001,910000001,0,1,50015,40001,6,0,-1,-1)
ON DUPLICATE KEY UPDATE `spell` = VALUES(`spell`);
)",
		.content_schema_update = true,
	},

	// v47: The Greater Soul Gem rank (45001) shipped with recast_time = 0. The client classifies
	// an AA as an activatable hotkey only when its reuse timer is nonzero (AltAdvManager's
	// GetCalculatedTimer > 0; the packet's spell_refresh comes from aa_ranks.recast_time). With 0
	// the client showed it as a passive toggle, never sent the activation, and the spell script
	// (which spends the 50 AA and summons the gem) never ran. Give it a 6 second reuse, matching
	// common activated AAs (e.g. Consume Item uses 5). Guarded on the old value so it is a no-op
	// once fixed; v46's insert already uses 6 for fresh installs.
	ManifestEntry{
		.version = 47,
		.description = "2026_09_18_greater_soul_gem_recast_fix",
		.check = "SELECT recast_time FROM aa_ranks WHERE id = 45001",
		.condition = "match",
		.match = "0",
		.sql = R"(
UPDATE `aa_ranks` SET `recast_time` = 6 WHERE `id` = 45001 AND `recast_time` = 0;
)",
		.content_schema_update = true,
	},

	// v48: The Greater Soul Gem spells (50015/50016) were inserted with a partial column list, so
	// eight nullable spells_new columns stayed NULL. SharedDatabase::LoadSpells reads them via
	// Strings::ToInt(row[...]), and Strings::ToInt takes a std::string -- a NULL char* builds a
	// std::string and calls strlen(NULL), so shared_memory.exe crashed with EXCEPTION_ACCESS_VIOLATION
	// while loading spells (that is why the runtime shared/spells never picked up the new spell and
	// the AA activation silently did nothing). Fill the NULLs with the same empty/zero values stock
	// rows carry. Only these two rows are affected: a scan of all 31 nullable spells_new columns
	// shows NULLs nowhere else. v45's inserts were fixed in place for fresh installs, so this
	// no-ops there. Guarded (not_empty) on the exact columns it repairs.
	ManifestEntry{
		.version = 48,
		.description = "2026_09_19_greater_soul_gem_null_spell_columns_fix",
		.check = "SELECT id FROM spells_new WHERE id IN (50015,50016) AND (teleport_zone IS NULL OR you_cast IS NULL OR other_casts IS NULL OR cast_on_you IS NULL OR cast_on_other IS NULL OR spell_fades IS NULL OR typedescnum IS NULL OR effectdescnum IS NULL)",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
UPDATE `spells_new`
   SET `teleport_zone` = COALESCE(`teleport_zone`, ''),
       `you_cast`      = COALESCE(`you_cast`, ''),
       `other_casts`   = COALESCE(`other_casts`, ''),
       `cast_on_you`   = COALESCE(`cast_on_you`, ''),
       `cast_on_other` = COALESCE(`cast_on_other`, ''),
       `spell_fades`   = COALESCE(`spell_fades`, ''),
       `typedescnum`   = COALESCE(`typedescnum`, 0),
       `effectdescnum` = COALESCE(`effectdescnum`, 0)
 WHERE `id` IN (50015, 50016);
)",
		.content_schema_update = true,
	},

	// v49: Greater Soul Gem item flags and spell descriptions.
	//
	// This fork stores the item no-drop / no-rent flags with REVERSE logic in the items table
	// (see common/item_data.h: "NoDrop: 0=nodrop, 255=not nodrop" / "NoRent: 0=norent, 255=not
	// norent"; SharedDatabase::LoadItems copies the columns straight into ItemData, and the trade
	// code allows transfer only when NoDrop != 0). Stock items confirm it: tradeable junk like
	// Rusty Long Sword / Short Sword are nodrop = 1, norent = 1. v45 set the gem to the standard
	// values (nodrop = 0, norent = 0), which this fork reads as no-drop + no-rent, so the gem
	// could not be traded and would not persist. stackable was also left 0. Fix all three, give
	// the item proper lore text and a numeric charmfileid like stock rows.
	//
	// The "DB Error" description was the click spell: spells_new.descnum = 0 makes the client's
	// description lookup fail. Working custom spells point descnum at a db_str id of type 6
	// (the spell-description string). Add type-6 descriptions and point both gram spells at them.
	//
	// Idempotent; guarded so it re-runs until both the item flags and the spell descnums are set.
	ManifestEntry{
		.version = 49,
		.description = "2026_09_19_greater_soul_gem_item_flags_and_descnum_fix",
		.check = "SELECT 1 FROM items WHERE id = 7000001 AND (nodrop = 0 OR norent = 0 OR stackable = 0) UNION ALL SELECT 1 FROM spells_new WHERE id IN (50015,50016) AND descnum = 0",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
UPDATE `items`
   SET `nodrop`      = 1,
       `norent`      = 1,
       `stackable`   = 1,
       `lore`        = 'A gem of concentrated experience, ready to be shattered.',
       `charmfileid` = '0'
 WHERE `id` = 7000001;

INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
 (910000002,6,'Creates a Greater Soul Gem, a tradeable gem that grants 50 AA points when used.'),
 (910000003,6,'Shatters the gem, granting you 50 AA points.')
ON DUPLICATE KEY UPDATE `value` = VALUES(`value`);

UPDATE `spells_new` SET `descnum` = 910000002 WHERE `id` = 50015;
UPDATE `spells_new` SET `descnum` = 910000003 WHERE `id` = 50016;
)",
		.content_schema_update = true,
	},

	// v50: Self-heal the alternate-currency rows and client strings a base `release-peq.sql`
	// import is missing. The base dump ships only alternate_currency ids 1 and 6 and no db_str
	// names for ids 4/5 or 30-39, so the RoF2 client's Alt. Currency tab renders the Radiant
	// Crystal (id 4) and Ebon Crystal (id 5) rows as "db unknown": the client always shows the
	// row it was sent in the populate packet, but dbstr_us.txt has no string for that currency
	// id. Restores the exact upstream PEQ rows so a fresh import matches a synced database
	// (mirrors utils/sql/peq_sync_B1a_alternate_currency.sql and
	// utils/sql/peq_sync_fix_alternate_currency_dbst.sql). Idempotent: the check returns rows
	// only while something is missing, and INSERT IGNORE never clobbers an existing row.
	// Regenerate the client files with export_client_files after this runs.
	ManifestEntry{
		.version = 50,
		.description = "2026_09_19_alt_currency_rows_and_client_strings",
		.check = "SELECT 1 FROM (SELECT 4 AS id, 17 AS type UNION ALL SELECT 4,18 UNION ALL SELECT 5,17 UNION ALL SELECT 5,18 UNION ALL SELECT 30,17 UNION ALL SELECT 30,18 UNION ALL SELECT 31,17 UNION ALL SELECT 31,18 UNION ALL SELECT 32,17 UNION ALL SELECT 32,18 UNION ALL SELECT 33,17 UNION ALL SELECT 33,18 UNION ALL SELECT 34,17 UNION ALL SELECT 34,18 UNION ALL SELECT 35,17 UNION ALL SELECT 35,18 UNION ALL SELECT 36,17 UNION ALL SELECT 36,18 UNION ALL SELECT 37,17 UNION ALL SELECT 37,18 UNION ALL SELECT 38,17 UNION ALL SELECT 38,18 UNION ALL SELECT 39,17 UNION ALL SELECT 39,18) req LEFT JOIN db_str d ON d.id = req.id AND d.type = req.type WHERE d.id IS NULL UNION ALL SELECT 1 FROM (SELECT 4 AS id UNION ALL SELECT 5 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35 UNION ALL SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39) reqc LEFT JOIN alternate_currency ac ON ac.id = reqc.id WHERE ac.id IS NULL",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
INSERT IGNORE INTO `alternate_currency` (`id`, `item_id`) VALUES
 (4, 40903),
 (5, 40902),
 (10, 79910),
 (11, 79911),
 (12, 79912),
 (13, 79913),
 (14, 100941),
 (16, 43942),
 (17, 43943),
 (18, 41408),
 (20, 47698),
 (21, 47900),
 (22, 52149),
 (23, 61080),
 (24, 61081),
 (25, 61082),
 (27, 61998),
 (28, 61999),
 (29, 63778),
 (30, 64188),
 (31, 56772),
 (32, 56773),
 (33, 85966),
 (34, 57057),
 (35, 18000),
 (36, 18441),
 (37, 18442),
 (38, 36627),
 (39, 39000);

-- db_str: type 17 = name, 18 = plural (same as singular)
INSERT IGNORE INTO `db_str` (`id`, `type`, `value`) VALUES
 (4, 17, 'Radiant Crystal'),
 (4, 18, 'Radiant Crystal'),
 (5, 17, 'Ebon Crystal'),
 (5, 18, 'Ebon Crystal'),
 (30, 17, 'Dreadstone'),
 (30, 18, 'Dreadstone'),
 (31, 17, 'Mark of Valor'),
 (31, 18, 'Mark of Valor'),
 (32, 17, 'Medal of Heroism'),
 (32, 18, 'Medal of Heroism'),
 (33, 17, 'Commemorative Coin'),
 (33, 18, 'Commemorative Coin'),
 (34, 17, 'Fist of Bayle'),
 (34, 18, 'Fist of Bayle'),
 (35, 17, 'Noble'),
 (35, 18, 'Noble'),
 (36, 17, 'Arx Energy Crystal'),
 (36, 18, 'Arx Energy Crystal'),
 (37, 17, 'Piece of Eight'),
 (37, 18, 'Piece of Eight'),
 (38, 17, 'Remnant of Tranquility'),
 (38, 18, 'Remnant of Tranquility'),
 (39, 17, 'Bifurcated Coin'),
 (39, 18, 'Bifurcated Coin');
)",
		.content_schema_update = true,
	},

	// v51: Gates of Discord / Omens of War / LDoN progression fixes.
	//  - LDoN: add the missing zone `version = 50` rows for the recruiters that request them
	//    (gukc, guke, gukg, taka, take) so their CreateExpedition instances can spawn.
	//  - progression_atlas: gate GoD abysmal (279) / inktuta (296) and the OoW Muramite
	//    Proving Grounds chambers (304-309).
	//  - progression_stages: add the OoW (Tunat`Muram Cuu Vauax) and DoN objectives the
	//    runtime plugin already uses so the two representations agree.
	// Idempotent: the check returns rows only while something is missing.
	ManifestEntry{
		.version = 51,
		.description = "2026_09_20_god_oow_ldon_progression_fixes",
		.check = "SELECT 1 FROM (SELECT 'gukc' AS sn UNION ALL SELECT 'guke' UNION ALL SELECT 'gukg' UNION ALL SELECT 'taka' UNION ALL SELECT 'take') r LEFT JOIN `zone` z ON z.short_name = r.sn AND z.version = 50 WHERE z.id IS NULL UNION ALL SELECT a.zone_id FROM (SELECT 279 AS zone_id UNION ALL SELECT 296 UNION ALL SELECT 304 UNION ALL SELECT 305 UNION ALL SELECT 306 UNION ALL SELECT 307 UNION ALL SELECT 308 UNION ALL SELECT 309) a LEFT JOIN progression_atlas pa ON pa.zone_id = a.zone_id WHERE pa.zone_id IS NULL UNION ALL SELECT s.id FROM (SELECT 18 AS id UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23) s LEFT JOIN progression_stages ps ON ps.id = s.id WHERE ps.id IS NULL",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
CREATE TEMPORARY TABLE tmp_zone_v50 LIKE `zone`;
ALTER TABLE tmp_zone_v50 DROP PRIMARY KEY, MODIFY id int(10) NULL;
INSERT INTO tmp_zone_v50
	SELECT z.* FROM `zone` z
	WHERE z.version = 0
	  AND z.short_name IN ('gukc','guke','gukg','taka','take')
	  AND NOT EXISTS (SELECT 1 FROM `zone` x WHERE x.short_name = z.short_name AND x.version = 50);
UPDATE tmp_zone_v50 SET id = NULL, version = 50;
INSERT INTO `zone` SELECT * FROM tmp_zone_v50;
DROP TEMPORARY TABLE tmp_zone_v50;

INSERT IGNORE INTO progression_atlas (zone_id, flag_id) VALUES
 (279, 5),
 (296, 5),
 (304, 6),
 (305, 6),
 (306, 6),
 (307, 6),
 (308, 6),
 (309, 6);

INSERT IGNORE INTO progression_stages (id, name, flag_id) VALUES
 (18, 'tunat`muram cuu vauax', 6),
 (19, 'xegony', 7),
 (20, 'fennin ro the tyrant of fire', 7),
 (21, 'coirnav the avatar of water', 7),
 (22, 'rathe council', 7),
 (23, 'agnarr the storm lord', 7);
)",
		.content_schema_update = true,
	},

	// v52: Omens of War task lines (ids 800000-800003): Muramite Proving Grounds,
	// Riftseekers' Sanctum, Anguish, and Dranik's Hollows. Kill activities use
	// npc_match_list = npc id and zones = zoneidnumber list. Idempotent: the check
	// returns a row while any of the four tasks or their activities are missing.
	ManifestEntry{
		.version = 52,
		.description = "2026_09_20_omens_of_war_tasks",
		.check = "SELECT 1 FROM (SELECT COUNT(*) c FROM tasks WHERE id BETWEEN 800000 AND 800003) a JOIN (SELECT COUNT(*) c FROM task_activities WHERE taskid BETWEEN 800000 AND 800003) b WHERE a.c < 4 OR b.c < 20",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
DELETE FROM task_activities WHERE taskid IN (800000,800001,800002,800003);
DELETE FROM tasks WHERE id IN (800000,800001,800002,800003);

INSERT INTO tasks
(id,type,duration,duration_code,title,description,reward_text,reward_id_list,cash_reward,exp_reward,reward_method,reward_points,reward_point_type,min_level,max_level,level_spread,min_players,max_players,repeatable,faction_reward,completion_emote,replay_timer_group,replay_timer_seconds,request_timer_group,request_timer_seconds,dz_template_id,lock_activity_id,faction_amount,enabled)
VALUES
(800000,2,0,0,'Omens of War: Muramite Proving Grounds','The Muramite Proving Grounds hold the trials the Legion of Mata Muram uses to rank its soldiers. Defeat the six chamber Masters to prove your worth and open the way to the Altar of Destruction.','Progression','',0,0,0,0,0,65,0,0,0,0,0,0,'You have bested the Masters of the Proving Grounds. The way deeper into the Muramite stronghold lies open.',0,0,0,0,0,-1,0,1),
(800001,2,0,0,'Omens of War: Riftseekers Sanctum','The Riftseekers guard the approach to the Altar of Destruction. Slay the King and Queen who command them.','Progression','',0,0,0,0,0,65,0,0,0,0,0,0,'The Riftseeker court has fallen. The path to Anguish grows nearer.',0,0,0,0,0,-1,0,1),
(800002,2,0,0,'Omens of War: Anguish, the Fallen Palace','Anguish is the seat of the Legion of Mata Muram. Cut down its wardens and its Overlord to end the Muramite threat.','Progression','',0,0,0,0,0,65,0,0,0,0,0,0,'The Overlord of the Muramites has been slain. Omens of War is complete.',0,0,0,0,0,-1,0,1),
(800003,2,0,0,'Omens of War: Draniks Hollows','The Draniks Hollows are twisted warrens beneath the Bloodfields. Clear the named horrors that lurk within.','Progression','',0,0,0,0,0,65,0,0,0,0,0,0,'The horrors of Dranik''s Hollows have been put down.',0,0,0,0,0,-1,0,1);

INSERT INTO task_activities
(taskid,activityid,req_activity_id,step,activitytype,target_name,goalmethod,goalcount,description_override,npc_match_list,item_id_list,item_list,dz_switch_id,min_x,min_y,min_z,max_x,max_y,max_z,skill_list,spell_list,zones,zone_version,optional,list_group)
VALUES
(800000,0,-1,1,2,'Master of Hate',0,1,'Defeat the Master of Hate.','304017','','',0,0,0,0,0,0,0,'-1','','304;305;306;307;308;309',-1,0,0),
(800000,1,-1,2,2,'Master of Weaponry',0,1,'Defeat the Master of Weaponry.','305004','','',0,0,0,0,0,0,0,'-1','','304;305;306;307;308;309',-1,0,0),
(800000,2,-1,3,2,'Master of Foresight',0,1,'Defeat the Master of Foresight.','306019','','',0,0,0,0,0,0,0,'-1','','304;305;306;307;308;309',-1,0,0),
(800000,3,-1,4,2,'Master of Specialization',0,1,'Defeat the Master of Specialization.','307007','','',0,0,0,0,0,0,0,'-1','','304;305;306;307;308;309',-1,0,0),
(800000,4,-1,5,2,'Master of Adaptation',0,1,'Defeat the Master of Adaptation.','308010','','',0,0,0,0,0,0,0,'-1','','304;305;306;307;308;309',-1,0,0),
(800000,5,-1,6,2,'Master of Destruction',0,1,'Defeat the Master of Destruction.','309061','','',0,0,0,0,0,0,0,'-1','','304;305;306;307;308;309',-1,0,0),
(800001,0,-1,1,2,'King Gelaqua',0,1,'Defeat King Gelaqua.','334041','','',0,0,0,0,0,0,0,'-1','','334',-1,0,0),
(800001,1,-1,2,2,'Queen Pyrilonis',0,1,'Defeat Queen Pyrilonis.','334049','','',0,0,0,0,0,0,0,'-1','','334',-1,0,0),
(800002,0,-1,1,2,'Keldovan the Harrier',0,1,'Defeat Keldovan the Harrier.','317005','','',0,0,0,0,0,0,0,'-1','','317',-1,0,0),
(800002,1,-1,2,2,'Ture',0,1,'Defeat Ture.','317003','','',0,0,0,0,0,0,0,'-1','','317',-1,0,0),
(800002,2,-1,3,2,'Jelvan',0,1,'Defeat Jelvan.','317004','','',0,0,0,0,0,0,0,'-1','','317',-1,0,0),
(800002,3,-1,4,2,'Warden Hanvar',0,1,'Defeat Warden Hanvar.','317002','','',0,0,0,0,0,0,0,'-1','','317',-1,0,0),
(800002,4,-1,5,2,'Arch Magus Vangl',0,1,'Defeat Arch Magus Vangl.','317107','','',0,0,0,0,0,0,0,'-1','','317',-1,0,0),
(800002,5,-1,6,2,'Overlord Mata Muram',0,1,'Defeat Overlord Mata Muram.','317109','','',0,0,0,0,0,0,0,'-1','','317',-1,0,0),
(800003,0,-1,1,2,'Girplan Pathmaker',0,1,'Slay the Girplan Pathmaker.','318038','','',0,0,0,0,0,0,0,'-1','','318;319;320',-1,0,0),
(800003,1,-1,2,2,'Discordling Hollower',0,1,'Slay the Discordling Hollower.','318039','','',0,0,0,0,0,0,0,'-1','','318;319;320',-1,0,0),
(800003,2,-1,3,2,'Kyv Bowkeeper',0,1,'Slay the Kyv Bowkeeper.','319026','','',0,0,0,0,0,0,0,'-1','','318;319;320',-1,0,0),
(800003,3,-1,4,2,'Ukun Fleshrender',0,1,'Slay the Ukun Fleshrender.','319027','','',0,0,0,0,0,0,0,'-1','','318;319;320',-1,0,0),
(800003,4,-1,5,2,'Silentpaw',0,1,'Slay Silentpaw.','320012','','',0,0,0,0,0,0,0,'-1','','318;319;320',-1,0,0),
(800003,5,-1,6,2,'Muridae the Plagued',0,1,'Slay Muridae the Plagued.','320026','','',0,0,0,0,0,0,0,'-1','','318;319;320',-1,0,0);
)",
		.content_schema_update = true,
	},

	// v53: LDoN Rujarkian Hills dungeons rujb/rujc/ruje. Adds zone version 50 rows, a
	// reused rujd NPC cast placed at interior points derived from the local client maps,
	// and three Commonlands recruiters (cloned from the camp recruiter template).
	// Idempotent: guards clear prior rows; the check verifies spawns/recruiters exist.
	ManifestEntry{
		.version = 53,
		.description = "2026_09_20_ldo_ruj_dungeons_b_c_e",
		.check = "SELECT 1 FROM (SELECT 'rujb' sn UNION ALL SELECT 'rujc' UNION ALL SELECT 'ruje') r LEFT JOIN `zone` z ON z.short_name=r.sn AND z.version=50 WHERE z.id IS NULL UNION ALL SELECT 1 FROM (SELECT COUNT(*) c FROM npc_types WHERE name IN ('Rujarkian_Scout_Delva','Rujarkian_Scout_Karn','Rujarkian_Scout_Orlo')) x WHERE x.c < 3",
		.condition = "not_empty",
		.match = "",
		.sql = R"(-- v53 guards (idempotent re-run)
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name LIKE 'rujb\_%' OR sg.name LIKE 'rujc\_%' OR sg.name LIKE 'ruje\_%';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name LIKE 'rujb\_%' OR sg.name LIKE 'rujc\_%' OR sg.name LIKE 'ruje\_%';
DELETE FROM spawngroup WHERE name LIKE 'rujb\_%' OR name LIKE 'rujc\_%' OR name LIKE 'ruje\_%';
DELETE s2 FROM spawn2 s2 JOIN spawnentry se ON s2.spawngroupID=se.spawngroupID JOIN npc_types nt ON se.npcID=nt.id WHERE nt.name IN ('Rujarkian_Scout_Delva','Rujarkian_Scout_Karn','Rujarkian_Scout_Orlo');
DELETE se FROM spawnentry se JOIN npc_types nt ON se.npcID=nt.id WHERE nt.name IN ('Rujarkian_Scout_Delva','Rujarkian_Scout_Karn','Rujarkian_Scout_Orlo');
DELETE FROM spawngroup WHERE name IN ('commonlands_rujb_scout','commonlands_rujc_scout','commonlands_ruje_scout');
DELETE FROM npc_types WHERE name IN ('Rujarkian_Scout_Delva','Rujarkian_Scout_Karn','Rujarkian_Scout_Orlo');
CREATE TEMPORARY TABLE tmp_zone_clone LIKE `zone`;
ALTER TABLE tmp_zone_clone DROP PRIMARY KEY, MODIFY id int(10) NULL;
INSERT INTO tmp_zone_clone SELECT z.* FROM `zone` z WHERE z.version=0 AND z.short_name IN ('rujb','rujc','ruje') AND NOT EXISTS (SELECT 1 FROM `zone` x WHERE x.short_name=z.short_name AND x.version=50);
UPDATE tmp_zone_clone SET id=NULL, version=50;
INSERT INTO `zone` SELECT * FROM tmp_zone_clone;
DROP TEMPORARY TABLE tmp_zone_clone;
-- Auto-generated LDoN ruj dungeon spawns (rujb/rujc/ruje)
-- Interior points derived from C:\games\Eqtriune\maps; cast reused from rujd v50

-- ===== rujb =====
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_boss_1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245199, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, -544.45, -328, -25, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_warrior_2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, -676, -328, -20, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_warrior_3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, -412.91, -328, -26, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_warrior_4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, -380.02, -166, -28, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_warrior_5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, -511.57, -166, -20, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_healer_6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245236, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, -133.37, -166, -27, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_healer_7',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245236, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, 343.49, -1165, -79.35, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_shaman_8',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245230, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, 524.36, -922, -14, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_shaman_9',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245230, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, -199.14, 995, -14, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_blackhand_10',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245231, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, -67.6, -1057, -21.85, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_blackhand_11',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245231, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, -676, -166, -20, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_dog_12',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245201, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, 31.06, 671, -14, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujb_dog_13',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245201, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujb', 50, 672.35, -355, -27, 0, 600);

-- ===== rujc =====
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_boss_1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245199, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, -1097, 256.66, -9, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_warrior_2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, -959.83, 256.66, -9, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_warrior_3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, -822.67, 256.66, -9, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_warrior_4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, -685.5, 256.66, -9, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_warrior_5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, -27.1, 256.66, -7, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_healer_6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245236, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, -164.27, 256.66, -10, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_healer_7',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245236, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, -548.33, 256.66, -3, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_shaman_8',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245230, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, -301.43, 256.66, -9, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_shaman_9',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245230, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, 110.07, 256.66, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_blackhand_10',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245231, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, 1152.53, -143.94, 6, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_blackhand_11',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245231, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, 329.53, 167.63, -5.43, 0, 600);
)" R"(INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_dog_12',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245201, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, 247.23, 256.66, -1.57, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rujc_dog_13',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245201, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rujc', 50, -109.4, -54.92, -10, 0, 600);

-- ===== ruje =====
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_boss_1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245199, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1619, 1254.3, -180, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_warrior_2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1619, 644.7, -190.5, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_warrior_3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1489.8, 1254.3, -180, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_warrior_4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1619, 835.2, -181, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_warrior_5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245227, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1489.8, 644.7, -180, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_healer_6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245236, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1360.6, 1254.3, -180, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_healer_7',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245236, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -693.07, 1254.3, -184, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_shaman_8',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245230, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -563.87, 1254.3, -189, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_shaman_9',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245230, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1489.8, 835.2, -181, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_blackhand_10',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245231, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1619, 378, -190.5, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_blackhand_11',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245231, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -822.27, 1254.3, -171, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_dog_12',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245201, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1231.4, 1254.3, -180, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ruje_dog_13',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 245201, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ruje', 50, -1360.6, 644.7, -180, 0, 600);



-- New LDoN ruj recruiters (rujb/rujc/ruje) for the Commonlands camp.
-- Clones the Chaenz_Abella recruiter npc_type (408152) into three new NPCs.

CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
ALTER TABLE tmp_npc DROP PRIMARY KEY, MODIFY id int(11) NULL;

INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id=408152;
UPDATE tmp_npc SET id=NULL, name='Rujarkian_Scout_Delva';
INSERT INTO npc_types SELECT * FROM tmp_npc;
SET @n1 := LAST_INSERT_ID();

UPDATE tmp_npc SET id=NULL, name='Rujarkian_Scout_Karn';
INSERT INTO npc_types SELECT * FROM tmp_npc;
SET @n2 := LAST_INSERT_ID();

UPDATE tmp_npc SET id=NULL, name='Rujarkian_Scout_Orlo';
INSERT INTO npc_types SELECT * FROM tmp_npc;
SET @n3 := LAST_INSERT_ID();

DROP TEMPORARY TABLE tmp_npc;

-- spawn Delva (rujb)
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('commonlands_rujb_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g1 := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g1, @n1, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g1, 'commonlands', 0, -2540, -1710, 35.625, 0, 600);

-- spawn Karn (rujc)
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('commonlands_rujc_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g2 := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g2, @n2, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g2, 'commonlands', 0, -2545, -1745, 35.5, 0, 600);

-- spawn Orlo (ruje)
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('commonlands_ruje_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g3 := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g3, @n3, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g3, 'commonlands', 0, -2480, -1700, 35.5, 0, 600);

)",
		.content_schema_update = true,
	},

	// v54: Dedicated Rujarkian Hills rujg recruiter (Hidden Vale of Deceit) for the
	// Commonlands camp, so the rujg raid is reachable without touching Chaenz_Abella's
	// Wayfarers emblem quest. Idempotent: guards clear prior rows.
	ManifestEntry{
		.version = 54,
		.description = "2026_09_20_ldo_rujg_recruiter",
		.check = "SELECT 1 FROM (SELECT COUNT(*) c FROM npc_types WHERE name='Rujarkian_Scout_Hessa') x WHERE x.c = 0",
		.condition = "not_empty",
		.match = "",
		.sql = R"(-- v54 guards (idempotent re-run)
DELETE s2 FROM spawn2 s2 JOIN spawnentry se ON s2.spawngroupID=se.spawngroupID JOIN npc_types nt ON se.npcID=nt.id WHERE nt.name='Rujarkian_Scout_Hessa';
DELETE se FROM spawnentry se JOIN npc_types nt ON se.npcID=nt.id WHERE nt.name='Rujarkian_Scout_Hessa';
DELETE FROM spawngroup WHERE name='commonlands_rujg_scout';
DELETE FROM npc_types WHERE name='Rujarkian_Scout_Hessa';

CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
ALTER TABLE tmp_npc DROP PRIMARY KEY, MODIFY id int(11) NULL;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id=408152;
UPDATE tmp_npc SET id=NULL, name='Rujarkian_Scout_Hessa';
INSERT INTO npc_types SELECT * FROM tmp_npc;
SET @n := LAST_INSERT_ID();
DROP TEMPORARY TABLE tmp_npc;

INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('commonlands_rujg_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, @n, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'commonlands', 0, -2470, -1730, 35.5, 0, 600);
)",
		.content_schema_update = true,
	},

	// v55: Consolidate the Rujarkian LDoN recruiters into the ecommons tunnel camp and
	// make Gaddius a working merchant (he was a DiscordMerchant with no inventory).
	// Idempotent: the check verifies Gaddius and the ecommons scout spawngroups.
	ManifestEntry{
		.version = 55,
		.description = "2026_09_20_ecommons_recruiters_and_gaddius",
		.check = "SELECT 1 FROM (SELECT COUNT(*) c FROM npc_types WHERE id=5555356 AND class=41 AND merchant_id=1000021) x WHERE x.c=0 UNION ALL SELECT 1 FROM (SELECT 'ecommons_rujb_scout' n UNION ALL SELECT 'ecommons_rujc_scout' UNION ALL SELECT 'ecommons_ruje_scout' UNION ALL SELECT 'ecommons_rujg_scout') r LEFT JOIN spawngroup sg ON sg.name=r.n WHERE sg.id IS NULL",
		.condition = "not_empty",
		.match = "",
		.sql = R"(-- v55: Commonlands -> ecommons recruiter consolidation + Gaddius merchant fix

-- 1. Gaddius (ecommons) was a DiscordMerchant (class 59, PvP points) with no merchant list.
--    Make him a normal merchant with the custom general-supplies list.
UPDATE npc_types SET class = 41, merchant_id = 1000021 WHERE id = 5555356;

-- 2. Remove the Commonlands duplicates of Luarnn/Uzmanya (the ecommons 22111/22112 remain).
DELETE s2 FROM spawn2 s2 JOIN spawnentry se ON s2.spawngroupID = se.spawngroupID WHERE se.npcID IN (408151,408153);
DELETE se FROM spawnentry se WHERE se.npcID IN (408151,408153);

-- 3. Clear the Commonlands scout recruiters (created by v53) so they can move to ecommons.
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID = sg.id WHERE sg.name IN ('commonlands_rujb_scout','commonlands_rujc_scout','commonlands_ruje_scout','commonlands_rujg_scout');
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID = sg.id WHERE sg.name IN ('commonlands_rujb_scout','commonlands_rujc_scout','commonlands_ruje_scout','commonlands_rujg_scout');
DELETE FROM spawngroup WHERE name IN ('commonlands_rujb_scout','commonlands_rujc_scout','commonlands_ruje_scout','commonlands_rujg_scout');

-- 4. Re-spawn the scout recruiters in the ecommons tunnel camp (resolve npc id by name).
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ecommons_rujb_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g1 := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) SELECT @g1, id, 100 FROM npc_types WHERE name='Rujarkian_Scout_Delva';
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g1, 'ecommons', 0, -150, -1660, 3.75, 0, 600);

INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ecommons_rujc_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g2 := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) SELECT @g2, id, 100 FROM npc_types WHERE name='Rujarkian_Scout_Karn';
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g2, 'ecommons', 0, -140, -1680, 3.75, 0, 600);

INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ecommons_ruje_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g3 := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) SELECT @g3, id, 100 FROM npc_types WHERE name='Rujarkian_Scout_Orlo';
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g3, 'ecommons', 0, -135, -1700, 3.75, 0, 600);

INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ecommons_rujg_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g4 := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) SELECT @g4, id, 100 FROM npc_types WHERE name='Rujarkian_Scout_Hessa';
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g4, 'ecommons', 0, -205, -1690, 3.75, 0, 600);
)",
		.content_schema_update = true,
	},

	// v56: LDoN dungeons gukb/gukd/takf/mirf. Adds zone version 50 rows, per-theme reused
	// casts placed at interior points derived from the local client maps, and four camp
	// recruiters (Guktan Scout Brell/Moka, Takish Scout Nareen, Miragul Scout Vosk).
	// Idempotent: guards clear prior rows; the check verifies spawns/recruiters exist.
	ManifestEntry{
		.version = 56,
		.description = "2026_09_20_ldo_gukb_gukd_takf_mirf",
		.check = "SELECT 1 FROM (SELECT 'gukb' sn UNION ALL SELECT 'gukd' UNION ALL SELECT 'takf' UNION ALL SELECT 'mirf') r WHERE (SELECT COUNT(*) FROM spawn2 s WHERE s.zone=r.sn AND s.version=50) < 9 UNION ALL SELECT 1 FROM (SELECT COUNT(*) c FROM npc_types WHERE name IN ('Guktan_Scout_Brell','Guktan_Scout_Moka','Takish_Scout_Nareen','Miragul_Scout_Vosk')) x WHERE x.c < 4",
		.condition = "not_empty",
		.match = "",
		.sql = R"(-- v56 guards (idempotent re-run)
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name LIKE 'gukb\_%' OR sg.name LIKE 'gukd\_%' OR sg.name LIKE 'takf\_%' OR sg.name LIKE 'mirf\_%';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name LIKE 'gukb\_%' OR sg.name LIKE 'gukd\_%' OR sg.name LIKE 'takf\_%' OR sg.name LIKE 'mirf\_%';
DELETE FROM spawngroup WHERE name LIKE 'gukb\_%' OR name LIKE 'gukd\_%' OR name LIKE 'takf\_%' OR name LIKE 'mirf\_%';
DELETE s2 FROM spawn2 s2 JOIN spawnentry se ON s2.spawngroupID=se.spawngroupID JOIN npc_types nt ON se.npcID=nt.id WHERE nt.name IN ('Guktan_Scout_Brell','Guktan_Scout_Moka','Takish_Scout_Nareen','Miragul_Scout_Vosk');
DELETE se FROM spawnentry se JOIN npc_types nt ON se.npcID=nt.id WHERE nt.name IN ('Guktan_Scout_Brell','Guktan_Scout_Moka','Takish_Scout_Nareen','Miragul_Scout_Vosk');
DELETE FROM spawngroup WHERE name IN ('southro_gukb_scout','sro_gukb_scout','southro_gukd_scout','sro_gukd_scout','northro_takf_scout','nro_takf_scout','everfrost_mirf_scout');
DELETE FROM npc_types WHERE name IN ('Guktan_Scout_Brell','Guktan_Scout_Moka','Takish_Scout_Nareen','Miragul_Scout_Vosk');
CREATE TEMPORARY TABLE tmp_zone_clone LIKE `zone`;
ALTER TABLE tmp_zone_clone DROP PRIMARY KEY, MODIFY id int(10) NULL;
INSERT INTO tmp_zone_clone SELECT z.* FROM `zone` z WHERE z.version=0 AND z.short_name IN ('gukb','gukd','takf','mirf') AND NOT EXISTS (SELECT 1 FROM `zone` x WHERE x.short_name=z.short_name AND x.version=50);
UPDATE tmp_zone_clone SET id=NULL, version=50;
INSERT INTO `zone` SELECT * FROM tmp_zone_clone;
DROP TEMPORARY TABLE tmp_zone_clone;
-- Auto-generated LDoN spawns for gukb/gukd/takf/mirf

-- ===== gukb =====
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_boss_1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239289, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, -745, -915.87, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_seer_2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239189, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, -745, -711.07, -10, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_assassin_3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239198, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, 33.67, -915.87, 59, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_priest_4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239273, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, -608.73, -915.87, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_knave_5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239192, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, -706.07, -267.33, 18, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_shinta_6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239271, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, -297.27, -915.87, 17, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_shaper_7',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239281, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, -102.6, -915.87, 17, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_soulreaper_8',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239279, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, 14.2, -699.69, 17, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_oculus_9',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239272, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, 169.93, -915.87, 59, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukb_dar_10',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239277, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukb', 50, -433.53, -915.87, 0, 0, 600);

-- ===== gukd =====
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_boss_1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239289, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, -483, 988.4, -27, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_seer_2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239189, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, -483, 639.31, -85, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_assassin_3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239198, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, -352.4, 988.4, -27.19, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_priest_4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239273, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, -178.27, 988.4, -11, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_knave_5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239192, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, -483, 426.82, -71.85, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_shinta_6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239271, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, -163.76, 624.13, -29, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_shaper_7',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239281, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, -18.64, 927.69, -28, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_soulreaper_8',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239279, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, -352.4, 639.31, -85, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_oculus_9',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239272, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, -236.31, 882.16, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gukd_dar_10',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 239277, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gukd', 50, 39.4, 411.64, -3, 0, 600);

-- ===== takf =====
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takf_boss_1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 231748, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takf', 50, 402.18, 1374.67, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takf_gemsetter_2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 231736, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takf', 50, 370.42, 1599.37, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takf_engineer_3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 231743, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takf', 50, 132.26, 1374.67, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takf_prodigy_4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 231774, 100);
)" R"(INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takf', 50, 259.28, 1224.87, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takf_inventor_5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 231737, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takf', 50, -74.16, 1524.47, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takf_engineer_6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 231740, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takf', 50, 52.87, 1649.3, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takf_prodigy_7',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 231741, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takf', 50, -42.4, 1349.7, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takf_gemsetter_8',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 231742, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takf', 50, -614, 750.5, 0, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takf_engineer_9',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 231784, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takf', 50, -455.22, 1274.8, -0.4, 0, 600);

-- ===== mirf =====
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mirf_boss_1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 242008, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mirf', 50, -810, 1321.41, 60, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mirf_hatchling_2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 242012, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mirf', 50, -680.11, 1321.41, 60, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mirf_mutation_3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 242013, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mirf', 50, -550.22, 1321.41, 60, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mirf_scamp_4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 242003, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mirf', 50, -420.33, 1321.41, 60, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mirf_icespinner_5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 242015, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mirf', 50, -290.44, 1321.41, 60, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mirf_vortex_6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 242006, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mirf', 50, -160.56, 1321.41, 60, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mirf_scamp_7',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 242002, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mirf', 50, -30.67, 1321.41, 60, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mirf_hatchling_8',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 242112, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mirf', 50, 99.22, 1321.41, 60, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mirf_mutation_9',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 242113, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mirf', 50, 229.11, 1321.41, 60, 0, 600);



-- v56 recruiters for gukb/gukd/takf/mirf
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
ALTER TABLE tmp_npc DROP PRIMARY KEY, MODIFY id int(11) NULL;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id=408152;

UPDATE tmp_npc SET id=NULL, name='Guktan_Scout_Brell'; INSERT INTO npc_types SELECT * FROM tmp_npc; SET @n1 := LAST_INSERT_ID();
UPDATE tmp_npc SET id=NULL, name='Guktan_Scout_Moka';  INSERT INTO npc_types SELECT * FROM tmp_npc; SET @n2 := LAST_INSERT_ID();
UPDATE tmp_npc SET id=NULL, name='Takish_Scout_Nareen'; INSERT INTO npc_types SELECT * FROM tmp_npc; SET @n3 := LAST_INSERT_ID();
UPDATE tmp_npc SET id=NULL, name='Miragul_Scout_Vosk';  INSERT INTO npc_types SELECT * FROM tmp_npc; SET @n4 := LAST_INSERT_ID();
DROP TEMPORARY TABLE tmp_npc;

-- Guktan_Scout_Brell (gukb): southro + sro
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('southro_gukb_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, @n1, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'southro', 0, -300, -120, 107.5, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('sro_gukb_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, @n1, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'sro', 0, 1015, -1490, -23.88, 0, 600);

-- Guktan_Scout_Moka (gukd): southro + sro
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('southro_gukd_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, @n2, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'southro', 0, -310, -140, 107.5, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('sro_gukd_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, @n2, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'sro', 0, 1025, -1510, -23.88, 0, 600);

-- Takish_Scout_Nareen (takf): northro + nro
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('northro_takf_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, @n3, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'northro', 0, -630, 7860, 96, 0, 600);
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('nro_takf_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, @n3, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'nro', 0, 915, 2660, -24.75, 0, 600);

-- Miragul_Scout_Vosk (mirf): everfrost
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('everfrost_mirf_scout',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, @n4, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'everfrost', 0, 5060, -1885, -64, 0, 600);

)",
		.content_schema_update = true,
	},

	// v57: Echo of the Past NPCs for the open (non-instance) zones of DoN, DoD, PoR,
	// TSS, TBS, SoF and SoD that were missing them, placed at each zone's safe spot.
	// Idempotent: each zone's echo spawngroup is cleared before re-insert; the check
	// returns a row while any target zone still lacks an Echo.
	ManifestEntry{
		.version = 57,
		.description = "2026_09_20_echoes_don_dod_por_tss_tbs_sof_sod",
		.check = "SELECT 1 FROM (SELECT 'arcstone' z UNION ALL SELECT 'ashengate' z UNION ALL SELECT 'atiiki' z UNION ALL SELECT 'barren' z UNION ALL SELECT 'bertoxtemple' z UNION ALL SELECT 'blacksail' z UNION ALL SELECT 'bloodmoon' z UNION ALL SELECT 'broodlands' z UNION ALL SELECT 'buriedsea' z UNION ALL SELECT 'commonlands' z UNION ALL SELECT 'corathus' z UNION ALL SELECT 'crescent' z UNION ALL SELECT 'cryptofshade' z UNION ALL SELECT 'crystallos' z UNION ALL SELECT 'deadbone' z UNION ALL SELECT 'devastation' z UNION ALL SELECT 'direwind' z UNION ALL SELECT 'discord' z UNION ALL SELECT 'discordtower' z UNION ALL SELECT 'dragonscale' z UNION ALL SELECT 'dreadspire' z UNION ALL SELECT 'eastkorlach' z UNION ALL SELECT 'elddar' z UNION ALL SELECT 'frostcrypt' z UNION ALL SELECT 'guardian' z UNION ALL SELECT 'gyrospireb' z UNION ALL SELECT 'gyrospirez' z UNION ALL SELECT 'hillsofshade' z UNION ALL SELECT 'icefall' z UNION ALL SELECT 'illsalin' z UNION ALL SELECT 'innothuleb' z UNION ALL SELECT 'jardelshook' z UNION ALL SELECT 'kattacastrum' z UNION ALL SELECT 'korascian' z UNION ALL SELECT 'lopingplains' z UNION ALL SELECT 'maidensgrave' z UNION ALL SELECT 'mansion' z UNION ALL SELECT 'mechanotus' z UNION ALL SELECT 'mesa' z UNION ALL SELECT 'mistythicket' z UNION ALL SELECT 'monkeyrock' z UNION ALL SELECT 'moors' z UNION ALL SELECT 'nektulosa' z UNION ALL SELECT 'northro' z UNION ALL SELECT 'oceangreenhills' z UNION ALL SELECT 'oceangreenvillage' z UNION ALL SELECT 'oceanoftears' z UNION ALL SELECT 'oldblackburrow' z UNION ALL SELECT 'oldbloodfield' z UNION ALL SELECT 'oldcommons' z UNION ALL SELECT 'olddranik' z UNION ALL SELECT 'oldfieldofbone' z UNION ALL SELECT 'oldhighpass' z UNION ALL SELECT 'oldkithicor' z UNION ALL SELECT 'oldkurn' z UNION ALL SELECT 'precipiceofwar' z UNION ALL SELECT 'rage' z UNION ALL SELECT 'rathechamber' z UNION ALL SELECT 'redfeather' z UNION ALL SELECT 'relic' z UNION ALL SELECT 'roost' z UNION ALL SELECT 'shadowspine' z UNION ALL SELECT 'silyssar' z UNION ALL SELECT 'skylance' z UNION ALL SELECT 'solteris' z UNION ALL SELECT 'southro' z UNION ALL SELECT 'steamfactory' z UNION ALL SELECT 'steamfontmts' z UNION ALL SELECT 'steppes' z UNION ALL SELECT 'stonehive' z UNION ALL SELECT 'suncrest' z UNION ALL SELECT 'sunderock' z UNION ALL SELECT 'takishruins' z UNION ALL SELECT 'thalassius' z UNION ALL SELECT 'theater' z UNION ALL SELECT 'toskirakk' z UNION ALL SELECT 'toxxulia' z UNION ALL SELECT 'valdeholm' z UNION ALL SELECT 'vergalid' z UNION ALL SELECT 'westkorlach' z UNION ALL SELECT 'zhisza' z) r WHERE NOT EXISTS (SELECT 1 FROM spawn2 s2 JOIN spawnentry se ON s2.spawngroupID=se.spawngroupID JOIN npc_types nt ON se.npcID=nt.id WHERE s2.zone=r.z AND nt.name='Echo_of_the_Past')",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
-- Auto-generated Echo of the Past spawns for expansions 9-15 (open zones)

-- arcstone
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='arcstone_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='arcstone_echo';
DELETE FROM spawngroup WHERE name='arcstone_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('arcstone_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'arcstone', 0, 1630, -279, 5, 0, 600);
-- ashengate
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='ashengate_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='ashengate_echo';
DELETE FROM spawngroup WHERE name='ashengate_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('ashengate_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'ashengate', 0, 0, -375, 8, 0, 600);
-- atiiki
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='atiiki_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='atiiki_echo';
DELETE FROM spawngroup WHERE name='atiiki_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('atiiki_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'atiiki', 0, -916, -1089, -39, 0, 600);
-- barren
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='barren_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='barren_echo';
DELETE FROM spawngroup WHERE name='barren_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('barren_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'barren', 0, 1203, 698, 54, 0, 600);
-- bertoxtemple
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='bertoxtemple_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='bertoxtemple_echo';
DELETE FROM spawngroup WHERE name='bertoxtemple_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('bertoxtemple_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'bertoxtemple', 0, 2, -2, 2, 0, 600);
-- blacksail
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='blacksail_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='blacksail_echo';
DELETE FROM spawngroup WHERE name='blacksail_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('blacksail_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'blacksail', 0, -165, 5410, 307, 0, 600);
-- bloodmoon
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='bloodmoon_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='bloodmoon_echo';
DELETE FROM spawngroup WHERE name='bloodmoon_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('bloodmoon_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'bloodmoon', 0, -4, 34, 8, 0, 600);
-- broodlands
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='broodlands_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='broodlands_echo';
DELETE FROM spawngroup WHERE name='broodlands_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('broodlands_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'broodlands', 0, -1613, -1016, 99, 0, 600);
-- buriedsea
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='buriedsea_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='buriedsea_echo';
DELETE FROM spawngroup WHERE name='buriedsea_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('buriedsea_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'buriedsea', 0, 3130, -1721, 308, 0, 600);
-- commonlands
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='commonlands_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='commonlands_echo';
DELETE FROM spawngroup WHERE name='commonlands_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('commonlands_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'commonlands', 0, -3492, 180, 15, 0, 600);
-- corathus
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='corathus_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='corathus_echo';
DELETE FROM spawngroup WHERE name='corathus_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('corathus_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'corathus', 0, 16, -337, -46, 0, 600);
-- crescent
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='crescent_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='crescent_echo';
DELETE FROM spawngroup WHERE name='crescent_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('crescent_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'crescent', 0, -8, 11, 2, 0, 600);
-- cryptofshade
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='cryptofshade_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='cryptofshade_echo';
DELETE FROM spawngroup WHERE name='cryptofshade_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('cryptofshade_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'cryptofshade', 0, 985, -445, -39, 0, 600);
-- crystallos
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='crystallos_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='crystallos_echo';
DELETE FROM spawngroup WHERE name='crystallos_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('crystallos_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'crystallos', 0, -65, -200, -75, 0, 600);
-- deadbone
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='deadbone_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='deadbone_echo';
DELETE FROM spawngroup WHERE name='deadbone_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('deadbone_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'deadbone', 0, -3817, 4044, 314, 0, 600);
-- devastation
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='devastation_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='devastation_echo';
DELETE FROM spawngroup WHERE name='devastation_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('devastation_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'devastation', 0, 1390, 216, 53, 0, 600);
-- direwind
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='direwind_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='direwind_echo';
DELETE FROM spawngroup WHERE name='direwind_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('direwind_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
)" R"(INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'direwind', 0, -329, -1845, 10, 0, 600);
-- discord
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='discord_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='discord_echo';
DELETE FROM spawngroup WHERE name='discord_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('discord_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'discord', 0, 28, -20, -16, 0, 600);
-- discordtower
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='discordtower_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='discordtower_echo';
DELETE FROM spawngroup WHERE name='discordtower_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('discordtower_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'discordtower', 0, 0, -48, -48, 0, 600);
-- dragonscale
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='dragonscale_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='dragonscale_echo';
DELETE FROM spawngroup WHERE name='dragonscale_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('dragonscale_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'dragonscale', 0, -1954, 3916, 19, 0, 600);
-- dreadspire
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='dreadspire_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='dreadspire_echo';
DELETE FROM spawngroup WHERE name='dreadspire_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('dreadspire_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'dreadspire', 0, 1358, -1030, -572, 0, 600);
-- eastkorlach
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='eastkorlach_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='eastkorlach_echo';
DELETE FROM spawngroup WHERE name='eastkorlach_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('eastkorlach_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'eastkorlach', 0, -950, -1130, 184, 0, 600);
-- elddar
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='elddar_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='elddar_echo';
DELETE FROM spawngroup WHERE name='elddar_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('elddar_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'elddar', 0, 606, 296, -36, 0, 600);
-- frostcrypt
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='frostcrypt_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='frostcrypt_echo';
DELETE FROM spawngroup WHERE name='frostcrypt_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('frostcrypt_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'frostcrypt', 0, 0, -40, 2, 0, 600);
-- guardian
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='guardian_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='guardian_echo';
DELETE FROM spawngroup WHERE name='guardian_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('guardian_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'guardian', 0, -115, 60, 4, 0, 600);
-- gyrospireb
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='gyrospireb_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='gyrospireb_echo';
DELETE FROM spawngroup WHERE name='gyrospireb_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gyrospireb_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gyrospireb', 0, -9, -843, 4, 0, 600);
-- gyrospirez
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='gyrospirez_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='gyrospirez_echo';
DELETE FROM spawngroup WHERE name='gyrospirez_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('gyrospirez_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'gyrospirez', 0, -9, -843, 4, 0, 600);
-- hillsofshade
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='hillsofshade_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='hillsofshade_echo';
DELETE FROM spawngroup WHERE name='hillsofshade_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('hillsofshade_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'hillsofshade', 0, -216, -1950, -50, 0, 600);
-- icefall
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='icefall_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='icefall_echo';
DELETE FROM spawngroup WHERE name='icefall_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('icefall_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'icefall', 0, 765, -1871, -46, 0, 600);
-- illsalin
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='illsalin_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='illsalin_echo';
DELETE FROM spawngroup WHERE name='illsalin_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('illsalin_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'illsalin', 0, 308, -182, -32, 0, 600);
-- innothuleb
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='innothuleb_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='innothuleb_echo';
DELETE FROM spawngroup WHERE name='innothuleb_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('innothuleb_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'innothuleb', 0, -1029, -1778, 19, 0, 600);
-- jardelshook
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='jardelshook_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='jardelshook_echo';
DELETE FROM spawngroup WHERE name='jardelshook_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('jardelshook_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'jardelshook', 0, 4677, -784, 373, 0, 600);
-- kattacastrum
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='kattacastrum_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='kattacastrum_echo';
DELETE FROM spawngroup WHERE name='kattacastrum_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('kattacastrum_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'kattacastrum', 0, -2, -425, -20, 0, 600);
-- korascian
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='korascian_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='korascian_echo';
DELETE FROM spawngroup WHERE name='korascian_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('korascian_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
)" R"(INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'korascian', 0, 24, -77, 25, 0, 600);
-- lopingplains
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='lopingplains_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='lopingplains_echo';
DELETE FROM spawngroup WHERE name='lopingplains_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('lopingplains_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'lopingplains', 0, -3698, -1289, 722, 0, 600);
-- maidensgrave
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='maidensgrave_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='maidensgrave_echo';
DELETE FROM spawngroup WHERE name='maidensgrave_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('maidensgrave_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'maidensgrave', 0, 4455, 2042, 307, 0, 600);
-- mansion
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='mansion_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='mansion_echo';
DELETE FROM spawngroup WHERE name='mansion_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mansion_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mansion', 0, 0, -73, 3, 0, 600);
-- mechanotus
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='mechanotus_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='mechanotus_echo';
DELETE FROM spawngroup WHERE name='mechanotus_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mechanotus_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mechanotus', 0, -1700, 350, 404, 0, 600);
-- mesa
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='mesa_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='mesa_echo';
DELETE FROM spawngroup WHERE name='mesa_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mesa_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mesa', 0, -85, -2050, 19, 0, 600);
-- mistythicket
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='mistythicket_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='mistythicket_echo';
DELETE FROM spawngroup WHERE name='mistythicket_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('mistythicket_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'mistythicket', 0, 662, -7, 4, 0, 600);
-- monkeyrock
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='monkeyrock_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='monkeyrock_echo';
DELETE FROM spawngroup WHERE name='monkeyrock_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('monkeyrock_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'monkeyrock', 0, -4084, -3067, 307, 0, 600);
-- moors
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='moors_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='moors_echo';
DELETE FROM spawngroup WHERE name='moors_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('moors_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'moors', 0, 3263, -626, -20, 0, 600);
-- nektulosa
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='nektulosa_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='nektulosa_echo';
DELETE FROM spawngroup WHERE name='nektulosa_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('nektulosa_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'nektulosa', 0, -11, 134, -13, 0, 600);
-- northro
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='northro_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='northro_echo';
DELETE FROM spawngroup WHERE name='northro_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('northro_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'northro', 0, -1262, 8590, 40, 0, 600);
-- oceangreenhills
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oceangreenhills_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oceangreenhills_echo';
DELETE FROM spawngroup WHERE name='oceangreenhills_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oceangreenhills_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oceangreenhills', 0, -1140, 4542, 73, 0, 600);
-- oceangreenvillage
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oceangreenvillage_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oceangreenvillage_echo';
DELETE FROM spawngroup WHERE name='oceangreenvillage_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oceangreenvillage_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oceangreenvillage', 0, 83, -72, 3, 0, 600);
-- oceanoftears
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oceanoftears_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oceanoftears_echo';
DELETE FROM spawngroup WHERE name='oceanoftears_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oceanoftears_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oceanoftears', 0, -7925, 1610, -292, 0, 600);
-- oldblackburrow
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oldblackburrow_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oldblackburrow_echo';
DELETE FROM spawngroup WHERE name='oldblackburrow_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oldblackburrow_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oldblackburrow', 0, 7, -377, 46, 0, 600);
-- oldbloodfield
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oldbloodfield_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oldbloodfield_echo';
DELETE FROM spawngroup WHERE name='oldbloodfield_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oldbloodfield_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oldbloodfield', 0, -2097, 2051, 3, 0, 600);
-- oldcommons
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oldcommons_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oldcommons_echo';
DELETE FROM spawngroup WHERE name='oldcommons_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oldcommons_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oldcommons', 0, -3492, 180, 15, 0, 600);
-- olddranik
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='olddranik_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='olddranik_echo';
DELETE FROM spawngroup WHERE name='olddranik_echo';
)" R"(INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('olddranik_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'olddranik', 0, -1799, 986, -184, 0, 600);
-- oldfieldofbone
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oldfieldofbone_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oldfieldofbone_echo';
DELETE FROM spawngroup WHERE name='oldfieldofbone_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oldfieldofbone_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oldfieldofbone', 0, 1692, 1194, -49, 0, 600);
-- oldhighpass
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oldhighpass_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oldhighpass_echo';
DELETE FROM spawngroup WHERE name='oldhighpass_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oldhighpass_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oldhighpass', 0, 0, 0, -5, 0, 600);
-- oldkithicor
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oldkithicor_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oldkithicor_echo';
DELETE FROM spawngroup WHERE name='oldkithicor_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oldkithicor_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oldkithicor', 0, -255, 1189, 10, 0, 600);
-- oldkurn
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='oldkurn_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='oldkurn_echo';
DELETE FROM spawngroup WHERE name='oldkurn_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('oldkurn_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'oldkurn', 0, 77, -268, 7, 0, 600);
-- precipiceofwar
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='precipiceofwar_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='precipiceofwar_echo';
DELETE FROM spawngroup WHERE name='precipiceofwar_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('precipiceofwar_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'precipiceofwar', 0, 985, -1110, 285, 0, 600);
-- rage
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='rage_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='rage_echo';
DELETE FROM spawngroup WHERE name='rage_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rage_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rage', 0, 0, 1065, 7, 0, 600);
-- rathechamber
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='rathechamber_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='rathechamber_echo';
DELETE FROM spawngroup WHERE name='rathechamber_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('rathechamber_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'rathechamber', 0, -19, -10, -22, 0, 600);
-- redfeather
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='redfeather_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='redfeather_echo';
DELETE FROM spawngroup WHERE name='redfeather_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('redfeather_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'redfeather', 0, 2531, -3638, 312, 0, 600);
-- relic
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='relic_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='relic_echo';
DELETE FROM spawngroup WHERE name='relic_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('relic_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'relic', 0, 861, 618, -265, 0, 600);
-- roost
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='roost_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='roost_echo';
DELETE FROM spawngroup WHERE name='roost_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('roost_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'roost', 0, -1592, 2125, -308, 0, 600);
-- shadowspine
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='shadowspine_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='shadowspine_echo';
DELETE FROM spawngroup WHERE name='shadowspine_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('shadowspine_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'shadowspine', 0, 2, 408, 72, 0, 600);
-- silyssar
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='silyssar_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='silyssar_echo';
DELETE FROM spawngroup WHERE name='silyssar_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('silyssar_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'silyssar', 0, 167, -50, -66, 0, 600);
-- skylance
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='skylance_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='skylance_echo';
DELETE FROM spawngroup WHERE name='skylance_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('skylance_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'skylance', 0, 0, -95, 2, 0, 600);
-- solteris
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='solteris_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='solteris_echo';
DELETE FROM spawngroup WHERE name='solteris_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('solteris_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'solteris', 0, 0, 0, -20, 0, 600);
-- southro
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='southro_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='southro_echo';
DELETE FROM spawngroup WHERE name='southro_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('southro_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'southro', 0, -581, -520, 126, 0, 600);
-- steamfactory
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='steamfactory_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='steamfactory_echo';
DELETE FROM spawngroup WHERE name='steamfactory_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('steamfactory_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'steamfactory', 0, -870, 66, 121, 0, 600);
-- steamfontmts
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='steamfontmts_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='steamfontmts_echo';
DELETE FROM spawngroup WHERE name='steamfontmts_echo';
)" R"(INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('steamfontmts_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'steamfontmts', 0, -170, -42, 2, 0, 600);
-- steppes
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='steppes_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='steppes_echo';
DELETE FROM spawngroup WHERE name='steppes_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('steppes_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'steppes', 0, -896, -2360, 3, 0, 600);
-- stonehive
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='stonehive_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='stonehive_echo';
DELETE FROM spawngroup WHERE name='stonehive_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('stonehive_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'stonehive', 0, -1331, -521, 26, 0, 600);
-- suncrest
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='suncrest_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='suncrest_echo';
DELETE FROM spawngroup WHERE name='suncrest_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('suncrest_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'suncrest', 0, -2241, -650, 316, 0, 600);
-- sunderock
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='sunderock_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='sunderock_echo';
DELETE FROM spawngroup WHERE name='sunderock_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('sunderock_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'sunderock', 0, -393, -3454, 4, 0, 600);
-- takishruins
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='takishruins_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='takishruins_echo';
DELETE FROM spawngroup WHERE name='takishruins_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('takishruins_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'takishruins', 0, -983, 269, 62, 0, 600);
-- thalassius
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='thalassius_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='thalassius_echo';
DELETE FROM spawngroup WHERE name='thalassius_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('thalassius_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'thalassius', 0, 37, -86, 23, 0, 600);
-- theater
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='theater_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='theater_echo';
DELETE FROM spawngroup WHERE name='theater_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('theater_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'theater', 0, 2933, 719, 376, 0, 600);
-- toskirakk
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='toskirakk_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='toskirakk_echo';
DELETE FROM spawngroup WHERE name='toskirakk_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('toskirakk_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'toskirakk', 0, -402.5, 309.17, 20.18, 0, 600);
-- toxxulia
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='toxxulia_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='toxxulia_echo';
DELETE FROM spawngroup WHERE name='toxxulia_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('toxxulia_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'toxxulia', 0, -718, 2102, 26, 0, 600);
-- valdeholm
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='valdeholm_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='valdeholm_echo';
DELETE FROM spawngroup WHERE name='valdeholm_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('valdeholm_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'valdeholm', 0, 119, -3215, 3, 0, 600);
-- vergalid
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='vergalid_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='vergalid_echo';
DELETE FROM spawngroup WHERE name='vergalid_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('vergalid_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'vergalid', 0, 14, 0, 3, 0, 600);
-- westkorlach
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='westkorlach_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='westkorlach_echo';
DELETE FROM spawngroup WHERE name='westkorlach_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('westkorlach_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'westkorlach', 0, -2229, 395, 895, 0, 600);
-- zhisza
DELETE se FROM spawnentry se JOIN spawngroup sg ON se.spawngroupID=sg.id WHERE sg.name='zhisza_echo';
DELETE s2 FROM spawn2 s2 JOIN spawngroup sg ON s2.spawngroupID=sg.id WHERE sg.name='zhisza_echo';
DELETE FROM spawngroup WHERE name='zhisza_echo';
INSERT INTO spawngroup (name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns) VALUES ('zhisza_echo',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@g, 111222, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime) VALUES (@g, 'zhisza', 0, 6, -856, 5, 0, 600);


)",
		.content_schema_update = true,
	},

	// ------------------------------------------------------------------------------------------------
	// Version 58: Normalize orphaned augment types (7/8/9/12) onto the live slot scheme.
	//
	// The live `items` set uses the classic augment-slot scheme (armor a1=1/a2=2, weapons
	// a1=2/a2=4) but the augment bitmasks were never normalized, so augs carrying bits for slot
	// types 7/8/9/12 can only fit gear slots that barely exist live (type 7 = 1 item, type 8 = 1
	// item, types 9/12 = none). ItemInstance::IsAugmentSlotAvailable matches via
	// (1 << (gear_slot_type - 1)) & augtype, so this rewrites each such augment's augtype into the
	// live scheme, classified by the augment's own `slots` bitmask:
	//   armor-only (slots has armor positions, no Primary/Secondary/Range) -> 2  (Elite)
	//   weapon-only (slots has Primary/Secondary/Range, no armor)          -> 8  (Weapon)
	//   both / neither                                                     -> 10 (2|8)
	// All-bits "soul" augments (augtype = 1073741823, ids 160000+) are intentionally left
	// universal. Bits 64|128|256|2048 = slot types 7|8|9|12; armor mask 2070526, weapon 2133776.
	// The companion gear UPDATE moves the one live type-8 slot (Heart Strike, Cleavers Dream) onto
	// the weapon slot. The check empties once converted, so this is idempotent.
	// ------------------------------------------------------------------------------------------------
	ManifestEntry{
		.version = 58,
		.description = "2026_09_20_normalize_orphaned_augment_types",
		.check = "SELECT 1 FROM `items` WHERE `itemtype` = 54 AND (`augtype` & 2496) <> 0 AND `augtype` <> 1073741823 LIMIT 1",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
-- Augments: replace slot-type bits 7/8/9/12 with the live scheme (Elite / Weapon).
UPDATE `items`
   SET `augtype` = CASE
       WHEN (`slots` & 2070526) <> 0 AND (`slots` & 2133776) = 0 THEN 2
       WHEN (`slots` & 2133776) <> 0 AND (`slots` & 2070526) = 0 THEN 8
       ELSE 10
   END
 WHERE `itemtype` = 54
   AND (`augtype` & 2496) <> 0
   AND `augtype` <> 1073741823;

-- Gear: the single live type-8 slot (Heart Strike, Cleavers Dream) -> weapon aug slot.
UPDATE `items`
   SET `augslot1type` = 4
 WHERE `id` = 9011011 AND `augslot1type` = 8;
)",
		.content_schema_update = true,
	},

	// ------------------------------------------------------------------------------------------------
	// Version 59: Keep the dynamic zone pool usable after a fresh DB import.
	//
	// Only one launcher (peq) is started by start-servers.bat, and the stock launcher row ships
	// dynamics = 5, so the server can host just five non-static zones at once. When all five are
	// held (zones stay assigned for seconds_before_idle / shutdowndelay after the last player
	// leaves), ZSList::TriggerBootup returns 0, world logs "failed to boot a zone for [<player>]"
	// and the client is bounced back to the zone it came from. Raise peq's dynamic count so hubs
	// like Sanctus Seru always get a slot.
	//
	// The guard only fires while dynamics is below 20, so this can never lower a pool an operator
	// has intentionally raised, and the check empties once applied (idempotent).
	// ------------------------------------------------------------------------------------------------
	ManifestEntry{
		.version = 59,
		.description = "2026_09_20_raise_peq_dynamic_zone_pool",
		.check = "SELECT 1 FROM `launcher` WHERE `name` = 'peq' AND `dynamics` < 20 LIMIT 1",
		.condition = "not_empty",
		.match = "",
		.sql = R"(
UPDATE `launcher` SET `dynamics` = 20 WHERE `name` = 'peq' AND `dynamics` < 20;
)",
		.content_schema_update = false,
	},

	// ------------------------------------------------------------------------------------------------
	// Version 60: TBS Solteris raid layer (zone 421). Companion to the 20260920_tbs_solteris_*
	// files and Release-NMS-Quests/solteris/. PEQ ships island-1 statics (sisters 421001-3,
	// Lochmaul 421005, Aprosis 421006, trash 421008-421021) with stub HPs; this entry trues up
	// their stats, adds the island 2-4 event NPCs (421022-421098; block verified empty), event
	// loot chests with lootdrops in the free 6210000-6210099 range, and throne-approach trash
	// that drops Shard of Eternal Light (53473) for the Two Gods event. The Two Gods clones
	// (421097 Solusek Ro / 421098 Mayong Mistmoore) carry clean names matching the SoF
	// progression subflags, unblocking the SoF stage via the hail-mob flag system. Bosses are
	// spawned per-expedition by the zone controller (421000.lua) gated on 4d12h lockouts, so
	// nothing here needs a static boss spawn. Idempotent: content blocks are deleted before
	// re-insert; the check empties once applied.
	// ------------------------------------------------------------------------------------------------
	ManifestEntry{
		.version = 60,
		.description = "2026_09_21_tbs_solteris_raid_layer",
		.check = "SELECT 1 FROM `npc_types` WHERE `id` = 421030 LIMIT 1",
		.condition = "empty",
		.match = "",
		.sql = std::string(R"(
-- ============================================================================
-- TBS Solteris raid layer (zone 421): island 2-4 events, raid loot, SoF flags
-- Same content as utils/sql/20260921_tbs_solteris_raid.sql (keep in sync).
-- ============================================================================

-- 1. Island-1 event NPCs: replace PEQ stub stats with raid-tier values
--    (calibration: Ture 317003 = 2.5M hp @ 80; Mayong 351118 = 8.07M @ 85)
UPDATE `npc_types` SET
    `hp` = 1200000, `AC` = 600, `ATK` = 300, `Accuracy` = 350, `findable` = 1
  WHERE `id` IN (421001,421002,421003);

UPDATE `npc_types` SET
    `hp` = 2200000, `AC` = 580, `ATK` = 350, `Accuracy` = 400, `findable` = 1
  WHERE `id` = 421005;

UPDATE `npc_types` SET
    `hp` = 2600000, `AC` = 600, `ATK` = 380, `Accuracy` = 420, `findable` = 1
  WHERE `id` = 421006;

-- 2. New event NPCs (temp-table clones keep npc_types schema-proof)

-- 421022 A_Sun_Sworn_Knight: island-4 trash pack leader (drops Shard 53473)
DELETE FROM `spawn2` WHERE `zone` = 'solteris' AND `spawngroupID` IN (SELECT spawngroupID FROM spawnentry WHERE npcID = 421022);
DELETE FROM `spawnentry` WHERE `npcID` = 421022;
DELETE FROM `spawngroup` WHERE `name` LIKE 'solteris_throne_trash%';
DELETE FROM `npc_types` WHERE `id` = 421022;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421021;
UPDATE tmp_solteris_npc SET id = 421022, name = 'A_Sun_Sworn_Knight', level = 80, maxlevel = 80,
    hp = 700000, AC = 550, ATK = 340, Accuracy = 400, loottable_id = 6210021, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421030-421038: Guardians of the Nine Primes (Mistresses event, scripted summons)
DELETE FROM `npc_types` WHERE `id` BETWEEN 421030 AND 421038;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421008;
UPDATE tmp_solteris_npc SET id = 421030, name = 'Guardian_of_the_First_Prime',  level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421031, name = 'Guardian_of_the_Second_Prime';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421014;
UPDATE tmp_solteris_npc SET id = 421032, name = 'Guardian_of_the_Third_Prime',  level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421033, name = 'Guardian_of_the_Fourth_Prime';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421001;
UPDATE tmp_solteris_npc SET id = 421034, name = 'Guardian_of_the_Fifth_Prime',  level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421035, name = 'Guardian_of_the_Sixth_Prime';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421012;
UPDATE tmp_solteris_npc SET id = 421036, name = 'Guardian_of_the_Seventh_Prime', level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421038, name = 'Guardian_of_the_Ninth_Prime';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421014;
UPDATE tmp_solteris_npc SET id = 421037, name = 'Guardian_of_the_Eighth_Prime', level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421040-421043: Balreth + golem split tiers + fail adds (construct model: Ture race 412)
DELETE FROM `npc_types` WHERE `id` BETWEEN 421040 AND 421043;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 317003;
UPDATE tmp_solteris_npc SET id = 421040, name = '#Rear_Guard_Captain_Balreth', level = 84, maxlevel = 84,
    hp = 1800000, AC = 590, ATK = 320, Accuracy = 380, loottable_id = 0, npc_faction_id = 1354, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421041, name = 'a_gargantuan_golem',     hp = 900000;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421042, name = 'a_massive_golem',        hp = 450000;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421043, name = 'an_uncontrollable_golem', hp = 500000, ATK = 400, Accuracy = 420;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421045-421049: Astire + the four weapon Guardians
DELETE FROM `npc_types` WHERE `id` BETWEEN 421045 AND 421049;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421001;
UPDATE tmp_solteris_npc SET id = 421045, name = '#Astire_the_Lunar_Eclipse', level = 85, maxlevel = 85,
    hp = 3200000, AC = 620, ATK = 420, Accuracy = 450, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421008;
UPDATE tmp_solteris_npc SET id = 421046, name = 'Guardian_of_the_Spear', level = 83, maxlevel = 83, hp = 900000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421012;
UPDATE tmp_solteris_npc SET id = 421047, name = 'Guardian_of_the_Staff', level = 83, maxlevel = 83, hp = 900000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421014;
UPDATE tmp_solteris_npc SET id = 421048, name = 'Guardian_of_the_Sword', level = 83, maxlevel = 83, hp = 900000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421049, name = 'Guardian_of_the_Fist';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421055-421057: Irrissa the Seer + trueborn summoners + portal attendants
DELETE FROM `npc_types` WHERE `id` BETWEEN 421055 AND 421057;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421008;
UPDATE tmp_solteris_npc SET id = 421055, name = '#Irrissa_the_Seer', level = 85, maxlevel = 85,
    hp = 3500000, AC = 620, ATK = 420, Accuracy = 450, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421018;
UPDATE tmp_solteris_npc SET id = 421056, name = 'a_trueborn_summoner', level = 80, maxlevel = 80, hp = 350000, AC = 500, ATK = 260, Accuracy = 340, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421020;
UPDATE tmp_solteris_npc SET id = 421057, name = 'a_portal_attendant', level = 76, maxlevel = 76, hp = 120000, AC = 450, ATK = 220, Accuracy = 300, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421065-421073: Commodus + the eight Aspects
DELETE FROM `npc_types` WHERE `id` BETWEEN 421065 AND 421073;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 317003;
UPDATE tmp_solteris_npc SET id = 421065, name = '#Commodus_Solar_Construct', level = 85, maxlevel = 85,
    hp = 3800000, AC = 620, ATK = 420, Accuracy = 450, loottable_id = 0, npc_faction_id = 1354, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421017;
UPDATE tmp_solteris_npc SET id = 421066, name = 'Aspect_of_Temperance',     level = 84, maxlevel = 84, hp = 900000, AC = 560, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421067, name = 'Aspect_of_Justice';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421068, name = 'Aspect_of_Wisdom';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421069, name = 'Aspect_of_Fortitude';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421070, name = 'Aspect_of_Courage';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421071, name = 'Aspect_of_Devotion';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421072, name = 'Aspect_of_Ambition';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421073, name = 'Aspect_of_Resourcefulness';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421080-421084: event adds
DELETE FROM `npc_types` WHERE `id` BETWEEN 421080 AND 421084;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421012;
UPDATE tmp_solteris_npc SET id = 421080, name = 'Liquid_Magma',            level = 80, maxlevel = 80, hp = 100000, AC = 450, ATK = 240, Accuracy = 320, loottable_id = 0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421081, name = 'Convergence_of_the_Sun',  hp = 50000;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421082, name = 'a_living_flame',          hp = 60000;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421084, name = 'an_unholy_dervish',       hp = 120000, ATK = 280;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
)")
			+ R"(CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421014;
UPDATE tmp_solteris_npc SET id = 421083, name = 'a_shade_bat',             level = 78, maxlevel = 78, hp = 30000, AC = 400, ATK = 200, Accuracy = 300, loottable_id = 0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421090-421096: event loot chests (clone Anguish Ornate_Chest)
DELETE FROM `npc_types` WHERE `id` BETWEEN 421090 AND 421096;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 317112;
UPDATE tmp_solteris_npc SET id = 421090, name = 'Ornate_Chest', loottable_id = 6210011, npc_faction_id = 0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421091, loottable_id = 6210012; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421092, loottable_id = 6210013; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421093, loottable_id = 6210014; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421094, loottable_id = 6210015; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421095, loottable_id = 6210016; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421096, loottable_id = 6210017; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421097/421098: The Two Gods. Dedicated event clones so the PEQ SoF statics
-- (212025/351118) are untouched. Names keep underscores: GetCleanName yields
-- 'Solusek Ro' / 'Mayong Mistmoore', matching the SoF progression subflags.
DELETE FROM `npc_types` WHERE `id` IN (421097,421098);
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 212025;
UPDATE tmp_solteris_npc SET id = 421097, level = 85, maxlevel = 85, hp = 6500000,
    AC = 600, ATK = 450, Accuracy = 480, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 351118;
UPDATE tmp_solteris_npc SET id = 421098, level = 85, maxlevel = 85, hp = 7500000,
    AC = 600, ATK = 450, Accuracy = 400, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 3. Raid loot (free 6210000-6210099 block, verified empty)
DELETE FROM `loottable_entries` WHERE `loottable_id` BETWEEN 6210011 AND 6210021;
DELETE FROM `lootdrop_entries`  WHERE `lootdrop_id`  BETWEEN 6210001 AND 6210021;
DELETE FROM `lootdrop`          WHERE `id`           BETWEEN 6210001 AND 6210021;
DELETE FROM `loottable`         WHERE `id`           BETWEEN 6210011 AND 6210021;

INSERT INTO `lootdrop` (`id`,`name`) VALUES
  (6210001,'Solteris_Mistresses_Chest'),
  (6210002,'Solteris_Aprosis_Chest'),
  (6210003,'Solteris_Balreth_Chest'),
  (6210004,'Solteris_Astire_Chest'),
  (6210005,'Solteris_Irissa_Chest'),
  (6210006,'Solteris_Commodus_Chest'),
  (6210007,'Solteris_TwoGods_Pool_A'),
  (6210008,'Solteris_TwoGods_Pool_B'),
  (6210021,'Solteris_Throne_Trash');

INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`chance`) VALUES
  (6210001,80612,1,30),(6210001,80613,1,30),(6210001,80614,1,30),(6210001,80615,1,30),
  (6210001,80616,1,30),(6210001,80617,1,30),(6210001,80618,1,30),(6210001,80619,1,30),
  (6210001,80620,1,30),(6210001,80621,1,30),(6210001,79912,200,100),
  (6210002,80622,1,30),(6210002,80623,1,30),(6210002,80624,1,30),(6210002,80625,1,30),
  (6210002,80626,1,30),(6210002,80627,1,30),(6210002,80628,1,30),(6210002,80629,1,30),
  (6210002,80630,1,30),(6210002,80631,1,30),(6210002,34017,2,100),
  (6210002,37416,1,25),(6210002,79912,200,100),
  (6210003,80632,1,30),(6210003,80633,1,30),(6210003,80634,1,30),(6210003,80635,1,30),
  (6210003,80636,1,30),(6210003,80637,1,30),(6210003,80638,1,30),(6210003,80639,1,30),
  (6210003,80640,1,30),(6210003,80641,1,30),(6210003,37416,1,25),(6210003,79912,400,100),
  (6210004,80642,1,30),(6210004,80643,1,30),(6210004,80644,1,30),(6210004,80645,1,30),
  (6210004,80646,1,30),(6210004,80647,1,30),(6210004,80648,1,30),(6210004,80649,1,30),
  (6210004,80650,1,30),(6210004,80651,1,30),(6210004,34018,2,100),
  (6210004,37416,1,25),(6210004,79912,400,100),
  (6210005,80652,1,30),(6210005,80653,1,30),(6210005,80654,1,30),(6210005,80655,1,30),
  (6210005,80656,1,30),(6210005,80657,1,30),(6210005,80658,1,30),(6210005,80659,1,30),
  (6210005,80660,1,30),(6210005,80661,1,30),(6210005,37416,1,25),(6210005,79912,800,100),
  (6210006,80662,1,30),(6210006,80663,1,30),(6210006,80664,1,30),(6210006,80665,1,30),
  (6210006,80666,1,30),(6210006,80667,1,30),(6210006,80668,1,30),(6210006,80669,1,30),
  (6210006,80670,1,30),(6210006,80671,1,30),(6210006,34019,2,100),
  (6210006,37416,1,25),(6210006,79912,800,100),
  (6210007,80672,1,20),(6210007,80673,1,20),(6210007,80674,1,20),(6210007,80675,1,20),
  (6210007,80676,1,20),(6210007,80677,1,20),(6210007,80678,1,20),(6210007,80679,1,20),
  (6210007,80680,1,20),(6210007,80681,1,20),
  (6210008,80682,1,20),(6210008,80683,1,20),(6210008,80684,1,20),(6210008,80685,1,20),
  (6210008,80686,1,20),(6210008,80687,1,20),(6210008,80688,1,20),(6210008,80689,1,20),
  (6210008,80690,1,20),(6210008,80691,1,20),
  (6210008,34020,2,100),(6210008,37416,1,50),(6210008,79912,2000,100),
  (6210021,53473,1,35),(6210021,79913,5,25);

INSERT INTO `loottable` (`id`,`name`) VALUES
  (6210011,'Solteris_Mistresses_Chest'),(6210012,'Solteris_Aprosis_Chest'),
  (6210013,'Solteris_Balreth_Chest'),(6210014,'Solteris_Astire_Chest'),
  (6210015,'Solteris_Irissa_Chest'),(6210016,'Solteris_Commodus_Chest'),
  (6210017,'Solteris_TwoGods_Chest'),(6210021,'Solteris_Throne_Trash');

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
  (6210011,6210001,1,0,2,100),
  (6210012,6210002,1,0,2,100),
  (6210013,6210003,1,0,2,100),
  (6210014,6210004,1,0,2,100),
  (6210015,6210005,1,0,2,100),
  (6210016,6210006,1,0,2,100),
  (6210017,6210007,1,1,1,100),
  (6210017,6210008,1,1,1,100),
  (6210021,6210021,1,0,0,100);

-- 4. Island-4 throne-approach trash (Shard of Eternal Light carriers).
--    spawnentry's PK is (spawngroupID, npcID): each pack mixes three
--    distinct escorts.
DELETE FROM `spawn2` WHERE `zone` = 'solteris' AND `spawngroupID` IN
  (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 421022);
DELETE FROM `spawnentry` WHERE `npcID` = 421022;
DELETE FROM `spawngroup` WHERE `name` LIKE 'solteris_throne_trash%';

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES
  ('solteris_throne_trash_1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,421022,100),(@g,421020,100),(@g,421018,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES
  (@g,'solteris',0,-2300,5350,3914,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES
  ('solteris_throne_trash_2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,421022,100),(@g,421019,100),(@g,421016,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES
  (@g,'solteris',0,-2400,5450,3914,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES
  ('solteris_throne_trash_3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,421022,100),(@g,421014,100),(@g,421021,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES
  (@g,'solteris',0,-2450,5500,3914,0,640);
)",
		.content_schema_update = true,
	},


	// ------------------------------------------------------------------------------------------------
	// Version 61: TBS Katta Castrum Orux missions (tasks 620100-620111) + systemic zone-id repair.
	//
	// The content DB renumbers zones alphabetically (anguish=6, atiiki=13, kattacastrum=192,
	// thalassius=390, zhisza=438, silyssar=343, solteris=358) while stock dz templates and the
	// generated Solteris arc used live ids (anguish=317, atiiki=418, ...): at runtime 6109
	// booted Valdeholm and every stock expedition was mis-zoned. Part A renumbers all
	// dynamic_zone_templates rows once via the live-id mapping parsed from the zone-list doc.
	// Part B repairs the Solteris access-arc + Sivrn activity gates. Part C wires the 12
	// non-arc Orux missions (Rasper's TBS mission summary) as shared/instanced tasks with
	// dz templates 6110-6121, quest items 9910002-9910017, mission NPCs 423915-423944 and
	// drop loot 6210101+. Orux payouts live in the giver quest scripts. ONE SHOT by manifest
	// versioning - the renumber must never run twice. Same content as
	// utils/sql/20260921_tbs_katta_missions.sql (keep in sync).
	// ------------------------------------------------------------------------------------------------
	ManifestEntry{
		.version = 61,
		.description = "2026_09_21_tbs_katta_missions",
		.check = "SELECT 1 FROM tasks WHERE id = 620100 LIMIT 1",
		.condition = "empty",
		.match = "",
		.sql = std::string(R"(
-- ============================================================================
-- TBS Katta Castrum: 12 Orux missions (tasks 620100-620111)
-- Generated by gen_katta_missions.py (2026-09-21).
-- All zone ids are runtime zone ids (zone.zoneidnumber):
--   kattacastrum=416, thalassius=417, atiiki=418, zhisza=419,
--   silyssar=420, solteris=421, barren=422.
-- ============================================================================
-- ============================================================================
-- TBS Katta Castrum: 12 Orux missions (tasks 620100-620111)
-- Generated by gen_katta_missions.py (2026-09-21).
-- All zone ids are runtime zone ids (zone.zoneidnumber):
--   kattacastrum=416, thalassius=417, atiiki=418, zhisza=419,
--   silyssar=420, solteris=421, barren=422.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- A1. quest items (clone of Etching Transcript 33959, quest-safe NoDrop)
DELETE FROM `items` WHERE `id` IN (9910002,9910003,9910004,9910005,9910006,9910007,9910008,9910009,9910010,9910011,9910012,9910013,9910014,9910015,9910016,9910017);
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910002, Name = 'Tongue Fragment', lore = 'A rough shard of the Stone Tongue of Ateleka', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910003, Name = 'Stone Key', lore = 'A key chiseled from living stone', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910004, Name = 'Gorilla Wrangler''s Staff', lore = 'A gnarled prod used by the efreeti gardeners', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910005, Name = 'Jungle Flower', lore = 'A rare blossom from the Atiiki gardens', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910006, Name = 'Glowing Fire Coral', lore = 'A cutting of coral that pulses with inner heat', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910007, Name = 'Sneaky Shissar Scale', lore = 'A scale shed by a shissar moving through the caves', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910008, Name = 'Encoded Message', lore = 'Orders written in a cipher of the Kedge', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910009, Name = 'Kedge Secrets', lore = 'A decree bearing the marks of the Kedge elders', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910010, Name = 'Dome Repair Device', lore = 'Dewas''s field kit for sealing Shissar dome cracks', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910011, Name = 'Mark of Emperor Zhisza', lore = 'The sigil of the true Emperor, used to challenge the loyal', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910012, Name = 'Collection Bowl', lore = 'A ceremonial bowl used to gather shissar power', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910013, Name = 'Power Conduit Shard', lore = 'A fragment of a shattered power conduit', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910014, Name = 'Vial of Inky Blood', lore = 'Blood drawn from a Shissar ritualist', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910015, Name = 'Shedded Snakeskin', lore = 'An intact skin shed by one of the immortal coils', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910016, Name = 'Rituals of Essence and Blood', lore = 'A codex of the rituals that bind the coils', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;
CREATE TEMPORARY TABLE tmp_km_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_km_item SET id = 9910017, Name = 'Bloodletting Kris', lore = 'A ritual blade used to feed the coils', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_km_item;
DROP TEMPORARY TABLE tmp_km_item;

-- A2. mission NPCs (clones; loottable/loot below)
DELETE FROM `npc_types` WHERE `id` IN (423915,423916,423917,423918,423919,423920,423921,423922,423923,423924,423925,423926,423927,423928,423929,423930,423931,423932,423933,423934,423935,423936,423937,423938,423939,423940,423941,423942,423943,423944);
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 317003 LIMIT 1;
UPDATE tmp_km_npc SET id = 423915, name = 'a_stone_tongue_golem', level = 77, maxlevel = 77, hp = 900000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE name = 'Efreeti_Lord_Djarn' LIMIT 1;
UPDATE tmp_km_npc SET id = 423916, name = 'a_noble_efreeti', level = 78, maxlevel = 78, hp = 500000, AC = 550, ATK = 280, Accuracy = 360, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419021 LIMIT 1;
UPDATE tmp_km_npc SET id = 423917, name = 'an_invader_shissar', level = 75, maxlevel = 75, hp = 250000, AC = 550, ATK = 240, Accuracy = 320, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419023 LIMIT 1;
UPDATE tmp_km_npc SET id = 423918, name = 'an_invader_priest', level = 77, maxlevel = 77, hp = 350000, AC = 550, ATK = 240, Accuracy = 320, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 423913 LIMIT 1;
UPDATE tmp_km_npc SET id = 423919, name = 'Emperor_Zhizuzun', level = 79, maxlevel = 79, hp = 1500000, AC = 550, ATK = 350, Accuracy = 400, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE name = 'a_hulking_gorilla' LIMIT 1;
UPDATE tmp_km_npc SET id = 423920, name = 'an_escaped_gorilla', level = 74, maxlevel = 74, hp = 300000, AC = 550, ATK = 230, Accuracy = 310, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE name = 'a_hulking_gorilla' LIMIT 1;
UPDATE tmp_km_npc SET id = 423921, name = 'Matriarch_Tusdum', level = 78, maxlevel = 78, hp = 900000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 417013 LIMIT 1;
UPDATE tmp_km_npc SET id = 423922, name = 'Patrikus_Grimor', level = 77, maxlevel = 77, hp = 700000, AC = 550, ATK = 280, Accuracy = 360, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 417013 LIMIT 1;
UPDATE tmp_km_npc SET id = 423923, name = 'Brinor_Schmidtzen', level = 77, maxlevel = 77, hp = 700000, AC = 550, ATK = 280, Accuracy = 360, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 417013 LIMIT 1;
UPDATE tmp_km_npc SET id = 423924, name = 'Wulthin_Unagi', level = 78, maxlevel = 78, hp = 1000000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419021 LIMIT 1;
UPDATE tmp_km_npc SET id = 423925, name = 'Salashar_the_Blade', level = 78, maxlevel = 78, hp = 1000000, AC = 550, ATK = 310, Accuracy = 390, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 417013 LIMIT 1;
UPDATE tmp_km_npc SET id = 423926, name = 'Ulthagor_Polaris', level = 79, maxlevel = 79, hp = 1100000, AC = 550, ATK = 320, Accuracy = 400, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419021 LIMIT 1;
)")
			+ R"(UPDATE tmp_km_npc SET id = 423927, name = 'Rak''Tharak', level = 79, maxlevel = 79, hp = 1100000, AC = 550, ATK = 320, Accuracy = 400, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 417013 LIMIT 1;
UPDATE tmp_km_npc SET id = 423928, name = 'Xao_Aulin', level = 80, maxlevel = 80, hp = 1600000, AC = 550, ATK = 340, Accuracy = 420, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 417013 LIMIT 1;
UPDATE tmp_km_npc SET id = 423929, name = 'a_darkwater_clawfiend', level = 77, maxlevel = 77, hp = 200000, AC = 550, ATK = 250, Accuracy = 330, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 417013 LIMIT 1;
UPDATE tmp_km_npc SET id = 423930, name = 'a_raging_sea_dervish', level = 77, maxlevel = 77, hp = 200000, AC = 550, ATK = 250, Accuracy = 330, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 417013 LIMIT 1;
UPDATE tmp_km_npc SET id = 423931, name = 'a_sea_mephit', level = 76, maxlevel = 76, hp = 150000, AC = 550, ATK = 220, Accuracy = 300, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 421000 LIMIT 1;
UPDATE tmp_km_npc SET id = 423932, name = 'a_fire_coral', level = 1, maxlevel = 1, hp = 12, AC = 550, ATK = 0, Accuracy = 0, loottable_id = 6210111, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419021 LIMIT 1;
UPDATE tmp_km_npc SET id = 423933, name = 'Shissar_Supervisor_Sslarn', level = 79, maxlevel = 79, hp = 1000000, AC = 550, ATK = 320, Accuracy = 400, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419021 LIMIT 1;
UPDATE tmp_km_npc SET id = 423934, name = 'Shissar_Supervisor_Enpsa', level = 79, maxlevel = 79, hp = 1000000, AC = 550, ATK = 320, Accuracy = 400, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419021 LIMIT 1;
UPDATE tmp_km_npc SET id = 423935, name = 'Shissar_Supervisor_Mozull', level = 79, maxlevel = 79, hp = 1000000, AC = 550, ATK = 320, Accuracy = 400, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 421000 LIMIT 1;
UPDATE tmp_km_npc SET id = 423936, name = 'a_dome_crack', level = 1, maxlevel = 1, hp = 11, AC = 550, ATK = 0, Accuracy = 0, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419021 LIMIT 1;
UPDATE tmp_km_npc SET id = 423937, name = 'an_ambush_shissar', level = 76, maxlevel = 76, hp = 300000, AC = 550, ATK = 260, Accuracy = 340, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419023 LIMIT 1;
UPDATE tmp_km_npc SET id = 423938, name = 'a_shissar_ritualist', level = 78, maxlevel = 78, hp = 700000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 6210113, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 317003 LIMIT 1;
UPDATE tmp_km_npc SET id = 423939, name = 'a_power_conduit', level = 75, maxlevel = 75, hp = 150000, AC = 550, ATK = 0, Accuracy = 0, loottable_id = 6210112, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 421000 LIMIT 1;
UPDATE tmp_km_npc SET id = 423940, name = 'a_collection_bowl', level = 1, maxlevel = 1, hp = 12, AC = 550, ATK = 0, Accuracy = 0, loottable_id = 6210114, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 421000 LIMIT 1;
UPDATE tmp_km_npc SET id = 423941, name = 'an_ornate_chest', level = 1, maxlevel = 1, hp = 12, AC = 550, ATK = 0, Accuracy = 0, loottable_id = 6210115, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419023 LIMIT 1;
UPDATE tmp_km_npc SET id = 423942, name = 'a_shissar_slave', level = 50, maxlevel = 50, hp = 100, AC = 550, ATK = 0, Accuracy = 0, loottable_id = 0, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 421000 LIMIT 1;
UPDATE tmp_km_npc SET id = 423943, name = 'Rituals_of_Essence_and_Blood', level = 1, maxlevel = 1, hp = 12, AC = 550, ATK = 0, Accuracy = 0, loottable_id = 6210116, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;
CREATE TEMPORARY TABLE tmp_km_npc AS SELECT * FROM npc_types WHERE id = 419023 LIMIT 1;
UPDATE tmp_km_npc SET id = 423944, name = 'a_shissar_sacrificer', level = 77, maxlevel = 77, hp = 500000, AC = 550, ATK = 280, Accuracy = 360, loottable_id = 6210117, npc_faction_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_km_npc;
DROP TEMPORARY TABLE tmp_km_npc;

-- A3. loot
DELETE FROM `loottable_entries` WHERE `loottable_id` BETWEEN 6210111 AND 6210118;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 6210101 AND 6210107;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 6210101 AND 6210107;
DELETE FROM `loottable` WHERE `id` BETWEEN 6210111 AND 6210118;
INSERT INTO `lootdrop` (`id`,`name`) VALUES
(6210101,'TBSM_6210101'),
(6210102,'TBSM_6210102'),
(6210103,'TBSM_6210103'),
(6210104,'TBSM_6210104'),
(6210105,'TBSM_6210105'),
(6210106,'TBSM_6210106'),
(6210107,'TBSM_6210107');
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`chance`) VALUES
(6210101,9910006,1,100),
(6210102,9910013,1,100),
(6210103,9910014,1,100),
(6210104,9910015,1,100),
(6210105,9910016,1,100),
(6210106,9910017,1,100),
(6210107,9910007,1,8);
INSERT INTO `loottable` (`id`,`name`) VALUES
(6210111,'TBSM_Fire_Coral'),
(6210112,'TBSM_Power_Conduit'),
(6210113,'TBSM_Ritualist'),
(6210114,'TBSM_Collection_Bowl'),
(6210115,'TBSM_Ornate_Chest'),
(6210116,'TBSM_Rituals_Book'),
(6210117,'TBSM_Sacrificer'),
(6210118,'TBSM_Sneaky_Scale');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
(6210111,6210101,1,0,0,100),
(6210112,6210102,1,0,0,100),
(6210113,6210103,1,0,0,100),
(6210115,6210104,1,0,0,100),
(6210116,6210105,1,0,0,100),
(6210117,6210106,1,0,0,100),
(6210118,6210107,1,0,0,100);

-- Sneaky Shissar Scale rides existing Thalassius trash loottables (additive).
INSERT IGNORE INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
(93375,6210107,1,0,0,100),(93376,6210107,1,0,0,100),(93384,6210107,1,0,0,100);

-- A4. spawns (anchored at existing same-zone spawns; tune with #npcspawn)
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423920) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423921) AND `zone` = 'atiiki';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
)"
			+ R"(DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423932) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423922) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423923) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423924) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423925) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423926) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423927) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423928) AND `zone` = 'thalassius';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423933) AND `zone` = 'zhisza';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423934) AND `zone` = 'zhisza';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423935) AND `zone` = 'zhisza';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423936) AND `zone` = 'zhisza';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423936) AND `zone` = 'zhisza';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423936) AND `zone` = 'zhisza';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423940) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423940) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423940) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423940) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423939) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423939) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423938) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423938) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423941) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423941) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423941) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423941) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423941) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423941) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423943) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423943) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423943) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423942) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423942) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423942) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423942) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423942) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423942) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423944) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423944) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423944) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423944) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423944) AND `zone` = 'silyssar';
DELETE FROM `spawn2` WHERE `spawngroupID` IN (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 423944) AND `zone` = 'silyssar';
DELETE FROM `spawnentry` WHERE `npcID` BETWEEN 423915 AND 423944;
DELETE FROM `spawngroup` WHERE `name` LIKE 'tbs_mission_%';

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+15,s2.y+15,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116702 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+-25,s2.y+30,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116702 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+40,s2.y+-20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116702 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+-40,s2.y+-30,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116702 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+20,s2.y+25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116712 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+-30,s2.y+20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116712 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla7',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+35,s2.y+35,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116712 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla8',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+-20,s2.y+-35,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116712 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla9',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+55,s2.y+5,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116702 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_gorilla10',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423920,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+5,s2.y+55,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116702 LIMIT 1;

)"
			+ R"(INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_matriarch',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423921,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'atiiki',0,s2.x+60,s2.y+60,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 116712 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+20,s2.y+10,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117059 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+-20,s2.y+25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117059 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+15,s2.y+-20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117060 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+30,s2.y+15,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117060 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+-25,s2.y+-15,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117061 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+20,s2.y+30,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117061 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral7',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+10,s2.y+20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117062 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral8',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+-30,s2.y+10,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117062 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral9',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+0,s2.y+-30,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117059 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_coral10',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423932,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+-15,s2.y+40,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117060 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_patrikus',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423922,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+30,s2.y+-30,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117061 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_brinor',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423923,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+-30,s2.y+-30,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117061 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_wulthin',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423924,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+45,s2.y+0,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117059 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_salashar',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423925,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+-45,s2.y+0,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117059 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_ulthagor',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423926,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+50,s2.y+0,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117062 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_raktharak',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423927,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+-50,s2.y+0,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117062 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_xao',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423928,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'thalassius',0,s2.x+0,s2.y+70,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 117062 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_sslarn',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423933,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'zhisza',0,995.375,-107.75,204.27,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_enpsa',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423934,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'zhisza',0,-809.25,-1153.625,363.7,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_mozull',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423935,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'zhisza',0,71.75,-1249.375,363.0,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_crack1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423936,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'zhisza',0,s2.x+60,s2.y+20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 124712 LIMIT 1;

)"
			+ R"(INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_crack2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423936,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'zhisza',0,s2.x+-40,s2.y+30,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 124713 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_crack3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423936,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'zhisza',0,s2.x+25,s2.y+-35,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 124714 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_bowl1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423940,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'silyssar',0,497.0,-7.0,584.0,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_bowl2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423940,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'silyssar',0,560.0,-274.0,642.0,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_bowl3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423940,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'silyssar',0,438.0,-243.0,642.0,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_bowl4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423940,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'silyssar',0,629.0,-25.0,638.0,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_conduit1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423939,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'silyssar',0,660.0,-87.0,588.0,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_conduit2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423939,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'silyssar',0,419.0,-69.0,638.0,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_ritualist1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423938,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'silyssar',0,411.0,-154.0,589.475,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_ritualist2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423938,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (@g,'silyssar',0,808.0,-23.0,589.475,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_chest1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423941,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+25,s2.y+10,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135484 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_chest2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423941,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-25,s2.y+15,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135484 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_chest3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423941,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+20,s2.y+-20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135485 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_chest4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423941,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-20,s2.y+-15,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135485 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_chest5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423941,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+15,s2.y+25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135486 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_chest6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423941,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-15,s2.y+-25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135486 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_book1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423943,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+0,s2.y+40,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135484 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_book2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423943,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+40,s2.y+0,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135485 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_book3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423943,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-40,s2.y+0,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135486 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_slave1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423942,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+30,s2.y+-20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135484 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_slave2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423942,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-30,s2.y+20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135484 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_slave3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423942,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+30,s2.y+20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135485 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_slave4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
)"
			+ R"(INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423942,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-30,s2.y+-20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135485 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_slave5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423942,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+20,s2.y+20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135486 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_slave6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423942,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-20,s2.y+-20,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135486 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_sacrificer1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423944,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+35,s2.y+-25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135484 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_sacrificer2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423944,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-35,s2.y+25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135484 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_sacrificer3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423944,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+35,s2.y+25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135485 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_sacrificer4',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423944,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-35,s2.y+-25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135485 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_sacrificer5',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423944,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+25,s2.y+25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135487 LIMIT 1;

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES ('tbs_mission_sacrificer6',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,423944,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) SELECT @g,'silyssar',0,s2.x+-25,s2.y+-25,s2.z+0,0,640 FROM spawn2 s2 WHERE s2.id = 135487 LIMIT 1;

-- True up PEQ's stub quest NPCs in Atiiki
UPDATE `npc_types` SET `hp` = 1500000, `AC` = 580, `ATK` = 320, `Accuracy` = 400, `findable` = 1 WHERE `id` IN (418020,418068,418071);

-- A5. dz templates 6110-6121 (runtime zone ids, default zone-in, return Katta)
DELETE FROM `dynamic_zone_templates` WHERE `id` BETWEEN 6110 AND 6121;
INSERT INTO `dynamic_zone_templates`
  (`id`,`zone_id`,`zone_version`,`name`,`min_players`,`max_players`,
   `duration_seconds`,`dz_switch_id`,`compass_zone_id`,`compass_x`,`compass_y`,
   `compass_z`,`return_zone_id`,`return_x`,`return_y`,`return_z`,`return_h`,
   `override_zone_in`,`zone_in_x`,`zone_in_y`,`zone_in_z`,`zone_in_h`) VALUES
(6110,418,0,'Katta Castrum: Stone Tongue of Ateleka',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6111,418,0,'Katta Castrum: The Great Invasion',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6112,418,0,'Katta Castrum: Fate of the Combine',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6113,418,0,'Katta Castrum: Gorillas in the Garden',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6114,417,0,'Katta Castrum: Coral Diving',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6115,417,0,'Katta Castrum: Evidence of Unity',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6116,417,0,'Katta Castrum: Sea Serpents',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6117,417,0,'Katta Castrum: The Hydromancer',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6118,419,0,'Katta Castrum: The Domes are Cracking',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6119,419,0,'Katta Castrum: Leave No Stone Unturned',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6120,420,0,'Katta Castrum: The Source of Shissar Power',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0),
(6121,420,0,'Katta Castrum: Immortal Coils',1,6,21600,0,0,0,0,0,416,-2,-425,-20,0,0,0,0,0,0);

-- A6. tasks 620100-620111 (shared/instanced, min 1 player)
DELETE FROM `task_activities` WHERE `taskid` IN (620100,620101,620102,620103,620104,620105,620106,620107,620108,620109,620110,620111);
DELETE FROM `tasks` WHERE `id` IN (620100,620101,620102,620103,620104,620105,620106,620107,620108,620109,620110,620111);

INSERT INTO `tasks` (id,type,duration,duration_code,title,
description,reward_text,reward_id_list,cash_reward,exp_reward,
reward_method,reward_points,reward_point_type,min_level,max_level,
level_spread,min_players,max_players,repeatable,faction_reward,
completion_emote,replay_timer_group,replay_timer_seconds,
request_timer_group,request_timer_seconds,dz_template_id,
lock_activity_id,faction_amount,enabled) VALUES
(620100,1,0,0,'Stone Tongue of Ateleka','A mission for the Combine survivors of Katta Castrum: Stone Tongue of Ateleka.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6110,-1,10,1),
(620101,1,0,0,'The Great Invasion','A mission for the Combine survivors of Katta Castrum: The Great Invasion.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6111,-1,10,1),
(620102,1,0,0,'Fate of the Combine','A mission for the Combine survivors of Katta Castrum: Fate of the Combine.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6112,-1,10,1),
(620103,1,0,0,'Gorillas in the Garden','A mission for the Combine survivors of Katta Castrum: Gorillas in the Garden.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6113,-1,10,1),
(620104,1,0,0,'Coral Diving','A mission for the Combine survivors of Katta Castrum: Coral Diving.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6114,-1,10,1),
(620105,1,0,0,'Evidence of Unity','A mission for the Combine survivors of Katta Castrum: Evidence of Unity.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6115,-1,10,1),
(620106,1,0,0,'Sea Serpents','A mission for the Combine survivors of Katta Castrum: Sea Serpents.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6116,-1,10,1),
(620107,1,0,0,'The Hydromancer','A mission for the Combine survivors of Katta Castrum: The Hydromancer.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6117,-1,10,1),
(620108,1,0,0,'The Domes are Cracking','A mission for the Combine survivors of Katta Castrum: The Domes are Cracking.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6118,-1,10,1),
(620109,1,0,0,'Leave No Stone Unturned','A mission for the Combine survivors of Katta Castrum: Leave No Stone Unturned.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6119,-1,10,1),
(620110,1,0,0,'The Source of Shissar Power','A mission for the Combine survivors of Katta Castrum: The Source of Shissar Power.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6120,-1,10,1),
(620111,1,0,0,'Immortal Coils','A mission for the Combine survivors of Katta Castrum: Immortal Coils.','Experience','',0,2000000,0,0,0,0,0,0,1,6,0,1170,'',0,0,0,0,6121,-1,10,1);

INSERT INTO `task_activities` (taskid,activityid,req_activity_id,
step,activitytype,target_name,goalmethod,goalcount,
description_override,npc_match_list,item_id_list,item_list,
dz_switch_id,min_x,min_y,min_z,max_x,max_y,max_z,skill_list,
spell_list,zones,zone_version,optional,list_group) VALUES
(620100,0,-1,1,2,'Guardian of Ateleka',1,4,'Slay the golems Osinzuhazhfet raises: 4 times','423915','','',0,0,0,0,0,0,0,'-1','0','418',-1,0,0),
(620100,1,-1,2,4,'Associate Researcher Plik',1,1,'Speak with Associate Researcher Plik','416011','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620101,0,-1,1,4,'Akarahotuten',1,1,'Speak with Akarahotuten','418071','','',0,0,0,0,0,0,0,'-1','0','418',-1,0,0),
(620101,1,-1,2,2,'invader shissar',1,10,'Kill 10 invader shissar','423917','','',0,0,0,0,0,0,0,'-1','0','418',-1,0,0),
(620101,2,-1,3,2,'invader priest',1,4,'Kill 4 invader priest','423918','','',0,0,0,0,0,0,0,'-1','0','418',-1,0,0),
(620101,3,-1,4,4,'Sergeant Zetren',1,1,'Speak with Sergeant Zetren','416034','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620102,0,-1,1,4,'Akarahotuten',1,1,'Speak with Akarahotuten','418071','','',0,0,0,0,0,0,0,'-1','0','418',-1,0,0),
(620102,1,-1,2,2,'Emperor Zhizuzun',1,1,'Hunt Emperor Zhizuzun across the temple floors','423919','','',0,0,0,0,0,0,0,'-1','0','418',-1,0,0),
(620102,2,-1,3,4,'Akarahotuten',1,1,'Speak with Akarahotuten','418071','','',0,0,0,0,0,0,0,'-1','0','418',-1,0,0),
(620102,3,-1,4,4,'Tuzart Relenfold',1,1,'Speak with Tuzart Relenfold','416002','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620103,0,-1,1,2,'an escaped gorilla',1,10,'Subdue 10 escaped gorillas','423920','','',0,0,0,0,0,0,0,'-1','0','418',-1,0,0),
(620103,1,-1,2,2,'Matriarch Tusdum',1,1,'Kill 1 Matriarch Tusdum','423921','','',0,0,0,0,0,0,0,'-1','0','418',-1,0,0),
)"
			+ R"((620103,2,-1,3,4,'Head Attendant Haestus',1,1,'Speak with Head Attendant Haestus','416005','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620104,0,-1,1,2,'kedge',1,20,'Kill 20 kedge creatures in the caves','417011,417012,417013,417023,417026,417028,417035','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620104,1,-1,2,2,'fire coral',1,10,'Harvest 10 Glowing Fire Coral','423932','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620104,2,-1,3,4,'Sorcerer Hearah',1,1,'Speak with Sorcerer Hearah','416014','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620105,0,-1,1,2,'kedge and puddles',1,8,'Kill 8 kedge or puddles along the way','417011,417012,417013,417023,417026,417028,417035','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620105,1,-1,2,1,'Sneaky Shissar Scale',1,5,'Loot 5 Sneaky Shissar Scale','','9910007','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620105,2,-1,3,2,'Patrikus Grimor',1,1,'Kill 1 Patrikus Grimor','423922','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620105,3,-1,4,2,'Brinor Schmidtzen',1,1,'Kill 1 Brinor Schmidtzen','423923','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620105,4,-1,5,1,'Encoded Message',1,1,'Loot 1 Encoded Message','','9910008','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620105,5,-1,6,1,'Kedge Secrets',1,1,'Loot 1 Kedge Secrets','','9910009','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620105,6,-1,7,4,'Flora Venloe',1,1,'Speak with Flora Venloe','416055','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620106,0,-1,1,2,'Wulthin Unagi',1,1,'Kill 1 Wulthin Unagi','423924','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620106,1,-1,2,2,'Salashar the Blade',1,1,'Kill 1 Salashar the Blade','423925','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620106,2,-1,3,2,'Ulthagor Polaris',1,1,'Kill 1 Ulthagor Polaris','423926','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620106,3,-1,4,2,'Rak''Tharak',1,1,'Kill 1 Rak''Tharak','423927','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620106,4,-1,5,4,'Flora Venloe',1,1,'Speak with Flora Venloe','416055','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620107,0,-1,1,2,'Xao Aulin',1,1,'Slay Xao Aulin before his darkwater allies drown the temple','423928','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620107,1,-1,2,4,'Flora Venloe',1,1,'Speak with Flora Venloe','416055','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620108,0,-1,1,2,'ambush shissar',1,12,'Survive and slay the three dome-crack ambushes (12 shissar)','423937','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620108,1,-1,2,4,'Structural Engineer Dewas',1,1,'Speak with Structural Engineer Dewas','416033','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620109,0,-1,1,2,'shissar patroller',1,10,'Challenge the shissar: 10 refuse the Emperor and must die','419001','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620109,1,-1,2,4,'Shissar Supervisor Sslarn',1,1,'Speak with Shissar Supervisor Sslarn','423933','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620109,2,-1,3,4,'Shissar Supervisor Enpsa',1,1,'Speak with Shissar Supervisor Enpsa','423934','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620109,3,-1,4,4,'Shissar Supervisor Mozull',1,1,'Speak with Shissar Supervisor Mozull','423935','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620109,4,-1,5,4,'Vizier Zio',1,1,'Speak with Vizier Zio','416140','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620110,0,-1,1,1,'Collection Bowl',1,4,'Loot 4 Collection Bowl','','9910012','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620110,1,-1,2,2,'a power conduit',1,2,'Destroy 2 power conduits','423939','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620110,2,-1,3,1,'Power Conduit Shard',1,2,'Loot 2 Power Conduit Shard','','9910013','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620110,3,-1,4,2,'a Shissar ritualist',1,2,'Kill 2 a Shissar ritualist','423938','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620110,4,-1,5,1,'Vial of Inky Blood',1,2,'Loot 2 Vial of Inky Blood','','9910014','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620110,5,-1,6,4,'Arcanist Tivalin',1,1,'Speak with Arcanist Tivalin','416016','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620111,0,-1,1,1,'Shedded Snakeskin',1,3,'Loot 3 Shedded Snakeskin','','9910015','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620111,1,-1,2,1,'Rituals of Essence and Blood',1,1,'Loot 1 Rituals of Essence and Blood','','9910016','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620111,2,-1,3,4,'a shissar slave',1,1,'Speak with a shissar slave','423942','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620111,3,-1,4,1,'Bloodletting Kris',1,3,'Loot 3 Bloodletting Kris','','9910017','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620111,4,-1,5,4,'Arcanist Tivalin',1,1,'Speak with Arcanist Tivalin','416016','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0);
)",
		.content_schema_update = true,
	},

	ManifestEntry{
		.version = 62,
		.description = "2026_09_05_fabled_npcs_roster_table",
		.check = "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fabled_npcs'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE IF NOT EXISTS `fabled_npcs` (
  `npc_id` INT UNSIGNED NOT NULL,
  `era` VARCHAR(8) NOT NULL,
  `level` TINYINT UNSIGNED NOT NULL,
  `hp_mult` FLOAT NOT NULL DEFAULT -1,
  `min_hit_mult` FLOAT NOT NULL DEFAULT -1,
  `max_hit_mult` FLOAT NOT NULL DEFAULT -1,
  `npc_spells_id` INT UNSIGNED NOT NULL DEFAULT 0,
  `special_abilities_append` VARCHAR(255) NOT NULL DEFAULT '',
  `chance` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `enabled` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`npc_id`),
  KEY `era` (`era`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
)",
		.content_schema_update = true,
	},

	ManifestEntry{
		.version = 63,
		.description = "2026_09_05_fabled_season_state_table",
		.check = "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fabled_season'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE IF NOT EXISTS `fabled_season` (
  `id` INT NOT NULL,
  `active` TINYINT(1) DEFAULT 0,
  `start_epoch` BIGINT DEFAULT 0,
  `end_epoch` BIGINT DEFAULT 0,
  `scope_kind` TINYINT UNSIGNED DEFAULT 0,
  `scope_value` VARCHAR(32) DEFAULT '',
  `chance` TINYINT UNSIGNED DEFAULT 50,
  `loot_tier` TINYINT UNSIGNED DEFAULT 2,
  `set_by` VARCHAR(64) DEFAULT '',
  `set_at` BIGINT DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `fabled_season` (`id`, `active`, `start_epoch`, `end_epoch`, `scope_kind`, `scope_value`, `chance`, `loot_tier`, `set_by`, `set_at`)
SELECT 1, 0, 0, 0, 0, '', 50, 2, '', 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `fabled_season` WHERE id = 1);
)", 
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 64,
		.description = "2026_09_22_shrouds_table",
		.check = "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'shrouds'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE IF NOT EXISTS `shrouds` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `progression` varchar(64) NOT NULL DEFAULT 'Shrouds',
  `branch` varchar(64) NOT NULL DEFAULT 'General',
  `level` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `race` smallint(5) unsigned NOT NULL DEFAULT 0,
  `gender` tinyint(3) unsigned NOT NULL DEFAULT 2,
  `class` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `texture` tinyint(3) unsigned NOT NULL DEFAULT 255,
  `helmet_texture` tinyint(3) unsigned NOT NULL DEFAULT 255,
  `size` float NOT NULL DEFAULT -1,
  `hp` int(11) NOT NULL DEFAULT 0,
  `mana` int(11) NOT NULL DEFAULT 0,
  `endurance` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
)",
		.content_schema_update = true,
	},

	ManifestEntry{
		.version = 65,
		.description = "2026_09_22_character_shroud_snapshot",
		.check = "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'character_shroud_snapshot'",
		.condition = "empty",
		.match = "",
		.sql = R"(
CREATE TABLE IF NOT EXISTS `character_shroud_snapshot` (
  `character_id` int(10) unsigned NOT NULL,
  `race` smallint(5) unsigned NOT NULL DEFAULT 0,
  `gender` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `class` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `level` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
)",
		.content_schema_update = false,
	},

	// Seeds the DoD spirit-shroud catalog (8 progressions x 34 templates x 14
	// level tiers, 5-70). Runs only when the table is empty, so it never
	// disturbs an install that has its own rows. Stats come from base_data.
	ManifestEntry{
		.version = 66,
		.description = "2026_09_22_shroud_catalog_seed",
		.check = "SELECT `id` FROM `shrouds` LIMIT 1",
		.condition = "empty",
		.match = "",
		.sql = R"(
INSERT INTO `shrouds`
	(`name`, `progression`, `branch`, `level`, `race`, `gender`, `class`, `texture`, `helmet_texture`, `size`, `hp`, `mana`, `endurance`)
SELECT
	CONCAT(t.`name`, ' ', b.`level`),
	t.`progression`,
	t.`name`,
	b.`level`,
	t.`race`,
	2,
	t.`class`,
	t.`texture`,
	255,
	t.`size`,
	CAST(ROUND(5 + b.`hp` + b.`hp_fac` * 75) AS SIGNED),
	CASE WHEN b.`mana` > 0 THEN CAST(ROUND(b.`mana` + b.`mana_fac` * 75) AS SIGNED) ELSE 0 END,
	CAST(ROUND(b.`end` + b.`end_fac` * 75) AS SIGNED)
FROM (
	SELECT 'Imp Wizard' AS `name`, 'Aberrations' AS `progression`, 130 AS `race`, 12 AS `class`, 1 AS `texture`, 5 AS `size`
	UNION ALL SELECT 'Evil Eye Psion', 'Aberrations', 21, 14, 0, 6
	UNION ALL SELECT 'Evil Eye Sorcerer', 'Aberrations', 21, 12, 0, 6
	UNION ALL SELECT 'Imp Trickster', 'Aberrations', 130, 14, 1, 5
	UNION ALL SELECT 'Gargoyle Fighter', 'Aberrations', 464, 1, 3, 2.5
	UNION ALL SELECT 'Bear Beast', 'Animals', 43, 1, 0, 6
	UNION ALL SELECT 'Wolf Beast', 'Animals', 42, 16, 0, 6
	UNION ALL SELECT 'Tiger Beast', 'Animals', 439, 16, 4, 4
	UNION ALL SELECT 'Werewolf Beast', 'Animals', 14, 16, 0, 6
	UNION ALL SELECT 'Earth Elemental Fighter', 'Elementals', 209, 1, 0, 6
	UNION ALL SELECT 'Water Elemental Cleric', 'Elementals', 211, 2, 0, 6
	UNION ALL SELECT 'Fire Elemental Wizard', 'Elementals', 212, 12, 0, 6
	UNION ALL SELECT 'Air Elemental Illusionist', 'Elementals', 210, 14, 0, 6
	UNION ALL SELECT 'Goblin Rogue', 'Goblinoid', 433, 9, 7, 3
	UNION ALL SELECT 'Orc Brute', 'Goblinoid', 54, 1, 0, 8
	UNION ALL SELECT 'Goblin Cleric', 'Goblinoid', 433, 2, 7, 3
	UNION ALL SELECT 'Goblin Wizard', 'Goblinoid', 433, 12, 7, 3
	UNION ALL SELECT 'Orc Battle Rager', 'Goblinoid', 54, 16, 0, 8
	UNION ALL SELECT 'Kobold Cleric', 'Humanoid', 455, 2, 2, 3
	UNION ALL SELECT 'Kobold Rogue', 'Humanoid', 455, 9, 2, 3
	UNION ALL SELECT 'Minotaur Brute', 'Humanoid', 470, 1, 0, 2.5
	UNION ALL SELECT 'Minotaur Berserker', 'Humanoid', 470, 16, 0, 2.5
	UNION ALL SELECT 'Fairy Trickster', 'Nature Spirits', 473, 14, 0, 1.5
	UNION ALL SELECT 'Fairy Wizard', 'Nature Spirits', 473, 12, 0, 1.5
	UNION ALL SELECT 'Fairy Cleric', 'Nature Spirits', 473, 2, 0, 1.5
	UNION ALL SELECT 'Sporali Spore Wielder', 'Nature Spirits', 456, 14, 2, 5
	UNION ALL SELECT 'Sporali Cleric', 'Nature Spirits', 456, 2, 2, 5
	UNION ALL SELECT 'Basilisk Beast', 'Reptiles', 91, 16, 1, 10
	UNION ALL SELECT 'Scaled Wolf Beast', 'Reptiles', 42, 16, 0, 6
	UNION ALL SELECT 'Raptor Beast', 'Reptiles', 163, 16, 1, 5
	UNION ALL SELECT 'Skeleton Wizard', 'Undead', 161, 12, 0, 6
	UNION ALL SELECT 'Zombie Fighter', 'Undead', 70, 1, 0, 6
	UNION ALL SELECT 'Scarecrow Mind Bender', 'Undead', 82, 14, 0, 6
	UNION ALL SELECT 'Spectre Ethereal Stalker', 'Undead', 85, 12, 0, 10
) t
JOIN base_data b
	ON b.`level` IN (5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70)
	AND b.`class` = t.`class`;
)",
		.content_schema_update = true,
	},

	// Persisted shroud state: shroud_id > 0 means the character is currently
	// shrouded as that form and the saved identity/appearance is what restores
	// them at the Shroudkeeper. shroud_id 0 is a legacy repair row.
	ManifestEntry{
		.version = 67,
		.description = "2026_09_22_character_shroud_snapshot_state",
		.check = "SHOW COLUMNS FROM `character_shroud_snapshot` LIKE 'shroud_id'",
		.condition = "empty",
		.match = "",
		.sql = R"(
ALTER TABLE `character_shroud_snapshot`
  ADD COLUMN `shroud_id` int(10) unsigned NOT NULL DEFAULT 0,
  ADD COLUMN `texture` tinyint(3) unsigned NOT NULL DEFAULT 255,
  ADD COLUMN `helmet_texture` tinyint(3) unsigned NOT NULL DEFAULT 255,
  ADD COLUMN `size` float NOT NULL DEFAULT -1;
)",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 68,
		.description = "2026_09_22_deity_blessings_rank1",
		.check = "SELECT id FROM items WHERE id = 9910023",
		.condition = "empty",
		.match = "",
		.sql = R"BLESS(
-- ============================================================================
-- Deity Blessings -- Rank 1: "Bring a Fired Idol"
-- Date: 2026-09-22
--
-- Adds the crafting chain + rank-1 delivery quests for the 16 deity trees
-- (incl. Veeshan) plus the Agnostic ("Unaligned") tree.
--
--   * Imbue Jacinth spell + Imbued Jacinth (tradable) + scroll
--   * Unfired/Golden Idol of Veeshan
--   * Unfired/Fired Idol of the Unaligned (agnostic)
--   * 17 one-shot rank-1 tasks (700001-700017), each a single Deliver activity
--   * 2 blessing NPCs spawned in The Bazaar (151) and Plane of Tranquility (203)
--
-- Idempotent: deletes the ids it owns before inserting.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Cleanup (safe: these ids are dedicated to this system)
-- ---------------------------------------------------------------------------
DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` IN (992007,992008,992009,992010);
DELETE FROM `tradeskill_recipe`         WHERE `id`        IN (992007,992008,992009,992010);
DELETE FROM `merchantlist`              WHERE `merchantid`= 202223 AND `item`=9910019;
DELETE FROM `task_activities`           WHERE `taskid` BETWEEN 700001 AND 700017;
DELETE FROM `tasks`                     WHERE `id` BETWEEN 700001 AND 700017;
DELETE FROM `spawn2`                    WHERE `id` IN (3390100,3390101);
DELETE FROM `spawnentry`                WHERE `spawngroupID` IN (5004100,5004101);
DELETE FROM `spawngroup`                WHERE `id` IN (5004100,5004101);
DELETE FROM `npc_types`                 WHERE `id` IN (344200,344201);
DELETE FROM `items`                     WHERE `id` IN (9910018,9910019,9910020,9910021,9910022,9910023);
DELETE FROM `spells_new`                WHERE `id`=50017;

-- ===========================================================================
-- Phase A -- Veeshan gem chain
-- ===========================================================================

-- Imbued Jacinth (tradable) -- clone of Imbued Diamond (22549)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=22549;
UPDATE `tmp_item` SET
    `id`=9910018,
    `Name`='Imbued Jacinth',
    `lore`='Imbued Jacinth-Veeshan',
    `loregroup`=0,
    `icon`=767,
    `price`=200000,
    `nodrop`=0,
    `magic`=0,
    `itemtype`=17,
    `minstatus`=0
WHERE `id`=22549;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- Spell: Imbue Jacinth scroll -- clone of Spell: Imbue Diamond (15895)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=15895;
UPDATE `tmp_item` SET
    `id`=9910019,
    `Name`='Spell: Imbue Jacinth',
    `lore`='Spell: Imbue Jacinth',
    `loregroup`=0,
    `price`=2933,
    `scrolltype`=0,
    `scrolleffect`=50017,
    `itemtype`=20,
    `minstatus`=0
WHERE `id`=15895;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- Imbue Jacinth -- clone of Imbue Emerald (1888), deity-locked to Veeshan (index 16)
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=1888;
UPDATE `tmp_spell` SET
    `id`=50017,
    `name`='Imbue Jacinth',
    `effect_base_value1`=9910018,
    `components1`=10053,
    `classes1`=255,
    `classes2`=29,
    `classes3`=255,
    `classes4`=255,
    `classes5`=255,
    `classes6`=29,
    `classes7`=255,
    `classes8`=255,
    `classes9`=255,
    `classes10`=255,
    `classes11`=255,
    `classes12`=255,
    `classes13`=255,
    `classes14`=255,
    `classes15`=255,
    `classes16`=255,
    `deities0`=0,`deities1`=0,`deities2`=0,`deities3`=0,`deities4`=0,
    `deities5`=0,`deities6`=0,`deities7`=0,`deities8`=0,`deities9`=0,
    `deities10`=0,`deities11`=0,`deities12`=0,`deities13`=0,`deities14`=0,
    `deities15`=0,`deities16`=-1
WHERE `id`=1888;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- Sell the scroll at the Bazaar cleric spell vendor (Vicar merchant 202223)
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (202223,93,9910019);

-- ===========================================================================
-- Phase B -- Veeshan idol chain
-- ===========================================================================

-- Unfired Idol of Veeshan -- clone of Unfired Idol of Bertoxxulous (9691)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9691;
UPDATE `tmp_item` SET
    `id`=9910020,
    `Name`='Unfired Idol of Veeshan',
    `lore`='Unfired Idol of Veeshan',
    `loregroup`=0,
    `minstatus`=0
WHERE `id`=9691;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- Golden Idol of Veeshan -- clone of Golden Idol of Prexus (9714)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9714;
UPDATE `tmp_item` SET
    `id`=9910021,
    `Name`='Golden Idol of Veeshan',
    `lore`='Golden Idol of Veeshan',
    `loregroup`=0,
    `ac`=4,
    `minstatus`=0
WHERE `id`=9714;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

INSERT INTO `tradeskill_recipe`
    (`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,`must_learn`,`learned_by_item_id`,`quest`,`enabled`,`min_expansion`,`max_expansion`)
VALUES
    (992007,'Unfired Idol Of Veeshan',69,0,335,0,0,0,0,0,1,-1,-1),
    (992008,'Golden Idol Of Veeshan',69,0,15,0,0,0,0,0,1,-1,-1),
    (992009,'Unfired Idol Of The Unaligned',69,0,38,0,0,0,0,0,1,-1,-1),
    (992010,'Fired Idol Of The Unaligned',69,0,40,0,0,0,0,0,1,-1,-1);

INSERT INTO `tradeskill_recipe_entries`
    (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
    -- Unfired Idol Of Veeshan
    (992007,21625,1,0,1,0,0),
    (992007,9650, 0,0,1,0,0),
    (992007,10253,0,0,1,0,0),
    (992007,13006,0,0,1,0,0),
    (992007,16502,0,0,1,0,0),
    (992007,16895,0,0,1,0,0),
    (992007,16896,0,0,1,0,0),
    (992007,9910018,0,0,1,0,0),
    (992007,9910020,1,0,0,0,0),
    -- Golden Idol Of Veeshan
    (992008,9910020,0,0,1,0,0),
    (992008,16578,0,0,1,0,0),
    (992008,16908,0,0,1,0,0),
    (992008,9910021,1,0,0,0,0),
    -- Unfired Idol Of The Unaligned
    (992009,21625,1,0,1,0,0),
    (992009,9650, 0,0,1,0,0),
    (992009,16502,0,0,1,0,0),
    (992009,16895,0,0,1,0,0),
    (992009,10053,0,0,1,0,0),
    (992009,16896,0,0,1,0,0),
    (992009,10253,0,0,1,0,0),
    (992009,13006,0,0,1,0,0),
    (992009,9910022,1,0,0,0,0),
    -- Fired Idol Of The Unaligned
    (992010,9910022,0,0,1,0,0),
    (992010,16578,0,0,1,0,0),
    (992010,16908,0,0,1,0,0),
    (992010,9910023,1,0,0,0,0),
    -- container markers (required for the client recipe list; 21 = pottery wheel, 22 = kiln)
    (992007,21,0,0,0,0,1),
    (992008,22,0,0,0,0,1),
    (992009,21,0,0,0,0,1),
    (992010,22,0,0,0,0,1);

-- ===========================================================================
-- Phase C -- Agnostic ("Unaligned") idol chain
-- ===========================================================================

-- Unfired Idol of the Unaligned -- clone of generic Unfired Idol (21610)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=21610;
UPDATE `tmp_item` SET
    `id`=9910022,
    `Name`='Unfired Idol of the Unaligned',
    `lore`='Unfired Idol of the Unaligned',
    `loregroup`=0,
    `minstatus`=0
WHERE `id`=21610;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- Fired Idol of the Unaligned -- clone of Golden Idol of Prexus (9714)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9714;
UPDATE `tmp_item` SET
    `id`=9910023,
    `Name`='Fired Idol of the Unaligned',
    `lore`='Fired Idol of the Unaligned',
    `loregroup`=0,
    `ac`=4,
    `minstatus`=0
WHERE `id`=9714;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- ===========================================================================
-- Phase D -- 2 blessing NPCs (The Bazaar 151, Plane of Tranquility 203)
-- ===========================================================================
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`merchant_id`,`npc_spells_id`)
VALUES
    (344200,'Blessing_of_the_Gods','Keeper of Devotion',70,6,1,1,32000,0,2,0,0,5,1.25,0,0),
    (344201,'Blessing_of_the_Gods','Keeper of Devotion',70,6,1,1,32000,0,2,0,0,5,1.25,0,0);

INSERT INTO `spawngroup` (`id`,`name`) VALUES
    (5004100,'blessing_of_the_gods_bazaar'),
    (5004101,'blessing_of_the_gods_potranquility');

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
    (5004100,344200,100),
    (5004101,344201,100);

INSERT INTO `spawn2`
    (`id`,`spawngroupID`,`zone`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
    (3390100,5004100,'bazaar',        -91,96,-16,0,7200,0),
    (3390101,5004101,'potranquility', -1480,590,-876,253,7200,0);

-- ===========================================================================
-- Phase E -- Rank-1 tasks (one per tree) + Deliver activities
-- ===========================================================================
INSERT INTO `tasks`
    (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,
     `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
     `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
     `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
     `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
     `faction_amount`,`enabled`)
VALUES
    (700001,2,0,0,'Devotion to Bertoxxulous','Deliver a forged idol of Bertoxxulous to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700002,2,0,0,'Devotion to Brell Serilis','Deliver a forged idol of Brell Serilis to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700003,2,0,0,'Devotion to Cazic-Thule','Deliver a forged idol of Cazic-Thule to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700004,2,0,0,'Devotion to Erollisi Marr','Deliver a forged idol of Erollisi Marr to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700005,2,0,0,'Devotion to Bristlebane','Deliver a forged idol of Bristlebane to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700006,2,0,0,'Devotion to Innoruuk','Deliver a forged idol of Innoruuk to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700007,2,0,0,'Devotion to Karana','Deliver a forged idol of Karana to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700008,2,0,0,'Devotion to Mithaniel Marr','Deliver a forged idol of Mithaniel Marr to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700009,2,0,0,'Devotion to Prexus','Deliver a forged idol of Prexus to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700010,2,0,0,'Devotion to Quellious','Deliver a forged idol of Quellious to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700011,2,0,0,'Devotion to Rallos Zek','Deliver a forged idol of Rallos Zek to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700012,2,0,0,'Devotion to Rodcet Nife','Deliver a forged idol of Rodcet Nife to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700013,2,0,0,'Devotion to Solusek Ro','Deliver a forged idol of Solusek Ro to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700014,2,0,0,'Devotion to the Tribunal','Deliver a forged idol of the Tribunal to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700015,2,0,0,'Devotion to Tunare','Deliver a forged idol of Tunare to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700016,2,0,0,'Devotion to Veeshan','Deliver a forged idol of Veeshan to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700017,2,0,0,'Devotion of the Unaligned','Deliver a forged idol of the Unaligned to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1);

INSERT INTO `task_activities`
    (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,
     `goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
     `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
     `zone_version`,`optional`,`list_group`)
VALUES
    (700001,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Bertoxxulous to the Keeper of Devotion.','344200|344201','9706','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700002,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Brell Serilis to the Keeper of Devotion.','344200|344201','9707','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700003,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Cazic-Thule to the Keeper of Devotion.','344200|344201','9708','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700004,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Erollisi Marr to the Keeper of Devotion.','344200|344201','9709','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700005,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Bristlebane to the Keeper of Devotion.','344200|344201','9710','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700006,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Innoruuk to the Keeper of Devotion.','344200|344201','9711','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700007,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Karana to the Keeper of Devotion.','344200|344201','9712','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700008,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Mithaniel Marr to the Keeper of Devotion.','344200|344201','9713','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700009,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Prexus to the Keeper of Devotion.','344200|344201','9714','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700010,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Quellious to the Keeper of Devotion.','344200|344201','9715','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700011,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Rallos Zek to the Keeper of Devotion.','344200|344201','9716','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700012,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Rodcet Nife to the Keeper of Devotion.','344200|344201','9717','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700013,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Solusek Ro to the Keeper of Devotion.','344200|344201','9718','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700014,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of the Tribunal to the Keeper of Devotion.','344200|344201','9719','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700015,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Tunare to the Keeper of Devotion.','344200|344201','9720','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700016,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Veeshan to the Keeper of Devotion.','344200|344201','9910021','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700017,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of the Unaligned to the Keeper of Devotion.','344200|344201','9910023','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0);
)BLESS",
		.content_schema_update = false,
	},


	ManifestEntry{
		.version = 69,
		.description = "2026_09_22_deity_blessings_desc_events",
		.check = "SELECT id FROM db_str WHERE id = 910000004",
		.condition = "empty",
		.match = "",
		.sql = R"BLESS2(
-- ============================================================================
-- Deity Blessings -- description string fix + proc-engine event export rows
-- Date: 2026-09-22
-- ============================================================================

-- Fix the Imbue Jacinth description (was inheriting Imbue Emerald's
-- via descnum=1888). Custom strings live above 910000000 like the soul gems.
INSERT INTO `db_str` (`id`,`type`,`value`)
VALUES (910000004, 6, 'Focuses the power of Veeshan into a jacinth.  Consumes a jacinth when cast.')
ON DUPLICATE KEY UPDATE `value` = VALUES(`value`);

UPDATE `spells_new`
SET `descnum` = 910000004, `typedescnum` = 0, `effectdescnum` = 0
WHERE `id` = 50017;

-- Reduce exported variables for the damage events the blessing proc engine
-- uses (matches the style of the other combat events: no qglobals/item).
INSERT INTO `perl_event_export_settings`
    (`event_id`,`event_description`,`export_qglobals`,`export_mob`,`export_zone`,`export_item`,`export_event`)
VALUES
    (116,'EVENT_DAMAGE_GIVEN',0,1,1,0,1),
    (117,'EVENT_DAMAGE_TAKEN',0,1,1,0,1)
ON DUPLICATE KEY UPDATE
    `event_description` = VALUES(`event_description`),
    `export_qglobals`   = VALUES(`export_qglobals`),
    `export_mob`        = VALUES(`export_mob`),
    `export_zone`       = VALUES(`export_zone`),
    `export_item`       = VALUES(`export_item`),
    `export_event`      = VALUES(`export_event`);
)BLESS2",
		.content_schema_update = false,
	},



	ManifestEntry{
		.version = 70,
		.description = "2026_09_23_neriak_rogue_armor_loot",
		.check = "SELECT id FROM tradeskill_recipe_entries WHERE recipe_id = 2966 AND item_id = 16 AND iscontainer = 1",
		.condition = "empty",
		.match = "",
		.sql = R"NERIAK(
-- ============================================================================
-- Neriak rogue newbie armor + classic low-level quest content repair
-- Date: 2026-09-23
--
--   1. Othmir Fur Cloak / Moccasins combines accept any sewing kit or loom
--      (bag type 16), mirroring the Othmir Fur Cap recipe (2965).
--   2. The Nektulos "a_zombie" (25432) drops a Lock of Zombie Hair (19583),
--      required by the Neriak rogue weapon quest.
--   3. Classic low-level spawns (ash/forest drakelings, orc arsonist, zombie)
--      are no longer era-gated (min_expansion = -1).
--
-- Idempotent: guarded INSERTs; the UPDATE is naturally repeatable.
-- ============================================================================

INSERT INTO `tradeskill_recipe_entries`
    (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
SELECT 2966, 16, 0, 0, 0, 0, 1 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `tradeskill_recipe_entries`
    WHERE `recipe_id` = 2966 AND `item_id` = 16 AND `iscontainer` = 1
);

INSERT INTO `tradeskill_recipe_entries`
    (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
SELECT 2967, 16, 0, 0, 0, 0, 1 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `tradeskill_recipe_entries`
    WHERE `recipe_id` = 2967 AND `item_id` = 16 AND `iscontainer` = 1
);

INSERT INTO `loottable_entries`
    (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
SELECT 102604, 12058, 1, 1, 0, 100 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `loottable_entries`
    WHERE `loottable_id` = 102604 AND `lootdrop_id` = 12058
);

UPDATE `spawn2` SET `min_expansion` = -1
WHERE `spawngroupID` IN (5812, 59485, 61434, 61435);
)NERIAK",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 71,
		.description = "2026_09_23_rename_echo_blessings_to_triune",
		// Guard on the primary blessing spell name; "missing" + match "Triune" runs the
		// rename only while spells_new still says "Echo ...".
		.check = "SELECT name FROM spells_new WHERE id = 43002",
		.condition = "missing",
		.match = "Triune",
		.sql = R"TRIUNE(
-- Rename the bazaar blessing buffs (Mal'zeth V'Tide, "Master of Buffs") from
-- "Echo of X" to "Triune of X". IDs are unchanged, so ID-based logic is unaffected.
-- Idempotent: plain UPDATEs.
UPDATE `spells_new` SET `name` = 'Triune of Luck'       WHERE `id` = 17779;
UPDATE `spells_new` SET `name` = 'Triune of Power'      WHERE `id` = 36856;
UPDATE `spells_new` SET `name` = 'Triune of Experience' WHERE `id` = 43002;
UPDATE `spells_new` SET `name` = 'Triune of Aegolism'   WHERE `id` = 43003;
UPDATE `spells_new` SET `name` = 'Triune of Focus'      WHERE `id` = 43004;
UPDATE `spells_new` SET `name` = 'Triune of Selo'       WHERE `id` = 43005;
UPDATE `spells_new` SET `name` = 'Triune of Koadic'     WHERE `id` = 43006;
UPDATE `spells_new` SET `name` = 'Triune of the Brood'  WHERE `id` = 43007;
UPDATE `spells_new` SET `name` = 'Triune of the Grove'  WHERE `id` = 43008;
)TRIUNE",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 72,
		.description = "2026_09_23_deity_blessings_custom_spells",
		.check = "SELECT id FROM spells_new WHERE id = 50022",
		.condition = "empty",
		.match = "",
		.sql = R"BLESS72(
-- ============================================================================
-- Deity Blessings -- collision-free buff effect spells (stack with everything)
-- Date: 2026-09-23
--
-- Custom, unscribable clones of the buff-type blessing effects. Their IDs are
-- added to Spells:AlwaysStackSpells so a blessing never conflicts with any
-- player spell line (different spell ids -> rule short-circuits to "no conflict").
--
--  50018 Blessing: Disease       (from Scourge 31; single target)
--  50019 Blessing: Root          (from Root 230)
--  50020 Blessing: Fear          (from Fear 229)
--  50021 Blessing: Snare         (from Cryomantic Snare 12721)
--  50022 Blessing: Damage Shield (from Nettle Shield 5358 -- Druid DS, SPA 59 only)
-- ============================================================================

DELETE FROM `spells_new` WHERE `id` IN (50018,50019,50020,50021,50022);
DELETE FROM `db_str`     WHERE `id` IN (910000005,910000006,910000007,910000008,910000009) AND `type`=6;

-- ---- Blessing: Disease (Scourge) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=31;
UPDATE `tmp_spell` SET `id`=50018, `name`='Blessing: Disease', `descnum`=910000005,
  `targettype`=5,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=31;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- Blessing: Root (Root) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=230;
UPDATE `tmp_spell` SET `id`=50019, `name`='Blessing: Root', `descnum`=910000006,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=230;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- Blessing: Fear (Fear) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=229;
UPDATE `tmp_spell` SET `id`=50020, `name`='Blessing: Fear', `descnum`=910000007,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=229;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- Blessing: Snare (Cryomantic Snare) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=12721;
UPDATE `tmp_spell` SET `id`=50021, `name`='Blessing: Snare', `descnum`=910000008,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=12721;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- Blessing: Damage Shield (Nettle Shield -- Druid DS, no fire resist) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=5358;
UPDATE `tmp_spell` SET `id`=50022, `name`='Blessing: Damage Shield', `descnum`=910000009,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=5358;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- descriptions ----
INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
    (910000005, 6, 'A blessing of decay seeps into your foe, rotting flesh over time.'),
    (910000006, 6, 'A blessing of stone grips your foe, holding it in place.'),
    (910000007, 6, 'A blessing of dread overwhelms your foe, sending it fleeing.'),
    (910000008, 6, 'A blessing of the wilds tangles your foe, slowing its movement.'),
    (910000009, 6, 'A divine blessing shields you, injuring those who strike you.');

-- ---- never collide with any other spell line ----
UPDATE `rule_values`
SET `rule_value` = CONCAT(`rule_value`, ',50018,50019,50020,50021,50022')
WHERE `rule_name` = 'Spells:AlwaysStackSpells'
  AND `rule_value` NOT LIKE '%50022%';
)BLESS72",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 73,
		.description = "2026_09_23_deity_blessings_agnostic_and_ranks",
		// "contains" + match "Unaligned" runs the rename only while the idol
		// item still carries the old Agnostic name.
		.check = "SELECT Name FROM items WHERE id = 9910022",
		.condition = "contains",
		.match = "Unaligned",
		.sql = R"BLESS73(
-- Corrective pass for databases where the blessing spells predate v72, plus the
-- Agnostic rename, repeatable rank tasks, and Rank I delivery gating.
-- Idempotent: plain UPDATEs.

-- Disease must be single target even if 50018 already existed.
UPDATE `spells_new` SET `targettype`=5 WHERE `id`=50018;

-- Re-source the Damage Shield from Nettle Shield (5358) for databases where
-- 50022 predates v72 and still carries the Magician DS fire-resist component.
DELETE FROM `spells_new` WHERE `id`=50022;
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=5358;
UPDATE `tmp_spell` SET `id`=50022, `name`='Blessing: Damage Shield', `descnum`=910000009,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=5358;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- Agnostic naming (drop the deity qualifier on the idol chain).
UPDATE `items`             SET `Name` = 'Unfired Idol' WHERE `id`=9910022;
UPDATE `items`             SET `Name` = 'Fired Idol'   WHERE `id`=9910023;
UPDATE `tradeskill_recipe` SET `name` = 'Unfired Idol' WHERE `id`=992009;
UPDATE `tradeskill_recipe` SET `name` = 'Fired Idol'   WHERE `id`=992010;
UPDATE `tasks`
   SET `title`='Devotion to the Cause',
       `description`='Deliver a forged idol of the Cause to the Keeper of Devotion.'
 WHERE `id`=700017;

-- All devotion ranks are repeatable so a change of faith re-earns from scratch.
UPDATE `tasks` SET `repeatable`=1 WHERE `id` BETWEEN 700001 AND 700017;

-- Rank I idols are only accepted by the Bazaar keeper (344200).
UPDATE `task_activities` SET `npc_match_list`='344200' WHERE `taskid` BETWEEN 700001 AND 700017;

-- Ensure the blessing buffs always stack (safe if v72 already appended them).
UPDATE `rule_values`
SET `rule_value` = CONCAT(`rule_value`, ',50018,50019,50020,50021,50022')
WHERE `rule_name` = 'Spells:AlwaysStackSpells'
  AND `rule_value` NOT LIKE '%50022%';
)BLESS73",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 74,
		.description = "2026_09_24_deity_blessings_tiered_idols",
		// Runs while at least one rank-1 task still has an un-expanded item list.
		.check = "SELECT taskid FROM task_activities WHERE taskid BETWEEN 700001 AND 700015 AND item_id_list NOT LIKE '%|%'",
		.condition = "not_empty",
		.match = "",
		.sql = R"BLESS74(
-- Rank I devotion: accept Enchanted (+1,000,000) and Legendary (+2,000,000)
-- idols, not just the base form. The task-deliver match compares the raw item
-- id (task_client_state.cpp), so the tiered ids must be listed explicitly.
-- Only bases below 1,000,000 are tierable (DoItemUpgrades), so Veeshan
-- (9910021) and Agnostic (9910023) are intentionally left untouched.
-- Idempotent: only rows without an expanded list are updated.

UPDATE `task_activities`
SET `item_id_list` = CONCAT(
        `item_id_list`, '|',
        CAST(`item_id_list` AS UNSIGNED) + 1000000, '|',
        CAST(`item_id_list` AS UNSIGNED) + 2000000)
WHERE `taskid` BETWEEN 700001 AND 700015
  AND `item_id_list` NOT LIKE '%|%';
)BLESS74",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 75,
		.description = "2026_09_25_deity_blessings_idol_rebase",
		// Runs once, while the rebased Veeshan idol is still absent.
		.check = "SELECT id FROM items WHERE id = 976203",
		.condition = "empty",
		.match = "",
		.sql = R"BLESS75(
-- ============================================================================
-- Deity Blessings -- rebase the custom idol chain into valid base IDs
-- Date: 2026-09-25
--
-- The Veeshan/Agnostic chain was authored at 9910018-9910023, which sits inside
-- the item-upgrade number space (tier = id / 1,000,000 = 9). Per the NMS
-- "Legendary & Tiered Item System" guide, Tier 0 bases must be 1-999,999 and
-- the base identity is id % 1,000,000. This rebases the chain to 976200-976205
-- and authors Enchanted (+1,000,000) / Legendary (+2,000,000) tiers for the two
-- Rank I hand-in idols so Veeshan and Agnostic behave like the other gods.
--
-- Guarded: runs only while item 976203 is absent, so it is idempotent.
-- ============================================================================

-- ---- clone the old custom items onto valid bases ----
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910018;
UPDATE `tmp_item` SET `id`=976200, `Name`='Imbued Jacinth', `lore`='Imbued Jacinth-Veeshan', `icon`=767, `loregroup`=0 WHERE `id`=9910018;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910019;
UPDATE `tmp_item` SET `id`=976201, `Name`='Spell: Imbue Jacinth', `lore`='Spell: Imbue Jacinth', `loregroup`=0 WHERE `id`=9910019;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910020;
UPDATE `tmp_item` SET `id`=976202, `Name`='Unfired Idol of Veeshan', `lore`='Unfired Idol of Veeshan', `loregroup`=0 WHERE `id`=9910020;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910021;
UPDATE `tmp_item` SET `id`=976203, `Name`='Golden Idol of Veeshan', `lore`='Golden Idol of Veeshan', `loregroup`=0 WHERE `id`=9910021;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910022;
UPDATE `tmp_item` SET `id`=976204, `Name`='Unfired Idol', `lore`='Unfired Idol', `loregroup`=0 WHERE `id`=9910022;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910023;
UPDATE `tmp_item` SET `id`=976205, `Name`='Fired Idol', `lore`='Fired Idol', `loregroup`=0 WHERE `id`=9910023;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- ---- Enchanted / Legendary tiers for the two Rank I hand-in idols ----
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=976203;
UPDATE `tmp_item` SET `id`=1976203, `Name`='Golden Idol of Veeshan (Enchanted)', `loregroup`=0 WHERE `id`=976203;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=976203;
UPDATE `tmp_item` SET `id`=2976203, `Name`='Golden Idol of Veeshan (Legendary)', `loregroup`=0 WHERE `id`=976203;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=976205;
UPDATE `tmp_item` SET `id`=1976205, `Name`='Fired Idol (Enchanted)', `loregroup`=0 WHERE `id`=976205;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=976205;
UPDATE `tmp_item` SET `id`=2976205, `Name`='Fired Idol (Legendary)', `loregroup`=0 WHERE `id`=976205;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- ---- repoint references from the retired ids ----
UPDATE `spells_new` SET `effect_base_value1`=976200 WHERE `id`=50017;
UPDATE `merchantlist` SET `item`=976201 WHERE `merchantid`=202223 AND `item`=9910019;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976200 WHERE `item_id`=9910018;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976202 WHERE `item_id`=9910020;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976203 WHERE `item_id`=9910021;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976204 WHERE `item_id`=9910022;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976205 WHERE `item_id`=9910023;

UPDATE `task_activities` SET `item_id_list`='976203|1976203|2976203' WHERE `taskid`=700016;
UPDATE `task_activities` SET `item_id_list`='976205|1976205|2976205' WHERE `taskid`=700017;

-- ---- retire the mis-encoded items ----
DELETE FROM `items` WHERE `id` IN (9910018,9910019,9910020,9910021,9910022,9910023);
)BLESS75",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 76,
		.description = "2026_09_24_chardok_assist_radius",
		// Guard: run only while Chardok-spawned NPCs still have an explicit assist radius.
		.check = "SELECT 1 FROM npc_types nt JOIN spawnentry se ON se.npcID = nt.id JOIN spawngroup sg ON sg.id = se.spawngroupID JOIN spawn2 s2 ON s2.spawngroupID = sg.id WHERE s2.zone = 'chardok' AND nt.assistradius > 0 LIMIT 1",
		.condition = "not_empty",
		.match = "",
		.sql = R"CHARDOK(
-- Chardok ships assistradius 85 (most NPCs) and 100 (Overking Bathezid, Queen Velazul),
-- versus the stock 70 and the 0/0 used by every other Kunark dungeon. Chardok rooms are
-- under ~60 units, so an 85-100 unit assist radius pulls allies from adjacent rooms.
-- Reset to 0 so they inherit aggroradius (60) at load: zonedb.cpp maps assistradius <= 0
-- to aggroradius. Idempotent: the guard empties once every row is 0.
UPDATE npc_types SET assistradius = 0
WHERE assistradius > 0
  AND id IN (
    SELECT DISTINCT se.npcID
    FROM spawnentry se
    JOIN spawngroup sg ON sg.id = se.spawngroupID
    JOIN spawn2 s2 ON s2.spawngroupID = sg.id
    WHERE s2.zone = 'chardok'
  );
)CHARDOK",
		.content_schema_update = false,
	},

	ManifestEntry{
		.version = 77,
		.description = "2026_09_25_shar_vahl_druids",
		// Guard: run only while no Druid start row has been moved to Shar Vahl.
		.check = "SELECT 1 FROM start_zones WHERE player_class = 6 AND player_race = 128 AND zone_id = 155 LIMIT 1",
		.condition = "empty",
		.match = "",
		.sql = R"SVDRUID(
-- ============================================================================
-- 2026-09-25 Shar Vahl Druids: Dark Elf (6) / Troll (9) / Ogre (10) / Iksar (128)
-- Druids of these races start in their racial home city, where they die-loop.
-- Move them to Shar Vahl (zone 155), mirroring the Paladin/Ranger rows, and
-- grant the shaman guild summons (18551 Dar Khura Guild Summons) so they can
-- begin the Shar Vahl citizenship chain with Elder Spiritist Grawleh.
--
-- start_zones holds exactly one row per (player_choice, class, deity, race), so
-- the UPDATE replaces the home city for all 17 deity rows per race. Idempotent:
-- the UPDATE is repeatable and the INSERTs are guarded.
-- ============================================================================

UPDATE `start_zones`
SET `zone_id`    = 155,
    `start_zone` = 155,
    `x`          = 100,
    `y`          = 55,
    `z`          = -259.5,
    `heading`    = 0,
    `bind_id`    = 155,
    `bind_x`     = 85,
    `bind_y`     = -1135,
    `bind_z`     = -188
WHERE `player_class` = 6
  AND `player_race` IN (6, 9, 10, 128);

INSERT INTO `starting_items`
    (`class_list`,`race_list`,`deity_list`,`zone_id_list`,`item_id`,`item_charges`,`inventory_slot`,`status`)
SELECT '6','6','0','155',18551,1,-1,0 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `starting_items`
    WHERE `item_id` = 18551 AND `class_list` = '6' AND `race_list` = '6' AND `zone_id_list` = '155'
);

INSERT INTO `starting_items`
    (`class_list`,`race_list`,`deity_list`,`zone_id_list`,`item_id`,`item_charges`,`inventory_slot`,`status`)
SELECT '6','9','0','155',18551,1,-1,0 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `starting_items`
    WHERE `item_id` = 18551 AND `class_list` = '6' AND `race_list` = '9' AND `zone_id_list` = '155'
);

INSERT INTO `starting_items`
    (`class_list`,`race_list`,`deity_list`,`zone_id_list`,`item_id`,`item_charges`,`inventory_slot`,`status`)
SELECT '6','10','0','155',18551,1,-1,0 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `starting_items`
    WHERE `item_id` = 18551 AND `class_list` = '6' AND `race_list` = '10' AND `zone_id_list` = '155'
);

INSERT INTO `starting_items`
    (`class_list`,`race_list`,`deity_list`,`zone_id_list`,`item_id`,`item_charges`,`inventory_slot`,`status`)
SELECT '6','128','0','155',18551,1,-1,0 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `starting_items`
    WHERE `item_id` = 18551 AND `class_list` = '6' AND `race_list` = '128' AND `zone_id_list` = '155'
);
)SVDRUID",
		.content_schema_update = true,
	},

	ManifestEntry{
		.version = 78,
		.description = "2026_09_25_shar_vahl_druid_create_combos",
		// Guard: run only while the Druid create combos are not yet on Shar Vahl.
		.check = "SELECT 1 FROM char_create_combinations WHERE class = 6 AND race = 128 AND start_zone = 155 LIMIT 1",
		.condition = "empty",
		.match = "",
		.sql = R"SVCOMBO(
-- ============================================================================
-- 2026-09-25 Shar Vahl Druids: create-combination city (dropdown)
-- The character-create city dropdown is populated from char_create_combinations:
-- world streams it to the client (OP_CharacterCreateRequest) and
-- CheckCharCreateInfoSoF validates the chosen start_zone against it. start_zones
-- alone only controls where the character lands, so the dropdown still showed the
-- home city (Neriak/Grobb/Oggok/Cabilis) until this runs.
-- PK is (race, class, deity, start_zone) with one row per combo, so no collision.
-- Idempotent: after the first run the guard check is no longer empty.
-- ============================================================================

UPDATE `char_create_combinations`
SET `start_zone` = 155
WHERE `class` = 6 AND `race` IN (6, 9, 10, 128);
)SVCOMBO",
		.content_schema_update = true,
	},

	// Used for testing

	//	ManifestEntry{
	//		.version = 9229,
	//		.description = "new_database_check_test",
	//		.check = "SHOW TABLES LIKE 'new_table'",
	//		.condition = "empty",
	//		.match = "",
	//		.sql = R"(
	// CREATE TABLE `new_table`  (
	//  `id` int NOT NULL AUTO_INCREMENT,
	//  PRIMARY KEY (`id`)
	//);
	// CREATE TABLE `new_table1`  (
	//  `id` int NOT NULL AUTO_INCREMENT,
	//  PRIMARY KEY (`id`)
	//);
	// CREATE TABLE `new_table2`  (
	//  `id` int NOT NULL AUTO_INCREMENT,
	//  PRIMARY KEY (`id`)
	//);
	// CREATE TABLE `new_table3`  (
	//  `id` int NOT NULL AUTO_INCREMENT,
	//  PRIMARY KEY (`id`)
	//);
	//)",
	//	}
};

// see struct definitions for what each field does
// struct ManifestEntry {
// 	int         version{};     // database version of the migration
// 	std::string description{}; // description of the migration ex: "add_new_table" or "add_index_to_table"
// 	std::string check{};       // query that checks against the condition
// 	std::string condition{};   // condition or "match_type" - Possible values [contains|match|missing|empty|not_empty]
// 	std::string match{};       // match field that is not always used, but works in conjunction with "condition" values [missing|match|contains]
// 	std::string sql{};         // the SQL DDL that gets ran when the condition is true
// };
