-- ============================================================================
-- Ascendant Charm line (Charm of the Nth Age) + Aurelian Stoneward
-- Source: Ascendant-EQ-Emu/Ascendant-Server @ main
--   server/quests/guildlobby/Aurelian_Stoneward.pl
--   database/ascendant_content.sql.gz
-- Adapted for Triptych/EQS:
--   * Ascendant charm IDs 2854/2855/2827/2829/4038 collide with live PEQ items;
--     renumbered to the free block 121850-121854.
--   * Item rows are identical to Ascendant (same 285-column schema); only the
--     id changes. Referenced effects 484/1689/3343 (click), 86/3660 (worn) and
--     aug distiller 47007 already exist locally.
--   * Era titles 398-402/411/419/421 kept at their Ascendant IDs (free locally).
--   * Aurelian npc_types row cloned from local NPC 344025 (Ascendant npc_types
--     schema differs by one column); spawned at Ascendant v0 coords.
-- Idempotent: DELETE+INSERT. Rollback: 20260928_ascendant_charm_line_rollback.sql
-- ============================================================================
SET NAMES utf8mb4;

-- ---- Charm items (renumbered) ----
DELETE FROM items WHERE id IN (121850,121851,121852,121853,121854);
INSERT INTO items VALUES (121850,0,'Charm of the First Age',10,15,0,0,9,9,0,11,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,9,0,0,0,0,0,0,0,0,0,0,0,1200,1200,'','',65535,0,'',0,0,0,10,0,0,131071,0,47007,0,10,1,1,0,0,0,0,0,0,0,0,0,0,0,'',0,15,0,0,1,110,3,1644,'IT63',0,11,0,0,0,0,'Champions of Classic - Celebrate!',-1,1,90,3,0,0,0,-1,10,0,1,0,10,0,65535,0,0,0,0,0,0,0,0,0,1,484,0,0,0,0,0,0,0,0,0,0,0,0,0,600,0,0,0,0,0,0,NULL,'',0,0,0,0,0,0,0,'',0,0,0,0,0,0,86,2,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,'',0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,'',0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,'','','','','',0,3,2,1,1,2,1,0,3,2,3,3,2,0,0,5,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
INSERT INTO items VALUES (121851,0,'Charm of the Second Age',11,20,0,0,13,12,0,14,11,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,12,0,0,0,0,0,0,0,0,0,0,0,1200,1200,'','',65535,0,'',0,0,0,10,0,0,131071,0,47007,0,10,1,1,0,0,0,0,0,0,0,0,0,0,0,'',0,15,0,0,1,185,5,1647,'IT63',0,11,0,0,0,0,'Champions of Kunark - Celebrate!',-1,1,165,5,0,0,0,-1,10,0,1,0,10,0,65535,0,0,0,0,0,0,0,0,0,1,1689,0,0,0,0,0,0,0,0,0,0,0,0,0,600,0,0,0,0,0,0,NULL,'',0,0,0,0,0,0,0,'',0,0,0,0,0,0,86,2,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,'',0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,'',0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,'','','','','',0,4,3,2,2,3,2,0,4,3,4,4,3,0,0,7,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
INSERT INTO items VALUES (121852,0,'Charm of the Third Age',15,24,0,0,18,15,0,18,17,0,0,7,1,0,0,0,0,0,0,0,0,0,0,64,0,19,0,0,0,0,0,0,0,0,0,0,0,1200,1200,'','',65535,0,'',0,0,0,20,0,0,131071,0,47007,0,13,1,1,0,0,0,0,0,0,0,0,0,0,0,'',0,15,0,0,1,232,5,1898,'IT63',0,11,0,0,0,0,'Champions of Kunark - Celebrate!',-1,1,245,5,0,0,0,-1,15,0,1,0,13,0,65535,0,0,0,0,0,0,0,0,0,1,3343,0,0,0,0,0,0,0,0,0,0,0,0,0,600,0,0,0,0,0,0,NULL,'',0,0,0,0,0,0,0,'',0,0,0,0,0,0,3660,2,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,'',0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,'',0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,'','','','','',0,7,6,5,5,6,5,0,7,5,6,7,5,0,0,7,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
INSERT INTO items VALUES (121853,0,'Charm of the Fourth Age',17,31,0,1,20,17,0,22,22,0,0,7,1,0,0,0,0,0,0,0,0,0,0,64,0,21,0,0,0,0,0,0,0,0,0,0,0,1200,1200,'','',65535,0,'',0,0,0,20,0,0,131071,0,47007,0,13,1,1,0,0,0,0,0,0,0,0,0,0,0,'',0,15,0,0,1,298,9,6321,'IT63',0,11,0,0,0,0,'I guess the moon IS made of cheese!',-1,1,278,9,0,0,0,-1,15,0,1,0,13,0,65535,0,0,0,0,0,0,0,0,0,1,3343,0,0,0,0,0,0,0,0,0,0,0,0,0,600,0,0,0,0,0,0,NULL,'',0,0,0,0,0,0,0,'',0,0,0,0,0,0,3660,2,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,'',0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,'',0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,'','','','','',0,6,7,7,6,7,7,0,8,6,7,8,6,0,6,12,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
INSERT INTO items VALUES (121854,0,'Charm of the Fifth Age',17,31,0,1,20,17,0,22,22,0,0,7,1,8,1,0,0,0,0,0,0,0,0,64,0,21,0,0,0,0,0,0,0,0,0,0,0,1200,1200,'','',65535,0,'',0,0,0,20,0,0,131071,0,47007,0,13,1,1,0,0,0,0,0,0,0,0,0,0,0,'',0,15,0,0,1,298,9,1688,'IT63',0,11,0,0,0,0,'I\'m feeling kinda powerful in these planes!',-1,1,278,9,0,0,0,-1,15,0,1,0,13,0,65535,0,0,0,0,0,0,0,0,0,1,3343,0,0,0,0,0,0,0,0,0,0,0,0,0,600,0,0,0,0,0,0,NULL,'',0,0,0,0,0,0,0,'',0,0,0,0,0,0,3660,2,0,0,0,0,0,1,0,0,0,0,0,0,NULL,NULL,NULL,'',0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,0,'',0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,0,0,0,0,'','','','','',0,6,7,7,6,7,7,0,8,6,7,8,6,0,6,12,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

-- ---- Era completion titles ----
DELETE FROM titles WHERE id IN (398,399,400,401,402,411,419,421);
INSERT INTO titles VALUES
(398,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'','the Spanker of Classic Dragons',0),
(399,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'','Old World Champion',0),
(400,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'Ascendant','',0),
(401,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'','Scourge of Kunark',0),
(402,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'','Certified Kunark Menace',0),
(411,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'','the Icebreaker',411),
(419,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'','the Lunar Ascendant',419),
(421,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,'','the Godbreaker',421);

-- ---- Aurelian Stoneward (npc_types clone of 344025) ----
DELETE FROM npc_types WHERE id = 344050;
DROP TEMPORARY TABLE IF EXISTS tmp_charm_npc;
CREATE TEMPORARY TABLE tmp_charm_npc LIKE npc_types;
INSERT INTO tmp_charm_npc SELECT * FROM npc_types WHERE id = 344025;
UPDATE tmp_charm_npc SET id=344050, name='Aurelian_Stoneward', lastname='Master of Progression', level=70, race=1, class=1, bodytype=1, gender=0, texture=0, helmtexture=0, size=6, hp=100000, mana=0, merchant_id=0, npc_spells_id=0, npc_faction_id=0, loottable_id=0, qglobal=0, d_melee_texture1=0, d_melee_texture2=0, show_name=1, findable=1, trackable=1, untargetable=0, runspeed=0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_charm_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_charm_npc;

-- ---- Spawn: guildlobby, v0, Ascendant coords (-77.235916,317.831116,1.852001) ----
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES (5004020,'guildlobby_Aurelian_Stoneward000',0,0,0,0,0,0,45000,15000,0,100,0);
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance,condition_value_filter,min_time,max_time,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES (5004020,344050,100,1,0,0,-1,-1,'','');
INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,path_when_zone_idle,_condition,cond_value,animation,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES (2141240,5004020,'guildlobby',0,-77.235916,317.831116,1.852001,76.0,1200,0,0,0,0,1,0,-1,-1,'','');
