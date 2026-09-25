-- ============================================================================
-- Neriak rogue newbie armor + classic low-level quest content repair
-- Date: 2026-09-23
--
-- Fixes:
--   1. Othmir Fur Cloak / Moccasins combines accept any sewing kit or loom
--      (bag type 16), mirroring the Othmir Fur Cap recipe (2965).
--   2. The Nektulos "a_zombie" (25432) drops a Lock of Zombie Hair (19583),
--      required by the Neriak rogue weapon quest.
--   3. Classic low-level spawns (ash/forest drakelings, orc arsonist, zombie)
--      are no longer era-gated (min_expansion = -1).
--
-- Idempotent: guarded INSERTs; the UPDATE is naturally repeatable.
-- ============================================================================

-- (1) Allow a standard sewing kit or loom (bag type 16) for these combines.
--     tradeskills.cpp maps a bag's BagType to c_type and matches it against
--     tradeskill_recipe_entries.item_id where iscontainer = 1.
INSERT INTO `tradeskill_recipe_entries`
    (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
SELECT 2966, 16, 0, 0, 0, 0, 1 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `tradeskill_recipe_entries`
    WHERE `recipe_id` = 2966 AND `item_id` = 16 AND `iscontainer` = 1
);

INSERT INTO `tradeskill_recipe_entries`
    (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
SELECT 2967, 16, 0, 0, 0, 0, 1 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `tradeskill_recipe_entries`
    WHERE `recipe_id` = 2967 AND `item_id` = 16 AND `iscontainer` = 1
);

-- (2) Lock of Zombie Hair on the Nektulos zombie (loottable 102604).
--     Reuses lootdrop 12058, which is the single-item 19583 drop @ 35%.
INSERT INTO `loottable_entries`
    (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
SELECT 102604, 12058, 1, 1, 0, 100 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `loottable_entries`
    WHERE `loottable_id` = 102604 AND `lootdrop_id` = 12058
);

-- (3) Remove expansion gating from the classic low-level spawns:
--     5812  = gfaydark orc arsonist
--     59485 = nektulos a_zombie
--     61434 = nektulos Nek3_newbie_fields_low (ash drakelings)
--     61435 = nektulos Nek3_newbie_fields_med (ash drakelings)
UPDATE `spawn2` SET `min_expansion` = -1
WHERE `spawngroupID` IN (5812, 59485, 61434, 61435);
