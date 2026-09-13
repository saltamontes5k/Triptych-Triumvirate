-- ============================================================================
-- LDoN / DoN access fixes
-- ----------------------------------------------------------------------------
-- 1. nro / sro "Wayfarer Porter" gatekeepers: port proven adventurers to the
--    North Ro / South Ro (3.0) LDoN camps. Gated on the DoN stage (the five
--    elemental gods) by the quest scripts via nms_progression.gate_stage.
-- 2. lavastorm "DoN Porter": ports proven adventurers to the Broodlands, since
--    the base client map has no DoN-era Lavastorm camp shelf / Broodlands line.
-- 3. Relocate the Dark Reign camp NPCs (27089-27110) from y 3000-3750 (off the
--    base map) to valid ground around the lavastorm porter.
--
-- Gatekeeper npc_types are cloned from Brunnel_Kegstander (27078). Idempotent:
-- INSERT IGNORE; the relocation UPDATEs are safe to re-run.
-- ============================================================================

-- Wayfarer Porter (nro) 1120001413
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 27078;
UPDATE tmp_npc SET id = 1120001413, name = 'Wayfarer_Porter', lastname = 'North Ro';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- Wayfarer Porter (sro) 1120001414
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 27078;
UPDATE tmp_npc SET id = 1120001414, name = 'Wayfarer_Porter', lastname = 'South Ro';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- DoN Porter (lavastorm) 1120001415
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 27078;
UPDATE tmp_npc SET id = 1120001415, name = 'DoN_Porter', lastname = 'The Broodlands';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_npc;

-- Gatekeeper spawns
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910030,'ldon_gatekeeper_nro',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910030,1120001413,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910030,910030,'nro',0,880,2660,-25,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910031,'ldon_gatekeeper_sro',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910031,1120001414,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910031,910031,'sro',0,286,1265,79,0,640,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (910032,'don_gatekeeper_lavastorm',0,0,0,0,0,0,0,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES (910032,1120001415,100);
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES (910032,910032,'lavastorm',0,795,417,-45,0,640,0);

-- Relocate the Dark Reign camp onto valid ground around the DoN Porter (795,417)
UPDATE spawn2 SET x=760, y=400, z=-46 WHERE id=38277;   -- #Talontar
UPDATE spawn2 SET x=770, y=400, z=-46 WHERE id=38275;   -- Celrak_Blightblood
UPDATE spawn2 SET x=780, y=400, z=-46 WHERE id=38276;   -- Daleynn_Spiritshadow
UPDATE spawn2 SET x=785, y=395, z=-46 WHERE id=45000347;-- Daleynn_Spiritshadow
UPDATE spawn2 SET x=795, y=417, z=-45 WHERE id=45000330;-- General_Lereh_Dirr
UPDATE spawn2 SET x=810, y=410, z=-46 WHERE id=38278;   -- Captain_Aleeth_Zyrv
UPDATE spawn2 SET x=815, y=405, z=-46 WHERE id=45000331;-- Captain_Aleeth_Zyrv
UPDATE spawn2 SET x=820, y=400, z=-46 WHERE id=45000332;-- Officer_Vacax_Rol`Tas
UPDATE spawn2 SET x=830, y=400, z=-46 WHERE id=38279;   -- Officer_Sirrikis_Ryktor
UPDATE spawn2 SET x=840, y=400, z=-46 WHERE id=45000333;-- Commander_Zaerr_Ty`Dar
UPDATE spawn2 SET x=770, y=440, z=-46 WHERE id=38280;   -- Chieftain_Relae_Aderi
UPDATE spawn2 SET x=780, y=440, z=-46 WHERE id=45000334;-- Private_Nylaen_Kel`Ther
UPDATE spawn2 SET x=790, y=440, z=-46 WHERE id=38281;   -- Keeper_Dilar_Nelune
UPDATE spawn2 SET x=800, y=440, z=-46 WHERE id=38282;   -- Lieutenant_Ekiltu_Verlor
UPDATE spawn2 SET x=810, y=440, z=-46 WHERE id=38283;   -- Captain_Areha_Burina
UPDATE spawn2 SET x=820, y=440, z=-46 WHERE id=38289;   -- Xeib_Darkskies
UPDATE spawn2 SET x=830, y=440, z=-46 WHERE id=38290;   -- Tatsujiro_the_Serene
