-- Prophecy of Ro - Phase 5 side quests (batch 5)
--   Task 3028  Exploring Arcstone (Spirit Hunter Azmaro)
--   Task 3029  Hero's Challenge  (Oathmir the Outcast)
-- Idempotent.

DELETE FROM `task_activities` WHERE `taskid` IN (3028,3029);
DELETE FROM `tasks` WHERE `id` IN (3028,3029);

INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3028,2,0,0,'Exploring Arcstone','Spirit Hunter Azmaro wants a report on the spirits and dangers of Arcstone. Explore the isle and return to him.','', '',0,20000,0,0,0,55,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3029,2,0,0,'Hero''s Challenge','Oathmir challenges you to prove yourself in the stronghold and the tower of Sullon Zek.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3028,0,-1,1,5,'',0,1,'Explore Arcstone, Isle of Spirits','','','',0, 0,0,0,0,0,0,'','','369',-1,0,0),
 (3028,1,-1,2,4,'Spirit Hunter Azmaro',0,1,'Report back to Spirit Hunter Azmaro','369000','','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3029,0,-1,1,5,'',0,1,'Enter the stronghold','','','',0, 0,0,0,0,0,0,'','','375',-1,0,0),
 (3029,1,-1,2,2,'',0,4,'Defeat the heroes of the stronghold','375001|375002|375003|375004|375005|375006|375007|375008|375009|375010','','',0, 0,0,0,0,0,0,'','','375',-1,0,0),
 (3029,2,-1,3,4,'Oathmir the Outcast',0,1,'Return to Oathmir the Outcast','372000','','',0, 0,0,0,0,0,0,'','','',-1,0,0);
