-- Prophecy of Ro - Phase 2 raid content
-- Daosheen the Firstborn (npc 371007, skylance): loot + death hook for the
-- Deathknell access chain. The Black Orb of Daosheen (85622) feeds the
-- "Black Orb of the Scrykin" quest (3423).
-- Idempotent.

DELETE FROM `loottable_entries` WHERE `loottable_id` = 91003;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` = 910006;
DELETE FROM `lootdrop` WHERE `id` = 910006;
DELETE FROM `loottable` WHERE `id` = 91003;

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`)
VALUES (91003,'por_daosheen',0,0,0,0,-1,-1);

INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`)
VALUES (910006,'por_daosheen_rewards',-1,-1);

INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910006,85622,1,0,100,0,0,0,1,0,0,-1,-1),  -- Black Orb of Daosheen the First
 (910006,39844,1,0,15,0,0,0,1,0,0,-1,-1);   -- Breeches of Prismatic Power (sample ToB-style drop)

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
VALUES (91003,910006,1,0,0,100);

UPDATE `npc_types` SET `loottable_id` = 91003 WHERE `id` = 371007;
