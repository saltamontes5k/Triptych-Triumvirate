-- ============================================================================
-- Deity Blessings -- Rank 2 "Deity Favors": quest target NPCs (set 1)
-- Date: 2026-10-06
--
-- Bertoxxulous plague animals, Rodcet injured animals, Cazic wand targets,
-- Quellious angry farmers, Innoruuk set, Erollisi delivery targets.
-- Animal races cloned from live PEQ models (bat 34, beetle 22, rat 36, snake
-- 37, wolf 42, bear 43, skunk 83, gator 91, drake 89, fae drake 113, hare 176,
-- rockhopper 200, scorpion 129, unicorn 124).
--
-- NPC ids 344230-344307 subset, spawngroups 5004240+, spawn2 3390240+.
-- Idempotent: deletes owned ids first.
-- ============================================================================

DELETE FROM `spawn2`     WHERE `id` BETWEEN 3390240 AND 3390319;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 5004240 AND 5004319;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 5004240 AND 5004319;
DELETE FROM `npc_types`  WHERE `id` BETWEEN 344230 AND 344349;

-- ------------------------------------------------- Bertoxxulous animals ----
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344230,'a_sandskimmer_bat','PlagueBearer',1,34,1,1,30,0,0,0,0,4,0.7,0),
    (344231,'a_mother_rat','PlagueBearer',1,36,1,1,30,0,0,0,0,4,0.7,0),
    (344232,'a_wiry_coyote','PlagueBearer',1,42,1,1,30,0,0,0,0,4,0.7,0),
    (344233,'a_raging_fire_beetle','PlagueBearer',1,22,1,1,30,0,0,0,0,3,0.7,0),
    (344234,'a_clever_stonesnake','PlagueBearer',1,37,1,1,30,0,0,0,0,4,0.7,0),
    (344235,'a_frisky_black_bear','PlagueBearer',1,43,1,1,30,0,0,0,0,6,0.7,0),
    (344236,'a_content_brown_bear','PlagueBearer',1,43,1,1,30,0,0,0,0,6,0.7,0),
    (344237,'a_clumsy_black_bear','PlagueBearer',1,43,1,1,30,0,0,0,0,6,0.7,0),
    (344238,'a_keen_driftwolf','PlagueBearer',1,42,1,1,30,0,0,0,0,5,0.7,0),
    (344239,'a_floppy_snow_hare','PlagueBearer',1,176,1,1,30,0,0,0,0,3,0.7,0),
    (344240,'a_sinewy_tiger','PlagueBearer',1,42,1,1,30,0,0,0,0,5,0.7,0),
    (344241,'an_endearing_skunk','PlagueBearer',1,83,1,1,30,0,0,0,0,3,0.7,0),
    (344242,'Damaex_the_Unicorn','Radiant and Ailing',10,124,1,1,400,0,0,0,0,6,0.7,0);

-- ---------------------------------------------------- Rodcet injured set ----
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344250,'an_Injured_Rat','Wounded Creature',1,36,1,1,30,0,0,0,0,4,0.5,0),
    (344251,'an_Injured_Skunk','Wounded Creature',1,83,1,1,30,0,0,0,0,3,0.5,0),
    (344252,'an_Injured_Drixie','Wounded Creature',1,113,1,1,30,0,0,0,0,3,0.5,0),
    (344253,'an_Injured_Drake','Wounded Creature',1,89,1,1,30,0,0,0,0,5,0.5,0),
    (344254,'an_Injured_Kodiak','Wounded Creature',1,43,1,1,30,0,0,0,0,7,0.5,0),
    (344255,'an_Injured_Coyote','Wounded Creature',1,42,1,1,30,0,0,0,0,5,0.5,0),
    (344256,'an_Injured_Rockhopper','Wounded Creature',1,200,1,1,30,0,0,0,0,4,0.5,0),
    (344257,'an_Injured_Snake','Wounded Creature',1,37,1,1,30,0,0,0,0,4,0.5,0),
    (344258,'an_Injured_Alligator','Wounded Creature',1,91,1,1,30,0,0,0,0,5,0.5,0),
    (344259,'an_Injured_Scorpion','Wounded Creature',1,129,1,1,30,0,0,0,0,4,0.5,0);

-- ------------------------------------------------------ Cazic wand targets --
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344260,'Galayna_Idirin','Bride of Light',10,4,1,1,400,0,1,0,0,5,1.25,0),
    (344261,'Arthin_Guinden','Groom of Light',10,4,1,1,400,0,0,0,0,5,1.25,0),
    (344262,'Ierene_Seldon','Worried Mother',10,3,1,1,400,0,1,0,0,5,1.25,0),
    (344263,'Agar_Treebs','Aspiring Merchant',10,1,1,1,400,0,0,0,0,5,1.25,0),
    (344264,'Captain_Callesh','Officer of the Bayle',50,1,1,1,9000,0,0,0,0,5,1.25,0),
    (344265,'Sephlin_of_Qeynos','Advisor to the Crown',50,5,1,1,9000,0,0,0,0,5,1.25,0);

-- ---------------------------------------------------- Quellious farmers ----
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344267,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,0,0,0,5,1.25,0),
    (344268,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,1,0,0,5,1.25,0),
    (344269,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,0,0,0,5,1.25,0),
    (344270,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,1,0,0,5,1.25,0),
    (344271,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,0,0,0,5,1.25,0),
    (344272,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,1,0,0,5,1.25,0),
    (344273,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,0,0,0,5,1.25,0),
    (344274,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,1,0,0,5,1.25,0),
    (344275,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,0,0,0,5,1.25,0),
    (344276,'an_angry_farmer','Rowdy as a Bull',5,11,1,1,200,0,1,0,0,5,1.25,0);

-- ----------------------------------------------------------- Innoruuk set --
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344277,'Lauren','Young Woman in Love',5,1,1,1,200,0,1,0,0,5,1.25,0),
    (344278,'Tyler','Young Man in Love',5,1,1,1,200,0,0,0,0,5,1.25,0),
    (344279,'Rondor_Sandskipper','Too Happy a Fisherman',10,1,1,1,400,0,0,0,0,5,1.25,0),
    (344280,'Innoruuks_Flame','Fire of Hatred',55,85,1,1,9000,0,0,0,0,6,0.7,0);

-- ------------------------------------------------------ Erollisi targets ---
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344305,'Oograh_Breaknose','Waiting for a Letter',10,12,1,1,400,0,1,0,0,5,1.25,0),
    (344306,'a_forlorn_spirit','Bound by Longing',45,85,1,1,8000,0,0,0,0,6,0.7,0),
    (344307,'Jheri_Dorsay','Singer of Silly Songs',10,7,1,1,400,0,0,0,0,5,1.25,0);

-- ------------------------------------------------ spawngroups + spawn2 ----
INSERT INTO `spawngroup` (`id`,`name`) VALUES
    (5004240,'bless_r2_plg_bat'),(5004241,'bless_r2_plg_rat'),(5004242,'bless_r2_plg_coyote'),
    (5004243,'bless_r2_plg_beetle'),(5004244,'bless_r2_plg_snake'),(5004245,'bless_r2_plg_bbear'),
    (5004246,'bless_r2_plg_brbear'),(5004247,'bless_r2_plg_bbear2'),(5004248,'bless_r2_plg_driftwolf'),
    (5004249,'bless_r2_plg_hare'),(5004250,'bless_r2_plg_tiger'),(5004251,'bless_r2_plg_skunk'),
    (5004252,'bless_r2_plg_damaex'),
    (5004255,'bless_r2_inj_rat'),(5004256,'bless_r2_inj_skunk'),(5004257,'bless_r2_inj_drixie'),
    (5004258,'bless_r2_inj_drake'),(5004259,'bless_r2_inj_kodiak'),(5004260,'bless_r2_inj_coyote'),
    (5004261,'bless_r2_inj_rockhopper'),(5004262,'bless_r2_inj_snake'),(5004263,'bless_r2_inj_gator'),
    (5004264,'bless_r2_inj_scorpion'),
    (5004267,'bless_r2_galayna'),(5004268,'bless_r2_arthin'),(5004269,'bless_r2_ierene'),
    (5004270,'bless_r2_agar'),(5004271,'bless_r2_callesh'),(5004272,'bless_r2_sephlin'),
    (5004274,'bless_r2_farmers_misty'),
    (5004278,'bless_r2_lauren'),(5004279,'bless_r2_tyler'),(5004280,'bless_r2_rondor'),
    (5004281,'bless_r2_flame'),(5004282,'bless_r2_enraged_aviak'),
    (5004290,'bless_r2_oograh'),(5004291,'bless_r2_forlorn'),(5004292,'bless_r2_jheri');

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
    (5004240,344230,100),(5004241,344231,100),(5004242,344232,100),(5004243,344233,100),
    (5004244,344234,100),(5004245,344235,100),(5004246,344236,100),(5004247,344237,100),
    (5004248,344238,100),(5004249,344239,100),(5004250,344240,100),(5004251,344241,100),
    (5004252,344242,100),
    (5004255,344250,100),(5004256,344251,100),(5004257,344252,100),(5004258,344253,100),
    (5004259,344254,100),(5004260,344255,100),(5004261,344256,100),(5004262,344257,100),
    (5004263,344258,100),(5004264,344259,100),
    (5004267,344260,100),(5004268,344261,100),(5004269,344262,100),(5004270,344263,100),
    (5004271,344264,100),(5004272,344265,100),
    (5004274,344267,100),(5004274,344268,100),(5004274,344269,100),(5004274,344270,100),
    (5004274,344271,100),(5004274,344272,100),(5004274,344273,100),(5004274,344274,100),
    (5004274,344275,100),(5004274,344276,100),
    (5004278,344277,100),(5004279,344278,100),(5004280,344279,100),
    (5004281,344280,100),(5004282,344281,100),
    (5004290,344305,100),(5004291,344306,100),(5004292,344307,100);

INSERT INTO `spawn2`
    (`id`,`spawngroupID`,`zone`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
    (3390240,5004240,'northro',  9118,-2126,23,0,300,0),
    (3390241,5004241,'northro',  8724,-2195,23,0,300,0),
    (3390242,5004242,'northro',  7875,-941,23,0,300,0),
    (3390243,5004243,'northro',  7972,-1819,23,0,300,0),
    (3390244,5004244,'northro',  6872,-1799,23,0,300,0),
    (3390245,5004245,'rathemtn', -642,747,16,0,300,0),
    (3390246,5004246,'rathemtn', 4795,1488,16,0,300,0),
    (3390247,5004247,'rathemtn', 3270,2460,16,0,300,0),
    (3390248,5004248,'eastwastes',-182,-468,26,0,300,0),
    (3390249,5004249,'eastwastes',-100,-380,26,0,300,0),
    (3390250,5004250,'toxxulia', -540,-119,28,0,300,0),
    (3390251,5004251,'toxxulia', 2145,-3,28,0,300,0),
    (3390252,5004252,'lfaydark', -141,1082,12,0,600,0),
    (3390255,5004255,'qeytoqrg', 113,139,-5,0,600,0),
    (3390256,5004256,'butcher',  3116,879,-12,0,600,0),
    (3390257,5004257,'lfaydark', -140,1080,12,0,600,0),
    (3390258,5004258,'nektulos', -637,-581,-34,0,600,0),
    (3390259,5004259,'commonlands',2680,283,-36,0,600,0),
    (3390260,5004260,'northro', -1293,9685,22,0,600,0),
    (3390261,5004261,'mseru',   -296,-1196,-161,0,600,0),
    (3390262,5004262,'nedaria', 1401,-617,70,0,600,0),
    (3390263,5004263,'innothule',-501,-2614,-20,0,600,0),
    (3390264,5004264,'fieldofbone',-2060,362,-52,0,600,0),
    (3390267,5004267,'gfaydark', 660,450,117,0,600,0),
    (3390268,5004268,'gfaydark', 700,400,117,0,600,0),
    (3390269,5004269,'erudnext', -1220,-353,-2,0,600,0),
    (3390270,5004270,'commonlands',-1600,-2506,-36,0,600,0),
    (3390271,5004271,'qeynos2', -120,-140,4,0,600,0),
    (3390272,5004272,'qeynos2', -170,-180,4,0,600,0),
    (3390274,5004274,'misty',   -705,345,3,0,120,0),
    (3390278,5004278,'northkarana',-315,-2690,-53,0,600,0),
    (3390279,5004279,'northkarana',-339,-2695,-53,0,600,0),
    (3390280,5004280,'oceanoftears',-1669,7529,-155,0,600,0),
    (3390281,5004281,'lakerathe',2485,994,-34,0,600,0),
    (3390282,5004282,'lakerathe',2520,1030,-34,0,600,0),
    (3390290,5004290,'steamfont',-753,-1151,-108,0,600,0),
    (3390291,5004291,'fieldofbone',-2167,-582,-15,0,600,0),
    (3390292,5004292,'gfaydark', 500,300,117,0,600,0);

-- Enraged aviak guard: clone of a live aviak guard to inherit the model
DROP TEMPORARY TABLE IF EXISTS `tmp_npc`;
CREATE TEMPORARY TABLE `tmp_npc` AS SELECT * FROM `npc_types` WHERE `id`=51008;
UPDATE `tmp_npc` SET
    `id`=344281, `Name`='an_enraged_aviak_guard', `lastname`='Screeching from the Flame',
    `level`=52, `hp`=18000, `mana`=0, `npc_spells_id`=0
WHERE `id`=51008;
INSERT INTO `npc_types` SELECT * FROM `tmp_npc`;
DROP TEMPORARY TABLE `tmp_npc`;
