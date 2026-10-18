-- ============================================================================
-- Deity Blessings -- Rank 2 "Deity Favors": giver + helper NPCs
-- Date: 2026-10-06
--
-- The 16 favor-givers (15 authored + PEQ's Avatar_of_Quellious 600155) and the
-- helper quest NPCs (Scheredin, Tober Grandim, Togg Purk, Pirex Saulen), plus
-- spawns for reused PEQ NPCs (Nettle 600156, miscreants 600157/600158, the
-- evil imp 76059, #Atler 394020, Lord Antonius 466029).
--
-- NPC ids 344210-344299, spawngroups 5004200+, spawn2 3390200+.
-- Idempotent: deletes owned ids first.
-- ============================================================================

DELETE FROM `spawn2`     WHERE `id` BETWEEN 3390200 AND 3390299;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 5004200 AND 5004299;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 5004200 AND 5004299;
DELETE FROM `npc_types`  WHERE `id` BETWEEN 344210 AND 344299;

-- ---------------------------------------------------------------- givers ----
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344210,'Avatar_of_Bertoxxulous','Herald of the Plague Lord',70,1,1,1,32767,0,0,0,0,6,1.25,0),
    (344211,'Roderik_High_Priest_of_Brell','High Priest of Brell',70,8,1,1,32767,0,0,0,0,6,1.25,0),
    (344212,'Avatar_of_Cazic-Thule','Herald of Fear',70,1,1,1,32767,0,0,0,0,6,1.25,0),
    (344213,'an_Aspect_of_Erollisi_Marr','Herald of Love',70,2,1,1,32767,0,1,0,0,6,1.25,0),
    (344214,'Fizzlethorpe_Bristlebanes_Image','Image of the Prankster',70,1,1,1,32767,0,0,0,0,5,1.25,0),
    (344215,'a_crystalline_avatar','Avatar of Veeshan',70,3,1,1,32767,0,0,0,0,6,1.25,0),
    (344216,'Herald_of_Justice_Due','Voice of the Six Judges',70,1,1,1,32767,0,0,0,0,6,1.25,0),
    (344217,'Avatar_of_Mithaniel_Marr','Herald of Valor',70,1,1,1,32767,0,0,0,0,6,1.25,0),
    (344218,'Avatar_of_Rallos_Zek','Herald of War',70,10,1,1,32767,0,0,0,0,8,1.25,0),
    (344219,'Avatar_of_Karana','Herald of the Storm',70,1,1,1,32767,0,0,0,0,7,1.25,0),
    (344220,'Avatar_of_Solusek_Ro','Herald of the Sun',70,3,1,1,32767,0,0,0,0,6,1.25,0),
    (344221,'Avatar_of_Tunare','Herald of the Mother',70,4,1,1,32767,0,1,0,0,6,1.25,0),
    (344222,'Primate_of_Prexus','Voice of the Ocean Lord',70,3,1,1,32767,0,0,0,0,6,1.25,0),
    (344223,'Helera_Garet','Priestess of Rodcet Nife',70,3,1,1,32767,0,1,0,0,5,1.25,0);

-- --------------------------------------------------------------- helpers ----
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344224,'Scheredin_Priest_of_Bertoxxulous','Plaguebringer',55,1,1,1,12000,0,0,0,0,5,1.25,0),
    (344225,'Tober_Grandim','Stormtinker',55,1,1,1,12000,0,0,0,0,5,1.25,0),
    (344226,'Togg_Purk','Warrior of Rallos Zek',55,10,1,1,18000,0,0,0,0,7,1.25,0),
    (344227,'Pirex_Saulen','Teller of Terrible Tales',55,13,1,1,12000,0,0,0,0,6,1.25,0);

-- ------------------------------------------------ spawngroups + spawn2 ----
INSERT INTO `spawngroup` (`id`,`name`) VALUES
    (5004200,'bless_r2_avatar_bertoxx_ekarana'),
    (5004201,'bless_r2_roderik_butcher'),
    (5004202,'bless_r2_avatar_cazic_feerrott'),
    (5004203,'bless_r2_aspect_erollisi_southro'),
    (5004204,'bless_r2_bristlebane_image_pok'),
    (5004205,'bless_r2_crystal_avatar_pok'),
    (5004206,'bless_r2_herald_tribunal_pot'),
    (5004207,'bless_r2_avatar_mith_pot'),
    (5004208,'bless_r2_avatar_rallos_pot'),
    (5004209,'bless_r2_avatar_karana_skarana'),
    (5004210,'bless_r2_avatar_solro_northro'),
    (5004211,'bless_r2_avatar_tunare_gfay'),
    (5004212,'bless_r2_primate_prexus_erudsxing'),
    (5004213,'bless_r2_helera_qeynos2'),
    (5004214,'bless_r2_avatar_quellious_pot'),
    (5004215,'bless_r2_evil_imp_innothule'),
    (5004216,'bless_r2_nettle_misty'),
    (5004217,'bless_r2_fordel_miscreant_shaven'),
    (5004218,'bless_r2_midst_miscreant_shaven'),
    (5004219,'bless_r2_atler_freportw'),
    (5004220,'bless_r2_antonius_qeynos2'),
    (5004221,'bless_r2_scheredin_freporte'),
    (5004222,'bless_r2_tober_northkarana'),
    (5004223,'bless_r2_togg_lavastorm'),
    (5004224,'bless_r2_pirex_fieldofbone');

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
    (5004200,344210,100),(5004201,344211,100),(5004202,344212,100),(5004203,344213,100),
    (5004204,344214,100),(5004205,344215,100),(5004206,344216,100),(5004207,344217,100),
    (5004208,344218,100),(5004209,344219,100),(5004210,344220,100),(5004211,344221,100),
    (5004212,344222,100),(5004213,344223,100),
    (5004214,600155,100),(5004215,76059,100),(5004216,600156,100),
    (5004217,600157,100),(5004218,600158,100),(5004219,394020,100),(5004220,466029,100),
    (5004221,344224,100),(5004222,344225,100),(5004223,344226,100),(5004224,344227,100);

INSERT INTO `spawn2`
    (`id`,`spawngroupID`,`zone`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
    (3390200,5004200,'eastkarana',   -296,-3026,2,0,7200,0),
    (3390201,5004201,'butcher',      2834,-2626,6,130,7200,0),
    (3390202,5004202,'feerrott',     -1124,-25,-23,0,7200,0),
    (3390203,5004203,'southro',      4200,-2219,32,0,7200,0),
    (3390204,5004204,'poknowledge',  -188,216,-110,0,7200,0),
    (3390205,5004205,'poknowledge',  200,-185,-108,0,7200,0),
    (3390206,5004206,'potranquility',633,-1496,-875,0,7200,0),
    (3390207,5004207,'potranquility',-68,-1262,-873,0,7200,0),
    (3390208,5004208,'potranquility',0,-186,-14,0,7200,0),
    (3390209,5004209,'southkarana',  -3693,-1811,20,0,7200,0),
    (3390210,5004210,'northro',      6761,-699,141,0,7200,0),
    (3390211,5004211,'gfaydark',     -2350,-1480,14,0,7200,0),
    (3390212,5004212,'erudsxing',    -1842,712,-13,0,7200,0),
    (3390213,5004213,'qeynos2',      313,681,3,0,7200,0),
    (3390214,5004214,'potranquility',-1452,2107,-710,0,7200,0),
    (3390215,5004215,'innothule',    -568,-290,-20,0,7200,0),
    (3390216,5004216,'misty',        -703,355,3,0,7200,0),
    (3390217,5004217,'shadowhaven',  1660,-530,-61,0,7200,0),
    (3390218,5004218,'shadowhaven',  1690,-550,-61,0,7200,0),
    (3390219,5004219,'freportw',     332,-558,-26,0,7200,0),
    (3390220,5004220,'qeynos2',      -146,-161,4,0,7200,0),
    (3390221,5004221,'freporte',     -606,336,-51,0,7200,0),
    (3390222,5004222,'northkarana',  -325,-2686,-53,0,7200,0),
    (3390223,5004223,'lavastorm',    680,30,-88,0,7200,0),
    (3390224,5004224,'fieldofbone',  -2326,2878,10,0,7200,0);
