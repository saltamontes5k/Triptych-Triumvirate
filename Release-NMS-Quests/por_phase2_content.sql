-- Prophecy of Ro - Phase 2 content: instance quest-item drops + Samples combine
-- Idempotent. Apply to the live `peq` DB.
--
-- Adds the missing drops that make the Theater of Blood / Deathknell chains
-- completable (several were already wired; these are the gaps):
--   36142 Codex Artifice        -> Head_Librarian_Magus (371037, skylance)
--   36143 Prototype Egg         -> a_pulsing_eggsack (91936, skylance)
--   36144 Tarnished Chime       -> a_shelled_atrocity (91938, skylance)
--   36145 Incubated Egg         -> a_shelled_atrocity (91938, skylance)
--   36139 Broken SandStone Sect -> a_whipping_wind (92073, takishruinsa)
--   84156 Vial of Corrupted Blood -> Sverag trash (rage) via loottable 91002
-- Plus the "Samples of Corruption" combine:
--   Runed Silver Box (84157) + 10x Vial of Corrupted Blood (84156) -> Sealed Runed Silver Box (84158)

-- ===========================================================================
-- 36142 Codex Artifice on Head_Librarian_Magus (371037)
-- ===========================================================================
DELETE FROM `loottable_entries` WHERE `loottable_id` = 91001;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` = 910001;
DELETE FROM `lootdrop` WHERE `id` = 910001;
DELETE FROM `loottable` WHERE `id` = 91001;
INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`) VALUES (91001,'por_skylance_library',0,0,0,0,-1,-1);
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910001,'por_codex_artifice',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
 (910001,36142,1,0,100,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (91001,910001,1,0,0,100);
UPDATE `npc_types` SET `loottable_id` = 91001 WHERE `id` = 371037;

-- ===========================================================================
-- 36143 Prototype Egg on a_pulsing_eggsack (loottable 91936)
-- ===========================================================================
DELETE FROM `loottable_entries` WHERE `loottable_id` = 91936 AND `lootdrop_id` = 910002;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` = 910002;
DELETE FROM `lootdrop` WHERE `id` = 910002;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910002,'por_prototype_egg',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
 (910002,36143,1,0,100,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (91936,910002,1,0,0,100);

-- ===========================================================================
-- 36144 Tarnished Chime + 36145 Incubated Egg on a_shelled_atrocity (loottable 91938)
-- ===========================================================================
DELETE FROM `loottable_entries` WHERE `loottable_id` = 91938 AND `lootdrop_id` = 910003;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` = 910003;
DELETE FROM `lootdrop` WHERE `id` = 910003;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910003,'por_laboratory_rewards',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
 (910003,36145,1,0,100,0,0,0,1,0,0,-1,-1),
 (910003,36144,1,0,100,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (91938,910003,1,0,0,100);

-- ===========================================================================
-- 36139 Broken Section of a SandStone Tablet on a_whipping_wind (loottable 92073)
-- ===========================================================================
DELETE FROM `loottable_entries` WHERE `loottable_id` = 92073 AND `lootdrop_id` = 910004;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` = 910004;
DELETE FROM `lootdrop` WHERE `id` = 910004;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910004,'por_tablet_final',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
 (910004,36139,1,0,100,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92073,910004,1,0,0,100);

-- ===========================================================================
-- 84156 Vial of Corrupted Blood on Sverag (rage) trash
-- ===========================================================================
DELETE FROM `loottable_entries` WHERE `loottable_id` = 91002;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` = 910005;
DELETE FROM `lootdrop` WHERE `id` = 910005;
DELETE FROM `loottable` WHERE `id` = 91002;
INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`) VALUES (91002,'por_sverag_trash',0,0,0,0,-1,-1);
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910005,'por_corrupted_blood',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
 (910005,84156,1,0,50,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (91002,910005,1,0,0,100);
UPDATE `npc_types` SET `loottable_id` = 91002 WHERE `id` BETWEEN 375001 AND 375065 AND `loottable_id` = 0;

-- ===========================================================================
-- Samples of Corruption combine: Runed Silver Box + 10 Vial of Corrupted Blood
-- ===========================================================================
DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` = 991001;
DELETE FROM `tradeskill_recipe` WHERE `id` = 991001;
INSERT INTO `tradeskill_recipe`
 (`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,`notes`,`must_learn`,`learned_by_item_id`,`quest`,`enabled`,`min_expansion`,`max_expansion`)
VALUES
 (991001,'Sealed Runed Silver Box',75,0,0,1,0,'Prophecy of Ro: Samples of Corruption',0,0,1,1,-1,-1);
INSERT INTO `tradeskill_recipe_entries`
 (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
 (991001,84157,0,0,0,0,1),
 (991001,84156,0,0,10,0,0),
 (991001,84158,1,0,0,0,0);
