-- ============================================================================
-- Bazaar progression flag NPCs (DoD / PoR / TSS / TBS / SoF / SoD)
-- ----------------------------------------------------------------------------
-- Six expansion progression-check NPCs in the bazaar, modeled after the
-- existing flag NPCs (A_Lost_Iksar 12000154, Coldain_Messenger 12000156,
-- A_Knight_of_Luclin 12000157, A_Planar_Projection 12000158). Hero-path
-- checkers: hail reports access state, [hero] lists kill prerequisites via
-- plugins/NMS_progression_utils.pl.
--
--   12000205 Shillskin_Herald          DoD  (shiliskin, -26,-782,26)
--   12000206 Emissary_of_Druzzil_Ro    PoR  (scrykin,   -28,-788,26)
--   12000207 Crystalwing_Scholar       TSS  (drakkin,   -34,-774,30)
--   12000208 Lost_Pirate               TBS  (pirate,    -17,-776,26)
--   12000209 Rebel_Clockwork           SoF  (clockwork,  -4,-775,26)
--   12000210 Orcish_Adventurer         SoD  (orc,        -3,-692,26)
--
-- npc_types are cloned from A_Knight_of_Luclin (12000157); only id, name,
-- lastname and race change. Idempotent: INSERT IGNORE throughout. All ids
-- verified unused at time of writing (npc_types 12000205-12000210,
-- spawngroup 5003836-5003841, spawn2 2141200-2141205).
-- ============================================================================

-- Shillskin_Herald (DoD) 12000205
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 12000157;
UPDATE tmp_npc SET id = 12000205, name = 'Shillskin_Herald', lastname = 'Depths of Darkhollow', race = 467;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- Emissary_of_Druzzil_Ro (PoR) 12000206
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 12000157;
UPDATE tmp_npc SET id = 12000206, name = 'Emissary_of_Druzzil_Ro', lastname = 'Prophecy of Ro', race = 495;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- Crystalwing_Scholar (TSS) 12000207
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 12000157;
UPDATE tmp_npc SET id = 12000207, name = 'Crystalwing_Scholar', lastname = "The Serpent's Spine", race = 522;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- Lost_Pirate (TBS) 12000208
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 12000157;
UPDATE tmp_npc SET id = 12000208, name = 'Lost_Pirate', lastname = 'The Buried Sea', race = 566;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- Rebel_Clockwork (SoF) 12000209
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 12000157;
UPDATE tmp_npc SET id = 12000209, name = 'Rebel_Clockwork', lastname = 'Secrets of Faydwer', race = 88;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

-- Orcish_Adventurer (SoD) 12000210
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 12000157;
UPDATE tmp_npc SET id = 12000210, name = 'Orcish_Adventurer', lastname = 'Seeds of Destruction', race = 54;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;

DROP TEMPORARY TABLE IF EXISTS tmp_npc;

-- Spawn groups (bazaar flag NPC convention: delay 45000, mindelay 15000)
INSERT IGNORE INTO spawngroup
(id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
(5003836,'bazaar-Shillskin_Herald000',0,0,0,0,0,0,45000,15000,0,100,0),
(5003837,'bazaar-Emissary_of_Druzzil_Ro000',0,0,0,0,0,0,45000,15000,0,100,0),
(5003838,'bazaar-Crystalwing_Scholar000',0,0,0,0,0,0,45000,15000,0,100,0),
(5003839,'bazaar-Lost_Pirate000',0,0,0,0,0,0,45000,15000,0,100,0),
(5003840,'bazaar-Rebel_Clockwork000',0,0,0,0,0,0,45000,15000,0,100,0),
(5003841,'bazaar-Orcish_Adventurer000',0,0,0,0,0,0,45000,15000,0,100,0);

-- Spawn entries (chance 50, matching the existing flag NPCs)
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES
(5003836,12000205,50),
(5003837,12000206,50),
(5003838,12000207,50),
(5003839,12000208,50),
(5003840,12000209,50),
(5003841,12000210,50);

-- Spawn points (respawn 1200s, no variance -- matches existing flag NPCs)
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance) VALUES
(2141200,5003836,'bazaar',0,-26,-782,26,250,1200,0),
(2141201,5003837,'bazaar',0,-28,-788,26,250,1200,0),
(2141202,5003838,'bazaar',0,-34,-774,30,250,1200,0),
(2141203,5003839,'bazaar',0,-17,-776,26,250,1200,0),
(2141204,5003840,'bazaar',0,-4,-775,26,250,1200,0),
(2141205,5003841,'bazaar',0,-3,-692,26,250,1200,0);
