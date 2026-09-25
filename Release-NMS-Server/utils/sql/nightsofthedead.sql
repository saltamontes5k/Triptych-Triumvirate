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
DELETE FROM task_activities WHERE taskid BETWEEN 620004 AND 620099;
DELETE FROM tasks           WHERE id     BETWEEN 620004 AND 620099;
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
