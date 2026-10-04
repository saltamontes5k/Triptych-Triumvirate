-- ============================================================================
-- Ascendant Guild Lobby v3 (gambling + April Fools)
-- Ports (adapted for Triptych/EQS):
--   Harley_Wynn + ascendant_gambling.pl (Lucky Coin id 121857)
--   ascendant_april_fools.pl + guildlobby/zone_controller.pl
-- Source: Ascendant-EQ-Emu/Ascendant-Server @ main
--
--   * Ascendant's Lucky Coin 1378 collides with a live PEQ item; moved to 121857.
--   * April Fools is gated by the local content-flag convention (like
--     erollisiday/frostfell) via a new 'april_fools' flag (off by default).
--   * zone_controller is the EQEmu zone-controller NPC (auto-created), so no
--     spawn row is required for it.
-- Idempotent. Rollback: 20260928_ascendant_guildlobby_e_rollback.sql
-- ============================================================================
SET NAMES utf8mb4;

-- ---- Lucky Coin (clone of 25805) ----
DELETE FROM items WHERE id = 121857;
DROP TEMPORARY TABLE IF EXISTS tmp_gl_item;
CREATE TEMPORARY TABLE tmp_gl_item LIKE items;
INSERT INTO tmp_gl_item SELECT * FROM items WHERE id = 25805;
UPDATE tmp_gl_item SET id=121857, Name='Lucky Coin', lore='A coin that decides your fate.', nodrop=0, magic=0, loregroup=-1, stackable=1, stacksize=100, clickeffect=-1, proceffect=-1, worneffect=-1, focuseffect=-1, scrolleffect=-1;
INSERT IGNORE INTO items SELECT * FROM tmp_gl_item;
DROP TEMPORARY TABLE IF EXISTS tmp_gl_item;

-- ---- April Fools content flag (off by default) ----
INSERT INTO content_flags (flag_name, enabled, notes)
SELECT 'april_fools', 0, 'Bristlebane April Fools event toggle (ascendant_april_fools.pl)'
WHERE NOT EXISTS (SELECT 1 FROM content_flags WHERE flag_name = 'april_fools');

-- ---- Harley Wynn NPC ----
DELETE FROM npc_types WHERE id = 344049;
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;
CREATE TEMPORARY TABLE tmp_gl_npc LIKE npc_types;
INSERT INTO tmp_gl_npc SELECT * FROM npc_types WHERE id = 344025;
UPDATE tmp_gl_npc SET id=344049, name='Harley_Wynn', lastname="Lucky Draw", level=70, race=1, class=1, bodytype=1, gender=0, texture=0, helmtexture=0, size=6, hp=100000, mana=0, merchant_id=0, npc_spells_id=0, npc_faction_id=0, loottable_id=0, qglobal=0, d_melee_texture1=0, d_melee_texture2=0, show_name=1, findable=1, trackable=1, untargetable=0, runspeed=0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_gl_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
 (5004028,'guildlobby_Harley_Wynn000',0,0,0,0,0,0,45000,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance,condition_value_filter,min_time,max_time,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (5004028,344049,100,1,0,0,-1,-1,'','');
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,path_when_zone_idle,_condition,cond_value,animation,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (2141248,5004028,'guildlobby',0,-70.000000,425.899994,3.620000,250.000000,1200,0,0,0,0,1,0,-1,-1,'','');
