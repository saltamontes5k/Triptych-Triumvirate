-- 283: Old Man McKenzie's Midnight Snack (skyshrine v41 monster mission).
-- Twin of the manifest v283 entry (common/database/database_update_manifest_custom.cpp).
-- Skyshrine version 41 expedition zone shipped EMPTY (the zone row only --
-- no v0 spawn2 rows are cloned: the Pac-Man maze holds nothing but the
-- mission's own spawns, cake-defense style), the Dwarven Ghost 40 shroud
-- form (race 117 texture 3 -- the Garanel Rucksif hull, the Unrest dwarf
-- ghost; class 16 berserker; the ability window serves the stock Tiger
-- Beast 40 kit through the source row's Animals/Tiger Beast progression and
-- branch; quest scripts call ApplyShroud(504)), the Midnight Snack task
-- 800006 (solo-only; one eat-the-cakes activity, one kill activity per
-- chaser), the invisible controller, three drakes + a drixie + the Sugar
-- Rage golem + the frosted cake, and the controller spawn in skyshrine v41
-- only.
-- Cakes and chasers are controller-spawned dynamically. Their coordinates
-- were sampled from walkable floor faces (z 373-409) of the zone's own
-- collision geometry (Maps/base/skyshrine.map) and deserve an in-game walk
-- before the mission ships.

-- Zone version row: clone skyshrine (zoneidnumber 114) v0 as version 41.
-- CREATE TABLE AS SELECT drops the auto_increment attribute, so give the id
-- explicitly; delete-guarded so re-runs (or a world-boot retry) stay idempotent.
DELETE FROM `zone` WHERE `zoneidnumber` = 114 AND `version` = 41;
DROP TEMPORARY TABLE IF EXISTS `tmp_zone`;
CREATE TEMPORARY TABLE `tmp_zone` AS SELECT * FROM `zone` WHERE `zoneidnumber` = 114 AND `version` = 0 LIMIT 1;
UPDATE `tmp_zone` SET `id` = (SELECT COALESCE(MAX(`id`), 0) + 1 FROM `zone`),
                    `version` = 41, `long_name` = 'Skyshrine: Midnight Snack';
INSERT INTO `zone` SELECT * FROM `tmp_zone`;
DROP TEMPORARY TABLE `tmp_zone`;

-- The instance stays EMPTY: no spawn2 clone. The maze plays Pac-Man with
-- only the mission's own cast (24 cakes + four chasers + the Sugar Rage
-- golem, all controller-spawned at runtime).

-- Dwarven Ghost 40 shroud form. Explicit id 504: quest scripts call
-- ApplyShroud(504). Progression/branch/level/class come from the stock
-- Tiger Beast 40 form (shrouds.id 95, progression 'Animals' / branch
-- 'Tiger Beast') -- same progression/branch means the shroud ability window
-- serves the stock tiger kit (aa band 91000+), and class 16 is berserker.
-- Race 117 texture 3 is the dwarven ghost hull -- the same look as Garanel
-- Rucksif, the Unrest dwarf ghost (npc_types 63062: race 117, texture 3,
-- gender 0, size 6). HP pinned to 900: the chasers hit hard enough that
-- being cornered is death -- the mission's run-or-die rule.
DELETE FROM `shrouds` WHERE `id` = 504;
INSERT INTO `shrouds`
	(`id`,`name`,`progression`,`branch`,`level`,`race`,`gender`,`class`,`texture`,`helmet_texture`,`size`,`hp`,`mana`,`endurance`)
SELECT
	504, 'Dwarven Ghost 40', `progression`, `branch`, `level`, 117, 0, `class`, 3, 3, 6.0,
	900, `mana`, `endurance`
FROM `shrouds` WHERE `id` = 95;

-- Midnight Snack task: min_level 40 (shrouds only go down, never up),
-- solo-only (min/max players 1), repeatable; the rant is the description
-- shown in the task select window (McKenzie opens it from poknowledge via
-- client:TaskSelector). One eat activity for the cakes and one kill
-- activity per chaser (activitytype 1), credited only inside skyshrine
-- version 41 (zones = zoneidnumber 114, zone_version 41). The engine's kill
-- credit needs the killer to be the player, which mirrors the "it has to be
-- you" rule; the controller keeps its own tally as the payout authority.
DELETE FROM `task_activities` WHERE `taskid` = 800006;
DELETE FROM `tasks` WHERE `id` = 800006;
INSERT INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(800006, 2, 600, 1, 'Old Man McKenzie''s Midnight Snack',
	'Old Man McKenzie turns his empty bottle over like it owes him money. "There was a maze, once. Up in the dragon shrine -- past the teleporter, past everything that matters. Winding little corridors of stone, and I sat in them for a week with a bottle of something brown, eating. Rations. Rats. Regrets. Everything is food if you''re sad enough." He taps his temple. "You know what I learned down there? The walls don''t hate you. The walls don''t do ANYTHING. It''s the colored ones that get you. The sad blue one. The mad red one. The glad yellow one. And the little bad one. They''re always hungry too, kid -- that''s the part nobody tells you. And the cakes just sit there. Round. Sweet. Completely unaware of what they are." He shoves a vial at you. "Be the ghost. Not the dead kind -- the hungry kind. Eat every cake in that maze. And when the Sugar Rage comes up out of the floor -- and it WILL -- you run. Rage makes them soft, though, so when the colored ones turn tail and scatter, you eat THEM. All four. Every last cake. Level 40 and up. Alone. It''s always alone in the maze."',
	'The last colored one goes down and the maze goes quiet. Old Man McKenzie''s voice, somewhere behind your eyes: "There. Now you know what I know. The eating never fills the hole -- but the eating is good." Four bottles of the Special Brew find your hand.',
	'', 0, 0, 0, 0, 0, 40, 0, 0, 1, 1, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1);

INSERT INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	(800006, 0, -1, 0, 1, 'frosted cakes', 1, 24, 'Eat 24 of the frosted cakes. Every fourth one wakes the Sugar Rage.', '1520001984', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '114', 41, 0, 0),
	(800006, 1, -1, 0, 1, 'the Sad One', 1, 1, 'Eat the sad blue drake while the Sugar Rage holds.', '1520001979', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '114', 41, 0, 0),
	(800006, 2, -1, 0, 1, 'the Mad One', 1, 1, 'Eat the mad red drake while the Sugar Rage holds.', '1520001980', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '114', 41, 0, 0),
	(800006, 3, -1, 0, 1, 'the Glad One', 1, 1, 'Eat the glad yellow drake while the Sugar Rage holds.', '1520001981', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '114', 41, 0, 0),
	(800006, 4, -1, 0, 1, 'the Bad One', 1, 1, 'Eat the little bad drixie while the Sugar Rage holds.', '1520001982', NULL, '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '114', 41, 0, 0);

-- Mission cast: invisible controller, the four colored ones (Sad = icy-blue
-- drake texture 3, Mad = ruby-red drake texture 2, Glad = the shimmering
-- drake -- the most yellow hull the client owns --, Bad = the drixie), the
-- Sugar Rage golem, and the frosted cake. Chasers are level 40 hunters:
-- npc_aggro 0 because nobody hunts by faction here -- the controller force-
-- feeds them hate on the ghost every poll. The golem is invulnerable by
-- script and exists to be run from. The cake is one hp, one hit, never
-- fights.
DELETE FROM `npc_types` WHERE `id` IN (1520001978,1520001979,1520001980,1520001981,1520001982,1520001983,1520001984);
INSERT INTO `npc_types`
	(`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`mindmg`,`maxdmg`,`attack_delay`,`AC`,`npc_aggro`,`aggroradius`,`npc_faction_id`,`npc_spells_id`,`merchant_id`,`loottable_id`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_details`)
VALUES
	(1520001978,'#Midnight_Snack_Controller','The Ghost of Appetites',100,587,1,3,32000,0,0,0,6,1.25,0,0,30,300,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0),
	(1520001979,'a_sad_drake','The Sad One',40,89,1,1,1300,0,3,255,10,1.10,70,120,30,150,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0),
	(1520001980,'a_mad_drake','The Mad One',40,89,1,1,1400,1,2,255,10,1.10,80,140,30,160,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0),
	(1520001981,'a_glad_drake','The Glad One',40,154,1,1,1200,0,0,255,8,1.05,60,110,30,140,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0),
	(1520001982,'a_bad_drixie','The Bad One',40,113,1,1,900,0,0,255,3,1.20,50,90,25,120,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0),
	(1520001983,'Sugar_Rage','The Cost of Sweetness',45,17,1,1,32000,0,0,255,10,1.10,90,160,30,200,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0),
	(1520001984,'a_frosted_cake','It Just Sits There',1,629,1,1,1,2,0,255,6,0.70,0,0,30,10,0,0,0,0,0,0,0,0,0,0,0,0,255,0,0);

-- Controller spawn: skyshrine v41 only, at the maze-level zone-in point.
-- Cakes and chasers are controller-spawned dynamically -- no static spawns.
DELETE FROM `spawngroup` WHERE `id` = 5004505;
DELETE FROM `spawnentry` WHERE `spawngroupID` = 5004505;
DELETE FROM `spawn2` WHERE `spawngroupID` = 5004505;
INSERT INTO `spawngroup` (`id`,`name`) VALUES (5004505,'midnight_snack_controller_skyshrine_41');
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (5004505,1520001978,100);
INSERT INTO `spawn2`
	(`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
	(5004505,'skyshrine',41,-669.7,1068.2,402.8,0,0,0);

-- verification
SELECT 'zone41' k, COUNT(*) c FROM `zone` WHERE `zoneidnumber` = 114 AND `version` = 41
UNION ALL SELECT 'empty_instance', COUNT(*) FROM `spawn2` WHERE `zone` = 'skyshrine' AND `version` = 41
UNION ALL SELECT 'shroud504', COUNT(*) FROM `shrouds` WHERE `id` = 504 AND `race` = 117
UNION ALL SELECT 'task', COUNT(*) FROM `tasks` WHERE `id` = 800006
UNION ALL SELECT 'activities', COUNT(*) FROM `task_activities` WHERE `taskid` = 800006
UNION ALL SELECT 'npcs', COUNT(*) FROM `npc_types` WHERE `id` BETWEEN 1520001978 AND 1520001984
UNION ALL SELECT 'ctrlspawn', COUNT(*) FROM `spawn2` WHERE `spawngroupID` = 5004505;
