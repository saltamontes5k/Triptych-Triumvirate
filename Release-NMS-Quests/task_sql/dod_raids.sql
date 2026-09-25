-- ---------------------------------------------------------------------------
-- Depths of Darkhollow raid access - NMS server
--
-- Adds:
--   1. The raid-version boss spawns the instance encounters attach to
--      (Bloodeye v2, Korlach v3, Draygun v2, Mayong v1).
--   2. An "a_sealed_portal" entry NPC in each parent zone that offers the raid
--      expedition (see quests/lua_modules/dod_raids.lua).
--
-- Idempotent: explicit primary keys + INSERT IGNORE, so re-running is a no-op.
-- Apply with: mariadb -u <user> -p <db> < dod_raids.sql
-- ---------------------------------------------------------------------------

-- 1. Missing raid-version boss spawns -----------------------------------------

-- Bloodeye in Snarlstone Dens: Bloodeye (eastkorlacha v2)
INSERT IGNORE INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`min_expansion`,`max_expansion`)
VALUES
	(900100, 284632, 'eastkorlacha', 2, 1455, 502, -82.875, 251, 640, 0, 0, 0, -1, -1);

-- Korlach in Lair of the Korlach: Korlach the Deep Leviathan (westkorlachc v3)
INSERT IGNORE INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`min_expansion`,`max_expansion`)
VALUES
	(900101, 284139, 'westkorlachc', 3, -34, 1868, 83.75, 183, 640, 0, 0, 0, -1, -1);

-- Emperor Draygun in the Nargil Pits: Draygun the Lich King (illsalinc v2)
INSERT IGNORE INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`min_expansion`,`max_expansion`)
VALUES
	(900102, 287152, 'illsalinc', 2, -6, -664, -111.5, 1, 640, 0, 0, 0, -1, -1);

-- Mayong Mistmoore in the Demi-Plane of Blood (dreadspire v1) - no prior spawn
INSERT IGNORE INTO `spawngroup` (`id`,`name`) VALUES (900103, 'Mayong_Mistmoore_dreadspire_v1');
INSERT IGNORE INTO `spawnentry` (`spawngroupID`,`npcID`) VALUES (900103, 351118);
INSERT IGNORE INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`min_expansion`,`max_expansion`)
VALUES
	(900103, 900103, 'dreadspire', 1, 1386, -1032, -575.145, 352, 640, 0, 0, 0, -1, -1);

-- 2. Entry seals --------------------------------------------------------------
-- NPC type ids:
--   900011 corathus     -> Antraygus, the Sporali King
--   900012 drachnidhive -> Sendaii, the Hive Queen
--   900013 eastkorlach  -> Bloodeye
--   900014 westkorlach  -> Matriarch Shyra
--   900015 westkorlach  -> Korlach, the Deep Leviathan
--   900016 illsalin     -> Emperor Draygun
--   900017 dreadspire   -> Mayong Mistmoore

INSERT IGNORE INTO `npc_types`
	(`id`,`name`,`level`,`race`,`class`,`bodytype`,`hp`,`size`,`runspeed`,`attack_delay`,`see_invis`,`see_invis_undead`,`see_hide`,`see_improved_hide`,`trackable`,`npc_spells_id`,`loottable_id`,`merchant_id`,`gender`,`texture`,`helmtexture`,`spawn_limit`)
VALUES
	(900011, 'a_sealed_portal', 1, 312, 1, 7, 100000, 2, 0, 30, 1, 1, 1, 1, 1, 0, 0, 0, 2, 0, 0, 0),
	(900012, 'a_sealed_portal', 1, 312, 1, 7, 100000, 2, 0, 30, 1, 1, 1, 1, 1, 0, 0, 0, 2, 0, 0, 0),
	(900013, 'a_sealed_portal', 1, 312, 1, 7, 100000, 2, 0, 30, 1, 1, 1, 1, 1, 0, 0, 0, 2, 0, 0, 0),
	(900014, 'a_sealed_portal', 1, 312, 1, 7, 100000, 2, 0, 30, 1, 1, 1, 1, 1, 0, 0, 0, 2, 0, 0, 0),
	(900015, 'a_sealed_portal', 1, 312, 1, 7, 100000, 2, 0, 30, 1, 1, 1, 1, 1, 0, 0, 0, 2, 0, 0, 0),
	(900016, 'a_sealed_portal', 1, 312, 1, 7, 100000, 2, 0, 30, 1, 1, 1, 1, 1, 0, 0, 0, 2, 0, 0, 0),
	(900017, 'a_sealed_portal', 1, 312, 1, 7, 100000, 2, 0, 30, 1, 1, 1, 1, 1, 0, 0, 0, 2, 0, 0, 0);

INSERT IGNORE INTO `spawngroup` (`id`,`name`) VALUES
	(900011, 'a_sealed_portal_corathus'),
	(900012, 'a_sealed_portal_drachnidhive'),
	(900013, 'a_sealed_portal_eastkorlach'),
	(900014, 'a_sealed_portal_westkorlach_shyra'),
	(900015, 'a_sealed_portal_westkorlach_korlach'),
	(900016, 'a_sealed_portal_illsalin'),
	(900017, 'a_sealed_portal_dreadspire');

INSERT IGNORE INTO `spawnentry` (`spawngroupID`,`npcID`) VALUES
	(900011, 900011),
	(900012, 900012),
	(900013, 900013),
	(900014, 900014),
	(900015, 900015),
	(900016, 900016),
	(900017, 900017);

INSERT IGNORE INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`min_expansion`,`max_expansion`)
VALUES
	(900011, 900011, 'corathus',     0, 243, -740, -47.6, 0, 900, 0, 0, 0, -1, -1),
	(900012, 900012, 'drachnidhive', 0, 1133, 380, 304, 0, 900, 0, 0, 0, -1, -1),
	(900013, 900013, 'eastkorlach',  0, -932, -1344, 186.4, 0, 900, 0, 0, 0, -1, -1),
	(900014, 900014, 'westkorlach',  0, 851, -686, 43.25, 0, 900, 0, 0, 0, -1, -1),
	(900015, 900015, 'westkorlach',  0, -1201, -66, 63.25, 0, 900, 0, 0, 0, -1, -1),
	(900016, 900016, 'illsalin',     0, 829, -734, 61, 0, 900, 0, 0, 0, -1, -1),
	(900017, 900017, 'dreadspire',   0, 1136, -1172, -547.5, 0, 900, 0, 0, 0, -1, -1);

-- 3. Seal positions (idempotent re-placement for existing installs) ----------
--    Seals are placed next to the thematically related quest NPCs:
--      corathus #Bellfast, drachnidhive #Drithnak, eastkorlach #Elder_Ritualist_Longshadow,
--      westkorlach Shadowalker_Dustspirit (Shyra) / Widdlethorpe_Gemfinder (Korlach),
--      illsalin #Ritesmaster_Verok, dreadspire a_servant entrance.
UPDATE `spawn2` SET `x` = 243,   `y` = -740,  `z` = -47.6  WHERE `id` = 900011;
UPDATE `spawn2` SET `x` = 1133,  `y` = 380,   `z` = 304    WHERE `id` = 900012;
UPDATE `spawn2` SET `x` = -932,  `y` = -1344, `z` = 186.4  WHERE `id` = 900013;
UPDATE `spawn2` SET `x` = 851,   `y` = -686,  `z` = 43.25  WHERE `id` = 900014;
UPDATE `spawn2` SET `x` = -1201, `y` = -66,   `z` = 63.25  WHERE `id` = 900015;
UPDATE `spawn2` SET `x` = 829,   `y` = -734,  `z` = 61     WHERE `id` = 900016;
UPDATE `spawn2` SET `x` = 1136,  `y` = -1172, `z` = -547.5 WHERE `id` = 900017;

-- ===========================================================================
-- G3: instanced Master Vule the Silent Tear (dreadspire version 2)
-- ---------------------------------------------------------------------------
-- The static version-0 Vule (spawn2 101495) is retained for open-world play.
-- This adds a version-2 instance (requested via Margaret Hill) so the raid can
-- record its lockout, like the other DoD raid targets.
-- Idempotent (zone row guarded by version; spawns use fixed ids).
-- ===========================================================================

-- 1. New dreadspire version 2 (clone the Demi-Plane instance row).
DELETE FROM `zone` WHERE `short_name` = 'dreadspire' AND `version` = 2;
DROP TEMPORARY TABLE IF EXISTS `dod_zone_clone`;
CREATE TEMPORARY TABLE `dod_zone_clone` AS SELECT * FROM `zone` WHERE `short_name` = 'dreadspire' AND `version` = 1;
UPDATE `dod_zone_clone` SET `id` = 0, `version` = 2, `long_name` = 'Dreadspire Keep: Vule''s Chambers';
INSERT INTO `zone` SELECT * FROM `dod_zone_clone`;
DROP TEMPORARY TABLE IF EXISTS `dod_zone_clone`;

-- 2. Margaret Hill (expedition giver), cloned from Brother Dark Water (362108).
DELETE FROM `spawnentry` WHERE `spawngroupID` = 900216;
DELETE FROM `spawngroup` WHERE `id` = 900216;
DELETE FROM `spawn2` WHERE `id` = 900216;
DELETE FROM `npc_types` WHERE `name` = 'Margaret_Hill';

DROP TEMPORARY TABLE IF EXISTS `dod_npc_clone`;
CREATE TEMPORARY TABLE `dod_npc_clone` AS SELECT * FROM `npc_types` WHERE `id` = 362108;
UPDATE `dod_npc_clone` SET `id` = 900216, `name` = 'Margaret_Hill', `loottable_id` = 0;
INSERT INTO `npc_types` SELECT * FROM `dod_npc_clone`;
DROP TEMPORARY TABLE IF EXISTS `dod_npc_clone`;

INSERT INTO `spawngroup` (`id`,`name`) VALUES (900216, 'Margaret_Hill_dreadspire');
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`) VALUES (900216, 900216);
INSERT INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`min_expansion`,`max_expansion`)
VALUES
	(900216, 900216, 'dreadspire', 0, 1400, -1000, -572, 0, 640, 0, 0, 0, -1, -1);

-- 3. Vule in the version-2 instance (reuse spawngroup 63329 = Master Vule).
INSERT IGNORE INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`min_expansion`,`max_expansion`)
VALUES
	(900217, 63329, 'dreadspire', 2, 0, 147, -1354.875, 0, 640, 0, 0, 0, -1, -1);