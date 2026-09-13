-- Prophecy of Ro - Phase 2: Ruins of Takish-Hiz arc (Burning Prince)
-- Creates Prince Tak`Salir and rewrites task 3015/3016 objectives to the real
-- instanced Takish-Hiz kills, then leaves the class reward to Tak`Valnakor.
-- Idempotent.

-- --- clean ---------------------------------------------------------------------
DELETE se FROM `spawnentry` se JOIN `spawngroup` sg ON sg.id=se.spawngroupID WHERE sg.id=910004;
DELETE FROM `spawn2` WHERE `id`=910004;
DELETE FROM `spawngroup` WHERE `id`=910004;
DELETE FROM `npc_types` WHERE `name`='#Prince_TakSalir';

-- --- Prince loot ---------------------------------------------------------------
DELETE FROM `loottable_entries` WHERE `loottable_id`=91006;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910009;
DELETE FROM `lootdrop` WHERE `id`=910009;
DELETE FROM `loottable` WHERE `id`=91006;
INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`) VALUES (91006,'por_prince_taksalir',0,0,0,0,-1,-1);
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910009,'por_prince_rewards',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES
 (910009,39844,1,0,20,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (91006,910009,1,0,0,100);

-- --- Prince clone + spawn ------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS `por_npc_clone2`;
CREATE TEMPORARY TABLE `por_npc_clone2` AS SELECT * FROM `npc_types` WHERE `id`=376093;
UPDATE `por_npc_clone2`
   SET `id`=0,
       `name`='#Prince_TakSalir',
       `level`=75, `maxlevel`=75, `hp`=30000,
       `mindmg`=500, `maxdmg`=1800, `attack_delay`=20,
       `loottable_id`=91006;
INSERT INTO `npc_types` SELECT * FROM `por_npc_clone2`;
SET @prince_id = LAST_INSERT_ID();

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`)
VALUES (910004,'por_prince_taksalir',0,0,0,0,0,0,45000,15000,0,100,0);
INSERT INTO `spawn2` (`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`)
VALUES (910004,910004,'takishruins',0,-983.0,269.0,62.0,0.0,640,0,0,0,0,1,0,-1,-1);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`)
VALUES (910004,@prince_id,100,1,0,0,-1,-1);

-- --- rewrite task 3015 objectives (Burning Prince) -----------------------------
DELETE FROM `task_activities` WHERE `taskid`=3015;
INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3015,0,-1,1,5,'',0,1,'Enter the Ruins of Takish-Hiz','','','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3015,1,-1,2,2,'',0,5,'Defeat the Sand Elf Priests','376018','','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3015,2,-1,3,2,'',0,1,'Defeat Prince Tak`Salir','','','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3015,3,-1,4,4,'Queen Tak`Yaliz',0,1,'Return to Queen Tak`Yaliz','392088','','',0, 0,0,0,0,0,0,'','','',-1,0,0);

UPDATE `task_activities` SET `npc_match_list` = @prince_id WHERE `taskid`=3015 AND `activityid`=2;

-- --- rewrite task 3016 objectives (Message from the Past) ----------------------
DELETE FROM `task_activities` WHERE `taskid`=3016;
INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3016,0,-1,1,5,'',0,1,'Enter the Ruins of Takish-Hiz','','','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3016,1,-1,2,2,'',0,1,'Defeat the priest who guards the Signet','376018','','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3016,2,-1,3,4,'Queen Tak`Yaliz',0,1,'Return to Queen Tak`Yaliz','392088','','',0, 0,0,0,0,0,0,'','','',-1,0,0);
