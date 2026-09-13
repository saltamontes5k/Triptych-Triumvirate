-- ============================================================================
-- Omens of War — missing NPCs referenced by ProjectEQ quest/raid scripts
-- ----------------------------------------------------------------------------
-- Audit (2026-09-10) found 7 npc_types referenced by the Omens of War quest
-- scripts under Release-NMS-Server/Build/bin/Release/quests that are absent
-- from the database. Their spawn2/unique_spawn calls therefore silently fail:
--
--   300104  a_broken_egg          spawned by wallofslaughter/a_quivering_egg.lua
--   301084  gaz_controller        encounter controller for bloodfields/gaz
--   301085  Girplan_Lacerator     spawned by bloodfields/Girplan_Slasher.lua
--   317123  Coerced_Lieutenant    second spawn used by anguish/encounters/omm.lua
--   336127  battlemaster_controller  encounter controller for dranik/battlemaster
--   336128  tiorpat_controller    controller for dranik/tiorpat (currently unused)
--   336129  a_Dragorn_Protector   spawned by dranik/Lirah_the_Bridgekeeper.lua
--
-- Each missing npc_type is cloned from the closest existing NPC in the same
-- zone/family, then re-keyed. The three controllers are also given a static
-- spawn so their encounter scripts load (their Controller_Spawn logic places
-- the actual event NPCs at fixed coordinates, so the controller's own position
-- is irrelevant). Idempotent: safe to re-run.
-- ============================================================================

-- a_broken_egg (300104) <- a_quivering_egg (300083)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 300083;
UPDATE tmp_npc SET id = 300104, name = 'a_broken_egg';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- Girplan_Lacerator (301085) <- Girplan_Slasher (301027)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 301027;
UPDATE tmp_npc SET id = 301085, name = 'Girplan_Lacerator';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- Coerced_Lieutenant (317123) <- Coerced_Lieutenant (317114)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 317114;
UPDATE tmp_npc SET id = 317123;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- a_Dragorn_Protector (336129) <- a_Dragorn_Protector (336011)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 336011;
UPDATE tmp_npc SET id = 336129;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- Encounter controllers <- #Event_Controller (343392)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 343392;
UPDATE tmp_npc SET id = 301084, name = 'gaz_controller', hp = 1, maxlevel = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 343392;
UPDATE tmp_npc SET id = 336127, name = 'battlemaster_controller', hp = 1, maxlevel = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 343392;
UPDATE tmp_npc SET id = 336128, name = 'tiorpat_controller', hp = 1, maxlevel = 1;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_npc;

-- Static spawns so the gaz / battlemaster encounters load on zone boot.
-- spawngroup / spawn2 use fixed high ids for idempotency.

-- gaz_controller (301084) in bloodfields
INSERT IGNORE INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
  VALUES (900084, 'oow_gaz_controller', 1, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0);
INSERT IGNORE INTO spawnentry (spawngroupID, npcID, chance) VALUES (900084, 301084, 100);
INSERT IGNORE INTO spawn2 (id, spawngroupID, zone, version, x, y, z, heading, respawntime, variance)
  VALUES (900084, 900084, 'bloodfields', 0, 677, -419, -816, 0, 1800, 0);

-- battlemaster_controller (336127) in dranik
INSERT IGNORE INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
  VALUES (900127, 'oow_battlemaster_controller', 1, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0);
INSERT IGNORE INTO spawnentry (spawngroupID, npcID, chance) VALUES (900127, 336127, 100);
INSERT IGNORE INTO spawn2 (id, spawngroupID, zone, version, x, y, z, heading, respawntime, variance)
  VALUES (900127, 900127, 'dranik', 0, 1678, 2778, -24.97, 0, 5400, 0);
