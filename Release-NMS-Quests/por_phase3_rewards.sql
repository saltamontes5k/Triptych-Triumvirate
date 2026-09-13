-- Prophecy of Ro - Phase 3 rewards
--   Task 3017 "The Chalice of Life" (55th level aura, Lilthill`yan`s Ghost)
--   Lifestone drops on the four Lifestone Guardians
--   Plane of Magic / Skylance reward is granted by Spirit of Ao (script-side).
-- Idempotent.

-- --- Lifestone drops on the guardians ------------------------------------------
DELETE FROM `loottable_entries` WHERE `loottable_id` IN (92064,92065,92066,92067) AND `lootdrop_id` BETWEEN 910010 AND 910013;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 910010 AND 910013;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 910010 AND 910013;

INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES
 (910010,'por_lifestone_autumn',-1,-1),
 (910011,'por_lifestone_winter',-1,-1),
 (910012,'por_lifestone_spring',-1,-1),
 (910013,'por_lifestone_summer',-1,-1);

INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910010,85641,1,0,100,0,0,0,1,0,0,-1,-1), -- Lifestone of Autumn  (376054)
 (910011,85642,1,0,100,0,0,0,1,0,0,-1,-1), -- Lifestone of Winter  (376023)
 (910012,85643,1,0,100,0,0,0,1,0,0,-1,-1), -- Lifestone of Spring  (376008)
 (910013,85644,1,0,100,0,0,0,1,0,0,-1,-1); -- Lifestone of Summer  (376050)

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (92064,910010,1,0,0,100),
 (92067,910011,1,0,0,100),
 (92065,910012,1,0,0,100),
 (92066,910013,1,0,0,100);

-- --- Task 3017 The Chalice of Life ---------------------------------------------
DELETE FROM `task_activities` WHERE `taskid`=3017;
DELETE FROM `tasks` WHERE `id`=3017;

INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3017,2,0,0,'The Chalice of Life',
  'Lilthill`yan`s Ghost asks you to lay the four Lifestone Guardians to rest and return their Lifestones to her.',
  '', '',0,0,0,0,0,55,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3017,0,-1,1,3,'',0,1,'Recover the Lifestone of Autumn','','85641','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3017,1,-1,2,3,'',0,1,'Recover the Lifestone of Winter','','85642','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3017,2,-1,3,3,'',0,1,'Recover the Lifestone of Spring','','85643','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3017,3,-1,4,3,'',0,1,'Recover the Lifestone of Summer','','85644','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3017,4,-1,5,1,'Lilthill`yan`s Ghost',0,1,'Deliver the Lifestone of Autumn','376056','85641','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3017,5,-1,6,1,'Lilthill`yan`s Ghost',0,1,'Deliver the Lifestone of Winter','376056','85642','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3017,6,-1,7,1,'Lilthill`yan`s Ghost',0,1,'Deliver the Lifestone of Spring','376056','85643','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3017,7,-1,8,1,'Lilthill`yan`s Ghost',0,1,'Deliver the Lifestone of Summer','376056','85644','',0, 0,0,0,0,0,0,'','','',-1,0,0);
