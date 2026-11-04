-- Vex Thal Lucid Shard drop-rate floor (2026-11-04). Live feedback: the Scepter of
-- Shadows grind is too slow. All 10 Lucid Shards (22185-22194) are plain
-- lootdrop_entries.chance values; before this change the 100 shard entries ranged
-- 1.2%-100% (most 5-35%). Raise the floor to 50%: only rows BELOW 50 move, entries
-- already at/above 50 (incl. several 60/100 rows) are untouched. Pure rate tuning -
-- no items, no scripts. Twin of manifest entry 332.
SET NAMES utf8mb4;
UPDATE `lootdrop_entries`
SET `chance` = 50
WHERE `item_id` BETWEEN 22185 AND 22194
  AND `chance` < 50;
