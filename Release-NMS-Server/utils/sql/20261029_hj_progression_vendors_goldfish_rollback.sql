-- Rollback for 20261029_hj_progression_vendors_goldfish.sql (manifest entries 261-263).
SET NAMES utf8mb4;
START TRANSACTION;

-- Hero's Journey progression achievements + rewards (entries 261-262)
DELETE FROM `reward_sources` WHERE `source_type` = 1 AND `source_id` BETWEEN 9501000 AND 9501015;
DELETE FROM `reward_option_entries` WHERE `reward_set_id` BETWEEN 9508206 AND 9508221;
DELETE FROM `reward_options` WHERE `reward_set_id` BETWEEN 9508206 AND 9508221;
DELETE FROM `reward_sets` WHERE `reward_set_id` BETWEEN 9508206 AND 9508221;
DELETE FROM `rewards` WHERE `reward_id` BETWEEN 9540412 AND 9540443;
DELETE FROM `achievement_category_associations` WHERE `achievement_id` BETWEEN 9501000 AND 9501015;
DELETE FROM `achievement_criteria` WHERE `achievement_id` BETWEEN 9501000 AND 9501015;
DELETE FROM `achievement_components` WHERE `achievement_id` BETWEEN 9501000 AND 9501015;
DELETE FROM `achievements` WHERE `id` BETWEEN 9501000 AND 9501015;

-- Vendors + Goldfish Flakes loot (entry 263)
DELETE FROM `merchantlist` WHERE `merchantid` = 7010100;
UPDATE `npc_types` SET `merchant_id` = 0 WHERE `id` = 202431;
DELETE FROM `global_loot` WHERE `id` = 178901;
DELETE FROM `loottable_entries` WHERE `loottable_id` = 1520009314;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` = 1520009414;
DELETE FROM `lootdrop` WHERE `id` = 1520009414;
DELETE FROM `loottable` WHERE `id` = 1520009314;
DELETE FROM `loottable_entries` WHERE `loottable_id` = 10831 AND `lootdrop_id` = 1520008200;

COMMIT;

-- Expected post-conditions: zero rows in every band above; Bindral merchant_id back
-- to 0; Phinny's loottable link to 1520008200 removed.
