-- 278: Old Man McKenzie's Boat Lesson (oot v29 monster mission).
-- Twin of the manifest v278 entry (common/database/database_update_manifest_custom.cpp).
-- Ocean of Tears version 29 expedition zone (v0 spawn2 rows cloned so the
-- instance keeps the world zone's population), the Rusty Steamboat 40 shroud
-- form (race 141 rowboat; quest scripts call ApplyShroud(502)), the Boat
-- Lesson task 800004 with five dock-proximity activities, the invisible
-- controller and two hostile ship tiers, plus the controller's spawns.
-- NOTE: re-running 20260922_shroud_catalog.sql wipes the shrouds table and
-- drops this row; re-run this file afterwards if that ever happens.

-- Zone version row: clone oot (zoneidnumber 69) v0 as version 29.
-- CREATE TABLE AS SELECT drops the auto_increment attribute, so give the id
-- explicitly; delete-guarded so re-runs (or a world-boot retry) stay idempotent.
DELETE FROM `zone` WHERE `zoneidnumber` = 69 AND `version` = 29;
DROP TEMPORARY TABLE IF EXISTS `tmp_zone`;
CREATE TEMPORARY TABLE `tmp_zone` AS SELECT * FROM `zone` WHERE `zoneidnumber` = 69 AND `version` = 0 LIMIT 1;
UPDATE `tmp_zone` SET `id` = (SELECT COALESCE(MAX(`id`), 0) + 1 FROM `zone`),
                    `version` = 29, `long_name` = 'Ocean of Tears: McKenzie''s Boat Lesson';
INSERT INTO `zone` SELECT * FROM `tmp_zone`;
DROP TEMPORARY TABLE `tmp_zone`;

-- spawn2: clone every v0 spawn into version 29 so the instance keeps the
-- world zone's population (merchants, translocators, quest NPCs, mobs) --
-- "don't empty the zone". spawn2.id is auto_increment, so ids are omitted
-- and assigned on insert; the delete-guard keeps re-runs idempotent.
DELETE FROM `spawn2` WHERE `zone` = 'oot' AND `version` = 29;
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)
SELECT `spawngroupID`,`zone`,29,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`
FROM `spawn2` WHERE `zone` = 'oot' AND `version` = 0;

-- Rusty Steamboat 40 shroud form. Explicit id 502: quest scripts call
-- ApplyShroud(502). Progression/branch/level/hp/mana/endurance are copied
-- from the stock Imp Wizard 40 form (shrouds.id 67) so the boat is exactly
-- the level-40 imp wizard with a rowboat hull; the shroud ability window
-- comes from the same Aberrations/Imp Wizard branch. Race 141 is the
-- rowboat model (a_boat / a_row_boat).
DELETE FROM `shrouds` WHERE `id` = 502;
INSERT INTO `shrouds`
	(`id`,`name`,`progression`,`branch`,`level`,`race`,`gender`,`class`,`texture`,`helmet_texture`,`size`,`hp`,`mana`,`endurance`)
SELECT
	502, 'Rusty Steamboat 40', `progression`, `branch`, `level`, 141, `gender`, `class`, `texture`, `helmet_texture`, 5.0,
	`hp`, `mana`, `endurance`
FROM `shrouds` WHERE `id` = 67;

-- Boat Lesson task: min_level 40 (shrouds only go down, never up),
-- repeatable; the rant is the description shown in the task select window
-- (McKenzie opens it from poknowledge via client:TaskSelector). Five explore
-- activities (activitytype 5), one per island dock, credited only inside
-- oot version 29 (zones = zoneidnumber 69, zone_version 29). Boxes are
-- +/-50..60 around each dock's named landing NPCs.
DELETE FROM `task_activities` WHERE `taskid` = 800004;
DELETE FROM `tasks` WHERE `id` = 800004;
INSERT INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(800004, 2, 0, 0, 'Old Man McKenzie''s Boat Lesson',
	'Old Man McKenzie stares out past the fountain like he can still see the water. "In my day, the sight of a boat on the horizon stopped a war cold. Rivals dropped their blades mid-swing just to watch her come in. Guilds ran their raid schedules off the boat timetable, and nobody -- NOBODY -- whined. Now? You lot whine the boats are broken, and you whine louder when they actually run. You don''t respect the boats because you''ve never BEEN one. So -- be one. I''ll drop you in the Ocean of Tears as a battered little rowboat. Float past the docks of every island without being sunk, and maybe you''ll understand what we lost. My jealous old memories will be out there in full sail, and they do not want you to make it." Level 40 and up, solo or up to six. Sinking fails the lesson.',
	'Old Man McKenzie grunts -- almost a smile. "Huh. Maybe there''s hope for your generation yet." He presses a bottle into your hands: one McKenzie''s Special Brew and a point of enlightenment.',
	'', 0, 0, 0, 0, 0, 40, 0, 0, 1, 6, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1);

INSERT INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	(800004, 0, -1, 0, 5, 'the Sister Isle landing', 1, 1, '', NULL, NULL, '', 0, -9907, 1230, -60, -9807, 1330, 300, '-1', '0', '69', 29, 0, 0),
	(800004, 1, -1, 0, 5, 'the Mudtoe landing',      1, 1, '', NULL, NULL, '', 0, -6623,  850, -60, -6523,  950, 300, '-1', '0', '69', 29, 0, 0),
	(800004, 2, -1, 0, 5, 'Capt. Surestout''s dock', 1, 1, '', NULL, NULL, '', 0, -5480,  697, -60, -5360,  817, 300, '-1', '0', '69', 29, 0, 0),
	(800004, 3, -1, 0, 5, 'the Aviak Isle shore',    1, 1, '', NULL, NULL, '', 0,  4183, 2136, -60,  4303, 2256, 300, '-1', '0', '69', 29, 0, 0),
	(800004, 4, -1, 0, 5, 'the East Isle landing',   1, 1, '', NULL, NULL, '', 0,  7661,-2271, -60,  7781,-2151, 300, '-1', '0', '69', 29, 0, 0);

-- NPCs: invisible controller (mirrors the cake controller form) and two
-- hostile ship tiers (race 533, the real ship model behind Golden_Maiden /
-- SirensBane / The_Seaking). Ship hp/damage and the spectre spell set (108)
-- are tuning knobs.
DELETE FROM `npc_types` WHERE `id` IN (1520001940,1520001950,1520001951);
INSERT INTO `npc_types`
	(`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`mindmg`,`maxdmg`,`attack_delay`,`AC`,`npc_aggro`,`aggroradius`,`npc_faction_id`,`npc_spells_id`,`merchant_id`,`loottable_id`)
VALUES
	(1520001940,'#Boat_Lesson_Controller','The Harbor Watch',100,587,1,3,32000,0,0,0,6,1.25,0,0,30,300,0,0,0,0,0,0),
	(1520001950,'a_spiteful_boat','McKenzie''s green memory',40,533,12,1,3000,0,0,0,6,1.25,20,55,30,300,1,400,0,108,0,0),
	(1520001951,'a_seething_wreck','A grudge that will not sink',40,533,12,1,4500,0,0,0,6,1.25,30,70,30,330,1,400,0,108,0,0);

-- Controller spawn: oot version 29 only (v29 instances load spawn2 rows
-- version 29/-1). Hostile ships are controller-spawned dynamically near the
-- boats, like the cake waves -- no static ship spawns.
DELETE FROM `spawngroup` WHERE `id` = 5004503;
DELETE FROM `spawnentry` WHERE `spawngroupID` = 5004503;
DELETE FROM `spawn2` WHERE `spawngroupID` = 5004503;
INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004503,'boat_lesson_controller_oot_29');
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004503,1520001940,100);
INSERT INTO `spawn2`
	(`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
	(5004503,'oot',29,-9200,390,6,0,0,0);

-- verification
SELECT 'zone29' k, COUNT(*) c FROM `zone` WHERE `zoneidnumber` = 69 AND `version` = 29
UNION ALL SELECT 'spawn29', COUNT(*) FROM `spawn2` WHERE `zone` = 'oot' AND `version` = 29
UNION ALL SELECT 'shroud502', COUNT(*) FROM `shrouds` WHERE `id` = 502
UNION ALL SELECT 'task', COUNT(*) FROM `tasks` WHERE `id` = 800004
UNION ALL SELECT 'activities', COUNT(*) FROM `task_activities` WHERE `taskid` = 800004
UNION ALL SELECT 'npcs', COUNT(*) FROM `npc_types` WHERE `id` IN (1520001940,1520001950,1520001951)
UNION ALL SELECT 'ctrlspawn', COUNT(*) FROM `spawn2` WHERE `spawngroupID` = 5004503;
