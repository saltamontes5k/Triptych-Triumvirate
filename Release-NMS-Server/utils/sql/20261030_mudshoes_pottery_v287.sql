-- 287: Mudshoes' Pottery Trial (beholder v80 tradeskill shroud mission).
-- Twin of the manifest v287 entry (common/database/database_update_manifest_custom.cpp).
-- Second mission in the Wendel cake-defense family (v121). A halfling potter
-- shroud quest: players enter a cleared beholder v80 expedition as a tiny
-- clay golem (shrouds.id 506, race 17), survive the water-elemental camp at
-- the entrance until the halfling potter lands one hit (the shaping), then
-- grow +30% per stage via the instant SE_ModelSize spell 44032 while they
-- fight 10 shaper's hands, then 10 fire elementals (kiln flames 1520001999
-- are melee/magic/client-harm immune scenery), then march back and one-shot
-- the potter, the gnomish magician and his elementals. Pays Pottery (skill
-- 69) +30 capped at 300 like the cake pays Baking.
--
-- Idempotent: every block is delete-guarded. Rollback:
-- 20261030_mudshoes_pottery_v287_rollback.sql
--
-- NOTE: three new spell ids require a spells_us.txt re-export
-- (shared_memory.bat, export-client-files.bat, restart zone layer) or the
-- buff icons / cast text are blank on the RoF2 client.
-- NOTE: re-running 20260922_shroud_catalog.sql wipes the shrouds table and
-- drops the clay golem row; re-run this file afterwards if that ever happens.

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- 1. Zone version row: clone beholder (zoneidnumber 16) v0 as version 80.
-- CREATE TABLE AS SELECT drops the auto_increment attribute, so give the id
-- explicitly; delete-guarded so re-runs stay idempotent. The instance is a
-- CLEARED clone: no spawn2 rows are copied from v0, so only the controller
-- (spawned below) and the controller-spawned stage actors exist in v80.
-- ---------------------------------------------------------------------------
DELETE FROM `zone` WHERE `zoneidnumber` = 16 AND `version` = 80;
DROP TEMPORARY TABLE IF EXISTS `tmp_zone`;
CREATE TEMPORARY TABLE `tmp_zone` AS SELECT * FROM `zone` WHERE `zoneidnumber` = 16 AND `version` = 0 LIMIT 1;
UPDATE `tmp_zone` SET `id` = (SELECT COALESCE(MAX(`id`), 0) + 1 FROM `zone`),
                    `version` = 80, `long_name` = 'Gorge of King Xorbb: Mudshoes'' Pottery Trial';
INSERT INTO `zone` SELECT * FROM `tmp_zone`;
DROP TEMPORARY TABLE `tmp_zone`;

-- ---------------------------------------------------------------------------
-- 2. Clay Golem 25 shroud form (id 506). Explicit id: quest scripts call
-- ApplyShroud(506). Race 17 is the clay golem/muddite model the zone already
-- uses; class 1 (warrior) is the form's class. size 2.0 is deliberately
-- tiny (the local muddites are 4-5): the grow spell (44032) multiplies the
-- CURRENT size, so the growth story reads tiny -> shaped -> kiln-fired.
-- Stats derive from base_data like the shroud catalog.
-- ---------------------------------------------------------------------------
DELETE FROM `shrouds` WHERE `id` = 506 OR `progression` = 'Earthenwares';
INSERT INTO `shrouds`
	(`id`,`name`,`progression`,`branch`,`level`,`race`,`gender`,`class`,`texture`,`helmet_texture`,`size`,`hp`,`mana`,`endurance`)
SELECT
	506, 'Clay Golem 25', 'Earthenwares', 'Clay Golem', b.`level`, 17, 2, 1, 0, 255, 2.0,
	CAST(ROUND(5 + b.`hp` + b.`hp_fac` * 75) AS SIGNED),
	CASE WHEN b.`mana` > 0 THEN CAST(ROUND(b.`mana` + b.`mana_fac` * 75) AS SIGNED) ELSE 0 END,
	CAST(ROUND(b.`end` + b.`end_fac` * 75) AS SIGNED)
FROM base_data b
WHERE b.`level` = 25 AND b.`class` = 1;

-- ---------------------------------------------------------------------------
-- 3. Mission spells (custom band below the RoF2 client spell ceiling of
-- 45001; next free after 44031). Clone-and-modify like the deity-blessing
-- spells, classes1-16 = 255, resisttype 0 (unresistable, like Parsing Root).
--   44032 Kiln Growth       instant SE_ModelSize base 130 = +30% of current
--                           size; the engine self-caps at two growths from
--                           base size, which is exactly the two-cast design.
--   44033 Clay Toughening I   permanent SE_MaxHPChange +400 max HP  (stage 2)
--   44034 Clay Toughening II  permanent SE_MaxHPChange +1200 max HP (stage 3)
-- No shroud_abilities rows: the golem fights with its own hands (doc section
-- 6 is the place to add a kit later).
-- ---------------------------------------------------------------------------
DELETE FROM `spells_new` WHERE `id` IN (44032, 44033, 44034);

-- 44032 Kiln Growth (from stock Shrink 40838: single target, beneficial,
-- instant -- buffdurationformula 0 means no buff slot; the size change is
-- sticky and survives the cast, which is what "grow" wants).
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id` = 40838;
UPDATE `tmp_spell` SET
	`id` = 44032, `name` = 'Kiln Growth',
	`you_cast` = 'Your clay body swells as it takes shape.', `other_casts` = '',
	`cast_on_you` = 'Your clay body swells as it takes shape.', `cast_on_other` = ' swells with shaped clay.',
	`effect_base_value1` = 130,
	`classes1` = 255, `classes2` = 255, `classes3` = 255, `classes4` = 255, `classes5` = 255, `classes6` = 255,
	`classes7` = 255, `classes8` = 255, `classes9` = 255, `classes10` = 255, `classes11` = 255,
	`classes12` = 255, `classes13` = 255, `classes14` = 255, `classes15` = 255, `classes16` = 255
WHERE `id` = 40838;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- 44033 Clay Toughening I (from Plague of Hulcror 5713, a flat SE_MaxHPChange
-- debuff: flip the sign, make it a beneficial permanent buff).
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id` = 5713;
UPDATE `tmp_spell` SET
	`id` = 44033, `name` = 'Clay Toughening I',
	`goodEffect` = 1, `buffdurationformula` = 50, `buffduration` = 0, `resisttype` = 0,
	`you_cast` = 'You knead yourself into shape.', `other_casts` = '',
	`cast_on_you` = 'Your clay firms up under firm hands.',
	`cast_on_other` = ' firms up under firm hands.', `spell_fades` = 'Your clay softens.',
	`effect_base_value1` = 400,
	`classes1` = 255, `classes2` = 255, `classes3` = 255, `classes4` = 255, `classes5` = 255, `classes6` = 255,
	`classes7` = 255, `classes8` = 255, `classes9` = 255, `classes10` = 255, `classes11` = 255,
	`classes12` = 255, `classes13` = 255, `classes14` = 255, `classes15` = 255, `classes16` = 255
WHERE `id` = 5713;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- 44034 Clay Toughening II (same donor, kiln-fired magnitude).
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id` = 5713;
UPDATE `tmp_spell` SET
	`id` = 44034, `name` = 'Clay Toughening II',
	`goodEffect` = 1, `buffdurationformula` = 50, `buffduration` = 0, `resisttype` = 0,
	`you_cast` = 'The kiln hardens you.', `other_casts` = '',
	`cast_on_you` = 'The kiln fire hardens your clay to stoneware.',
	`cast_on_other` = ' hardens to stoneware in the kiln fire.', `spell_fades` = 'Your stoneware softens.',
	`effect_base_value1` = 1200,
	`classes1` = 255, `classes2` = 255, `classes3` = 255, `classes4` = 255, `classes5` = 255, `classes6` = 255,
	`classes7` = 255, `classes8` = 255, `classes9` = 255, `classes10` = 255, `classes11` = 255,
	`classes12` = 255, `classes13` = 255, `classes14` = 255, `classes15` = 255, `classes16` = 255
WHERE `id` = 5713;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---------------------------------------------------------------------------
-- 4. NPCs. 1520001995 intentionally unused (kept as a spare in the band).
-- Elemental/mage/potter damage is enormous against the tiny golem (one hit
-- kills it, which is the stage-1 hazard) but their HP is a sliver, so the
-- twice-grown, toughened golem one-shots them in stage 4 -- the same three
-- actors serve both stages and never despawn between them.
-- The kiln flame is unkillable scenery: 'ABZ' = melee/magic/client-harm
-- immunity (npc.cpp NPCSpecialAttacks letters), npc_aggro 0.
-- ---------------------------------------------------------------------------
DELETE FROM `npc_types` WHERE `id` IN
	(1520001990,1520001991,1520001992,1520001993,1520001994,1520001996,1520001997,1520001998,1520001999);
INSERT INTO `npc_types`
	(`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`mindmg`,`maxdmg`,`attack_delay`,`AC`,`npc_aggro`,`aggroradius`,`npc_faction_id`,`npc_spells_id`,`merchant_id`,`loottable_id`,`npcspecialattks`)
VALUES
	(1520001990,'Pimm_Mudshoes','Wheeler of the Bazaar',30,128,1,1,1500,0,0,0,3,1.25,0,0,30,300,0,0,0,0,0,0,''),
	(1520001991,'#Pottery_Trial_Controller','The Kiln Ward',100,587,1,3,32000,0,0,0,6,1.25,0,0,30,300,0,0,0,0,0,0,''),
	(1520001992,'a_halfling_potter','Wheeler of Clay',25,128,1,1,45,1,0,0,3,1.25,40,90,30,100,1,250,0,0,0,0,''),
	(1520001993,'a_gnomish_magician','Keeper of the Rite',25,12,1,1,60,0,0,0,3,1.25,8000,12000,30,100,1,250,0,0,0,0,''),
	(1520001994,'a_water_elemental','Bound to the Magician',25,211,1,1,60,2,0,0,5,1.25,9000,14000,30,150,1,400,0,0,0,0,''),
	(1520001996,'a_shapers_hand','Won''t Hold Still',10,80,1,1,180,2,0,0,4,1.25,10,24,30,120,1,600,0,0,0,0,''),
	(1520001997,'a_shapers_hand','Patient as Clay',10,80,1,1,180,2,1,0,4,1.25,10,24,30,120,0,0,0,0,0,0,''),
	(1520001998,'a_fire_elemental','Kiln-Bound',25,212,1,1,300,2,0,0,5,1.25,30,55,30,200,1,300,0,0,0,0,''),
	(1520001999,'a_kiln_flame','Cannot Be Shaped',30,212,1,1,32000,2,1,0,5,0.75,0,0,30,300,0,0,0,0,0,0,'ABZ');

-- ---------------------------------------------------------------------------
-- 5. Spawns: Mudshoes in the Bazaar v0 (next to Wendel_Sweetcrumb), the
-- invisible controller in beholder v80 (version column MUST be the instance
-- version or -1 or the instance boots with no controller). Stage actors are
-- NOT spawned here -- the controller spawns them per stage so the elemental
-- count can scale with the party.
-- spawn2 id band is shared across sessions: re-grep MAX(id) before reusing.
-- ---------------------------------------------------------------------------
DELETE FROM `spawngroup` WHERE `id` IN (5004767,5004768);
DELETE FROM `spawnentry` WHERE `spawngroupID` IN (5004767,5004768);
DELETE FROM `spawn2` WHERE `id` IN (1520028328,1520028329);
INSERT INTO `spawngroup` (`id`,`name`) VALUES
	(5004767,'pimm_mudshoes_bazaar'),
	(5004768,'pottery_trial_controller_beholder_80');
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
	(5004767,1520001990,100),
	(5004768,1520001991,100);
INSERT INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
	(1520028328,5004767,'bazaar',    0,162,-489,3,128,7200,0),
	(1520028329,5004768,'beholder', 80,-1840,720,9,0,0,0);

-- ---------------------------------------------------------------------------
-- 6. Roam grids (type 3, random, matching beholder's stock grid style) for
-- the entrance water elementals and the hunter shaper's hands. The passive
-- hands and every other stage actor get grid 0 (stand and wait).
-- grid ids are global: 1520000000 was already taken, these two were free.
-- ---------------------------------------------------------------------------
DELETE FROM `grid` WHERE `id` IN (1520000001,1520000002) AND `zoneid` = 16;
DELETE FROM `grid_entries` WHERE `gridid` IN (1520000001,1520000002) AND `zoneid` = 16;
INSERT INTO `grid` (`id`,`zoneid`,`type`,`type2`) VALUES
	(1520000001,16,3,0),
	(1520000002,16,3,0);
INSERT INTO `grid_entries` (`gridid`,`zoneid`,`number`,`x`,`y`,`z`,`heading`,`pause`,`centerpoint`) VALUES
	(1520000001,16,1,-1905,690,9,-1,15,0),
	(1520000001,16,2,-1770,775,9,-1,0,0),
	(1520000001,16,3,-1710,660,9,-1,0,0),
	(1520000001,16,4,-1855,805,9,-1,0,0),
	(1520000002,16,1,135,-100,7,-1,10,0),
	(1520000002,16,2,20,-205,7,-1,0,0),
	(1520000002,16,3,-100,-110,7,-1,0,0),
	(1520000002,16,4,15,-15,7,-1,0,0);
