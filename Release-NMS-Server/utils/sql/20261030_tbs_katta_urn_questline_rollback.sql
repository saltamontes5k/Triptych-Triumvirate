-- ============================================================================
-- Rollback of 20261030_tbs_katta_urn_questline.sql (v290).
--
-- Removes the 22 urn tasks, the combine recipes, the loot rows, the ground
-- spawns, the two new NPCs and their spawns. The 15 quest items (9910018-
-- 9910032) are deleted too; the pre-existing urn props (79919, 79954-79980,
-- spell 11571) are NOT touched. The cipher-chance bump is reverted.
-- Safe on an already-rolled-back database (all statements are no-ops).
-- ============================================================================

SET NAMES utf8mb4;
START TRANSACTION;

DELETE FROM `task_activities` WHERE `taskid` BETWEEN 620112 AND 620133;
DELETE FROM `tasks` WHERE `id` BETWEEN 620112 AND 620133;

DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` BETWEEN 992016 AND 992020;
DELETE FROM `tradeskill_recipe` WHERE `id` BETWEEN 992016 AND 992020;

DELETE FROM `ground_spawns` WHERE `zoneid` = 416 AND `name` LIKE 'urn_book_kat%';
DELETE FROM `ground_spawns` WHERE `zoneid` = 419 AND `name` LIKE 'urn_book_zhi%';

DELETE FROM `lootdrop_entries` WHERE `item_id` IN (9910019, 9910020, 9910021, 9910022, 9910023, 9910024, 9910025, 9910026, 9910027, 9910028, 9910029, 9910030, 9910031, 9910032);
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` IN (1520009425, 1520009426);
DELETE FROM `loottable_entries` WHERE `lootdrop_id` IN (1520009425, 1520009426);
DELETE FROM `lootdrop` WHERE `id` IN (1520009425, 1520009426);
UPDATE `lootdrop_entries` SET `chance` = 1.2 WHERE `item_id` = 33889 AND `chance` = 20;
UPDATE `lootdrop_entries` SET `chance` = 0.9 WHERE `item_id` = 33888 AND `chance` = 20;

DELETE FROM `spawn2` WHERE `spawngroupID` IN (1900000126, 1900000127, 1900000128, 1900000129, 1900000130, 1900000131, 1900000132, 1900000133);
DELETE FROM `spawnentry` WHERE `spawngroupID` IN (1900000126, 1900000127, 1900000128, 1900000129, 1900000130, 1900000131, 1900000132, 1900000133);
DELETE FROM `spawngroup` WHERE `id` IN (1900000126, 1900000127, 1900000128, 1900000129, 1900000130, 1900000131, 1900000132, 1900000133);
DELETE FROM `npc_types` WHERE `id` IN (1520002001, 1520002002);

DELETE FROM `items` WHERE `id` BETWEEN 9910018 AND 9910032;

COMMIT;
