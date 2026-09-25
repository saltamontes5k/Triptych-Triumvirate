-- ============================================================================
-- TBS Solteris raid layer (zone 421): island 2-4 events, raid loot, SoF flags
-- Hand-written (2026-09-21), companion to 20260920_tbs_solteris_access.sql.
--
-- PEQ already ships island 1 statics (sisters 421001-3, Lochmaul 421005,
-- Aprosis 421006, trash 421008-421021 with Phosphite loots). This file:
--   1. Trues up the PEQ stub HPs/combat stats on the island-1 event NPCs
--   2. Adds island 2-4 event NPCs (421022-421098; block verified empty)
--   3. Adds event chest NPCs (clone of Anguish Ornate_Chest 317112) with
--      lootdrops in the free 6210000-6210099 range
--   4. Adds island-4 (throne approach) trash that drops Shard of Eternal
--      Light (53473, used in the Two Gods event)
--
-- Bosses are NOT statically spawned: Release-NMS-Quests/solteris/421000.lua
-- (the zone controller) spawns each island's event only when the expedition
-- lacks that event's 4d12h lockout, and event scripts summon all adds.
-- Scripted bosses get loottable_id = 0: all raid loot flows through chests,
-- which are loot-event protected like Anguish (zone_status.lua pattern).
--
-- Encounter coordinates come from the Brewall community map POIs negated
-- (spawn x/y = -POI x/y; verified against PEQ's existing island-1 spawns).
-- Throne-room placements are approximate: fine-tune in game with #npcspawn.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Island-1 event NPCs: replace PEQ stub stats with raid-tier values
--    (calibration: Ture 317003 = 2.5M hp @ 80; Mayong 351118 = 8.07M @ 85)
-- ---------------------------------------------------------------------------
UPDATE `npc_types` SET
    `hp` = 1200000, `AC` = 600, `ATK` = 300, `Accuracy` = 350, `findable` = 1
  WHERE `id` IN (421001,421002,421003);               -- Althea / Brenda / Christine

UPDATE `npc_types` SET
    `hp` = 2200000, `AC` = 580, `ATK` = 350, `Accuracy` = 400, `findable` = 1
  WHERE `id` = 421005;                                -- #Ur-Floxiz_Lochmaul (hits ~8k, flurries: script)

UPDATE `npc_types` SET
    `hp` = 2600000, `AC` = 600, `ATK` = 380, `Accuracy` = 420, `findable` = 1
  WHERE `id` = 421006;                                -- #Aprosis_the_Fourth_Confidant (hits ~9k)

-- ---------------------------------------------------------------------------
-- 2. New event NPCs. Temp-table clones keep npc_types schema-proof.
-- ---------------------------------------------------------------------------

-- 421022 A_Sun_Sworn_Knight: island-4 trash pack leader (drops Shard 53473)
DELETE FROM `spawn2` WHERE `zone` = 'solteris' AND `spawngroupID` IN (SELECT spawngroupID FROM spawnentry WHERE npcID = 421022);
DELETE FROM `spawnentry` WHERE `npcID` = 421022;
DELETE FROM `npc_types` WHERE `id` = 421022;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421021;
UPDATE tmp_solteris_npc SET id = 421022, name = 'A_Sun_Sworn_Knight', level = 80, maxlevel = 80,
    hp = 700000, AC = 550, ATK = 340, Accuracy = 400, loottable_id = 6210021, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421030-421038: Guardians of the Nine Primes (Mistresses event, scripted summons)
DELETE FROM `npc_types` WHERE `id` BETWEEN 421030 AND 421038;
-- Prime 1/2: drachnid
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421008;
UPDATE tmp_solteris_npc SET id = 421030, name = 'Guardian_of_the_First_Prime',  level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421031, name = 'Guardian_of_the_Second_Prime';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
-- Prime 3/4: werewolf (shadowmane)
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421014;
UPDATE tmp_solteris_npc SET id = 421032, name = 'Guardian_of_the_Third_Prime',  level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421033, name = 'Guardian_of_the_Fourth_Prime';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
-- Prime 5/6: vampire (sister model)
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421001;
UPDATE tmp_solteris_npc SET id = 421034, name = 'Guardian_of_the_Fifth_Prime',  level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421035, name = 'Guardian_of_the_Sixth_Prime';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
-- Prime 7/9: gargoyle, Prime 8: wolf
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421012;
UPDATE tmp_solteris_npc SET id = 421036, name = 'Guardian_of_the_Seventh_Prime', level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421038, name = 'Guardian_of_the_Ninth_Prime';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421014;
UPDATE tmp_solteris_npc SET id = 421037, name = 'Guardian_of_the_Eighth_Prime', level = 83, maxlevel = 83, hp = 850000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421040-421043: Balreth + golem split tiers + fail adds (construct model: Ture race 412)
DELETE FROM `npc_types` WHERE `id` BETWEEN 421040 AND 421043;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 317003;
UPDATE tmp_solteris_npc SET id = 421040, name = '#Rear_Guard_Captain_Balreth', level = 84, maxlevel = 84,
    hp = 1800000, AC = 590, ATK = 320, Accuracy = 380, loottable_id = 0, npc_faction_id = 1354, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421041, name = 'a_gargantuan_golem',     hp = 900000;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421042, name = 'a_massive_golem',        hp = 450000;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421043, name = 'an_uncontrollable_golem', hp = 500000, ATK = 400, Accuracy = 420;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421045-421049: Astire + the four weapon Guardians
DELETE FROM `npc_types` WHERE `id` BETWEEN 421045 AND 421049;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421001;
UPDATE tmp_solteris_npc SET id = 421045, name = '#Astire_the_Lunar_Eclipse', level = 85, maxlevel = 85,
    hp = 3200000, AC = 620, ATK = 420, Accuracy = 450, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421008;
UPDATE tmp_solteris_npc SET id = 421046, name = 'Guardian_of_the_Spear', level = 83, maxlevel = 83, hp = 900000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421012;
UPDATE tmp_solteris_npc SET id = 421047, name = 'Guardian_of_the_Staff', level = 83, maxlevel = 83, hp = 900000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421014;
UPDATE tmp_solteris_npc SET id = 421048, name = 'Guardian_of_the_Sword', level = 83, maxlevel = 83, hp = 900000, AC = 550, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421049, name = 'Guardian_of_the_Fist';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421055-421057: Irrissa the Seer + trueborn summoners + portal attendants
DELETE FROM `npc_types` WHERE `id` BETWEEN 421055 AND 421057;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421008;
UPDATE tmp_solteris_npc SET id = 421055, name = '#Irrissa_the_Seer', level = 85, maxlevel = 85,
    hp = 3500000, AC = 620, ATK = 420, Accuracy = 450, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421018;
UPDATE tmp_solteris_npc SET id = 421056, name = 'a_trueborn_summoner', level = 80, maxlevel = 80, hp = 350000, AC = 500, ATK = 260, Accuracy = 340, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421020;
UPDATE tmp_solteris_npc SET id = 421057, name = 'a_portal_attendant', level = 76, maxlevel = 76, hp = 120000, AC = 450, ATK = 220, Accuracy = 300, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421065-421073: Commodus + the eight Aspects
DELETE FROM `npc_types` WHERE `id` BETWEEN 421065 AND 421073;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 317003;
UPDATE tmp_solteris_npc SET id = 421065, name = '#Commodus_Solar_Construct', level = 85, maxlevel = 85,
    hp = 3800000, AC = 620, ATK = 420, Accuracy = 450, loottable_id = 0, npc_faction_id = 1354, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421017;
UPDATE tmp_solteris_npc SET id = 421066, name = 'Aspect_of_Temperance',     level = 84, maxlevel = 84, hp = 900000, AC = 560, ATK = 300, Accuracy = 380, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421067, name = 'Aspect_of_Justice';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421068, name = 'Aspect_of_Wisdom';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421069, name = 'Aspect_of_Fortitude';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421070, name = 'Aspect_of_Courage';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421071, name = 'Aspect_of_Devotion';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421072, name = 'Aspect_of_Ambition';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421073, name = 'Aspect_of_Resourcefulness';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421080-421084: event adds
DELETE FROM `npc_types` WHERE `id` BETWEEN 421080 AND 421084;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421012;
UPDATE tmp_solteris_npc SET id = 421080, name = 'Liquid_Magma',            level = 80, maxlevel = 80, hp = 100000, AC = 450, ATK = 240, Accuracy = 320, loottable_id = 0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421081, name = 'Convergence_of_the_Sun',  hp = 50000;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421082, name = 'a_living_flame',          hp = 60000;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421084, name = 'an_unholy_dervish',       hp = 120000, ATK = 280;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 421014;
UPDATE tmp_solteris_npc SET id = 421083, name = 'a_shade_bat',             level = 78, maxlevel = 78, hp = 30000, AC = 400, ATK = 200, Accuracy = 300, loottable_id = 0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421090-421096: event loot chests (clone Anguish Ornate_Chest)
DELETE FROM `npc_types` WHERE `id` BETWEEN 421090 AND 421096;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 317112;
UPDATE tmp_solteris_npc SET id = 421090, name = 'Ornate_Chest', loottable_id = 6210011, npc_faction_id = 0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421091, loottable_id = 6210012; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421092, loottable_id = 6210013; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421093, loottable_id = 6210014; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421094, loottable_id = 6210015; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421095, loottable_id = 6210016; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
UPDATE tmp_solteris_npc SET id = 421096, loottable_id = 6210017; INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- 421097/421098: The Two Gods. Dedicated event clones so the PEQ SoF statics
-- (212025/351118) are untouched. Names keep underscores: GetCleanName yields
-- 'Solusek Ro' / 'Mayong Mistmoore', matching the SoF progression subflags.
DELETE FROM `npc_types` WHERE `id` IN (421097,421098);
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 212025;
UPDATE tmp_solteris_npc SET id = 421097, level = 85, maxlevel = 85, hp = 6500000,
    AC = 600, ATK = 450, Accuracy = 480, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;
CREATE TEMPORARY TABLE tmp_solteris_npc AS SELECT * FROM npc_types WHERE id = 351118;
UPDATE tmp_solteris_npc SET id = 421098, level = 85, maxlevel = 85, hp = 7500000,
    AC = 600, ATK = 450, Accuracy = 400, loottable_id = 0, findable = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_solteris_npc;
DROP TEMPORARY TABLE tmp_solteris_npc;

-- ---------------------------------------------------------------------------
-- 3. Raid loot (free 6210000-6210099 block, verified empty)
--    Pool items: 30% each; chest loottable mindrop 2 keeps the guide's
--    "two of the following" while a big raid still can't vacuum the pool.
-- ---------------------------------------------------------------------------
DELETE FROM `loottable_entries` WHERE `loottable_id` BETWEEN 6210011 AND 6210021;
DELETE FROM `lootdrop_entries`  WHERE `lootdrop_id`  BETWEEN 6210001 AND 6210021;
DELETE FROM `lootdrop`          WHERE `id`           BETWEEN 6210001 AND 6210021;
DELETE FROM `loottable`         WHERE `id`           BETWEEN 6210011 AND 6210021;

INSERT INTO `lootdrop` (`id`,`name`) VALUES
  (6210001,'Solteris_Mistresses_Chest'),
  (6210002,'Solteris_Aprosis_Chest'),
  (6210003,'Solteris_Balreth_Chest'),
  (6210004,'Solteris_Astire_Chest'),
  (6210005,'Solteris_Irissa_Chest'),
  (6210006,'Solteris_Commodus_Chest'),
  (6210007,'Solteris_TwoGods_Pool_A'),
  (6210008,'Solteris_TwoGods_Pool_B'),
  (6210021,'Solteris_Throne_Trash');

INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`chance`) VALUES
  -- Mayong's Mistresses (unlocks Wrists, 200 Phosphene)
  (6210001,80612,1,30),(6210001,80613,1,30),(6210001,80614,1,30),(6210001,80615,1,30),
  (6210001,80616,1,30),(6210001,80617,1,30),(6210001,80618,1,30),(6210001,80619,1,30),
  (6210001,80620,1,30),(6210001,80621,1,30),(6210001,79912,200,100),
  -- Aprosis (Gloves, 200 Phosphene, 2x Corrupted drop, sunshard chance)
  (6210002,80622,1,30),(6210002,80623,1,30),(6210002,80624,1,30),(6210002,80625,1,30),
  (6210002,80626,1,30),(6210002,80627,1,30),(6210002,80628,1,30),(6210002,80629,1,30),
  (6210002,80630,1,30),(6210002,80631,1,30),(6210002,34017,2,100),
  (6210002,37416,1,25),(6210002,79912,200,100),
  -- Balreth (Feet, 400 Phosphene, sunshard chance)
  (6210003,80632,1,30),(6210003,80633,1,30),(6210003,80634,1,30),(6210003,80635,1,30),
  (6210003,80636,1,30),(6210003,80637,1,30),(6210003,80638,1,30),(6210003,80639,1,30),
  (6210003,80640,1,30),(6210003,80641,1,30),(6210003,37416,1,25),(6210003,79912,400,100),
  -- Astire (Heads, 400 Phosphene, 2x Impure drop, sunshard chance)
  (6210004,80642,1,30),(6210004,80643,1,30),(6210004,80644,1,30),(6210004,80645,1,30),
  (6210004,80646,1,30),(6210004,80647,1,30),(6210004,80648,1,30),(6210004,80649,1,30),
  (6210004,80650,1,30),(6210004,80651,1,30),(6210004,34018,2,100),
  (6210004,37416,1,25),(6210004,79912,400,100),
  -- Irrissa (Arms, 800 Phosphene, sunshard chance)
  (6210005,80652,1,30),(6210005,80653,1,30),(6210005,80654,1,30),(6210005,80655,1,30),
  (6210005,80656,1,30),(6210005,80657,1,30),(6210005,80658,1,30),(6210005,80659,1,30),
  (6210005,80660,1,30),(6210005,80661,1,30),(6210005,37416,1,25),(6210005,79912,800,100),
  -- Commodus (Legs, 800 Phosphene, 2x Purified drop, sunshard chance)
  (6210006,80662,1,30),(6210006,80663,1,30),(6210006,80664,1,30),(6210006,80665,1,30),
  (6210006,80666,1,30),(6210006,80667,1,30),(6210006,80668,1,30),(6210006,80669,1,30),
  (6210006,80670,1,30),(6210006,80671,1,30),(6210006,34019,2,100),
  (6210006,37416,1,25),(6210006,79912,800,100),
  -- Two Gods (Chests, 2000 Phosphene, 2x Pristine drop; one from each pool)
  (6210007,80672,1,20),(6210007,80673,1,20),(6210007,80674,1,20),(6210007,80675,1,20),
  (6210007,80676,1,20),(6210007,80677,1,20),(6210007,80678,1,20),(6210007,80679,1,20),
  (6210007,80680,1,20),(6210007,80681,1,20),
  (6210008,80682,1,20),(6210008,80683,1,20),(6210008,80684,1,20),(6210008,80685,1,20),
  (6210008,80686,1,20),(6210008,80687,1,20),(6210008,80688,1,20),(6210008,80689,1,20),
  (6210008,80690,1,20),(6210008,80691,1,20),
  (6210008,34020,2,100),(6210008,37416,1,50),(6210008,79912,2000,100),
  -- Throne-approach trash: Shard of Eternal Light (Two Gods event clicky)
  (6210021,53473,1,35),(6210021,79913,5,25);

INSERT INTO `loottable` (`id`,`name`) VALUES
  (6210011,'Solteris_Mistresses_Chest'),(6210012,'Solteris_Aprosis_Chest'),
  (6210013,'Solteris_Balreth_Chest'),(6210014,'Solteris_Astire_Chest'),
  (6210015,'Solteris_Irissa_Chest'),(6210016,'Solteris_Commodus_Chest'),
  (6210017,'Solteris_TwoGods_Chest'),(6210021,'Solteris_Throne_Trash');

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
  (6210011,6210001,1,0,2,100),
  (6210012,6210002,1,0,2,100),
  (6210013,6210003,1,0,2,100),
  (6210014,6210004,1,0,2,100),
  (6210015,6210005,1,0,2,100),
  (6210016,6210006,1,0,2,100),
  (6210017,6210007,1,1,1,100),   -- exactly one from Mayong's pool
  (6210017,6210008,1,1,1,100),   -- exactly one from Solusek's pool
  (6210021,6210021,1,0,0,100);

-- ---------------------------------------------------------------------------
-- 4. Island-4 throne-approach trash (three packs between the third island
--    port-in and the throne room). Trash drops Shard of Eternal Light.
--    Pack leader 421022 carries loottable 6210021.
--    NOTE: spawnentry's PK is (spawngroupID, npcID) - a pack may list any
--    NPC at most once, so each pack mixes three distinct escorts.
-- ---------------------------------------------------------------------------
DELETE FROM `spawn2` WHERE `zone` = 'solteris' AND `spawngroupID` IN
  (SELECT `spawngroupID` FROM `spawnentry` WHERE `npcID` = 421022);
DELETE FROM `spawnentry` WHERE `npcID` = 421022;
DELETE FROM `spawngroup` WHERE `name` LIKE 'solteris_throne_trash%';

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES
  ('solteris_throne_trash_1',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,421022,100),(@g,421020,100),(@g,421018,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES
  (@g,'solteris',0,-2300,5350,3914,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES
  ('solteris_throne_trash_2',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,421022,100),(@g,421019,100),(@g,421016,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES
  (@g,'solteris',0,-2400,5450,3914,0,640);

INSERT INTO `spawngroup` (`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES
  ('solteris_throne_trash_3',0,0,0,0,0,0,0,15000,0,100,0);
SET @g := LAST_INSERT_ID();
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (@g,421022,100),(@g,421014,100),(@g,421021,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES
  (@g,'solteris',0,-2450,5500,3914,0,640);
