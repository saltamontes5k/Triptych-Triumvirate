-- ============================================================================
-- Progression spoiler NPC - Librarian of Lost Ages (Plane of Knowledge)
-- ----------------------------------------------------------------------------
-- One in-game guide NPC that explains, per expansion from PoP onward, how each
-- access flag is earned (kill chains, the PoP flag web, access tasks) with
-- live per-account flag status. READ-ONLY: the NPC never grants or sets any
-- flag; every line of its dialogue is sourced from the quest scripts that
-- enforce the gates (sources listed in the .pl header).
--
-- Quest script: Release-NMS-Quests/poknowledge/Librarian_of_Lost_Ages.pl
-- Spawned beside the Seer (npc 202006, poknowledge -225,-43,-156).
--
-- npc_types cloned from A_Knight_of_Luclin (12000157), race set to high elf.
-- Idempotent: INSERT IGNORE throughout. Ids verified unused at time of
-- writing (npc_types 12000211, spawngroup 5003842, spawn2 2141210).
--
-- Twin of ManifestEntry .version = 293 in
-- common/database/database_update_manifest_custom.cpp (keep in sync).
-- Rollback:
--   DELETE FROM spawn2 WHERE id = 2141210;
--   DELETE FROM spawnentry WHERE spawngroupID = 5003842;
--   DELETE FROM spawngroup WHERE id = 5003842;
--   DELETE FROM npc_types WHERE id = 12000211;
-- ============================================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- Librarian_of_Lost_Ages (12000211)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 12000157;
UPDATE tmp_npc SET id = 12000211, name = 'Librarian_of_Lost_Ages', lastname = 'Keeper of the Paths', race = 3;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_npc;

-- Spawn group (flag-NPC convention: delay 45000, mindelay 15000)
INSERT IGNORE INTO spawngroup
(id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
(5003842,'poknowledge-Librarian_of_Lost_Ages000',0,0,0,0,0,0,45000,15000,0,100,0);

-- Spawn entry (chance 100: the Librarian is a fixture, not a rare)
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES
(5003842,12000211,100);

-- Spawn point: beside Seer_Mal_Nae`Shi (-225,-43,-156) in poknowledge
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES
(2141210,5003842,'poknowledge',0,-214,-36,-156.125,128,1200,0);

COMMIT;
