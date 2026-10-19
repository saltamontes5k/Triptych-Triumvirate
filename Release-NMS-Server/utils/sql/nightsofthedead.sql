-- ===========================================================================
-- Nights of the Dead (Halloween) — content flag + seasonal gating
-- Flag: peq_halloween  (matches the 209 existing spawn2 rows that already
--       reference 'peq_halloween'; the flag was never defined, so all of that
--       content was silently filtered out by ContentFilterCriteria).
-- Off-season: content_flags.enabled = 0  ->  filtered out.
-- On-season : UPDATE content_flags SET enabled=1 WHERE flag_name='peq_halloween';
--             then #reload content_flags global  and  #repop <zones>.
-- Idempotent. Scope: flag + spawn gating only (content additions live in the
-- companion sections appended to this file).
-- Coordinates: Bonzz /waypoint values are (Y, X); spawn2 is (x, y) => swap only.
-- ===========================================================================
SET NAMES utf8mb4;
START TRANSACTION;

-- --- Phase 0: content flag -------------------------------------------------
INSERT INTO content_flags (flag_name, enabled, notes)
SELECT 'peq_halloween', 0, 'Nights of the Dead / Halloween seasonal event' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM content_flags WHERE flag_name = 'peq_halloween');

-- --- Phase 1: gate currently-ungated Halloween spawns ----------------------
-- Shakey_Scarecrow (rivervale), Haunted_Jack / Spooky_Sally (freeportwest),
-- a_frightening_liaison / Hadya_Ware (poknowledge, currently hard-disabled).
-- (cabeast spawn2 11863 is Vessel_Grott, NOT Halloween — deliberately excluded.)
UPDATE spawn2 SET content_flags = 'peq_halloween'
 WHERE id IN (10940, 107665, 107666, 148654, 148656)
   AND (content_flags IS NULL OR content_flags = '');

-- --- Phase 1b: retire the spawn2_disabled workarounds so the flag is the
--              single gate (rows are kept, flag cleared). ---------------------
UPDATE spawn2_disabled SET disabled = 0
 WHERE spawn2_id IN (148654, 148656);

-- --- Phase 2: gate event-exclusive loot tables -----------------------------
-- Loot tables used ONLY by Halloween NPCs (verified via direct npc_types
-- counts). Shared tables are deliberately NOT gated:
--   loottable 46  (Orc_Centurion)     - also used by year-round orc_centurion
--   loottable 4210 (Priest_Of_Discord) - also used by PoK Priest_of_Discord
-- gating either would suppress non-event drops. Loot filtering is enforced in
-- zone/loot.cpp::AddLootTable() via DoesPassContentFiltering().
UPDATE loottable SET content_flags = 'peq_halloween'
 WHERE id IN (1627, 87670, 90412, 90413, 90573, 101557, 110185)
   AND (content_flags IS NULL OR content_flags = '');

-- NOTE: merchantlists 202386 (Spooky_Sally) / 202387 (Haunted_Jack) are reached
-- only through their spawn-gated merchants, so they are intentionally left
-- ungated (gating them would not change reachability). merchant 999999 is shared.

COMMIT;

-- ===========================================================================
-- Phase 3 — content additions (PoK trio + 2005-2008 quests)
-- ===========================================================================
START TRANSACTION;

-- --- Zigan Ribshard (PoK, Bone Mask of Horror finisher) --------------------
-- Existing ungated spawn; gate it with the rest of the event.
UPDATE spawn2 SET content_flags = 'peq_halloween'
 WHERE id = 40668 AND (content_flags IS NULL OR content_flags = '');

-- --- "Carry the Torch" (2008) ---------------------------------------------
-- Reuses existing year-round NPCs (Rongol/Anderia, qey2hh1) and Innkeep Danin's
-- existing Torch stock (item 13002). Task is script-driven (type 255).
INSERT INTO tasks (id,type,duration,duration_code,title,description,reward_text,reward_id_list,cash_reward,exp_reward,reward_method,reward_points,min_level,max_level,level_spread,repeatable,completion_emote,enabled)
SELECT 620003,0,0,0,'Carry the Torch','Rongol asks that you carry four torches to Anderia.','',NULL,0,0,0,0,0,0,0,1,'',1
WHERE NOT EXISTS (SELECT 1 FROM tasks WHERE id = 620003);

DELETE FROM task_activities WHERE taskid = 620003;
INSERT INTO task_activities (taskid,activityid,req_activity_id,step,activitytype,target_name,goalmethod,goalcount,description_override,npc_match_list,item_id_list,item_list,zones,zone_version,optional,list_group) VALUES
(620003,0,-1,1,255,'',0,1,'Speak with Rongol.','','','','12',-1,0,0),
(620003,1,-1,2,255,'',0,4,'Deliver 4 Torches to Anderia.','','13002','','12',-1,0,0);

COMMIT;

-- After applying: #reload content_flags global ; #repop poknowledge freeportwest
--   rivervale (or restart those zones).

-- ===========================================================================
-- Phase 4 — Nights of the Dead 2005-2008 quests (60+ single version)
-- Sources: Allakhazam quests 3803/4318/4903/5068/4898/5369/4902/9223 via the
-- Wayback Machine.  Allakhazam /loc is (Y, X, Z) => spawn2 (x, y, z) swap only.
-- Every row is gated by content_flags='peq_halloween'.  Idempotent:
-- scoped DELETE by id block, then INSERT.
-- ===========================================================================
START TRANSACTION;

-- --- New items (Witch's Wishes) -------------------------------------------
DELETE FROM items WHERE id BETWEEN 3001001 AND 3001006;
INSERT INTO items (id,Name,lore,itemtype,slots,stackable,nodrop,magic,weight,price,icon,idfile,clickeffect,clicktype,casttime,recastdelay,maxcharges,reqlevel,classes,races,size,bagtype,bagslots,bagsize,bagwr,loregroup,questitemflag,norent) VALUES
(3001001,'Dreadful Witch''s Cauldron','Dreadful Witch''s Cauldron',11,0,0,1,0,0.5,0,1233,'IT63',-1,0,0,0,0,0,65535,65535,1,1,4,1,0,0,1,1),
(3001002,'Dreadful Mushroom','Dreadful Mushroom',11,0,1,0,0,0.2,0,632,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,0),
(3001003,'Lost Mirror','Lost Mirror',11,0,1,1,0,0.2,0,1233,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,1),
(3001004,'Pieces of a Shattered Mirror','Pieces of a Shattered Mirror',11,0,1,1,0,0.2,0,1233,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,0),
(3001005,'Broken Horseshoe','Broken Horseshoe',11,0,1,0,0,0.2,0,1141,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,0),
(3001006,'Dreadful Witch''s Brew','Dreadful Witch''s Brew',11,0,1,0,0,0.2,0,593,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,0);

-- --- New NPCs --------------------------------------------------------------
DELETE FROM npc_types WHERE id BETWEEN 1500200001 AND 1500200099;
INSERT INTO npc_types (id,name,lastname,level,race,class,bodytype,hp,mana,gender,texture,helmtexture,size,loottable_id,merchant_id,npc_spells_id,npc_faction_id,mindmg,maxdmg,attack_count,npcspecialattks,special_abilities,aggroradius,assistradius,runspeed,MR,CR,DR,FR,PR,Corrup,PhR,qglobal,AC,npc_aggro,attack_speed,attack_delay,findable,STR,STA,DEX,AGI,_INT,WIS,CHA,see_invis,see_invis_undead,trackable,ATK,slow_mitigation,version,maxlevel,scalerate,isquest) VALUES
-- 12+1 Bonecollectors (Skeleton Zapping 3803)
(1500200001,'Aauman_the_Bonecollector','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200002,'Bethun_the_Bonecollector','',60,1,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200003,'Filada_the_Bonecollector','',60,1,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200004,'Jarz_the_Bonecollector','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200005,'Khbantiz_the_Bonecollector','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200006,'Kordulaf_the_Bonecollector','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200007,'Mynen_the_Bonecollector','',60,1,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200008,'Ordun_the_Bonecollector','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200009,'Oxrun_the_Bonecollector','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200010,'Pralak_the_Bonecollector','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200011,'Renla_the_Bonecollector','',60,1,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200012,'Rentila_the_Bonecollector','',60,1,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200013,'Uzek_the_Bonecollector','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
-- Troublemakers in Faydark (4318) / Necromancer's Garden (4903)
(1500200020,'Silas_Lightweaver','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200021,'Leavalin_Mossbite','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
-- Undead Rising (5068)
(1500200022,'Corporal_Gravlin','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200023,'a_frightened_traveler','',60,1,1,1,5000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',0,0,1.25,15,15,15,15,15,0,0,0,0,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200024,'a_minion_of_Pyzjn','',60,161,1,3,6000,0,0,0,0,6.00,0,0,0,0,0,25,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,0,0,0,30,1,100,100,100,100,100,100,100,0,0,0,0,0,0,60,0,0),
-- Missing Costume Pieces (4898)
(1500200025,'a_dressed-up_halfling','',60,11,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200026,'a_bloody_vampire','',60,342,1,1,12000,0,0,0,0,6.00,0,0,0,0,0,40,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,0,0,0,30,1,120,120,120,120,120,120,120,0,0,0,0,0,0,60,0,0),
-- The Bone Collector (5369)
(1500200027,'Barsin_the_Bone_Collector','',60,82,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200028,'a_bone_construct','',66,161,1,3,50000,0,0,0,0,12.00,0,0,0,0,80,250,1,'','',70,70,1.25,15,15,15,15,15,0,0,0,0,0,0,30,1,200,200,200,200,200,200,200,0,0,0,0,0,0,66,0,0),
-- The Witch's Wishes (9223)
(1500200029,'Cikdew','',60,1,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
-- Scarecrow Roundup (4902)
(1500200030,'a_crazed_scarecrow','',25,82,1,3,1200,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',0,0,1.25,15,15,15,15,15,0,0,0,0,0,0,30,1,100,100,100,100,100,100,100,0,0,0,0,0,0,25,0,0),
(1500200031,'a_hired_hand','',50,1,1,1,8000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,0,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,50,0,1);

-- --- Spawn groups / entries / points (all gated peq_halloween) -------------
DELETE FROM spawnentry WHERE spawngroupID BETWEEN 60020001 AND 60020031;
DELETE FROM spawn2      WHERE id BETWEEN 45020001 AND 45020037;
DELETE FROM spawngroup  WHERE id BETWEEN 60020001 AND 60020031;

INSERT INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
(60020001,'notd_Aauman',0,0,0,0,0,0,0,0,0,0,0),
(60020002,'notd_Bethun',0,0,0,0,0,0,0,0,0,0,0),
(60020003,'notd_Filada',0,0,0,0,0,0,0,0,0,0,0),
(60020004,'notd_Jarz',0,0,0,0,0,0,0,0,0,0,0),
(60020005,'notd_Khbantiz',0,0,0,0,0,0,0,0,0,0,0),
(60020006,'notd_Kordulaf',0,0,0,0,0,0,0,0,0,0,0),
(60020007,'notd_Mynen',0,0,0,0,0,0,0,0,0,0,0),
(60020008,'notd_Ordun',0,0,0,0,0,0,0,0,0,0,0),
(60020009,'notd_Oxrun',0,0,0,0,0,0,0,0,0,0,0),
(60020010,'notd_Pralak',0,0,0,0,0,0,0,0,0,0,0),
(60020011,'notd_Renla',0,0,0,0,0,0,0,0,0,0,0),
(60020012,'notd_Rentila',0,0,0,0,0,0,0,0,0,0,0),
(60020013,'notd_Uzek',0,0,0,0,0,0,0,0,0,0,0),
(60020020,'notd_Silas_Lightweaver',0,0,0,0,0,0,0,0,0,0,0),
(60020021,'notd_Leavalin_Mossbite',0,0,0,0,0,0,0,0,0,0,0),
(60020022,'notd_Corporal_Gravlin',0,0,0,0,0,0,0,0,0,0,0),
(60020025,'notd_a_dressed-up_halfling',0,0,0,0,0,0,0,0,0,0,0),
(60020026,'notd_a_bloody_vampire',0,0,0,0,0,0,0,0,0,0,0),
(60020027,'notd_Barsin',0,0,0,0,0,0,0,0,0,0,0),
(60020029,'notd_Cikdew',0,0,0,0,0,0,0,0,0,0,0),
(60020030,'notd_a_crazed_scarecrow',0,0,0,0,0,0,0,0,0,0,0),
(60020031,'notd_a_hired_hand',0,0,0,0,0,0,0,0,0,0,0);

INSERT INTO spawnentry (spawngroupID,npcID,chance,min_time,max_time,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(60020001,1500200001,100,0,0,-1,-1,'',''),
(60020002,1500200002,100,0,0,-1,-1,'',''),
(60020003,1500200003,100,0,0,-1,-1,'',''),
(60020004,1500200004,100,0,0,-1,-1,'',''),
(60020005,1500200005,100,0,0,-1,-1,'',''),
(60020006,1500200006,100,0,0,-1,-1,'',''),
(60020007,1500200007,100,0,0,-1,-1,'',''),
(60020008,1500200008,100,0,0,-1,-1,'',''),
(60020009,1500200009,100,0,0,-1,-1,'',''),
(60020010,1500200010,100,0,0,-1,-1,'',''),
(60020011,1500200011,100,0,0,-1,-1,'',''),
(60020012,1500200012,100,0,0,-1,-1,'',''),
(60020013,1500200013,100,0,0,-1,-1,'',''),
(60020020,1500200020,100,0,0,-1,-1,'',''),
(60020021,1500200021,100,0,0,-1,-1,'',''),
(60020022,1500200022,100,0,0,-1,-1,'',''),
(60020025,1500200025,100,0,0,-1,-1,'',''),
(60020026,1500200026,100,0,0,-1,-1,'',''),
(60020027,1500200027,100,0,0,-1,-1,'',''),
(60020029,1500200029,100,0,0,-1,-1,'',''),
(60020030,1500200030,100,0,0,-1,-1,'',''),
(60020031,1500200031,100,0,0,-1,-1,'','');

INSERT INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,path_when_zone_idle,_condition,cond_value,animation,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(45020001,60020001,'tox',0,-881.0,2224.0,-39.25,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020002,60020002,'misty',0,-1351.0,373.0,10.0,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020003,60020003,'gfaydark',0,-2344.0,-1977.0,28.75,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020004,60020004,'sharvahl',0,94.0,-498.0,-192.5,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020005,60020005,'fieldofbone',0,3543.0,-2512.0,7.75,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020006,60020006,'butcher',0,-168.0,2886.0,-0.88,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020007,60020007,'gfaydark',0,174.0,0.0,77.6,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020008,60020008,'freeportwest',0,205.0,-137.0,-39.0,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020009,60020009,'everfrost',0,617.0,3320.0,-47.38,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020010,60020010,'crescent',0,-50.0,-34.0,0.70,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020011,60020011,'qeynos2',0,206.0,339.0,2.8,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020012,60020012,'qrg',0,153.0,-26.0,4.0,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020013,60020013,'nektulos',0,-940.0,1848.0,26.375,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020020,60020020,'gfaydark',0,395.0,490.0,161.63,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020021,60020021,'gfaydark',0,-1930.0,-1115.0,25.0,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020022,60020022,'qeytoqrg',0,59.0,-61.0,-4.0,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020025,60020025,'kithicor',0,-570.0,1090.0,-39.77,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020026,60020026,'mistmoore',0,46.0,-180.88,-154.75,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020027,60020027,'kithicor',0,9.0,-101.0,-65.0,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020029,60020029,'southkarana',0,896.0,2544.0,-59.25,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020030,60020030,'qey2hh1',0,-9350.0,-3600.0,-0.13,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020031,60020030,'qey2hh1',0,-9200.0,-3550.0,-0.13,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020032,60020030,'qey2hh1',0,-9450.0,-3750.0,-0.13,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020033,60020030,'qey2hh1',0,-9100.0,-3650.0,-0.13,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020034,60020031,'qey2hh1',0,-9320.0,-3720.0,-0.13,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020035,60020031,'qey2hh1',0,-9260.0,-3690.0,-0.13,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020036,60020031,'qey2hh1',0,-9340.0,-3660.0,-0.13,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020037,60020031,'qey2hh1',0,-9250.0,-3740.0,-0.13,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween','');

-- --- Ground spawns ---------------------------------------------------------
DELETE FROM ground_spawns WHERE id BETWEEN 460001 AND 460010;
INSERT INTO ground_spawns (id,zoneid,version,max_x,max_y,max_z,min_x,min_y,heading,name,item,max_allowed,comment,respawn_timer,fix_z,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(460001,24,0,-105.0,-715.0,25.0,-155.0,-685.0,0,'','3001003',1,'Witch Wishes: Lost Mirror (Erudin)',300,1,-1,-1,'peq_halloween',''),
(460002,14,0,-2317.0,236.0,-56.0,-2357.0,276.0,0,'','3001005',1,'Witch Wishes: Broken Horseshoe (S. Karana)',300,1,-1,-1,'peq_halloween',''),
(460003,123,0,145.0,-1815.0,-258.0,105.0,-1855.0,0,'','84081',1,'Bone Collector: Dragon Skull Fragments (Dragon Necropolis)',300,1,-1,-1,'peq_halloween','');

-- --- Tasks -----------------------------------------------------------------
-- (range narrowed to the 2005-2008 block; 620012-620017 are deleted in Phase 5)
DELETE FROM task_activities WHERE taskid BETWEEN 620004 AND 620011;
DELETE FROM tasks           WHERE id     BETWEEN 620004 AND 620011;
INSERT INTO tasks (id,type,duration,duration_code,title,description,reward_text,reward_id_list,cash_reward,exp_reward,reward_method,reward_points,min_level,max_level,level_spread,repeatable,completion_emote,enabled) VALUES
(620004,0,0,0,'Skeleton Zapping','Destroy ten skeletons with the Scythe of Skeletal Expulsion.','',NULL,0,0,0,0,0,0,0,1,'',1),
(620005,0,0,0,'Troublemakers in Faydark','Capture ten faerie and pixie troublemakers, then release them in Lesser Faydark.','',NULL,0,0,0,0,0,0,0,1,'',1),
(620006,0,0,0,'Necromancer''s Garden','Destroy ten graveskulls with the Blessed Shillelagh.','',NULL,0,0,0,0,0,0,0,1,'',1),
(620007,0,0,0,'Undead Rising','Escort a frightened traveler safely to Surefall Glade.','',NULL,0,0,0,0,0,0,0,1,'',1),
(620008,0,0,0,'Missing Costume Pieces','Recover the Bloody Vampire Cloak and Fangs.','',NULL,0,0,0,0,0,0,0,1,'',1),
(620009,0,0,0,'The Bone Collector','Gather the bones Barsin asked for.','',NULL,0,0,0,0,0,0,0,1,'',1),
(620010,0,0,0,'Scarecrow Roundup','Round up ten crazed scarecrows with Rongol''s Pitchfork.','',NULL,0,0,0,0,0,0,0,1,'',1),
(620011,0,0,0,'The Witch''s Wishes','Help Cikdew brew a dreadful witch''s potion.','',NULL,0,0,0,0,0,0,0,1,'',1);

INSERT INTO task_activities (taskid,activityid,req_activity_id,step,activitytype,target_name,goalmethod,goalcount,description_override,npc_match_list,item_id_list,item_list,zones,zone_version,optional,list_group) VALUES
(620004,0,-1,1,255,'',0,10,'Expel 10 skeletons with the Scythe of Skeletal Expulsion.','','87296','','',-1,0,0),
(620005,0,-1,1,255,'',0,10,'Capture faerie and pixie troublemakers in Greater Faydark.','','80040','','54',-1,0,0),
(620005,1,-1,2,255,'',0,1,'Release the troublemakers in Lesser Faydark.','','80040','','57',-1,0,0),
(620005,2,-1,3,255,'',0,1,'Return to Silas Lightweaver.','','','','54',-1,0,0),
(620006,0,-1,1,255,'',0,10,'Destroy 10 graveskulls with the Blessed Shillelagh.','','49061','','54',-1,0,0),
(620007,0,-1,1,255,'',0,1,'Let Corporal Gravlin know you are ready.','','80041','','4',-1,0,0),
(620007,1,-1,2,255,'',0,1,'Escort the frightened traveler safely to Surefall Glade.','','','','4',-1,0,0),
(620007,2,-1,3,255,'',0,1,'Report back to Corporal Gravlin.','','','','4',-1,0,0),
(620008,0,-1,1,255,'',0,1,'Recover the Bloody Vampire Cloak from Castle Mistmoore.','','85060','','59',-1,0,0),
(620008,1,-1,2,255,'',0,1,'Recover the Bloody Vampire Fangs from Castle Mistmoore.','','85061','','59',-1,0,0),
(620008,2,-1,3,255,'',0,1,'Return the cloak and fangs to the Dressed-Up Halfling.','','','','20',-1,0,0),
(620009,0,-1,1,255,'',0,1,'Loot a Splintered Discordling Bone in Wall of Slaughter.','','54349','','300',-1,0,0),
(620009,1,-1,2,255,'',0,4,'Loot 4 Bone Chips in the Plane of Nightmare.','','12694','','204',-1,0,0),
(620009,2,-1,3,255,'',0,1,'Collect Dragon Skull Fragments in Dragon Necropolis.','','84081','','123',-1,0,0),
(620009,3,-1,4,255,'',0,1,'Deliver the bones to Barsin.','','','','20',-1,0,0),
(620009,4,-1,5,255,'',0,1,'Destroy the bone construct.','','','','20',-1,0,0),
(620010,0,-1,1,255,'',0,10,'Force 10 crazed scarecrows into the corral with Rongol''s Pitchfork.','','49060','','12',-1,0,0),
(620011,0,-1,1,255,'',0,1,'Find the Lost Mirror near the Erudin Palace.','','','','24',-1,0,0),
(620011,1,-1,2,255,'',0,1,'Deliver the Lost Mirror to Mugu outside Oggok.','','','','47',-1,0,0),
(620011,2,-1,3,255,'',0,1,'Gather Rock Salt and a Candied Spider for the brew.','','','','',-1,0,0),
(620011,3,-1,4,255,'',0,1,'Find a Broken Horseshoe in the South Karana Centaur Village.','','','','14',-1,0,0),
(620011,4,-1,5,255,'',0,1,'Brew the Dreadful Witch''s Brew.','','','','',-1,0,0),
(620011,5,-1,6,255,'',0,1,'Travel to Shadowrest and perform the ceremony.','','','','187',-1,0,0),
(620011,6,-1,7,255,'',0,1,'Harvest the Dreadful Mushroom.','','','','187',-1,0,0),
(620011,7,-1,8,255,'',0,1,'Deliver the Dreadful Mushroom to Cikdew.','','','','14',-1,0,0);

-- --- Task completion rewards (reward_id_list is '|'-separated) --------------
UPDATE tasks SET reward_id_list='87312',     reward_text='Ginormous Jawbreaker'              WHERE id=620004;
UPDATE tasks SET reward_id_list='80042',     reward_text='Firework: Nagafen Fire'           WHERE id=620005;
UPDATE tasks SET reward_id_list='80057|80059',reward_text='Floating Skull Potion, Worm Skull Muffin' WHERE id=620006;
UPDATE tasks SET reward_id_list='80055',     reward_text='Firestorm Torch'                  WHERE id=620007;
UPDATE tasks SET reward_id_list='85062',     reward_text='Bristlebane''s Ticket of Admission' WHERE id=620008;
UPDATE tasks SET reward_id_list='90025|85062',reward_text='Bone Earring, Ticket of Admission' WHERE id=620009;
UPDATE tasks SET reward_id_list='80060|80058',reward_text='Spiced Crow''s Blood, Scarecrow Potion' WHERE id=620010;

-- --- Undead Rising: 6 escort minions ---------------------------------------
UPDATE task_activities SET goalcount=6, description_override='Burn 6 minions of Pyzjn with the torch.' WHERE taskid=620007 AND activityid=1;

-- --- Bloody Vampire loot (Missing Costume Pieces) --------------------------
DELETE FROM loottable_entries WHERE loottable_id = 200001;
DELETE FROM loottable         WHERE id = 200001;
DELETE FROM lootdrop_entries  WHERE lootdrop_id = 200001;
DELETE FROM lootdrop          WHERE id = 200001;
INSERT INTO loottable (id,name,mincash,maxcash,avgcoin,done,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(200001,'notd_bloody_vampire',0,0,0,0,-1,-1,'peq_halloween','');
INSERT INTO lootdrop (id,name,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(200001,'notd_bloody_vampire',-1,-1,'peq_halloween','');
INSERT INTO lootdrop_entries (lootdrop_id,item_id,item_charges,equip_item,chance,disabled_chance,trivial_min_level,trivial_max_level,multiplier,npc_min_level,npc_max_level,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(200001,85060,1,0,100,0,0,0,1,0,0,-1,-1,'',''),
(200001,85061,1,0,100,0,0,0,1,0,0,-1,-1,'','');
INSERT INTO loottable_entries (loottable_id,lootdrop_id,multiplier,droplimit,mindrop,probability) VALUES
(200001,200001,1,0,2,100);
UPDATE npc_types SET loottable_id = 200001 WHERE id = 1500200026;

COMMIT;

-- ===========================================================================
-- Phase 5 — Nights of the Dead 2009/2010 + Out With the Old (tasks 620012-620017)
-- Sources: bonzz.com/nightsofthedead.htm (#hauntedcave #diggraves #tattooed
--          #terror #underskin) and bonzz.com/bonemask.htm (#5).
-- Adaptations vs live (documented in the quest scripts too):
--   * "Out With the Old" monster mission -> scripted Void Legion defense
--     event in kithicor (no monster-mission tech on this server).  Entry
--     consumes Bristlebane's Ticket of Admission (85062, reward of 620008).
--   * "Under Your Skin" runs in a remote gfaydark pocket (eastkorlacha /
--     Snarlstone Dens is dz-instanced only here); the true Skinwalker is a
--     zone qglobal (notd_uys_true) picked when the encounter starts.
--   * "Digging Their Graves" 14h lockout and the master-quest 5x counter are
--     character buckets: notd_graves_last / notd_graves_count /
--     notd_master_prog (see poknowledge/Edmund_Strangeways.pl).
--   * "the Gravedigger" suffix title rides on titles.item_id (Frightening
--     Writ, 3001010) - claim with /title.
-- Zones for digging sites / skinwalker hunts (zoneidnumber):
--   nektulos 25, lakeofillomen 85, firiona 84, emeraldjungle 94, mesa 397,
--   barren 422, steppes 399, lopingplains 443, buriedsea 423,
--   oldfieldofbone 452 (Field of Scale), crescent 394, kithicor 20,
--   poknowledge 202, gfaydark 54.
-- ===========================================================================
START TRANSACTION;

-- --- Items ------------------------------------------------------------------
DELETE FROM items WHERE id BETWEEN 3001007 AND 3001014;
INSERT INTO items (id,Name,lore,itemtype,slots,stackable,nodrop,magic,weight,price,icon,idfile,clickeffect,clicktype,casttime,recastdelay,maxcharges,reqlevel,classes,races,size,bagtype,bagslots,bagsize,bagwr,loregroup,questitemflag,norent,astr,acha,awis,aint,hp,mana)
VALUES
(3001007,'Pirate''s Gold','Pirate''s Gold',11,0,0,0,1,0.2,0,632,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,0,6,3,8,8,70,60),
(3001008,'Edmund''s Shovel','Edmund''s Shovel',11,0,0,1,0,1.5,0,789,'IT63',122100,5,8000,5,-1,0,65535,65535,1,0,0,0,0,0,1,1,0,0,0,0,0,0),
(3001009,'Intricately Tattooed Flesh','Intricately Tattooed Flesh',11,0,1,1,0,0.1,0,832,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,1,0,0,0,0,0,0),
(3001010,'Frightening Writ','Frightening Writ',11,0,0,0,1,0.1,0,1233,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,0,0,0,0,0,0,0),
(3001011,'Skinwalker''s Soul Shard','Skinwalker''s Soul Shard',11,0,1,1,1,0.1,0,788,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,1,0,0,0,0,0,0),
(3001012,'Vial of Chiropteranform','Vial of Chiropteranform',21,0,0,0,1,0.3,0,519,'IT63',32824,3,1500,5,10,1,65535,65535,1,0,0,0,0,0,1,0,0,0,0,0,0,0),
(3001013,'Vial of the Wild Moon','Vial of the Wild Moon',21,0,0,0,1,0.3,0,519,'IT63',585,3,1500,5,10,1,65535,65535,1,0,0,0,0,0,1,0,0,0,0,0,0,0),
(3001014,'Void Artifact','Void Artifact',11,0,0,1,1,1.0,0,1233,'IT63',-1,0,0,0,0,0,65535,65535,1,0,0,0,0,0,1,1,0,0,0,0,0,0);

-- --- Grave Dig spell (shovel click, target the disturbed earth) --------------
DELETE FROM spells_new WHERE id = 122100;
INSERT INTO spells_new (id, name, player_1, effectid1, effect_base_value1,
                        targettype, cast_time, buffdurationformula, buffduration,
                        teleport_zone, goodEffect, ResistDiff, mana, can_mgb, reflectable)
VALUES (122100,'Grave_Dig','PLAYER_1',254,0,5,2000,0,0,'',1,0,0,0,0);
UPDATE spells_new SET effectid2=254, effectid3=254, effectid4=254, effectid5=254,
  effectid6=254, effectid7=254, effectid8=254, effectid9=254, effectid10=254,
  effectid11=254, effectid12=254 WHERE id = 122100;

-- --- New NPCs ----------------------------------------------------------------
DELETE FROM npc_types WHERE id BETWEEN 1500200032 AND 1500200099;
INSERT INTO npc_types (id,name,lastname,level,race,class,bodytype,hp,mana,gender,texture,helmtexture,size,loottable_id,merchant_id,npc_spells_id,npc_faction_id,mindmg,maxdmg,attack_count,npcspecialattks,special_abilities,aggroradius,assistradius,runspeed,MR,CR,DR,FR,PR,Corrup,PhR,qglobal,AC,npc_aggro,attack_speed,attack_delay,findable,STR,STA,DEX,AGI,_INT,WIS,CHA,see_invis,see_invis_undead,trackable,ATK,slow_mitigation,version,maxlevel,scalerate,isquest) VALUES
-- Haunted Cave (Crescent Reach)
(1500200032,'Jilian_Florantine','',60,1,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200033,'Ghost_of_All_Hallows_Eve','',60,67,1,3,30000,0,0,0,0,6.00,0,0,0,0,30,120,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,80,1,0,30,1,120,120,120,120,120,120,120,0,0,1,0,0,0,60,0,0),
(1500200034,'Shadow_of_All_Hallows_Eve','',62,67,1,3,42000,0,0,1,0,6.00,0,0,0,0,40,150,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,90,1,0,30,1,130,130,130,130,130,130,130,0,0,1,0,0,0,62,0,0),
-- Digging Their Graves / Hunt for Tattooed Flesh (PoK)
(1500200035,'Edmund_Strangeways','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
-- Terror of Illis Taberish giver (PoK)
(1500200037,'Illis_Taberish','',60,1,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
-- Under Your Skin (PoK giver + gfaydark pocket encounter)
(1500200036,'Rhaeda_Evel','',60,21,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200075,'Skinwalker','',70,253,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',0,0,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,70,0,1),
(1500200076,'a_revealed_skinwalker','',72,253,1,1,90000,0,0,0,0,6.00,0,0,0,0,150,380,1,'Z','',0,0,1.25,15,15,15,15,15,0,0,0,150,1,0,30,0,200,200,200,200,200,200,200,0,0,1,0,0,0,72,0,0),
(1500200077,'a_revealed_skinwalker','',72,253,1,1,90000,0,0,1,0,6.00,0,0,0,0,150,380,1,'Z','',0,0,1.25,15,15,15,15,15,0,0,0,150,1,0,30,0,200,200,200,200,200,200,200,0,0,1,0,0,0,72,0,0),
(1500200078,'a_revealed_skinwalker','',72,253,1,1,90000,0,0,2,0,6.00,0,0,0,0,150,380,1,'Z','',0,0,1.25,15,15,15,15,15,0,0,0,150,1,0,30,0,200,200,200,200,200,200,200,0,0,1,0,0,0,72,0,0),
(1500200079,'Elder_Ritualist_Longshadow','',70,3,1,1,200000,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',0,0,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,70,0,1),
-- Out With the Old (kithicor Void Legion defense)
(1500200038,'Cathil','',60,1,1,1,200000,0,1,0,0,6.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200039,'A_Silly_Puppet','',60,41,1,1,200000,0,0,0,0,3.00,0,0,0,0,0,0,0,'','',70,70,1.25,15,15,15,15,15,0,0,0,50,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200084,'#Void_Defense_Controller','',80,127,1,11,32767,0,0,0,0,6.00,0,0,0,0,0,0,0,'','',0,0,1.25,15,15,15,15,15,0,0,0,0,0,0,30,0,100,100,100,100,100,100,100,0,0,0,0,0,0,0,0,1),
(1500200080,'The_Legion_Commander_of_the_Void','',78,1,1,1,450000,0,0,3,3,8.00,200004,0,0,0,400,900,1,'Z','',70,70,1.25,15,15,15,15,15,0,0,0,250,1,0,30,1,250,250,250,250,250,250,250,0,0,1,0,0,0,78,0,0),
(1500200081,'a_void_legionnaire','',72,1,1,1,120000,0,0,3,0,6.00,0,0,0,0,200,420,1,'Z','',70,70,1.25,15,15,15,15,15,0,0,0,220,1,0,30,0,220,220,220,220,220,220,220,0,0,1,0,0,0,72,0,0),
(1500200082,'a_void_bloodmage','',73,1,1,1,100000,60000,0,3,0,6.00,0,0,0,0,180,380,1,'Z','',70,70,1.25,15,15,15,15,15,0,0,0,200,1,0,30,0,210,210,210,210,210,210,210,0,0,1,0,0,0,73,0,0),
(1500200083,'a_void_ravager','',74,1,1,1,140000,0,0,3,0,7.00,0,0,0,0,250,450,1,'Z','',70,70,1.25,15,15,15,15,15,0,0,0,240,1,0,30,0,230,230,230,230,230,230,230,0,0,1,0,0,0,74,0,0),
-- Grave-dig site objects and spawns
(1500200072,'a_disturbed_earth','',60,56,1,66,32767,0,0,2,0,5.00,0,0,0,0,0,0,0,'','',0,0,1.25,15,15,15,15,15,0,0,0,0,0,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,60,0,1),
(1500200073,'a_disturbed_spirit','',55,67,1,3,25000,0,0,0,0,6.00,0,0,0,0,30,110,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,80,1,0,30,1,120,120,120,120,120,120,120,0,0,1,0,0,0,55,0,0),
(1500200074,'a_tattooed_zombie','',60,2,1,3,35000,0,0,0,0,6.00,200002,0,0,0,35,130,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,90,1,0,30,1,140,140,140,140,140,140,140,0,0,1,0,0,0,60,0,0),
-- Terror of Illis Taberish: 32 skinwalker nameds, 4 per band
(1500200040,'Lorna_Sheecot','',10,30,1,1,4000,0,0,0,0,6.00,200003,0,0,0,15,40,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,40,1,0,30,1,80,80,80,80,80,80,80,0,0,1,0,0,0,10,0,0),
(1500200041,'Petra_Grenal','',10,30,1,1,4000,0,1,0,0,6.00,200003,0,0,0,15,40,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,40,1,0,30,1,80,80,80,80,80,80,80,0,0,1,0,0,0,10,0,0),
(1500200042,'Piolo_Meesker','',10,30,1,1,4000,0,0,1,0,6.00,200003,0,0,0,15,40,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,40,1,0,30,1,80,80,80,80,80,80,80,0,0,1,0,0,0,10,0,0),
(1500200043,'Saldis_Oro','',10,30,1,1,4000,0,0,2,0,6.00,200003,0,0,0,15,40,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,40,1,0,30,1,80,80,80,80,80,80,80,0,0,1,0,0,0,10,0,0),
(1500200044,'Kano_Burber','',20,30,1,1,9000,0,0,0,0,6.00,200003,0,0,0,25,80,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,60,1,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,20,0,0),
(1500200045,'Lendal_Fobins','',20,30,1,1,9000,0,1,0,0,6.00,200003,0,0,0,25,80,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,60,1,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,20,0,0),
(1500200046,'Liskard','',20,30,1,1,9000,0,0,1,0,6.00,200003,0,0,0,25,80,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,60,1,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,20,0,0),
(1500200047,'Shay_Talgot','',20,30,1,1,9000,0,0,2,0,6.00,200003,0,0,0,25,80,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,60,1,0,30,1,100,100,100,100,100,100,100,0,0,1,0,0,0,20,0,0),
(1500200048,'Igo_Pho','',30,30,1,1,16000,0,0,0,0,6.00,200003,0,0,0,40,120,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,80,1,0,30,1,120,120,120,120,120,120,120,0,0,1,0,0,0,30,0,0),
(1500200049,'Meego_Battledrum','',30,30,1,1,16000,0,1,0,0,6.00,200003,0,0,0,40,120,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,80,1,0,30,1,120,120,120,120,120,120,120,0,0,1,0,0,0,30,0,0),
(1500200050,'Schalter_Gringham','',30,30,1,1,16000,0,0,1,0,6.00,200003,0,0,0,40,120,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,80,1,0,30,1,120,120,120,120,120,120,120,0,0,1,0,0,0,30,0,0),
(1500200051,'Tenos_Aryvin','',30,30,1,1,16000,0,0,2,0,6.00,200003,0,0,0,40,120,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,80,1,0,30,1,120,120,120,120,120,120,120,0,0,1,0,0,0,30,0,0),
(1500200052,'Hael_Nebur','',40,30,1,1,25000,0,0,0,0,6.00,200003,0,0,0,55,160,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,100,1,0,30,1,140,140,140,140,140,140,140,0,0,1,0,0,0,40,0,0),
(1500200053,'Jolee_Winger','',40,30,1,1,25000,0,1,0,0,6.00,200003,0,0,0,55,160,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,100,1,0,30,1,140,140,140,140,140,140,140,0,0,1,0,0,0,40,0,0),
(1500200054,'Pas_Neep_Arda','',40,30,1,1,25000,0,0,1,0,6.00,200003,0,0,0,55,160,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,100,1,0,30,1,140,140,140,140,140,140,140,0,0,1,0,0,0,40,0,0),
(1500200055,'Salohcin_Bilox','',40,30,1,1,25000,0,0,2,0,6.00,200003,0,0,0,55,160,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,100,1,0,30,1,140,140,140,140,140,140,140,0,0,1,0,0,0,40,0,0),
(1500200056,'Aliq_Reet','',50,30,1,1,40000,0,0,0,0,6.00,200003,0,0,0,70,200,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,120,1,0,30,1,160,160,160,160,160,160,160,0,0,1,0,0,0,50,0,0),
(1500200057,'Nonnahs_Sernwall','',50,30,1,1,40000,0,1,0,0,6.00,200003,0,0,0,70,200,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,120,1,0,30,1,160,160,160,160,160,160,160,0,0,1,0,0,0,50,0,0),
(1500200058,'Rasco_Gundar','',50,30,1,1,40000,0,0,1,0,6.00,200003,0,0,0,70,200,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,120,1,0,30,1,160,160,160,160,160,160,160,0,0,1,0,0,0,50,0,0),
(1500200059,'Thob_Runtskil','',50,30,1,1,40000,0,0,2,0,6.00,200003,0,0,0,70,200,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,120,1,0,30,1,160,160,160,160,160,160,160,0,0,1,0,0,0,50,0,0),
(1500200060,'Amoro_Bosckillio','',60,30,1,1,60000,0,0,0,0,6.00,200003,0,0,0,90,240,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,140,1,0,30,1,180,180,180,180,180,180,180,0,0,1,0,0,0,60,0,0),
(1500200061,'Fellot_Newten','',60,30,1,1,60000,0,1,0,0,6.00,200003,0,0,0,90,240,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,140,1,0,30,1,180,180,180,180,180,180,180,0,0,1,0,0,0,60,0,0),
(1500200062,'Kellar_Dinit','',60,30,1,1,60000,0,0,1,0,6.00,200003,0,0,0,90,240,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,140,1,0,30,1,180,180,180,180,180,180,180,0,0,1,0,0,0,60,0,0),
(1500200063,'Onda_Granst','',60,30,1,1,60000,0,0,2,0,6.00,200003,0,0,0,90,240,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,140,1,0,30,1,180,180,180,180,180,180,180,0,0,1,0,0,0,60,0,0),
(1500200064,'Djando_Kordisan','',70,30,1,1,90000,0,0,0,0,6.00,200003,0,0,0,110,300,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,170,1,0,30,1,200,200,200,200,200,200,200,0,0,1,0,0,0,70,0,0),
(1500200065,'Jaecen_Oel','',70,30,1,1,90000,0,1,0,0,6.00,200003,0,0,0,110,300,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,170,1,0,30,1,200,200,200,200,200,200,200,0,0,1,0,0,0,70,0,0),
(1500200066,'Nella_Vond','',70,30,1,1,90000,0,0,1,0,6.00,200003,0,0,0,110,300,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,170,1,0,30,1,200,200,200,200,200,200,200,0,0,1,0,0,0,70,0,0),
(1500200067,'Trawets_Deeve','',70,30,1,1,90000,0,0,2,0,6.00,200003,0,0,0,110,300,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,170,1,0,30,1,200,200,200,200,200,200,200,0,0,1,0,0,0,70,0,0),
(1500200068,'Allistan_Fenner','',80,30,1,1,120000,0,0,0,0,6.00,200003,0,0,0,140,380,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,200,1,0,30,1,220,220,220,220,220,220,220,0,0,1,0,0,0,80,0,0),
(1500200069,'Calaen_Demre','',80,30,1,1,120000,0,1,0,0,6.00,200003,0,0,0,140,380,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,200,1,0,30,1,220,220,220,220,220,220,220,0,0,1,0,0,0,80,0,0),
(1500200070,'Jar_Hunol','',80,30,1,1,120000,0,0,1,0,6.00,200003,0,0,0,140,380,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,200,1,0,30,1,220,220,220,220,220,220,220,0,0,1,0,0,0,80,0,0),
(1500200071,'Wendel_Mummershen','',80,30,1,1,120000,0,0,2,0,6.00,200003,0,0,0,140,380,1,'Z','',40,40,1.25,15,15,15,15,15,0,0,0,200,1,0,30,1,220,220,220,220,220,220,220,0,0,1,0,0,0,80,0,0);

-- --- Spawn groups / entries / points ----------------------------------------
DELETE FROM spawnentry WHERE spawngroupID BETWEEN 60020032 AND 60020089;
DELETE FROM spawn2      WHERE id BETWEEN 45020038 AND 45020099;
DELETE FROM spawngroup  WHERE id BETWEEN 60020032 AND 60020089;

INSERT INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
(60020032,'notd_Jilian_Florantine',0,0,0,0,0,0,0,0,0,0,0),
(60020033,'notd_Ghost_All_Hallows',0,0,0,0,0,0,0,0,0,0,0),
(60020034,'notd_Shadow_All_Hallows',0,0,0,0,0,0,0,0,0,0,0),
(60020035,'notd_Edmund_Strangeways',0,0,0,0,0,0,0,0,0,0,0),
(60020036,'notd_Rhaeda_Evel',0,0,0,0,0,0,0,0,0,0,0),
(60020037,'notd_Illis_Taberish',0,0,0,0,0,0,0,0,0,0,0),
(60020038,'notd_Cathil',0,0,0,0,0,0,0,0,0,0,0),
(60020039,'notd_A_Silly_Puppet',0,0,0,0,0,0,0,0,0,0,0),
(60020040,'notd_Void_Defense_Controller',0,0,0,0,0,0,0,0,0,0,0),
(60020041,'notd_Lorna_Sheecot',0,0,0,0,0,0,0,0,0,0,0),
(60020042,'notd_Petra_Grenal',0,0,0,0,0,0,0,0,0,0,0),
(60020043,'notd_Piolo_Meesker',0,0,0,0,0,0,0,0,0,0,0),
(60020044,'notd_Saldis_Oro',0,0,0,0,0,0,0,0,0,0,0),
(60020045,'notd_Kano_Burber',0,0,0,0,0,0,0,0,0,0,0),
(60020046,'notd_Lendal_Fobins',0,0,0,0,0,0,0,0,0,0,0),
(60020047,'notd_Liskard',0,0,0,0,0,0,0,0,0,0,0),
(60020048,'notd_Shay_Talgot',0,0,0,0,0,0,0,0,0,0,0),
(60020049,'notd_Igo_Pho',0,0,0,0,0,0,0,0,0,0,0),
(60020050,'notd_Meego_Battledrum',0,0,0,0,0,0,0,0,0,0,0),
(60020051,'notd_Schalter_Gringham',0,0,0,0,0,0,0,0,0,0,0),
(60020052,'notd_Tenos_Aryvin',0,0,0,0,0,0,0,0,0,0,0),
(60020053,'notd_Hael_Nebur',0,0,0,0,0,0,0,0,0,0,0),
(60020054,'notd_Jolee_Winger',0,0,0,0,0,0,0,0,0,0,0),
(60020055,'notd_Pas_Neep_Arda',0,0,0,0,0,0,0,0,0,0,0),
(60020056,'notd_Salohcin_Bilox',0,0,0,0,0,0,0,0,0,0,0),
(60020057,'notd_Aliq_Reet',0,0,0,0,0,0,0,0,0,0,0),
(60020058,'notd_Nonnahs_Sernwall',0,0,0,0,0,0,0,0,0,0,0),
(60020059,'notd_Rasco_Gundar',0,0,0,0,0,0,0,0,0,0,0),
(60020060,'notd_Thob_Runtskil',0,0,0,0,0,0,0,0,0,0,0),
(60020061,'notd_Amoro_Bosckillio',0,0,0,0,0,0,0,0,0,0,0),
(60020062,'notd_Fellot_Newten',0,0,0,0,0,0,0,0,0,0,0),
(60020063,'notd_Kellar_Dinit',0,0,0,0,0,0,0,0,0,0,0),
(60020064,'notd_Onda_Granst',0,0,0,0,0,0,0,0,0,0,0),
(60020065,'notd_Djando_Kordisan',0,0,0,0,0,0,0,0,0,0,0),
(60020066,'notd_Jaecen_Oel',0,0,0,0,0,0,0,0,0,0,0),
(60020067,'notd_Nella_Vond',0,0,0,0,0,0,0,0,0,0,0),
(60020068,'notd_Trawets_Deeve',0,0,0,0,0,0,0,0,0,0,0),
(60020069,'notd_Allistan_Fenner',0,0,0,0,0,0,0,0,0,0,0),
(60020070,'notd_Calaen_Demre',0,0,0,0,0,0,0,0,0,0,0),
(60020071,'notd_Jar_Hunol',0,0,0,0,0,0,0,0,0,0,0),
(60020072,'notd_Wendel_Mummershen',0,0,0,0,0,0,0,0,0,0,0),
(60020073,'notd_a_disturbed_earth',0,0,0,0,0,0,0,0,0,0,0),
(60020074,'notd_a_disturbed_spirit',0,0,0,0,0,0,0,0,0,0,0),
(60020075,'notd_a_tattooed_zombie',0,0,0,0,0,0,0,0,0,0,0),
(60020076,'notd_Skinwalker_uys',0,0,0,0,0,0,0,0,0,0,0),
(60020077,'notd_revealed_1',0,0,0,0,0,0,0,0,0,0,0),
(60020078,'notd_revealed_2',0,0,0,0,0,0,0,0,0,0,0),
(60020079,'notd_revealed_3',0,0,0,0,0,0,0,0,0,0,0),
(60020080,'notd_Longshadow',0,0,0,0,0,0,0,0,0,0,0),
(60020081,'notd_void_commander',0,0,0,0,0,0,0,0,0,0,0),
(60020082,'notd_void_legionnaire',0,0,0,0,0,0,0,0,0,0,0),
(60020083,'notd_void_bloodmage',0,0,0,0,0,0,0,0,0,0,0),
(60020084,'notd_void_ravager',0,0,0,0,0,0,0,0,0,0,0);

INSERT INTO spawnentry (spawngroupID,npcID,chance,min_time,max_time,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(60020032,1500200032,100,0,0,-1,-1,'',''),
(60020033,1500200033,100,0,0,-1,-1,'',''),
(60020034,1500200034,100,0,0,-1,-1,'',''),
(60020035,1500200035,100,0,0,-1,-1,'',''),
(60020036,1500200036,100,0,0,-1,-1,'',''),
(60020037,1500200037,100,0,0,-1,-1,'',''),
(60020038,1500200038,100,0,0,-1,-1,'',''),
(60020039,1500200039,100,0,0,-1,-1,'',''),
(60020040,1500200084,100,0,0,-1,-1,'',''),
(60020041,1500200040,100,0,0,-1,-1,'',''),
(60020042,1500200041,100,0,0,-1,-1,'',''),
(60020043,1500200042,100,0,0,-1,-1,'',''),
(60020044,1500200043,100,0,0,-1,-1,'',''),
(60020045,1500200044,100,0,0,-1,-1,'',''),
(60020046,1500200045,100,0,0,-1,-1,'',''),
(60020047,1500200046,100,0,0,-1,-1,'',''),
(60020048,1500200047,100,0,0,-1,-1,'',''),
(60020049,1500200048,100,0,0,-1,-1,'',''),
(60020050,1500200049,100,0,0,-1,-1,'',''),
(60020051,1500200050,100,0,0,-1,-1,'',''),
(60020052,1500200051,100,0,0,-1,-1,'',''),
(60020053,1500200052,100,0,0,-1,-1,'',''),
(60020054,1500200053,100,0,0,-1,-1,'',''),
(60020055,1500200054,100,0,0,-1,-1,'',''),
(60020056,1500200055,100,0,0,-1,-1,'',''),
(60020057,1500200056,100,0,0,-1,-1,'',''),
(60020058,1500200057,100,0,0,-1,-1,'',''),
(60020059,1500200058,100,0,0,-1,-1,'',''),
(60020060,1500200059,100,0,0,-1,-1,'',''),
(60020061,1500200060,100,0,0,-1,-1,'',''),
(60020062,1500200061,100,0,0,-1,-1,'',''),
(60020063,1500200062,100,0,0,-1,-1,'',''),
(60020064,1500200063,100,0,0,-1,-1,'',''),
(60020065,1500200064,100,0,0,-1,-1,'',''),
(60020066,1500200065,100,0,0,-1,-1,'',''),
(60020067,1500200066,100,0,0,-1,-1,'',''),
(60020068,1500200067,100,0,0,-1,-1,'',''),
(60020069,1500200068,100,0,0,-1,-1,'',''),
(60020070,1500200069,100,0,0,-1,-1,'',''),
(60020071,1500200070,100,0,0,-1,-1,'',''),
(60020072,1500200071,100,0,0,-1,-1,'',''),
(60020073,1500200072,100,0,0,-1,-1,'',''),
(60020074,1500200073,100,0,0,-1,-1,'',''),
(60020075,1500200074,100,0,0,-1,-1,'',''),
(60020076,1500200075,100,0,0,-1,-1,'',''),
(60020077,1500200076,100,0,0,-1,-1,'',''),
(60020078,1500200077,100,0,0,-1,-1,'',''),
(60020079,1500200078,100,0,0,-1,-1,'',''),
(60020080,1500200079,100,0,0,-1,-1,'',''),
(60020081,1500200080,100,0,0,-1,-1,'',''),
(60020082,1500200081,100,0,0,-1,-1,'',''),
(60020083,1500200082,100,0,0,-1,-1,'',''),
(60020084,1500200083,100,0,0,-1,-1,'','');

INSERT INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,path_when_zone_idle,_condition,cond_value,animation,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
-- Haunted Cave (Crescent Reach: river bank + the two caves)
(45020038,60020032,'crescent',0,-2125.0,315.0,-95.88,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020039,60020033,'crescent',0,-2380.0,680.0,-71.25,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020040,60020034,'crescent',0,-2410.0,600.0,-71.25,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020041,60020034,'crescent',0,-2430.0,560.0,-71.25,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- PoK givers (evil quarter / bank trees)
(45020042,60020035,'poknowledge',0,185.0,650.0,-155.50,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020043,60020036,'poknowledge',0,325.0,300.0,-126.71,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020044,60020037,'poknowledge',0,330.0,250.0,-125.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- Out With the Old (kithicor, near the Rivervale trail)
(45020045,60020038,'kithicor',0,1068.0,1228.0,97.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020046,60020039,'kithicor',0,1092.0,1228.0,97.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020047,60020040,'kithicor',0,1040.0,1250.0,97.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- Skinwalker nameds: nektulos (10)
(45020048,60020041,'nektulos',0,-637.0,-581.0,-34.75,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020049,60020042,'nektulos',0,-760.0,-480.0,-34.75,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020050,60020043,'nektulos',0,-510.0,-700.0,-34.75,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020051,60020044,'nektulos',0,-820.0,-650.0,-34.75,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- lakeofillomen (20)
(45020052,60020045,'lakeofillomen',0,-2773.0,-1780.0,101.40,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020053,60020046,'lakeofillomen',0,-2900.0,-1650.0,101.40,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020054,60020047,'lakeofillomen',0,-2650.0,-1900.0,101.40,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020055,60020048,'lakeofillomen',0,-2550.0,-1700.0,101.40,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- firiona (30)
(45020056,60020049,'firiona',0,1466.0,-4566.0,-140.90,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020057,60020050,'firiona',0,1600.0,-4450.0,-140.90,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020058,60020051,'firiona',0,1330.0,-4700.0,-140.90,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020059,60020052,'firiona',0,1250.0,-4470.0,-140.90,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- emeraldjungle (40)
(45020060,60020053,'emeraldjungle',0,2580.0,1849.0,-340.38,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020061,60020054,'emeraldjungle',0,2720.0,1960.0,-340.38,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020062,60020055,'emeraldjungle',0,2440.0,1740.0,-340.38,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020063,60020056,'emeraldjungle',0,2360.0,1960.0,-340.38,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- mesa (50)
(45020064,60020057,'mesa',0,-13.0,-1720.0,68.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020065,60020058,'mesa',0,150.0,-1600.0,68.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020066,60020059,'mesa',0,-180.0,-1840.0,68.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020067,60020060,'mesa',0,250.0,-1900.0,-6.50,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- barren (60)
(45020068,60020061,'barren',0,-549.0,-179.0,-5.50,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020069,60020062,'barren',0,-420.0,-100.0,-5.50,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020070,60020063,'barren',0,-680.0,-260.0,-5.50,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020071,60020064,'barren',0,-300.0,-40.0,4.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- steppes (70)
(45020072,60020065,'steppes',0,-784.0,-1897.0,9.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020073,60020066,'steppes',0,-650.0,-1780.0,9.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020074,60020067,'steppes',0,-920.0,-2000.0,9.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020075,60020068,'steppes',0,-1055.0,-1859.0,4.13,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- lopingplains (80)
(45020076,60020069,'lopingplains',0,1770.0,2057.0,289.25,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020077,60020070,'lopingplains',0,1900.0,1950.0,289.25,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020078,60020071,'lopingplains',0,1640.0,2160.0,289.25,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020079,60020072,'lopingplains',0,1451.0,2559.0,239.88,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- Disturbed earth dig sites (10 zones, one each)
(45020080,60020073,'nektulos',0,-637.0,-581.0,-34.75,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020081,60020073,'lakeofillomen',0,-2975.0,-1694.0,102.10,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020082,60020073,'firiona',0,1489.0,-4464.0,-62.35,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020083,60020073,'emeraldjungle',0,2880.0,1474.0,-340.60,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020084,60020073,'mesa',0,250.0,-1948.0,-6.50,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020085,60020073,'barren',0,-58.0,-151.0,4.00,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020086,60020073,'steppes',0,-900.0,-1950.0,9.00,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020087,60020073,'lopingplains',0,1650.0,2300.0,260.00,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020088,60020073,'buriedsea',0,845.0,385.0,300.00,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020089,60020073,'oldfieldofbone',0,1315.0,300.0,-25.00,0.0,120,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
-- Under Your Skin pocket (gfaydark far east)
(45020090,60020076,'gfaydark',0,4440.0,1869.0,5.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween',''),
(45020091,60020080,'gfaydark',0,4455.0,1890.0,5.00,0.0,640,0,0,0,0,1,0,-1,-1,'peq_halloween','');

-- --- Loot --------------------------------------------------------------------
DELETE FROM loottable_entries WHERE loottable_id BETWEEN 200002 AND 200004;
DELETE FROM loottable         WHERE id BETWEEN 200002 AND 200004;
DELETE FROM lootdrop_entries  WHERE lootdrop_id BETWEEN 200002 AND 200004;
DELETE FROM lootdrop          WHERE id BETWEEN 200002 AND 200004;
INSERT INTO loottable (id,name,mincash,maxcash,avgcoin,done,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(200002,'notd_tattooed_zombie',0,0,0,0,-1,-1,'peq_halloween',''),
(200003,'notd_skinwalker_named',0,0,0,0,-1,-1,'peq_halloween',''),
(200004,'notd_void_commander',0,0,0,0,-1,-1,'peq_halloween','');
INSERT INTO lootdrop (id,name,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(200002,'notd_tattooed_zombie',-1,-1,'peq_halloween',''),
(200003,'notd_skinwalker_named',-1,-1,'peq_halloween',''),
(200004,'notd_void_commander',-1,-1,'peq_halloween','');
INSERT INTO lootdrop_entries (lootdrop_id,item_id,item_charges,equip_item,chance,disabled_chance,trivial_min_level,trivial_max_level,multiplier,npc_min_level,npc_max_level,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(200002,3001009,1,0,100,0,0,0,1,0,0,-1,-1,'',''),
(200003,3001011,1,0,100,0,0,0,1,0,0,-1,-1,'',''),
(200004,3001014,1,0,100,0,0,0,1,0,0,-1,-1,'','');
INSERT INTO loottable_entries (loottable_id,lootdrop_id,multiplier,droplimit,mindrop,probability) VALUES
(200002,200002,1,0,1,100),
(200003,200003,1,0,1,100),
(200004,200004,1,0,1,100);

-- --- Tasks -------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid BETWEEN 620012 AND 620017;
DELETE FROM tasks           WHERE id     BETWEEN 620012 AND 620017;
INSERT INTO tasks (id,type,duration,duration_code,title,description,reward_text,reward_id_list,cash_reward,exp_reward,reward_method,reward_points,min_level,max_level,level_spread,repeatable,completion_emote,enabled) VALUES
(620012,0,0,0,'Haunted Cave','Explore the haunted caves of Crescent Reach for Jilian Florantine.','Pirate''s Gold','3001007',0,0,0,0,0,0,0,1,'',1),
(620013,0,0,0,'Digging Their Graves','Dig up a grave with Edmund''s Shovel and slay whatever rises.','',NULL,0,0,0,0,0,0,0,1,'',1),
(620014,0,0,0,'The Hunt for Tattooed Flesh','Edmund needs five more burial duties done. Report back after each.','Frightening Writ','3001010',0,0,0,0,0,0,0,0,'',1),
(620015,0,0,0,'Terror of Illis Taberish','Slay four skinwalkers and bring their soul shards to Illis Taberish.','Vial of Chiropteranform','3001012',0,0,0,0,0,0,0,1,'',1),
(620016,0,0,0,'Under Your Skin','Enter the hiding spot in far Greater Faydark and root out the true Skinwalker.','Vial of the Wild Moon','3001013',0,0,0,0,0,0,0,1,'',1),
(620017,0,0,0,'Out With the Old','Hand A Silly Puppet Bristlebane''s Ticket of Admission and defend Kithicor from the Void Legion.','',NULL,0,0,0,0,0,0,0,1,'',1);

INSERT INTO task_activities (taskid,activityid,req_activity_id,step,activitytype,target_name,goalmethod,goalcount,description_override,npc_match_list,item_id_list,item_list,zones,zone_version,optional,list_group) VALUES
-- 620012 Haunted Cave
(620012,0,-1,1,0,'Ghost_of_All_Hallows_Eve',0,1,'Slay the Ghost of All Hallows Eve in the Nokk cave.','','','','394',-1,0,0),
(620012,1,-1,2,0,'Shadow_of_All_Hallows_Eve',0,2,'Slay 2 Shadows of All Hallows Eve in the undead cave.','','','','394',-1,0,0),
(620012,2,-1,3,255,'',0,1,'Return to Jilian Florantine.','','','','394',-1,0,0),
-- 620013 Digging Their Graves
(620013,0,-1,1,1,'',0,1,'Take Intricately Tattooed Flesh from a Tattooed Zombie.','','3001009','','',-1,0,0),
(620013,1,-1,2,255,'',0,1,'Return the flesh and Edmund''s Shovel to Edmund Strangeways.','','','','202',-1,0,0),
-- 620014 Hunt for Tattooed Flesh (master)
(620014,0,-1,1,255,'',0,1,'Complete a burial duty and report to Edmund (1/5).','','','','202',-1,0,0),
(620014,1,-1,2,255,'',0,1,'Complete a burial duty and report to Edmund (2/5).','','','','202',-1,0,0),
(620014,2,-1,3,255,'',0,1,'Complete a burial duty and report to Edmund (3/5).','','','','202',-1,0,0),
(620014,3,-1,4,255,'',0,1,'Complete a burial duty and report to Edmund (4/5).','','','','202',-1,0,0),
(620014,4,-1,5,255,'',0,1,'Complete a burial duty and report to Edmund (5/5).','','','','202',-1,0,0),
-- 620015 Terror of Illis Taberish
(620015,0,-1,1,0,'',0,4,'Slay 4 skinwalkers near your level band.','','1500200040|1500200041|1500200042|1500200043|1500200044|1500200045|1500200046|1500200047|1500200048|1500200049|1500200050|1500200051|1500200052|1500200053|1500200054|1500200055|1500200056|1500200057|1500200058|1500200059|1500200060|1500200061|1500200062|1500200063|1500200064|1500200065|1500200066|1500200067|1500200068|1500200069|1500200070|1500200071','','25|85|84|94|397|422|399|443',-1,0,0),
(620015,1,-1,2,255,'',0,1,'Deliver four Skinwalker''s Soul Shards to Illis Taberish in the Plane of Knowledge.','','','','202',-1,0,0),
-- 620016 Under Your Skin
(620016,0,-1,1,255,'',0,1,'Find and hail the Skinwalker hiding at the far east edge of Greater Faydark.','','','','54',-1,0,0),
(620016,1,-1,2,255,'',0,1,'Slay the true Skinwalker (fakes collapse into mist; only the true one falls).','','','','54',-1,0,0),
(620016,2,-1,3,255,'',0,1,'Hail Elder Ritualist Longshadow.','','','','54',-1,0,0),
-- 620017 Out With the Old
(620017,0,-1,1,255,'',0,1,'Repel the first wave of the Void Legion.','','','','20',-1,0,0),
(620017,1,-1,2,255,'',0,1,'Repel the second wave of the Void Legion.','','','','20',-1,0,0),
(620017,2,-1,3,0,'The_Legion_Commander_of_the_Void',0,1,'Slay The Legion Commander of the Void.','','','','20',-1,0,0),
(620017,3,-1,4,255,'',0,1,'Give the Void Artifact to Cathil.','','','','20',-1,0,0);

-- --- Gravedigger title (claim with /title while holding the Frightening Writ) -
DELETE FROM titles WHERE title_set = 300140;
INSERT INTO titles (skill_id,min_skill_value,max_skill_value,min_aa_points,max_aa_points,class,gender,char_id,status,item_id,prefix,suffix,title_set)
VALUES (-1,-1,-1,-1,-1,-1,-1,0,0,3001010,'','the Gravedigger',300140);

COMMIT;
