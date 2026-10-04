-- =====================================================================
--  Lavastorm corrections (v0 only)
--  Triptych Triumvirate
--
--  Part 1: move every Norrath's Keepers NPC in Lavastorm to 1392, 1003, 129
--          and fan them out in an arc so they are not stacked on one loc.
--
--          Verified against the PLAYER map (C:\Games\EQTriune\maps\lavastorm.txt,
--          whose coordinates are the negative of server coords): the ground at
--          1392, 1003 sits at z ~= 118.0, so the requested 129 stands just above
--          it and is visible. The previous loc (1318-1345, 898-942, z 120) came
--          from the server's nms_waypoints.h waypoint row, which does not match
--          the player map's geometry -- that is why the faction read as
--          "off the map".
--
--  Part 2: put the DoN Porter back where ldon_don_access.sql originally placed
--          it -- 795, 417, -45 -- so it is reachable by everyone regardless of
--          faction, and make it non-aggressive so it cannot attack anyone.
--
--  v0 ONLY: every statement pins `version = 0`. See the DELIBERATELY NOT section
--  of don_camp_and_pok_ports.sql for the v1 set, which is left alone.
-- =====================================================================


-- =====================================================================
-- PART 1 - Norrath's Keepers (npc_faction_id 1040) -> 1392, 1003, 129
--
-- Named faction NPCs and their two guard/scout pools. Each guard row is one
-- shared random pool of 3 NPCs, so moving the row moves the whole pool.
-- Spread is a 35-60 unit arc to the north/west of the anchor so the NPCs do
-- not overlap each other.
-- =====================================================================

-- Named faction NPCs
UPDATE `spawn2` SET `x` = 1382, `y` = 1003, `z` = 129, `heading` = 64  WHERE `id` = 38280 AND `version` = 0; -- Chieftain_Relae_Aderi
UPDATE `spawn2` SET `x` = 1368, `y` = 985,  `z` = 129, `heading` = 96  WHERE `id` = 45000334 AND `version` = 0;-- Private_Nylaen_Kel`Ther
UPDATE `spawn2` SET `x` = 1362, `y` = 1012, `z` = 129, `heading` = 32  WHERE `id` = 38281 AND `version` = 0; -- Keeper_Dilar_Nelune
UPDATE `spawn2` SET `x` = 1375, `y` = 1030, `z` = 129, `heading` = 448 WHERE `id` = 38282 AND `version` = 0; -- Lieutenant_Ekiltu_Verlor
UPDATE `spawn2` SET `x` = 1398, `y` = 1032, `z` = 129, `heading` = 384 WHERE `id` = 38283 AND `version` = 0; -- Captain_Areha_Burina
UPDATE `spawn2` SET `x` = 1404, `y` = 1015, `z` = 129, `heading` = 320 WHERE `id` = 38290 AND `version` = 0; -- Tatsujiro_the_Serene (merchant)

-- Two more faction-1040 NPCs that were parked out at y 3626-3679
UPDATE `spawn2` SET `x` = 1412, `y` = 1025, `z` = 129, `heading` = 288 WHERE `id` = 38273 AND `version` = 0; -- #Kanetheus_Forestwalker
UPDATE `spawn2` SET `x` = 1418, `y` = 1005, `z` = 129, `heading` = 256 WHERE `id` = 38274 AND `version` = 0; -- #Gordish_Frozenheart

-- Guard / Scout pools (3 NPCs each)
UPDATE `spawn2` SET `x` = 1392, `y` = 957,  `z` = 129, `heading` = 0   WHERE `id` = 38232 AND `version` = 0; -- Keepers Guard/Scout pool
UPDATE `spawn2` SET `x` = 1420, `y` = 981,  `z` = 129, `heading` = 320 WHERE `id` = 38233 AND `version` = 0; -- Keepers Guard/Scout pool
UPDATE `spawn2` SET `x` = 1350, `y` = 1000, `z` = 129, `heading` = 96  WHERE `id` = 38350 AND `version` = 0; -- Keepers Guard/Scout pool


-- =====================================================================
-- PART 2 - DoN Porter back to the original location, non-aggressive
--
-- ldon_don_access.sql created this spawn at 795, 417, -45. Put it back there
-- so the port is reachable by any faction, and clear aggression so the porter
-- cannot attack a player who hails it.
-- =====================================================================

UPDATE `spawn2` SET `x` = 795, `y` = 417, `z` = -45, `heading` = 0
 WHERE `id` = 910032 AND `version` = 0;                          -- don_gatekeeper_lavastorm

-- npc_faction_id is already 0; npc_aggro=1 makes the porter attackable/aggro.
-- Set it passive so it never engages anyone.
UPDATE `npc_types` SET `npc_aggro` = 0 WHERE `id` = 1120001415;   -- DoN_Porter


-- =====================================================================
-- VERIFY
-- =====================================================================
-- Keepers arc around 1392, 1003, 129 (expect 8 rows + 3 guard pools):
-- SELECT s2.id, s2.version, nt.name, s2.x, s2.y, s2.z
--   FROM spawn2 s2 JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID
--  WHERE s2.zone='lavastorm' AND s2.version=0 AND s2.x BETWEEN 1300 AND 1470
--  ORDER BY s2.x;
--
-- Porter back at 795, 417 and passive:
-- SELECT s2.id, nt.name, nt.npc_faction_id, nt.npc_aggro, s2.x, s2.y, s2.z
--   FROM spawn2 s2 JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID WHERE s2.id=910032;


-- =====================================================================
-- ROLLBACK - pre-change values for this script's rows.
-- =====================================================================
-- UPDATE `spawn2` SET `x` = 1322, `y` = 926,  `z` = 120, `heading` = 270 WHERE `id` = 38280 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1300, `y` = 924,  `z` = 120, `heading` = 180 WHERE `id` = 45000334 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1292, `y` = 908,  `z` = 120, `heading` = 128 WHERE `id` = 38281 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1306, `y` = 898,  `z` = 120, `heading` = 64  WHERE `id` = 38282 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1332, `y` = 902,  `z` = 120, `heading` = 384 WHERE `id` = 38283 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1340, `y` = 920,  `z` = 120, `heading` = 320 WHERE `id` = 38290 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1338, `y` = 932,  `z` = 120, `heading` = 320 WHERE `id` = 38273 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1345, `y` = 915,  `z` = 120, `heading` = 384 WHERE `id` = 38274 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1310, `y` = 942,  `z` = 120, `heading` = 448 WHERE `id` = 38232 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1330, `y` = 938,  `z` = 120, `heading` = 320 WHERE `id` = 38233 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 1281, `y` = 922,  `z` = 120, `heading` = 128 WHERE `id` = 38350 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 941, `y` = -393, `z` = 3,   `heading` = 128 WHERE `id` = 910032 AND `version` = 0;
-- UPDATE `npc_types` SET `npc_aggro` = 1 WHERE `id` = 1120001415;
