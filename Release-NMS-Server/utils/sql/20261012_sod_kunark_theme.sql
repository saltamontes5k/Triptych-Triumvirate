-- SoD Kunark theme completion (raspersrealm themeKunark). Generated
-- by sod_content/gen_kunarktheme.py -- do not hand-edit.
-- Twin content of manifest entry '20261012_sod_kunark_theme' (v147).
-- Sections: Kaesora Library/Hatchery entry doors; Tynoc faction
-- chain (npc_faction 1520000104, kill cascade via faction_association,
-- Kunark tasks -> 1224); merchant 999999 + Bone Wiring Tools / Emblem
-- of Scale; Bone Mask of the Ancient Iksar click effect; the 37
-- missing themeKunark static named rares with page loot.

-- ============================================================
-- 1. Doors: FoS Kaesora Library (38/39/44) + Hatchery (36/37)
--    teleport doors -> the dungeon safe points. Both door version
--    rows (0 and 100) are covered by the unfiltered UPDATE.
-- ============================================================
UPDATE `doors` SET `dest_zone` = 'oldkaesoraa', `dest_x` = 33.67, `dest_y` = -20.86, `dest_z` = 3.37 WHERE `zone` = 'oldfieldofbone' AND `doorid` IN (38, 39, 44);
UPDATE `doors` SET `dest_zone` = 'oldkaesorab', `dest_x` = -64, `dest_y` = -30, `dest_z` = 2 WHERE `zone` = 'oldfieldofbone' AND `doorid` IN (36, 37);

-- ============================================================
-- 2. Tynoc faction chain: primary faction for the Warmly merchant
--    gate; kill cascade so theme trash raises Tynoc (-25/kill);
--    Kunark tasks flip from Cirtan to Tynoc (page: every quest in
--    the theme raises this faction).
-- ============================================================
DELETE FROM `npc_faction` WHERE `id` = 1520000104;
INSERT INTO `npc_faction` (`id`,`name`,`primaryfaction`,`ignore_primary_assist`) VALUES (1520000104,'overhaul_1224',1224,0);
UPDATE `npc_types` SET `npc_faction_id` = 1520000104 WHERE `id` = 452153;
UPDATE `faction_association` SET `id_3` = 1224, `mod_3` = -1.0 WHERE `id` = 307;
DELETE FROM `faction_association` WHERE `id` = 1229;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1229,1224,-1.0);
-- FoS sarnak trash (npc_faction 405 -> primary 307): RewardFaction
-- path with -25/kill, cascading +25 Tynoc via association mod -1.0.
UPDATE `npc_types` SET `faction_amount` = -25 WHERE `npc_faction_id` = 405 AND `id` BETWEEN 452000 AND 452999;
-- Theme dungeon trash + iksar rares (npc_faction 1520000091 ->
-- primary 1229, used only in the four theme zones): same treatment.
UPDATE `npc_types` SET `faction_amount` = -25 WHERE `npc_faction_id` = 1520000091;
UPDATE `tasks` SET `faction_reward` = 1224 WHERE `id` IN (303020,303021,303022,303023,303024,303062);

-- ============================================================
-- 3. Tynoc merchant (999999, shared with Cirtan): Bone Wiring
--    Tools (page Apprehensive tier) + Emblem of Scale (page Ally
--    tier = 1101). Warmly Rk. II scrolls already on the list.
-- ============================================================
DELETE FROM `merchantlist` WHERE `merchantid` = 999999 AND `item` IN (42782,103102);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (999999,773,42782,0);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (999999,774,103102,1101);

-- ============================================================
-- 4. The Grand Illusion: Bone Mask of the Ancient Iksar click
--    effect (Illusion: Ancient Iksar, 2s, unlimited). Handed out
--    by oldfieldofbone/452150.pl (Phara Dar).
-- ============================================================
UPDATE `items` SET `clickeffect` = 13394, `clicktype` = 5, `casttime` = 2000, `clicklevel` = 0, `recastdelay` = 0, `recasttype` = 0, `maxcharges` = -1 WHERE `id` = 80061;

-- ============================================================
-- 5. Theme static named rares: donor clones, always up, page
--    loot (plain 25%, namesake 15%). Spawn points are real elite
--    spawn2 coordinates read at generation time.
-- ============================================================
DELETE FROM `npc_types` WHERE `id` BETWEEN 1120002073 AND 1120002109;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 1520008723 AND 1520008759;
DELETE FROM `spawn2` WHERE `spawngroupID` BETWEEN 1520008723 AND 1520008759;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 1520008723 AND 1520008759;
DELETE FROM `loottable_entries` WHERE `loottable_id` BETWEEN 1520008393 AND 1520008429;
DELETE FROM `loottable` WHERE `id` BETWEEN 1520008393 AND 1520008429;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 1520008432 AND 1520008468;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 1520008432 AND 1520008468;

DROP TEMPORARY TABLE IF EXISTS sod_kunark_rare_nt;
CREATE TEMPORARY TABLE sod_kunark_rare_nt AS SELECT * FROM npc_types WHERE 0;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452251;
UPDATE sod_kunark_rare_nt SET id = 1120002073, name = 'an_ancient_bonegrinder', level = 82, hp = 200000, mana = 0, loottable_id = 1520008393, merchant_id = 0, faction_amount = -25 WHERE id = 452251;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452253;
UPDATE sod_kunark_rare_nt SET id = 1120002074, name = 'Battleguard_Gauntas', level = 82, hp = 200000, mana = 0, loottable_id = 1520008394, merchant_id = 0, faction_amount = -25 WHERE id = 452253;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452085;
UPDATE sod_kunark_rare_nt SET id = 1120002075, name = 'Blackblade_Lorkis', level = 82, hp = 200000, mana = 0, loottable_id = 1520008395, merchant_id = 0, faction_amount = -25 WHERE id = 452085;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452023;
UPDATE sod_kunark_rare_nt SET id = 1120002076, name = 'Darkcoil_the_Constrictor', level = 80, hp = 150000, mana = 0, loottable_id = 1520008396, merchant_id = 0, faction_amount = -25 WHERE id = 452023;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452023;
UPDATE sod_kunark_rare_nt SET id = 1120002077, name = 'Festersting_the_Diminutive', level = 80, hp = 150000, mana = 0, loottable_id = 1520008397, merchant_id = 0, faction_amount = -25 WHERE id = 452023;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452258;
UPDATE sod_kunark_rare_nt SET id = 1120002078, name = 'Fluttershade', level = 80, hp = 120000, mana = 0, loottable_id = 1520008398, merchant_id = 0, faction_amount = -25 WHERE id = 452258;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452013;
UPDATE sod_kunark_rare_nt SET id = 1120002079, name = 'Jracsza_the_Feral', level = 81, hp = 160000, mana = 0, loottable_id = 1520008399, merchant_id = 0, faction_amount = -25 WHERE id = 452013;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452239;
UPDATE sod_kunark_rare_nt SET id = 1120002080, name = 'Naskado_the_Demented', level = 82, hp = 180000, mana = 0, loottable_id = 1520008400, merchant_id = 0, faction_amount = -25 WHERE id = 452239;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452239;
UPDATE sod_kunark_rare_nt SET id = 1120002081, name = 'Oracle_Vro`Zok', level = 82, hp = 180000, mana = 0, loottable_id = 1520008401, merchant_id = 0, faction_amount = -25 WHERE id = 452239;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453003;
UPDATE sod_kunark_rare_nt SET id = 1120002082, name = 'Aquadominus_Selestian', level = 85, hp = 250000, mana = 0, loottable_id = 1520008402, merchant_id = 0, faction_amount = -25 WHERE id = 453003;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453068;
UPDATE sod_kunark_rare_nt SET id = 1120002083, name = 'Assistant_Librarian_Krekn', level = 82, hp = 180000, mana = 0, loottable_id = 1520008403, merchant_id = 0, faction_amount = -25 WHERE id = 453068;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453024;
UPDATE sod_kunark_rare_nt SET id = 1120002084, name = 'Chief_Groundskeeper_Dralnit', level = 83, hp = 220000, mana = 0, loottable_id = 1520008404, merchant_id = 0, faction_amount = -25 WHERE id = 453024;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453108;
UPDATE sod_kunark_rare_nt SET id = 1120002085, name = 'Corrupted_Sentinel', level = 83, hp = 220000, mana = 0, loottable_id = 1520008405, merchant_id = 0, faction_amount = -25 WHERE id = 453108;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453072;
UPDATE sod_kunark_rare_nt SET id = 1120002086, name = 'Grellik_Master_of_Torments', level = 85, hp = 250000, mana = 0, loottable_id = 1520008406, merchant_id = 0, faction_amount = -25 WHERE id = 453072;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453038;
UPDATE sod_kunark_rare_nt SET id = 1120002087, name = 'Hesila_Preceptor_of_Kaesora', level = 85, hp = 250000, mana = 0, loottable_id = 1520008407, merchant_id = 0, faction_amount = -25 WHERE id = 453038;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453024;
UPDATE sod_kunark_rare_nt SET id = 1120002088, name = 'Library_Director_Eslisar', level = 84, hp = 240000, mana = 0, loottable_id = 1520008408, merchant_id = 0, faction_amount = -25 WHERE id = 453024;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453031;
UPDATE sod_kunark_rare_nt SET id = 1120002089, name = 'Skeleton_Keymaster', level = 84, hp = 240000, mana = 0, loottable_id = 1520008409, merchant_id = 0, faction_amount = -25 WHERE id = 453031;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453072;
UPDATE sod_kunark_rare_nt SET id = 1120002090, name = 'Sorakan_the_Mighty', level = 85, hp = 260000, mana = 0, loottable_id = 1520008410, merchant_id = 0, faction_amount = -25 WHERE id = 453072;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453031;
UPDATE sod_kunark_rare_nt SET id = 1120002091, name = 'Teacher''s_Pet', level = 80, hp = 150000, mana = 0, loottable_id = 1520008411, merchant_id = 0, faction_amount = -25 WHERE id = 453031;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453038;
UPDATE sod_kunark_rare_nt SET id = 1120002092, name = 'Thisla_Twinskull_Matron', level = 84, hp = 240000, mana = 0, loottable_id = 1520008412, merchant_id = 0, faction_amount = -25 WHERE id = 453038;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 454005;
UPDATE sod_kunark_rare_nt SET id = 1120002093, name = 'Blademaster_Kraszen', level = 85, hp = 250000, mana = 0, loottable_id = 1520008413, merchant_id = 0, faction_amount = -25 WHERE id = 454005;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452239;
UPDATE sod_kunark_rare_nt SET id = 1120002094, name = 'Eazack_the_Cruel', level = 84, hp = 240000, mana = 0, loottable_id = 1520008414, merchant_id = 0, faction_amount = -25 WHERE id = 452239;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 454014;
UPDATE sod_kunark_rare_nt SET id = 1120002095, name = 'Grandmaster_Merxs', level = 85, hp = 250000, mana = 0, loottable_id = 1520008415, merchant_id = 0, faction_amount = -25 WHERE id = 454014;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 454023;
UPDATE sod_kunark_rare_nt SET id = 1120002096, name = 'Imperial_Enforcer', level = 84, hp = 240000, mana = 0, loottable_id = 1520008416, merchant_id = 0, faction_amount = -25 WHERE id = 454023;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 454000;
UPDATE sod_kunark_rare_nt SET id = 1120002097, name = 'Lich_Guardian_Ssicroz', level = 85, hp = 250000, mana = 0, loottable_id = 1520008417, merchant_id = 0, faction_amount = -25 WHERE id = 454000;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 454023;
UPDATE sod_kunark_rare_nt SET id = 1120002098, name = 'Numbing_Construct', level = 82, hp = 200000, mana = 0, loottable_id = 1520008418, merchant_id = 0, faction_amount = -25 WHERE id = 454023;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 454005;
UPDATE sod_kunark_rare_nt SET id = 1120002099, name = 'Toriss_the_Protector', level = 84, hp = 240000, mana = 0, loottable_id = 1520008419, merchant_id = 0, faction_amount = -25 WHERE id = 454005;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452251;
UPDATE sod_kunark_rare_nt SET id = 1120002100, name = 'Bite', level = 82, hp = 200000, mana = 0, loottable_id = 1520008420, merchant_id = 0, faction_amount = -25 WHERE id = 452251;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 455067;
UPDATE sod_kunark_rare_nt SET id = 1120002101, name = 'Consersa', level = 84, hp = 240000, mana = 0, loottable_id = 1520008421, merchant_id = 0, faction_amount = -25 WHERE id = 455067;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453024;
UPDATE sod_kunark_rare_nt SET id = 1120002102, name = 'Cosensal', level = 85, hp = 250000, mana = 0, loottable_id = 1520008422, merchant_id = 0, faction_amount = -25 WHERE id = 453024;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 455002;
UPDATE sod_kunark_rare_nt SET id = 1120002103, name = 'Estar', level = 84, hp = 240000, mana = 0, loottable_id = 1520008423, merchant_id = 0, faction_amount = -25 WHERE id = 455002;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 455067;
UPDATE sod_kunark_rare_nt SET id = 1120002104, name = 'Isinente', level = 84, hp = 240000, mana = 0, loottable_id = 1520008424, merchant_id = 0, faction_amount = -25 WHERE id = 455067;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 455011;
UPDATE sod_kunark_rare_nt SET id = 1120002105, name = 'Lieutenant_Tenante', level = 83, hp = 220000, mana = 0, loottable_id = 1520008425, merchant_id = 0, faction_amount = -25 WHERE id = 455011;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453038;
UPDATE sod_kunark_rare_nt SET id = 1120002106, name = 'Louko', level = 85, hp = 250000, mana = 0, loottable_id = 1520008426, merchant_id = 0, faction_amount = -25 WHERE id = 453038;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 452251;
UPDATE sod_kunark_rare_nt SET id = 1120002107, name = 'Mordid', level = 82, hp = 200000, mana = 0, loottable_id = 1520008427, merchant_id = 0, faction_amount = -25 WHERE id = 452251;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 453003;
UPDATE sod_kunark_rare_nt SET id = 1120002108, name = 'Oracao', level = 84, hp = 240000, mana = 0, loottable_id = 1520008428, merchant_id = 0, faction_amount = -25 WHERE id = 453003;
INSERT INTO sod_kunark_rare_nt SELECT * FROM npc_types WHERE id = 455067;
UPDATE sod_kunark_rare_nt SET id = 1120002109, name = 'Protector_Hilith', level = 83, hp = 220000, mana = 0, loottable_id = 1520008429, merchant_id = 0, faction_amount = -25 WHERE id = 455067;
INSERT INTO `npc_types` SELECT * FROM sod_kunark_rare_nt;
DROP TEMPORARY TABLE sod_kunark_rare_nt;

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008393,'sod_kunark_bonegrinder',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008432,'sod_kunark_bonegrinder_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008393,1520008432,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008432,105724,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008432,105772,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008432,106224,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008394,'sod_kunark_gauntas',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008433,'sod_kunark_gauntas_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008394,1520008433,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008433,105717,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008433,105739,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008433,106217,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008433,106239,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008395,'sod_kunark_lorkis',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008434,'sod_kunark_lorkis_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008395,1520008434,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008434,105738,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008434,105746,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008434,106238,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008434,106246,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008396,'sod_kunark_darkcoil',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008435,'sod_kunark_darkcoil_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008396,1520008435,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008435,105712,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008435,105760,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008435,106212,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008397,'sod_kunark_festersting',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008436,'sod_kunark_festersting_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008397,1520008436,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008436,105718,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008436,105768,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008436,106218,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008398,'sod_kunark_fluttershade',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008437,'sod_kunark_fluttershade_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008398,1520008437,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008437,105723,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008437,105751,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008437,106223,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008437,106251,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008399,'sod_kunark_jracsza',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008438,'sod_kunark_jracsza_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008399,1520008438,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008438,105725,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008438,105773,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008438,106225,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008400,'sod_kunark_naskado',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008439,'sod_kunark_naskado_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008400,1520008439,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008439,105713,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008439,105761,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008439,106213,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008401,'sod_kunark_vrozok',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008440,'sod_kunark_vrozok_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008401,1520008440,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008440,105729,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008440,105740,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008440,106229,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008440,106240,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008402,'sod_kunark_selestian',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008441,'sod_kunark_selestian_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008402,1520008441,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008441,105716,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008441,105770,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008441,106216,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008403,'sod_kunark_krekn',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008442,'sod_kunark_krekn_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008403,1520008442,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008442,105715,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008442,105763,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008442,106215,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008404,'sod_kunark_dralnit',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008443,'sod_kunark_dralnit_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008404,1520008443,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008443,105743,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008443,105748,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008443,106243,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008443,106248,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008405,'sod_kunark_corrupted_sentinel',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008444,'sod_kunark_corrupted_sentinel_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008405,1520008444,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008444,105700,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008444,105705,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008444,106200,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008444,106205,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008406,'sod_kunark_grellik',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008445,'sod_kunark_grellik_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008406,1520008445,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008445,105732,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008445,105777,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008445,106232,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008407,'sod_kunark_hesila',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008446,'sod_kunark_hesila_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008407,1520008446,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008446,105756,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008446,105778,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008446,106256,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008408,'sod_kunark_eslisar',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008447,'sod_kunark_eslisar_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008408,1520008447,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008447,105726,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008447,105779,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008447,106226,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008409,'sod_kunark_keymaster',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008448,'sod_kunark_keymaster_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008409,1520008448,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008448,105737,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008448,105755,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008448,106237,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008448,106255,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008410,'sod_kunark_sorakan',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008449,'sod_kunark_sorakan_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008410,1520008449,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008449,105745,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008449,105762,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008449,106245,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008411,'sod_kunark_teachers_pet',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008450,'sod_kunark_teachers_pet_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008411,1520008450,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008450,105733,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008450,105759,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008450,106233,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008412,'sod_kunark_thisla',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008451,'sod_kunark_thisla_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008412,1520008451,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008451,105731,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008451,106231,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008451,106247,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008413,'sod_kunark_kraszen',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008452,'sod_kunark_kraszen_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008413,1520008452,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008452,105742,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008452,105774,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008452,106242,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008414,'sod_kunark_eazack',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008453,'sod_kunark_eazack_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008414,1520008453,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008453,105754,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008453,105775,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008453,106254,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008415,'sod_kunark_merxs',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008454,'sod_kunark_merxs_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008415,1520008454,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008454,105711,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008454,105758,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008454,106211,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008416,'sod_kunark_enforcer',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008455,'sod_kunark_enforcer_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008416,1520008455,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008455,105727,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008455,105765,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008455,106227,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008417,'sod_kunark_ssicroz',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008456,'sod_kunark_ssicroz_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008417,1520008456,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008456,105728,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008456,105766,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008456,106228,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008418,'sod_kunark_numbing',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008457,'sod_kunark_numbing_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008418,1520008457,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008457,105702,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008457,105707,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008457,106202,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008457,106207,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008419,'sod_kunark_toriss',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008458,'sod_kunark_toriss_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008419,1520008458,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008458,105706,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008458,105709,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008458,106206,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008458,106209,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008420,'sod_kunark_bite',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008459,'sod_kunark_bite_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008420,1520008459,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008459,105703,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008459,105708,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008459,106203,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008459,106208,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008421,'sod_kunark_consersa',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008460,'sod_kunark_consersa_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008421,1520008460,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008460,105749,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008460,105769,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008460,106249,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008422,'sod_kunark_cosensal',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008461,'sod_kunark_cosensal_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008422,1520008461,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008461,105722,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008461,105767,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008461,106222,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008423,'sod_kunark_estar',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008462,'sod_kunark_estar_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008423,1520008462,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008462,105730,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008462,105764,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008462,106230,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008424,'sod_kunark_isinente',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008463,'sod_kunark_isinente_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008424,1520008463,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008463,105721,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008463,105753,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008463,106221,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008463,106253,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008425,'sod_kunark_tenante',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008464,'sod_kunark_tenante_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008425,1520008464,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008464,105736,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008464,105757,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008464,106236,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008464,106257,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008426,'sod_kunark_louko',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008465,'sod_kunark_louko_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008426,1520008465,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008465,105719,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008465,105744,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008465,106219,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008465,106244,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008427,'sod_kunark_mordid',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008466,'sod_kunark_mordid_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008427,1520008466,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008466,105720,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008466,105741,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008466,106220,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008466,106241,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008428,'sod_kunark_oracao',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008467,'sod_kunark_oracao_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008428,1520008467,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008467,105714,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008467,105771,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008467,106214,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008429,'sod_kunark_hilith',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008468,'sod_kunark_hilith_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008429,1520008468,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008468,105701,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008468,105704,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008468,106201,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008468,106204,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008723,'sod_kunark_rare_bonegrinder',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008723,1120002073,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008723,'oldfieldofbone',0,-666.38,-1931.38,-47.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008724,'sod_kunark_rare_gauntas',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008724,1120002074,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008724,'oldfieldofbone',0,-98.5,-1836.12,-47.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008725,'sod_kunark_rare_lorkis',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008725,1120002075,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008725,'oldfieldofbone',0,218.25,-852.5,-40.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008726,'sod_kunark_rare_darkcoil',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008726,1120002076,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008726,'oldfieldofbone',0,582.0,-70.0,-31.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008727,'sod_kunark_rare_festersting',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008727,1120002077,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008727,'oldfieldofbone',0,843.5,-1526.62,-28.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008728,'sod_kunark_rare_fluttershade',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008728,1120002078,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008728,'oldfieldofbone',0,1096.88,-1800.62,-22.12,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008729,'sod_kunark_rare_jracsza',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008729,1120002079,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008729,'oldfieldofbone',0,1305.38,-1451.0,-28.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008730,'sod_kunark_rare_naskado',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008730,1120002080,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008730,'oldfieldofbone',0,1428.0,1714.62,-45.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008731,'sod_kunark_rare_vrozok',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008731,1120002081,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008731,'oldfieldofbone',0,2001.25,-81.88,-38.38,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008732,'sod_kunark_rare_selestian',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008732,1120002082,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008732,'oldkaesoraa',0,-2512.25,-758.25,-767.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008733,'sod_kunark_rare_krekn',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008733,1120002083,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008733,'oldkaesoraa',0,-2220.5,-1072.62,-759.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008734,'sod_kunark_rare_dralnit',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008734,1120002084,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008734,'oldkaesoraa',0,-1816.12,-1190.88,-687.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008735,'sod_kunark_rare_corrupted_sentinel',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008735,1120002085,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008735,'oldkaesoraa',0,-1493.38,-865.75,-327.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008736,'sod_kunark_rare_grellik',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008736,1120002086,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008736,'oldkaesoraa',0,-1320.62,-1099.75,-159.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008737,'sod_kunark_rare_hesila',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008737,1120002087,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008737,'oldkaesoraa',0,-1245.62,-841.25,-287.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008738,'sod_kunark_rare_eslisar',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008738,1120002088,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008738,'oldkaesoraa',0,-1177.75,-1238.0,-517.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008739,'sod_kunark_rare_keymaster',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008739,1120002089,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008739,'oldkaesoraa',0,-995.88,-1259.75,-156.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008740,'sod_kunark_rare_sorakan',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008740,1120002090,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008740,'oldkaesoraa',0,-1.0,-147.75,2.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008741,'sod_kunark_rare_teachers_pet',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008741,1120002091,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008741,'oldkaesoraa',0,142.88,-1765.88,-191.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008742,'sod_kunark_rare_thisla',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008742,1120002092,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008742,'oldkaesoraa',0,261.0,-2094.0,-157.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008743,'sod_kunark_rare_kraszen',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008743,1120002093,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008743,'oldkaesorab',0,17.62,35.12,2.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008744,'sod_kunark_rare_eazack',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008744,1120002094,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008744,'oldkaesorab',0,133.88,-93.25,-21.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008745,'sod_kunark_rare_merxs',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008745,1120002095,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008745,'oldkaesorab',0,219.25,-219.38,-49.38,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008746,'sod_kunark_rare_enforcer',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008746,1120002096,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008746,'oldkaesorab',0,313.38,-28.0,-131.12,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008747,'sod_kunark_rare_ssicroz',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008747,1120002097,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008747,'oldkaesorab',0,365.12,157.5,-87.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008748,'sod_kunark_rare_numbing',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008748,1120002098,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008748,'oldkaesorab',0,465.38,-145.88,-50.12,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008749,'sod_kunark_rare_toriss',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008749,1120002099,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008749,'oldkaesorab',0,517.0,1.0,-21.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008750,'sod_kunark_rare_bite',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008750,1120002100,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008750,'oldkurn',0,-416.88,-24.12,113.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008751,'sod_kunark_rare_consersa',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008751,1120002101,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008751,'oldkurn',0,-316.38,-197.62,140.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008752,'sod_kunark_rare_cosensal',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008752,1120002102,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008752,'oldkurn',0,-285.12,-65.38,152.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008753,'sod_kunark_rare_estar',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008753,1120002103,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008753,'oldkurn',0,-219.5,33.25,312.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008754,'sod_kunark_rare_isinente',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008754,1120002104,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008754,'oldkurn',0,-182.12,-130.0,194.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008755,'sod_kunark_rare_tenante',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008755,1120002105,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008755,'oldkurn',0,-139.25,60.5,192.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008756,'sod_kunark_rare_louko',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008756,1120002106,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008756,'oldkurn',0,-98.88,51.75,2.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008757,'sod_kunark_rare_mordid',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008757,1120002107,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008757,'oldkurn',0,-56.38,-92.0,103.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008758,'sod_kunark_rare_oracao',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008758,1120002108,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008758,'oldkurn',0,35.75,51.25,4.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008759,'sod_kunark_rare_hilith',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008759,1120002109,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008759,'oldkurn',0,86.5,96.75,2.88,0,3600);
