-- Prophecy of Ro - Phase 5 side quests (batch 4): Tunare's Shrine corruption chain
--   Task 3025  Investigating the Elddar
--   Task 3026  Questioning the Priest
--   Task 3027  Key to Corruption
--   Final turn-in to Shalowen the Pure yields The Chalice of Life (85670).
-- Idempotent.

-- --- quest-item drops -----------------------------------------------------------
DELETE FROM `loottable_entries` WHERE `lootdrop_id` IN (910017,910018,910019);
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` IN (910017,910018,910019);
DELETE FROM `lootdrop` WHERE `id` IN (910017,910018,910019);

INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES
 (910017,'por_figurine_of_ro',-1,-1),
 (910018,'por_sealed_scroll_of_ro',-1,-1),
 (910019,'por_carved_wooden_key',-1,-1);

INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
 (910017,85076,1,0,40,0,0,0,1,0,0,-1,-1),
 (910018,85080,1,0,100,0,0,0,1,0,0,-1,-1),
 (910019,85079,1,0,40,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (92145,910017,1,0,0,100),
 (92146,910017,1,0,0,100),
 (92147,910017,1,0,0,100),
 (92148,910017,1,0,0,100),
 (92149,910017,1,0,0,100),
 (92150,910017,1,0,0,100),
 (92152,910018,1,0,0,100),
 (92116,910019,1,0,0,100),
 (92129,910019,1,0,0,100);

-- --- tasks ---------------------------------------------------------------------
DELETE FROM `task_activities` WHERE `taskid` IN (3025,3026,3027);
DELETE FROM `tasks` WHERE `id` IN (3025,3026,3027);

INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3025,2,0,0,'Investigating the Elddar','Recover the Figurine of Ro from the corrupted Elddar within Tunare''s Shrine.','', '',0,0,0,0,0,65,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3026,2,0,0,'Questioning the Priest','Recover the Sealed Scroll of Ro from the priest of Ro within Tunare''s Shrine.','', '',0,0,0,0,0,65,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3027,2,0,0,'Key to Corruption','Recover the Carved Wooden Key from the treants of the Elddar Forest.','', '',0,0,0,0,0,65,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3025,0,-1,1,3,'',0,1,'Recover the Figurine of Ro','','85076','',0, 0,0,0,0,0,0,'','','379',-1,0,0),
 (3025,1,-1,2,1,'Shalowen the Pure',0,1,'Deliver the Figurine of Ro to Shalowen','378059','85076','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3026,0,-1,1,3,'',0,1,'Recover the Sealed Scroll of Ro','','85080','',0, 0,0,0,0,0,0,'','','379',-1,0,0),
 (3026,1,-1,2,1,'Shalowen the Pure',0,1,'Deliver the Sealed Scroll of Ro to Shalowen','378059','85080','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3027,0,-1,1,3,'',0,1,'Recover the Carved Wooden Key','','85079','',0, 0,0,0,0,0,0,'','','378',-1,0,0),
 (3027,1,-1,2,1,'Shalowen the Pure',0,1,'Deliver the Carved Wooden Key to Shalowen','378059','85079','',0, 0,0,0,0,0,0,'','','',-1,0,0);
