-- Prophecy of Ro - Phase 5 side quests (batch 3)
--   Task 3024  Black Orb of the Scrykin (Apprentice Mage Sarcrynn, Arcstone)
--   Wire the 13 scrykin orbs onto the Relic scrykin (only Daosheen's was obtainable).
-- Idempotent.

-- --- orbs onto Relic scrykin ----------------------------------------------------
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910016;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910016;
DELETE FROM `lootdrop` WHERE `id`=910016;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910016,'por_scrykin_orbs',-1,-1);
INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910016,85623,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85624,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85625,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85626,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85627,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85628,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85629,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85630,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85631,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85632,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85633,1,0,20,0,0,0,1,0,0,-1,-1),
 (910016,85634,1,0,20,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (91889,910016,1,0,0,100),
 (91897,910016,1,0,0,100),
 (91898,910016,1,0,0,100),
 (91904,910016,1,0,0,100),
 (91905,910016,1,0,0,100),
 (91906,910016,1,0,0,100),
 (91907,910016,1,0,0,100),
 (91908,910016,1,0,0,100),
 (91909,910016,1,0,0,100),
 (91910,910016,1,0,0,100);

-- --- Task 3024 Black Orb of the Scrykin -----------------------------------------
DELETE FROM `task_activities` WHERE `taskid`=3024;
DELETE FROM `tasks` WHERE `id`=3024;
INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3024,2,0,0,'Black Orb of the Scrykin','Apprentice Mage Sarcrynn wants the black orbs of all thirteen elder scrykin, that the Black Orb of Scrykin may be forged.','', '',0,0,0,0,0,60,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3024,0,-1,1,3,'',0,1,'Recover the Black Orb of Daosheen the First','','85622','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,1,-1,2,3,'',0,1,'Recover the Black Orb of Porthio the Second','','85623','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,2,-1,3,3,'',0,1,'Recover a scrykin orb','','85624','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,3,-1,4,3,'',0,1,'Recover a scrykin orb','','85625','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,4,-1,5,3,'',0,1,'Recover a scrykin orb','','85626','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,5,-1,6,3,'',0,1,'Recover a scrykin orb','','85627','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,6,-1,7,3,'',0,1,'Recover the Black Orb of Zomm the Seventh','','85628','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,7,-1,8,3,'',0,1,'Recover a scrykin orb','','85629','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,8,-1,9,3,'',0,1,'Recover the Black Orb of Sharlash the Ninth','','85630','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,9,-1,10,3,'',0,1,'Recover a scrykin orb','','85631','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,10,-1,11,3,'',0,1,'Recover the Black Orb of Thanus the Eleventh','','85632','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,11,-1,12,3,'',0,1,'Recover the Black Orb of Maru the Twelfth','','85633','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,12,-1,13,3,'',0,1,'Recover a scrykin orb','','85634','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3024,13,-1,14,1,'Apprentice Mage Sarcrynn',0,1,'Deliver the thirteen scrykin orbs to Sarcrynn','369097','85622|85623|85624|85625|85626|85627|85628|85629|85630|85631|85632|85633|85634','',0, 0,0,0,0,0,0,'','','',-1,0,0);
