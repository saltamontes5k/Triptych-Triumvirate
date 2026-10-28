-- 121: Cake Defense test monster mission.
-- Twin of the manifest v121 entry (common/database/database_update_manifest_custom.cpp).
-- Rivervale version 202 expedition zone (empty by spawn2 version filtering),
-- the Birthday Cake 25 shroud form (race 629; quest scripts call
-- ApplyShroud(500)), Confections ability rows mirroring the Elementals test
-- AAs with cake names, baker/controller/wave NPCs and spawns.
-- NOTE: re-running 20260922_shroud_catalog.sql wipes the shrouds table and
-- drops the cake row; re-run this file afterwards if that ever happens.

-- Zone version row: clone rivervale (zoneidnumber 19) v0 as version 202.
-- CREATE TABLE AS SELECT drops the auto_increment attribute, so give the id
-- explicitly; delete-guarded so re-runs (or a world-boot retry) stay idempotent.
DELETE FROM `zone` WHERE `zoneidnumber` = 19 AND `version` = 202;
DROP TEMPORARY TABLE IF EXISTS `tmp_zone`;
CREATE TEMPORARY TABLE `tmp_zone` AS SELECT * FROM `zone` WHERE `zoneidnumber` = 19 AND `version` = 0 LIMIT 1;
UPDATE `tmp_zone` SET `id` = (SELECT COALESCE(MAX(`id`), 0) + 1 FROM `zone`),
                    `version` = 202, `long_name` = 'Rivervale: Fool''s Gold Cake Defense';
INSERT INTO `zone` SELECT * FROM `tmp_zone`;
DROP TEMPORARY TABLE `tmp_zone`;

-- Birthday Cake 25 shroud form. Explicit id 500: quest scripts call
-- ApplyShroud(500); stats derive from base_data like the shroud catalog.
DELETE FROM `shrouds` WHERE `id` = 500 OR `progression` = 'Confections';
INSERT INTO `shrouds`
	(`id`,`name`,`progression`,`branch`,`level`,`race`,`gender`,`class`,`texture`,`helmet_texture`,`size`,`hp`,`mana`,`endurance`)
SELECT
	500, 'Birthday Cake 25', 'Confections', 'Birthday Cake', b.`level`, 629, 2, 14, 0, 255, 6.0,
	CAST(ROUND(5 + b.`hp` + b.`hp_fac` * 75) AS SIGNED),
	CASE WHEN b.`mana` > 0 THEN CAST(ROUND(b.`mana` + b.`mana_fac` * 75) AS SIGNED) ELSE 0 END,
	CAST(ROUND(b.`end` + b.`end_fac` * 75) AS SIGNED)
FROM base_data b
WHERE b.`level` = 25 AND b.`class` = 14;

-- Confections ability rows (mirror the Elementals rows: vigor passive + Fire I active).
DELETE FROM `shroud_abilities` WHERE `progression` = 'Confections';
INSERT INTO `shroud_abilities` (`progression`,`min_level`,`kind`,`aa_id`,`display_order`) VALUES
('Confections',1,'passive',90102,1),
('Confections',1,'active',90103,2);

-- Cake-named clones of the v112 shroud test AAs (90100/90101, ranks 902xx/90300).
DELETE FROM `aa_rank_effects` WHERE `rank_id` IN (90301,90302);
DELETE FROM `aa_ranks` WHERE `id` IN (90301,90302);
DELETE FROM `aa_ability` WHERE `id` IN (90102,90103);
DELETE FROM `db_str` WHERE `id` IN (90102,90103);

INSERT INTO `aa_ability` (`id`,`name`,`category`,`classes`,`races`,`drakkin_heritage`,`deities`,`status`,`type`,`charges`,`grant_only`,`first_rank_id`,`enabled`,`reset_on_death`,`auto_grant_enabled`) VALUES
(90102,'Frosted Vigor',-1,65535,65535,127,131071,0,1,0,0,90301,1,0,0),
(90103,'Sprinkle Bomb',-1,65535,65535,127,131071,0,1,0,0,90302,1,0,0);

INSERT INTO `aa_ranks` (`id`,`upper_hotkey_sid`,`lower_hotkey_sid`,`title_sid`,`desc_sid`,`cost`,`level_req`,`spell`,`spell_type`,`recast_time`,`expansion`,`prev_id`,`next_id`) VALUES
(90301,90102,90102,90102,90102,1,1,-1,0,0,0,-1,-1),
(90302,90103,90103,90103,90103,1,1,7414,0,5,0,-1,-1);

INSERT INTO `aa_rank_effects` (`rank_id`,`slot`,`effect_id`,`base1`,`base2`) VALUES
(90301,1,6,2,0);

INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
(90102,1,'Frosted Vigor'),
(90102,2,'Confection'),
(90102,3,'Vigor'),
(90102,4,'A confection passive: +2 agility while caked. (All Classes)'),
(90103,1,'Sprinkle Bomb'),
(90103,2,'Confection'),
(90103,3,'Bomb'),
(90103,4,'Hurl a fistful of molten sugar (Fire I) while caked. (All Classes)');

-- NPCs: baker, invisible controller (mirrors the bloodmoon controller form),
-- and three wave tiers of hungry adventurers. Stats are tuning knobs.
DELETE FROM `npc_types` WHERE `id` IN (1520001800,1520001801,1520001810,1520001811,1520001812);
INSERT INTO `npc_types`
	(`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`mindmg`,`maxdmg`,`attack_delay`,`AC`,`npc_aggro`,`aggroradius`,`npc_faction_id`,`npc_spells_id`,`merchant_id`,`loottable_id`)
VALUES
	(1520001800,'Wendel_Sweetcrumb','Master Confectioner',30,128,41,1,1500,0,0,0,3,1.25,0,0,30,300,0,0,0,0,0,0),
	(1520001801,'#Cake_Defense_Controller','The Pastry Ward',100,587,1,3,32000,0,0,0,6,1.25,0,0,30,300,0,0,0,0,0,0),
	(1520001810,'a_peckish_adventurer','Could eat a whole halfling',24,1,1,1,270,0,0,0,6,1.25,5,12,30,200,0,150,0,0,0,0),
	(1520001811,'a_famished_adventurer','Has not eaten in days',25,1,1,1,330,0,1,0,6,1.25,6,14,30,220,0,150,0,0,0,0),
	(1520001812,'a_ravenous_adventurer','Smells frosting from a zone away',26,1,1,1,390,0,2,0,6,1.25,7,16,30,240,0,150,0,0,0,0);

-- Spawns: baker in the Bazaar v0, controller in rivervale v202 (version
-- column set explicitly -- v202 instances only load spawn2 version 202/-1).
-- spawn2 id band is shared across sessions: re-grep MAX(id) before reusing.
DELETE FROM `spawngroup` WHERE `id` IN (5004501,5004502);
DELETE FROM `spawnentry` WHERE `spawngroupID` IN (5004501,5004502);
DELETE FROM `spawn2` WHERE `id` IN (1520023003,1520023004);
INSERT INTO `spawngroup` (`id`,`name`) VALUES
	(5004501,'wendel_sweetcrumb_bazaar'),
	(5004502,'cake_defense_controller_rivervale_202');
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
	(5004501,1520001800,100),
	(5004502,1520001801,100);
INSERT INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
	(1520023003,5004501,'bazaar',   0,150,-496,3,0,7200,0),
	(1520023004,5004502,'rivervale',202,-160,-90,3,0,0,0);

-- 2026-10-09 follow-up: the cake AA rows were inserted with upper/lower
-- hotkey_sid = -1. The RoF2 client renders an AA hotbutton from those two
-- dbstr sids, so every cake ability dropped onto a hotbar came out blank
-- (the guide content and the older 90300 row all set hotkey_sid = title_sid).
-- Point each rank's hotkey sids at its own name string.
UPDATE `aa_ranks` SET `upper_hotkey_sid` = `title_sid`, `lower_hotkey_sid` = `title_sid`
WHERE `id` BETWEEN 90300 AND 90313 AND `title_sid` BETWEEN 90101 AND 90114;
