-- 20261101_umbral_keymaster_cleanup.sql
-- Retire the inert umbral #Keymaster prop (npc_types 176110, spawn2 57829,
-- spawngroup 47317). It has no quest script in any quest tree (umbral folder,
-- runtime copies, git grep) - it is an invulnerable race-224 prop (99M hp,
-- special_abilities 19/20/21/24) that teleports nobody. Vex Thal entry is
-- already native: door UMDOOR301 (doors 8917, doorid 1, opentype 58, keyitem
-- 22198 Scepter of Shadows) teleports to vexthal with server-side key
-- enforcement (doors.cpp HandleClick), and walk-in zone_point 45 sits behind
-- the gate (-750,-1912,150 -> vexthal). The prop just stands in front of it.
-- Side finding (flagged, NOT changed): 22198 is unobtainable on EQS (no quest
-- refs, no lootdrop rows) - VT is GM-only entry today.
-- Deliberately NOT touched: bothunder porter NPCs (1120001034,
-- 1120001055-1068). Unlike this prop they are load-bearing: stock zone_points
-- 983-1006 there all carry target_instance=0, so inside an instanced BoT the
-- client pad lines would ZoneToZone players into static BoT; the porters'
-- MovePCInstance is the only instance-preserving pad and bothunder/player.lua
-- (Agnarr doors 51/61/63/65/67) is explicitly instance-aware.
-- Twin: database_update_manifest_custom.cpp entry v301 (keep in sync).
SET NAMES utf8mb4;
START TRANSACTION;

DELETE FROM `spawn2` WHERE `id` = 57829 AND `zone` = 'umbral';
DELETE FROM `spawnentry` WHERE `spawngroupID` = 47317;
DELETE FROM `spawngroup` WHERE `id` = 47317;
DELETE FROM `npc_types` WHERE `id` = 176110;

COMMIT;
