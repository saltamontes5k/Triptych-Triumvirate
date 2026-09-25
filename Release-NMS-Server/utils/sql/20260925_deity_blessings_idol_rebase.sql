-- ============================================================================
-- Deity Blessings -- rebase the custom idol chain into valid base IDs
-- Date: 2026-09-25
--
-- The Veeshan/Agnostic chain was authored at 9910018-9910023, which sits inside
-- the item-upgrade number space (tier = id / 1,000,000 = 9). Per the NMS
-- "Legendary & Tiered Item System" guide, Tier 0 bases must be 1-999,999 and
-- the base identity is id % 1,000,000. This rebases the chain to 976200-976205
-- and authors Enchanted (+1,000,000) / Legendary (+2,000,000) tiers for the two
-- Rank I hand-in idols so Veeshan and Agnostic behave like the other gods.
--
-- Mirrors manifest v75. Guarded by the caller; run only while item 976203 is
-- absent.
-- ============================================================================

-- ---- clone the old custom items onto valid bases ----
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910018;
UPDATE `tmp_item` SET `id`=976200, `Name`='Imbued Jacinth', `lore`='Imbued Jacinth-Veeshan', `icon`=767, `loregroup`=0 WHERE `id`=9910018;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910019;
UPDATE `tmp_item` SET `id`=976201, `Name`='Spell: Imbue Jacinth', `lore`='Spell: Imbue Jacinth', `loregroup`=0 WHERE `id`=9910019;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910020;
UPDATE `tmp_item` SET `id`=976202, `Name`='Unfired Idol of Veeshan', `lore`='Unfired Idol of Veeshan', `loregroup`=0 WHERE `id`=9910020;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910021;
UPDATE `tmp_item` SET `id`=976203, `Name`='Golden Idol of Veeshan', `lore`='Golden Idol of Veeshan', `loregroup`=0 WHERE `id`=9910021;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910022;
UPDATE `tmp_item` SET `id`=976204, `Name`='Unfired Idol', `lore`='Unfired Idol', `loregroup`=0 WHERE `id`=9910022;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9910023;
UPDATE `tmp_item` SET `id`=976205, `Name`='Fired Idol', `lore`='Fired Idol', `loregroup`=0 WHERE `id`=9910023;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- ---- Enchanted / Legendary tiers for the two Rank I hand-in idols ----
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=976203;
UPDATE `tmp_item` SET `id`=1976203, `Name`='Golden Idol of Veeshan (Enchanted)', `loregroup`=0 WHERE `id`=976203;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=976203;
UPDATE `tmp_item` SET `id`=2976203, `Name`='Golden Idol of Veeshan (Legendary)', `loregroup`=0 WHERE `id`=976203;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=976205;
UPDATE `tmp_item` SET `id`=1976205, `Name`='Fired Idol (Enchanted)', `loregroup`=0 WHERE `id`=976205;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=976205;
UPDATE `tmp_item` SET `id`=2976205, `Name`='Fired Idol (Legendary)', `loregroup`=0 WHERE `id`=976205;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- ---- repoint references from the retired ids ----
UPDATE `spells_new` SET `effect_base_value1`=976200 WHERE `id`=50017;
UPDATE `merchantlist` SET `item`=976201 WHERE `merchantid`=202223 AND `item`=9910019;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976200 WHERE `item_id`=9910018;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976202 WHERE `item_id`=9910020;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976203 WHERE `item_id`=9910021;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976204 WHERE `item_id`=9910022;
UPDATE `tradeskill_recipe_entries` SET `item_id`=976205 WHERE `item_id`=9910023;

UPDATE `task_activities` SET `item_id_list`='976203|1976203|2976203' WHERE `taskid`=700016;
UPDATE `task_activities` SET `item_id_list`='976205|1976205|2976205' WHERE `taskid`=700017;

-- ---- retire the mis-encoded items ----
DELETE FROM `items` WHERE `id` IN (9910018,9910019,9910020,9910021,9910022,9910023);
