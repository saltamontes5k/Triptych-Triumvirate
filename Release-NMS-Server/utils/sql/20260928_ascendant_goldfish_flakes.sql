-- ============================================================================
-- Goldfish Flakes (Ascendant) -> rare fishing catch + guaranteed drops
-- Source: Ascendant-EQ-Emu/Ascendant-Server @ main (item 17681 "Goldfish Flakes")
-- Adapted for Triptych/EQS:
--   * Ascendant item 17681 collides with the live Glamour "U Slay My <3";
--     renumbered to the free id 121858.
--   * Fishing: one row per zone that already has a fishing table AND a water
--     map (all 69 qualifying zones), skill_level 50, weight 2 => rare.
--   * Guaranteed (100%) drop from Faydedar, #Lord Koi`Doken, Kelorek`Dar via a
--     dedicated lootdrop; their existing loot is untouched.
-- Idempotent. Rollback: 20260928_ascendant_goldfish_flakes_rollback.sql
-- ============================================================================
SET NAMES utf8mb4;

-- ---- Item ----
DELETE FROM items WHERE id = 121858;
INSERT INTO items VALUES (121858,0,'Goldfish Flakes',7,0,0,8,10,12,0,3,8,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,71,'','0',65535,4278190080,'0',0,0,1611,8,0,0,0,0,0,0,9,0,0,0,0,58,0,0,0,0,0,0,0,0,'',-1,8,0,0,0,62,5,1697,'IT63',0,14,0,0,0,0,'Delicious, nutritious, everything a growing fish needs!',0,0,58,5,0,0,0,0,10,1,1,0,4,0,65535,0,0,0,0,1,0,3,-1,0,0,-1,0,0,0,0,0,2,42,0,1,0,0,0,0,0,0,2,0,0,0,0,'2015-12-28 06:46:14','',0,0,0,0,100,0,1,'',0,-1,0,0,0,0,-1,0,0,0,0,0,0,0,0,-1,0,0,0,0,NULL,'2016-01-06 11:44:45',NULL,'13THFLOOR',0,'',1,0,0,0,0,0,0,0,0,0,-1,0,0,'0000000000000000000',0,'',-1,0,0,0,0,'',-1,0,0,0,0,0,'',-1,0,0,0,0,0,'',-1,0,0,0,0,0,'',-1,0,0,0,0,0,0,'','','','','',0,1,3,1,1,0,0,0,0,0,0,0,0,0,3,3,0,0,'2015-12-07 22:36:00',0,70,0,0,0,-1,0,0,0,0,0,0,0,0,'',-1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,-256,255,0,0,0,0,0,0,0,0);

-- ---- Fishing rows: one per qualifying zone (fishing table + water map) ----
DELETE FROM fishing WHERE Itemid = 121858;
DELETE FROM fishing WHERE id = 9501;
DELETE FROM fishing WHERE id = 9502;
DELETE FROM fishing WHERE id = 9503;
DELETE FROM fishing WHERE id = 9504;
DELETE FROM fishing WHERE id = 9505;
DELETE FROM fishing WHERE id = 9506;
DELETE FROM fishing WHERE id = 9507;
DELETE FROM fishing WHERE id = 9508;
DELETE FROM fishing WHERE id = 9509;
DELETE FROM fishing WHERE id = 9510;
DELETE FROM fishing WHERE id = 9511;
DELETE FROM fishing WHERE id = 9512;
DELETE FROM fishing WHERE id = 9513;
DELETE FROM fishing WHERE id = 9514;
DELETE FROM fishing WHERE id = 9515;
DELETE FROM fishing WHERE id = 9516;
DELETE FROM fishing WHERE id = 9517;
DELETE FROM fishing WHERE id = 9518;
DELETE FROM fishing WHERE id = 9519;
DELETE FROM fishing WHERE id = 9520;
DELETE FROM fishing WHERE id = 9521;
DELETE FROM fishing WHERE id = 9522;
DELETE FROM fishing WHERE id = 9523;
DELETE FROM fishing WHERE id = 9524;
DELETE FROM fishing WHERE id = 9525;
DELETE FROM fishing WHERE id = 9526;
DELETE FROM fishing WHERE id = 9527;
DELETE FROM fishing WHERE id = 9528;
DELETE FROM fishing WHERE id = 9529;
DELETE FROM fishing WHERE id = 9530;
DELETE FROM fishing WHERE id = 9531;
DELETE FROM fishing WHERE id = 9532;
DELETE FROM fishing WHERE id = 9533;
DELETE FROM fishing WHERE id = 9534;
DELETE FROM fishing WHERE id = 9535;
DELETE FROM fishing WHERE id = 9536;
DELETE FROM fishing WHERE id = 9537;
DELETE FROM fishing WHERE id = 9538;
DELETE FROM fishing WHERE id = 9539;
DELETE FROM fishing WHERE id = 9540;
DELETE FROM fishing WHERE id = 9541;
DELETE FROM fishing WHERE id = 9542;
DELETE FROM fishing WHERE id = 9543;
DELETE FROM fishing WHERE id = 9544;
DELETE FROM fishing WHERE id = 9545;
DELETE FROM fishing WHERE id = 9546;
DELETE FROM fishing WHERE id = 9547;
DELETE FROM fishing WHERE id = 9548;
DELETE FROM fishing WHERE id = 9549;
DELETE FROM fishing WHERE id = 9550;
DELETE FROM fishing WHERE id = 9551;
DELETE FROM fishing WHERE id = 9552;
DELETE FROM fishing WHERE id = 9553;
DELETE FROM fishing WHERE id = 9554;
DELETE FROM fishing WHERE id = 9555;
DELETE FROM fishing WHERE id = 9556;
DELETE FROM fishing WHERE id = 9557;
DELETE FROM fishing WHERE id = 9558;
DELETE FROM fishing WHERE id = 9559;
DELETE FROM fishing WHERE id = 9560;
DELETE FROM fishing WHERE id = 9561;
DELETE FROM fishing WHERE id = 9562;
DELETE FROM fishing WHERE id = 9563;
DELETE FROM fishing WHERE id = 9564;
DELETE FROM fishing WHERE id = 9565;
DELETE FROM fishing WHERE id = 9566;
DELETE FROM fishing WHERE id = 9567;
DELETE FROM fishing WHERE id = 9568;
DELETE FROM fishing WHERE id = 9569;
INSERT INTO fishing (id,zoneid,Itemid,skill_level,chance,npc_id,npc_chance,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES
(9501,3,121858,50,2,0,0,-1,-1,NULL,NULL),
(9502,5,121858,50,2,0,0,-1,-1,NULL,NULL),
(9503,12,121858,50,2,0,0,-1,-1,NULL,NULL),
(9504,13,121858,50,2,0,0,-1,-1,NULL,NULL),
(9505,14,121858,50,2,0,0,-1,-1,NULL,NULL),
(9506,15,121858,50,2,0,0,-1,-1,NULL,NULL),
(9507,17,121858,50,2,0,0,-1,-1,NULL,NULL),
(9508,25,121858,50,2,0,0,-1,-1,NULL,NULL),
(9509,38,121858,50,2,0,0,-1,-1,NULL,NULL),
(9510,39,121858,50,2,0,0,-1,-1,NULL,NULL),
(9511,46,121858,50,2,0,0,-1,-1,NULL,NULL),
(9512,47,121858,50,2,0,0,-1,-1,NULL,NULL),
(9513,51,121858,50,2,0,0,-1,-1,NULL,NULL),
(9514,55,121858,50,2,0,0,-1,-1,NULL,NULL),
(9515,58,121858,50,2,0,0,-1,-1,NULL,NULL),
(9516,61,121858,50,2,0,0,-1,-1,NULL,NULL),
(9517,62,121858,50,2,0,0,-1,-1,NULL,NULL),
(9518,64,121858,50,2,0,0,-1,-1,NULL,NULL),
(9519,68,121858,50,2,0,0,-1,-1,NULL,NULL),
(9520,69,121858,50,2,0,0,-1,-1,NULL,NULL),
(9521,70,121858,50,2,0,0,-1,-1,NULL,NULL),
(9522,74,121858,50,2,0,0,-1,-1,NULL,NULL),
(9523,79,121858,50,2,0,0,-1,-1,NULL,NULL),
(9524,82,121858,50,2,0,0,-1,-1,NULL,NULL),
(9525,83,121858,50,2,0,0,-1,-1,NULL,NULL),
(9526,84,121858,50,2,0,0,-1,-1,NULL,NULL),
(9527,89,121858,50,2,0,0,-1,-1,NULL,NULL),
(9528,90,121858,50,2,0,0,-1,-1,NULL,NULL),
(9529,93,121858,50,2,0,0,-1,-1,NULL,NULL),
(9530,96,121858,50,2,0,0,-1,-1,NULL,NULL),
(9531,98,121858,50,2,0,0,-1,-1,NULL,NULL),
(9532,102,121858,50,2,0,0,-1,-1,NULL,NULL),
(9533,103,121858,50,2,0,0,-1,-1,NULL,NULL),
(9534,106,121858,50,2,0,0,-1,-1,NULL,NULL),
(9535,107,121858,50,2,0,0,-1,-1,NULL,NULL),
(9536,110,121858,50,2,0,0,-1,-1,NULL,NULL),
(9537,113,121858,50,2,0,0,-1,-1,NULL,NULL),
(9538,116,121858,50,2,0,0,-1,-1,NULL,NULL),
(9539,117,121858,50,2,0,0,-1,-1,NULL,NULL),
(9540,120,121858,50,2,0,0,-1,-1,NULL,NULL),
(9541,121,121858,50,2,0,0,-1,-1,NULL,NULL),
(9542,125,121858,50,2,0,0,-1,-1,NULL,NULL),
(9543,126,121858,50,2,0,0,-1,-1,NULL,NULL),
(9544,128,121858,50,2,0,0,-1,-1,NULL,NULL),
(9545,181,121858,50,2,0,0,-1,-1,NULL,NULL),
(9546,182,121858,50,2,0,0,-1,-1,NULL,NULL),
(9547,203,121858,50,2,0,0,-1,-1,NULL,NULL),
(9548,204,121858,50,2,0,0,-1,-1,NULL,NULL),
(9549,205,121858,50,2,0,0,-1,-1,NULL,NULL),
(9550,208,121858,50,2,0,0,-1,-1,NULL,NULL),
(9551,210,121858,50,2,0,0,-1,-1,NULL,NULL),
(9552,216,121858,50,2,0,0,-1,-1,NULL,NULL),
(9553,224,121858,50,2,0,0,-1,-1,NULL,NULL),
(9554,225,121858,50,2,0,0,-1,-1,NULL,NULL),
(9555,226,121858,50,2,0,0,-1,-1,NULL,NULL),
(9556,229,121858,50,2,0,0,-1,-1,NULL,NULL),
(9557,234,121858,50,2,0,0,-1,-1,NULL,NULL),
(9558,239,121858,50,2,0,0,-1,-1,NULL,NULL),
(9559,244,121858,50,2,0,0,-1,-1,NULL,NULL),
(9560,249,121858,50,2,0,0,-1,-1,NULL,NULL),
(9561,254,121858,50,2,0,0,-1,-1,NULL,NULL),
(9562,259,121858,50,2,0,0,-1,-1,NULL,NULL),
(9563,264,121858,50,2,0,0,-1,-1,NULL,NULL),
(9564,279,121858,50,2,0,0,-1,-1,NULL,NULL),
(9565,280,121858,50,2,0,0,-1,-1,NULL,NULL),
(9566,395,121858,50,2,0,0,-1,-1,NULL,NULL),
(9567,413,121858,50,2,0,0,-1,-1,NULL,NULL),
(9568,422,121858,50,2,0,0,-1,-1,NULL,NULL),
(9569,480,121858,50,2,0,0,-1,-1,NULL,NULL);

-- ---- Guaranteed drops ----
DELETE FROM loottable_entries WHERE lootdrop_id = 1520008200;
DELETE FROM lootdrop_entries WHERE lootdrop_id = 1520008200;
DELETE FROM lootdrop WHERE id = 1520008200;
INSERT INTO lootdrop (id,name,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES (1520008200,'Goldfish Flakes (Guaranteed)',-1,-1,NULL,NULL);
INSERT INTO lootdrop_entries (lootdrop_id,item_id,item_charges,equip_item,chance,disabled_chance,trivial_min_level,trivial_max_level,multiplier,npc_min_level,npc_max_level,min_expansion,max_expansion,content_flags,content_flags_disabled) VALUES (1520008200,121858,1,0,100,0,0,0,1,0,0,-1,-1,NULL,NULL);
INSERT INTO loottable_entries (loottable_id,lootdrop_id,multiplier,droplimit,mindrop,probability) VALUES (14255,1520008200,1,1,1,100),(7730,1520008200,1,1,1,100),(2810,1520008200,1,1,1,100);
