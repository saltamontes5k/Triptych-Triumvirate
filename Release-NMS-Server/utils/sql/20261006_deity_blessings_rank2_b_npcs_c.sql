-- ============================================================================
-- Deity Blessings -- Rank 2 "Deity Favors": quest target NPCs (set 2)
-- Date: 2026-10-06
--
-- 10 spectres of evil (Mithaniel Marr), 3 dopplegangers (Rallos Zek),
-- 10 Tribunal justice targets, 8 hidden Party Machines (Bristlebane).
--
-- NPC ids 344282-344304 + 344308-344315, spawngroups 5004300+, spawn2 3390300+.
-- Idempotent: deletes owned ids first.
-- ============================================================================

DELETE FROM `spawn2`     WHERE `id` BETWEEN 3390300 AND 3390339;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 5004300 AND 5004339;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 5004300 AND 5004339;
DELETE FROM `npc_types`  WHERE `id` IN (344292,344293,344294,344308,344309,344310,344311,344312,344313,344314,344315);

-- ------------------------------------------- spectres of evil (Mith Marr) ---
-- one unique id per location; kill activities match the exact id
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344282,'a_spectre_of_evil','Bane of the Frozen Pass',52,85,1,1,18000,0,0,0,0,6,0.9,0),
    (344283,'a_spectre_of_evil','Bane of Grimrot Fields',52,85,1,1,18000,0,0,0,0,6,0.9,0),
    (344284,'a_spectre_of_evil','Bane of the Lumberyard',52,85,1,1,18000,0,0,0,0,6,0.9,0),
    (344285,'a_spectre_of_evil','Bane of the Chessboard',52,85,1,1,18000,0,0,0,0,6,0.9,0),
    (344286,'a_spectre_of_evil','Bane of the Shadowed Monument',52,85,1,1,18000,0,0,0,0,6,0.9,0),
    (344287,'a_spectre_of_evil','Bane of the Docks',52,85,1,1,18000,0,0,0,0,6,0.9,0),
    (344288,'a_spectre_of_evil','Bane of the Pirate Camp',52,85,1,1,18000,0,0,0,0,6,0.9,0),
    (344289,'a_spectre_of_evil','Bane of the Queen of Thorns',52,85,1,1,18000,0,0,0,0,6,0.9,0),
    (344290,'a_spectre_of_evil','Bane of the Brigand Camp',52,85,1,1,18000,0,0,0,0,6,0.9,0),
    (344291,'a_spectre_of_evil','Bane of the Moor',52,85,1,1,18000,0,0,0,0,6,0.9,0);

-- ------------------------------------------------ dopplegangers (Rallos) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_npc`;
CREATE TEMPORARY TABLE `tmp_npc` AS SELECT * FROM `npc_types` WHERE `id`=12173;
UPDATE `tmp_npc` SET `id`=344292, `Name`='a_Doppleganger', `lastname`='Mimic of the Warrior',
    `level`=52, `hp`=15000, `mana`=0, `npc_spells_id`=0 WHERE `id`=12173;
INSERT INTO `npc_types` SELECT * FROM `tmp_npc`;
UPDATE `tmp_npc` SET `id`=344293, `Name`='a_Fierce_Doppleganger', `lastname`='Mimic of the Warrior' WHERE `id`=344292;
INSERT INTO `npc_types` SELECT * FROM `tmp_npc`;
UPDATE `tmp_npc` SET `id`=344294, `Name`='a_Raging_Doppleganger', `lastname`='Mimic of the Warrior' WHERE `id`=344293;
INSERT INTO `npc_types` SELECT * FROM `tmp_npc`;
DROP TEMPORARY TABLE `tmp_npc`;

-- ------------------------------------------------- Tribunal justice targets -
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344295,'Branack_Welk','Judged by the Six',52,1,1,1,18000,0,0,0,0,5,1.25,0),
    (344296,'Tomee_Stenk','Judged by the Six',52,11,1,1,18000,0,0,0,0,4,1.25,0),
    (344297,'Silva_Tonk','Judged by the Six',52,3,1,1,18000,0,0,0,0,5,1.25,0),
    (344298,'Encan_VDal','Judged by the Six',52,6,1,1,18000,0,0,0,0,5,1.25,0),
    (344299,'Eoando_Kelu','Judged by the Six',52,5,1,1,18000,0,0,0,0,5,1.25,0),
    (344300,'Gloribo_Hammerbreaker','Judged by the Six',52,8,1,1,18000,0,0,0,0,4,1.25,0),
    (344301,'Snogge','Judged by the Six',52,10,1,1,18000,0,0,0,0,7,1.25,0),
    (344302,'Bronkks','Judged by the Six',52,9,1,1,18000,0,0,0,0,7,1.25,0),
    (344303,'Scooky_Moog','Judged by the Six',52,11,1,1,18000,0,0,0,0,4,1.25,0),
    (344304,'Doran_Keez','Judged by the Six',52,1,1,1,18000,0,0,0,0,5,1.25,0);

-- -------------------------------------------- Bristlebane party machines ----
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`npc_spells_id`)
VALUES
    (344308,'Bristlebanes_Party_Machine','Ticking with Glee',50,60,1,1,9000,0,0,0,0,5,0.7,0),
    (344309,'Bristlebanes_Party_Machine','Ticking with Glee',50,60,1,1,9000,0,0,0,0,5,0.7,0),
    (344310,'Bristlebanes_Party_Machine','Ticking with Glee',50,60,1,1,9000,0,0,0,0,5,0.7,0),
    (344311,'Bristlebanes_Party_Machine','Ticking with Glee',50,60,1,1,9000,0,0,0,0,5,0.7,0),
    (344312,'Bristlebanes_Party_Machine','Ticking with Glee',50,60,1,1,9000,0,0,0,0,5,0.7,0),
    (344313,'Bristlebanes_Party_Machine','Ticking with Glee',50,60,1,1,9000,0,0,0,0,5,0.7,0),
    (344314,'Bristlebanes_Party_Machine','Ticking with Glee',50,60,1,1,9000,0,0,0,0,5,0.7,0),
    (344315,'Bristlebanes_Party_Machine','Ticking with Glee',50,60,1,1,9000,0,0,0,0,5,0.7,0);

-- ------------------------------------------------ spawngroups + spawn2 ----
INSERT INTO `spawngroup` (`id`,`name`) VALUES
    (5004300,'bless_r2_spec_everfrost'),(5004301,'bless_r2_spec_skarana'),
    (5004302,'bless_r2_spec_highpass'),(5004303,'bless_r2_spec_butcher'),
    (5004304,'bless_r2_spec_lfay'),(5004305,'bless_r2_spec_firiona'),
    (5004306,'bless_r2_spec_iceclad'),(5004307,'bless_r2_spec_abysmal'),
    (5004308,'bless_r2_spec_shadeweaver'),(5004309,'bless_r2_spec_hollowshade'),
    (5004310,'bless_r2_dopp1'),(5004311,'bless_r2_dopp2'),(5004312,'bless_r2_dopp3'),
    (5004315,'bless_r2_just_wfp'),(5004316,'bless_r2_just_sq'),
    (5004317,'bless_r2_just_erudin'),(5004318,'bless_r2_just_neriak'),
    (5004319,'bless_r2_just_sfelwithe'),(5004320,'bless_r2_just_kaladim'),
    (5004321,'bless_r2_just_oggok'),(5004322,'bless_r2_just_grobb'),
    (5004323,'bless_r2_just_rivervale'),(5004324,'bless_r2_just_qhills'),
    (5004325,'bless_r2_bpm_steamfont'),(5004326,'bless_r2_bpm_butcher'),
    (5004327,'bless_r2_bpm_qhills'),(5004328,'bless_r2_bpm_southro'),
    (5004329,'bless_r2_bpm_everfrost'),(5004330,'bless_r2_bpm_feerrott'),
    (5004331,'bless_r2_bpm_gfay'),(5004332,'bless_r2_bpm_nektulos');

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
    (5004300,344282,100),(5004301,344283,100),(5004302,344284,100),(5004303,344285,100),
    (5004304,344286,100),(5004305,344287,100),(5004306,344288,100),(5004307,344289,100),
    (5004308,344290,100),(5004309,344291,100),
    (5004310,344292,100),(5004311,344293,100),(5004312,344294,100),
    (5004315,344295,100),(5004316,344296,100),(5004317,344297,100),(5004318,344298,100),
    (5004319,344299,100),(5004320,344300,100),(5004321,344301,100),(5004322,344302,100),
    (5004323,344303,100),(5004324,344304,100),
    (5004325,344308,100),(5004326,344309,100),(5004327,344310,100),(5004328,344311,100),
    (5004329,344312,100),(5004330,344313,100),(5004331,344314,100),(5004332,344315,100);

INSERT INTO `spawn2`
    (`id`,`spawngroupID`,`zone`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
    (3390300,5004300,'everfrost',  3109,-3897,-60,0,1200,0),
    (3390301,5004301,'southkarana',1482,1127,20,0,1200,0),
    (3390302,5004302,'highpass',   -599,-250,6,0,1200,0),
    (3390303,5004303,'butcher',    677,-2489,-12,0,1200,0),
    (3390304,5004304,'lfaydark',   -228,-1779,12,0,1200,0),
    (3390305,5004305,'firiona',    -4333,1397,-140,0,1200,0),
    (3390306,5004306,'iceclad',    4661,1246,-39,0,1200,0),
    (3390307,5004307,'abysmal',    -143,39,130,0,1200,0),
    (3390308,5004308,'shadeweaver',-2448,-2685,-213,0,1200,0),
    (3390309,5004309,'hollowshade',1031,1960,162,0,1200,0),
    (3390310,5004310,'lavastorm',  700,50,-88,0,900,0),
    (3390311,5004311,'lavastorm',  720,70,-88,0,900,0),
    (3390312,5004312,'lavastorm',  740,90,-88,0,900,0),
    (3390315,5004315,'freportw',   -200,-888,-20,0,1200,0),
    (3390316,5004316,'qeynos',     290,-71,4,0,1200,0),
    (3390317,5004317,'erudnext',   -1102,-16,-2,0,1200,0),
    (3390318,5004318,'neriakc',    -67,-992,-21,0,1200,0),
    (3390319,5004319,'felwitheb',  402,-897,-5,0,1200,0),
    (3390320,5004320,'kaladimb',   156,257,-10,0,1200,0),
    (3390321,5004321,'oggok',      454,845,78,0,1200,0),
    (3390322,5004322,'grobb',      542,-379,-2,0,1200,0),
    (3390323,5004323,'rivervale',  231,-130,-6,0,1200,0),
    (3390324,5004324,'qeytoqrg',   130,120,-5,0,1200,0),
    (3390325,5004325,'steamfont',  -753,-1151,-108,0,3600,0),
    (3390326,5004326,'butcher',    3116,879,-12,0,3600,0),
    (3390327,5004327,'qeytoqrg',   113,139,-5,0,3600,0),
    (3390328,5004328,'southro',    -1524,-271,102,0,3600,0),
    (3390329,5004329,'everfrost',  567,1960,-60,0,3600,0),
    (3390330,5004330,'feerrott',   -2517,-1018,-23,0,3600,0),
    (3390331,5004331,'gfaydark',   688,421,117,0,3600,0),
    (3390332,5004332,'nektulos',   -637,-581,-34,0,3600,0);
