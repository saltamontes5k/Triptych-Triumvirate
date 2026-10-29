-- Existing Welcome to Shards Landing prerequisite and original PEQ shard pickups.
START TRANSACTION;
INSERT INTO `tasks` (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`) VALUES
(910000,2,0,0,'Welcome to Shard''s Landing','Meet the Harbingers of Thule, explore the landing and investigate the Silent Hall. Return the unusual crystal to Overseer Drent.','225 platinum, experience and 3 AA points',NULL,225000,-10002,0,0,0,85,0,0,0,0,0,1822,'',0,0,0,0,0,-1,100,1)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`type`=VALUES(`type`),`duration`=VALUES(`duration`),`duration_code`=VALUES(`duration_code`),`title`=VALUES(`title`),`description`=VALUES(`description`),`reward_text`=VALUES(`reward_text`),`reward_id_list`=VALUES(`reward_id_list`),`cash_reward`=VALUES(`cash_reward`),`exp_reward`=VALUES(`exp_reward`),`reward_method`=VALUES(`reward_method`),`reward_points`=VALUES(`reward_points`),`reward_point_type`=VALUES(`reward_point_type`),`min_level`=VALUES(`min_level`),`max_level`=VALUES(`max_level`),`level_spread`=VALUES(`level_spread`),`min_players`=VALUES(`min_players`),`max_players`=VALUES(`max_players`),`repeatable`=VALUES(`repeatable`),`faction_reward`=VALUES(`faction_reward`),`completion_emote`=VALUES(`completion_emote`),`replay_timer_group`=VALUES(`replay_timer_group`),`replay_timer_seconds`=VALUES(`replay_timer_seconds`),`request_timer_group`=VALUES(`request_timer_group`),`request_timer_seconds`=VALUES(`request_timer_seconds`),`dz_template_id`=VALUES(`dz_template_id`),`lock_activity_id`=VALUES(`lock_activity_id`),`faction_amount`=VALUES(`faction_amount`),`enabled`=VALUES(`enabled`);
DELETE FROM task_activities WHERE taskid=910000;
INSERT INTO `task_activities` (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`) VALUES
(910000,0,-1,0,5,'Harbinger''s Outpost',0,1,'',NULL,NULL,'',0,-200,-85,-59,400,515,61,'-1','0','752',0,0,0),
(910000,1,-1,1,4,'Overseer Drent',0,1,'','752119',NULL,'',0,0,0,0,0,0,0,'-1','0','752',0,0,0),
(910000,2,-1,2,4,'Master Hunter Jilare',0,1,'','752118',NULL,'',0,0,0,0,0,0,0,'-1','0','752',0,0,0),
(910000,3,-1,3,5,'Magus Burlshin''s Camp',0,1,'',NULL,NULL,'',0,-1200,-1550,-60,-1000,-1350,60,'-1','0','752',0,0,0),
(910000,4,-1,3,5,'Valley of the Naeya',0,1,'',NULL,NULL,'',0,-1500,-1020,-55,-1300,-820,65,'-1','0','752',0,0,0),
(910000,5,-1,3,5,'Banescale''s Den',0,1,'',NULL,NULL,'',0,-1350,700,-57,-1150,900,63,'-1','0','752',0,0,0),
(910000,6,-1,3,5,'Village of the Forsaken',0,1,'',NULL,NULL,'',0,-1980,320,-59,-1780,520,61,'-1','0','752',0,0,0),
(910000,7,-1,3,5,'Greenscale Nest',0,1,'',NULL,NULL,'',0,1080,550,-59,1280,750,61,'-1','0','752',0,0,0),
(910000,8,-1,3,5,'Pyrebeak''s Peak',0,1,'',NULL,NULL,'',0,605,-375,90,805,-175,210,'-1','0','752',0,0,0),
(910000,9,-1,3,5,'Corruption''s End',0,1,'',NULL,NULL,'',0,730,-1300,-50,930,-1100,70,'-1','0','752',0,0,0),
(910000,10,-1,3,5,'Worntooth''s Run',0,1,'',NULL,NULL,'',0,-450,1950,-59,-250,2150,61,'-1','0','752',0,0,0),
(910000,11,-1,3,5,'Cragfeast Rock',0,1,'',NULL,NULL,'',0,-1400,1760,-50,-1200,1960,70,'-1','0','752',0,0,0),
(910000,12,-1,3,5,'Infested Plain',0,1,'',NULL,NULL,'',0,790,1925,-94,990,2125,26,'-1','0','752',0,0,0),
(910000,13,-1,3,5,'Stonecoat''s Plateau',0,1,'',NULL,NULL,'',0,1500,1400,-36,1700,1600,84,'-1','0','752',0,0,0),
(910000,14,-1,4,5,'Underground City',0,1,'',NULL,NULL,'',0,2000,350,-345,2200,550,-225,'-1','0','752',0,0,0),
(910000,15,-1,4,5,'Council Chambers',0,1,'',NULL,NULL,'',0,2100,-700,-462,2300,-500,-342,'-1','0','752',0,0,0),
(910000,16,-1,4,5,'Silent Hall',0,1,'',NULL,NULL,'',0,570,-500,-810,770,-300,-690,'-1','0','752',0,0,0),
(910000,17,-1,5,13,'Small Crystalline Shard',0,1,'',NULL,'85971','',0,0,0,0,0,0,0,'-1','0','752',0,0,0),
(910000,18,-1,6,1,'Overseer Drent',0,1,'','752119','85971','',0,0,0,0,0,0,0,'-1','0','752',0,0,0)
ON DUPLICATE KEY UPDATE `taskid`=VALUES(`taskid`),`activityid`=VALUES(`activityid`),`req_activity_id`=VALUES(`req_activity_id`),`step`=VALUES(`step`),`activitytype`=VALUES(`activitytype`),`target_name`=VALUES(`target_name`),`goalmethod`=VALUES(`goalmethod`),`goalcount`=VALUES(`goalcount`),`description_override`=VALUES(`description_override`),`npc_match_list`=VALUES(`npc_match_list`),`item_id_list`=VALUES(`item_id_list`),`item_list`=VALUES(`item_list`),`dz_switch_id`=VALUES(`dz_switch_id`),`min_x`=VALUES(`min_x`),`min_y`=VALUES(`min_y`),`min_z`=VALUES(`min_z`),`max_x`=VALUES(`max_x`),`max_y`=VALUES(`max_y`),`max_z`=VALUES(`max_z`),`skill_list`=VALUES(`skill_list`),`spell_list`=VALUES(`spell_list`),`zones`=VALUES(`zones`),`zone_version`=VALUES(`zone_version`),`optional`=VALUES(`optional`),`list_group`=VALUES(`list_group`);
INSERT INTO `ground_spawns` (`id`,`zoneid`,`version`,`max_x`,`max_y`,`max_z`,`min_x`,`min_y`,`heading`,`name`,`item`,`max_allowed`,`comment`,`respawn_timer`,`fix_z`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`) VALUES
(1761,752,0,780,30,-747,780,30,0,'IT11154_ACTORDEF',85971,1,'EQQuests 5978 mapped shard location 1; audit 20261015',300,0,19,-1,NULL,NULL),
(1762,752,0,550,-120,-747,550,-120,0,'IT11154_ACTORDEF',85971,1,'EQQuests 5978 mapped shard location 2; audit 20261015',300,0,19,-1,NULL,NULL),
(1763,752,0,790,-310,-747,790,-310,0,'IT11154_ACTORDEF',85971,1,'EQQuests 5978 mapped shard location 3; audit 20261015',300,0,19,-1,NULL,NULL)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`zoneid`=VALUES(`zoneid`),`version`=VALUES(`version`),`max_x`=VALUES(`max_x`),`max_y`=VALUES(`max_y`),`max_z`=VALUES(`max_z`),`min_x`=VALUES(`min_x`),`min_y`=VALUES(`min_y`),`heading`=VALUES(`heading`),`name`=VALUES(`name`),`item`=VALUES(`item`),`max_allowed`=VALUES(`max_allowed`),`comment`=VALUES(`comment`),`respawn_timer`=VALUES(`respawn_timer`),`fix_z`=VALUES(`fix_z`),`min_expansion`=VALUES(`min_expansion`),`max_expansion`=VALUES(`max_expansion`),`content_flags`=VALUES(`content_flags`),`content_flags_disabled`=VALUES(`content_flags_disabled`);
COMMIT;
