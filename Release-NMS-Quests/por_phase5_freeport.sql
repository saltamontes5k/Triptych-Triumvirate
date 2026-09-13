-- Prophecy of Ro - Phase 5 side quests (batch 6): Freeport Arena Charm
--   Task 3030  Arena Champion's Badge (Knight Champion Eddard, Freeport Arena)
--   Spawns arena contestants so the charm task is completable.
-- Idempotent.

DELETE se FROM `spawnentry` se JOIN `spawngroup` sg ON sg.id=se.spawngroupID WHERE sg.id=910006;
DELETE FROM `spawn2` WHERE `id` BETWEEN 910006 AND 910009;
DELETE FROM `spawngroup` WHERE `id`=910006;
DELETE FROM `npc_types` WHERE `name`='an_arena_contestant';

DROP TEMPORARY TABLE IF EXISTS `por_arena_clone`;
CREATE TEMPORARY TABLE `por_arena_clone` AS SELECT * FROM `npc_types` WHERE `id`=382018;
UPDATE `por_arena_clone` SET `id`=0, `name`='an_arena_contestant', `level`=55, `maxlevel`=55, `hp`=5000, `loottable_id`=0;
INSERT INTO `npc_types` SELECT * FROM `por_arena_clone`;
SET @contestant_id = LAST_INSERT_ID();

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`)
VALUES (910006,'por_arena_contestants',0,0,0,0,0,0,45000,15000,0,100,0);
INSERT INTO `spawn2` (`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`)
VALUES
 (910006,910006,'freeportarena',0,-6.75,-42.5,3.0,0,30,0,0,0,0,1,0,-1,-1),
 (910007,910006,'freeportarena',0,6.0,-42.5,3.0,0,30,0,0,0,0,1,0,-1,-1),
 (910008,910006,'freeportarena',0,-14.0,-42.5,3.0,0,30,0,0,0,0,1,0,-1,-1),
 (910009,910006,'freeportarena',0,12.0,-42.5,3.0,0,30,0,0,0,0,1,0,-1,-1);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`)
VALUES (910006,@contestant_id,100,1,0,0,-1,-1);

DELETE FROM `task_activities` WHERE `taskid`=3030;
DELETE FROM `tasks` WHERE `id`=3030;
INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3030,2,0,0,'Arena Champion''s Badge','Knight Champion Eddard wants you to best the arena contestants and prove you are worthy of the Arena Champion''s Badge.','', '',0,0,0,0,0,45,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3030,0,-1,1,2,'',0,4,'Defeat the arena contestants','@contestant','','',0, 0,0,0,0,0,0,'','','388',-1,0,0),
 (3030,1,-1,2,4,'Knight Champion Eddard',0,1,'Return to Knight Champion Eddard','388000','','',0, 0,0,0,0,0,0,'','','',-1,0,0);

UPDATE `task_activities` SET `npc_match_list`=@contestant_id WHERE `taskid`=3030 AND `activityid`=0;
