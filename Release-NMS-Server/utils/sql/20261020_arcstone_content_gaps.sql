-- Arcstone (Prophecy of Ro) content gap closure.
--
-- Closes the audited gaps against the Arcstone walkthrough:
--   * the nine named rares absent from the zone
--     (Bristlebark, Champion Ultharas, Coalshade, Echo of Skylance, Firelash,
--      Oroshar the Ashcaster, Squall, Stillsheen, Tempest)
--   * Mark of Oroshar (85610), the fifth "Mark of the Spirits" turn-in
--   * Zomm the Seventh Born (369036) loottable (orbs + gear + Chronal Stone)
--   * Colossus Shard Earring (39215) added to the Colossus loottable
--   * "a_Colossus_shard" (369119) - the NPC the Colossus splits into
--   * the "Mark of the Spirits" task for Spirit Hunter Elijo (369002)
--
-- Item ids are local PEQ ids. Idempotent: INSERT IGNORE throughout (safe to
-- re-run); the npc_types rows are cloned from in-zone kin so they inherit
-- sensible model/stat/faction defaults.
--
-- NOTE: no authoritative spawn coordinates exist for the nine missing rares
-- (arcstone.map carries no named POIs and no NPC stat source is available), so
-- each is placed near its thematic kin and its stats mirror that kin. These
-- placements are deliberate approximations, not scraped data.
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- 1. Nine missing named rares + the Colossus shard (npc_types 369110-369119)
-- ---------------------------------------------------------------------------
-- tmp_arc_npc is seeded from a real in-zone model per rare, overridden, and
-- inserted; the temp row is reused so column order always matches npc_types.
DROP TEMPORARY TABLE IF EXISTS tmp_arc_npc;
CREATE TEMPORARY TABLE tmp_arc_npc AS SELECT * FROM npc_types WHERE id = 0;

-- Bristlebark - rare mulch (kin: #Thorn). 89748 / 89754 / Mark of Vision.
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369099;
UPDATE tmp_arc_npc SET id=369110, name='Bristlebark', level=70, race=494, bodytype=25, hp=6000,
  mindmg=170, maxdmg=700, attack_delay=30, size=8.0, loottable_id=1520008492,
  npcspecialattks='', special_abilities='';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;

-- Champion Ultharas - rare undead knight (kin: Manifestation of Ravenglass).
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369037;
UPDATE tmp_arc_npc SET id=369111, name='Champion_Ultharas', level=70, race=491, bodytype=3, hp=6500,
  mindmg=180, maxdmg=750, attack_delay=29, size=7.0, loottable_id=1520008493;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;

-- Coalshade - rare (spawn cycle with Oroshar the Ashcaster and Skysmoke).
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369024;
UPDATE tmp_arc_npc SET id=369112, name='Coalshade', level=70, race=431, bodytype=5, hp=6200,
  mindmg=170, maxdmg=700, attack_delay=30, size=8.0, loottable_id=1520008494;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;

-- Echo of Skylance - rare wisp. 89756 / 89762 / Mark of Scale.
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369024;
UPDATE tmp_arc_npc SET id=369113, name='Echo_of_Skylance', level=70, race=69, bodytype=5, hp=5800,
  mindmg=160, maxdmg=680, attack_delay=30, size=7.0, loottable_id=1520008495, npcspecialattks='';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;

-- Firelash - rare pyroilean (kin: #Embra). Mark of Battle.
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369021;
UPDATE tmp_arc_npc SET id=369114, name='Firelash', level=70, race=411, bodytype=24, hp=5800,
  mindmg=165, maxdmg=690, attack_delay=30, size=7.0, loottable_id=1520008496;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;

-- Oroshar the Ashcaster - rare drake; spawn cycle with Coalshade and Skysmoke.
-- Molten Talons (dd + AC debuff); 89771 / 89779 / Mark of Oroshar.
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369024;
UPDATE tmp_arc_npc SET id=369115, name='Oroshar_the_Ashcaster', level=72, race=431, bodytype=5, hp=7200,
  mindmg=200, maxdmg=820, attack_delay=28, size=11.0, loottable_id=1520008497;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;

-- Squall - rare dervish. Storm of Lightning; 89744 / 89750 / Mark of Air.
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369024;
UPDATE tmp_arc_npc SET id=369116, name='Squall', level=70, race=431, bodytype=5, hp=6000,
  mindmg=170, maxdmg=700, attack_delay=30, size=7.0, loottable_id=1520008498;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;

-- Stillsheen - rare gelidran. Submerge (stun); 89749 / 89755 / Mark of Water.
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369024;
UPDATE tmp_arc_npc SET id=369117, name='Stillsheen', level=70, race=417, bodytype=5, hp=6000,
  mindmg=170, maxdmg=700, attack_delay=30, size=7.0, loottable_id=1520008499;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;

-- Tempest - rare dervish. Storm of Lightning; 89745 / 89751 / Mark of Air.
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369024;
UPDATE tmp_arc_npc SET id=369118, name='Tempest', level=70, race=431, bodytype=5, hp=6000,
  mindmg=170, maxdmg=700, attack_delay=30, size=7.0, loottable_id=1520008500;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;

-- a Colossus shard - spawned only by The_Colossus_of_Skylance (369070) at ~12%.
-- Root/slow-able; carries no loottable (the last shard's corpse is given a drop
-- by arcstone/369119.lua).
INSERT INTO tmp_arc_npc SELECT * FROM npc_types WHERE id = 369070;
UPDATE tmp_arc_npc SET id=369119, name='a_Colossus_shard', level=75, bodytype=3, hp=5200,
  mindmg=250, maxdmg=900, attack_delay=30, size=6.0, loottable_id=0,
  npcspecialattks='', special_abilities='';
INSERT IGNORE INTO npc_types SELECT * FROM tmp_arc_npc;
DELETE FROM tmp_arc_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_arc_npc;

-- ---------------------------------------------------------------------------
-- 2. Loottables / lootdrops for the new rares
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO loottable (id,name,mincash,maxcash,avgcoin,done,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (1520008492,'Bristlebark',0,0,0,0,-1,-1,NULL,NULL),
 (1520008493,'Champion_Ultharas',0,0,0,0,-1,-1,NULL,NULL),
 (1520008494,'Coalshade',0,0,0,0,-1,-1,NULL,NULL),
 (1520008495,'Echo_of_Skylance',0,0,0,0,-1,-1,NULL,NULL),
 (1520008496,'Firelash',0,0,0,0,-1,-1,NULL,NULL),
 (1520008497,'Oroshar_the_Ashcaster',0,0,0,0,-1,-1,NULL,NULL),
 (1520008498,'Squall',0,0,0,0,-1,-1,NULL,NULL),
 (1520008499,'Stillsheen',0,0,0,0,-1,-1,NULL,NULL),
 (1520008500,'Tempest',0,0,0,0,-1,-1,NULL,NULL),
 (1520008501,'Zomm_the_Seventh_Born',0,0,0,0,-1,-1,NULL,NULL);

INSERT IGNORE INTO loottable_entries (loottable_id,lootdrop_id,multiplier,droplimit,mindrop,probability) VALUES
 (1520008492,1520008536,1,1,1,100),
 (1520008493,1520008537,1,1,1,100),
 (1520008494,1520008538,1,1,1,100),
 (1520008495,1520008539,1,1,1,100),
 (1520008496,1520008540,1,1,1,100),
 (1520008497,1520008541,1,1,1,100),
 (1520008498,1520008542,1,1,1,100),
 (1520008499,1520008543,1,1,1,100),
 (1520008500,1520008544,1,1,1,100),
 (1520008501,1520008545,3,1,1,100),   -- 3x Black Orb of Zomm the Seventh
 (1520008501,1520008546,1,2,2,100),   -- two of the five gear drops
 (1520008501,1520008547,1,1,0,100);   -- chance at a Chronal Stone

INSERT IGNORE INTO lootdrop (id,name,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
 (1520008536,'Bristlebark',-1,-1,NULL,NULL),
 (1520008537,'Champion_Ultharas',-1,-1,NULL,NULL),
 (1520008538,'Coalshade',-1,-1,NULL,NULL),
 (1520008539,'Echo_of_Skylance',-1,-1,NULL,NULL),
 (1520008540,'Firelash',-1,-1,NULL,NULL),
 (1520008541,'Oroshar_the_Ashcaster',-1,-1,NULL,NULL),
 (1520008542,'Squall',-1,-1,NULL,NULL),
 (1520008543,'Stillsheen',-1,-1,NULL,NULL),
 (1520008544,'Tempest',-1,-1,NULL,NULL),
 (1520008545,'por_zomm_black_orbs',-1,-1,NULL,NULL),
 (1520008546,'por_zomm_gear',-1,-1,NULL,NULL),
 (1520008547,'por_zomm_chronal_stone',-1,-1,NULL,NULL);

INSERT IGNORE INTO lootdrop_entries (lootdrop_id,item_id,chance) VALUES
 -- Bristlebark: Dark Spiritbone Urn, Greater Spiritbone Briar, Spirit Mark of Vision
 (1520008536,89748,40),(1520008536,89754,40),(1520008536,85657,60),
 -- Champion Ultharas: Ethereal Silversilk Wristwraps, Arcblade
 (1520008537,89775,40),(1520008537,89783,40),
 -- Coalshade: Ethereal Plate Bracers, Mageblade
 (1520008538,89772,40),(1520008538,89780,40),
 -- Echo of Skylance: Fireforged Mantle, Warpwood Waraxe, Spirit Mark of Scale
 (1520008539,89756,40),(1520008539,89762,40),(1520008539,85656,60),
 -- Firelash: Spirit Mark of Battle
 (1520008540,85658,60),
 -- Oroshar the Ashcaster: Mantle of the Spellcaller, Necklace of the Arch Scrykin, Mark of Oroshar
 (1520008541,89771,40),(1520008541,89779,40),(1520008541,85610,82),
 -- Squall: Shadeforge Gloves, Shadeiron Legplates, Spirit Mark of Air
 (1520008542,89744,40),(1520008542,89750,40),(1520008542,85655,60),
 -- Stillsheen: Disk of the Deft, Ring of Spellcraft, Spirit Mark of Water
 (1520008543,89749,40),(1520008543,89755,40),(1520008543,85653,60),
 -- Tempest: Shadelink Boots, Shadelink Leggings, Spirit Mark of Air
 (1520008544,89745,40),(1520008544,89751,40),(1520008544,85655,60),
 -- Zomm: Black Orb of Zomm the Seventh (multiplied x3 by the loottable entry)
 (1520008545,85628,100),
 -- Zomm: Mask of Foresight, Pendant of the Elder Scrykin, Eye of Nine Worlds,
 --       Zomm's Wand, Iris Blade (two are selected by the loottable entry)
 (1520008546,39237,40),(1520008546,39238,40),(1520008546,39239,40),
 (1520008546,39240,40),(1520008546,39241,40),
 -- Zomm: Chance at a Chronal Stone
 (1520008547,33318,10);

-- Zomm the Seventh Born drops the new loottable.
UPDATE npc_types SET loottable_id = 1520008501 WHERE id = 369036 AND (loottable_id = 0 OR loottable_id IS NULL);

-- ---------------------------------------------------------------------------
-- 3. Colossus Shard Earring (39215) added to the Colossus lootdrop
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO lootdrop_entries (lootdrop_id,item_id,chance) VALUES (108197,39215,20);

-- ---------------------------------------------------------------------------
-- 4. Spawns for the nine rares
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
 (1520008826,'arcstone_bristlebark',0,0,0,0,0,0,45000,15000,0,100,0),
 (1520008827,'arcstone_ultharas',0,0,0,0,0,0,45000,15000,0,100,0),
 (1520008828,'arcstone_oroshar_cycle',1,0,0,0,0,0,45000,15000,0,100,0),
 (1520008829,'arcstone_echo_of_skylance',0,0,0,0,0,0,45000,15000,0,100,0),
 (1520008830,'arcstone_firelash',0,0,0,0,0,0,45000,15000,0,100,0),
 (1520008831,'arcstone_squall',0,0,0,0,0,0,45000,15000,0,100,0),
 (1520008832,'arcstone_stillsheen',0,0,0,0,0,0,45000,15000,0,100,0),
 (1520008833,'arcstone_tempest',0,0,0,0,0,0,45000,15000,0,100,0);

-- Bristlebark, Ultharas, Echo, Firelash, Squall, Stillsheen, Tempest: one entry each.
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES
 (1520008826,369110,100),
 (1520008827,369111,100),
 (1520008829,369113,100),
 (1520008830,369114,100),
 (1520008831,369116,100),
 (1520008832,369117,100),
 (1520008833,369118,100);
-- Coalshade / Oroshar the Ashcaster cycle (spawn_limit 1 -> one up at a time).
INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance) VALUES
 (1520008828,369112,50),
 (1520008828,369115,50);

INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime) VALUES
 -- Approximate placements near thematic kin (see header note).
 (1520023300,1520008826,'arcstone',0,-532,481,405,0,1800),   -- Bristlebark, by Norgaro
 (1520023301,1520008827,'arcstone',0,-540,410,421,0,1800),   -- Champion Ultharas, by the Colossus
 (1520023302,1520008828,'arcstone',0,760,-393,202,0,1800),   -- Coalshade/Oroshar, Skysmoke's rise
 (1520023303,1520008829,'arcstone',0,380,-10,394,0,1800),    -- Echo of Skylance, spirit hollow
 (1520023304,1520008830,'arcstone',0,900,-575,188,0,1800),   -- Firelash, by #Embra
 (1520023305,1520008831,'arcstone',0,-1040,-950,495,0,1800), -- Squall, Sundersky's storm
 (1520023306,1520008832,'arcstone',0,-1020,-985,497,0,1800), -- Stillsheen, elder galestorm
 (1520023307,1520008833,'arcstone',0,-350,-991,382,0,1800);  -- Tempest, the whirlwind

-- ---------------------------------------------------------------------------
-- 5. "Mark of the Spirits" (task 3031) for Spirit Hunter Elijo (369002)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO tasks (id,type,duration,duration_code,title,description,reward_text,reward_id_list,cash_reward,exp_reward,reward_method,reward_points,reward_point_type,min_level,max_level,level_spread,min_players,max_players,repeatable,faction_reward,completion_emote,replay_timer_group) VALUES
 (3031,2,0,0,'Mark of the Spirits','Spirit Hunter Elijo has asked you to recover the marks borne by the champions of Arcstone: the Mark of Okahn, the Mark of Ravenglass, the Mark of Stillwillow, the Mark of Xanzerok, and the Mark of Oroshar.','You have gathered the marks of the spirits.', '',0,0,0,0,0,60,0,0,1,1,0,0,'',0);

INSERT IGNORE INTO task_activities (taskid,activityid,req_activity_id,step,activitytype,target_name,goalmethod,goalcount,description_override,item_id_list,item_list,optional,list_group) VALUES
 (3031,0,-1,1,1,'Spirit Hunter Elijo',0,1,'Bring Elijo the Mark of Okahn','85606','',0,0),
 (3031,1,-1,2,1,'Spirit Hunter Elijo',0,1,'Bring Elijo the Mark of Ravenglass','85607','',0,0),
 (3031,2,-1,3,1,'Spirit Hunter Elijo',0,1,'Bring Elijo the Mark of Stillwillow','85608','',0,0),
 (3031,3,-1,4,1,'Spirit Hunter Elijo',0,1,'Bring Elijo the Mark of Xanzerok','85609','',0,0),
 (3031,4,-1,5,1,'Spirit Hunter Elijo',0,1,'Bring Elijo the Mark of Oroshar','85610','',0,0);
