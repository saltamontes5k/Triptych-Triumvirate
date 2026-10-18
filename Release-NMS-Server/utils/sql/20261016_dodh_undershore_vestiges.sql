-- ---------------------------------------------------------------------------
-- Depths of Darkhollow - The Undershore: Vestiges of the Empire + Dark Prophecy
-- (phase 3a - open-world quest pair, task ids 505790-505792)
--
-- NMS-authored reconstruction of two tasks the stock DB left unimplemented:
--
--   505790  Investigate the Tomb of Emperor Illsalin
--           given by Brother_Learned_Hand (npc 362097); a single proximity step
--           that fires when the player reaches the Tomb of Emperor Illsalin,
--           npc 362064 at (197, -1125, 49.5) == fan-page "(-1125, 200)" (Y,X).
--           On completion eastkorlach/player.lua grants 505791.
--
--   505791  Vestiges of the Empire
--           collect the five emperor gemstones and deliver them to the Tomb
--           (npc 362064).  Deliver activities are all on step 1 so any subset
--           may be handed in, in any order, and pre-looted stones all count.
--           Engine reward: 89360 The Shattered Blade (evolving range item,
--           evolving set 1059 -- tiers 89360/89361/89362).
--
--   505792  Dark Prophecy
--           given by Brother_Nine_Stones (npc 362007); a proximity step at
--           Jarzarrad the Prophet (npc 362092, 637, -957, 84.5).  The task
--           carries no item reward; eastkorlach/player.lua grants the AA on
--           completion.
--
-- Evidence notes (see AGENTS "rules of reporting"):
--   * TaskSystem:EnableTaskProximity read TRUE from rule_values, so the two
--     Explore activities are live, not latent.
--   * The gemstones 85526 (Shiliskin, illsalin) / 85527 (Shadowmane,
--     westkorlach) / 85529 (Drachnid, drachnidhive) already drop from stock
--     loottables; 85528 and 85530 are the mission rewards of Spies Like Them
--     (mission_08) and Deserting The Ranks (mission_15) respectively.
--   * Deliver matching uses npc_match_list == the Tomb's npc id (362064) and
--     zones '-1' (any zone); the engine stamps TaskDeliveredCount before the
--     NPC event fires, and The_Tomb_of_Emperor_Illsalin.lua consumes exactly
--     the delivered units (Bellfast pattern).
--   * Reward model is the task engine itself (zone/task_client_state.cpp
--     HandleTaskReward); cash_reward is copper, so 0 here.
--
-- Idempotent (DELETE + INSERT IGNORE).
-- ---------------------------------------------------------------------------

DELETE FROM `task_activities` WHERE `taskid` BETWEEN 505790 AND 505792;
DELETE FROM `tasks`           WHERE `id`     BETWEEN 505790 AND 505792;

INSERT IGNORE INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(505790, 2, 0, 0, 'Investigate the Tomb of Emperor Illsalin', '[1,Follow the western shore of the Undershore to the Tomb of Emperor Illsalin.]', '', '', 0, 0, 0, 0, 0, 65, 0, 0, 0, 0, 0, 0, 'You have found the Tomb of Emperor Illsalin.', 0, 0, 0, 0, 0, -1, 0, 1),
	(505791, 2, 0, 0, 'Vestiges of the Empire', '[1,Recover the five gemstones of the fallen emperors of Illsalin.][2,Deliver the gemstones to the Tomb of Emperor Illsalin.]', 'The Shattered Blade', '89360', 0, 0, 0, 0, 0, 65, 0, 0, 0, 0, 1, 0, 'The Tomb accepts the gemstones, and the Shattered Blade is made whole.', 0, 0, 0, 0, 0, -1, 0, 1),
	(505792, 2, 0, 0, 'Dark Prophecy', '[1,Seek out Jarzarrad the Prophet in the Undershore.]', '', '', 0, 0, 0, 0, 0, 65, 0, 0, 0, 0, 0, 0, 'The dark prophecy settles over you.', 0, 0, 0, 0, 0, -1, 0, 1);

-- ---------------------------------------------------------------------------
-- Activities
--   1 Deliver, 2 Kill, 3 Loot, 4 SpeakWith, 5 Explore
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	-- 505790 Investigate the Tomb of Emperor Illsalin (proximity at the Tomb, -1125, 200)
	(505790, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, 167, -1155, 10, 227, -1095, 90, '-1', '', '362', -1, 0, 0),
	-- 505791 Vestiges of the Empire (five gemstones -> the Tomb, npc 362064, all step 1)
	(505791, 0, -1, 1, 1, '', 0, 1, '', '362064', '85526', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505791, 1, -1, 1, 1, '', 0, 1, '', '362064', '85527', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505791, 2, -1, 1, 1, '', 0, 1, '', '362064', '85528', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505791, 3, -1, 1, 1, '', 0, 1, '', '362064', '85529', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505791, 4, -1, 1, 1, '', 0, 1, '', '362064', '85530', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505792 Dark Prophecy (proximity at Jarzarrad the Prophet, 637, -957)
	(505792, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, 607, -987, 45, 667, -927, 125, '-1', '', '362', -1, 0, 0);
