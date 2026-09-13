-- Prophecy of Ro - Phase 5 side quests (batch 2)
--   Task 3021  The Needy               (Borso, Relic)
--   Task 3022  A Shopkeeper's Delight  (Borso, Relic)
--   Task 3023  Tree Heaven             (Speaker Grayleaf -> Dryad of Tunare)
--   Scribe Luritem merchant stock (Arcstone port spells)
--   Dryad of Tunare spawn in the Plane of Growth
-- Idempotent.
--
-- Local item ids (note: these differ from the Allakhazam ids in the guides):
--   Piece of Parchment 13063, Quill 13051
--   Borso's Prized Ring 39708, Borso's Prized Earring 39707
--   Belt of the Rainmakers 39691, Crimson Cloak of Moonwaters 39692
--   Pouch of Treant Spirit Seeds 85645

-- --- Scribe Luritem merchant stock (ports) -------------------------------------
DELETE FROM `merchantlist` WHERE `merchantid`=369004;
INSERT INTO `merchantlist`
 (`merchantid`,`slot`,`item`,`faction_required`,`level_required`,`min_status`,`max_status`,`alt_currency_cost`,`classes_required`,`probability`,`bucket_name`,`bucket_value`,`bucket_comparison`,`min_expansion`,`max_expansion`)
VALUES
 (369004,1,78032,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Circle of Arcstone
 (369004,2,78033,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Arcstone Portal
 (369004,3,78034,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Ring of Arcstone
 (369004,4,78035,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Arcstone Gate
 (369004,5,78036,-100,0,0,255,0,65535,100,'','',0,-1,-1); -- Translocate: Arcstone

-- --- Tellen's Trinket Chest also drops from the Relic supply runners ------------
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910015;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910015;
DELETE FROM `lootdrop` WHERE `id`=910015;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910015,'por_tellen_trinket_chest',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES (910015,36123,1,0,40,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (91913,910015,1,0,0,100);

-- --- Dryad of Tunare -----------------------------------------------------------
DELETE se FROM `spawnentry` se JOIN `spawngroup` sg ON sg.id=se.spawngroupID WHERE sg.id=910005;
DELETE FROM `spawn2` WHERE `id`=910005;
DELETE FROM `spawngroup` WHERE `id`=910005;
DELETE FROM `npc_types` WHERE `name`='Dryad_of_Tunare';
DROP TEMPORARY TABLE IF EXISTS `por_dryad_clone`;
CREATE TEMPORARY TABLE `por_dryad_clone` AS SELECT * FROM `npc_types` WHERE `id`=127007;
UPDATE `por_dryad_clone` SET `id`=0, `name`='Dryad_of_Tunare', `level`=65, `maxlevel`=65, `hp`=10000, `loottable_id`=0;
INSERT INTO `npc_types` SELECT * FROM `por_dryad_clone`;
SET @dryad_id = LAST_INSERT_ID();
INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`)
VALUES (910005,'por_dryad_of_tunare',0,0,0,0,0,0,45000,15000,0,100,0);
INSERT INTO `spawn2` (`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`)
VALUES (910005,910005,'growthplane',0,1295.0,-1555.0,205.0,0.0,640,0,0,0,0,1,0,-1,-1);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`)
VALUES (910005,@dryad_id,100,1,0,0,-1,-1);

-- --- tasks ---------------------------------------------------------------------
DELETE FROM `task_activities` WHERE `taskid` IN (3021,3022,3023);
DELETE FROM `tasks` WHERE `id` IN (3021,3022,3023);

INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3021,2,0,0,'The Needy','Borso needs supplies. Recover Tellen''s Trinket Chest from the supply runners of Relic.','', '',0,0,0,0,0,65,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3022,2,0,0,'A Shopkeeper''s Delight','Borso wants Tellen''s supply crates intercepted. Recover a Supply Crate for Tellen.','', '',0,0,0,0,0,65,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3023,2,0,0,'Tree Heaven','Carry the Pouch of Treant Spirit Seeds to the Dryad of Tunare in the Plane of Growth.','', '',0,0,0,0,0,55,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3021,0,-1,1,1,'Borso',0,1,'Deliver Tellen''s Trinket Chest to Borso','370020','36123','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3022,0,-1,1,1,'Borso',0,1,'Deliver a Supply Crate for Tellen to Borso','370020','36124','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3023,0,-1,1,1,'Dryad of Tunare',0,1,'Deliver the Pouch of Treant Spirit Seeds to the Dryad of Tunare','','85645','',0, 0,0,0,0,0,0,'','','',-1,0,0);

UPDATE `task_activities` SET `npc_match_list`=@dryad_id WHERE `taskid`=3023 AND `activityid`=0;
