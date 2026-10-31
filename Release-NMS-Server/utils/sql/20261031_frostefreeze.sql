-- 294: Frostefreeze — joke Frostfell ice cream expedition zone.
-- Twin of the manifest v294 entry (common/database/database_update_manifest_custom.cpp).
-- Frostcrypt (zoneidnumber 402) cloned to version 220 and renamed 'frostefreeze';
-- expedition-only, requested from Grimble_Underhollow in the Plane of Knowledge.
-- Zone contents spawn ONLY in version 220 instances (spawn2 version filtering).
--   * Ice-cream-named retro frost giants (clone of classic race 188 a_frost_giant
--     116019, stats hand-set for the L60+ PoK audience) drop the existing
--     Vanilla/Chocolate/Cherry Ice Cream items (75005/75006/75007).
--   * a_Rock_Candy_Golem and the shop-order rares (Rocky Road / Banana Split /
--     Neapolitan) are renames of Frostcrypt's own a_fallen_Krithgor_warrior
--     (402010 donor, race 523) — the "bit of challenge" tier.
-- Turn-ins on Grimble: any 20 ice creams -> EXISTING glamour item 701463
-- ("Glamour - 'Ice Cream Cone'", already in the items table); 10 Rock Candy
-- (64352) -> one bonus glamour. No new items anywhere in this migration.
--
-- Client requirement (manual, per install): copy frostcrypt.eqg/.emt/.mp3/.zon/
-- _assets.txt/_chr.txt/_environmentemitters.txt to frostefreeze.* — the client
-- resolves zone geometry from the version row's short name (zone.cpp LoadZoneCFG).

-- Zone version row: clone frostcrypt v0 as version 220. CTAS drops the
-- auto_increment attribute, so give the id explicitly; delete-guarded so re-runs
-- (or a world-boot retry) stay idempotent.
DELETE FROM `zone` WHERE `zoneidnumber` = 402 AND `version` = 220;
DROP TEMPORARY TABLE IF EXISTS `tmp_zone`;
CREATE TEMPORARY TABLE `tmp_zone` AS SELECT * FROM `zone` WHERE `zoneidnumber` = 402 AND `version` = 0 LIMIT 1;
UPDATE `tmp_zone` SET `id` = (SELECT COALESCE(MAX(`id`), 0) + 1 FROM `zone`),
                    `version` = 220,
                    `short_name` = 'frostefreeze',
                    `long_name` = 'Frostefreeze',
                    `min_expansion` = 0,
                    `flag_needed` = '',
                    `min_level` = 0;
INSERT INTO `zone` SELECT * FROM `tmp_zone`;
DROP TEMPORARY TABLE `tmp_zone`;

-- Faction: hostile to everyone (base -2000). The faction_list guard is
-- name-checked so a foreign row that has since claimed id 5062 fails loudly
-- instead of being deleted.
DELETE FROM `faction_list` WHERE `id` = 5062 AND `name` = 'Frostefreeze Ice Cream Men';
INSERT INTO `faction_list` (`id`,`name`,`base`) VALUES (5062,'Frostefreeze Ice Cream Men',-2000);
DELETE FROM `npc_faction` WHERE `id` = 1520000113;
INSERT INTO `npc_faction` (`id`,`name`,`primaryfaction`,`ignore_primary_assist`) VALUES (1520000113,'frostefreeze_kos',5062,0);

-- NPCs, band 1120002550-1120002558 (live max was 1120002547 at authoring time).
DELETE FROM `npc_types` WHERE `id` BETWEEN 1120002550 AND 1120002558;

-- Grimble (halfling, subtly wrong: slightly shrunken, unkillable, never hostile)
-- and the invisible egress/ambience controller, authored from scratch like the
-- cake-defense NPCs.
INSERT INTO `npc_types`
	(`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`mindmg`,`maxdmg`,`attack_delay`,`AC`,`npc_aggro`,`aggroradius`,`npc_faction_id`,`npc_spells_id`,`merchant_id`,`loottable_id`)
VALUES
	(1120002550,'Grimble_Underhollow','He Means Well',65,11,1,1,30000,0,0,0,2.8,1.25,0,0,30,500,0,0,0,0,0,0),
	(1120002551,'#Frostefreeze_Controller','The Freezer',100,587,1,3,32000,0,0,0,6,1.25,0,0,30,300,0,0,0,0,0,0);

-- Ice cream giants: classic retro giant model, tuned levels/damage.
DROP TEMPORARY TABLE IF EXISTS `tmp_nt`;
CREATE TEMPORARY TABLE `tmp_nt` AS SELECT * FROM `npc_types` WHERE `id` = 116019 LIMIT 1;
UPDATE `tmp_nt` SET `id` = 1120002552, `Name` = 'a_Vanilla_Ice_Cream_Cone', `lastname` = '',
	`level` = 60, `hp` = 12000, `AC` = 230, `mindmg` = 50, `maxdmg` = 120,
	`npc_faction_id` = 1520000113, `loottable_id` = 1520009320;
INSERT INTO `npc_types` SELECT * FROM `tmp_nt`;
UPDATE `tmp_nt` SET `id` = 1120002553, `Name` = 'a_Chocolate_Ice_Cream_Cone',
	`level` = 62, `hp` = 14000, `AC` = 245, `mindmg` = 55, `maxdmg` = 130,
	`loottable_id` = 1520009321;
INSERT INTO `npc_types` SELECT * FROM `tmp_nt`;
UPDATE `tmp_nt` SET `id` = 1120002554, `Name` = 'a_Cherry_Ice_Cream_Cone',
	`level` = 65, `hp` = 17000, `AC` = 260, `mindmg` = 60, `maxdmg` = 145,
	`loottable_id` = 1520009322;
INSERT INTO `npc_types` SELECT * FROM `tmp_nt`;
DROP TEMPORARY TABLE `tmp_nt`;

-- Candy golem + rares: renames of Frostcrypt's own fallen Krithgor warrior.
DROP TEMPORARY TABLE IF EXISTS `tmp_nt`;
CREATE TEMPORARY TABLE `tmp_nt` AS SELECT * FROM `npc_types` WHERE `id` = 402010 LIMIT 1;
UPDATE `tmp_nt` SET `id` = 1120002555, `Name` = 'a_Rock_Candy_Golem', `lastname` = 'Certified Organic',
	`level` = 75, `hp` = 7000, `mindmg` = 70, `maxdmg` = 170,
	`npc_faction_id` = 1520000113, `loottable_id` = 1520009323;
INSERT INTO `npc_types` SELECT * FROM `tmp_nt`;
UPDATE `tmp_nt` SET `id` = 1120002556, `Name` = 'Rocky_Road', `lastname` = 'A Hard Place',
	`level` = 76, `hp` = 16000, `AC` = 380, `mindmg` = 80, `maxdmg` = 190,
	`loottable_id` = 1520009324;
INSERT INTO `npc_types` SELECT * FROM `tmp_nt`;
UPDATE `tmp_nt` SET `id` = 1120002557, `Name` = 'Banana_Split', `lastname` = 'Split Personality';
INSERT INTO `npc_types` SELECT * FROM `tmp_nt`;
UPDATE `tmp_nt` SET `id` = 1120002558, `Name` = 'Neapolitan', `lastname` = 'Three Faces';
INSERT INTO `npc_types` SELECT * FROM `tmp_nt`;
DROP TEMPORARY TABLE `tmp_nt`;

-- Loot: five tables referencing EXISTING items only. Coin left at zero — this
-- zone pays in scoops.
DELETE FROM `loottable` WHERE `id` BETWEEN 1520009320 AND 1520009324;
DELETE FROM `loottable_entries` WHERE `loottable_id` BETWEEN 1520009320 AND 1520009324;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 1520009430 AND 1520009434;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 1520009430 AND 1520009434;
INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`) VALUES
	(1520009320,'frostefreeze_vanilla',0,0,0,0),
	(1520009321,'frostefreeze_chocolate',0,0,0,0),
	(1520009322,'frostefreeze_cherry',0,0,0,0),
	(1520009323,'frostefreeze_candy_golem',0,0,0,0),
	(1520009324,'frostefreeze_rare',0,0,0,0);
INSERT INTO `lootdrop` (`id`,`name`) VALUES
	(1520009430,'frostefreeze_vanilla_drop'),
	(1520009431,'frostefreeze_chocolate_drop'),
	(1520009432,'frostefreeze_cherry_drop'),
	(1520009433,'frostefreeze_candy_drop'),
	(1520009434,'frostefreeze_rare_drop');
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
	(1520009320,1520009430,1,0,0,100),
	(1520009321,1520009431,1,0,0,100),
	(1520009322,1520009432,1,0,0,100),
	(1520009323,1520009433,1,0,0,100),
	(1520009324,1520009434,1,0,0,100);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`) VALUES
	(1520009430,75005,1,0,100),
	(1520009431,75006,1,0,100),
	(1520009432,75007,1,0,100),
	(1520009433,64352,2,0,60),
	(1520009434,75005,5,0,100),
	(1520009434,75006,5,0,100),
	(1520009434,75007,5,0,100);

-- Spawn groups (1520009300-1520009308; live 152-band max was 1520009215) and
-- entries.
DELETE FROM `spawngroup` WHERE `id` BETWEEN 1520009300 AND 1520009308;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 1520009300 AND 1520009308;
INSERT INTO `spawngroup` (`id`,`name`) VALUES
	(1520009300,'grimble_underhollow_pok'),
	(1520009301,'frostefreeze_controller_v220'),
	(1520009302,'frostefreeze_vanilla'),
	(1520009303,'frostefreeze_chocolate'),
	(1520009304,'frostefreeze_cherry'),
	(1520009305,'frostefreeze_rock_candy_golem'),
	(1520009306,'frostefreeze_rocky_road'),
	(1520009307,'frostefreeze_banana_split'),
	(1520009308,'frostefreeze_neapolitan');
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
	(1520009300,1120002550,100),
	(1520009301,1120002551,100),
	(1520009302,1120002552,100),
	(1520009303,1120002553,100),
	(1520009304,1120002554,100),
	(1520009305,1120002555,100),
	(1520009306,1120002556,100),
	(1520009307,1120002557,100),
	(1520009308,1120002558,100);

-- Spawns. Grimble stands in poknowledge v0 near Devin_Traical's cluster; the
-- controller sits at the frostcrypt safe point; everything else is version 220
-- ONLY, placed on real frostcrypt v0 trash coordinates (sampled from spawn2),
-- spread from the entry halls to the deep halls. Rares hold the far reaches.
DELETE FROM `spawn2` WHERE `id` BETWEEN 1520028450 AND 1520028494;
INSERT INTO `spawn2`
	(`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
	(1520028450,1520009300,'poknowledge',  0,497,-30,-90,250,640,0),
	(1520028451,1520009301,'frostcrypt',220,10,-40,2,0,640,0),
	(1520028452,1520009302,'frostcrypt',220,99.625,98.0,-14.0,0,600,0),
	(1520028453,1520009302,'frostcrypt',220,-0.125,181.25,-53.625,0,600,0),
	(1520028454,1520009302,'frostcrypt',220,180.75,93.5,-62.5,0,600,0),
	(1520028455,1520009302,'frostcrypt',220,-207.25,56.625,-52.0,0,600,0),
	(1520028456,1520009302,'frostcrypt',220,255.75,22.875,-62.5,0,600,0),
	(1520028457,1520009302,'frostcrypt',220,182.75,188.0,-62.375,0,600,0),
	(1520028458,1520009302,'frostcrypt',220,-257.125,96.375,-62.5,0,600,0),
	(1520028459,1520009302,'frostcrypt',220,74.0,259.0,-62.5,0,600,0),
	(1520028460,1520009302,'frostcrypt',220,248.875,155.125,-62.375,0,600,0),
	(1520028461,1520009302,'frostcrypt',220,20.0,320.0,-62.625,0,600,0),
	(1520028462,1520009303,'frostcrypt',220,181.625,28.5,-62.5,0,600,0),
	(1520028463,1520009303,'frostcrypt',220,32.0,178.0,-53.625,0,600,0),
	(1520028464,1520009303,'frostcrypt',220,-179.375,95.0,-62.5,0,600,0),
	(1520028465,1520009303,'frostcrypt',220,220.5,84.0,-62.5,0,600,0),
	(1520028466,1520009303,'frostcrypt',220,-252.5,30.375,-62.5,0,600,0),
	(1520028467,1520009303,'frostcrypt',220,-180.625,188.5,-62.375,0,600,0),
	(1520028468,1520009303,'frostcrypt',220,267.0,89.875,-62.5,0,600,0),
	(1520028469,1520009303,'frostcrypt',220,-73.125,265.5,-63.375,0,600,0),
	(1520028470,1520009303,'frostcrypt',220,-250.0,150.5,-62.375,0,600,0),
	(1520028471,1520009303,'frostcrypt',220,-19.0,320.0,-62.625,0,600,0),
	(1520028472,1520009304,'frostcrypt',220,-186.25,31.25,-62.5,0,600,0),
	(1520028473,1520009304,'frostcrypt',220,-30.0,178.0,-53.625,0,600,0),
	(1520028474,1520009304,'frostcrypt',220,230.625,57.25,-52.0,0,600,0),
	(1520028475,1520009304,'frostcrypt',220,-73.0,221.0,-62.5,0,600,0),
	(1520028476,1520009304,'frostcrypt',220,219.5,219.625,-62.375,0,600,0),
	(1520028477,1520009304,'frostcrypt',220,-204.125,274.25,-61.625,0,600,0),
	(1520028478,1520009304,'frostcrypt',220,-232.375,275.125,-61.625,0,600,0),
	(1520028479,1520009304,'frostcrypt',220,-257.375,181.875,-62.0,0,600,0),
	(1520028480,1520009304,'frostcrypt',220,313.0,215.125,-62.375,0,600,0),
	(1520028481,1520009304,'frostcrypt',220,306.625,240.25,-62.375,0,600,0),
	(1520028482,1520009305,'frostcrypt',220,18.875,59.875,-32.5,0,600,0),
	(1520028483,1520009305,'frostcrypt',220,-15.625,62.75,-32.5,0,600,0),
	(1520028484,1520009305,'frostcrypt',220,-249.25,57.25,-62.5,0,600,0),
	(1520028485,1520009305,'frostcrypt',220,-73.0,266.0,-62.5,0,600,0),
	(1520028486,1520009305,'frostcrypt',220,-342.875,172.75,-62.375,0,600,0),
	(1520028487,1520009305,'frostcrypt',220,356.0,181.625,-52.625,0,600,0),
	(1520028488,1520009305,'frostcrypt',220,188.0,348.875,-63.25,0,600,0),
	(1520028489,1520009305,'frostcrypt',220,-305.75,239.375,-62.375,0,600,0),
	(1520028490,1520009305,'frostcrypt',220,314.25,264.25,-62.375,0,600,0),
	(1520028494,1520009305,'frostcrypt',220,376.125,182.125,-62.0,0,600,0),
	(1520028491,1520009306,'frostcrypt',220,-244.25,335.75,-62.375,0,600,0),
	(1520028492,1520009307,'frostcrypt',220,208.375,343.25,-62.375,0,600,0),
	(1520028493,1520009308,'frostcrypt',220,74.0,223.0,-62.5,0,600,0);
