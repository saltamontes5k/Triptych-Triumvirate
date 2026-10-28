-- 227: Dwarven Keg Wedding monster mission (brewing / alcohol tolerance).
-- Twin of the manifest v227 entry (common/database/database_update_manifest_custom.cpp).
--
-- Builds:
--   * kaladima (South Kaladim, zoneidnumber 60) version 25 -- an empty clone of
--     the base zone; base spawn2 rows are version 0 so only version 25 rows load.
--   * the Dwarven Keg of Beer 25 shroud (id 501, race 377 = Barrel, model
--     BRL / brl_ch, neutral; level 25 enchanter clone of Evil Eye Psion 25).
--   * the "Brewing" shroud-ability catalog: eleven booze-named activated AAs that
--     cast the Evil Eye Psion 25 kit, with Mana Bolt replaced by the Air Elemental
--     shroud's Gale Force (8328).
--   * ten base wedding guests, eight optional extra-quest guests (spawned by
--     the controller for larger groups), the invisible controller, seven
--     objector rows, and the bazaar quest giver Dorgan Thunderbrew.
--
-- The ability AAs use stock spells only. Alt-ability casts bypass the spell's own
-- recast (spells.cpp: AltAbility starts the AA timer and skips the spell timer),
-- so Keg Blast can reuse stock Gale Force 8328 on a 6 second AA recast without a
-- new spell row or client spell-file export.

-- ------------------------------------------------------------------
-- Zone version: empty clone of South Kaladim v0 as version 25.
-- ------------------------------------------------------------------
DELETE FROM `zone` WHERE `zoneidnumber` = 60 AND `version` = 25;
DROP TEMPORARY TABLE IF EXISTS `tmp_keg_zone`;
CREATE TEMPORARY TABLE `tmp_keg_zone` AS
	SELECT * FROM `zone` WHERE `zoneidnumber` = 60 AND `version` = 0 LIMIT 1;
UPDATE `tmp_keg_zone`
	SET `id` = (SELECT COALESCE(MAX(`id`), 0) + 1 FROM `zone`),
		`version` = 25,
		`long_name` = 'South Kaladim: Dwarven Keg Wedding';
INSERT INTO `zone` SELECT * FROM `tmp_keg_zone`;
DROP TEMPORARY TABLE `tmp_keg_zone`;

-- ------------------------------------------------------------------
-- Shroud form: Dwarven Keg of Beer 25. Race 377 is the stock barrel/keg
-- model (the a_wooden_barrel / a_kobold_barrel NPCs use it). Stats are the
-- Evil Eye Psion 25 base_data row (630 hp / 516 mana / 516 endurance).
-- ------------------------------------------------------------------
DELETE FROM `shrouds` WHERE `id` = 501 OR `progression` = 'Brewing';
INSERT INTO `shrouds`
	(`id`,`name`,`progression`,`branch`,`level`,`race`,`gender`,`class`,`texture`,`helmet_texture`,`size`,`hp`,`mana`,`endurance`)
SELECT
	501, 'Dwarven Keg of Beer 25', 'Brewing', 'Dwarven Keg of Beer', b.`level`, 377, 2, 14, 0, 255, 5.0,
	CAST(ROUND(5 + b.`hp` + b.`hp_fac` * 75) AS SIGNED),
	CASE WHEN b.`mana` > 0 THEN CAST(ROUND(b.`mana` + b.`mana_fac` * 75) AS SIGNED) ELSE 0 END,
	CAST(ROUND(b.`end` + b.`end_fac` * 75) AS SIGNED)
FROM `base_data` b
WHERE b.`level` = 25 AND b.`class` = 14;

-- ------------------------------------------------------------------
-- Brewing ability catalog. Every row is min_level 25 (the form level), so a
-- fresh keg can buy all eleven with the 36 monster points a level 25 shroud
-- grants. display_order is the AA pane order.
-- ------------------------------------------------------------------
DELETE FROM `shroud_abilities` WHERE `progression` = 'Brewing';
INSERT INTO `shroud_abilities` (`progression`,`min_level`,`kind`,`aa_id`,`display_order`) VALUES
('Brewing',25,'active',90120,1),  -- Beer Goggles        (Gaze of the Beholder I, 8310)
('Brewing',25,'active',90121,2),  -- Liquid Courage       (Gift of Speed V, 8294)
('Brewing',25,'active',90122,3),  -- Drunken Stupor       (Lethargy I, 7536)
('Brewing',25,'active',90123,4),  -- Beer Bubbles         (Levitate, 261)
('Brewing',25,'active',90124,5),  -- Stale Brew           (Malaise I, 8300)
('Brewing',25,'active',90125,6),  -- Keg Blast            (Gale Force, 8328)
('Brewing',25,'active',90126,7),  -- Hair of the Dog      (Pure Thought IV, 8174)
('Brewing',25,'active',90127,8),  -- Sober Up             (Remove Curse I, 7514)
('Brewing',25,'active',90128,9),  -- Pass Out             (Sleep II, 7532)
('Brewing',25,'active',90129,10), -- Last Call            (Spirit Sending, 7790)
('Brewing',25,'active',90130,11); -- Brewmaster's Bidding (Beguile, 182)

-- ------------------------------------------------------------------
-- Booze-named clones of the Evil Eye Psion 25 activated kit. Stock spell
-- ids, so no spell export / shared-memory regen is needed. The AA recast is
-- the real gate for an AltAbility cast.
-- ------------------------------------------------------------------
DELETE FROM `aa_rank_effects` WHERE `rank_id` BETWEEN 90320 AND 90330;
DELETE FROM `aa_ranks` WHERE `id` BETWEEN 90320 AND 90330;
DELETE FROM `aa_ability` WHERE `id` BETWEEN 90120 AND 90130;
DELETE FROM `db_str` WHERE `id` BETWEEN 90120 AND 90130;

INSERT INTO `aa_ability`
	(`id`,`name`,`category`,`classes`,`races`,`drakkin_heritage`,`deities`,`status`,`type`,`charges`,`grant_only`,`first_rank_id`,`enabled`,`reset_on_death`,`auto_grant_enabled`)
VALUES
(90120,'Beer Goggles',-1,65535,65535,127,131071,0,1,0,0,90320,1,0,0),
(90121,'Liquid Courage',-1,65535,65535,127,131071,0,1,0,0,90321,1,0,0),
(90122,'Drunken Stupor',-1,65535,65535,127,131071,0,1,0,0,90322,1,0,0),
(90123,'Beer Bubbles',-1,65535,65535,127,131071,0,1,0,0,90323,1,0,0),
(90124,'Stale Brew',-1,65535,65535,127,131071,0,1,0,0,90324,1,0,0),
(90125,'Keg Blast',-1,65535,65535,127,131071,0,1,0,0,90325,1,0,0),
(90126,'Hair of the Dog',-1,65535,65535,127,131071,0,1,0,0,90326,1,0,0),
(90127,'Sober Up',-1,65535,65535,127,131071,0,1,0,0,90327,1,0,0),
(90128,'Pass Out',-1,65535,65535,127,131071,0,1,0,0,90328,1,0,0),
(90129,'Last Call',-1,65535,65535,127,131071,0,1,0,0,90329,1,0,0),
(90130,'Brewmaster''s Bidding',-1,65535,65535,127,131071,0,1,0,0,90330,1,0,0);

INSERT INTO `aa_ranks`
	(`id`,`upper_hotkey_sid`,`lower_hotkey_sid`,`title_sid`,`desc_sid`,`cost`,`level_req`,`spell`,`spell_type`,`recast_time`,`expansion`,`prev_id`,`next_id`)
VALUES
(90320,90120,90120,90120,90120,1,1,8310,0,30,0,-1,-1),   -- Beer Goggles
(90321,90121,90121,90121,90121,1,1,8294,0,2,0,-1,-1),    -- Liquid Courage
(90322,90122,90122,90122,90122,1,1,7536,0,9,0,-1,-1),    -- Drunken Stupor
(90323,90123,90123,90123,90123,1,1,261,0,5,0,-1,-1),    -- Beer Bubbles
(90324,90124,90124,90124,90124,1,1,8300,0,10,0,-1,-1),   -- Stale Brew
(90325,90125,90125,90125,90125,1,1,8328,0,6,0,-1,-1),    -- Keg Blast (Gale Force)
(90326,90126,90126,90126,90126,1,1,8174,0,2,0,-1,-1),    -- Hair of the Dog
(90327,90127,90127,90127,90127,1,1,7514,0,6,0,-1,-1),    -- Sober Up
(90328,90128,90128,90128,90128,1,1,7532,0,6,0,-1,-1),    -- Pass Out
(90329,90129,90129,90129,90129,1,1,7790,0,900,0,-1,-1),  -- Last Call
(90330,90130,90130,90130,90130,1,1,182,0,10,0,-1,-1);    -- Brewmaster's Bidding

INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
(90120,1,'Beer Goggles'),(90120,2,'Brewing'),(90120,3,'Goggles'),
(90120,4,'A bleary, beery stare that stuns your target for a moment. (All Classes)'),
(90121,1,'Liquid Courage'),(90121,2,'Brewing'),(90121,3,'Courage'),
(90121,4,'Liquid courage: 25% haste for 30 minutes. (All Classes)'),
(90122,1,'Drunken Stupor'),(90122,2,'Brewing'),(90122,3,'Stupor'),
(90122,4,'Slow your target''s attacks by 35% with a wave of cheap ale. (All Classes)'),
(90123,1,'Beer Bubbles'),(90123,2,'Brewing'),(90123,3,'Bubbles'),
(90123,4,'Bubbles of beer lift your target off the floor. (All Classes)'),
(90124,1,'Stale Brew'),(90124,2,'Brewing'),(90124,3,'Stale'),
(90124,4,'A pint of stale brew lowers the target''s magic, fire, cold and poison resistances. (All Classes)'),
(90125,1,'Keg Blast'),(90125,2,'Brewing'),(90125,3,'Blast'),
(90125,4,'A blast of beery wind stuns everything nearby. Reuses the Air Elemental shroud''s Gale Force. (All Classes)'),
(90126,1,'Hair of the Dog'),(90126,2,'Brewing'),(90126,3,'Hair'),
(90126,4,'The hair of the dog: steady mana regeneration for 15 minutes. (All Classes)'),
(90127,1,'Sober Up'),(90127,2,'Brewing'),(90127,3,'Sober'),
(90127,4,'Sober up and shed a curse. (All Classes)'),
(90128,1,'Pass Out'),(90128,2,'Brewing'),(90128,3,'Pass Out'),
(90128,4,'So dull the target with drink that it falls asleep where it stands. (All Classes)'),
(90129,1,'Last Call'),(90129,2,'Brewing'),(90129,3,'Last Call'),
(90129,4,'Last call sends you and your group home. (All Classes)'),
(90130,1,'Brewmaster''s Bidding'),(90130,2,'Brewing'),(90130,3,'Bidding'),
(90130,4,'Charm the brewmaster into tapping the keg. (All Classes)');

-- ------------------------------------------------------------------
-- NPCs. The base party, the optional extra-quest guests and the seven objectors
-- all share the name a_wedding_guest so one quest script can serve them;
-- GetNPCTypeID() tells them apart. Guests never aggro and cannot be aggroed by
-- NPCs, but a client can still hit them -- the "alcohol kills" fail state.
-- ------------------------------------------------------------------
DELETE FROM `npc_types` WHERE `id` BETWEEN 1520001900 AND 1520001930;
INSERT INTO `npc_types`
	(`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`mindmg`,`maxdmg`,`attack_delay`,`AC`,`npc_aggro`,`aggroradius`,`npc_faction_id`,`npc_spells_id`,`merchant_id`,`loottable_id`,`special_abilities`)
VALUES
-- Wedding party (static).
(1520001900,'a_wedding_guest','Matron of the Ironforge',25,8,1,1,600,1,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001901,'a_wedding_guest','Uncle Borruk',25,8,1,1,600,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001902,'a_wedding_guest','Uncle Dagnar',25,8,1,1,600,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001903,'a_wedding_guest','Best Man Balric',25,8,1,1,600,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001904,'a_wedding_guest','Brewmaster Frothy',25,8,1,1,600,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001905,'a_wedding_guest','Priest of Brell',30,8,2,1,800,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001906,'a_wedding_guest','Wedding Guest',25,8,1,1,500,1,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001907,'a_wedding_guest','Wedding Guest',25,8,1,1,500,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001908,'a_wedding_guest','Wedding Guest',25,8,1,1,500,1,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001909,'a_wedding_guest','Wedding Guest',25,8,1,1,500,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
-- Optional extra-quest guests. The controller spawns these only when a larger
-- group needs the extra wedding tasks (2+ players -> aunts, 3+ -> father-in-law,
-- 4+ -> groom, 5+ -> bridesmaids, 6 -> grandparents).
(1520001917,'a_wedding_guest','Aunt Hilde',25,8,1,1,600,1,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001918,'a_wedding_guest','Aunt Marta',25,8,1,1,600,1,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001919,'a_wedding_guest','Father-in-law Grund',25,8,1,1,600,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001921,'a_wedding_guest','the Groom',25,8,1,1,600,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001922,'a_wedding_guest','Bridesmaid Inga',25,8,1,1,600,1,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001923,'a_wedding_guest','Bridesmaid Sif',25,8,1,1,600,1,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001924,'a_wedding_guest','Grandfather Odin',25,8,1,1,600,0,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
(1520001925,'a_wedding_guest','Grandmother Freya',25,8,1,1,600,1,0,0,4.0,1.0,0,0,30,100,0,0,0,0,0,0,'24,1^25,1'),
-- Seven objectors (spawned by the controller at checkpoint 5). Distinct NPC
-- type ids so the guest script can report each one individually.
(1520001910,'a_wedding_guest','Objector to the Union',26,8,1,1,1800,0,0,0,4.5,1.25,3,9,40,120,1,200,0,0,0,0,'21,1'),
(1520001911,'a_wedding_guest','Objector to the Union',26,8,1,1,1800,0,0,0,4.5,1.25,3,9,40,120,1,200,0,0,0,0,'21,1'),
(1520001912,'a_wedding_guest','Objector to the Union',26,8,1,1,1800,0,0,0,4.5,1.25,3,9,40,120,1,200,0,0,0,0,'21,1'),
(1520001913,'a_wedding_guest','Objector to the Union',26,8,1,1,1800,0,0,0,4.5,1.25,3,9,40,120,1,200,0,0,0,0,'21,1'),
(1520001914,'a_wedding_guest','Objector to the Union',26,8,1,1,1800,0,0,0,4.5,1.25,3,9,40,120,1,200,0,0,0,0,'21,1'),
(1520001915,'a_wedding_guest','Objector to the Union',26,8,1,1,1800,0,0,0,4.5,1.25,3,9,40,120,1,200,0,0,0,0,'21,1'),
(1520001916,'a_wedding_guest','Objector to the Union',26,8,1,1,1800,0,0,0,4.5,1.25,3,9,40,120,1,200,0,0,0,0,'21,1'),
-- Invisible zone controller and the bazaar quest giver.
(1520001920,'#Dwarven_Wedding_Controller','The Wedding Keg',100,587,1,3,32000,0,0,0,6.0,1.25,0,0,30,300,0,0,0,0,0,0,'19,1^24,1^25,1'),
(1520001930,'Dorgan_Thunderbrew','Wedding Guest',50,8,1,1,1500,0,0,0,4.0,1.25,0,0,30,300,0,0,0,0,0,0,'19,1^24,1^25,1');

-- ------------------------------------------------------------------
-- Spawns. Guests/controller are version 25 (only the instance loads them);
-- Dorgan is version 0 in the Bazaar next to Wendel Sweetcrumb.
-- ------------------------------------------------------------------
DELETE FROM `spawngroup` WHERE `id` BETWEEN 5004601 AND 5004612;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 5004601 AND 5004612;
DELETE FROM `spawn2` WHERE `id` BETWEEN 1520023810 AND 1520023821;

INSERT INTO `spawngroup` (`id`,`name`) VALUES
(5004601,'dwarven_wedding_controller_kaladima_25'),
(5004602,'dwarven_wedding_matron'),
(5004603,'dwarven_wedding_priest'),
(5004604,'dwarven_wedding_best_man'),
(5004605,'dwarven_wedding_brewmaster'),
(5004606,'dwarven_wedding_uncle_borruk'),
(5004607,'dwarven_wedding_uncle_dagnar'),
(5004608,'dwarven_wedding_guest_1'),
(5004609,'dwarven_wedding_guest_2'),
(5004610,'dwarven_wedding_guest_3'),
(5004611,'dwarven_wedding_guest_4'),
(5004612,'dorgan_thunderbrew_bazaar');

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
(5004601,1520001920,100),
(5004602,1520001900,100),
(5004603,1520001905,100),
(5004604,1520001903,100),
(5004605,1520001904,100),
(5004606,1520001901,100),
(5004607,1520001902,100),
(5004608,1520001906,100),
(5004609,1520001907,100),
(5004610,1520001908,100),
(5004611,1520001909,100),
(5004612,1520001930,100);

INSERT INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
(1520023810,5004601,'kaladima',25,396,44,30,0,0,0),
(1520023811,5004602,'kaladima',25,396,34,9,0,0,0),
(1520023812,5004603,'kaladima',25,396,24,9,0,0,0),
(1520023813,5004604,'kaladima',25,410,44,9,192,0,0),
(1520023814,5004605,'kaladima',25,382,44,9,128,0,0),
(1520023815,5004606,'kaladima',25,386,54,9,0,0,0),
(1520023816,5004607,'kaladima',25,406,54,9,0,0,0),
(1520023817,5004608,'kaladima',25,378,36,9,0,0,0),
(1520023818,5004609,'kaladima',25,414,36,9,0,0,0),
(1520023819,5004610,'kaladima',25,378,52,9,0,0,0),
(1520023820,5004611,'kaladima',25,414,52,9,0,0,0),
(1520023821,5004612,'bazaar',0,170,-496,3,270,7200,0);
