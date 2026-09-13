-- ============================================================================
-- Vrabbit Xloren (108052) — missing static spawn
-- ----------------------------------------------------------------------------
-- Audit (2026-09-12) found npc_types 108052 'Vrabbit_Xloren' (Level 70,
-- drake, warrior, faction 394 Veeshan's Peak General) exists but has no
-- spawnentry/spawn2 row anywhere, is never script-spawned, and is never
-- spell-summoned. He is the "Proof for Phara Dar" quest NPC ("This door
-- behind me is sealed with a powerful ward, only Phara herself can remove"),
-- so his step is unreachable until he spawns.
--
-- Placement: the corridor southwest of Phara Dar's chamber leading up to her
-- sealed lair door, south of the existing corridor trash points at
-- (-1136.5,-999.9) / (-1190,-1003.8). Version 0 (classic zone). Static
-- respawn (640s, 0 variance) so the quest giver is reliably up, matching
-- the misc-missing-spawn patches. Heading faces the approach corridor.
--
-- Idempotent: INSERT IGNORE, fixed high ids from the live auto_increment
-- watermarks (next free spawngroup 60005254, spawn2 45000702). No npc_types
-- changes. Re-apply verbatim after any reimport.
-- ============================================================================

BEGIN;

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (60005254,'veeshan_vrabbit_xloren',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (60005254,108052,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,path_when_zone_idle,_condition,cond_value,animation,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES (45000702,60005254,'veeshan',0,-1156.0,-1047.0,292.38,30.0,640,0,0,0,0,1,0,-1,-1,NULL,NULL);

COMMIT;