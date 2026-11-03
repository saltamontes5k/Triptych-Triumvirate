-- ============================================================================
-- NMS arcade: Master_of_Games host NPC (Bazaar)
-- ----------------------------------------------------------------------------
-- The arcade feature (script-drawn NMS windows + the arcade.lua /
-- NMS_arcade.pl game library, engine in zone/nms_window.h) needs a host NPC.
-- This adds one "Master of Games" to the Bazaar, a few steps from the
-- Platinum Arcade gambling halfling (1120001081 at -232,-830), which keeps
-- the games corner in one place.
--
-- npc_types 1120002560 was verified unused at time of writing (custom band
-- max 1120002558). Row cloned from the Platinum Arcade halfling for the
-- halfling race/model, then stripped to a clean quest NPC: no loot, no
-- merchant, no faction, no spells, aggroradius 0.
--
-- Spawn: spawngroup 1520009310 / spawn2 1520028510 (both verified unused),
-- bazaar at -215,-815,z3.227 heading 200 (z taken from the neighbor spawn).
-- Custom bands verified: spawngroup max 1520009308, spawn2 max 1520028494.
--
-- The quest script is Release-NMS-Quests/bazaar/Master_of_Games.pl (Perl):
-- EVENT_SAY lists games via plugin::arcade_npc, EVENT_TIMER drives the
-- 20-tick clock, EVENT_NMS_WINDOW routes window events into the library.
--
-- Idempotent: INSERT IGNORE everywhere.
--
-- Twin of ManifestEntry .version = 312 in
-- common/database/database_update_manifest_custom.cpp (keep in sync).
-- Rollback:
--   DELETE FROM spawn2 WHERE id = 1520028510;
--   DELETE FROM spawnentry WHERE spawngroupID = 1520009310;
--   DELETE FROM spawngroup WHERE id = 1520009310;
--   DELETE FROM npc_types WHERE id = 1120002560;
-- ============================================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- Master_of_Games (1120002560)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001081;
UPDATE tmp_npc SET id = 1120002560, name = 'Master_of_Games', lastname = 'Keeper of the Arcade',
	level = 75, hp = 30000, mana = 0,
	loottable_id = 0, merchant_id = 0, greed = 0, alt_currency_id = 0,
	npc_spells_id = 0, npc_spells_effects_id = 0, npc_faction_id = 0,
	aggroradius = 0, see_invis = 1, raid_target = 0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_npc;

-- spawn point beside the Platinum Arcade
INSERT IGNORE INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay)
VALUES (1520009310, 'bazaar_master_of_games', 1, 0, 0, 0, 0, 0, 15000);
INSERT IGNORE INTO spawnentry (spawngroupID, npcID, chance)
VALUES (1520009310, 1120002560, 100);
INSERT IGNORE INTO spawn2 (id, spawngroupID, zone, version, x, y, z, heading, respawntime, _condition, cond_value, min_expansion, max_expansion)
VALUES (1520028510, 1520009310, 'bazaar', 0, -215.0, -815.0, 3.227, 200.0, 1200, 0, 0, -1, -1);

COMMIT;
