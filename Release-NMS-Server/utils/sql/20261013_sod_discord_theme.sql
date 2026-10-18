-- SoD Discord theme completion (raspersrealm themeDiscord). Generated
-- by sod_content/gen_discotheme.py -- do not hand-edit.
-- Twin content of manifest entry '20261013_sod_discord_theme' (v152).
-- Sections: the two-herald faction chain (Argoth 1226 / Druzzil Ro
-- 1227; Korafax trash gets its own faction 5058 because the
-- association table is single-target per source); Argoth merchant
-- 472002 page stock; the 15 themeDiscord partisan tasks 303172-186;
-- Babel crystal task-loot wiring; the 29 missing themeDiscord static
-- rares with page loot (+ appended drops on #Grg`nok and #Shzalk).

-- ============================================================
-- 1. Faction: npc_faction 1520000106 -> Argoth (1226) for the
--    Bloodfields/Dranik herald and quest NPCs (moving the dragorn
--    partisans OFF the trash rows also repairs a latent KOS bug for
--    GoD veterans); 1520000107 -> Druzzil Ro (1227) for the Korafax
--    herald and quest NPCs; 1520000108 -> new faction_list 5058
--    'Korafax Discordians' so Korafax kills cascade to 1227 while
--    BF/CoD kills (1209/1210/1013/1767/1768) cascade to 1226 -- the
--    association table holds one target per source faction. All
--    theme trash to the RewardFaction path (-25/kill). The 15
--    existing Discord tasks flip from Cirtan 1222 per the page.
-- ============================================================
DELETE FROM `faction_list` WHERE `id` = 5058;
INSERT INTO `faction_list` (`id`,`name`,`base`) VALUES (5058,'Korafax Discordians',0);
DELETE FROM `npc_faction` WHERE `id` IN (1520000106, 1520000107, 1520000108);
INSERT INTO `npc_faction` (`id`,`name`,`primaryfaction`,`ignore_primary_assist`) VALUES (1520000106,'overhaul_1226',1226,0), (1520000107,'overhaul_1227',1227,0), (1520000108,'korafax_discordant',5058,0);
-- Herald Argoth (472002) + the Bloodfields/Dranik quest NPCs.
UPDATE `npc_types` SET `npc_faction_id` = 1520000106 WHERE `id` IN (472002,472022,472039,472051,472055,472056,472057,474005,474011,474012,474016,474019,474036);
-- Herald of Druzzil Ro (470001) + the Korafax quest NPCs.
UPDATE `npc_types` SET `npc_faction_id` = 1520000107 WHERE `id` IN (470000,470001,470020);
-- Korafax trash (discord 470xxx) onto its own faction with the kill
-- flip; the quest NPCs above were moved off 1520000083 first.
UPDATE `npc_types` SET `npc_faction_id` = 1520000108, `faction_amount` = -25 WHERE `npc_faction_id` = 1520000083 AND `id` BETWEEN 470000 AND 470999;
-- Bloodfields/Dranik discordian trash (Discordant Army 1210, Dragorn
-- Forces 1209, OMM ukun 1013, Hexxt 1767, Rav 1768).
UPDATE `npc_types` SET `faction_amount` = -25 WHERE `npc_faction_id` = 1520000083 AND `id` BETWEEN 472000 AND 474999;
UPDATE `npc_types` SET `faction_amount` = -25 WHERE `npc_faction_id` = 1520000082 AND `id` BETWEEN 474000 AND 474999;
UPDATE `npc_types` SET `faction_amount` = -25 WHERE `npc_faction_id` IN (1048, 727, 728) AND `id` BETWEEN 472000 AND 474999;
-- Association re-points (replacing the old mutual/noise targets).
DELETE FROM `faction_association` WHERE `id` = 1210;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1210,1226,-1.0);
DELETE FROM `faction_association` WHERE `id` = 1209;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1209,1226,-1.0);
DELETE FROM `faction_association` WHERE `id` = 1013;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1013,1226,-1.0);
DELETE FROM `faction_association` WHERE `id` = 1767;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1767,1226,-1.0);
DELETE FROM `faction_association` WHERE `id` = 1768;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (1768,1226,-1.0);
DELETE FROM `faction_association` WHERE `id` = 5058;
INSERT INTO `faction_association` (`id`,`id_1`,`mod_1`) VALUES (5058,1227,-1.0);
-- Task flips: Bloodfields missions -> Argoth; Korafax arc, raids and
-- the tower -> Druzzil Ro (amounts kept at the v91 values).
UPDATE `tasks` SET `faction_reward` = 1226 WHERE `id` IN (303040,303041);
UPDATE `tasks` SET `faction_reward` = 1227 WHERE `id` IN (303042,303043,303044,303045,303046,303047,303048,303049,303050,303051,303064,303065,303066,303067);

-- ============================================================
-- 2. Argoth's merchant 472002: the page's Bloodfields lists --
--    Apprehensive coalescing/repair items (-1100, the merchant's
--    v110 convention), Warmly Rk. II spells (750), Ally Faycite
--    Shards + Emblem of Chaos (1101, the v150 tier convention).
--    'Song: Tempest Blade' is skipped: no such spell exists in
--    this content set and a dead scroll would ship broken. The
--    Korafax herald's 470001 stock already matches the page.
-- ============================================================
DELETE FROM `merchantlist` WHERE `merchantid` = 472002 AND `slot` BETWEEN 57 AND 89;
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,57,42851,-1100);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,58,42885,-1100);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,59,42886,-1100);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,60,118435,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,61,118810,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,62,119067,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,63,118251,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,64,119208,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,65,118593,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,66,119453,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,67,118763,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,68,118930,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,69,118103,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,70,119306,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,71,117967,750);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,72,101422,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,73,101391,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,74,101390,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,75,101397,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,76,101469,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,77,101493,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,78,101482,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,79,101446,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,80,101431,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,81,101458,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,82,101414,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,83,101440,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,84,101451,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,85,101476,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,86,101405,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,87,101399,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,88,101437,1101);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`,`faction_required`) VALUES (472002,89,103104,1101);

-- ============================================================
-- 3. Babel crystal task loot: the partisan crystal steps have no
--    drop source (live hands the pieces out as rewards). Wire the
--    Chip onto the Old Bloodfields ikaav castigator loottable and
--    the Shard onto the City of Dranik loottable at 30%.
-- ============================================================
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` IN (1520008532, 1520008533);
DELETE FROM `lootdrop` WHERE `id` IN (1520008532, 1520008533);
DELETE FROM `loottable_entries` WHERE `lootdrop_id` IN (1520008532, 1520008533);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008532,'sod_disco_chip_drop'), (1520008533,'sod_disco_shard_drop');
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (1520008532,42825,1,0,30,0,0,0,1,0,0,-1,-1), (1520008533,42828,1,0,30,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (94790,1520008532,1,0,0,100), (94816,1520008533,1,0,0,100);

-- ============================================================
-- 4. Theme tasks 303172-303186 (themeDiscord achievement lists).
--    All givers are pre-existing spawns (now on npc_faction
--    1520000106); offers live in plugins/NMS_sod_utils.pl
--    %SOD_OFFERS (v152 block). Type 0 solo per the page (no (g)
--    marks on either partisan list).
-- ============================================================
DELETE FROM `task_activities` WHERE `taskid` IN (303172,303173,303174,303175,303176,303177,303178,303179,303180,303181,303182,303183,303184,303185,303186);
DELETE FROM `tasks` WHERE `id` IN (303172,303173,303174,303175,303176,303177,303178,303179,303180,303181,303182,303183,303184,303185,303186);

INSERT INTO `tasks` (id,type,duration,duration_code,title,description,reward_text,reward_id_list,cash_reward,exp_reward,reward_method,reward_points,reward_point_type,min_level,max_level,level_spread,min_players,max_players,repeatable,faction_reward,completion_emote,replay_timer_group,replay_timer_seconds,request_timer_group,request_timer_seconds,dz_template_id,lock_activity_id,faction_amount,enabled) VALUES
(303172,0,0,0,'Lost Memories','Noble Yemall''s memories scatter with the timeshear. The ikaav casters carry them as babel crystal chips -- gather three and bring them back to her.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303173,0,0,0,'Supply Interruption','Noble Ramel has mapped the supply lines: the fleshhounds haul the spoil and Xirisst commands the haul. Break the dogs, then put down the quartermaster.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303174,0,0,0,'Deliver the Message','Noble Mikuv has word for the commander, and the commander has word for the general. Carry both and return.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303175,0,0,0,'The Kyv are Coming','Commander Prezul counts the discordian archers massing at the treeline. Thin them -- twenty of the kyv.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303176,0,0,0,'Impairing the Ikaav','The ikaav casters bleed the fields with their rites. Impair them -- twenty of the corrupters and deathbeckoners.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303177,0,0,0,'Undoing the Ukun','The ukun wardens hold the field''s approaches. Undo them -- twenty of the hounds and guards.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303178,0,0,0,'Knockdown the Noc','The noc tear at whatever still stands. Knock them down -- twenty of the darklurches, fleshletters and flashblades.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303179,0,0,0,'The Ultimate Weapon','Nahsulen reads the discord''s design: they are grafting a siege beast in the fields, and Acolyte Maarnek is the hand that animates it. Break the acolyte and his castigator keepers.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303180,0,0,0,'Lifting the Fog','General Azerug cannot move while the discord''s fog patrols hold the avenues. Lift the fog: fifteen of the fleshhounds and despisers.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303181,0,0,0,'Vile Weaponry','Grithyank Avlonnon wants the armed ranks broken before they reach the dragorn quarter. Twelve of the flashblades and heartpiercers.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303182,0,0,0,'The Rescuers','Ziven has guardians pinned in the outer quarters. Reach all three, then cut down the ukun jailers keeping them there.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303183,0,0,0,'Acolytes of Despair','General Azerug has named the despair''s source: Acolytes Grindrik and Torsk and their castigator retinue. Remove them.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303184,0,0,0,'Favors of the Hopelost','Citykeeper Nardic tends the hopeless. Carry word to the lookouts and bring back two babel crystal shards from the castigators as proof the roads are watched.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303185,0,0,0,'A Limit to Despair','Nardic wants no ceremony, only confirmation. Speak with Givrund and Ziven, then tell Nardic the city still has hands to save it.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1),
(303186,0,0,0,'The Missing Chalice','Givrund''s devotional chalice went to the acolytes'' altar. Acolyte Torsk carried it -- reclaim it from him and return.','Experience','',0,250000,0,0,0,75,0,0,0,0,0,0,'',0,0,0,0,0,-1,0,1);

INSERT INTO `task_activities` (taskid,activityid,req_activity_id,step,activitytype,target_name,goalmethod,goalcount,description_override,npc_match_list,item_id_list,item_list,dz_switch_id,min_x,min_y,min_z,max_x,max_y,max_z,skill_list,spell_list,zones,zone_version,optional,list_group) VALUES
(303172,0,-1,1,3,'a Babel Crystal Chip',0,3,'a Babel Crystal Chip','','42825','',0,0,0,0,0,0,0,'-1','0','oldbloodfield',-1,0,0),
(303172,1,0,2,4,'Noble Yemall the Arcane',0,1,'Noble Yemall the Arcane','472039','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303173,0,-1,1,2,'the supply-line fleshhounds',0,12,'the supply-line fleshhounds','472009|472027|472029|472058','','',0,0,0,0,0,0,0,'-1','0','oldbloodfield',-1,0,0),
(303173,1,0,2,2,'Xirisst',0,1,'Xirisst','472024','','',0,0,0,0,0,0,0,'-1','0','oldbloodfield',-1,0,0),
(303174,0,-1,1,4,'Commander Prezul',0,1,'Commander Prezul','472051','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303174,1,0,2,4,'General Vurig the Imposing',0,1,'General Vurig the Imposing','472055','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303174,2,1,3,4,'Noble Mikuv the Rational',0,1,'Noble Mikuv the Rational','472056','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303175,0,-1,1,2,'the discordian kyv',0,20,'the discordian kyv','472012|472014|472016|472035','','',0,0,0,0,0,0,0,'-1','0','oldbloodfield',-1,0,0),
(303176,0,-1,1,2,'the ikaav casters',0,20,'the ikaav casters','472017|472025|472028|472031|472033|472043','','',0,0,0,0,0,0,0,'-1','0','oldbloodfield',-1,0,0),
(303177,0,-1,1,2,'the ukun ranks',0,20,'the ukun ranks','472009|472027|472029|472058','','',0,0,0,0,0,0,0,'-1','0','oldbloodfield',-1,0,0),
(303178,0,-1,1,2,'the noc ranks',0,20,'the noc ranks','472011|472013|472015|472023|472026','','',0,0,0,0,0,0,0,'-1','0','oldbloodfield',-1,0,0),
(303179,0,-1,1,2,'Acolyte Maarnek',0,1,'Acolyte Maarnek','472005','','',0,0,0,0,0,0,0,'-1','0','oldbloodfield',-1,0,0),
(303179,1,0,2,2,'the castigator keepers',0,8,'the castigator keepers','472028|472043','','',0,0,0,0,0,0,0,'-1','0','oldbloodfield',-1,0,0),
(303179,2,1,3,4,'Nahsulen the Tactician',0,1,'Nahsulen the Tactician','472022','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303180,0,-1,1,2,'the fog patrols',0,15,'the fog patrols','474025|474110|474114|474044|474108|474116','','',0,0,0,0,0,0,0,'-1','0','olddranik',-1,0,0),
(303181,0,-1,1,2,'the armed ranks',0,12,'the armed ranks','474113|474120|474111|474054|474117','','',0,0,0,0,0,0,0,'-1','0','olddranik',-1,0,0),
(303182,0,-1,1,4,'a Dragorn guardian',0,1,'a Dragorn guardian','474000','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303182,1,0,2,4,'a Dragorn guardian',0,1,'a Dragorn guardian','474003','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303182,2,1,3,4,'a Dragorn guardian',0,1,'a Dragorn guardian','474022','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303182,3,2,4,2,'the ukun jailers',0,10,'the ukun jailers','474025|474110|474114','','',0,0,0,0,0,0,0,'-1','0','olddranik',-1,0,0),
(303183,0,-1,1,2,'Acolyte Grindrik',0,1,'Acolyte Grindrik','474013','','',0,0,0,0,0,0,0,'-1','0','olddranik',-1,0,0),
(303183,1,0,2,2,'Acolyte Torsk',0,1,'Acolyte Torsk','474053','','',0,0,0,0,0,0,0,'-1','0','olddranik',-1,0,0),
(303183,2,1,3,2,'the castigator retinue',0,10,'the castigator retinue','474039|474112|474056','','',0,0,0,0,0,0,0,'-1','0','olddranik',-1,0,0),
(303184,0,-1,1,4,'a Dragorn lookout',0,1,'a Dragorn lookout','474027','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303184,1,0,2,4,'a Dragorn lookout',0,1,'a Dragorn lookout','474028','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303184,2,1,3,3,'a Babel Crystal Shard',0,2,'a Babel Crystal Shard','','42828','',0,0,0,0,0,0,0,'-1','0','olddranik',-1,0,0),
(303184,3,2,4,4,'Citykeeper Nardic the Proud',0,1,'Citykeeper Nardic the Proud','474012','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303185,0,-1,1,4,'Givrund the Devoted',0,1,'Givrund the Devoted','474011','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303185,1,0,2,4,'Ziven',0,1,'Ziven','474019','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303185,2,1,3,4,'Citykeeper Nardic the Proud',0,1,'Citykeeper Nardic the Proud','474012','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0),
(303186,0,-1,1,2,'Acolyte Torsk',0,1,'Acolyte Torsk','474053','','',0,0,0,0,0,0,0,'-1','0','olddranik',-1,0,0),
(303186,1,0,2,4,'Givrund the Devoted',0,1,'Givrund the Devoted','474011','','',0,0,0,0,0,0,0,'-1','0','',-1,0,0);

-- Faction rewards: every themeDiscord partisan task raises Argoth (1226, +150; page: every quest in Bloodfields and City of Dranik raises this faction).
UPDATE `tasks` SET `faction_reward` = 1226, `faction_amount` = 150 WHERE `id` IN (303172,303173,303174,303175,303176,303177,303178,303179,303180,303181,303182,303183,303184,303185,303186);

-- ============================================================
-- 5. Theme static named rares: donor clones, always up, page
--    loot (last item 15%, the rest 25%; missing names skipped).
--    Spawn points are real elite spawn2 coordinates read at
--    generation time. #Grg`nok (470036) and #Shzalk (474115) keep
--    their junk loottables and get the page drops appended.
-- ============================================================
DELETE FROM `npc_types` WHERE `id` BETWEEN 1120002143 AND 1120002171;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 1520008793 AND 1520008821;
DELETE FROM `spawn2` WHERE `spawngroupID` BETWEEN 1520008793 AND 1520008821;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 1520008793 AND 1520008821;
DELETE FROM `loottable_entries` WHERE `loottable_id` BETWEEN 1520008463 AND 1520008491;
DELETE FROM `loottable` WHERE `id` BETWEEN 1520008463 AND 1520008491;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 1520008503 AND 1520008531;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 1520008503 AND 1520008531;

DROP TEMPORARY TABLE IF EXISTS sod_disco_rare_nt;
CREATE TEMPORARY TABLE sod_disco_rare_nt AS SELECT * FROM npc_types WHERE 0;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 472043;
UPDATE sod_disco_rare_nt SET id = 1120002143, name = 'Chaxyl', level = 86, hp = 250000, mana = 0, loottable_id = 1520008463, merchant_id = 0, faction_amount = -25 WHERE id = 472043;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 472035;
UPDATE sod_disco_rare_nt SET id = 1120002144, name = 'Emlyxi', level = 85, hp = 250000, mana = 0, loottable_id = 1520008464, merchant_id = 0, faction_amount = -25 WHERE id = 472035;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 472015;
UPDATE sod_disco_rare_nt SET id = 1120002145, name = 'Klygg', level = 85, hp = 250000, mana = 0, loottable_id = 1520008465, merchant_id = 0, faction_amount = -25 WHERE id = 472015;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 472026;
UPDATE sod_disco_rare_nt SET id = 1120002146, name = 'Kyris', level = 85, hp = 250000, mana = 0, loottable_id = 1520008466, merchant_id = 0, faction_amount = -25 WHERE id = 472026;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 472058;
UPDATE sod_disco_rare_nt SET id = 1120002147, name = 'Naddik', level = 86, hp = 250000, mana = 0, loottable_id = 1520008467, merchant_id = 0, faction_amount = -25 WHERE id = 472058;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 472025;
UPDATE sod_disco_rare_nt SET id = 1120002148, name = 'Noddri', level = 85, hp = 250000, mana = 0, loottable_id = 1520008468, merchant_id = 0, faction_amount = -25 WHERE id = 472025;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 472048;
UPDATE sod_disco_rare_nt SET id = 1120002149, name = 'Pherin_the_Traitor', level = 85, hp = 250000, mana = 0, loottable_id = 1520008469, merchant_id = 0, faction_amount = -25 WHERE id = 472048;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 472011;
UPDATE sod_disco_rare_nt SET id = 1120002150, name = 'Taath', level = 86, hp = 250000, mana = 0, loottable_id = 1520008470, merchant_id = 0, faction_amount = -25 WHERE id = 472011;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 472033;
UPDATE sod_disco_rare_nt SET id = 1120002151, name = 'Thangrel', level = 85, hp = 250000, mana = 0, loottable_id = 1520008471, merchant_id = 0, faction_amount = -25 WHERE id = 472033;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 474035;
UPDATE sod_disco_rare_nt SET id = 1120002152, name = 'Beguiler_Chandra', level = 85, hp = 250000, mana = 0, loottable_id = 1520008472, merchant_id = 0, faction_amount = -25 WHERE id = 474035;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 474054;
UPDATE sod_disco_rare_nt SET id = 1120002153, name = 'Cythkes', level = 85, hp = 250000, mana = 0, loottable_id = 1520008473, merchant_id = 0, faction_amount = -25 WHERE id = 474054;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 474042;
UPDATE sod_disco_rare_nt SET id = 1120002154, name = 'Maxantxora', level = 86, hp = 250000, mana = 0, loottable_id = 1520008474, merchant_id = 0, faction_amount = -25 WHERE id = 474042;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 474039;
UPDATE sod_disco_rare_nt SET id = 1120002155, name = 'Txenn', level = 85, hp = 250000, mana = 0, loottable_id = 1520008475, merchant_id = 0, faction_amount = -25 WHERE id = 474039;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 474109;
UPDATE sod_disco_rare_nt SET id = 1120002156, name = 'Ulkat', level = 85, hp = 250000, mana = 0, loottable_id = 1520008476, merchant_id = 0, faction_amount = -25 WHERE id = 474109;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 474110;
UPDATE sod_disco_rare_nt SET id = 1120002157, name = 'Xangef', level = 86, hp = 250000, mana = 0, loottable_id = 1520008477, merchant_id = 0, faction_amount = -25 WHERE id = 474110;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 474044;
UPDATE sod_disco_rare_nt SET id = 1120002158, name = 'Xoneua', level = 86, hp = 250000, mana = 0, loottable_id = 1520008478, merchant_id = 0, faction_amount = -25 WHERE id = 474044;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470022;
UPDATE sod_disco_rare_nt SET id = 1120002159, name = 'Attendant_Xixkt', level = 86, hp = 250000, mana = 0, loottable_id = 1520008479, merchant_id = 0, faction_amount = -25 WHERE id = 470022;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470032;
UPDATE sod_disco_rare_nt SET id = 1120002160, name = 'Bazu_Warsmasher', level = 86, hp = 250000, mana = 0, loottable_id = 1520008480, merchant_id = 0, faction_amount = -25 WHERE id = 470032;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470021;
UPDATE sod_disco_rare_nt SET id = 1120002161, name = 'Chainrender', level = 86, hp = 250000, mana = 0, loottable_id = 1520008481, merchant_id = 0, faction_amount = -25 WHERE id = 470021;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470030;
UPDATE sod_disco_rare_nt SET id = 1120002162, name = 'Deathstalker', level = 86, hp = 250000, mana = 0, loottable_id = 1520008482, merchant_id = 0, faction_amount = -25 WHERE id = 470030;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470033;
UPDATE sod_disco_rare_nt SET id = 1120002163, name = 'Dire_Feran_Mindrender', level = 86, hp = 250000, mana = 0, loottable_id = 1520008483, merchant_id = 0, faction_amount = -25 WHERE id = 470033;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470002;
UPDATE sod_disco_rare_nt SET id = 1120002164, name = 'Hexxt_Shadowslayer', level = 86, hp = 250000, mana = 0, loottable_id = 1520008484, merchant_id = 0, faction_amount = -25 WHERE id = 470002;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470027;
UPDATE sod_disco_rare_nt SET id = 1120002165, name = 'Hexxt_Soulhunter', level = 86, hp = 250000, mana = 0, loottable_id = 1520008485, merchant_id = 0, faction_amount = -25 WHERE id = 470027;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470006;
UPDATE sod_disco_rare_nt SET id = 1120002166, name = 'Noc_Bloodswarmer', level = 86, hp = 250000, mana = 0, loottable_id = 1520008486, merchant_id = 0, faction_amount = -25 WHERE id = 470006;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470037;
UPDATE sod_disco_rare_nt SET id = 1120002167, name = 'Overlord_Gevalark_the_Dread', level = 87, hp = 300000, mana = 0, loottable_id = 1520008487, merchant_id = 0, faction_amount = -25 WHERE id = 470037;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470025;
UPDATE sod_disco_rare_nt SET id = 1120002168, name = 'Pixxt_Darkhammer', level = 85, hp = 250000, mana = 0, loottable_id = 1520008488, merchant_id = 0, faction_amount = -25 WHERE id = 470025;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470028;
UPDATE sod_disco_rare_nt SET id = 1120002169, name = 'Pixxt_Deathbinder', level = 85, hp = 250000, mana = 0, loottable_id = 1520008489, merchant_id = 0, faction_amount = -25 WHERE id = 470028;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470013;
UPDATE sod_disco_rare_nt SET id = 1120002170, name = 'Spikemangler', level = 86, hp = 250000, mana = 0, loottable_id = 1520008490, merchant_id = 0, faction_amount = -25 WHERE id = 470013;
INSERT INTO sod_disco_rare_nt SELECT * FROM npc_types WHERE id = 470019;
UPDATE sod_disco_rare_nt SET id = 1120002171, name = 'Veltarik', level = 85, hp = 250000, mana = 0, loottable_id = 1520008491, merchant_id = 0, faction_amount = -25 WHERE id = 470019;
INSERT INTO `npc_types` SELECT * FROM sod_disco_rare_nt;
DROP TEMPORARY TABLE sod_disco_rare_nt;

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008463,'sod_disco_chaxyl',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008503,'sod_disco_chaxyl_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008463,1520008503,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008503,105928,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008503,105959,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008503,106428,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008464,'sod_disco_emlyxi',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008504,'sod_disco_emlyxi_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008464,1520008504,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008504,105916,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008504,105932,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008504,106416,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008504,106432,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008465,'sod_disco_klygg',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008505,'sod_disco_klygg_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008465,1520008505,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008505,105920,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008505,105952,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008505,106420,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008466,'sod_disco_kyris',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008506,'sod_disco_kyris_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008466,1520008506,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008506,105908,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008506,105948,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008506,106408,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008467,'sod_disco_naddik',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008507,'sod_disco_naddik_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008467,1520008507,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008507,105900,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008507,105935,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008507,106400,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008507,106435,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008468,'sod_disco_noddri',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008508,'sod_disco_noddri_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008468,1520008508,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008508,105922,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008508,105947,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008508,106422,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008508,106447,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008469,'sod_disco_pherin',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008509,'sod_disco_pherin_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008469,1520008509,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008509,105934,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008509,105944,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008509,106434,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008509,106444,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008470,'sod_disco_taath',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008510,'sod_disco_taath_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008470,1520008510,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008510,105904,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008510,105938,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008510,106404,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008510,106438,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008471,'sod_disco_thangrel',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008511,'sod_disco_thangrel_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008471,1520008511,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008511,105906,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008511,105912,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008511,106406,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008511,106412,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008472,'sod_disco_chandra',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008512,'sod_disco_chandra_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008472,1520008512,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008512,105918,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008512,105943,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008512,106418,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008512,106443,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008473,'sod_disco_cythkes',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008513,'sod_disco_cythkes_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008473,1520008513,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008513,105924,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008513,105946,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008513,106424,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008513,106446,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008474,'sod_disco_maxantxora',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008514,'sod_disco_maxantxora_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008474,1520008514,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008514,105940,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008514,105956,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008514,106440,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008475,'sod_disco_txenn',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008515,'sod_disco_txenn_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008475,1520008515,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008515,105909,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008515,105914,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008515,106409,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008515,106414,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008476,'sod_disco_ulkat',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008516,'sod_disco_ulkat_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008476,1520008516,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008516,105933,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008516,105939,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008516,106433,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008516,106439,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008477,'sod_disco_xangef',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008517,'sod_disco_xangef_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008477,1520008517,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008517,105907,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008517,105949,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008517,106407,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008478,'sod_disco_xoneua',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008518,'sod_disco_xoneua_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008478,1520008518,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008518,105919,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008518,105957,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008518,106419,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008479,'sod_disco_xixkt',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008519,'sod_disco_xixkt_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008479,1520008519,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008519,105931,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008519,105942,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008519,106431,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008519,106442,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008480,'sod_disco_warsmasher',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008520,'sod_disco_warsmasher_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008480,1520008520,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008520,105903,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008520,105941,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008520,106403,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008520,106441,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008481,'sod_disco_chainrender',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008521,'sod_disco_chainrender_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008481,1520008521,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008521,105923,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008521,105958,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008521,106423,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008482,'sod_disco_deathstalker',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008522,'sod_disco_deathstalker_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008482,1520008522,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008522,105911,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008522,105951,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008522,106411,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008483,'sod_disco_mindrender',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008523,'sod_disco_mindrender_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008483,1520008523,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008523,105917,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008523,105955,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008523,106417,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008484,'sod_disco_shadowslayer',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008524,'sod_disco_shadowslayer_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008484,1520008524,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008524,105902,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008524,105960,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008524,106402,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008485,'sod_disco_soulhunter',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008525,'sod_disco_soulhunter_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008485,1520008525,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008525,105915,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008525,105961,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008525,106415,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008486,'sod_disco_bloodswarmer',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008526,'sod_disco_bloodswarmer_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008486,1520008526,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008526,105913,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008526,105926,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008526,106413,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008526,106426,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008487,'sod_disco_gevalark',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008527,'sod_disco_gevalark_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008487,1520008527,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008527,105921,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008527,105954,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008527,106421,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008488,'sod_disco_pixxt_dark',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008528,'sod_disco_pixxt_dark_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008488,1520008528,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008528,105901,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008528,129057,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008528,106401,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008489,'sod_disco_pixxt_death',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008529,'sod_disco_pixxt_death_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008489,1520008529,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008529,105925,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008529,105927,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008529,106425,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008529,106427,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008490,'sod_disco_spikemangler',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008530,'sod_disco_spikemangler_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008490,1520008530,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008530,105930,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008530,105950,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008530,106430,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES (1520008491,'sod_disco_veltarik',1000000,5000000,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008531,'sod_disco_veltarik_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (1520008491,1520008531,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008531,105910,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008531,105945,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008531,106410,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008531,106445,1,0,15,0,0,0,1,0,0,-1,-1);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008793,'sod_disco_rare_chaxyl',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008793,1120002143,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008793,'oldbloodfield',0,-2097.0,2051.0,3.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008794,'sod_disco_rare_emlyxi',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008794,1120002144,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008794,'oldbloodfield',0,-1270.0,1230.0,6.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008795,'sod_disco_rare_klygg',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008795,1120002145,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008795,'oldbloodfield',0,-1004.0,-1028.0,6.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008796,'sod_disco_rare_kyris',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008796,1120002146,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008796,'oldbloodfield',0,-607.0,-785.0,111.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008797,'sod_disco_rare_naddik',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008797,1120002147,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008797,'oldbloodfield',0,-50.0,50.0,4.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008798,'sod_disco_rare_noddri',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008798,1120002148,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008798,'oldbloodfield',0,533.0,811.88,9.12,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008799,'sod_disco_rare_pherin',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008799,1120002149,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008799,'oldbloodfield',0,731.0,743.0,6.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008800,'sod_disco_rare_taath',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008800,1120002150,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008800,'oldbloodfield',0,1166.88,-239.88,6.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008801,'sod_disco_rare_thangrel',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008801,1120002151,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008801,'oldbloodfield',0,1497.62,1893.0,10.75,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008802,'sod_disco_rare_chandra',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008802,1120002152,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008802,'olddranik',0,-1836.88,1159.88,-180.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008803,'sod_disco_rare_cythkes',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008803,1120002153,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008803,'olddranik',0,-436.38,419.75,-135.38,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008804,'sod_disco_rare_maxantxora',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008804,1120002154,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008804,'olddranik',0,551.0,251.0,-3.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008805,'sod_disco_rare_txenn',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008805,1120002155,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008805,'olddranik',0,964.0,1056.0,90.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008806,'sod_disco_rare_ulkat',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008806,1120002156,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008806,'olddranik',0,1364.12,766.75,136.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008807,'sod_disco_rare_xangef',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008807,1120002157,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008807,'olddranik',0,1701.75,961.88,133.38,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008808,'sod_disco_rare_xoneua',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008808,1120002158,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008808,'olddranik',0,2490.38,651.12,49.88,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008809,'sod_disco_rare_xixkt',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008809,1120002159,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008809,'discord',0,-51.0,33.0,27.0,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008810,'sod_disco_rare_warsmasher',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008810,1120002160,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008810,'discord',0,787.5,-100.88,16.12,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008811,'sod_disco_rare_chainrender',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008811,1120002161,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008811,'discord',0,853.25,-1128.0,-13.5,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008812,'sod_disco_rare_deathstalker',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008812,1120002162,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008812,'discord',0,900.38,-79.88,94.12,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008813,'sod_disco_rare_mindrender',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008813,1120002163,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008813,'discord',0,981.75,-777.12,19.38,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008814,'sod_disco_rare_shadowslayer',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008814,1120002164,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008814,'discord',0,1042.0,-1394.12,348.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008815,'sod_disco_rare_soulhunter',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008815,1120002165,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008815,'discord',0,1125.0,-117.0,390.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008816,'sod_disco_rare_bloodswarmer',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008816,1120002166,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008816,'discord',0,1181.0,-323.25,155.12,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008817,'sod_disco_rare_gevalark',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008817,1120002167,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008817,'discord',0,1291.5,-333.12,153.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008818,'sod_disco_rare_pixxt_dark',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008818,1120002168,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008818,'discord',0,1343.0,-630.38,184.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008819,'sod_disco_rare_pixxt_death',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008819,1120002169,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008819,'discord',0,1418.88,-199.25,186.62,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008820,'sod_disco_rare_spikemangler',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008820,1120002170,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008820,'discord',0,1630.75,-864.5,353.25,0,3600);

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`delay`,`mindelay`,`despawn`) VALUES (1520008821,'sod_disco_rare_veltarik',0,0,3600,1800,0);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES (1520008821,1120002171,100);
INSERT INTO `spawn2` (`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`) VALUES (1520008821,'discord',0,1836.88,225.25,379.62,0,3600);

INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008534,'sod_disco_grgnok_patch');
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008534,105929,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008534,105937,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008534,106429,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008534,106437,1,0,15,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (94776,1520008534,1,0,0,100);

INSERT INTO `lootdrop` (`id`,`name`) VALUES (1520008535,'sod_disco_shzalk_patch');
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
    (1520008535,105905,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008535,105936,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008535,106405,1,0,25,0,0,0,1,0,0,-1,-1),
    (1520008535,106436,1,0,15,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (94826,1520008535,1,0,0,100);
