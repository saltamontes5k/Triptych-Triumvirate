-- Prophecy of Ro - Phase 2 raid spawns (Sullon Zek, Suchun) + Shrine of Druzzil Ro
-- Idempotent (drops and recreates by fixed spawngroup ids; boss npc_types are
-- cloned with fresh auto-increment ids, so stale clones are cleaned by name first).
--
-- Sullon Zek, Mistress of Rage  -> ragea (Razorthorn tower interior)
-- Suchun, Blood Warden          -> takishruinsa (Root of Ro: Lair of Suchun)
-- Shrine of Druzzil Ro (369067) -> arcstone

-- --- clean stale clones/spawns -------------------------------------------------
DELETE se FROM `spawnentry` se JOIN `spawngroup` sg ON sg.id=se.spawngroupID WHERE sg.id IN (910001,910002,910003);
DELETE FROM `spawn2` WHERE `id` IN (910001,910002,910003);
DELETE FROM `spawngroup` WHERE `id` IN (910001,910002,910003);
DELETE FROM `npc_types` WHERE `name` IN ('Sullon_Zek,_Mistress_of_Rage','Suchun,_Blood_Warden_of_Solusek');

-- --- loottables ----------------------------------------------------------------
DELETE FROM `loottable_entries` WHERE `loottable_id` IN (91004,91005);
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` IN (910007,910008);
DELETE FROM `lootdrop` WHERE `id` IN (910007,910008);
DELETE FROM `loottable` WHERE `id` IN (91004,91005);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`) VALUES
 (91004,'por_sullon_zek',0,0,0,0,-1,-1),
 (91005,'por_suchun',0,0,0,0,-1,-1);

INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES
 (910007,'por_sullon_rewards',-1,-1),
 (910008,'por_suchun_rewards',-1,-1);

INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910007,39844,1,0,25,0,0,0,1,0,0,-1,-1),
 (910008,39957,1,0,25,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (91004,910007,1,0,0,100),
 (91005,910008,1,0,0,100);

-- --- Sullon Zek clone + spawn --------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS `por_npc_clone`;
CREATE TEMPORARY TABLE `por_npc_clone` AS SELECT * FROM `npc_types` WHERE `id` = 371007;
UPDATE `por_npc_clone`
   SET `id` = 0,
       `name` = 'Sullon_Zek,_Mistress_of_Rage',
       `level` = 85, `maxlevel` = 85, `hp` = 150000,
       `mindmg` = 900, `maxdmg` = 3200, `attack_delay` = 18,
       `loottable_id` = 91004;
INSERT INTO `npc_types` SELECT * FROM `por_npc_clone`;
SET @sullon_id = LAST_INSERT_ID();

-- --- Suchun clone + spawn ------------------------------------------------------
UPDATE `por_npc_clone`
   SET `id` = 0,
       `name` = 'Suchun,_Blood_Warden_of_Solusek',
       `level` = 85, `maxlevel` = 85, `hp` = 150000,
       `mindmg` = 900, `maxdmg` = 3200, `attack_delay` = 18,
       `loottable_id` = 91005;
INSERT INTO `npc_types` SELECT * FROM `por_npc_clone`;
SET @suchun_id = LAST_INSERT_ID();

-- --- spawn groups --------------------------------------------------------------
INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`)
VALUES
 (910001,'por_sullon_zek',0,0,0,0,0,0,45000,15000,0,100,0),
 (910002,'por_suchun',0,0,0,0,0,0,45000,15000,0,100,0),
 (910003,'por_shrine_druzzil_ro',0,0,0,0,0,0,45000,15000,0,100,0);

INSERT INTO `spawn2` (`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`)
VALUES
 (910001,910001,'ragea',0,314.0,-347.0,290.875,123.0,640,0,0,0,0,1,0,-1,-1),
 (910002,910002,'takishruinsa',0,18.0,-138.0,-29.0,0.0,640,0,0,0,0,1,0,-1,-1),
 (910003,910003,'arcstone',0,1630.0,-279.0,5.0,0.0,640,0,0,0,0,1,0,-1,-1);

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`)
VALUES
 (910001,@sullon_id,100,1,0,0,-1,-1),
 (910002,@suchun_id,100,1,0,0,-1,-1),
 (910003,369067,100,1,0,0,-1,-1);
