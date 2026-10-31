-- 281: Old Man McKenzie's King of the Monsters (moors v40 monster mission).
-- Twin of the manifest v281 entry (common/database/database_update_manifest_custom.cpp).
-- Blightfire Moors version 40 expedition zone (v0 spawn2 rows cloned so the
-- instance keeps the world zone's population -- wildlife stays and hunts the
-- whelps), the Western Moorwalker 40 shroud form (race 436 basilisk;
-- quest scripts call ApplyShroud(503)), the King of the Monsters task 800005
-- with six devour-per-color activities, the invisible controller, six
-- drakkin whelps and the confused froglok, plus the controller's spawn and
-- the McKenzie's Prey faction that makes the moors wildlife scowl at them.
-- Solo-only: the task and the expedition are min/max players 1.

-- Zone version row: clone moors (zoneidnumber 395) v0 as version 40.
-- CREATE TABLE AS SELECT drops the auto_increment attribute, so give the id
-- explicitly; delete-guarded so re-runs (or a world-boot retry) stay idempotent.
DELETE FROM `zone` WHERE `zoneidnumber` = 395 AND `version` = 40;
DROP TEMPORARY TABLE IF EXISTS `tmp_zone`;
CREATE TEMPORARY TABLE `tmp_zone` AS SELECT * FROM `zone` WHERE `zoneidnumber` = 395 AND `version` = 0 LIMIT 1;
UPDATE `tmp_zone` SET `id` = (SELECT COALESCE(MAX(`id`), 0) + 1 FROM `zone`),
                    `version` = 40, `long_name` = 'Blightfire Moors: King of the Monsters';
INSERT INTO `zone` SELECT * FROM `tmp_zone`;
DROP TEMPORARY TABLE `tmp_zone`;

-- spawn2: clone every v0 spawn into version 40 so the instance keeps the
-- world zone's population ("don't empty the zone") EXCEPT the real Western
-- Moorwalker (spawngroup 60299 -- the shrouded player takes his place; the
-- v40 moors has the real one removed). spawn2.id is auto_increment, so ids
-- are omitted and assigned on insert; the delete-guard keeps re-runs
-- idempotent.
DELETE FROM `spawn2` WHERE `zone` = 'moors' AND `version` = 40;
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)
SELECT `spawngroupID`,`zone`,40,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`
FROM `spawn2` WHERE `zone` = 'moors' AND `version` = 0 AND `spawngroupID` <> 60299;

-- Western Moorwalker 40 shroud form. Explicit id 503: quest scripts call
-- ApplyShroud(503). Progression/branch/level/abilities come from the stock
-- Basilisk Beast 40 form (shrouds.id 389, progression 'Reptiles' / branch
-- 'Basilisk Beast') -- same progression/branch means the shroud ability
-- window serves the stock basilisk kit. Race 436 is the basilisk model the
-- real Moorwalker walks; size 40 matches his npc_types size. HP is pinned
-- to 900 (not the 389 copy): one confused-froglok death burst (Venom Blast
-- 11684, -500) is a huge portion and two bursts kill -- per the mission's
-- "eating 2 will kill you" rule.
DELETE FROM `shrouds` WHERE `id` = 503;
INSERT INTO `shrouds`
	(`id`,`name`,`progression`,`branch`,`level`,`race`,`gender`,`class`,`texture`,`helmet_texture`,`size`,`hp`,`mana`,`endurance`)
SELECT
	503, 'Western Moorwalker 40', `progression`, `branch`, `level`, 436, `gender`, `class`, `texture`, `helmet_texture`, 40.0,
	900, `mana`, `endurance`
FROM `shrouds` WHERE `id` = 389;

-- King of the Monsters task: min_level 40 (shrouds only go down, never up),
-- solo-only (min/max players 1), repeatable; the rant is the description
-- shown in the task select window (McKenzie opens it from poknowledge via
-- client:TaskSelector). Six devour activities (activitytype 1), one per
-- whelp color, 2 each, credited only inside moors version 40 (zones =
-- zoneidnumber 395, zone_version 40). The engine's kill credit needs the
-- killer to be the player, which mirrors the "it has to be you" rule; the
-- controller keeps its own strict per-color count as the payout authority.
DELETE FROM `task_activities` WHERE `taskid` = 800005;
DELETE FROM `tasks` WHERE `id` = 800005;
INSERT INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(800005, 2, 300, 1, 'Old Man McKenzie''s King of the Monsters',
	'Old Man McKenzie''s face curdles. "Drakkin. Ugly as a rockslide, can''t dance a step, mope from the cradle, and somehow every last family of them dies in some grand tragedy -- and STILL they hatch 666 whelps a brood. Sixty-six six! Who eats that many? NOBODY, that''s who. They waddle out of Crescent Reach and straight for the Plane of Knowledge stone, every litter of them." He jabs a scarred finger at the moors. "But once -- ONCE -- there was a Moorwalker in those blighted flats. Western Moorwalker. Worked himself to the bone saving the planes, saving Norrath''s eyes and feelings, and what thanks did he get? Forgotten, like the rest of us." He shoves a vial at you. "Be him. Be the monster the moors remember. You have five minutes: devour twelve whelps -- two of EVERY color -- before they touch the stone. The gold ones cheat death once; the black ones wear a harmstring; the blue and white ones are drunk on their own phase tricks. And whatever you do, do NOT swallow the confused froglok. His passing is... explosive." Level 40 and up. Alone. This hunt is McKenzie''s alone, and no circus of helpers is invited.',
	'The last whelp slides down. Old Man McKenzie cackles somewhere behind your eyes: "HA! Twelve! The moors remember, all right -- and so do I." A bottle of the Special Brew finds your hand.',
	'', 0, 0, 0, 0, 0, 40, 0, 0, 1, 1, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1);

INSERT INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	(800005, 0, -1, 0, 1, 'green drakkin whelps', 1, 2, 'Devour 2 of the green whelps.', '1520001971', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '395', 40, 0, 0),
	(800005, 1, -1, 0, 1, 'red drakkin whelps',   1, 2, 'Devour 2 of the red whelps.',   '1520001972', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '395', 40, 0, 0),
	(800005, 2, -1, 0, 1, 'blue drakkin whelps',  1, 2, 'Devour 2 of the drunk blue whelps.',  '1520001973', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '395', 40, 0, 0),
	(800005, 3, -1, 0, 1, 'white drakkin whelps', 1, 2, 'Devour 2 of the drunk white whelps.', '1520001974', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '395', 40, 0, 0),
	(800005, 4, -1, 0, 1, 'gold drakkin whelps',  1, 2, 'Devour 2 of the gold whelps. The first taste always escapes -- Veeshan''s brats get up again.', '1520001975', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '395', 40, 0, 0),
	(800005, 5, -1, 0, 1, 'black drakkin whelps', 1, 2, 'Devour 2 of the black whelps. Their harmstring lasts a breath -- wait it out.', '1520001976', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '395', 40, 0, 0);

-- NPCs: invisible controller (mirrors the boat controller form), six whelp
-- colors (level 5 drakkin, tiny, never fight back -- the scripts disable
-- their melee), and the confused froglok (level 1, harmless, follows the
-- nearest whelp because he is confused; do not eat him).
DELETE FROM `npc_types` WHERE `id` IN (1520001970,1520001971,1520001972,1520001973,1520001974,1520001975,1520001976,1520001977);
INSERT INTO `npc_types`
	(`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`mindmg`,`maxdmg`,`attack_delay`,`AC`,`npc_aggro`,`aggroradius`,`npc_faction_id`,`npc_spells_id`,`merchant_id`,`loottable_id`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_details`)
VALUES
	(1520001970,'#King_of_the_Monsters_Controller','The Moorwalker''s Legacy',100,587,1,3,32000,0,0,0,6,1.25,0,0,30,300,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0),
	(1520001971,'a_green_drakkin_whelp','Green',5,522,1,1,120,0,3,255,3.0,1.40,0,0,30,50,0,0,1520000112,0,0,0,2,3,3,8,8,2,255,1,1),
	(1520001972,'a_red_drakkin_whelp','Red',5,522,1,1,120,1,3,255,3.0,1.40,0,0,30,50,0,0,1520000112,0,0,0,3,3,2,8,8,2,255,2,2),
	(1520001973,'a_blue_drakkin_whelp','Drunk',5,522,1,1,120,0,3,255,3.0,1.40,0,0,30,50,0,0,1520000112,0,0,0,4,3,4,8,8,2,255,3,3),
	(1520001974,'a_white_drakkin_whelp','Drunk',5,522,1,1,120,1,3,255,3.0,1.40,0,0,30,50,0,0,1520000112,0,0,0,5,3,6,8,8,2,255,4,4),
	(1520001975,'a_gold_drakkin_whelp','Gold',5,522,1,1,120,0,3,255,3.0,1.40,0,0,30,50,0,0,1520000112,0,0,0,6,3,5,8,8,2,255,5,5),
	(1520001976,'a_black_drakkin_whelp','Black',5,522,1,1,120,1,3,255,3.0,1.40,0,0,30,50,0,0,1520000112,0,0,0,7,3,7,8,8,2,255,6,6),
	(1520001977,'a_confused_froglok','Where am I? Who are you?',1,330,1,1,200,0,0,255,6.0,1.25,0,0,30,40,0,0,1520000112,0,0,0,0,0,0,0,0,0,255,0,0);

-- McKenzie's Prey: the whelps and the froglok wear this faction; the scowl
-- entries below make every moors wildlife faction (Berserker 16 and the
-- animal factions 1520000047-53) auto-attack them on sight -- NPC-vs-NPC
-- aggro reads the VICTIM's npc_faction_entries. The moors wildlife factions
-- themselves are untouched.
DELETE FROM `npc_faction_entries` WHERE `npc_faction_id` = 1520000112;
DELETE FROM `npc_faction` WHERE `id` = 1520000112;
INSERT INTO `npc_faction` (`id`,`name`,`primaryfaction`,`ignore_primary_assist`) VALUES (1520000112,'Mackenzie''s Prey',0,0);
INSERT INTO `npc_faction_entries` (`npc_faction_id`,`faction_id`,`value`,`npc_value`,`temp`) VALUES
	(1520000112,16,-100,-100,0),
	(1520000112,1520000047,-100,-100,0),
	(1520000112,1520000048,-100,-100,0),
	(1520000112,1520000049,-100,-100,0),
	(1520000112,1520000051,-100,-100,0),
	(1520000112,1520000053,-100,-100,0);

-- Controller spawn: moors version 40 only (v40 instances load spawn2 rows
-- version 40/-1), beside the Plane of Knowledge stone the whelps are racing
-- for. Whelps and the froglok are controller-spawned dynamically -- no
-- static prey spawns.
DELETE FROM `spawngroup` WHERE `id` = 5004504;
DELETE FROM `spawnentry` WHERE `spawngroupID` = 5004504;
DELETE FROM `spawn2` WHERE `spawngroupID` = 5004504;
INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004504,'king_of_monsters_controller_moors_40');
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004504,1520001970,100);
INSERT INTO `spawn2`
	(`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
	(5004504,'moors',40,-1340,-600,25,0,0,0);

-- verification
SELECT 'zone40' k, COUNT(*) c FROM `zone` WHERE `zoneidnumber` = 395 AND `version` = 40
UNION ALL SELECT 'spawn40', COUNT(*) FROM `spawn2` WHERE `zone` = 'moors' AND `version` = 40
UNION ALL SELECT 'no_moorwalker', COUNT(*) FROM `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID WHERE s.zone='moors' AND s.version=40 AND se.npcID = 395153
UNION ALL SELECT 'shroud503', COUNT(*) FROM `shrouds` WHERE `id` = 503 AND `race` = 436
UNION ALL SELECT 'task', COUNT(*) FROM `tasks` WHERE `id` = 800005
UNION ALL SELECT 'activities', COUNT(*) FROM `task_activities` WHERE `taskid` = 800005
UNION ALL SELECT 'npcs', COUNT(*) FROM `npc_types` WHERE `id` BETWEEN 1520001970 AND 1520001977
UNION ALL SELECT 'faction', COUNT(*) FROM `npc_faction` WHERE `id` = 1520000112
UNION ALL SELECT 'faction_entries', COUNT(*) FROM `npc_faction_entries` WHERE `npc_faction_id` = 1520000112
UNION ALL SELECT 'ctrlspawn', COUNT(*) FROM `spawn2` WHERE `spawngroupID` = 5004504;
