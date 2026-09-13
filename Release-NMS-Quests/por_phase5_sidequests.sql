-- Prophecy of Ro - Phase 5 side quests (batch 1)
--   Task 3019  The Great Caiman Issue   (Dimbwicket Middifoodle, South Ro)
--   Task 3020  Challenge of the Circle  (Arena Overseer, Relic)
-- Idempotent.

DELETE FROM `task_activities` WHERE `taskid` IN (3019,3020);
DELETE FROM `tasks` WHERE `id` IN (3019,3020);

INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3019,2,0,0,'The Great Caiman Issue','Dimbwicket Middifoodle wants the caimans cleared from the beaches of South Ro.','', '',0,5000,0,0,0,1,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3020,2,0,0,'Challenge of the Circle','The Arena Overseer of Relic challenges you to best the champions of the Circle.','', '',0,0,0,0,0,65,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 -- 3019 The Great Caiman Issue
 (3019,0,-1,1,2,'',0,15,'Clear the caimans from the beach','393090|393107|393108','','',0, 0,0,0,0,0,0,'','','393',-1,0,0),
 (3019,1,-1,2,4,'Dimbwicket Middifoodle',0,1,'Report back to Dimbwicket','393084','','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 3020 Challenge of the Circle
 (3020,0,-1,1,2,'',0,1,'Defeat Arkon of the Sixth Circle','370041','','',0, 0,0,0,0,0,0,'','','370',-1,0,0),
 (3020,1,-1,2,2,'',0,1,'Defeat Hurlinor of the Fifth Circle','370057','','',0, 0,0,0,0,0,0,'','','370',-1,0,0),
 (3020,2,-1,3,2,'',0,1,'Defeat KaChnt of the Fourth Circle','370066','','',0, 0,0,0,0,0,0,'','','370',-1,0,0),
 (3020,3,-1,4,4,'Arena Overseer',0,1,'Return to the Arena Overseer','370021','','',0, 0,0,0,0,0,0,'','','',-1,0,0);
