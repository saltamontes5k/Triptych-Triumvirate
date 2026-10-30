-- 284: Old Man McKenzie's Derelict Space Station (netherbian v66 monster
-- mission, group of 1-6). Netherbian Lair version 66 expedition zone: every
-- vanilla combat spawn point is re-targeted at one of three mission
-- replacements (a_leaper_of_the_dark / a_fungal_fiend / a_zombie), ONE
-- spawnentry per point so the task kill-counts are exact and deterministic.
-- Event actors (Lerin_Sardor, Strange, This_passage, Poil_Lolp, #____) and a
-- 60-unit pocket around the zone-in are left out. respawntime 604800 = the
-- infestation never repops: the mission is a full clear, and a respawn would
-- make it incompletable. Event actors are excluded BY NAME (Lerin_Sardor and
-- Poil_Lolp are race-1/229 and would otherwise map to a family).
-- The Master Officer Wizard Armor 40 shroud (race 323 animated armor) is a
-- 1:1 copy of the stock Goblin Wizard 40 form (shrouds.id 221) -- quest
-- scripts call ApplyShroud(505). Task 800007 has three kill activities
-- (Mildew / Leapers / crew). Controller 1520001985 + Watchful Spark
-- 1520001989 spawn statically in v66 only; the mission npcs are 1520001986-
-- 1988 and ALL wear npc_faction 79 (KOS_assist) so the engine's scowls
-- auto-aggro keeps working; leapers are gated by aggroradius 1 (0 would be
-- bumped to 70) until their script reveals them.
-- Standalone copy of the manifest v284 entry. (283 went to the concurrent
-- Midnight Snack mission while this was being authored.)

-- Zone version row: clone netherbian (zoneidnumber 161) v0 as version 66.
-- CREATE TABLE AS SELECT drops the auto_increment attribute, so give the id
-- explicitly; delete-guarded so re-runs stay idempotent.
DELETE FROM `zone` WHERE `zoneidnumber` = 161 AND `version` = 66;
DROP TEMPORARY TABLE IF EXISTS `tmp_zone`;
CREATE TEMPORARY TABLE `tmp_zone` AS SELECT * FROM `zone` WHERE `zoneidnumber` = 161 AND `version` = 0 LIMIT 1;
UPDATE `tmp_zone` SET `id` = (SELECT COALESCE(MAX(`id`), 0) + 1 FROM `zone`),
                    `version` = 66, `long_name` = 'Netherbian Lair: Derelict Space Station';
INSERT INTO `zone` SELECT * FROM `tmp_zone`;
DROP TEMPORARY TABLE `tmp_zone`;

-- Master Officer Wizard Armor 40: the Goblin Wizard 40 form (shrouds.id 221,
-- race 433) with a race-323 animated armor hull. Same progression/branch/
-- level/class means the shroud ability window serves the stock goblin wizard
-- kit; texture 0 / size 5.0 dress the hull.
DELETE FROM `shrouds` WHERE `id` = 505;
INSERT INTO `shrouds`
	(`id`,`name`,`progression`,`branch`,`level`,`race`,`gender`,`class`,`texture`,`helmet_texture`,`size`,`hp`,`mana`,`endurance`)
SELECT
	505, 'Master Officer Wizard Armor 40', `progression`, `branch`, `level`, 323, `gender`, `class`, 0, 255, 5.0,
	`hp`, `mana`, `endurance`
FROM `shrouds` WHERE `id` = 221;

-- Mission npcs: invisible controller (moors template), the Leaper of the
-- Dark and the fungal fiend (level 40 rangers -- special_abilities '11,1' is
-- RangedAttack: they shoot bows at range with no bow item needed), the
-- zombie (melee brute), and the Watchful Spark (harmless station monitor the
-- players can hail). All hostiles wear faction 79 (KOS_assist); the leaper's
-- aggroradius 1 keeps auto-aggro off until the script reveals it.
DELETE FROM `npc_types` WHERE `id` IN (1520001985,1520001986,1520001987,1520001988,1520001989);
INSERT INTO `npc_types`
	(`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`mindmg`,`maxdmg`,`attack_delay`,`AC`,`npc_aggro`,`aggroradius`,`npc_faction_id`,`npc_spells_id`,`merchant_id`,`loottable_id`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_details`,`special_abilities`)
VALUES
	(1520001985,'#Derelict_Station_Controller','The Officer''s Handler',100,587,1,3,32000,0,0,0,6,1.25,0,0,30,300,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0,NULL),
	(1520001986,'a_leaper_of_the_dark','Hides in the dark',40,229,4,1,1600,0,0,255,2.5,1.35,30,55,30,300,0,1,79,0,0,0,0,0,0,0,0,0,255,0,0,'11,1'),
	(1520001987,'a_fungal_fiend','The Mildew''s bloom',40,218,4,1,2000,0,0,255,3.5,1.25,35,60,30,300,1,55,79,0,0,0,0,0,0,0,0,0,255,0,0,'11,1'),
	(1520001988,'a_zombie','Still on duty',40,70,1,1,2600,0,0,0,6,1.05,40,70,30,320,1,55,79,0,0,0,0,0,0,0,0,0,255,0,0,NULL),
	(1520001989,'a_watchful_spark','The station''s monitor',100,72,1,1,32000,0,0,255,3,0.01,0,0,30,300,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0,NULL);

-- Derelict Space Station task: min_level 40 (shrouds only go down, never
-- up), groups of 1-6, repeatable, no time limit; the rant is the description
-- shown in the task select window. Three kill activities (activitytype 1),
-- goalcounts = the exact spawn counts emitted below, credited only inside
-- netherbian version 66 (zones = zoneidnumber 161, zone_version 66).
DELETE FROM `task_activities` WHERE `taskid` = 800007;
DELETE FROM `tasks` WHERE `id` = 800007;
INSERT INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(800007, 2, 0, 0, 'Old Man McKenzie''s Derelict Space Station',
	'Old Man McKenzie''s eyes cross trying to focus on you. "There was a RING, see. Great big Moon-Ring, hung in the sky like a brass farthing somebody owes me. And on the ring there was a STATION -- a derlict one, out in the deep of space. DEEP space, boy. Deeper than the Deep. I was there. Who do you think taught the Watchful Spark to glow?" He hiccups into the Brew. "Then the Mildew came. Crawled off the ring and into the crew -- PWOOF -- zombies, the whole shift, still on duty and absolutely no work ethic left. And the Leapers of the Dark. Fancy armor. Beautiful capes. Hid in the dark like cowards in boots, and I never saw ONE until it was ON me. Woke up in the moon-tunnels three days later wearing somebody else''s boots." He shoves a brass helmet at you. "So suit up, Master Officer. My last squad of Master Officer armors is in the closet -- animated, level 40, wizards to a suit. Go down there: purge the Mildew, silence the Leapers, cull the crew -- EVERY last one -- and do NOT fire the station. We do not talk about who fired the station." Level 40 and up, up to six. Die and the tour''s over.',
	'The station goes quiet. Old Man McKenzie cackles somewhere behind your eyes: "HA! Every last one! The Mildew remembers, the crew remembers, and the Spark won''t stop talking about it. Mind you don''t spill the Brew."',
	'', 0, 0, 0, 0, 0, 40, 0, 0, 1, 6, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1);

INSERT INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	(800007, 0, -1, 0, 1, 'the Mildew', 1, 73, 'Purge 73 of the Mildew.', '1520001987', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '161', 66, 0, 0),
	(800007, 1, -1, 0, 1, 'the Leapers of the Dark', 1, 58, 'Silence 58 of the Leapers of the Dark. They were never there. Until they were.', '1520001986', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '161', 66, 0, 0),
	(800007, 2, -1, 0, 1, 'the shambling crew', 1, 21, 'Cull 21 of the shambling crew. Still on duty.', '1520001988', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '161', 66, 0, 0);

-- Spawns: controller + Watchful Spark statically in v66, then one new
-- spawngroup per combat point (single spawnentry, chance 100) so each point
-- deterministically spawns its replacement. respawn 0 would repop instantly,
-- so the infestation gets 604800s (the engine's own "arbitrarily large"
-- number) -- killed stays dead for the 2h instance.
DELETE FROM `spawn2` WHERE `zone` = 'netherbian' AND `version` = 66;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 5004613 AND 5004766;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 5004613 AND 5004766;
INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004613,'derelict_station_controller_netherbian_66');
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004613,1520001985,100);
INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004614,'derelict_station_watchful_spark_netherbian_66');
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004614,1520001989,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`) VALUES
	(5004613,'netherbian',66,74,-676,4.1,0,0,0),
	(5004614,'netherbian',66,60,-684,6,0,0,0)
;

	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004615,'derelict_station_v66_p29916');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004615,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004616,'derelict_station_v66_p29917');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004616,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004617,'derelict_station_v66_p29918');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004617,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004618,'derelict_station_v66_p29919');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004618,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004619,'derelict_station_v66_p29920');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004619,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004620,'derelict_station_v66_p29921');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004620,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004621,'derelict_station_v66_p29922');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004621,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004622,'derelict_station_v66_p29923');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004622,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004623,'derelict_station_v66_p29924');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004623,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004624,'derelict_station_v66_p29925');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004624,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004625,'derelict_station_v66_p29926');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004625,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004626,'derelict_station_v66_p29927');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004626,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004627,'derelict_station_v66_p29928');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004627,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004628,'derelict_station_v66_p29929');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004628,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004629,'derelict_station_v66_p29930');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004629,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004630,'derelict_station_v66_p29931');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004630,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004631,'derelict_station_v66_p29932');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004631,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004632,'derelict_station_v66_p29933');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004632,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004633,'derelict_station_v66_p29934');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004633,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004634,'derelict_station_v66_p29935');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004634,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004635,'derelict_station_v66_p29936');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004635,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004636,'derelict_station_v66_p29937');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004636,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004637,'derelict_station_v66_p29938');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004637,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004638,'derelict_station_v66_p29940');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004638,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004639,'derelict_station_v66_p29942');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004639,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004640,'derelict_station_v66_p29943');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004640,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004641,'derelict_station_v66_p29944');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004641,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004642,'derelict_station_v66_p29945');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004642,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004643,'derelict_station_v66_p29946');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004643,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004644,'derelict_station_v66_p29947');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004644,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004645,'derelict_station_v66_p29948');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004645,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004646,'derelict_station_v66_p29949');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004646,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004647,'derelict_station_v66_p29950');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004647,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004648,'derelict_station_v66_p29951');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004648,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004649,'derelict_station_v66_p29952');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004649,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004650,'derelict_station_v66_p29954');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004650,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004651,'derelict_station_v66_p29955');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004651,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004652,'derelict_station_v66_p29956');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004652,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004653,'derelict_station_v66_p29957');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004653,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004654,'derelict_station_v66_p29958');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004654,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004655,'derelict_station_v66_p29959');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004655,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004656,'derelict_station_v66_p29960');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004656,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004657,'derelict_station_v66_p29961');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004657,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004658,'derelict_station_v66_p29962');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004658,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004659,'derelict_station_v66_p29963');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004659,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004660,'derelict_station_v66_p29964');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004660,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004661,'derelict_station_v66_p29965');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004661,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004662,'derelict_station_v66_p29966');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004662,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004663,'derelict_station_v66_p29968');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004663,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004664,'derelict_station_v66_p29969');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004664,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004665,'derelict_station_v66_p29970');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004665,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004666,'derelict_station_v66_p29971');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004666,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004667,'derelict_station_v66_p29972');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004667,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004668,'derelict_station_v66_p29973');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004668,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004669,'derelict_station_v66_p29975');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004669,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004670,'derelict_station_v66_p29976');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004670,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004671,'derelict_station_v66_p29977');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004671,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004672,'derelict_station_v66_p29978');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004672,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004673,'derelict_station_v66_p29979');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004673,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004674,'derelict_station_v66_p29980');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004674,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004675,'derelict_station_v66_p29981');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004675,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004676,'derelict_station_v66_p29982');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004676,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004677,'derelict_station_v66_p29983');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004677,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004678,'derelict_station_v66_p29984');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004678,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004679,'derelict_station_v66_p29985');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004679,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004680,'derelict_station_v66_p29986');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004680,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004681,'derelict_station_v66_p29987');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004681,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004682,'derelict_station_v66_p29988');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004682,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004683,'derelict_station_v66_p29989');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004683,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004684,'derelict_station_v66_p29990');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004684,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004685,'derelict_station_v66_p29991');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004685,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004686,'derelict_station_v66_p29992');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004686,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004687,'derelict_station_v66_p29993');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004687,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004688,'derelict_station_v66_p29994');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004688,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004689,'derelict_station_v66_p29995');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004689,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004690,'derelict_station_v66_p29996');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004690,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004691,'derelict_station_v66_p29997');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004691,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004692,'derelict_station_v66_p29998');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004692,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004693,'derelict_station_v66_p29999');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004693,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004694,'derelict_station_v66_p30000');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004694,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004695,'derelict_station_v66_p30001');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004695,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004696,'derelict_station_v66_p30002');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004696,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004697,'derelict_station_v66_p30003');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004697,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004698,'derelict_station_v66_p30004');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004698,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004699,'derelict_station_v66_p30008');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004699,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004700,'derelict_station_v66_p30010');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004700,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004701,'derelict_station_v66_p30011');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004701,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004702,'derelict_station_v66_p30012');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004702,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004703,'derelict_station_v66_p30013');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004703,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004704,'derelict_station_v66_p30014');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004704,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004705,'derelict_station_v66_p30015');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004705,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004706,'derelict_station_v66_p30016');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004706,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004707,'derelict_station_v66_p30017');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004707,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004708,'derelict_station_v66_p30018');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004708,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004709,'derelict_station_v66_p30019');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004709,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004710,'derelict_station_v66_p30020');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004710,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004711,'derelict_station_v66_p30021');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004711,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004712,'derelict_station_v66_p30022');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004712,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004713,'derelict_station_v66_p30023');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004713,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004714,'derelict_station_v66_p30024');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004714,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004715,'derelict_station_v66_p30025');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004715,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004716,'derelict_station_v66_p30026');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004716,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004717,'derelict_station_v66_p30027');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004717,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004718,'derelict_station_v66_p30028');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004718,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004719,'derelict_station_v66_p30029');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004719,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004720,'derelict_station_v66_p30030');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004720,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004721,'derelict_station_v66_p30031');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004721,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004722,'derelict_station_v66_p30032');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004722,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004723,'derelict_station_v66_p30033');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004723,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004724,'derelict_station_v66_p30036');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004724,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004725,'derelict_station_v66_p30037');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004725,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004726,'derelict_station_v66_p30039');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004726,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004727,'derelict_station_v66_p30040');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004727,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004728,'derelict_station_v66_p30041');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004728,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004729,'derelict_station_v66_p30042');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004729,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004730,'derelict_station_v66_p30043');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004730,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004731,'derelict_station_v66_p30044');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004731,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004732,'derelict_station_v66_p30046');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004732,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004733,'derelict_station_v66_p30047');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004733,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004734,'derelict_station_v66_p30048');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004734,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004735,'derelict_station_v66_p30049');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004735,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004736,'derelict_station_v66_p30050');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004736,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004737,'derelict_station_v66_p30051');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004737,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004738,'derelict_station_v66_p30052');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004738,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004739,'derelict_station_v66_p30053');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004739,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004740,'derelict_station_v66_p30054');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004740,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004741,'derelict_station_v66_p30055');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004741,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004742,'derelict_station_v66_p30058');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004742,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004743,'derelict_station_v66_p30059');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004743,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004744,'derelict_station_v66_p30060');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004744,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004745,'derelict_station_v66_p30061');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004745,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004746,'derelict_station_v66_p30062');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004746,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004747,'derelict_station_v66_p30063');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004747,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004748,'derelict_station_v66_p30064');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004748,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004749,'derelict_station_v66_p30065');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004749,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004750,'derelict_station_v66_p30066');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004750,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004751,'derelict_station_v66_p30067');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004751,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004752,'derelict_station_v66_p30068');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004752,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004753,'derelict_station_v66_p30069');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004753,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004754,'derelict_station_v66_p30070');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004754,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004755,'derelict_station_v66_p30071');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004755,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004756,'derelict_station_v66_p30072');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004756,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004757,'derelict_station_v66_p30073');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004757,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004758,'derelict_station_v66_p30074');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004758,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004759,'derelict_station_v66_p30075');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004759,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004760,'derelict_station_v66_p30076');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004760,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004761,'derelict_station_v66_p30077');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004761,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004762,'derelict_station_v66_p30078');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004762,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004763,'derelict_station_v66_p30079');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004763,1520001986,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004764,'derelict_station_v66_p30080');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004764,1520001988,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004765,'derelict_station_v66_p30081');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004765,1520001987,100);
	INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004766,'derelict_station_v66_p30082');
	INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004766,1520001987,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`) VALUES
	(5004615,'netherbian',66,1328.63,-801.13,33.5,130,604800,0),
	(5004616,'netherbian',66,986.25,-678.25,32.75,387,604800,0),
	(5004617,'netherbian',66,694.13,-412.13,43.25,128.75,604800,0),
	(5004618,'netherbian',66,-402.875,557.125,-10.75,0,604800,0),
	(5004619,'netherbian',66,1110.88,-631.25,31.125,348,604800,0),
	(5004620,'netherbian',66,957.375,-606.125,34.75,4,604800,0),
	(5004621,'netherbian',66,-410.625,723.625,-9.125,320,604800,0),
	(5004622,'netherbian',66,177.625,-16,30.125,508,604800,0),
	(5004623,'netherbian',66,298.75,-413.125,27.75,242,604800,0),
	(5004624,'netherbian',66,-599.125,233.75,4.125,0,604800,0),
	(5004625,'netherbian',66,-79.125,212.125,12.75,40,604800,0),
	(5004626,'netherbian',66,-357.625,-245.625,-2.625,14,604800,0),
	(5004627,'netherbian',66,-472.375,223.75,-3.125,14,604800,0),
	(5004628,'netherbian',66,-410.625,723.625,-9.125,322,604800,0),
	(5004629,'netherbian',66,-482.75,749.125,-12.125,22,604800,0),
	(5004630,'netherbian',66,370.5,-177.875,27.125,16,604800,0),
	(5004631,'netherbian',66,1153.88,-774.375,33.25,322,604800,0),
	(5004632,'netherbian',66,957.375,-453.625,36.75,2,604800,0),
	(5004633,'netherbian',66,-20,1649,-65.13,251,604800,0),
	(5004634,'netherbian',66,-107.38,212.13,19.5,129.25,604800,0),
	(5004635,'netherbian',66,951,488,72.75,392,604800,0),
	(5004636,'netherbian',66,-504.38,191.38,-1.13,381.5,604800,0),
	(5004637,'netherbian',66,951,434,72.75,386,604800,0),
	(5004638,'netherbian',66,-329,392,-5.38,5,604800,0),
	(5004639,'netherbian',66,-465.13,-227.25,-2.13,245.75,604800,0),
	(5004640,'netherbian',66,-482.88,-306.88,-0.63,13,604800,0),
	(5004641,'netherbian',66,-404,-242,-2.75,84,604800,0),
	(5004642,'netherbian',66,-394,-308,3,114,604800,0),
	(5004643,'netherbian',66,-245,-456,6.75,356,604800,0),
	(5004644,'netherbian',66,-473.88,-467.63,1.13,255.5,604800,0),
	(5004645,'netherbian',66,389,-123,26.63,16,604800,0),
	(5004646,'netherbian',66,454,-79,23.75,363,604800,0),
	(5004647,'netherbian',66,369.75,-64.25,24.63,363,604800,0),
	(5004648,'netherbian',66,369.75,-19.5,26,363,604800,0),
	(5004649,'netherbian',66,360,118.63,21.75,363,604800,0),
	(5004650,'netherbian',66,1168.13,-544.75,36.75,0.5,604800,0),
	(5004651,'netherbian',66,1204.88,-800.88,31.13,363,604800,0),
	(5004652,'netherbian',66,1168,-426.25,39.88,363,604800,0),
	(5004653,'netherbian',66,1326.63,-609.63,34.75,0.75,604800,0),
	(5004654,'netherbian',66,1113.38,-678.25,32.13,363,604800,0),
	(5004655,'netherbian',66,957.38,-672.13,38.13,363,604800,0),
	(5004656,'netherbian',66,957.38,-485.5,35.75,257.75,604800,0),
	(5004657,'netherbian',66,272.88,-437.38,28.8,248.5,604800,0),
	(5004658,'netherbian',66,299.5,-371.38,24.38,258,604800,0),
	(5004659,'netherbian',66,1037.38,-426.25,35.75,129.5,604800,0),
	(5004660,'netherbian',66,449.5,1017.13,35.75,363,604800,0),
	(5004661,'netherbian',66,521.25,594,35.63,363,604800,0),
	(5004662,'netherbian',66,1174,-834,57.88,363,604800,0),
	(5004663,'netherbian',66,-318.362,413.753,-4.02426,344,604800,0),
	(5004664,'netherbian',66,644.63,1017.13,38.75,363,604800,0),
	(5004665,'netherbian',66,1102,-834,31.75,363,604800,0),
	(5004666,'netherbian',66,-260.778,475.258,0.127006,127.75,604800,0),
	(5004667,'netherbian',66,-673.053,675.933,-8.43222,414,604800,0),
	(5004668,'netherbian',66,-708.137,731.804,-5.87727,224.25,604800,0),
	(5004669,'netherbian',66,-305.75,212.13,-4.13,5,604800,0),
	(5004670,'netherbian',66,49,1650,-65.13,268,604800,0),
	(5004671,'netherbian',66,-472.38,3.25,3.13,0.5,604800,0),
	(5004672,'netherbian',66,-418.63,472.5,-1,1,604800,0),
	(5004673,'netherbian',66,369.75,62.25,23.5,0.5,604800,0),
	(5004674,'netherbian',66,-353.13,-279.13,0.75,5,604800,0),
	(5004675,'netherbian',66,-564,661.25,-1,226,604800,0),
	(5004676,'netherbian',66,-599.13,418,-1.25,257.75,604800,0),
	(5004677,'netherbian',66,-182.13,-304.63,7.75,127,604800,0),
	(5004678,'netherbian',66,-357.63,-137.5,1.13,258.25,604800,0),
	(5004679,'netherbian',66,453.75,-246.88,23.75,257.75,604800,0),
	(5004680,'netherbian',66,774.88,-597,39.38,363,604800,0),
	(5004681,'netherbian',66,997,-414,39,334,604800,0),
	(5004682,'netherbian',66,519.88,-246.63,26.3,508.5,604800,0),
	(5004683,'netherbian',66,808,-630,39,382,604800,0),
	(5004684,'netherbian',66,1168.13,-483.25,39.63,0,604800,0),
	(5004685,'netherbian',66,1265.75,-800.88,29.75,363,604800,0),
	(5004686,'netherbian',66,234.88,-437.38,28.75,363,604800,0),
	(5004687,'netherbian',66,957.38,-548.88,34.8,4.5,604800,0),
	(5004688,'netherbian',66,203.13,-437.38,29.75,363,604800,0),
	(5004689,'netherbian',66,1326.63,-638,34.8,497,604800,0),
	(5004690,'netherbian',66,1175,-656,34.88,363,604800,0),
	(5004691,'netherbian',66,1085,-748,48.63,363,604800,0),
	(5004692,'netherbian',66,188,55,21,504,604800,0),
	(5004693,'netherbian',66,-319.434,546.92,-2.77667,326.5,604800,0),
	(5004694,'netherbian',66,-402.581,620.975,-12.3902,256.25,604800,0),
	(5004695,'netherbian',66,-745.18,735.937,-4.0337,117.75,604800,0),
	(5004696,'netherbian',66,1013.88,-678.25,32.75,363,604800,0),
	(5004697,'netherbian',66,-351.369,519.403,-9.87298,227,604800,0),
	(5004698,'netherbian',66,370.63,-221,30.25,258.5,604800,0),
	(5004699,'netherbian',66,-367.5,453.75,-8.25,424.75,604800,0),
	(5004700,'netherbian',66,369.75,9.5,26,363,604800,0),
	(5004701,'netherbian',66,-402.88,699,-12.13,0.5,604800,0),
	(5004702,'netherbian',66,-411.13,411.38,0.5,247.75,604800,0),
	(5004703,'netherbian',66,-587.75,716.5,-8.63,222.75,604800,0),
	(5004704,'netherbian',66,-511,749.13,-8.38,385.25,604800,0),
	(5004705,'netherbian',66,-472.38,-99.38,2.75,258.5,604800,0),
	(5004706,'netherbian',66,519.63,621.63,39.13,5,604800,0),
	(5004707,'netherbian',66,139,42,25.25,363,604800,0),
	(5004708,'netherbian',66,-776,705,18.75,5,604800,0),
	(5004709,'netherbian',66,16,418,3.8,363,604800,0),
	(5004710,'netherbian',66,945,-409,37,256,604800,0),
	(5004711,'netherbian',66,1097,-704,40.75,363,604800,0),
	(5004712,'netherbian',66,1129,-708,33.88,363,604800,0),
	(5004713,'netherbian',66,1329.63,-689,32,2.5,604800,0),
	(5004714,'netherbian',66,-149.935,457.6,1.14698,127,604800,0),
	(5004715,'netherbian',66,-456.25,749.125,-12.125,8,604800,0),
	(5004716,'netherbian',66,-707,674,-6.125,384,604800,0),
	(5004717,'netherbian',66,-472.375,67.25,-0.75,40,604800,0),
	(5004718,'netherbian',66,361.375,461.125,26.75,24,604800,0),
	(5004719,'netherbian',66,325.625,-412.125,26.625,344,604800,0),
	(5004720,'netherbian',66,1168.12,-622.375,33.25,344,604800,0),
	(5004721,'netherbian',66,626,-412.125,46.125,344,604800,0),
	(5004722,'netherbian',66,815,-677,37,476,604800,0),
	(5004723,'netherbian',66,-650.323,750.37,-8.0078,280.25,604800,0),
	(5004724,'netherbian',66,-599.125,382.875,-0.75,40,604800,0),
	(5004725,'netherbian',66,-472.375,-140.75,2.625,40,604800,0),
	(5004726,'netherbian',66,1093,-652,60.75,344,604800,0),
	(5004727,'netherbian',66,1157,-838,-197.625,344,604800,0),
	(5004728,'netherbian',66,94,1847,74,344,604800,0),
	(5004729,'netherbian',66,448,855,65.5,344,604800,0),
	(5004730,'netherbian',66,812,-571,37,484,604800,0),
	(5004731,'netherbian',66,-535.375,191.375,1.75,8,604800,0),
	(5004732,'netherbian',66,-599.125,275.25,2.375,40,604800,0),
	(5004733,'netherbian',66,127,1777,21.75,344,604800,0),
	(5004734,'netherbian',66,1094,-613,31.75,40,604800,0),
	(5004735,'netherbian',66,-758.75,772.75,18.75,464,604800,0),
	(5004736,'netherbian',66,-607.334,651.717,-3.56442,244.75,604800,0),
	(5004737,'netherbian',66,-320.798,525.546,-9.87298,389.25,604800,0),
	(5004738,'netherbian',66,-241,449.63,0.5,259.25,604800,0),
	(5004739,'netherbian',66,-411.13,411.38,0.5,292.5,604800,0),
	(5004740,'netherbian',66,-106.25,-12.75,4.13,0,604800,0),
	(5004741,'netherbian',66,520.5,-300.88,23.8,3.5,604800,0),
	(5004742,'netherbian',66,9,137.63,3.75,385.5,604800,0),
	(5004743,'netherbian',66,228.5,121.38,22.75,386.25,604800,0),
	(5004744,'netherbian',66,-106.25,-278,14.13,258.25,604800,0),
	(5004745,'netherbian',66,-225.63,-305.38,5.13,1.5,604800,0),
	(5004746,'netherbian',66,177.63,-85.75,30.63,0.25,604800,0),
	(5004747,'netherbian',66,329.625,121.375,22,344,604800,0),
	(5004748,'netherbian',66,-472.25,380.125,-6.625,22,604800,0),
	(5004749,'netherbian',66,-267.75,212.125,-1.5,14,604800,0),
	(5004750,'netherbian',66,-258.5,414.875,-3.75,8,604800,0),
	(5004751,'netherbian',66,-148.25,-305.125,8.75,2,604800,0),
	(5004752,'netherbian',66,-472.375,223.75,-3.125,0,604800,0),
	(5004753,'netherbian',66,-280.875,-467,1.125,472,604800,0),
	(5004754,'netherbian',66,299.5,-246.625,22.875,2,604800,0),
	(5004755,'netherbian',66,175.5,132.5,22.375,336,604800,0),
	(5004756,'netherbian',66,-69.375,212.125,11,0,604800,0),
	(5004757,'netherbian',66,-354.125,-467.5,0.75,0,604800,0),
	(5004758,'netherbian',66,15.5,1037.38,-45,0,604800,0),
	(5004759,'netherbian',66,511.25,-412.5,29.625,24,604800,0),
	(5004760,'netherbian',66,-402.875,571.125,-12.125,12,604800,0),
	(5004761,'netherbian',66,-419.125,748.75,-7.5,14,604800,0),
	(5004762,'netherbian',66,-472.5,187.25,-4.125,8,604800,0),
	(5004763,'netherbian',66,-377,212.125,-3.125,24,604800,0),
	(5004764,'netherbian',66,-319.875,91.875,7,504,604800,0),
	(5004765,'netherbian',66,453.75,-147.75,23.75,4,604800,0),
	(5004766,'netherbian',66,1168.12,-483.25,39.625,16,604800,0)
;

-- verification
SELECT 'zone66' k, COUNT(*) c FROM `zone` WHERE `zoneidnumber` = 161 AND `version` = 66
UNION ALL SELECT 'spawn66', COUNT(*) FROM `spawn2` WHERE `zone` = 'netherbian' AND `version` = 66
UNION ALL SELECT 'shroud505', COUNT(*) FROM `shrouds` WHERE `id` = 505 AND `race` = 323
UNION ALL SELECT 'task', COUNT(*) FROM `tasks` WHERE `id` = 800007
UNION ALL SELECT 'activities', COUNT(*) FROM `task_activities` WHERE `taskid` = 800007
UNION ALL SELECT 'npcs', COUNT(*) FROM `npc_types` WHERE `id` BETWEEN 1520001985 AND 1520001989
UNION ALL SELECT 'leaper_pts', COUNT(*) FROM `spawnentry` WHERE `npcID` = 1520001986
UNION ALL SELECT 'fiend_pts', COUNT(*) FROM `spawnentry` WHERE `npcID` = 1520001987
UNION ALL SELECT 'zombie_pts', COUNT(*) FROM `spawnentry` WHERE `npcID` = 1520001988
UNION ALL SELECT 'no_respawn', COUNT(*) FROM `spawn2` WHERE `zone` = 'netherbian' AND `version` = 66 AND `respawntime` < 604800 AND `spawngroupID` >= 5004615;
