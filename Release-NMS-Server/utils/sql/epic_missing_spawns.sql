-- ============================================================================
-- Epic quest NPCs — missing static spawns
-- ----------------------------------------------------------------------------
-- Audit (2026-09-10) found epic 1.5/2.0 quest NPCs and required named mobs that
-- exist in npc_types but have no spawn2/spawnentry row anywhere, are never
-- script-spawned, and are never spell-summoned. Their steps are therefore
-- unreachable. Each is placed at its documented location (guide/zone data).
--
--   Dry Sapara (91092)              Paladin 1.5/2.0   skyfire     near VP zone-in
--   Eryke Stremstin (151053)        Monk epic         bazaar      -402, +146
--   Red Dogwood Treant (181222)     Ranger 1.5        jaggedpine  Fertile Earth
--   corrupted_spirit (47209)        Druid 1.5         feerrott    bridge area
--   Bantil Io`Tuv (202328)          Magician epic     poknowledge library 4F
--   Julei Direaxe (39167)           Berserker epic    hole        castle room
--   Discord Fluctuation (336241)    Necromancer epic  dranik      NE room
--   an ancient necromantic shade (163052)  Berserker epic  griegsend  SE end
--   a shrouded minion (163051)      Berserker epic    griegsend   with shade
--
-- REVISION (2026-09-12): the original fix used ids 910001-910009, but the PoR
-- content pass re-used that same range (Sullon Zek, Suchun, Druzzil Ro shrine,
-- Prince Taksalir, Dryad of Tunare, freeport Arena, ...), silently clobbering
-- this restore: skyfire/bazaar/jaggedpine/feerrott/poknowledge/hole lost their
-- whole spawngroup+spawn2, and dranik/griegsend lost their spawn2 rows while
-- keeping the (now orphaned) spawngroup/entry. natimbi/sirens/umbral were
-- unaffected and are not re-issued here. This revision uses the fresh, free
-- id range 912001-912009 so it can be re-applied after any reimport.
--
-- Idempotent: INSERT IGNORE, fixed high ids (912001-912009). NPCs already exist
-- in npc_types; no npc_types changes are made. Entries 912001-912006 create new
-- spawngroup+spawnentry+spawn2; entries 912007-912009 only add a spawn2 row for
-- the existing epic groups 910007-910009 that lost their spawn point.
-- ============================================================================

-- 1) Dry Sapara (91092) — skyfire, near the Veeshan's Peak zone-in
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (912001,'oow_epic_dry_sapara',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (912001,91092,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (912001,912001,'skyfire',0,3045,2662,-77.8,0,640,0);

-- 2) Eryke Stremstin (151053) — bazaar
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (912002,'oow_epic_eryke_stremstin',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (912002,151053,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (912002,912002,'bazaar',0,-402,146,-28,0,640,0);

-- 3) Red Dogwood Treant (181222) — jaggedpine, at the Fertile Earth combine spot
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (912003,'oow_epic_red_dogwood_treant',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (912003,181222,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (912003,912003,'jaggedpine',0,-960,1380,-14.4,0,640,0);

-- 4) corrupted_spirit (47209) — feerrott, near the bridge (-375,-155)
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (912004,'oow_epic_corrupted_spirit',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (912004,47209,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (912004,912004,'feerrott',0,-375,-155,-16,0,640,0);

-- 5) Bantil Io`Tuv (202328) — Plane of Knowledge, library 4th floor
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (912005,'oow_epic_bantil_iotuv',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (912005,202328,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (912005,912005,'poknowledge',0,115,995,95,0,640,0);

-- 6) Julei Direaxe (39167) — The Hole, castle room behind the underwater tunnel
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (912006,'oow_epic_julei_direaxe',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (912006,39167,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (912006,912006,'hole',0,496,-224,-217,0,640,0);

-- 7) Discord Fluctuation (336241) — Ruined City of Dranik, NE room (adds spawn ~150,2362,118.5).
--     spawngroup 910007 + entry survive; only the spawn2 point was lost.
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (912007,910007,'dranik',0,150,2362,118.5,0,640,0);

-- 8) an ancient necromantic shade (163052) — Grieg's End, southeastern end.
--     spawngroup 910008 + entry survive; only the spawn2 point was lost.
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (912008,910008,'griegsend',0,-627,1785,-69,0,640,0);

-- 9) a shrouded minion (163051) — Grieg's End, with the shade.
--     spawngroup 910009 + entry survive; only the spawn2 point was lost.
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (912009,910009,'griegsend',0,-627,1785,-69,0,640,0);