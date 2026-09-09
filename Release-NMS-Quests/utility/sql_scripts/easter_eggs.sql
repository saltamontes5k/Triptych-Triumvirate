-- =====================================================================
--  Easter Egg drops (THJ heritage event)  --  Triptych Triumvirate
--  Egg (24131) drops via global_loot, incubates in the Power Source slot
--  (handled in C++ exp.cpp + global_player.pl EVENT_ITEM_CLICK_CAST_CLIENT),
--  then cracks for rewards on click.
--
--  ID block 178800 is verified FREE in the live peq DB across all tables
--  (global_loot / loottable / lootdrop / *_entries). The aug generator only
--  occupies 178700-178706. Do not collide with those.
--
--  Event switch:  global_loot.enabled (below) 0 = off, 1 = on
--  Reload:        #reload global loot   (or restart zone.exe)
-- =====================================================================

-- Loot table: single drop = the Easter Egg at chance 100 (~1% per kill).
INSERT IGNORE INTO `loottable`
(`id`, `name`, `mincash`, `maxcash`, `avgcoin`, `done`,
 `min_expansion`, `max_expansion`, `content_flags`, `content_flags_disabled`)
VALUES
(178800, 'GLB_Easter_Eggs', 0, 0, 0, 0, -1, -1, NULL, NULL);

INSERT IGNORE INTO `loottable_entries`
(`loottable_id`, `lootdrop_id`, `multiplier`, `droplimit`, `mindrop`, `probability`)
VALUES
(178800, 178800, 1, 1, 0, 100);

INSERT IGNORE INTO `lootdrop`
(`id`, `name`)
VALUES
(178800, 'GLB_Easter_Egg');

INSERT IGNORE INTO `lootdrop_entries`
(`lootdrop_id`, `item_id`, `item_charges`, `equip_item`, `chance`, `disabled_chance`,
 `trivial_min_level`, `trivial_max_level`, `multiplier`,
 `npc_min_level`, `npc_max_level`, `min_expansion`, `max_expansion`,
 `content_flags`, `content_flags_disabled`)
VALUES
(178800, 24131, 1, 0, 100.0, 0, 0, 0, 1, 1, 99, -1, -1, NULL, NULL);

-- Global loot mapping: any zone, any content, race/class agnostic.
-- hot_zone 0 = "any zone" (this build's GlobalLootManager treats 0 as match-all).
INSERT IGNORE INTO `global_loot`
(`id`, `description`, `loottable_id`, `enabled`, `min_level`, `max_level`,
 `rare`, `raid`, `race`, `class`, `bodytype`, `zone`,
 `hot_zone`, `min_expansion`, `max_expansion`, `content_flags`, `content_flags_disabled`)
VALUES
(178800, 'GLB-Easter-Eggs', 178800, 0, 1, 99, 0, 0, '', '', '', '', 0, -1, -1, '', '');
