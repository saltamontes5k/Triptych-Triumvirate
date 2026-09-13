-- ============================================================================
-- Echo of the Past — custom-instance NPCs for OoW static zones + GoD hub cities
-- ----------------------------------------------------------------------------
-- global/Echo_of_the_Past.pl offers a private instance of its own zone via
-- plugin::OfferStandardInstance: Respawning/Farming (Custom:FarmingInstanceVersion)
-- or Non-Respawning/Static (Custom:StaticInstanceVersion). It spawns only in the
-- base zone (depops when instance version > 0), so it belongs in static zones.
--
-- GoD's 9 static combat zones already have one. This adds the missing ones:
--   OoW static zones : draniksscar, wallofslaughter, causeway, bloodfields,
--                      dranik, provinggrounds, riftseekers, harbingers
--   GoD hub cities   : abysmal, nedaria
-- Excluded (expedition-only, redundant): anguish and the instance-only zones
-- (chambersa-f, dranikcatacombs*, dranikhollows*, draniksewers*).
--
-- Each npc_types row is cloned from the GoD donor Echo (1120001116) and re-keyed
-- with a zone lastname, matching the existing convention. Placed at each zone's
-- safe point. Idempotent: INSERT IGNORE, fixed ids 1120001403-1120001412 /
-- spawngroup+spawn2 910020-910029.
-- ============================================================================

-- draniksscar (1120001403)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001403, lastname = 'Draniksscar';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- wallofslaughter (1120001404)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001404, lastname = 'Wallofslaughter';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- causeway (1120001405)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001405, lastname = 'Causeway';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- bloodfields (1120001406)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001406, lastname = 'Bloodfields';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- dranik (1120001407)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001407, lastname = 'Dranik';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- provinggrounds (1120001408)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001408, lastname = 'Provinggrounds';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- riftseekers (1120001409)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001409, lastname = 'Riftseekers';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- harbingers (1120001410)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001410, lastname = 'Harbingers';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- abysmal (1120001411)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001411, lastname = 'Abysmal';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- nedaria (1120001412)
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 1120001116;
UPDATE tmp_npc SET id = 1120001412, lastname = 'Nedaria';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_npc;

-- Static spawns at each zone's safe point.
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910020,'oow_echo_draniksscar',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910020,1120001403,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910020,910020,'draniksscar',0,-1468,-1519,260,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910021,'oow_echo_wallofslaughter',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910021,1120001404,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910021,910021,'wallofslaughter',0,-1461,-2263,-69,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910022,'oow_echo_causeway',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910022,1120001405,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910022,910022,'causeway',0,-239,-1674,317,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910023,'oow_echo_bloodfields',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910023,1120001406,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910023,910023,'bloodfields',0,-1763,2140,-928,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910024,'oow_echo_dranik',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910024,1120001407,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910024,910024,'dranik',0,-1112,-1953,-369,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910025,'oow_echo_provinggrounds',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910025,1120001408,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910025,910025,'provinggrounds',0,-124,-5676,-306,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910026,'oow_echo_riftseekers',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910026,1120001409,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910026,910026,'riftseekers',0,-1,297,-208,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910027,'oow_echo_harbingers',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910027,1120001410,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910027,910027,'harbingers',0,122,-98,10,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910028,'oow_echo_abysmal',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910028,1120001411,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910028,910028,'abysmal',0,0,-199,140,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910029,'oow_echo_nedaria',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910029,1120001412,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910029,910029,'nedaria',0,-1737,-181,256,0,640,0);
