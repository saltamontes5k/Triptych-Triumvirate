-- SoD Rathe theme completion (raspersrealm themeRathe). Generated
-- by sod_content/gen_rathetheme.py -- do not hand-edit.
-- Twin content of manifest entry '20261013_sod_rathe_theme' (v150).
-- Sections: Mitius faction chain (npc_faction 1520000105, trash
-- RewardFaction flip, faction_association, 10 tasks -> 1225);
-- merchant 999999 Apprehensive items + Emblem of Earth; the 25
-- themeRathe achievement tasks 303147-303171; the 33 missing
-- themeRathe static named rares with page loot.

-- ============================================================
-- 1. Mitius, Herald of Change faction chain: primary faction for
--    the Warmly merchant gate; theme trash to the RewardFaction
--    path (-25/kill cascading +25 Mitius via faction_association,
--    which already pointed 1212/1213/1216/1220 -> 1225 in this DB;
--    the DELETE+INSERT keeps the twin self-contained); the 10
--    Rathe tasks flip from Cirtan to Mitius per the page.
-- ============================================================
DELETE FROM `npc_faction` WHERE `id` = 1520000105;
INSERT INTO `npc_faction` (`id`,`name`,`primaryfaction`,`ignore_primary_assist`) VALUES (1520000105,'overhaul_1225',1225,0);
UPDATE `npc_types` SET `npc_faction_id` = 1520000105 WHERE `id` = 475006;
-- Toskirakk Slavers/rallosian guards/invaders trash (npc_faction
-- 1520000085/86/88; the quest givers sharing 1520000085 are gated
-- on nothing and have no vendor, so the kill-path flip is inert
-- for them).
UPDATE `npc_types` SET `faction_amount` = -25 WHERE `npc_faction_id` IN (1520000085, 1520000086, 1520000088) AND `id` BETWEEN 475000 AND 476999;
-- Primal Crystallines trash (npc_faction 1520000090) by name: the
-- Darkhammer delvers share the row and stay on the classic path.
UPDATE `npc_types` SET `faction_amount` = -25 WHERE `npc_faction_id` = 1520000090 AND (`name` LIKE 'a\_crystalline%' OR `name` LIKE '#Crystalline%');
DELETE FROM `faction_association` WHERE `id` = 1212;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1212,1225,-1.0);
DELETE FROM `faction_association` WHERE `id` = 1213;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1213,1225,-1.0);
DELETE FROM `faction_association` WHERE `id` = 1216;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1216,1225,-1.0);
DELETE FROM `faction_association` WHERE `id` = 1220;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1220,1225,-1.0);
UPDATE `tasks` SET `faction_reward` = 1225 WHERE `id` IN (303030,303031,303032,303033,303034,303035,303036,303063,303077,303079);

-- ============================================================
-- 2. Mitius merchant (999999, shared with Cirtan/Tynoc): the four
--    page Apprehensive-tier items ungated + Emblem of Earth
--    (Ally tier = 1101). Warmly Rk. II scrolls already on the
--    list; buy prices live in items.price (pre-set). 42885/42886
--    were already stocked ungated at slots 3/4 (v110 pass); the
--    delete-by-item + insert-by-slot re-homes them with the rest
--    (merchantlist has a unique (merchantid,item) key).
-- ============================================================
DELETE FROM `merchantlist` WHERE `merchantid` = 999999 AND `item` IN (42820, 42821, 42885, 42886, 103103);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (999999,775,42820,0);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (999999,776,42821,0);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (999999,777,42886,0);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (999999,778,42885,0);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (999999,779,103103,1101);

-- ============================================================
-- 3. Fresh Supplies (48961) has no drop source (live hands it
--    out as a task item); wire it onto the war boar loottable at
--    100% for the Humble Petition loot step.
-- ============================================================
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` = 1520008502;
DELETE FROM `lootdrop` WHERE `id` = 1520008502;
DELETE FROM `loottable_entries` WHERE `lootdrop_id` = 1520008502;
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008502,'sod_rathe_supply_drop');
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (1520008502,48961,1,0,100,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (94834,1520008502,1,0,0,100);

-- ============================================================
-- 4. Theme tasks 303147-303171 (themeRathe achievement lists).
--    All givers are pre-existing PEQ spawns; offers live in
--    plugins/NMS_sod_utils.pl %SOD_OFFERS (v150 block). Type 0 =
--    solo, type 2 = shared group task (v143/v145 convention).
-- ============================================================
DELETE FROM `task_activities` WHERE `taskid` IN (303147,303148,303149,303150,303151,303152,303153,303154,303155,303156,303157,303158,303159,303160,303161,303162,303163,303164,303165,303166,303167,303168,303169,303170,303171);
DELETE FROM `tasks` WHERE `id` IN (303147,303148,303149,303150,303151,303152,303153,303154,303155,303156,303157,303158,303159,303160,303161,303162,303163,303164,303165,303166,303167,303168,303169,303170,303171);

INSERT INTO `tasks` (id,type,duration,duration_code,title,description,reward_text,reward_id_list,cash_reward,exp_reward,reward_method,reward_points,reward_point_type,min_level,max_level,level_spread,min_players,max_players,repeatable,faction_reward,completion_emote,replay_timer_group,replay_timer_seconds,request_timer_group,request_timer_seconds,dz_template_id,lock_activity_id,faction_amount,enabled) VALUES
(303147,0,0,0,'Times are a Chainin''','An injured slave begs a favor: the slavers carry shackle keys. Loot one from a Rallosian slaver and bring it to Dwerina Feystalker.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303148,0,0,0,'Millik''s Remains','Dwerina wants Millik''s remains recovered. The ogre ranks carry the hand, head and leg -- bring all three back.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303149,0,0,0,'Humble Petition','Petition the slaves for their grievances, then answer them: Fekden demands ten war boars culled before he releases Fresh Supplies for Dwerina.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303150,0,0,0,'Augury of Time','The tunnels to the central warrens are ambushed. Cut through the Rallosian slayers holding them, then report to Blurik the Runner.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303151,0,0,0,'The Cult of Lakkung','Namekeeper Tregnok and Spiritminder Loknar demand tribute for their cult: eight massive rat heads from the dreadrats of the caves.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303152,0,0,0,'Against the Grain','Wazlum wants the traitor Ganrik dealt with. Hunt him down and put him down -- he will not stay down easily.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303153,2,0,0,'Streets of Justice','Jink wants the marketplace cleaned up, starting with Basta Shivstalker''s thieves and ending with Kuddor Gakk''s stolen hornbook.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303154,0,0,0,'The Prince Must Die!','Galadvert has traced the clues of the prince''s court. Follow them to the Hall of Decrees and destroy its honor guard.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303155,0,0,0,'The Crimes of War','Four generals command the invasion. Arblok, Bardak and Grusix have their war crimes tallied -- remove them.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303156,0,0,0,'Massive Retaliation','Galadvert wants false orders planted. Give them to Ganekk Dopp and let the retaliation fall on his own head.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303157,0,0,0,'Fregg''s Challenge','Fregg the Tamer bets his pet Hurkka can break anyone. Prove him wrong three times over.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303158,0,0,0,'Blurik''s Toil','Blurik needs ward sergeant crystals for his augury. Break the sergeants and gather dasiron crystals from them.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303159,0,0,0,'Beetle Wrangling','Keruk Garrkol needs wrangled beetles for his herd. Cull eight giant death beetles from the pens and caves.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303160,2,0,0,'Cruel Overseers','Trilyaris plans a slave revolt. Break the Rallosian overseers lording over the work crews -- all fifteen of them.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303161,2,0,0,'Spies, Lies, and Prison Cells','The slave pens are guarded by the ward sergeants and their retainers. Cut a path through the prison detail.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303162,2,0,0,'Hiding in Plain Sight','Provisions for a hidden ally: slaver blood, bruiser bone, a seer''s ochre pouch and an emblem of Rallos Zek. Return them to Trilyaris.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303163,0,0,0,'Get to the Delve','Dalikand Darkhammer directs newcomers to the delve. Find Delver Hagorn deep in the warrens and make yourself known.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303164,0,0,0,'A Plague of Mephits','Hagorn wants the delve''s vermin plague thinned: the swarming crawlers of the tunnels, eight of them, dealt with.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303165,0,0,0,'Darkhammer Supply Run','The delve eats supplies. Strip thirty loads of materiel from the Rallosian ranks holding the warrens.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303166,0,0,0,'Supplication for Mercy','Hagorn''s supplication runs through Kaigrun and back to the slave camp. Carry the word and return.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303167,0,0,0,'Master of the Mines','Glerud Darkhammer contests the golem-broken mines. Speak with him, break five golems, and report the mines cleared.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303168,0,0,0,'Crystal Clarity','Ulgin maps the crystal warrens. Every strain must be sampled: corrupters, dischargers, exterminators, trichordonts and hulks.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303169,0,0,0,'Primal Terrors','The primal crystal fluid bleeds from everything crystalline in the northeast warrens. Collect twelve vials for Ulgin.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303170,0,0,0,'Unusual Properties','Ulgin studies the stranger strains. Break visceronts, spheres and aetheronts until their odd properties are accounted for.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303171,0,0,0,'Pinnacle of Destruction','The Imperiont rules the cave structure in the middle of the lake. Prove the dwarf hold secure: break it.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1);

INSERT INTO `task_activities` (taskid,activityid,req_activity_id,step,activitytype,target_name,goalmethod,goalcount,description_override,npc_match_list,item_id_list,item_list,dz_switch_id,min_x,min_y,min_z,max_x,max_y,max_z,skill_list,spell_list,zones,zone_version,optional,list_group) VALUES
(303147,0,-1,1,3,'a Toskirakk Shackle Key',0,1,'a Toskirakk Shackle Key','','48957','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303147,1,0,2,4,'Dwerina Feystalker',0,1,'Dwerina Feystalker','475002','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303148,0,-1,1,3,'Millik''s Head',0,1,'Millik''s Head','','48958','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303148,1,0,2,3,'Millik''s Hand',0,1,'Millik''s Hand','','48960','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303148,2,1,3,3,'Millik''s Leg',0,1,'Millik''s Leg','','48959','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303149,0,-1,1,4,'an elven slave',0,1,'an elven slave','475004','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303149,1,0,2,2,'the hulking war boars',0,10,'the hulking war boars','475044','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303149,2,1,3,3,'Fresh Supplies',0,1,'Fresh Supplies','','48961','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303149,3,2,4,4,'Dwerina Feystalker',0,1,'Dwerina Feystalker','475002','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303150,0,-1,1,2,'the Rallosian ambushers',0,6,'the Rallosian ambushers','475032','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303150,1,0,2,4,'Blurik the Runner',0,1,'Blurik the Runner','475029','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303151,0,-1,1,3,'a Massive Rat Head',0,8,'a Massive Rat Head','','88349','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303151,1,0,2,4,'Namekeeper Tregnok',0,1,'Namekeeper Tregnok','475064','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303151,2,1,3,4,'Spiritminder Loknar',0,1,'Spiritminder Loknar','475065','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303152,0,-1,1,2,'Ganrik',0,4,'Ganrik','475067','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303153,0,-1,1,4,'Muskorr Agitarr',0,1,'Muskorr Agitarr','475046','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303153,1,0,2,2,'the Shivstalker thieves',0,5,'the Shivstalker thieves','475050','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303153,2,1,3,2,'Basta Shivstalker',0,1,'Basta Shivstalker','475053','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303153,3,2,4,3,'Basta Shivstalker''s Head',0,1,'Basta Shivstalker''s Head','','88350','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303153,4,3,5,4,'Muskorr Agitarr',0,1,'Muskorr Agitarr','475046','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303153,5,4,6,2,'Kuddor Gakk',0,1,'Kuddor Gakk','475055','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303153,6,5,7,3,'the Hornbook of Toskirakk',0,1,'the Hornbook of Toskirakk','','41116','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303153,7,6,8,4,'Jink',0,1,'Jink','475010','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303154,0,-1,1,5,'the first clue',1,1,'the first clue','','','',0,-2405,751,14,-2305,851,114,'-1','0','toskirakk',-1,0,0),
(303154,1,0,2,5,'the second clue',1,1,'the second clue','','','',0,-2067,675,14,-1967,775,114,'-1','0','toskirakk',-1,0,0),
(303154,2,1,3,5,'the Hall of Decrees',1,1,'the Hall of Decrees','','','',0,-1650,468,223,-1550,568,323,'-1','0','toskirakk',-1,0,0),
(303154,3,2,4,2,'the Hall''s honor guard',0,3,'the Hall''s honor guard','475041|475026|475060','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303155,0,-1,1,2,'General Arblok',0,1,'General Arblok','475056','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303155,1,0,2,2,'General Bardak',0,1,'General Bardak','475039','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303155,2,1,3,2,'General Grusix',0,1,'General Grusix','1120002130','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303156,0,-1,1,4,'Ganekk Dopp',0,1,'Ganekk Dopp','475022','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303156,1,0,2,2,'Ganekk Dopp',0,1,'Ganekk Dopp','475022','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303157,0,-1,1,2,'Hurkka',0,3,'Hurkka','475057','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303158,0,-1,1,4,'Muskorr Agitarr',0,1,'Muskorr Agitarr','475046','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303158,1,0,2,2,'the Toskirakk ward sergeants',0,6,'the Toskirakk ward sergeants','475047','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303158,2,1,3,3,'a Dasiron Crystal',0,6,'a Dasiron Crystal','','41113','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303159,0,-1,1,2,'the giant death beetles',0,8,'the giant death beetles','475043|475062','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303160,0,-1,1,2,'the Rallosian overseers',0,15,'the Rallosian overseers','475041|475026|475060','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303161,0,-1,1,2,'the guard commanders',0,2,'the guard commanders','475047','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303161,1,0,2,2,'the prison detail',0,8,'the prison detail','475041|475026|475060','','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303162,0,-1,1,3,'a Vial of Slaver Blood',0,1,'a Vial of Slaver Blood','','60335','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303162,1,0,2,3,'a Toskirakk Bruiser Bone',0,1,'a Toskirakk Bruiser Bone','','60336','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303162,2,1,3,3,'a Seer''s Ochre Pouch',0,1,'a Seer''s Ochre Pouch','','60337','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303162,3,2,4,3,'an Emblem of Rallos Zek',0,1,'an Emblem of Rallos Zek','','60338','',0,0,0,0,0,0,0,'-1','0','toskirakk',-1,0,0),
(303162,4,3,5,4,'Trilyaris',0,1,'Trilyaris','475005','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303163,0,-1,1,4,'Delver Hagorn',0,1,'Delver Hagorn','476043','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303164,0,-1,1,2,'the delve vermin',0,8,'the delve vermin','476127|476130|476089','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303165,0,-1,1,2,'the Rallosian warrens detail',0,30,'the Rallosian warrens detail','476056|476069|476070|476071|476074|476075|476076|476078|476080|476083|476084|476086|476091|476099|476101|476102|476103|476106|476107|476109|476123','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303166,0,-1,1,4,'Kaigrun Darkhammer',0,1,'Kaigrun Darkhammer','476038','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303166,1,0,2,4,'Dwerina Feystalker',0,1,'Dwerina Feystalker','475002','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303166,2,1,3,4,'Kaigrun Darkhammer',0,1,'Kaigrun Darkhammer','476038','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303166,3,2,4,4,'Delver Hagorn',0,1,'Delver Hagorn','476043','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303167,0,-1,1,4,'Glerud Darkhammer',0,1,'Glerud Darkhammer','476095','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303167,1,0,2,2,'the mine golems',0,5,'the mine golems','476065|476047|476064','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303167,2,1,3,4,'Glerud Darkhammer',0,1,'Glerud Darkhammer','476095','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303168,0,-1,1,2,'crystalline corrupters',0,2,'crystalline corrupters','476002','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303168,1,0,2,2,'crystalline dischargers',0,2,'crystalline dischargers','476025','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303168,2,1,3,2,'crystalline exterminators',0,2,'crystalline exterminators','476001','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303168,3,2,4,2,'crystalline trichordonts',0,2,'crystalline trichordonts','476000','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303168,4,3,5,2,'crystalline hulks',0,2,'crystalline hulks','476093|476111','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303168,5,4,6,4,'Ulgin Darkhammer',0,1,'Ulgin Darkhammer','476041','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303169,0,-1,1,3,'a Vial of Primal Crystal Fluid',0,12,'a Vial of Primal Crystal Fluid','','41253','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303169,1,0,2,4,'Ulgin Darkhammer',0,1,'Ulgin Darkhammer','476041','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303170,0,-1,1,2,'crystalline visceronts',0,4,'crystalline visceronts','476027|476029|476042','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303170,1,0,2,2,'crystalline spheres',0,4,'crystalline spheres','476004|476005|476017','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303170,2,1,3,2,'crystalline aetheronts',0,4,'crystalline aetheronts','476028','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303170,3,2,4,4,'Ulgin Darkhammer',0,1,'Ulgin Darkhammer','476041','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303171,0,-1,1,2,'Crystalline Imperiont',0,1,'Crystalline Imperiont','476020','','',0,0,0,0,0,0,0,'-1','0','korascian',-1,0,0),
(303171,1,0,2,4,'Ulgin Darkhammer',0,1,'Ulgin Darkhammer','476041','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0);

-- Faction rewards: every themeRathe task raises Mitius, Herald of Change (1225, +150, page: every quest in the theme raises this faction).
UPDATE `tasks` SET `faction_reward` = 1225, `faction_amount` = 150 WHERE `id` IN (303147,303148,303149,303150,303151,303152,303153,303154,303155,303156,303157,303158,303159,303160,303161,303162,303163,303164,303165,303166,303167,303168,303169,303170,303171);

-- ============================================================
-- 5. Theme static named rares: donor clones, always up, page
--    loot (last item 15%, the rest 25%; missing names skipped).
--    Spawn points are real elite spawn2 coordinates read at
--    generation time.
-- ============================================================
DELETE FROM `npc_types` WHERE `id` BETWEEN 1120002110 AND 1120002142;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 1520008760 AND 1520008792;
DELETE FROM `spawn2` WHERE `spawngroupID` BETWEEN 1520008760 AND 1520008792;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 1520008760 AND 1520008792;
DELETE FROM `loottable_entries` WHERE `loottable_id` BETWEEN 1520008430 AND 1520008462;
DELETE FROM `loottable` WHERE `id` BETWEEN 1520008430 AND 1520008462;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 1520008469 AND 1520008501;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 1520008469 AND 1520008501;

DROP TEMPORARY TABLE IF EXISTS sod_rathe_rare_nt;
CREATE TEMPORARY TABLE sod_rathe_rare_nt AS SELECT * FROM npc_types WHERE 0;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475027;
UPDATE sod_rathe_rare_nt SET id = 1120002110, name = 'Borskar', level = 85, hp = 250000, mana = 0, loottable_id = 1520008430, merchant_id = 0, faction_amount = -25 WHERE id = 475027;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475054;
UPDATE sod_rathe_rare_nt SET id = 1120002111, name = 'Brusk_of_Oggok', level = 85, hp = 250000, mana = 0, loottable_id = 1520008431, merchant_id = 0, faction_amount = -25 WHERE id = 475054;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475047;
UPDATE sod_rathe_rare_nt SET id = 1120002112, name = 'Captain_Tregenek', level = 85, hp = 250000, mana = 0, loottable_id = 1520008432, merchant_id = 0, faction_amount = -25 WHERE id = 475047;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475054;
UPDATE sod_rathe_rare_nt SET id = 1120002113, name = 'Frundil', level = 85, hp = 250000, mana = 0, loottable_id = 1520008433, merchant_id = 0, faction_amount = -25 WHERE id = 475054;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475044;
UPDATE sod_rathe_rare_nt SET id = 1120002114, name = 'Graknar_the_Bull', level = 86, hp = 300000, mana = 0, loottable_id = 1520008434, merchant_id = 0, faction_amount = -25 WHERE id = 475044;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475027;
UPDATE sod_rathe_rare_nt SET id = 1120002115, name = 'Griddunk', level = 85, hp = 250000, mana = 0, loottable_id = 1520008435, merchant_id = 0, faction_amount = -25 WHERE id = 475027;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475054;
UPDATE sod_rathe_rare_nt SET id = 1120002116, name = 'Kuris_the_Garbage_Eater', level = 85, hp = 250000, mana = 0, loottable_id = 1520008436, merchant_id = 0, faction_amount = -25 WHERE id = 475054;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475004;
UPDATE sod_rathe_rare_nt SET id = 1120002117, name = 'Sturk_the_Insane_Froglok_Slave', level = 85, hp = 250000, mana = 0, loottable_id = 1520008437, merchant_id = 0, faction_amount = -25 WHERE id = 475004;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475054;
UPDATE sod_rathe_rare_nt SET id = 1120002118, name = 'Tonkk_the_Axestopper', level = 85, hp = 250000, mana = 0, loottable_id = 1520008438, merchant_id = 0, faction_amount = -25 WHERE id = 475054;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475032;
UPDATE sod_rathe_rare_nt SET id = 1120002119, name = 'Treblor_the_Slasher', level = 85, hp = 250000, mana = 0, loottable_id = 1520008439, merchant_id = 0, faction_amount = -25 WHERE id = 475032;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475030;
UPDATE sod_rathe_rare_nt SET id = 1120002120, name = 'Ulgren_Vith', level = 85, hp = 250000, mana = 0, loottable_id = 1520008440, merchant_id = 0, faction_amount = -25 WHERE id = 475030;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475033;
UPDATE sod_rathe_rare_nt SET id = 1120002121, name = 'Vessa_the_Oracle', level = 85, hp = 250000, mana = 0, loottable_id = 1520008441, merchant_id = 0, faction_amount = -25 WHERE id = 475033;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 475028;
UPDATE sod_rathe_rare_nt SET id = 1120002122, name = 'Vruten_the_Intendant', level = 85, hp = 250000, mana = 0, loottable_id = 1520008442, merchant_id = 0, faction_amount = -25 WHERE id = 475028;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476109;
UPDATE sod_rathe_rare_nt SET id = 1120002123, name = 'Auliggis', level = 86, hp = 280000, mana = 0, loottable_id = 1520008443, merchant_id = 0, faction_amount = -25 WHERE id = 476109;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476000;
UPDATE sod_rathe_rare_nt SET id = 1120002124, name = 'Crystalline_Auridont', level = 87, hp = 300000, mana = 0, loottable_id = 1520008444, merchant_id = 0, faction_amount = -25 WHERE id = 476000;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476000;
UPDATE sod_rathe_rare_nt SET id = 1120002125, name = 'Crystalline_Pyrodont', level = 87, hp = 300000, mana = 0, loottable_id = 1520008445, merchant_id = 0, faction_amount = -25 WHERE id = 476000;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476000;
UPDATE sod_rathe_rare_nt SET id = 1120002126, name = 'Crystalline_Thaumadont', level = 87, hp = 300000, mana = 0, loottable_id = 1520008446, merchant_id = 0, faction_amount = -25 WHERE id = 476000;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476028;
UPDATE sod_rathe_rare_nt SET id = 1120002127, name = 'Ezal', level = 86, hp = 280000, mana = 0, loottable_id = 1520008447, merchant_id = 0, faction_amount = -25 WHERE id = 476028;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476044;
UPDATE sod_rathe_rare_nt SET id = 1120002128, name = 'Felsa_Kabbek', level = 86, hp = 280000, mana = 0, loottable_id = 1520008448, merchant_id = 0, faction_amount = -25 WHERE id = 476044;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476004;
UPDATE sod_rathe_rare_nt SET id = 1120002129, name = 'Fracture', level = 86, hp = 280000, mana = 0, loottable_id = 1520008449, merchant_id = 0, faction_amount = -25 WHERE id = 476004;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476103;
UPDATE sod_rathe_rare_nt SET id = 1120002130, name = 'General_Grusix', level = 86, hp = 280000, mana = 0, loottable_id = 1520008450, merchant_id = 0, faction_amount = -25 WHERE id = 476103;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476070;
UPDATE sod_rathe_rare_nt SET id = 1120002131, name = 'Gradd_the_Mutineer', level = 86, hp = 280000, mana = 0, loottable_id = 1520008451, merchant_id = 0, faction_amount = -25 WHERE id = 476070;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476102;
UPDATE sod_rathe_rare_nt SET id = 1120002132, name = 'Mauk_Peskysnout', level = 86, hp = 280000, mana = 0, loottable_id = 1520008452, merchant_id = 0, faction_amount = -25 WHERE id = 476102;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476078;
UPDATE sod_rathe_rare_nt SET id = 1120002133, name = 'Perd_Kraknakk', level = 86, hp = 280000, mana = 0, loottable_id = 1520008453, merchant_id = 0, faction_amount = -25 WHERE id = 476078;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476103;
UPDATE sod_rathe_rare_nt SET id = 1120002134, name = 'Provost_Vokk_Raskk', level = 87, hp = 300000, mana = 0, loottable_id = 1520008454, merchant_id = 0, faction_amount = -25 WHERE id = 476103;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476083;
UPDATE sod_rathe_rare_nt SET id = 1120002135, name = 'Reuk_the_Portal_Tender', level = 86, hp = 280000, mana = 0, loottable_id = 1520008455, merchant_id = 0, faction_amount = -25 WHERE id = 476083;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476000;
UPDATE sod_rathe_rare_nt SET id = 1120002136, name = 'Shem_Saldon', level = 86, hp = 280000, mana = 0, loottable_id = 1520008456, merchant_id = 0, faction_amount = -25 WHERE id = 476000;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476106;
UPDATE sod_rathe_rare_nt SET id = 1120002137, name = 'Slaukk_the_Messcook', level = 86, hp = 280000, mana = 0, loottable_id = 1520008457, merchant_id = 0, faction_amount = -25 WHERE id = 476106;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 476093;
UPDATE sod_rathe_rare_nt SET id = 1120002138, name = 'Uk', level = 87, hp = 300000, mana = 0, loottable_id = 1520008458, merchant_id = 0, faction_amount = -25 WHERE id = 476093;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 477005;
UPDATE sod_rathe_rare_nt SET id = 1120002139, name = 'Glithos', level = 87, hp = 300000, mana = 0, loottable_id = 1520008459, merchant_id = 0, faction_amount = -25 WHERE id = 477005;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 477017;
UPDATE sod_rathe_rare_nt SET id = 1120002140, name = 'Glutch_the_Heap', level = 87, hp = 300000, mana = 0, loottable_id = 1520008460, merchant_id = 0, faction_amount = -25 WHERE id = 477017;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 477041;
UPDATE sod_rathe_rare_nt SET id = 1120002141, name = 'The_Rathe_Librarian', level = 87, hp = 300000, mana = 0, loottable_id = 1520008461, merchant_id = 0, faction_amount = -25 WHERE id = 477041;
INSERT INTO sod_rathe_rare_nt SELECT * FROM npc_types WHERE id = 477016;
UPDATE sod_rathe_rare_nt SET id = 1120002142, name = 'Yoz`an_the_Ritualist', level = 87, hp = 300000, mana = 0, loottable_id = 1520008462, merchant_id = 0, faction_amount = -25 WHERE id = 477016;
INSERT INTO `npc_types` SELECT * FROM sod_rathe_rare_nt;
DROP TEMPORARY TABLE sod_rathe_rare_nt;

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008430,'sod_rathe_borskar',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008469,'sod_rathe_borskar_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008430,1520008469,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008469,105802,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008469,105807,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008469,106302,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008469,106307,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008431,'sod_rathe_brusk',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008470,'sod_rathe_brusk_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008431,1520008470,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008470,105828,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008470,105866,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008470,106328,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008432,'sod_rathe_tregenek',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008471,'sod_rathe_tregenek_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008432,1520008471,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008471,105843,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008471,105844,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008471,106343,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008471,106344,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008433,'sod_rathe_frundil',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008472,'sod_rathe_frundil_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008433,1520008472,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008472,105820,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008472,105867,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008472,106320,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008434,'sod_rathe_graknar',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008473,'sod_rathe_graknar_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008434,1520008473,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008473,105800,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008473,105805,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008473,106300,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008473,106305,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008435,'sod_rathe_griddunk',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008474,'sod_rathe_griddunk_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008435,1520008474,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008474,105826,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008474,105846,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008474,106326,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008474,106346,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008436,'sod_rathe_kuris',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008475,'sod_rathe_kuris_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008436,1520008475,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008475,105814,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008475,105834,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008475,106314,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008475,106334,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008437,'sod_rathe_sturk',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008476,'sod_rathe_sturk_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008437,1520008476,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008476,105812,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008476,105830,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008476,106312,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008476,106330,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008438,'sod_rathe_tonkk',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008477,'sod_rathe_tonkk_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008438,1520008477,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008477,105840,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008477,105855,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008477,106340,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008477,106355,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008439,'sod_rathe_treblor',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008478,'sod_rathe_treblor_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008439,1520008478,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008478,105801,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008478,105806,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008478,106301,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008478,106306,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008440,'sod_rathe_ulgren',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008479,'sod_rathe_ulgren_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008440,1520008479,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008479,105816,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008479,105858,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008479,106316,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008441,'sod_rathe_vessa',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008480,'sod_rathe_vessa_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008441,1520008480,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008480,105827,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008480,105832,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008480,106327,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008480,106332,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008442,'sod_rathe_vruten',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008481,'sod_rathe_vruten_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008442,1520008481,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008481,105815,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008481,105856,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008481,106315,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008443,'sod_rathe_auliggis',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008482,'sod_rathe_auliggis_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008443,1520008482,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008482,105821,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008482,105862,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008482,106321,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008444,'sod_rathe_auridont',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008483,'sod_rathe_auridont_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008444,1520008483,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008483,105825,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008483,105859,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008483,106325,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008445,'sod_rathe_pyrodont',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008484,'sod_rathe_pyrodont_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008445,1520008484,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008484,105829,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008484,105849,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008484,106329,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008484,106349,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008446,'sod_rathe_thaumadont',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008485,'sod_rathe_thaumadont_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008446,1520008485,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008485,105824,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008485,105857,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008485,106324,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008447,'sod_rathe_ezal',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008486,'sod_rathe_ezal_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008447,1520008486,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008486,105823,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008486,105863,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008486,106323,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008448,'sod_rathe_felsa',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008487,'sod_rathe_felsa_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008448,1520008487,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008487,105817,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008487,105865,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008487,106317,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008449,'sod_rathe_fracture',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008488,'sod_rathe_fracture_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008449,1520008488,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008488,105803,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008488,105839,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008488,106303,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008488,106339,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008450,'sod_rathe_grusix',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008489,'sod_rathe_grusix_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008450,1520008489,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008489,105804,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008489,105851,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008489,106304,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008489,106351,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008451,'sod_rathe_gradd',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008490,'sod_rathe_gradd_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008451,1520008490,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008490,105833,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008490,105854,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008490,106333,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008490,106354,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008452,'sod_rathe_mauk',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008491,'sod_rathe_mauk_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008452,1520008491,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008491,105836,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008491,105853,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008491,106336,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008491,106353,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008453,'sod_rathe_perd',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008492,'sod_rathe_perd_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008453,1520008492,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008492,105842,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008492,105845,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008492,106342,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008492,106345,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008454,'sod_rathe_vokk',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008493,'sod_rathe_vokk_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008454,1520008493,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008493,105810,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008493,105835,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008493,106310,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008493,106335,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008455,'sod_rathe_reuk',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008494,'sod_rathe_reuk_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008455,1520008494,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008494,105809,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008494,105847,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008494,106309,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008494,106347,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008456,'sod_rathe_shem',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008495,'sod_rathe_shem_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008456,1520008495,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008495,105818,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008495,105848,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008495,106318,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008495,106348,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008457,'sod_rathe_slaukk',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008496,'sod_rathe_slaukk_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008457,1520008496,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008496,105813,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008496,105841,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008496,106313,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008496,106341,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008458,'sod_rathe_uk',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008497,'sod_rathe_uk_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008458,1520008497,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008497,105822,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008497,105861,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008497,106322,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008459,'sod_rathe_glithos',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008498,'sod_rathe_glithos_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008459,1520008498,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008498,105808,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008498,105831,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008498,106308,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008498,106331,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008460,'sod_rathe_glutch',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008499,'sod_rathe_glutch_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008460,1520008499,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008499,105838,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008499,105864,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008499,106338,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008461,'sod_rathe_librarian',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008500,'sod_rathe_librarian_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008461,1520008500,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008500,105819,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008500,105852,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008500,106319,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008500,106352,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008462,'sod_rathe_yozan',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008501,'sod_rathe_yozan_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008462,1520008501,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008501,105850,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008501,105860,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008501,106350,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008760,'sod_rathe_rare_borskar',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008760,1120002110,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008760,'toskirakk',0,-1639.12,-268.75,434.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008761,'sod_rathe_rare_brusk',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008761,1120002111,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008761,'toskirakk',0,-375.0,347.0,19.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008762,'sod_rathe_rare_tregenek',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008762,1120002112,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008762,'toskirakk',0,144.0,34.62,-2.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008763,'sod_rathe_rare_frundil',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008763,1120002113,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008763,'toskirakk',0,1003.5,-562.62,69.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008764,'sod_rathe_rare_graknar',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008764,1120002114,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008764,'toskirakk',0,1199.88,-1427.88,288.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008765,'sod_rathe_rare_griddunk',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008765,1120002115,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008765,'toskirakk',0,1294.0,-1131.0,66.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008766,'sod_rathe_rare_kuris',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008766,1120002116,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008766,'toskirakk',0,1457.88,-489.25,69.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008767,'sod_rathe_rare_sturk',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008767,1120002117,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008767,'toskirakk',0,1581.0,-750.0,69.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008768,'sod_rathe_rare_tonkk',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008768,1120002118,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008768,'toskirakk',0,1750.75,-903.0,279.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008769,'sod_rathe_rare_treblor',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008769,1120002119,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008769,'toskirakk',0,1872.0,407.0,160.38,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008770,'sod_rathe_rare_ulgren',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008770,1120002120,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008770,'toskirakk',0,2226.0,-849.88,67.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008771,'sod_rathe_rare_vessa',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008771,1120002121,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008771,'toskirakk',0,2526.0,-360.88,286.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008772,'sod_rathe_rare_vruten',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008772,1120002122,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008772,'toskirakk',0,2918.25,108.0,291.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008773,'sod_rathe_rare_auliggis',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008773,1120002123,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008773,'korascian',0,-2805.0,1513.0,-44.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008774,'sod_rathe_rare_auridont',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008774,1120002124,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008774,'korascian',0,-2337.0,1196.0,-56.12,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008775,'sod_rathe_rare_pyrodont',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008775,1120002125,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008775,'korascian',0,-2118.88,51.0,-36.12,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008776,'sod_rathe_rare_thaumadont',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008776,1120002126,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008776,'korascian',0,-1996.75,552.62,-15.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008777,'sod_rathe_rare_ezal',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008777,1120002127,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008777,'korascian',0,-1885.0,1648.0,-46.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008778,'sod_rathe_rare_felsa',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008778,1120002128,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008778,'korascian',0,-1645.88,1071.75,-43.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008779,'sod_rathe_rare_fracture',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008779,1120002129,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008779,'korascian',0,-1330.25,1929.88,-49.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008780,'sod_rathe_rare_grusix',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008780,1120002130,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008780,'korascian',0,-1157.0,1936.0,-50.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008781,'sod_rathe_rare_gradd',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008781,1120002131,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008781,'korascian',0,-983.88,2961.88,-43.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008782,'sod_rathe_rare_mauk',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008782,1120002132,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008782,'korascian',0,-836.12,2799.5,-46.38,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008783,'sod_rathe_rare_perd',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008783,1120002133,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008783,'korascian',0,-749.25,3076.25,-42.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008784,'sod_rathe_rare_vokk',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008784,1120002134,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008784,'korascian',0,-661.0,2629.0,-48.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008785,'sod_rathe_rare_reuk',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008785,1120002135,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008785,'korascian',0,-192.0,1464.0,-87.38,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008786,'sod_rathe_rare_shem',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008786,1120002136,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008786,'korascian',0,121.0,628.0,-32.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008787,'sod_rathe_rare_slaukk',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008787,1120002137,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008787,'korascian',0,456.12,1094.88,-33.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008788,'sod_rathe_rare_uk',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008788,1120002138,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008788,'korascian',0,1061.0,927.0,-7.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008789,'sod_rathe_rare_glithos',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008789,1120002139,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008789,'rathechamber',0,-2064.62,1846.75,-110.38,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008790,'sod_rathe_rare_glutch',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008790,1120002140,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008790,'rathechamber',0,-1207.0,1106.0,-122.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008791,'sod_rathe_rare_librarian',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008791,1120002141,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008791,'rathechamber',0,-889.88,284.25,-32.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008792,'sod_rathe_rare_yozan',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008792,1120002142,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008792,'rathechamber',0,-575.5,886.0,-38.25,0,3600);
