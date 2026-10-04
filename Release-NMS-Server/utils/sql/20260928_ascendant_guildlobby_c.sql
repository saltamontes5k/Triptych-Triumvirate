-- ============================================================================
-- Ascendant Guild Lobby v1 (self-contained NPCs)
-- Ports (adapted for Triptych/EQS):
--   Chronicler_Elodin, Kilven_the_Quartermaster, Ben_Affactor,
--   the_temporary_reprieve, A_Dust_Covered_Wayfarer
-- Source: Ascendant-EQ-Emu/Ascendant-Server @ main
--
--   * npc_types rows cloned from local NPC 344025 (human template) and
--     re-applied with each NPC's race/appearance; spawned at Ascendant's v0
--     guildlobby coordinates.
--   * Ben Affactor needs the philanthropist tables from
--     plugins/ascendant_philanthropist.pl.
--   * the_temporary_reprieve uses Gold Token (alt currency 17 / item 43943),
--     which already exists locally.
--   * A_Dust_Covered_Wayfarer is adapted to accept the local LDoN spore tokens
--     (items 56977-56991) instead of the Ascendant relic 9544 (which collides
--     with a live PEQ item), and no longer rewrites zone expansion gating.
--
-- Idempotent. Rollback: 20260928_ascendant_guildlobby_c_rollback.sql
-- ============================================================================
SET NAMES utf8mb4;

-- ---- Philanthropist tables (ascendant_philanthropist.pl) ----
CREATE TABLE IF NOT EXISTS philanthropist_pool (
  id INT NOT NULL AUTO_INCREMENT,
  donor_char_id INT NOT NULL,
  donor_account_id INT NOT NULL,
  donor_name VARCHAR(64) NOT NULL,
  amount INT NOT NULL DEFAULT 0,
  distributed TINYINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_philanthropist_pool_distributed (distributed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS pending_plat_grants (
  id INT NOT NULL AUTO_INCREMENT,
  character_id INT NOT NULL,
  amount INT NOT NULL DEFAULT 0,
  donor_names VARCHAR(255) NOT NULL DEFAULT '',
  status VARCHAR(16) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  claimed_at DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_pending_plat_grants_char (character_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- NPCs (clone of 344025) ----
DELETE FROM npc_types WHERE id IN (344042,344043,344044,344045,344046);

-- Chronicler_Elodin (High Elf)
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;
CREATE TEMPORARY TABLE tmp_gl_npc LIKE npc_types;
INSERT INTO tmp_gl_npc SELECT * FROM npc_types WHERE id = 344025;
UPDATE tmp_gl_npc SET id=344042, name='Chronicler_Elodin', lastname='Server Information', level=70, race=5, class=1, bodytype=1, gender=0, texture=0, helmtexture=0, size=6, hp=100000, mana=0, merchant_id=0, npc_spells_id=0, npc_faction_id=0, loottable_id=0, qglobal=0, d_melee_texture1=0, d_melee_texture2=0, show_name=1, findable=1, trackable=1, untargetable=0, runspeed=0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_gl_npc;

-- Kilven_the_Quartermaster (Dwarf, merchant)
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;
CREATE TEMPORARY TABLE tmp_gl_npc LIKE npc_types;
INSERT INTO tmp_gl_npc SELECT * FROM npc_types WHERE id = 344025;
UPDATE tmp_gl_npc SET id=344043, name='Kilven_the_Quartermaster', lastname='General Supplies', level=70, race=8, class=1, bodytype=1, gender=0, texture=0, helmtexture=0, size=5, hp=100000, mana=0, merchant_id=442009, npc_spells_id=0, npc_faction_id=0, loottable_id=0, qglobal=0, d_melee_texture1=0, d_melee_texture2=0, show_name=1, findable=1, trackable=1, untargetable=0, runspeed=0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_gl_npc;

-- Ben_Affactor (High Elf)
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;
CREATE TEMPORARY TABLE tmp_gl_npc LIKE npc_types;
INSERT INTO tmp_gl_npc SELECT * FROM npc_types WHERE id = 344025;
UPDATE tmp_gl_npc SET id=344044, name='Ben_Affactor', lastname='Philanthropic Broker', level=70, race=5, class=1, bodytype=1, gender=0, texture=0, helmtexture=0, size=6, hp=100000, mana=0, merchant_id=0, npc_spells_id=0, npc_faction_id=0, loottable_id=0, qglobal=0, d_melee_texture1=0, d_melee_texture2=0, show_name=1, findable=1, trackable=1, untargetable=0, runspeed=0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_gl_npc;

-- the_temporary_reprieve (High Elf)
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;
CREATE TEMPORARY TABLE tmp_gl_npc LIKE npc_types;
INSERT INTO tmp_gl_npc SELECT * FROM npc_types WHERE id = 344025;
UPDATE tmp_gl_npc SET id=344045, name='the_temporary_reprieve', lastname='AA Restoration Vendor', level=70, race=5, class=1, bodytype=1, gender=0, texture=0, helmtexture=0, size=6, hp=100000, mana=0, merchant_id=0, npc_spells_id=0, npc_faction_id=0, loottable_id=0, qglobal=0, d_melee_texture1=0, d_melee_texture2=0, show_name=1, findable=1, trackable=1, untargetable=0, runspeed=0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_gl_npc;

-- A_Dust_Covered_Wayfarer (Troll)
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;
CREATE TEMPORARY TABLE tmp_gl_npc LIKE npc_types;
INSERT INTO tmp_gl_npc SELECT * FROM npc_types WHERE id = 344025;
UPDATE tmp_gl_npc SET id=344046, name='A_Dust_Covered_Wayfarer', lastname='', level=70, race=9, class=1, bodytype=1, gender=0, texture=0, helmtexture=0, size=7, hp=100000, mana=0, merchant_id=0, npc_spells_id=0, npc_faction_id=0, loottable_id=0, qglobal=0, d_melee_texture1=0, d_melee_texture2=0, show_name=1, findable=1, trackable=1, untargetable=0, runspeed=0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_gl_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;

-- ---- Spawns ----
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
 (5004021,'guildlobby_Chronicler_Elodin000',0,0,0,0,0,0,45000,15000,0,100,0),
 (5004022,'guildlobby_Kilven_the_Quartermaster000',0,0,0,0,0,0,45000,15000,0,100,0),
 (5004023,'guildlobby_Ben_Affactor000',0,0,0,0,0,0,45000,15000,0,100,0),
 (5004024,'guildlobby_the_temporary_reprieve000',0,0,0,0,0,0,45000,15000,0,100,0),
 (5004025,'guildlobby_A_Dust_Covered_Wayfarer000',0,0,0,0,0,0,45000,15000,0,100,0);

INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance,condition_value_filter,min_time,max_time,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (5004021,344042,100,1,0,0,-1,-1,'',''),
 (5004022,344043,100,1,0,0,-1,-1,'',''),
 (5004023,344044,100,1,0,0,-1,-1,'',''),
 (5004024,344045,100,1,0,0,-1,-1,'',''),
 (5004025,344046,100,1,0,0,-1,-1,'','');

INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,path_when_zone_idle,_condition,cond_value,animation,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (2141241,5004021,'guildlobby',0,-50.210468,294.816132,1.852001,62.750000,1200,0,0,0,0,1,0,-1,-1,'',''),
 (2141242,5004022,'guildlobby',0,-87.440002,401.809998,-0.880000,142.000000,1200,0,0,0,0,1,0,-1,-1,'',''),
 (2141243,5004023,'guildlobby',0,26.896828,163.301361,1.851997,386.250000,1200,0,0,0,0,1,0,-1,-1,'',''),
 (2141244,5004024,'guildlobby',0,81.000000,289.000000,1.750000,189.000000,1200,0,0,0,0,1,0,-1,-1,'',''),
 (2141245,5004025,'guildlobby',0,-165.270004,528.000000,1.750000,172.000000,1200,0,0,0,0,1,0,-1,-1,'','');
