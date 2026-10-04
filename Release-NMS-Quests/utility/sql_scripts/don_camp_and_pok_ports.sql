-- =====================================================================
--  DoN camp relocation (Lavastorm) + Plane of Knowledge portal NPCs
--  Triptych Triumvirate
--
--  *** v0 ONLY. Every statement pins `version = 0`. ***
--  lavastorm has two zone rows: id 202 / version 0 (base) and id 9016 /
--  version 1 ("Dragons of Norrath Lavastorm"). The v1 copy is a separate
--  spawn set whose ground is ~79 units lower (the v1 DoN Porter sits at
--  z = -45/-46, while the v0 terrain at the same x/y is z = 33). A version-less
--  UPDATE silently rewrites BOTH sets, which is wrong for either map. This file
--  therefore touches v0 only and leaves the v1 rows exactly as it found them.
--
--  Background: the v0 camp was built by ldon_don_access.sql, which put the whole
--  camp next to the DoN Porter at (795, 417) and clamped every member to z = -46,
--  and then 20260929_lavastorm_don_camp_z33.sql, which forced that z up to 33
--  because the camp was "spawning below the client terrain, deep inside
--  geometry". The z=33 clamp is one blanket value, so it only looks right where
--  the terrain happens to sit at 33.
--
--  Part 1: move the Dark Reign camp to 941, -393, 3 -- the DoN merchant camp,
--          whose real v0 ground is z ~ -1..8 (Cyspeth Romtai 3.39, Jenah
--          Wheelspinner -1.00, Jengo Smirt 3.53). The DoN Porter is NOT moved:
--          it stays at its original neutral spot 795, 417, -45 so every faction
--          can reach it, and it is made non-aggressive.
--
--  Part 2: the Norrath's Keepers camp (npc_faction_id 1040) is moved OUT of that
--          camp and up to the Lavastorm druid ring. It was left at (770-830, 440)
--          holding the z = 33 clamp, so at that spot's true ground the whole
--          faction sits inside geometry and never appears. The ring's v0 ground
--          is z ~ 119.5 (waypoint row in zone/nms_waypoints.h; #Sasily_Verous
--          spawns there at 119.5, Tisiana's copies at 125.9-128.0).
--
--  Part 3: the v0 guard pools that share the old camp's coordinates move too --
--          Keepers Guard/Scout to the ring with their camp, Dark Reign Guard to
--          the merchant camp with theirs. These spawn2 rows are shared random
--          pools (2-3 NPCs each at 33-50% chance), so one row moves a whole pool.
--
--  Part 4: create the Plane of Knowledge "Crystalwing Scholar" (npc_types
--          202533) at -154, 55, -157 -- ports to Crescent Reach when hailed,
--          gated on TSS progression (see poknowledge/Crystalwing_Scholar.lua).
--
--  NOTE - no Priest of Discord is created here. poknowledge already has
--  Priest_of_Discord 202340 (spawns 40403 and 3264410), and because quest files
--  are matched by NPC name, poknowledge/Priest_of_Discord.lua attaches to that
--  existing NPC. An earlier revision of this file added a second Priest
--  (202534); it was deleted as redundant. See the DELIBERATELY NOT section.
--
--  Part 6: the two DoN merchants were stranded elsewhere in the zone, sunk in
--          geometry (Voltak at z=38, Wendel at z=33). Moved into the merchant
--          camp at z = 3 beside the same ground references.
--
--  The Herald_of_Druzzil_Ro in Plane of Knowledge already exists (202425) and
--  needs no SQL: poknowledge/Herald_of_Druzzil_Ro.lua now gates its Plane of
--  Time port on SoD progression.
--
--  ID blocks used (checked free in the live peq DB):
--    npc_types   202533
--    spawngroup  60005200
--    spawn2      1201151
--  (spawngroup 60005201 / npc_types 202534 were a redundant second Priest of
--   Discord and have been removed -- see the note above.)
--
--  Applied to the live peq DB. Safe to re-run: scoped UPDATEs plus INSERT IGNORE.
--
--  After applying: in game #repop in Lavastorm and The Plane of Knowledge
--  (or restart those zones) and #reload quest.
-- =====================================================================


-- =====================================================================
-- PART 1 - Dark Reign camp + DoN Porter -> 941, -393, 3 (v0)
-- =====================================================================

-- 1a. DoN Porter: KEPT at its original 795, 417, -45 (the spawn ldon_don_access.sql
--     created). It was briefly moved to the merchant camp, but the porter must stay
--     reachable by every faction, so it belongs at this neutral spot and not inside
--     the Dark Reign camp. Also made non-aggressive so it cannot attack a player.
UPDATE `spawn2` SET `x` = 795, `y` = 417, `z` = -45, `heading` = 0
 WHERE `id` = 910032 AND `version` = 0;                          -- don_gatekeeper_lavastorm

UPDATE `npc_types` SET `npc_aggro` = 0 WHERE `id` = 1120001415;  -- DoN_Porter

-- 1b. Dark Reign command (new-style named spawns), clustered around the porter.
UPDATE `spawn2` SET `x` = 955, `y` = -385, `z` = 3 WHERE `id` = 45000330 AND `version` = 0; -- General_Lereh_Dirr
UPDATE `spawn2` SET `x` = 962, `y` = -399, `z` = 3 WHERE `id` = 45000331 AND `version` = 0; -- Captain_Aleeth_Zyrv
UPDATE `spawn2` SET `x` = 966, `y` = -410, `z` = 3 WHERE `id` = 45000332 AND `version` = 0; -- Officer_Vacax_Rol`Tas
UPDATE `spawn2` SET `x` = 974, `y` = -395, `z` = 3 WHERE `id` = 45000333 AND `version` = 0; -- Commander_Zaerr_Ty`Dar

-- 1c. Dark Reign members that only exist as old auto-named spawns.
UPDATE `spawn2` SET `x` = 935, `y` = -405, `z` = 3 WHERE `id` = 38278 AND `version` = 0; -- Captain_Aleeth_Zyrv
UPDATE `spawn2` SET `x` = 942, `y` = -415, `z` = 3 WHERE `id` = 38279 AND `version` = 0; -- Officer_Sirrikis_Ryktor
UPDATE `spawn2` SET `x` = 985, `y` = -410, `z` = 3 WHERE `id` = 38289 AND `version` = 0; -- Xeib_Darkskies
UPDATE `spawn2` SET `x` = 940, `y` = -370, `z` = 3 WHERE `id` = 38275 AND `version` = 0; -- Celrak_Blightblood
UPDATE `spawn2` SET `x` = 930, `y` = -360, `z` = 3 WHERE `id` = 38276 AND `version` = 0; -- Daleynn_Spiritshadow (old copy)
UPDATE `spawn2` SET `x` = 945, `y` = -355, `z` = 3 WHERE `id` = 38277 AND `version` = 0; -- #Talontar
UPDATE `spawn2` SET `x` = 920, `y` = -390, `z` = 3 WHERE `id` = 45000347 AND `version` = 0; -- Daleynn_Spiritshadow


-- =====================================================================
-- PART 2 - Norrath's Keepers (npc_faction_id 1040) -> 1392, 1003, 129 (v0)
--
-- Coordinates verified against the PLAYER map (C:\Games\EQTriune\maps\lavastorm.txt,
-- whose coordinates are the negative of server coords): ground around 1392, 1003
-- runs z 118.0 .. 124.6, so z = 129 stands just above the highest ground and the
-- NPCs are visible. An earlier revision used 1318, 918 from the server's
-- nms_waypoints.h "Druid Ring" row; that row does not match the player map's
-- geometry and the faction read as off the map, so it was corrected.
--
-- The Keepers are fanned into a ~35-60 unit arc so they are not stacked on one
-- loc. Nothing else shares these positions.
-- =====================================================================

UPDATE `spawn2` SET `x` = 1382, `y` = 1003, `z` = 129, `heading` = 64  WHERE `id` = 38280 AND `version` = 0; -- Chieftain_Relae_Aderi
UPDATE `spawn2` SET `x` = 1368, `y` = 985,  `z` = 129, `heading` = 96  WHERE `id` = 45000334 AND `version` = 0;-- Private_Nylaen_Kel`Ther
UPDATE `spawn2` SET `x` = 1362, `y` = 1012, `z` = 129, `heading` = 32  WHERE `id` = 38281 AND `version` = 0; -- Keeper_Dilar_Nelune
UPDATE `spawn2` SET `x` = 1375, `y` = 1030, `z` = 129, `heading` = 448 WHERE `id` = 38282 AND `version` = 0; -- Lieutenant_Ekiltu_Verlor
UPDATE `spawn2` SET `x` = 1398, `y` = 1032, `z` = 129, `heading` = 384 WHERE `id` = 38283 AND `version` = 0; -- Captain_Areha_Burina
UPDATE `spawn2` SET `x` = 1404, `y` = 1015, `z` = 129, `heading` = 320 WHERE `id` = 38290 AND `version` = 0; -- Tatsujiro_the_Serene (merchant)

-- Two more faction-1040 v0 NPCs were parked out at y 3626-3679 on the blanket
-- z = 33 and are buried the same way. Their quest scripts live in lavastorm/old
-- and lavastorm/v1, so they are v0-active Keepers camp NPCs.
UPDATE `spawn2` SET `x` = 1412, `y` = 1025, `z` = 129, `heading` = 288 WHERE `id` = 38273 AND `version` = 0; -- #Kanetheus_Forestwalker
UPDATE `spawn2` SET `x` = 1418, `y` = 1005, `z` = 129, `heading` = 256 WHERE `id` = 38274 AND `version` = 0; -- #Gordish_Frozenheart


-- =====================================================================
-- PART 3 - Camp guard pools (v0)
--
-- Each of these spawn2 rows is one shared random pool -- 2-3 Guard/Scout NPCs
-- at 33-50% chance -- so moving the row moves the whole pool.
--   v0 Keeper pools : 38232 lavastorm216018, 38233 lavastorm216019,
--                     38350 lavastorm216136
--   v0 Dark pools   : 38252 lavastorm216038, 38253 lavastorm216039,
--                     38333 lavastorm216119
-- =====================================================================

-- Keepers Guard/Scout pools -> the same arc, ringing the named faction NPCs.
UPDATE `spawn2` SET `x` = 1392, `y` = 957,  `z` = 129, `heading` = 0   WHERE `id` = 38232 AND `version` = 0; -- Keepers Guard/Scout pool
UPDATE `spawn2` SET `x` = 1420, `y` = 981,  `z` = 129, `heading` = 320 WHERE `id` = 38233 AND `version` = 0; -- Keepers Guard/Scout pool
UPDATE `spawn2` SET `x` = 1350, `y` = 1000, `z` = 129, `heading` = 96  WHERE `id` = 38350 AND `version` = 0; -- Keepers Guard/Scout pool

-- Dark Reign Guard pools -> the merchant camp, spread on its approaches.
UPDATE `spawn2` SET `x` = 905, `y` = -370, `z` = 3, `heading` = 128 WHERE `id` = 38252 AND `version` = 0; -- Dark Reign Guard pool
UPDATE `spawn2` SET `x` = 941, `y` = -440, `z` = 3, `heading` = 0   WHERE `id` = 38253 AND `version` = 0; -- Dark Reign Guard pool
UPDATE `spawn2` SET `x` = 960, `y` = -330, `z` = 3, `heading` = 320 WHERE `id` = 38333 AND `version` = 0; -- Dark Reign Guard pool


-- =====================================================================
-- PART 4 - Crystalwing Scholar (Plane of Knowledge, zone 394 / npc 202533)
-- =====================================================================

INSERT IGNORE INTO `npc_types`
(`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `gender`,
 `texture`, `size`, `runspeed`, `aggroradius`, `attack_delay`, `trackable`,
 `show_name`, `exclude`, `flymode`, `private_corpse`, `isquest`)
VALUES
(202533, 'Crystalwing_Scholar', 'Circle of the Crystalwing', 70, 522, 1, 1, 8000, 2,
 1, 6.0, 1.25, 55, 30, 1,
 1, 1, -1, 0, 1);

INSERT IGNORE INTO `spawngroup` (`id`, `name`, `spawn_limit`, `dist`) VALUES
(60005200, 'poknowledge_crystalwing_scholar', 0, 0);

INSERT IGNORE INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES
(60005200, 202533, 100);

INSERT IGNORE INTO `spawn2`
(`id`, `spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`)
VALUES
(1201151, 60005200, 'poknowledge', 0, -154, 55, -157, 128, 640, 0, 0);


-- =====================================================================
-- PART 5 - Recover the stranded DoN merchants (v0)
-- =====================================================================

-- Voltak_Shadethorn: was -255, 3045, 38
UPDATE `spawn2` SET `x` = 920, `y` = -425, `z` = 3, `heading` = 128
 WHERE `id` = 45000345 AND `version` = 0;                        -- don_merchant_Voltak_Shadethorn

-- Wendel_Skyreach: was 535, 3665, 33
UPDATE `spawn2` SET `x` = 962, `y` = -390, `z` = 3, `heading` = 192
 WHERE `id` = 45000346 AND `version` = 0;                        -- don_merchant_Wendel_Skyreach


-- =====================================================================
-- DELIBERATELY NOT TOUCHED - the version 1 set
--
-- lavastorm_275215 (spawn2 250646) is Private_Nylaen's v1 copy. An earlier
-- revision of this file moved it to the ring because it matched on id alone;
-- it belongs to the v1 map and must not follow the v0 camp. Same for the
-- v1-only rows: 250644/250645 (#Boldger/#Bianca), 250654-250657 (v1 Dark
-- Reign command), 264696 (v1 Keeper guard pool), 264697 (v1 Dark guard pool),
-- 264281-264283/264693-264695 (v1 Wayfarers), 38222 (v1 Jenah), 38356.
--
-- Those v1 rows still carry the blanket z = 33 on ground whose real level is
-- ~ -46, so the v1 map very likely has the same buried-NPC problem. Fixing it
-- is a separate change against the v1 set -- not attempted here.
-- =====================================================================


-- =====================================================================
-- VERIFY
-- =====================================================================
-- Dark Reign + porter + merchants at the camp (expect z 3, x 902-985):
-- SELECT s2.id, s2.version, nt.name, nt.npc_faction_id, s2.x, s2.y, s2.z
--   FROM spawn2 s2 JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID
--  WHERE s2.zone='lavastorm' AND s2.version=0 AND s2.x BETWEEN 800 AND 1100
--    AND s2.y BETWEEN -600 AND -200 ORDER BY nt.name;
--
-- Norrath's Keepers (named + guard pools) at the druid ring (expect z 120):
-- SELECT s2.id, s2.version, nt.name, s2.x, s2.y, s2.z
--   FROM spawn2 s2 JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID
--  WHERE s2.zone='lavastorm' AND s2.version=0 AND nt.npc_faction_id=1040;
--
-- Nothing was left on version 1 by this file:
-- SELECT s2.id, s2.version, s2.x, s2.y, s2.z FROM spawn2 s2
--  WHERE s2.id IN (250646,264696,264697,250644,250645) ORDER BY s2.id;
--
-- poknowledge portal NPCs (expect exactly one Crystalwing Scholar and the
-- pre-existing Priest 202340 with its two original spawns):
-- SELECT s2.id, nt.id, nt.name, s2.x, s2.y, s2.z FROM spawn2 s2
--   JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID
--  WHERE s2.zone='poknowledge' AND (nt.name LIKE '%Discord%'
--     OR nt.name LIKE '%Crystalwing%' OR nt.name LIKE '%Druzzil%');


-- =====================================================================
-- ROLLBACK - original v0 positions before this script ran.
-- A full pre-change copy of the camp/porter/merchant rows is in table
-- spawn2_bak_don_pok_2026 (21 rows, created just before applying). That table
-- does NOT include the guard pools touched later in Part 3 (38232, 38233,
-- 38350, 38252, 38253, 38333) -- their pre-change positions are inline below.
-- =====================================================================
-- UPDATE `spawn2` SET `x` = 795, `y` = 417, `z` = 33, `heading` = 0   WHERE `id` = 910032 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 795, `y` = 417, `z` = 33, `heading` = 180 WHERE `id` = 45000330 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 815, `y` = 405, `z` = 33, `heading` = 200 WHERE `id` = 45000331 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 820, `y` = 400, `z` = 33, `heading` = 300 WHERE `id` = 45000332 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 840, `y` = 400, `z` = 33, `heading` = 60  WHERE `id` = 45000333 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 780, `y` = 440, `z` = 33, `heading` = 120 WHERE `id` = 45000334 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 785, `y` = 395, `z` = 33, `heading` = 0   WHERE `id` = 45000347 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 810, `y` = 410, `z` = 33, `heading` = 240 WHERE `id` = 38278 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 830, `y` = 400, `z` = 33, `heading` = 136 WHERE `id` = 38279 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 770, `y` = 440, `z` = 33, `heading` = 252 WHERE `id` = 38280 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 790, `y` = 440, `z` = 33, `heading` = 208 WHERE `id` = 38281 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 800, `y` = 440, `z` = 33, `heading` = 232 WHERE `id` = 38282 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 810, `y` = 440, `z` = 33, `heading` = 188 WHERE `id` = 38283 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 820, `y` = 440, `z` = 33, `heading` = 196 WHERE `id` = 38289 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 830, `y` = 440, `z` = 33, `heading` = 56  WHERE `id` = 38290 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 533.0, `y` = 3679.0, `z` = 33.0, `heading` = 0 WHERE `id` = 38273 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 517.0, `y` = 3626.0, `z` = 33.0, `heading` = 0 WHERE `id` = 38274 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 770, `y` = 400, `z` = 33, `heading` = 48  WHERE `id` = 38275 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 780, `y` = 400, `z` = 33, `heading` = 112 WHERE `id` = 38276 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 760, `y` = 400, `z` = 33, `heading` = 0   WHERE `id` = 38277 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 661.0,  `y` = 3220.0, `z` = 36.0,    `heading` = 176.0 WHERE `id` = 38232 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 646.0,  `y` = 3113.0, `z` = 36.875,  `heading` = 48.0  WHERE `id` = 38233 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 348.0,  `y` = 3522.5, `z` = 0.0,     `heading` = 195.0 WHERE `id` = 38350 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = -170.375, `y` = 2947.0, `z` = 37.75,  `heading` = 84.0  WHERE `id` = 38252 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = -223.0,   `y` = 2947.0, `z` = 36.625, `heading` = 28.0  WHERE `id` = 38253 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = -52.0,    `y` = 3380.0, `z` = 33.0,   `heading` = 232.0 WHERE `id` = 38333 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = -255, `y` = 3045, `z` = 38, `heading` = 0 WHERE `id` = 45000345 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 535, `y` = 3665, `z` = 33, `heading` = 0  WHERE `id` = 45000346 AND `version` = 0;
-- DELETE FROM `spawn2`     WHERE `id` = 1201151;
-- DELETE FROM `spawnentry` WHERE `spawngroupID` = 60005200;
-- DELETE FROM `spawngroup` WHERE `id` = 60005200;
-- DELETE FROM `npc_types`  WHERE `id` = 202533;
--
-- The redundant Priest of Discord (npc 202534, spawngroup 60005201, spawn2
-- 1201152) was deleted after an earlier revision added it. Its rows are
-- preserved in npc_types_bak_pok_priest_202534, spawn2_bak_pok_priest_202534,
-- spawnentry_bak_pok_priest_202534 and spawngroup_bak_pok_priest_202534 if it
-- ever needs to come back.
