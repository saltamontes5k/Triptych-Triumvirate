-- ============================================================================
-- Deity Blessings -- Rank 2 "Deity Favors": quest items
-- Date: 2026-10-06
--
-- Flavor/quest items for the 16 rank-2 deity favor quests (Allakhazam 4827-
-- 4842, the 10th Anniversary Deity Favors, adapted). The per-god reward
-- items (Fireworks Focus of <god> 42962-42977 and Potion of Adventure II
-- 40994) already exist live and are granted by the plugin, not authored here.
--
-- Items 976210-976244 (the blessing chain block after the rank-1 idols
-- 976200-976205). All quest-flavor, no stats, NO DROP.
--
-- Idempotent: deletes the ids it owns before inserting.
-- ============================================================================

DELETE FROM `items` WHERE `id` BETWEEN 976210 AND 976249;

-- Template: Spiderling Silk (13099) -- plain stackable non-food item.
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=13099;

-- one insert helper per item: clone, rename, re-id
DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976210, `Name`='Eye of Valor', `lore`='Eye of Valor', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976211, `Name`='True Karanite Rod of Rainfall', `lore`='True Karanite Rod of Rainfall', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976212, `Name`='Flames of Solusek Ro', `lore`='Flames of Solusek Ro', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976213, `Name`='Quellious Wand of Tranquility', `lore`='Quellious'' Wand of Tranquility', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976214, `Name`='Innoruuks Needle of Hatred', `lore`='Innoruuk''s Needle of Hatred', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976215, `Name`='Bag of Mysterious Seeds', `lore`='Bag of Mysterious Seeds', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976216, `Name`='Minor Trinket of Rodcet Nife', `lore`='Minor Trinket of Rodcet Nife', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976217, `Name`='Brells Party Plans', `lore`='Brell''s Party Plans', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976218, `Name`='Book of Love Vol 1', `lore`='Book of Love Vol. 1', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976219, `Name`='Book of Love Vol 2', `lore`='Book of Love Vol. 2', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976220, `Name`='Book of Love Vol 3', `lore`='Book of Love Vol. 3', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976221, `Name`='Strawberry-Jumjum Pie', `lore`='Strawberry-Jumjum Pie', `loregroup`=0, `nodrop`=1, `stacksize`=20, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976222, `Name`='Wand of Dire Doubtfall', `lore`='Wand of Dire Doubtfall', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976223, `Name`='Wand of Hopecutting', `lore`='Wand of Hopecutting', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976224, `Name`='Wand of Fearful Unminding', `lore`='Wand of Fearful Unminding', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976225, `Name`='Virulent Olisteir Mold', `lore`='Virulent Olisteir Mold', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976226, `Name`='Bone-Eating Goo', `lore`='Bone-Eating Goo', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976227, `Name`='Augrins Cholerae', `lore`='Augrin''s Cholerae', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976228, `Name`='Fraechs Hidebloom', `lore`='Fraech''s Hidebloom', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976229, `Name`='Redrecths Scallops Plague', `lore`='Redrech''s Scallops Plague', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

-- Blessed fish (fishing-table drops; not edible, stackable)
DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976230, `Name`='Blessed Barren Flounder', `lore`='Blessed Barren Flounder', `loregroup`=0, `nodrop`=1, `stacksize`=4, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976231, `Name`='Blessed Gunthak Mackerel', `lore`='Blessed Gunthak Mackerel', `loregroup`=0, `nodrop`=1, `stacksize`=4, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976232, `Name`='Blessed Timorous Tuna', `lore`='Blessed Timorous Tuna', `loregroup`=0, `nodrop`=1, `stacksize`=4, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976233, `Name`='Blessed Iceclad Cutlassfish', `lore`='Blessed Iceclad Cutlassfish', `loregroup`=0, `nodrop`=1, `stacksize`=4, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976234, `Name`='Blessed Kunark Mullet', `lore`='Blessed Kunark Mullet', `loregroup`=0, `nodrop`=1, `stacksize`=4, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976235, `Name`='Blessed 15 lb. Saltwater Tuna', `lore`='Blessed 15 lb. Saltwater Tuna', `loregroup`=0, `nodrop`=1, `stacksize`=4, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976236, `Name`='Blessed Kedge Grunion', `lore`='Blessed Kedge Grunion', `loregroup`=0, `nodrop`=1, `stacksize`=4, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976237, `Name`='Blessed Ovate Jellyfish', `lore`='Blessed Ovate Jellyfish', `loregroup`=0, `nodrop`=1, `stacksize`=4, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

-- Brell's craft results (tradeskill outputs)
DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976240, `Name`='Silk Napkin', `lore`='Silk Napkin', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976241, `Name`='Unfired Plain Dining Plate', `lore`='Unfired Plain Dining Plate', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976242, `Name`='Plain Dining Plate', `lore`='Plain Dining Plate', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976243, `Name`='Kiola Nut Brew', `lore`='Kiola Nut Brew', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `t2`;
CREATE TEMPORARY TABLE `t2` AS SELECT * FROM `tmp_item`;
UPDATE `t2` SET `id`=976244, `Name`='Celebratory Seafood Medley', `lore`='Celebratory Seafood Medley', `loregroup`=0, `nodrop`=1, `stacksize`=1, `itemtype`=0 WHERE 1;
INSERT INTO `items` SELECT * FROM `t2`; DROP TEMPORARY TABLE `t2`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;

-- Kiola Nut (13340) sold at the Bazaar cleric vendor next to the rank-1 scroll
DELETE FROM `merchantlist` WHERE `merchantid`=202223 AND `item`=13340;
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (202223,250,13340);
