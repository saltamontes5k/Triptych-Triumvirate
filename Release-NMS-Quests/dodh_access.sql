-- Depths of Darkhollow - Dreadspire / Demi-Plane of Blood access (ROUGH FRAMEWORK)
--
-- The five-task access chain from Bonzz's "Dreadspire, The Demi-Plane of Blood"
-- guide (Eye Bound line):
--   505745  Frustrated Functionary   (Melion Pell, Dreadspire)   -> Dreadspire Library key
--   505746  Check Out a Library Book (Treddlehoop, Corathus)     -> Polished Mystical Glass Shard
--   505747  Eyes Wide Open           (Treddlehoop, Corathus)     -> Blurry Lens
--   505748  Misty for You            (Coldwind Blackfoot, Nektulos) -> Lens of Bound Eyes
--   505749  Eye Bound                (Coldwind Blackfoot, Nektulos) -> Lens of Eye-Glass
--   final   Monocle of Blood         (Treddlehoop: Lens of Eye-Glass + device)
--
-- This is a framework only: task givers, turn-ins, the Misty Blackfoot spawn and
-- the three missing key drops are wired. The Demi-Plane zone curse / blockers and
-- the Curse of Blood raid loot-rights are NOT part of this file.
--
-- Local item ids (all stock PEQ):
--   88005 Treddlehoop's Wonderful Monoculor Seeing Device  88006 Shard of Mystical Glass
--   88007 Study of Mystical Vision                          88009 Coral-set Golden Necklace
--   88013 Monocle of Blood                                  88016 Funeral Donation Pouch
--   88017 Crypt Blood Slurry                                88018 Bloody Cloth Eye Patch
--   88019 Polished Mystical Glass Shard                     88020 Blurry Lens
--   88021 Lens of Bound Eyes                                88022 Moon-shaped Diamond Pendant
--   88034 Lens of Eye-Glass                                 88035 Vule's Eye
-- Idempotent.

-- ===========================================================================
-- Tasks 505745-505749
-- ===========================================================================
DELETE FROM `task_activities` WHERE `taskid` BETWEEN 505745 AND 505749;
DELETE FROM `tasks` WHERE `id` BETWEEN 505745 AND 505749;

INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (505745,2,0,0,'Frustrated Functionary','Melion Pell, Minor Functionary, wants eight grayfang bats slain and a Coral-set Golden Necklace procured from the castle orcs.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (505746,2,0,0,'Check Out a Library Book','Treddlehoop needs the Study of Mystical Vision, held by the Official Cataloguer in Dreadspire Keep.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (505747,2,0,0,'Eyes Wide Open','Recover the Bloody Cloth Eye Patch from Gronk One-Eye and distil the crypt blood for Treddlehoop.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (505748,2,0,0,'Misty for You','Slay Misty Blackfoot in the lower spire and return her Moon-shaped Diamond Pendant to Coldwind Blackfoot.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (505749,2,0,0,'Eye Bound','Slay Master Vule the Silent Tear and return his eye to Coldwind Blackfoot.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 -- 505745 Frustrated Functionary
 (505745,0,-1,1,2,'',0,8,'Slay grayfang bats','351013|351014','','',0, 0,0,0,0,0,0,'','','dreadspire',-1,0,0),
 (505745,1,-1,2,1,'Melion Pell, Minor Functionary',0,1,'Deliver the Coral-set Golden Necklace','351107','88009','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 505746 Check Out a Library Book
 (505746,0,-1,1,1,'Treddlehoop',0,1,'Deliver the Study of Mystical Vision','365284','88007','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 505747 Eyes Wide Open
 (505747,0,-1,1,3,'',0,1,'Recover the Bloody Cloth Eye Patch','','88018','',0, 0,0,0,0,0,0,'','','dreadspire',-1,0,0),
 (505747,1,-1,2,1,'Treddlehoop',0,1,'Deliver the Bloody Cloth Eye Patch','365284','88018','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 505748 Misty for You
 (505748,0,-1,1,2,'',0,1,'Defeat Misty Blackfoot','','','',0, 0,0,0,0,0,0,'','','dreadspire',-1,0,0),
 (505748,1,-1,2,1,'Coldwind Blackfoot',0,1,'Deliver the Moon-shaped Diamond Pendant','25414','88022','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 505749 Eye Bound
 (505749,0,-1,1,2,'',0,1,'Defeat Master Vule the Silent Tear','351034','','',0, 0,0,0,0,0,0,'','','dreadspire',-1,0,0),
 (505749,1,-1,2,1,'Coldwind Blackfoot',0,1,'Deliver Vule''s Eye','25414','88035','',0, 0,0,0,0,0,0,'','','',-1,0,0);

-- ===========================================================================
-- Misty Blackfoot: clone of Coldwind (25414), spawned in the lower spire
-- ===========================================================================
DELETE se FROM `spawnentry` se JOIN `spawngroup` sg ON sg.id=se.spawngroupID WHERE sg.id=910200;
DELETE FROM `spawn2` WHERE `id`=910200;
DELETE FROM `spawngroup` WHERE `id`=910200;
DELETE FROM `npc_types` WHERE `name`='#Misty_Blackfoot';

DELETE FROM `loottable_entries` WHERE `loottable_id`=910200;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910200;
DELETE FROM `lootdrop` WHERE `id`=910200;
DELETE FROM `loottable` WHERE `id`=910200;

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`)
VALUES (910200,'dodh_misty_blackfoot',0,0,0,0,-1,-1);
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`)
VALUES (910200,'dodh_moon_diamond_pendant',-1,-1);
INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910200,88022,1,0,100,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
VALUES (910200,910200,1,0,0,100);

DROP TEMPORARY TABLE IF EXISTS `dodh_clone`;
CREATE TEMPORARY TABLE `dodh_clone` AS SELECT * FROM `npc_types` WHERE `id`=25414;
UPDATE `dodh_clone`
   SET `id`=0,
       `name`='#Misty_Blackfoot',
       `level`=73, `maxlevel`=73, `hp`=150000,
       `mindmg`=400, `maxdmg`=1600, `attack_delay`=20,
       `loottable_id`=910200;
INSERT INTO `npc_types` SELECT * FROM `dodh_clone`;
SET @misty_id = LAST_INSERT_ID();

INSERT INTO `spawngroup` (`id`,`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`)
VALUES (910200,'dodh_misty_blackfoot',0,0,0,0,0,0,45000,15000,0,100,0);
INSERT INTO `spawn2` (`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,`pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`)
VALUES (910200,910200,'dreadspire',0, 0.0,300.0,-1000.0,0.0,640,0,0,0,0,1,0,-1,-1);
INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`)
VALUES (910200,@misty_id,100,1,0,0,-1,-1);

UPDATE `task_activities` SET `npc_match_list`=@misty_id WHERE `taskid`=505748 AND `activityid`=0;

-- ===========================================================================
-- Missing key drops
-- ===========================================================================
-- Shard of Mystical Glass (88006) on a_shadowmane_researcher (loottable 91464)
DELETE FROM `loottable_entries` WHERE `loottable_id`=91464 AND `lootdrop_id`=910201;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910201;
DELETE FROM `lootdrop` WHERE `id`=910201;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`)
VALUES (910201,'dodh_shard_mystical_glass',-1,-1);
INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910201,88006,1,0,50,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
VALUES (91464,910201,1,0,0,100);

-- Bloody Cloth Eye Patch (88018) on #Gronk_One-Eye (loottable 91489)
DELETE FROM `loottable_entries` WHERE `loottable_id`=91489 AND `lootdrop_id`=910202;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910202;
DELETE FROM `lootdrop` WHERE `id`=910202;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`)
VALUES (910202,'dodh_bloody_cloth_eyepatch',-1,-1);
INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910202,88018,1,0,100,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
VALUES (91489,910202,1,0,0,100);
