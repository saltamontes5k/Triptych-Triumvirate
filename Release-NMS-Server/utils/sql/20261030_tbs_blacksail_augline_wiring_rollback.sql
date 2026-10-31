-- ============================================================================
-- Rollback of 20261030_tbs_blacksail_augline_wiring.sql (v287).
--
-- Restores sections 1-4. Section 5 (jardelshook leftover spawn cleanup) is
-- intentionally NOT reversed -- it is a permanent cleanup of unreachable
-- stock spawns; to restore them, re-import the jardelshook spawn2/spawnentry/
-- spawngroup rows from the release-peq.zip snapshot.
--
-- Safe on an already-rolled-back database: every UPDATE is absolute and the
-- DELETEs are no-ops when nothing matches.
-- ============================================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- 1. Doubloon funding off.
UPDATE `tasks` SET `reward_point_type` = 0, `reward_points` = 0 WHERE `id` IN (
    625010, 625011, 625012, 625013, 625014, 625015, 625016, 625017, 625018,
    625021, 625022, 625023, 625026, 625027, 625028, 625031, 625032, 625033,
    625036, 625037, 625038, 625041, 625042, 625043, 625046, 625047, 625048
);

-- 2. Faction wiring off.
UPDATE `npc_types` SET `npc_faction_id` = 0 WHERE `id` IN (
    422004, 422009, 422012, 422019, 423079, 423091, 423105, 423107, 423122,
    423124, 423144, 423146, 423148, 423152, 423900
);
DELETE FROM `npc_faction_entries` WHERE `npc_faction_id` = 1520000063 AND `faction_id` = 1169 AND `value` = -50;
UPDATE `merchantlist` SET `faction_required` = -1100 WHERE `merchantid` = 423124 AND `item` = 79918;

-- 3a. Siren Hair loot off.
DELETE FROM `loottable_entries` WHERE `lootdrop_id` BETWEEN 1520009420 AND 1520009424;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 1520009420 AND 1520009424;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 1520009420 AND 1520009424;

-- 3b. Fire Totem Piece chances back to stock.
UPDATE `lootdrop_entries` SET `chance` = 0.015 WHERE `lootdrop_id` = 112698 AND `item_id` = 54748;
UPDATE `lootdrop_entries` SET `chance` = 0.026 WHERE `lootdrop_id` = 112787 AND `item_id` = 54748;

-- 3c. Spawn supply adds off.
DELETE FROM `spawn2` WHERE `id` BETWEEN 1520028400 AND 1520028425;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 1900000100 AND 1900000125;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 1900000100 AND 1900000125;

-- 4. Recipe cleanup off.
UPDATE `tradeskill_recipe` SET `enabled` = 1 WHERE `id` IN (991100, 991103, 991104, 991105, 991106);
UPDATE `tradeskill_recipe` SET `tradeskill` = 0 WHERE `id` BETWEEN 992000 AND 992006;

COMMIT;
