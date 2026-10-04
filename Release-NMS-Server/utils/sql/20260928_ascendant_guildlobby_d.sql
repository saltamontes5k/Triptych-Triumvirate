-- ============================================================================
-- Ascendant Guild Lobby v2 (item-tier NPCs)
-- Ports (adapted for Triptych/EQS):
--   Khael_the_Spellforger, Morvain_the_Diminisher, Ancient Shard item
-- Source: Ascendant-EQ-Emu/Ascendant-Server @ main
--
--   * Ascendant used additive tier offsets +300k/+500k/+700k and shard 9600.
--     Both the offsets and shard 9600 collide with EQS conventions/items.
--     Rewritten against NMS_item_utils.pl tiers:
--        Tier0 base  (< 1,000,000)
--        Tier1 Enchanted (+1,000,000)
--        Tier2 Legendary (+2,000,000)
--     with the shard moved to the free id 121856.
--   * NPCs cloned from local 344025 and spawned in the Guild Lobby.
-- Idempotent. Rollback: 20260928_ascendant_guildlobby_d_rollback.sql
-- ============================================================================
SET NAMES utf8mb4;

-- ---- Ancient Shard of Ascendant Power (clone of 56977) ----
DELETE FROM items WHERE id = 121856;
DROP TEMPORARY TABLE IF EXISTS tmp_gl_item;
CREATE TEMPORARY TABLE tmp_gl_item LIKE items;
INSERT INTO tmp_gl_item SELECT * FROM items WHERE id = 56977;
UPDATE tmp_gl_item SET id=121856, Name='Ancient Shard of Ascendant Power', lore='A fragment of raw ascendant power.', nodrop=0, magic=1, loregroup=-1, itemtype=11, slots=0, classes=65535, races=65535, stacksize=0, clickeffect=-1, proceffect=-1, worneffect=-1, focuseffect=-1, scrolleffect=-1;
INSERT IGNORE INTO items SELECT * FROM tmp_gl_item;
DROP TEMPORARY TABLE IF EXISTS tmp_gl_item;

-- ---- Khael failure-leaderboard titles ---- 
DELETE FROM titles WHERE id IN (412,413,414,415);
INSERT INTO titles VALUES
 (412,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'','the Failure',412),
 (413,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'','the Disappointment',413),
 (414,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'Unlucky','',414),
 (415,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'Angry','',415);

-- ---- NPCs ----
DELETE FROM npc_types WHERE id IN (344047,344048);

-- Khael the Spellforger (Human)
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;
CREATE TEMPORARY TABLE tmp_gl_npc LIKE npc_types;
INSERT INTO tmp_gl_npc SELECT * FROM npc_types WHERE id = 344025;
UPDATE tmp_gl_npc SET id=344047, name='Khael_the_Spellforger', lastname='Item Tier Upgrades', level=70, race=1, class=1, bodytype=1, gender=0, texture=0, helmtexture=0, size=6, hp=100000, mana=0, merchant_id=0, npc_spells_id=0, npc_faction_id=0, loottable_id=0, qglobal=0, d_melee_texture1=0, d_melee_texture2=0, show_name=1, findable=1, trackable=1, untargetable=0, runspeed=0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_gl_npc;

-- Morvain the Diminisher (Barbarian)
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;
CREATE TEMPORARY TABLE tmp_gl_npc LIKE npc_types;
INSERT INTO tmp_gl_npc SELECT * FROM npc_types WHERE id = 344025;
UPDATE tmp_gl_npc SET id=344048, name='Morvain_the_Diminisher', lastname='Item Tier Restoration', level=70, race=2, class=1, bodytype=1, gender=0, texture=0, helmtexture=0, size=7, hp=100000, mana=0, merchant_id=0, npc_spells_id=0, npc_faction_id=0, loottable_id=0, qglobal=0, d_melee_texture1=0, d_melee_texture2=0, show_name=1, findable=1, trackable=1, untargetable=0, runspeed=0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_gl_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_gl_npc;

-- ---- Spawns ----
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
 (5004026,'guildlobby_Khael_the_Spellforger000',0,0,0,0,0,0,45000,15000,0,100,0),
 (5004027,'guildlobby_Morvain_the_Diminisher000',0,0,0,0,0,0,45000,15000,0,100,0);

INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance,condition_value_filter,min_time,max_time,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (5004026,344047,100,1,0,0,-1,-1,'',''),
 (5004027,344048,100,1,0,0,-1,-1,'','');

INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,path_when_zone_idle,_condition,cond_value,animation,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (2141246,5004026,'guildlobby',0,-87.720001,445.000000,3.620000,180.000000,1200,0,0,0,0,1,0,-1,-1,'',''),
 (2141247,5004027,'guildlobby',0,-87.720001,425.899994,3.620000,112.750000,1200,0,0,0,0,1,0,-1,-1,'','');
