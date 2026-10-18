-- ---------------------------------------------------------------------------
-- Depths of Darkhollow - Undershore / Stoneroot Falls open-world missions
-- (phase 1: the repeatable side tasks whose NPCs exist but were unscripted).
--
-- NMS-authored reconstruction of the DoDH side missions the stock DB left
-- unwired (the giver NPCs are present in npc_types, no tasks/activities were).
--   Undershore (eastkorlach): Free Trader Arislo, Hourglass, Slave Trader Arad,
--   Slave Trader Bologore, Slave Trader Zillvinshin, Zahn.
--
-- Task ids 505772-505784; reward model is the task engine itself (see
-- zone/task_client_state.cpp HandleTaskReward): it pays reward_id_list items,
-- cash_reward (copper), faction_reward/faction_amount and exp on completion, so
-- the quest scripts only assign tasks and hand out containers.
--
-- Container combines (player-made via the quest container items):
--   85550 Arad's Spear            : 10x 85548 Deep Orc Head            -> 85549 Totem of Impaled Orc Heads
--   85552 Zillvinshin's Trophy Belt: 10x 85551 Withered Shiliskin Tentacle -> 85553 Tentacle-Laden Trophy Belt
--   85562 Hourglass' Voodoo Skull : 10x 85563 Drachnid Spirit          -> 85564 Skull of Spirits
--
-- Idempotent (INSERT IGNORE for keyed rows; DELETE+INSERT for loot/recipes).
-- Apply with:
--   mariadb -u <user> -p <db> < 20261016_dodh_undershore_missions.sql
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- 1. Tasks
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(505772, 2, 0, 0, 'Arislo\'s Armor', '[1,Gather two Undamaged Splorgath Skins, two Witheran Carapaces and two Witheran Teeth for Free Trader Arislo.]', 'Free Traders of Malgrinnor faction', '', 0, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'Free Trader Arislo nods and tucks the hides away.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505773, 2, 0, 0, 'Arislo\'s Weapons', '[1,Gather two Undamaged Splorgath Skins and two Cursed Shiliskin Thigh Bones for Free Trader Arislo.]', 'Free Traders of Malgrinnor faction', '', 0, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'Free Trader Arislo tests the edge of the shiliskin bone.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505774, 2, 0, 0, 'Arislo\'s Food', '[1,Gather two Gloms, two Serinals and two Bottles of Grandlor for Free Trader Arislo.]', 'Free Traders of Malgrinnor faction', '', 0, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'Free Trader Arislo licks his lips at the Grandlor.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505775, 2, 0, 0, 'Handy Work', '[1,Gather two Cursed Shiliskin Hands for Free Trader Arislo.]', 'Free Traders of Malgrinnor faction', '', 0, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'Free Trader Arislo snaps the fingers, satisfied.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505776, 2, 0, 0, 'Destroy the Bloodwings', '[1,Kill five Bloodwing perch guards in the Ruins of Illsalin.][2,Kill five winged watchers in the Ruins of Illsalin.]', 'Experience, coin and a potion', '40607', 8000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'You have been given a Potion of Healing.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505777, 2, 0, 0, 'Dredged Drachnids', '[1,Collect ten Drachnid Spirits from the dredged drachnid zombies of the Ruins of Illsalin.][2,Combine them into a Skull of Spirits and give it to Hourglass in the Undershore.]', 'Experience, coin and a potion', '40607', 8000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'You have been given a Potion of Healing.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505778, 2, 0, 0, 'A Traitor\'s Fate', '[1,Collect ten Deep Orc Heads from the Deep Orc conscripts of the Hive.][2,Combine them into a Totem of Impaled Orc Heads with Arad\'s Spear and give it to Slave Trader Arad.]', 'Experience, coin and a potion', '40607', 9000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'You have been given a Potion of Healing.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505779, 2, 0, 0, 'Veruzan', '[1,Slay Veruzan in Stoneroot Falls.][2,Recover four of Veruzan\'s Paws.][3,Give the paws to Slave Trader Arad in the Undershore.]', 'Experience, coin and a potion', '40607', 9000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'You have been given a Potion of Healing.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505780, 2, 0, 0, 'The Coral Bogs', '[1,Collect four Brittle Nargilor Cores from the coral of Stoneroot Falls.][2,Collect four Glowing Nargilor Cores from the coral of Stoneroot Falls.][3,Deliver the Brittle Nargilor Cores to Slave Trader Arad.][4,Deliver the Glowing Nargilor Cores to Slave Trader Arad.]', 'Experience, coin and a potion', '40607', 9000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'You have been given a Potion of Healing.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505781, 2, 0, 0, 'Harvest of the Deep', '[1,Collect five Living Nargil Corals in the Ruins of Illsalin.][2,Collect five Splintered Nargilore Shards in the Ruins of Illsalin.][3,Deliver the Living Nargil Corals to Slave Trader Bologore.][4,Deliver the Splintered Nargilore Shards to Slave Trader Bologore.]', 'Experience, coin and a potion', '40607', 9000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'You have been given a Potion of Healing.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505782, 2, 0, 0, 'Cleaning the Canals', '[1,Kill five cave fishers in the Undershore.][2,Kill ten moccasins in the Undershore.][3,Kill five witherans in the Undershore.][4,Report back to Slave Trader Zillvinshin.]', 'Experience, coin and a potion', '40607', 8000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'You have been given a Potion of Healing.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505783, 2, 0, 0, 'The Walls of Illsalin', '[1,Collect ten Withered Shiliskin Tentacles from the Illsalin shiliskin in the Undershore.][2,Combine them into a Tentacle-Laden Trophy Belt with Zillvinshin\'s Trophy Belt and give it to Slave Trader Zillvinshin.]', 'Experience, coin and a potion', '40607', 8000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 0, 1055, 'You have been given a Potion of Healing.', 0, 0, 0, 0, 0, -1, 25, 1),
	(505784, 2, 0, 0, 'Shilgrave Vengeance', '[1,Loot twelve Malgrin Legion Shields from the Malgrin Legion of the Undershore.][2,Deliver the shields to Zahn.]', 'Experience, coin and a potion', '40607', 9000, 0, 0, 0, 0, 55, 0, 0, 0, 0, 1, 1055, 'You have been given a Potion of Healing.', 0, 0, 0, 0, 0, -1, 25, 1);

-- ---------------------------------------------------------------------------
-- 2. Task activities
--    activitytype: 1 Deliver, 2 Kill, 3 Loot, 4 SpeakWith
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	-- 505772 Arislo's Armor
	(505772, 0, -1, 1, 1, '', 0, 2, '', '362076', '88024', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505772, 1, -1, 1, 1, '', 0, 2, '', '362076', '88025', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505772, 2, -1, 1, 1, '', 0, 2, '', '362076', '88026', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505773 Arislo's Weapons
	(505773, 0, -1, 1, 1, '', 0, 2, '', '362076', '88024', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505773, 1, -1, 1, 1, '', 0, 2, '', '362076', '88027', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505774 Arislo's Food
	(505774, 0, -1, 1, 1, '', 0, 2, '', '362076', '88028', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505774, 1, -1, 1, 1, '', 0, 2, '', '362076', '88029', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505774, 2, -1, 1, 1, '', 0, 2, '', '362076', '88030', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505775 Handy Work
	(505775, 0, -1, 1, 1, '', 0, 2, '', '362076', '88031', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505776 Destroy the Bloodwings
	(505776, 0, -1, 1, 2, 'a_Bloodwing_perch_guard', 0, 5, '', '347005', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	(505776, 1, -1, 2, 2, 'a_winged_watcher', 0, 5, '', '347041', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	-- 505777 Dredged Drachnids
	(505777, 0, -1, 1, 3, 'a_dredged_drachnid_zombie', 0, 10, '', '347031', '85563', 'Drachnid Spirit', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	(505777, 1, -1, 2, 1, '', 0, 1, '', '362115', '85564', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505778 A Traitor's Fate
	(505778, 0, -1, 1, 3, 'a_Deep_Orc_conscript', 0, 10, '', '354098|354135|354189|354195|354263|354314', '85548', 'Deep Orc Head', 0, 0, 0, 0, 0, 0, 0, '-1', '', '354', -1, 0, 0),
	(505778, 1, -1, 2, 1, '', 0, 1, '', '362029', '85549', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505779 Veruzan
	(505779, 0, -1, 1, 2, 'Veruzan', 0, 1, '', '358999', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505779, 1, -1, 2, 3, 'Veruzan', 0, 4, '', '358999', '85565', 'Veruzan\'s Paw', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505779, 2, -1, 3, 1, '', 0, 4, '', '362029', '85565', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505780 The Coral Bogs
	(505780, 0, -1, 1, 3, 'a coral', 0, 4, '', '358033|358036|358039|358043|358046|358049|358050|358052|358053|358055', '85560', 'Brittle Nargilor Core', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505780, 1, -1, 2, 3, 'a coral', 0, 4, '', '358033|358036|358039|358043|358046|358049|358050|358052|358053|358055', '85561', 'Glowing Nargilor Core', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(505780, 2, -1, 3, 1, '', 0, 4, '', '362029', '85560', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505780, 3, -1, 4, 1, '', 0, 4, '', '362029', '85561', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505781 Harvest of the Deep
	(505781, 0, -1, 1, 3, 'a_colony_of_nargilor', 0, 5, '', '347003', '86019', 'Living Nargil Coral', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	(505781, 1, -1, 2, 3, 'a_colony_of_nargilor', 0, 5, '', '347003', '86028', 'Splintered Nargilore Shard', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	(505781, 2, -1, 3, 1, '', 0, 5, '', '362026', '86019', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	(505781, 3, -1, 4, 1, '', 0, 5, '', '362026', '86028', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505782 Cleaning the Canals
	(505782, 0, -1, 1, 2, 'a_cave_fisher', 0, 5, '', '362065|362272', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '362', -1, 0, 0),
	(505782, 1, -1, 2, 2, 'a moccasin', 0, 10, '', '362054|362063|362224|362249|362266', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '362', -1, 0, 0),
	(505782, 2, -1, 3, 2, 'a witheran', 0, 5, '', '362048|362057|362217|362221', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '362', -1, 0, 0),
	(505782, 3, -1, 4, 4, '', 0, 1, '', '362027', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '362', -1, 0, 0),
	-- 505783 The Walls of Illsalin
	(505783, 0, -1, 1, 3, 'an Illsalin shiliskin', 0, 10, '', '362006|362030|362041|362043|362045|362051|362058|362271|362278|362285|362288|362290|362297|362298|362299|362300', '85551', 'Withered Shiliskin Tentacle', 0, 0, 0, 0, 0, 0, 0, '-1', '', '362', -1, 0, 0),
	(505783, 1, -1, 2, 1, '', 0, 1, '', '362027', '85553', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0),
	-- 505784 Shilgrave Vengeance
	(505784, 0, -1, 1, 3, 'a Malgrin Legionnaire', 0, 12, '', '362053|362087|362114|362169|362204|362208|362211|362212|362274|362275', '85536', 'Malgrin Legion Shield', 0, 0, 0, 0, 0, 0, 0, '-1', '', '362', -1, 0, 0),
	(505784, 1, -1, 2, 1, '', 0, 12, '', '362117', '85536', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '-1', -1, 0, 0);

-- ---------------------------------------------------------------------------
-- 3. Quest-container combines (DELETE+INSERT keeps this idempotent)
-- ---------------------------------------------------------------------------

DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` IN (938052, 938053, 938054);
DELETE FROM `tradeskill_recipe` WHERE `id` IN (938052, 938053, 938054);

INSERT INTO `tradeskill_recipe`
	(`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,`quest`,`enabled`,`min_expansion`,`max_expansion`)
VALUES
	(938052, 'Totem of Impaled Orc Heads', 0, 0, 0, 1, 0, 1, 1, -1, -1),
	(938053, 'Tentacle-Laden Trophy Belt', 0, 0, 0, 1, 0, 1, 1, -1, -1),
	(938054, 'Skull of Spirits', 0, 0, 0, 1, 0, 1, 1, -1, -1);

INSERT INTO `tradeskill_recipe_entries`
	(`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
	-- 938052 Arad's Spear (85550): 10x 85548 -> 85549
	(938052, 85550, 0, 0, 0, 0, 1),
	(938052, 85548, 0, 0, 10, 0, 0),
	(938052, 85549, 1, 0, 0, 0, 0),
	-- 938053 Zillvinshin's Trophy Belt (85552): 10x 85551 -> 85553
	(938053, 85552, 0, 0, 0, 0, 1),
	(938053, 85551, 0, 0, 10, 0, 0),
	(938053, 85553, 1, 0, 0, 0, 0),
	-- 938054 Hourglass' Voodoo Skull (85562): 10x 85563 -> 85564
	(938054, 85562, 0, 0, 0, 0, 1),
	(938054, 85563, 0, 0, 10, 0, 0),
	(938054, 85564, 1, 0, 0, 0, 0);

-- ---------------------------------------------------------------------------
-- 4. Loot (lootdrops 910226-910228)
-- ---------------------------------------------------------------------------

DELETE FROM `loottable_entries` WHERE `lootdrop_id` BETWEEN 910226 AND 910231;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 910226 AND 910231;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 910226 AND 910231;
DELETE FROM `loottable_entries` WHERE `loottable_id` = 920900;
DELETE FROM `loottable` WHERE `id` = 920900;

-- Veruzan yields all four paws in a single kill: four independent guaranteed
-- lootdrops (a lootdrop_entries row is unique per (lootdrop,item), so duplicates
-- in one drop cannot be used).
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES
	(910226, 'dod_mission_drachnid_spirit', -1, -1),
	(910227, 'dod_mission_splintered_nargilore_shard', -1, -1),
	(910228, 'dod_mission_veruzans_paw_1', -1, -1),
	(910229, 'dod_mission_veruzans_paw_2', -1, -1),
	(910230, 'dod_mission_veruzans_paw_3', -1, -1),
	(910231, 'dod_mission_veruzans_paw_4', -1, -1);

INSERT INTO `lootdrop_entries`
	(`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
	(910226, 85563, 1, 0, 35, 0, 0, 0, 1, 0, 0, -1, -1), -- Drachnid Spirit
	(910227, 86028, 1, 0, 100, 0, 0, 0, 1, 0, 0, -1, -1), -- Splintered Nargilore Shard
	(910228, 85565, 1, 0, 100, 0, 0, 0, 1, 0, 0, -1, -1), -- Veruzan's Paw
	(910229, 85565, 1, 0, 100, 0, 0, 0, 1, 0, 0, -1, -1),
	(910230, 85565, 1, 0, 100, 0, 0, 0, 1, 0, 0, -1, -1),
	(910231, 85565, 1, 0, 100, 0, 0, 0, 1, 0, 0, -1, -1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`) VALUES
	(920900, 'dod_mission_veruzan', 0, 0, 0, 0, -1, -1);

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
	(91382, 910226, 1, 0, 0, 100), -- a_dredged_drachnid_zombie (illsalin)
	(91368, 910227, 1, 0, 0, 100), -- a_colony_of_nargilor (illsalin)
	(920900, 910228, 1, 0, 0, 100), -- Veruzan (westkorlach)
	(920900, 910229, 1, 0, 0, 100),
	(920900, 910230, 1, 0, 0, 100),
	(920900, 910231, 1, 0, 0, 100);

-- ---------------------------------------------------------------------------
-- 5. Veruzan (npc 358999, spawn in westkorlach near the Xillsfar camp)
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO `npc_types`
	(`id`,`name`,`lastname`,`level`,`race`,`class`,`bodytype`,`gender`,`size`,`hp`,`loottable_id`,`npc_faction_id`,`mindmg`,`maxdmg`,`attack_delay`,`prim_melee_type`,`see_invis`,`trackable`,`findable`)
VALUES
	(358999, 'Veruzan', 'the Depths-Spawn', 63, 467, 1, 3, 2, 7, 42000, 920900, 0, 180, 720, 30, 0, 0, 1, 0);

DELETE FROM `spawnentry` WHERE `spawngroupID` = 9000150;
DELETE FROM `spawn2` WHERE `spawngroupID` = 9000150;
DELETE FROM `spawngroup` WHERE `id` = 9000150;

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`) VALUES
	(9000150, 'Veruzan', 0, 0);

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`,`min_expansion`,`max_expansion`) VALUES
	(9000150, 358999, 100, -1, -1);

INSERT INTO `spawn2`
	(`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`)
VALUES
	(9000150, 'westkorlach', 0, -1931.875, 473.000, 522.750, 0.000, 640, 0, 0, 0, 0, 0, -1, -1);
