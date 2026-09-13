-- Prophecy of Ro - Razorthorn access chain task definitions
--   Task 3000  Saga Skins
--   Task 3001  Preparing Your New Skins
--   Task 3002  Become the Vessel
--
-- Idempotent: re-running replaces the three tasks and their activities.
-- Apply to the live `peq` DB, then let `world`/`zone` (or #reloadtasks) pick it up.
--
-- Local PEQ item ids used here (NOT the Allakhazam ids from the walkthroughs):
--   skins  88069-88077   translations 88078-88086   book 88087/88089
--   comb 88090  blood 88091  soot 88092   armor 88093-88097   charm 88099
-- Maelin npc 202125. The Subjugant npc 374016 (Sverag).

DELETE FROM `task_activities` WHERE `taskid` IN (3000, 3001, 3002);
DELETE FROM `tasks` WHERE `id` IN (3000, 3001, 3002);

-- ===========================================================================
-- Task 3000 - Saga Skins
-- ===========================================================================
INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3000,2,0,0,'Saga Skins',
  'The warriors of the Plane of Rage keep their history on their skins. Gather the nine strangely patterned saga skins for Grand Librarian Maelin.',
  '', '', 0, 0, 0, 0, 0, 70, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3000,0,-1,1,3,'',0,1,'Loot a Scarred Bolvirk Skin',          '',      '88069','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3000,1,-1,2,3,'',0,1,'Loot a Mummified Pigmented Skin',      '',      '88070','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3000,2,-1,3,3,'',0,1,'Loot a Patch of Dyed Kobold Fur',      '',      '88071','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3000,3,-1,4,3,'',0,1,'Loot Torn and Tattooed Orc Flesh',     '',      '88072','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3000,4,-1,5,3,'',0,1,'Loot an Inked Evil Eye Hide',          '',      '88073','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3000,5,-1,6,3,'',0,1,'Loot a Decorated Wurine Hide',         '',      '88074','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3000,6,-1,7,3,'',0,1,'Loot an Etched Drachnid Carapace',     '',      '88075','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3000,7,-1,8,3,'',0,1,'Loot a Tattooed Shiliskin Skin',       '',      '88076','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3000,8,-1,9,3,'',0,1,'Loot a Scarred and Tattooed Skin',     '',      '88077','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3000,9,-1,10,1,'Grand Librarian Maelin',0,1,'Deliver the Saga Skin Translations - vol. 1','202125','88087','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3000,10,-1,11,1,'Grand Librarian Maelin',0,1,'Deliver the Saga Skin Translations - vol. 2','202125','88089','',0, 0,0,0,0,0,0,'','','',-1,0,0);

-- ===========================================================================
-- Task 3001 - Preparing Your New Skins
-- ===========================================================================
INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3001,2,0,0,'Preparing Your New Skins',
  'Grand Librarian Maelin will fashion the saga skins you gathered into a suit of Enraged Flesh armor. Gather a Bone Tattoo Comb, Warrior''s Blood and Battleground Soot, then give him the skins.',
  '', '', 0, 0, 0, 0, 0, 70, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3001,0,-1,1,3,'',0,1,'Loot a Bone Tattoo Comb',               '',      '88090','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3001,1,-1,2,3,'',0,5,'Loot vials of Warrior''s Blood',        '',      '88091','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3001,2,-1,3,3,'',0,5,'Loot handfuls of Battleground Soot',    '',      '88092','',0, 0,0,0,0,0,0,'','','372|374|375',-1,0,0),
 (3001,3,-1,4,1,'Grand Librarian Maelin',0,1,'Deliver a Bone Tattoo Comb','202125','88090','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3001,4,-1,5,1,'Grand Librarian Maelin',0,5,'Deliver five Warrior''s Blood','202125','88091','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3001,5,-1,6,1,'Grand Librarian Maelin',0,5,'Deliver five Battleground Soot','202125','88092','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3001,6,-1,7,1,'Grand Librarian Maelin',0,1,'Deliver a Scarred Bolvirk Skin (Enraged Flesh Tunic)','202125','88069','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3001,7,-1,8,1,'Grand Librarian Maelin',0,1,'Deliver Torn and Tattooed Orc Flesh (Enraged Flesh Leggings)','202125','88072','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3001,8,-1,9,1,'Grand Librarian Maelin',0,1,'Deliver a Tattooed Shiliskin Skin (Enraged Flesh Cap)','202125','88076','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3001,9,-1,10,1,'Grand Librarian Maelin',0,1,'Deliver a Scarred and Tattooed Skin (Enraged Flesh Sleeves)','202125','88077','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3001,10,-1,11,1,'Grand Librarian Maelin',0,1,'Deliver a Decorated Wurine Hide (Enraged Flesh Gloves)','202125','88074','',0, 0,0,0,0,0,0,'','','',-1,0,0);

-- ===========================================================================
-- Task 3002 - Become the Vessel (Razorthorn access)
-- ===========================================================================
INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3002,2,0,0,'Become the Vessel',
  'Don the five pieces of Enraged Flesh armor and present yourself to the Subjugant of Rage, vent your rage upon the stronghold, then return to the tower and deliver the armor to Grand Librarian Maelin for the Enraged Flesh Charm.',
  '', '', 0, 0, 0, 0, 0, 70, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3002,0,-1,1,4,'The Subjugant',0,1,'Present yourself to the Subjugant of Rage','374016','','',0, 0,0,0,0,0,0,'','','374',-1,0,0),
 (3002,1,-1,2,2,'',0,60,'Vent your rage upon the stronghold','374001|374002|374003|374004|374005|374006|374007|374008|374009|374010|374011|374012|374013|374014|374015|374016|374018|374019|374020|374021|374022|374023|374024|374025|374026|374027','','',0, 0,0,0,0,0,0,'','','374',-1,0,0),
 (3002,2,-1,3,4,'The Subjugant',0,1,'Return to the Subjugant for judgment','374016','','',0, 0,0,0,0,0,0,'','','374',-1,0,0),
 (3002,3,-1,4,1,'Grand Librarian Maelin',0,1,'Deliver the Enraged Flesh Tunic','202125','88093','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3002,4,-1,5,1,'Grand Librarian Maelin',0,1,'Deliver the Enraged Flesh Leggings','202125','88094','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3002,5,-1,6,1,'Grand Librarian Maelin',0,1,'Deliver the Enraged Flesh Cap','202125','88095','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3002,6,-1,7,1,'Grand Librarian Maelin',0,1,'Deliver the Enraged Flesh Sleeves','202125','88096','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3002,7,-1,8,1,'Grand Librarian Maelin',0,1,'Deliver the Enraged Flesh Gloves','202125','88097','',0, 0,0,0,0,0,0,'','','',-1,0,0);
