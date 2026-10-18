-- 112: Spirit-shroud live-like experiment tables (Custom:ShroudLiveMode).
-- Twin of the manifest v112 entry (common/database/database_update_manifest_custom.cpp).
-- Monster-point pool + shroud-AA purchase records for the shroud session, the
-- canonical character_shroud_snapshot DDL (previously applied out-of-band),
-- and two test shroud AAs (categories 3/4) in the free 90100+ id band
-- (aa_ability max 70005, aa_ranks max 90045, client dbstr sids 90100/90101
-- unused in RoF2 #630 dbstr_us.txt).

CREATE TABLE IF NOT EXISTS `character_shroud_points` (
  `character_id` int(10) unsigned NOT NULL,
  `points_available` int(10) unsigned NOT NULL DEFAULT 0,
  `points_spent` int(10) unsigned NOT NULL DEFAULT 0,
  `shroud_id` int(10) unsigned NOT NULL DEFAULT 0,
  `granted_level` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- One row per (character, form, ability): a shroud form remembers what was bought
-- for it, so re-shrouding the same form (tiger, goblin cleric, ...) restores the
-- spread instead of making the player buy it all again.
CREATE TABLE IF NOT EXISTS `character_shroud_aa` (
  `character_id` int(10) unsigned NOT NULL,
  `shroud_id` int(10) unsigned NOT NULL DEFAULT 0,
  `aa_id` int(10) unsigned NOT NULL,
  `value` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`character_id`,`shroud_id`,`aa_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `character_shroud_snapshot` (
  `character_id` int(10) unsigned NOT NULL,
  `race` smallint(5) unsigned NOT NULL DEFAULT 0,
  `gender` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `class` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `level` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `shroud_id` int(10) unsigned NOT NULL DEFAULT 0,
  `texture` tinyint(3) unsigned NOT NULL DEFAULT 255,
  `helmet_texture` tinyint(3) unsigned NOT NULL DEFAULT 255,
  `size` float NOT NULL DEFAULT -1,
  PRIMARY KEY (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

DELETE FROM `aa_rank_effects` WHERE `rank_id` IN (90200,90201,90300);
DELETE FROM `aa_ranks` WHERE `id` IN (90200,90201,90300);
DELETE FROM `aa_ability` WHERE `id` IN (90100,90101);
DELETE FROM `db_str` WHERE `id` IN (90100,90101);

INSERT INTO `aa_ability` (`id`,`name`,`category`,`classes`,`races`,`drakkin_heritage`,`deities`,`status`,`type`,`charges`,`grant_only`,`first_rank_id`,`enabled`,`reset_on_death`,`auto_grant_enabled`) VALUES
(90100,'Shroud Vigor',-1,65535,65535,127,131071,0,1,0,0,90200,1,0,0),
(90101,'Shroud Fireball',-1,65535,65535,127,131071,0,1,0,0,90300,1,0,0);

-- The hotkey sids drive the label the client shows on an AA hotbutton: with the
-- default -1 the button is drawn with no text at all, so both hotkey sids point
-- at the same db_str rows as title_sid.
INSERT INTO `aa_ranks` (`id`,`upper_hotkey_sid`,`lower_hotkey_sid`,`title_sid`,`desc_sid`,`cost`,`level_req`,`spell`,`spell_type`,`recast_time`,`expansion`,`prev_id`,`next_id`) VALUES
(90200,90100,90100,90100,90100,1,1,-1,0,0,0,-1,90201),
(90201,90100,90100,90100,90100,1,1,-1,0,0,0,90200,-1),
(90300,90101,90101,90101,90101,1,1,7414,0,5,0,-1,-1);

INSERT INTO `aa_rank_effects` (`rank_id`,`slot`,`effect_id`,`base1`,`base2`) VALUES
(90200,1,6,2,0),
(90201,1,6,4,0);

INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
(90100,1,'Shroud Vigor'),
(90100,2,'Shroud'),
(90100,3,'Vigor'),
(90100,4,'A monster-body passive: +2 agility per rank while shrouded. (All Classes)'),
(90101,1,'Shroud Fireball'),
(90101,2,'Shroud'),
(90101,3,'Fireball'),
(90101,4,'Hurl a monster fireball (Fire I) while shrouded. (All Classes)');

-- Monster points granted per shroud level follow the live guide's ladder (0 below
-- level 20, then 32/36/40/45/50/55 for levels 20-45, 78 at 50, 84 at 55, 91 at 60,
-- 97 at 65). The guide's per-form totals vary by up to ~40%, so this scale lets a
-- server tune the whole ladder without a rebuild.
INSERT INTO `rule_values` (`ruleset_id`,`rule_name`,`rule_value`,`notes`) VALUES
(1,'Custom:ShroudMonsterPointScale','100','Percent multiplier on the shroud monster-point ladder (100 = live guide baseline)')
ON DUPLICATE KEY UPDATE `rule_value` = VALUES(`rule_value`);
