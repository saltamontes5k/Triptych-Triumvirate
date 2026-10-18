-- ---------------------------------------------------------------------------
-- Depths of Darkhollow - The Nargilor Pits: Deserting the Ranks (phase 3b)
--
-- NMS-authored reconstruction.  The instanced zone already exists -- illsalinc
-- (zone 350) version 1 -- and already carries the mission cast:
--   an_ornate_chest     350019  (375, -387, -146.5)
--   Guardian_of_the_Pit 350039  (0, -454, -85)
--   a_Shilgrave_legionnaire 350035-350038
-- What the stock DB lacks is the task, the key drop on the v1 chest, the
-- finale captain and his insignia, and the giver wiring (see eastkorlach/Zahn.lua).
--
--   Task 505793 "Deserting the Ranks"
--     [1] loot the Carved Nargil Triangle (86025) from the ornate chest
--     [2] slay the Guardian of the Pit (350039)
--     [3] destroy the Shilgrave Captain (350095, risen by Guardian_of_the_Pit.lua)
--     [4] return the Captain's Insignia (86017) to Zahn (362117)
--   Engine reward: 85530 Gemstone of Emperor Draygun + 88010 Golden Shiliskin
--   Tentacle Ring (Dreadspire access).  min_level 68 (mission_15).
--
-- Evidence notes (see AGENTS "rules of reporting"):
--   * The 86025 key already lived on loottable 91430 / lootdrop 107021 but the
--     v1 chest (350019) had loottable_id 0, so the key was unreachable in the
--     instance; this migration points the v1 chest at 91430.
--   * 86017 had no lootdrop at all; lootdrop/loottable 910240 are added here.
--   * The new captain npc id (350095) is chosen above the illsalinc npc ceiling
--     (350094); its body is a clone of a_Shilgrave_legionnaire (350035) so its
--     model, faction and resists track the stock legionnaires.
--
-- Idempotent (DELETE + INSERT; NPC via temp-table clone with INSERT IGNORE).
-- ---------------------------------------------------------------------------

-- 1. Task ---------------------------------------------------------------------

DELETE FROM `task_activities` WHERE `taskid` = 505793;
DELETE FROM `tasks`           WHERE `id`     = 505793;

INSERT INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(505793, 2, 0, 0, 'Deserting the Ranks', '[1,Search the Nargilor Pits for the Carved Nargil Triangle.][2,Slay the Guardian of the Pit.][3,Destroy the Shilgrave Captain and his legion.][4,Return the Captain\'s Insignia to Zahn.]', 'The Gemstone of Emperor Draygun or the Golden Shiliskin Tentacle Ring', '85530|88010', 0, 0, 0, 0, 0, 68, 0, 0, 0, 0, 1, 0, 'Zahn turns the Shilgrave insignia over in his hands and nods grimly.', 0, 0, 0, 0, 0, -1, 0, 1);

INSERT INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	(505793, 0, -1, 1, 3, 'an_ornate_chest',     0, 1, '', '350019', '86025', 'Carved Nargil Triangle', 0, 0, 0, 0, 0, 0, 0, '-1', '', '350', -1, 0, 0),
	(505793, 1, -1, 2, 2, 'Guardian_of_the_Pit', 0, 1, '', '350039', '',      '',                      0, 0, 0, 0, 0, 0, 0, '-1', '', '350', -1, 0, 0),
	(505793, 2, -1, 3, 2, 'a_Shilgrave_captain', 0, 1, '', '350095', '',      '',                      0, 0, 0, 0, 0, 0, 0, '-1', '', '350', -1, 0, 0),
	(505793, 3, -1, 4, 1, '',                    0, 1, '', '362117', '86017', '',                      0, 0, 0, 0, 0, 0, 0, '-1', '', '-1',  -1, 0, 0);

-- 2. The v1 ornate chest should carry the key ----------------------------------

UPDATE `npc_types` SET `loottable_id` = 91430 WHERE `id` = 350019;

-- 3. The Shilgrave Captain (clone of a_Shilgrave_legionnaire, 350035) ----------

CREATE TEMPORARY TABLE `_tmp_shilgrave_captain` AS SELECT * FROM `npc_types` WHERE `id` = 350035;

UPDATE `_tmp_shilgrave_captain`
	SET `id` = 350095,
	    `name` = 'a_Shilgrave_captain',
	    `level` = 72,
	    `loottable_id` = 910240;

INSERT IGNORE INTO `npc_types` SELECT * FROM `_tmp_shilgrave_captain`;
DROP TEMPORARY TABLE `_tmp_shilgrave_captain`;

-- 4. Shilgrave Captain's Insignia (86017) --------------------------------------

DELETE FROM `lootdrop_entries`  WHERE `lootdrop_id`  = 910240;
DELETE FROM `loottable_entries` WHERE `loottable_id` = 910240;

INSERT INTO `lootdrop_entries`
	(`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
	(910240, 86017, 1, 0, 100, 0, 0, 0, 1, 0, 0, -1, -1);

INSERT INTO `loottable_entries`
	(`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
VALUES
	(910240, 910240, 1, 0, 0, 100);
