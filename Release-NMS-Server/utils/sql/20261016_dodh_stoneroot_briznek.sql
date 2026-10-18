-- ---------------------------------------------------------------------------
-- Depths of Darkhollow - Stoneroot Falls: Researcher Briznek's tasks (phase 2)
--
-- NMS-authored reconstruction of the five open-world tasks handed out by
-- #Researcher_Briznek (npc 358070, westkorlach) which the stock DB left
-- unscripted.  Task ids 505785-505789.
--
--   Basilisks           505785  kill 25 basilisks, loot 4 Cracked Basilisk Tails
--   Shiliskins          505786  kill 25 Xillsfar shiliskin, loot 4 Bone Chips
--   Snakes              505787  climb the pillar, kill 20 female redbacks, loot 4 Snake Skins
--   Witherans           505788  kill 30 witherans, loot 4 Aged Witheran Glands
--   The Search for Savil 505789 ten proximity updates -> pages -> combined book
--
-- Evidence notes (see AGENTS "rules of reporting"):
--   * TaskSystem:EnableTaskProximity is read TRUE from rule_values, so the two
--     Explore ("get close to X") activities are live, not latent.
--   * Aged Witheran Glands (85036) drop from *Stoneroot* (westkorlach) witherans;
--     the fan page's "in Undershore" is wrong for this item, so the kill/loot
--     zone here is 358.  The other three components likewise drop only in 358.
--   * The page's shiliskin kill count is self-flagged "45 (is this accurate??)";
--     25 is used to match the other tasks.  Consistent with Basilisks (25) and
--     Snakes (20).
--   * Reward model is the task engine itself (zone/task_client_state.cpp
--     HandleTaskReward): cash_reward is copper, so 50-80pp == 50000-80000.
--
-- Pages/combine: 85051 Assistant Savil's Empty Field Book (10-slot quest
-- container) + pages 85041-85050 -> 85053 Restored Field Book (recipe 938055).
-- 85052 (Collected Field Book) is the lore keepsake handed out by the engine.
--
-- Idempotent (INSERT IGNORE for tasks/activities; DELETE+INSERT for the recipe).
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- 1. Tasks
-- ---------------------------------------------------------------------------

DELETE FROM `task_activities` WHERE `taskid` BETWEEN 505785 AND 505789;
DELETE FROM `tasks`           WHERE `id`     BETWEEN 505785 AND 505789;

INSERT IGNORE INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(505785, 2, 0, 0, 'Basilisks', '[1,Scout the isle where Grokui, the Slumbering Basilisk, makes its lair.][2,Kill twenty-five basilisks in Stoneroot Falls.][3,Recover four Cracked Basilisk Tails.][4,Return the basilisk tails to Researcher Briznek.]', 'Experience, coin and a potion', '40607', 50000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 0, 'Researcher Briznek tucks the tails away and scribbles a note.', 0, 0, 0, 0, 0, -1, 0, 1),
	(505786, 2, 0, 0, 'Shiliskins', '[1,Kill twenty-five Xillsfar shiliskin in the city of Xill.][2,Recover four Damaged Shiliskin Bone Chips.][3,Return the bone chips to Researcher Briznek.]', 'Experience, coin and a potion', '40607', 60000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 0, 'Researcher Briznek puzzles over the shiliskin bone chips.', 0, 0, 0, 0, 0, -1, 0, 1),
	(505787, 2, 0, 0, 'Snakes', '[1,Climb the pillar above the basilisk pools near Stonebite.][2,Kill twenty female Darkhollow redbacks.][3,Recover four Medium Quality Snake Skins.][4,Return the snake skins to Researcher Briznek.]', 'Experience, coin and a potion', '40607', 50000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 0, 'Researcher Briznek smooths the skins flat for his notes.', 0, 0, 0, 0, 0, -1, 0, 1),
	(505788, 2, 0, 0, 'Witherans', '[1,Kill thirty witherans in Stoneroot Falls.][2,Recover four Aged Witheran Glands.][3,Return the glands to Researcher Briznek.]', 'Experience, coin and a potion', '40607', 60000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 0, 'Researcher Briznek seals the glands in a jar.', 0, 0, 0, 0, 0, -1, 0, 1),
	(505789, 2, 0, 0, 'The Search for Savil', '[1,Follow the trail of Assistant Savil across Stoneroot Falls.][2,Combine the recovered pages inside Assistant Savil\'s Field Book.][3,Deliver Assistant Savil\'s Restored Field Book to Researcher Briznek.]', 'Experience, coin, a potion and Assistant Savil\'s Collected Field Book', '40607|85052', 80000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 0, 'Researcher Briznek reads the restored book slowly, then smiles.', 0, 0, 0, 0, 0, -1, 0, 1);

-- ---------------------------------------------------------------------------
-- 2. Task activities
--    activitytype: 1 Deliver, 2 Kill, 3 Loot, 4 SpeakWith, 5 Explore
--    Explore boxes cover the real spawn points of the named Stoneroot landmark
--    for each page (fan-page "260, -1160" == Grokui's isle; "-650, -1400" ==
--    Stonebite's pillar, confirming the Y,X->X,Y conversion).
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	-- 505785 Basilisks
	(505785, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -1185, 239, 10, -1155, 269, 80, '-1', '', '358', -1, 0, 0),
	(505785, 1, -1, 2, 2, 'a_Stoneroot_basilisk', 0, 25, '', '358037|358041', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505785, 2, -1, 3, 3, 'a_Stoneroot_basilisk', 0, 4, '', '358037|358041', '85038', 'Cracked Basilisk Tail', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505785, 3, -1, 4, 1, '', 0, 4, '', '358070', '85038', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505786 Shiliskins
	(505786, 0, -1, 1, 2, 'a_Xillsfar_shiliskin', 0, 25, '', '358000|358001|358002|358004|358005|358006|358007|358008|358011|358012|358014|358015|358017|358024|358026|358027|358032|358034|358035|358060|358065|358077|358085|358103|358109|358111|358118|358134|358158', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505786, 1, -1, 2, 3, 'a_Xillsfar_shiliskin', 0, 4, '', '358000|358001|358002|358004|358005|358006|358007|358008|358011|358012|358014|358015|358017|358024|358026|358027|358032|358034|358035|358060|358065|358077|358085|358103|358109|358111|358118|358134|358158', '85037', 'Damaged Shiliskin Bone Chips', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505786, 2, -1, 3, 1, '', 0, 4, '', '358070', '85037', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505787 Snakes
	(505787, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -1413, -681, 262, -1383, -651, 332, '-1', '', '358', -1, 0, 0),
	(505787, 1, -1, 2, 2, 'a_female_Darkhollow_redback', 0, 20, '', '358054', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505787, 2, -1, 3, 3, 'a_female_Darkhollow_redback', 0, 4, '', '358054|358056|358057', '85039', 'Medium Quality Snake Skin', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505787, 3, -1, 4, 1, '', 0, 4, '', '358070', '85039', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505788 Witherans
	(505788, 0, -1, 1, 2, 'a_witheran', 0, 30, '', '358021|358022|358040|358042|358044|358045|358072|358092|358116|358117', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505788, 1, -1, 2, 3, 'a_witheran', 0, 4, '', '358021|358022|358040|358042|358044|358045|358072|358092|358116|358117', '85036', 'Aged Witheran Glands', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505788, 2, -1, 3, 1, '', 0, 4, '', '358070', '85036', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505789 The Search for Savil (ten proximity updates, all in step 1)
	(505789, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -1185, 239, 10, -1155, 269, 80, '-1', '', '358', -1, 0, 0),
	(505789, 1, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -1413, -681, 262, -1383, -651, 332, '-1', '', '358', -1, 0, 0),
	(505789, 2, -1, 1, 5, '', 0, 1, '', '', '', '', 0, 1466, 546, 47, 1496, 576, 117, '-1', '', '358', -1, 0, 0),
	(505789, 3, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -1493, 1097, 78, -1463, 1127, 148, '-1', '', '358', -1, 0, 0),
	(505789, 4, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -926, 1079, 38, -896, 1109, 108, '-1', '', '358', -1, 0, 0),
	(505789, 5, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -570, -989, 110, -540, -959, 180, '-1', '', '358', -1, 0, 0),
	(505789, 6, -1, 1, 5, '', 0, 1, '', '', '', '', 0, 6, -1015, 51, 36, -985, 121, '-1', '', '358', -1, 0, 0),
	(505789, 7, -1, 1, 5, '', 0, 1, '', '', '', '', 0, 748, -477, 142, 778, -447, 212, '-1', '', '358', -1, 0, 0),
	(505789, 8, -1, 1, 5, '', 0, 1, '', '', '', '', 0, 1050, -701, 199, 1080, -671, 269, '-1', '', '358', -1, 0, 0),
	(505789, 9, -1, 1, 5, '', 0, 1, '', '', '', '', 0, 1269, 572, 36, 1299, 602, 106, '-1', '', '358', -1, 0, 0),
	(505789, 10, -1, 2, 1, '', 0, 1, '', '358070', '85053', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0);

-- ---------------------------------------------------------------------------
-- 3. Assistant Savil's Field Book combine (recipe 938055)
--    85051 (10-slot quest container) + 85041..85050 -> 85053
-- ---------------------------------------------------------------------------

DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` = 938055;
DELETE FROM `tradeskill_recipe` WHERE `id` = 938055;

INSERT INTO `tradeskill_recipe`
	(`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,`quest`,`enabled`,`min_expansion`,`max_expansion`)
VALUES
	(938055, 'Assistant Savil\'s Restored Field Book', 0, 0, 0, 1, 0, 1, 1, -1, -1);

INSERT INTO `tradeskill_recipe_entries`
	(`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
	(938055, 85051, 0, 0, 0, 0, 1),
	(938055, 85041, 0, 0, 1, 0, 0),
	(938055, 85042, 0, 0, 1, 0, 0),
	(938055, 85043, 0, 0, 1, 0, 0),
	(938055, 85044, 0, 0, 1, 0, 0),
	(938055, 85045, 0, 0, 1, 0, 0),
	(938055, 85046, 0, 0, 1, 0, 0),
	(938055, 85047, 0, 0, 1, 0, 0),
	(938055, 85048, 0, 0, 1, 0, 0),
	(938055, 85049, 0, 0, 1, 0, 0),
	(938055, 85050, 0, 0, 1, 0, 0),
	(938055, 85053, 1, 0, 0, 0, 0);
