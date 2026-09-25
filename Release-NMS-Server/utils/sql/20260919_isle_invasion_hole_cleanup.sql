-- 20260919_isle_invasion_hole_cleanup.sql
--
-- Fix: DoN Thundercrest "Isle" mobs leaking into The Hole (zone 'hole').
--
-- Root cause: the B7 additive spawn sync collided upstream spawngroup ids
-- 288058-288062 (upstream = thundercrest_288058..288062, DoN Thundercrest Isle
-- mobs) with pre-existing local Hole groups of the same ids
-- (hole-Master_Yael000, hole-elem000, hole-elemm000, hole-elemmpat000,
-- hole-pat000). The upstream spawngroup rows were never inserted, so the Isle
-- spawnentry rows landed in the local Hole groups and the Thundercrest spawn2
-- (264688-264692) were pointed at those Hole groups.
--
-- Fix: move the 5 custom Hole groups to fresh ids (60006101-60006105), keep
-- their native NPCs, and hand ids 288058-288062 back to the canonical
-- Thundercrest groups (matching upstream PEQ). Thundercrest spawn2
-- 264688-264692 already reference 288058-288062, so they become correct with no
-- spawn2 change.
--
-- Same collision class as docs/dirtdigger-invasion-leak-2026-09.md.
-- Repop after applying:  #repop hole   and   #repop thundercrest
--
-- Safety snapshots: spawngroup_bak_20260919_isle, spawnentry_bak_20260919_isle,
--                   spawn2_bak_20260919_isle

SET NAMES utf8mb4;

DROP TABLE IF EXISTS spawngroup_bak_20260919_isle;
CREATE TABLE spawngroup_bak_20260919_isle AS
  SELECT * FROM spawngroup WHERE id IN (288058,288059,288060,288061,288062);
DROP TABLE IF EXISTS spawnentry_bak_20260919_isle;
CREATE TABLE spawnentry_bak_20260919_isle AS
  SELECT * FROM spawnentry WHERE spawngroupID IN (288058,288059,288060,288061,288062);
DROP TABLE IF EXISTS spawn2_bak_20260919_isle;
CREATE TABLE spawn2_bak_20260919_isle AS
  SELECT * FROM spawn2 WHERE id IN (2140683,2140684,2140685,2140686,2140687,264688,264689,264690,264691,264692);

START TRANSACTION;

-- 1) Free the collided names and hand the ids to the canonical Thundercrest groups.
UPDATE spawngroup SET name='thundercrest_288058' WHERE id=288058;
UPDATE spawngroup SET name='thundercrest_288059' WHERE id=288059;
UPDATE spawngroup SET name='thundercrest_288060' WHERE id=288060;
UPDATE spawngroup SET name='thundercrest_288061' WHERE id=288061;
UPDATE spawngroup SET name='thundercrest_288062' WHERE id=288062;

-- 2) Recreate the custom Hole groups under fresh ids (names preserved).
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
 (60006101,'hole-Master_Yael000',0,0,0,0,0,0,45000,15000,0,100,0),
 (60006102,'hole-elem000',0,0,0,0,0,0,45000,15000,0,100,0),
 (60006103,'hole-elemm000',0,0,0,0,0,0,45000,15000,0,100,0),
 (60006104,'hole-elemmpat000',0,0,0,0,0,0,45000,15000,0,100,0),
 (60006105,'hole-pat000',0,0,0,0,0,0,45000,15000,0,100,0);

-- 3) Hole-native spawnentry on the new ids (restores Master Yael + elementals).
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance,condition_value_filter,min_time,max_time,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (60006101,2000382,50,1,0,0,-1,-1,NULL,NULL),
 (60006102,39001,50,1,0,0,-1,-1,NULL,NULL),
 (60006103,39009,50,1,0,0,-1,-1,NULL,NULL),
 (60006104,39139,50,1,0,0,-1,-1,NULL,NULL),
 (60006105,39140,50,1,0,0,-1,-1,NULL,NULL);

-- 4) Repoint the Hole spawn2 at the new ids.
UPDATE spawn2 SET spawngroupID=60006101 WHERE id=2140683;
UPDATE spawn2 SET spawngroupID=60006102 WHERE id=2140684;
UPDATE spawn2 SET spawngroupID=60006103 WHERE id=2140685;
UPDATE spawn2 SET spawngroupID=60006104 WHERE id=2140686;
UPDATE spawn2 SET spawngroupID=60006105 WHERE id=2140687;

-- 5) Reset spawnentry at 288058-288062 to the canonical Thundercrest Isle set.
DELETE FROM spawnentry WHERE spawngroupID IN (288058,288059,288060,288061,288062);
INSERT INTO spawnentry (spawngroupID,npcID,chance,condition_value_filter,min_time,max_time,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (288058,340435,22,1,0,0,-1,-1,NULL,NULL),
 (288058,340443,50,1,0,0,-1,-1,NULL,NULL),
 (288058,340448,12,1,0,0,-1,-1,NULL,NULL),
 (288058,340473,16,1,0,0,-1,-1,NULL,NULL),
 (288059,340013,100,1,0,0,-1,-1,NULL,NULL),
 (288060,340435,14,1,0,0,-1,-1,NULL,NULL),
 (288060,340443,71,1,0,0,-1,-1,NULL,NULL),
 (288060,340447,8,1,0,0,-1,-1,NULL,NULL),
 (288060,340448,7,1,0,0,-1,-1,NULL,NULL),
 (288061,340443,80,1,0,0,-1,-1,NULL,NULL),
 (288061,340448,20,1,0,0,-1,-1,NULL,NULL),
 (288062,340526,100,1,0,0,-1,-1,NULL,NULL);

COMMIT;
