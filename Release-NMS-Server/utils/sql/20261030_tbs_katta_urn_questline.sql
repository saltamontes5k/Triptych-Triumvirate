-- ============================================================================
-- 2026-10-31  TBS Katta Castrum: Tsaph Katta's Urn questline (v290)
--
-- Twin of ManifestEntry .version = 290 in
-- common/database/database_update_manifest_custom.cpp (keep in sync).
--
-- Wires the 22-task urn questline (Rasper's Realm TBS miscUrn): the prior
-- batch authored every prop (fragments 79956-79975, combine results
-- 79976-79979, handles 79954/79955, Pottery Sealant 79919, urn 79980,
-- Deep Stasis 11571, all 8 giver NPCs, nearly all target mobs) but none of
-- the glue. This adds:
--   - tasks 620112-620133 (type 2 solo, faction_reward 1170 +10 each, the
--     live faction-500 task series), each rewarding its pottery fragment
--   - 5 combine recipes (4 tier combines + final, container-matched, nofail)
--   - 15 quest items in the 9910018+ band (Treaty, 4 herbs, 4 library
--     books, waterlogged page, wing/mandible/sac/fang, kedge artifact)
--   - loot rows: herbs on the shissar tender/alchemist lootdrops, wing/
--     mandible on deathspore insects, sac/fang on zhisza snakes/apes,
--     kedge artifact on the kedge trio, Shissar Artifact on the silyssar
--     rubble piles (loottable 93437 was empty), cipher halves raised from
--     0.6-1.2% to 20%
--   - npc_types + spawns for Kraj Lucolupos (thalassius rare) and 7
--     a_pile_of_refuse (thalassius), each with its own lootdrop for the
--     waterlogged page
--   - 6 ground spawns: 4 katta library books + the two zhisza tomes
--   - giver scripts are separate files (kattacastrum/416003.pl etc.);
--     Head Attendant Haestus (416005) recharges the urn on hand-in.
--
-- Idempotency: applies once via the manifest check (task 620112 sentinel).
-- The INSERT blocks use reserved bands and duplicate-key on manual re-run.
--
-- Rollback: utils/sql/20261030_tbs_katta_urn_questline_rollback.sql
-- ============================================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- ---------------------------------------------------------------------------
-- A1. Quest items (NoDrop quest-safe clones of the Etching Transcript shape).
-- ---------------------------------------------------------------------------
DELETE FROM `items` WHERE `id` BETWEEN 9910018 AND 9910032;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910018, Name = 'The Treaty of Teleportation', lore = 'A water-stained treaty bearing the Combine seals', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910019, Name = 'Shissar Sage', lore = 'A pungent herb cultivated by the shissar gardeners', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910020, Name = 'Cauldron Bloom', lore = 'A flower that thrives only in the alchemists'' steaming beds', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910021, Name = 'Deep Mallow', lore = 'A pale herb grown far below the Castrum', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910022, Name = 'Silt Root', lore = 'A root caked in the rich silt of the garden terraces', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910023, Name = 'Tome of Tsaph''s Line', lore = 'A library volume on the lineage of Tsaph Katta', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910024, Name = 'Ledger of the Combine', lore = 'A supply ledger from the early days of the Castrum', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910025, Name = 'Shissar Warden Records', lore = 'Rotation rosters of the library''s shissar wardens', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910026, Name = 'Katta Foundry Notes', lore = 'An engineer''s notes on the Castrum foundries', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910027, Name = 'Waterlogged Page', lore = 'A sodden page recovered from the refuse of the deep', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910028, Name = 'Deathspore Wing', lore = 'A gossamer wing still faintly spore-dusted', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910029, Name = 'Chitin Mandible', lore = 'The grinding mandible of a deathspore insect', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910030, Name = 'Serpent Sac', lore = 'A venom sac taken from a Zhisza serpent', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910031, Name = 'Venom Fang', lore = 'A hollow fang dripping Zhisza venom', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;
CREATE TEMPORARY TABLE tmp_urn_item AS SELECT * FROM items WHERE id = 33959;
UPDATE tmp_urn_item SET id = 9910032, Name = 'Kedge Artifact', lore = 'A relic of the kedge civilization of Thalassius', loregroup = 0, NoDrop = 1;
INSERT IGNORE INTO items SELECT * FROM tmp_urn_item; DROP TEMPORARY TABLE tmp_urn_item;

-- ---------------------------------------------------------------------------
-- A2. New NPCs: Kraj Lucolupos (thalassius rare) and the thalassius
--     a_pile_of_refuse (cloned from local mobs, renamed).
-- ---------------------------------------------------------------------------
DELETE FROM `spawnentry` WHERE `npcID` IN (1520002001, 1520002002);
DELETE FROM `spawn2` WHERE `spawngroupID` IN (1900000126, 1900000127, 1900000128, 1900000129, 1900000130, 1900000131, 1900000132, 1900000133);
DELETE FROM `spawngroup` WHERE `id` IN (1900000126, 1900000127, 1900000128, 1900000129, 1900000130, 1900000131, 1900000132, 1900000133);
DELETE FROM `npc_types` WHERE `id` IN (1520002001, 1520002002);

CREATE TEMPORARY TABLE tmp_urn_npc AS SELECT * FROM npc_types WHERE id = 417003;
UPDATE tmp_urn_npc SET id = 1520002001, name = 'Kraj_Lucolupos', level = 76, hp = 9200, loottable_id = 0;
INSERT INTO npc_types SELECT * FROM tmp_urn_npc; DROP TEMPORARY TABLE tmp_urn_npc;
CREATE TEMPORARY TABLE tmp_urn_npc AS SELECT * FROM npc_types WHERE id = 420007;
UPDATE tmp_urn_npc SET id = 1520002002, name = 'a_pile_of_refuse', loottable_id = 1520009426;
INSERT INTO npc_types SELECT * FROM tmp_urn_npc; DROP TEMPORARY TABLE tmp_urn_npc;

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES
    (1900000126, 'urn_kraj_lucolupos', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000127, 'thal_refuse_1', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000128, 'thal_refuse_2', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000129, 'thal_refuse_3', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000130, 'thal_refuse_4', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000131, 'thal_refuse_5', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000132, 'thal_refuse_6', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000133, 'thal_refuse_7', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0);

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`) VALUES
    (1900000126, 1520002001, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000127, 1520002002, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000128, 1520002002, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000129, 1520002002, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000130, 1520002002, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000131, 1520002002, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000132, 1520002002, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000133, 1520002002, 100, 1, 0, 0, -1, -1, NULL, NULL);

INSERT INTO `spawn2` (`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES
    (1520028426, 1900000126, 'thalassius', 0, -350.000, 150.000, -185.000, 511, 1200),
    (1520028427, 1900000127, 'thalassius', 0, -460.000, 120.000, -180.000, 511, 640),
    (1520028428, 1900000128, 'thalassius', 0, -250.000, -50.000, -190.000, 511, 640),
    (1520028429, 1900000129, 'thalassius', 0, 0.000, 0.000, -194.000, 511, 640),
    (1520028430, 1900000130, 'thalassius', 0, 200.000, 100.000, -186.000, 511, 640),
    (1520028431, 1900000131, 'thalassius', 0, 450.000, -70.000, -194.000, 511, 640),
    (1520028432, 1900000132, 'thalassius', 0, -100.000, 220.000, -188.000, 511, 640),
    (1520028433, 1900000133, 'thalassius', 0, 320.000, 210.000, -185.000, 511, 640);

-- ---------------------------------------------------------------------------
-- A3. Loot: herbs on the tender/alchemist lootdrops, wing/mandible on the
--     deathspore insects, sac/fang on zhisza snakes and gorillas, kedge
--     artifact on the kedge trio, Shissar Artifact on the rubble piles
--     (loottable 93437 was empty), and a page lootdrop for the refuse.
-- ---------------------------------------------------------------------------
INSERT INTO `lootdrop` (`id`,`name`) VALUES
    (1520009425, 'urn_rubble_artifact'),
    (1520009426, 'urn_refuse_page');

INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`) VALUES
    (1520009425, 33893, 1, 0, 55, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (1520009426, 9910027, 1, 0, 60, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL);

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
    (93437, 1520009425, 1, 1, 0, 100);

INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`) VALUES
    (112096, 9910019, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112096, 9910020, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112096, 9910021, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112096, 9910022, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112097, 9910019, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112097, 9910020, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112097, 9910021, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112097, 9910022, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112102, 9910019, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112102, 9910020, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112102, 9910021, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112102, 9910022, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112103, 9910019, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112103, 9910020, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112103, 9910021, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112103, 9910022, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112285, 9910028, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112285, 9910029, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112286, 9910028, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112286, 9910029, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112313, 9910030, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112313, 9910031, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112314, 9910030, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112314, 9910031, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (6200001, 9910030, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (6200001, 9910031, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112287, 9910030, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112287, 9910031, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112288, 9910030, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112288, 9910031, 1, 0, 30, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112178, 9910032, 1, 0, 35, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112179, 9910032, 1, 0, 35, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (112180, 9910032, 1, 0, 35, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL);

-- The Zhisza cipher halves dropped at 0.6-1.2%; the urn task needs both.
UPDATE `lootdrop_entries` SET `chance` = 20 WHERE `item_id` IN (33888, 33889);

-- ---------------------------------------------------------------------------
-- A4. Ground spawns: 4 katta library books + the two zhisza tomes.
-- ---------------------------------------------------------------------------
INSERT INTO `ground_spawns` (`zoneid`,`version`,`max_x`,`max_y`,`max_z`,`min_x`,`min_y`,`heading`,`name`,`item`,`max_allowed`,`comment`,`respawn_timer`,`fix_z`,`min_expansion`,`max_expansion`) VALUES
    (416, 0, -2790.000, 3130.000, -548.375, -2790.000, 3130.000, 0, 'urn_book_kat1', 9910023, 1, 'Tsaph Katta urn: library volume', 900, 1, -1, -1),
    (416, 0, -2850.000, 3150.000, -548.375, -2850.000, 3150.000, 0, 'urn_book_kat2', 9910024, 1, 'Tsaph Katta urn: library volume', 900, 1, -1, -1),
    (416, 0, -2900.000, 3180.000, -548.375, -2900.000, 3180.000, 0, 'urn_book_kat3', 9910025, 1, 'Tsaph Katta urn: library volume', 900, 1, -1, -1),
    (416, 0, -2760.000, 3170.000, -548.375, -2760.000, 3170.000, 0, 'urn_book_kat4', 9910026, 1, 'Tsaph Katta urn: library volume', 900, 1, -1, -1),
    (419, 0, -18.000, 1076.000, 360.875, -18.000, 1076.000, 0, 'urn_book_zhi1', 9910018, 1, 'Tsaph Katta urn: temple tome', 900, 1, -1, -1),
    (419, 0, 68.500, 1172.500, 432.500, 68.500, 1172.500, 0, 'urn_book_zhi2', 33886, 1, 'Tsaph Katta urn: temple tome', 900, 1, -1, -1);

-- ---------------------------------------------------------------------------
-- A5. The 22 urn tasks (620112-620133). Each rewards its pottery fragment
--     and +10 Combine Empire Merchants (the live faction-500 series).
-- ---------------------------------------------------------------------------
DELETE FROM `task_activities` WHERE `taskid` BETWEEN 620112 AND 620133;
DELETE FROM `tasks` WHERE `id` BETWEEN 620112 AND 620133;

INSERT INTO `tasks` (id,type,duration,duration_code,title,
description,reward_text,reward_id_list,cash_reward,exp_reward,
reward_method,reward_points,reward_point_type,min_level,max_level,
level_spread,min_players,max_players,repeatable,faction_reward,
completion_emote,replay_timer_group,replay_timer_seconds,
request_timer_group,request_timer_seconds,dz_template_id,
lock_activity_id,faction_amount,enabled) VALUES
(620112,2,0,0,'Herb Retrieval','Alchemist Hesia needs four rare herbs from the shissar gardeners of the Castrum.','Experience','79956',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620113,2,0,0,'The Serpent Slayer','Guard Captain Parvus wants the shissar threat culled. Kill 20 shissar.','Experience','79958',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620114,2,0,0,'Beheading the Snake','Take the head of Commander Zzarishazum for Guard Captain Parvus.','Experience','79957',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620115,2,0,0,'Renegade Servants','Arcanist Thalian wants the renegade servants rounded up: darkmuds, elementals of the deep, and fire whisperers.','Experience','79959',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620116,2,0,0,'Storms of Magic','Collect 10 Sparkling Coral Dust for Arcanist Thalian''s next project.','Experience','79960',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620117,2,0,0,'Reacquiring Control','Sorcerer Xycl needs the surface of Thalassius brought back under control.','Experience','79961',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620118,2,0,0,'The Incursion','Recover 9 kedge artifacts and thin the kedge incursion for Sorcerer Xycl.','Experience','79962',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620119,2,0,0,'Inconsequential Restoration','Sift the refuse by the drowned halls, salvage what pages remain, and cull the zone for Sorcerer Xycl.','Experience','79963',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620120,2,0,0,'Exploring the Chambers','Map the sunken chambers of Thalassius and cull the kedge experiments within.','Experience','79964',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620121,2,0,0,'Cavernous Reconnaissance','Scout the caverns of Thalassius and put down the brute Kraj Lucolupos.','Experience','79965',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620122,2,0,0,'Adapting to the Environment','Archarcanist Pintanus studies Zhisza''s insects: cull them and bring back wings and mandibles.','Experience','79966',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620123,2,0,0,'Adapting to the Environment II','Pintanus'' studies continue: cull Zhisza''s serpents and apes and bring back sacs and fangs.','Experience','79967',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620124,2,0,0,'Retrieving the Lost Knowledge','Chief Librarian Lars wants the lost tomes of Zhisza recovered: the Treaty and the History, plus the scattered Combine tomes.','Experience','79968',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620125,2,0,0,'Zhisza Cypher','Recover both halves of the Zhisza Cypher for Chief Librarian Lars.','Experience','79969',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620126,2,0,0,'Snakes on the Plain','Put down the great serpents of Zhisza: Copperfang, King Brownscale, and Coralitus.','Experience','79970',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620127,2,0,0,'Seeking Revenge','Vizier Zio calls for the heads of the traitors: Morduz, Ail`zhin, and Tizlrim.','Experience','79971',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620128,2,0,0,'Remnants of a Lost Civilization','Break open the rubble piles of Silyssar for Shissar Artifacts.','Experience','79972',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620129,2,0,0,'Remnants of a Lost Civilization II','Cull the brackwater elementals and goos and gather Artifact Shards for Pintanus.','Experience','79973',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620130,2,0,0,'Death Sentence','Deliver Vizier Zio''s vial of thick green fluid to the loyalist agents hiding in Silyssar.','Experience','79974',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620131,2,0,0,'Eye in the Sky','Clear the trash around the three pyramid portals of Silyssar for Pintanus.','Experience','79975',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620132,2,0,0,'Library Heist','Spiral Arcanist Variszh wants four volumes from the Castrum library. He cannot enter it himself.','Experience','79954',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1),
(620133,2,0,0,'Battling the Shissar','Parvus wants proof the guard is ready: templers, firetongues, shadowslithers, revenants, and arbiters.','Experience','79955',0,400000,0,0,0,0,0,0,0,0,0,1170,'',0,0,0,0,0,-1,10,1);

INSERT INTO `task_activities` (taskid,activityid,req_activity_id,
step,activitytype,target_name,goalmethod,goalcount,
description_override,npc_match_list,item_id_list,item_list,
dz_switch_id,min_x,min_y,min_z,max_x,max_y,max_z,skill_list,
spell_list,zones,zone_version,optional,list_group) VALUES
-- 620112 Herb Retrieval
(620112,0,-1,1,3,'rare herb',1,4,'Retrieve 4 rare herbs from the shissar gardeners','','9910019,9910020,9910021,9910022','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620112,1,-1,2,4,'Alchemist Hesia',416003,1,'Bring the herbs to Alchemist Hesia','416003','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620113 The Serpent Slayer
(620113,0,-1,1,2,'shissar',1,20,'Kill 20 shissar of the Castrum','416074,416082,416090,416098,416099,416101,416104,416105,416107,416109,416080,416118,416122,416089,416095,416111,416155,416160,416162,416168,416170,416171','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620113,1,-1,2,4,'Guard Captain Parvus',416035,1,'Report back to Guard Captain Parvus','416035','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620114 Beheading the Snake
(620114,0,-1,1,2,'Commander Zzarishazum',1,1,'Take the head of Commander Zzarishazum','416167','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620114,1,-1,2,4,'Guard Captain Parvus',416035,1,'Bring the head to Guard Captain Parvus','416035','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620115 Renegade Servants
(620115,0,-1,1,2,'darkmuds',1,5,'Kill 5 darkmuds','416045,416051,416075,416139,416151,416152','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620115,1,-1,2,2,'elementals of the deep',1,5,'Kill 5 elementals of the deep','416052,416087,416150,416056,416081,416084','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620115,2,-1,3,2,'fire whisperers',1,5,'Kill 5 fire whisperers','416088,416157,416159','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620115,3,-1,4,4,'Arcanist Thalian',416025,1,'Report back to Arcanist Thalian','416025','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620116 Storms of Magic
(620116,0,-1,1,3,'Sparkling Coral Dust',1,10,'Collect 10 Sparkling Coral Dust','','33958','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620116,1,-1,2,4,'Arcanist Thalian',416025,1,'Bring the dust to Arcanist Thalian','416025','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620117 Reacquiring Control
(620117,0,-1,1,2,'surface trash',1,15,'Kill 15 of the surface dwellers of Thalassius','417001,417004,417006,417007,417018,417021,417022,417024','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620117,1,-1,2,2,'a great brute',1,1,'Kill the rare brute: Muckdiver or Rockcrusher','417009,417003','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620117,2,-1,3,4,'Sorcerer Xycl',416010,1,'Report back to Sorcerer Xycl','416010','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620118 The Incursion
(620118,0,-1,1,3,'Kedge Artifact',1,9,'Recover 9 Kedge Artifacts','','9910032','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620118,1,-1,2,2,'kedge',1,20,'Kill 20 kedge','417011,417012,417013,417035','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620118,2,-1,3,4,'Sorcerer Xycl',416010,1,'Bring the artifacts to Sorcerer Xycl','416010','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620119 Inconsequential Restoration
(620119,0,-1,1,2,'pile of refuse',1,7,'Sift 7 piles of refuse','1520002002','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620119,1,-1,2,3,'Waterlogged Page',1,5,'Salvage 5 Waterlogged Pages','','9910027','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620119,2,-1,3,2,'zone trash',1,32,'Cull 32 denizens of Thalassius','417001,417004,417006,417007,417018,417021,417022,417024','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620119,3,-1,4,4,'Sorcerer Xycl',416010,1,'Report back to Sorcerer Xycl','416010','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620120 Exploring the Chambers
(620120,0,-1,1,5,'the drowned entry',1,1,'Explore the drowned entry of Thalassius','','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620120,1,-1,2,5,'the kedge warrens',1,1,'Explore the kedge warrens','','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620120,2,-1,3,5,'the flooded gallery',1,1,'Explore the flooded gallery','','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620120,3,-1,4,5,'the sunken amphitheater',1,1,'Explore the sunken amphitheater','','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620120,4,-1,5,5,'the coral vaults',1,1,'Explore the coral vaults','','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620120,5,-1,6,5,'the deep chamber',1,1,'Explore the deep chamber','','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620120,6,-1,7,2,'kedge experiments',1,20,'Kill 20 kedge experiments','417023,417026,417028','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620120,7,-1,8,4,'Sorcerer Xycl',416010,1,'Report back to Sorcerer Xycl','416010','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620121 Cavernous Reconnaissance
(620121,0,-1,1,5,'the caverns',1,1,'Scout the caverns of Thalassius','','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620121,1,-1,2,2,'Kraj Lucolupos',1,1,'Put down Kraj Lucolupos','1520002001','','',0,0,0,0,0,0,0,'-1','0','417',-1,0,0),
(620121,2,-1,3,4,'Sorcerer Xycl',416010,1,'Report back to Sorcerer Xycl','416010','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620122 Adapting to the Environment
(620122,0,-1,1,2,'deathspore insects',1,10,'Cull 10 deathspore insects','a_deathspore_insect','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620122,1,-1,2,3,'Deathspore Wings',1,3,'Loot 3 Deathspore Wings','','9910028','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620122,2,-1,3,3,'Chitin Mandibles',1,3,'Loot 3 Chitin Mandibles','','9910029','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620122,3,-1,4,4,'Archarcanist Pintanus',416024,1,'Bring them to Archarcanist Pintanus','416024','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620123 Adapting to the Environment II
(620123,0,-1,1,2,'serpents and apes',1,10,'Cull 10 serpents or gorillas','419007,419009','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620123,1,-1,2,3,'Serpent Sacs',1,3,'Loot 3 Serpent Sacs','','9910030','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620123,2,-1,3,3,'Venom Fangs',1,3,'Loot 3 Venom Fangs','','9910031','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620123,3,-1,4,4,'Archarcanist Pintanus',416024,1,'Bring them to Archarcanist Pintanus','416024','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620124 Retrieving the Lost Knowledge
(620124,0,-1,1,1,'The Treaty of Teleportation',1,1,'Recover The Treaty of Teleportation from the temple grounds','','9910018','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620124,1,-1,2,1,'The History of the Combine',1,1,'Recover The History of the Combine from the temple grounds','','33886','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620124,2,-1,3,3,'Illegible Combine Tome',1,5,'Loot 5 Illegible Combine Tomes from the temple shissar','','33887','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620124,3,-1,4,4,'Chief Librarian Lars',416093,1,'Bring everything to Chief Librarian Lars','416093','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620125 Zhisza Cypher
(620125,0,-1,1,3,'Top Half of the Zhisza Cipher',1,1,'Loot the Top Half of the Zhisza Cipher','','33889','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620125,1,-1,2,3,'Bottom Half of the Zhisza Cipher',1,1,'Loot the Bottom Half of the Zhisza Cipher','','33888','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620125,2,-1,3,4,'Chief Librarian Lars',416093,1,'Bring the cypher to Chief Librarian Lars','416093','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620126 Snakes on the Plain
(620126,0,-1,1,2,'Copperfang',1,1,'Kill Copperfang','419034','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620126,1,-1,2,2,'King Brownscale',1,1,'Kill King Brownscale','419044','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620126,2,-1,3,2,'Coralitus',1,1,'Kill Coralitus','419039','','',0,0,0,0,0,0,0,'-1','0','419',-1,0,0),
(620126,3,-1,4,4,'Archarcanist Pintanus',416024,1,'Report back to Archarcanist Pintanus','416024','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620127 Seeking Revenge
(620127,0,-1,1,2,'Defiler Morduz',1,1,'Kill Defiler Morduz','420054','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620127,1,-1,2,2,'Reaver Ail`zhin',1,1,'Kill Reaver Ail`zhin','420043','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620127,2,-1,3,2,'Disciple Tizlrim',1,1,'Kill Disciple Tizlrim','420060','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620127,3,-1,4,4,'Vizier Zio',416140,1,'Report back to Vizier Zio','416140','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620128 Remnants of a Lost Civilization
(620128,0,-1,1,2,'rubble piles',1,5,'Break open 5 rubble piles','420007','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620128,1,-1,2,3,'Shissar Artifact',1,5,'Recover 5 Shissar Artifacts','','33893','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620128,2,-1,3,4,'Archarcanist Pintanus',416024,1,'Bring them to Archarcanist Pintanus','416024','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620129 Remnants of a Lost Civilization II
(620129,0,-1,1,2,'brackwater elementals',1,10,'Kill 10 brackwater elementals','420001,420003,420004','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620129,1,-1,2,2,'brackwater goos',1,10,'Kill 10 brackwater goos','420005,420002','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620129,2,-1,3,3,'Artifact Shard',1,5,'Loot 5 Artifact Shards','','33894','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620129,3,-1,4,4,'Archarcanist Pintanus',416024,1,'Bring them to Archarcanist Pintanus','416024','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620130 Death Sentence
(620130,0,-1,1,1,'Lirzzha',1,1,'Deliver the vial to Lirzzha','420052','33897','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620130,1,-1,2,1,'Mordezh',1,1,'Deliver the vial to Mordezh','420061','33897','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620130,2,-1,3,1,'Hi`szhia',1,1,'Deliver the vial to Hi`szhia','420049','33897','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620130,3,-1,4,4,'Vizier Zio',416140,1,'Report back to Vizier Zio','416140','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620131 Eye in the Sky
(620131,0,-1,1,2,'shimmershell scarabs',1,10,'Clear 10 shimmershell scarabs by the first portal','420018','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620131,1,-1,2,2,'temple guards',1,10,'Clear 10 temple guards by the second portal','420048','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620131,2,-1,3,2,'imperial golems',1,10,'Clear 10 imperial golems by the third portal','420015,420016','','',0,0,0,0,0,0,0,'-1','0','420',-1,0,0),
(620131,3,-1,4,4,'Archarcanist Pintanus',416024,1,'Report back to Archarcanist Pintanus','416024','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620132 Library Heist
(620132,0,-1,1,1,'Tome of Tsaph''s Line',1,1,'Take the Tome of Tsaph''s Line from the library','','9910023','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620132,1,-1,2,1,'Ledger of the Combine',1,1,'Take the Ledger of the Combine from the library','','9910024','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620132,2,-1,3,1,'Shissar Warden Records',1,1,'Take the Shissar Warden Records from the library','','9910025','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620132,3,-1,4,1,'Katta Foundry Notes',1,1,'Take the Katta Foundry Notes from the library','','9910026','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620132,4,-1,5,4,'Arcanist Variszh',416144,1,'Deliver the volumes to Arcanist Variszh','416144','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
-- 620133 Battling the Shissar
(620133,0,-1,1,2,'templers',1,5,'Kill 5 shissar templers','416090,416107','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620133,1,-1,2,2,'firetongues',1,5,'Kill 5 shissar firetongues','416099,416101,416109','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620133,2,-1,3,2,'shadowslithers',1,5,'Kill 5 shissar shadowslithers','416098,416104,416143','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620133,3,-1,4,2,'revenants',1,5,'Kill 5 shissar revenants','416080,416118,416122','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620133,4,-1,5,2,'arbiters',1,5,'Kill 5 shissar arbiters','416074,416082,416105','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0),
(620133,5,-1,6,4,'Guard Captain Parvus',416035,1,'Report back to Guard Captain Parvus','416035','','',0,0,0,0,0,0,0,'-1','0','416',-1,0,0);

-- ---------------------------------------------------------------------------
-- A6. Combine recipes: 4 tier combines (5 fragments + sealant container ->
--     urn fragment) and the final six-item combine (4 urn fragments +
--     both handles + sealant -> the urn). Container-matched, nofail.
-- ---------------------------------------------------------------------------
DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` BETWEEN 992016 AND 992020;
DELETE FROM `tradeskill_recipe` WHERE `id` BETWEEN 992016 AND 992020;

INSERT INTO `tradeskill_recipe`
    (`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,`must_learn`,`learned_by_item_id`,`quest`,`enabled`,`min_expansion`,`max_expansion`)
VALUES
    (992016,'Dusty Urn Fragment',61,0,0,1,0,0,0,0,1,-1,-1),
    (992017,'Polished Urn Fragment',61,0,0,1,0,0,0,0,1,-1,-1),
    (992018,'Worn Urn Fragment',61,0,0,1,0,0,0,0,1,-1,-1),
    (992019,'Smudged Urn Fragment',61,0,0,1,0,0,0,0,1,-1,-1),
    (992020,'Tsaph Katta''s Urn of Rejuvenation',61,0,0,1,0,0,0,0,1,-1,-1);

INSERT INTO `tradeskill_recipe_entries`
    (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
    (992016,79919,0,0,1,0,1),
    (992016,79956,0,0,1,0,0),(992016,79957,0,0,1,0,0),(992016,79958,0,0,1,0,0),(992016,79959,0,0,1,0,0),(992016,79960,0,0,1,0,0),
    (992016,79976,1,0,0,0,0),
    (992017,79919,0,0,1,0,1),
    (992017,79961,0,0,1,0,0),(992017,79962,0,0,1,0,0),(992017,79963,0,0,1,0,0),(992017,79964,0,0,1,0,0),(992017,79965,0,0,1,0,0),
    (992017,79977,1,0,0,0,0),
    (992018,79919,0,0,1,0,1),
    (992018,79966,0,0,1,0,0),(992018,79967,0,0,1,0,0),(992018,79968,0,0,1,0,0),(992018,79969,0,0,1,0,0),(992018,79970,0,0,1,0,0),
    (992018,79978,1,0,0,0,0),
    (992019,79919,0,0,1,0,1),
    (992019,79971,0,0,1,0,0),(992019,79972,0,0,1,0,0),(992019,79973,0,0,1,0,0),(992019,79974,0,0,1,0,0),(992019,79975,0,0,1,0,0),
    (992019,79979,1,0,0,0,0),
    (992020,79919,0,0,1,0,1),
    (992020,79976,0,0,1,0,0),(992020,79977,0,0,1,0,0),(992020,79978,0,0,1,0,0),(992020,79979,0,0,1,0,0),
    (992020,79954,0,0,1,0,0),(992020,79955,0,0,1,0,0),
    (992020,79980,1,0,0,0,0);

COMMIT;
