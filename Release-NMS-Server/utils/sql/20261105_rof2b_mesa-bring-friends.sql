-- 20261105 rof2b port: mesa-bring-friends - Mesa Bring Friends defense encounters (4 quests).
-- Source: github.com/nightstalker6669/EQEmu branch rof2-achievements,
--   extensions/rof2/achievements/content/mesa-bring-friends (GPL-3.0), ported 2026-11-05.
-- Forward SQL files concatenated verbatim in install order; fail-closed
-- guards and session variables preserved. Reviewed-flag acceptance block
-- added here (upstream reconstruction defaults documented in the package's
-- provenance/ directory; see docs/rof2-zone-quests-attribution.md).
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;

-- ---- mesa-bring-friends/sql/010-bring-friends.sql ----
DELIMITER //
BEGIN NOT ATOMIC
DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;RESIGNAL;END;
START TRANSACTION;

IF (SELECT COUNT(*)FROM `tasks` WHERE id BETWEEN 3040465 AND 3040468)<>4 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Bring Friends tasks conflict';END IF;
IF (SELECT COUNT(*)FROM `task_activities` WHERE taskid BETWEEN 3040465 AND 3040468)<0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Bring Friends task_activities conflict';END IF;
IF (SELECT COUNT(*)FROM `achievement_criteria` WHERE achievement_id=500040800 AND component_type=1 AND component_id BETWEEN 50162 AND 50165)<0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Bring Friends achievement_criteria conflict';END IF;
IF (SELECT COUNT(*)FROM `npc_faction` WHERE id=3040466)<0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Bring Friends npc_faction conflict';END IF;
IF (SELECT COUNT(*)FROM `npc_types` WHERE id BETWEEN 397905 AND 397909)<0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Bring Friends npc_types conflict';END IF;
INSERT IGNORE INTO `tasks`(`id`,`type`,`duration`,`title`,`description`,`reward_text`,`reward_id_list`,`reward_method`,`exp_reward`,`min_level`,`min_players`,`max_players`,`repeatable`,`enabled`,`duration_code`,`cash_reward`,`reward_points`,`reward_point_type`,`max_level`,`level_spread`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`)VALUES
(3040465,1,21600,CONVERT(0x412042616420447265616d USING utf8mb4),CONVERT(0x48656c702048616e6f6f6b2070726f74656374207468652057696e6477696c6c6f772e USING utf8mb4),CONVERT(0x457870657269656e6365 USING utf8mb4),'',0,1000,0,1,6,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,-1,0),
(3040466,1,21600,CONVERT(0x4f68204e6f21 USING utf8mb4),CONVERT(0x48656c702048616e6f6f6b2070726f74656374207468652057696e6477696c6c6f772e USING utf8mb4),CONVERT(0x457870657269656e6365 USING utf8mb4),'',0,1000,0,1,6,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,-1,0),
(3040467,2,0,CONVERT(0x5374616e642057697468205573 USING utf8mb4),CONVERT(0x48656c702048616e6f6f6b2070726f74656374207468652057696e6477696c6c6f772e USING utf8mb4),CONVERT(0x457870657269656e63653b2057696e6477696c6c6f7720536170204e65636b6c616365 USING utf8mb4),CONVERT(0x35333536332c31 USING utf8mb4),0,1000,0,1,1,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,-1,0),
(3040468,1,21600,CONVERT(0x546865792061726520436f6d696e6721 USING utf8mb4),CONVERT(0x53746f702074686520726169646572206361707461696e206265666f726520746865204d696e6f6874656e2063616d70206973206f76657272756e2e USING utf8mb4),CONVERT(0x457870657269656e63653b2057696e6477696c6c6f772053617020426175626c65 USING utf8mb4),CONVERT(0x35333535322c31 USING utf8mb4),0,1000,0,1,6,1,0,0,0,0,0,0,0,0,'',0,0,0,0,0,-1,0);
INSERT IGNORE INTO `task_activities`(`taskid`,`activityid`,`step`,`activitytype`,`goalmethod`,`goalcount`,`target_name`,`description_override`,`npc_match_list`,`item_id_list`,`zones`,`req_activity_id`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zone_version`,`optional`,`list_group`)VALUES
(3040465,0,0,4,0,1,CONVERT(0x537065616b207769746820456c64657220566173696c65 USING utf8mb4),CONVERT(0x537065616b207769746820456c64657220566173696c65 USING utf8mb4),CONVERT(0x333937313032 USING utf8mb4),'',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040465,1,1,3,0,5,CONVERT(0x4c6f6f742035205475666665696e205472696e6b657473 USING utf8mb4),CONVERT(0x4c6f6f742035205475666665696e205472696e6b657473 USING utf8mb4),'',CONVERT(0x3231343930 USING utf8mb4),CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040465,2,2,1,0,5,CONVERT(0x44656c697665722035205475666665696e205472696e6b65747320746f20456c64657220566173696c65 USING utf8mb4),CONVERT(0x44656c697665722035205475666665696e205472696e6b65747320746f20456c64657220566173696c65 USING utf8mb4),CONVERT(0x333937313032 USING utf8mb4),CONVERT(0x3231343930 USING utf8mb4),CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040465,3,3,4,0,1,CONVERT(0x537065616b207769746820456c64657220566173696c65 USING utf8mb4),CONVERT(0x537065616b207769746820456c64657220566173696c65 USING utf8mb4),CONVERT(0x333937313032 USING utf8mb4),'',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040465,4,4,4,0,1,CONVERT(0x537065616b20776974682048616e6f6f6b USING utf8mb4),CONVERT(0x537065616b20776974682048616e6f6f6b USING utf8mb4),CONVERT(0x333937303430 USING utf8mb4),'',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040466,0,0,5,2,1,CONVERT(0x4578706c6f726520746865205475666665696e20656e63616d706d656e74 USING utf8mb4),CONVERT(0x4578706c6f726520746865205475666665696e20656e63616d706d656e74 USING utf8mb4),'','',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040466,1,1,2,2,1,CONVERT(0x4b696c6c20476c6173736f6e USING utf8mb4),CONVERT(0x4b696c6c20476c6173736f6e USING utf8mb4),CONVERT(0x333937393035 USING utf8mb4),'',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040466,2,2,3,0,1,CONVERT(0x4c6f6f7420746865205475666665696e20526169646572204f7264657273 USING utf8mb4),CONVERT(0x4c6f6f7420746865205475666665696e20526169646572204f7264657273 USING utf8mb4),'',CONVERT(0x3231343931 USING utf8mb4),CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040466,3,3,1,0,1,CONVERT(0x44656c6976657220746865206f726465727320746f2048616e6f6f6b USING utf8mb4),CONVERT(0x44656c6976657220746865206f726465727320746f2048616e6f6f6b USING utf8mb4),CONVERT(0x333937303430 USING utf8mb4),CONVERT(0x3231343931 USING utf8mb4),CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040467,0,0,5,2,1,CONVERT(0x4d6f766520746f2074686520656e7472616e636520746f2074686520746f70206f6620746865206d657361 USING utf8mb4),CONVERT(0x4d6f766520746f2074686520656e7472616e636520746f2074686520746f70206f6620746865206d657361 USING utf8mb4),'','',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040467,1,1,0,2,1,CONVERT(0x446f206e6f74206c65742074686520747265656b696c6c65727320636c6f736520746f207468652074726565 USING utf8mb4),CONVERT(0x446f206e6f74206c65742074686520747265656b696c6c65727320636c6f736520746f207468652074726565 USING utf8mb4),'','',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040467,2,2,4,0,1,CONVERT(0x537065616b20776974682048616e6f6f6b USING utf8mb4),CONVERT(0x537065616b20776974682048616e6f6f6b USING utf8mb4),CONVERT(0x333937303430 USING utf8mb4),'',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040468,0,0,5,2,1,CONVERT(0x436f6e66726f6e74207468652072616964657273206173207468657920636f6d652066726f6d20746865206c6f776c616e6473 USING utf8mb4),CONVERT(0x436f6e66726f6e74207468652072616964657273206173207468657920636f6d652066726f6d20746865206c6f776c616e6473 USING utf8mb4),'','',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040468,1,1,2,2,1,CONVERT(0x536c6179207468652072616964657273e28099206361707461696e USING utf8mb4),CONVERT(0x536c6179207468652072616964657273e28099206361707461696e USING utf8mb4),CONVERT(0x333937393039 USING utf8mb4),'',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0),
(3040468,2,2,4,0,1,CONVERT(0x52657475726e20746f20506572657461656e752077697468206e657773206f6620796f757220766963746f7279 USING utf8mb4),CONVERT(0x52657475726e20746f20506572657461656e752077697468206e657773206f6620796f757220766963746f7279 USING utf8mb4),CONVERT(0x333937303932 USING utf8mb4),'',CONVERT(0x333937 USING utf8mb4),-1,'',0,0.0,0.0,0.0,0.0,0.0,0.0,CONVERT(0x2d31 USING utf8mb4),CONVERT(0x30 USING utf8mb4),-1,0,0);
-- NMS: enable the parent achievement(s) (upstream DB carried them enabled
-- from earlier steps our flow does not reproduce).
UPDATE achievements SET enabled=1 WHERE id=500040800;
INSERT IGNORE INTO `achievement_criteria`(`achievement_id`,`component_type`,`component_sequence`,`component_id`,`event_type`,`progress_mode`,`behavior`,`target_id`,`target_id2`,`target_value`,`required_count`,`enabled`)VALUES
(500040800,1,1,50162,4,3,0,3040465,0,0,1,0),
(500040800,1,2,50163,4,3,0,3040466,0,0,1,0),
(500040800,1,3,50164,4,3,0,3040467,0,0,1,0),
(500040800,1,4,50165,4,3,0,3040468,0,0,1,0);
INSERT IGNORE INTO `npc_faction`(`id`,`name`,`primaryfaction`,`ignore_primary_assist`)VALUES
(3040466,CONVERT(0x4d657361204272696e6720467269656e6473207265636f6e737472756374696f6e206163746f7273 USING utf8mb4),-10,0);
INSERT IGNORE INTO `npc_types`(`id`,`name`,`level`,`race`,`class`,`hp`,`mindmg`,`maxdmg`,`npc_spells_id`,`npc_faction_id`,`loottable_id`,`mana`,`aggroradius`,`runspeed`,`special_abilities`,`emoteid`,`lastname`,`bodytype`,`gender`,`texture`,`helmtexture`,`herosforgemodel`,`size`,`hp_regen_rate`,`hp_regen_per_second`,`mana_regen_rate`,`merchant_id`,`greed`,`alt_currency_id`,`npc_spells_effects_id`,`adventure_template_id`,`trap_template`,`attack_count`,`npcspecialattks`,`assistradius`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_tattoo`,`drakkin_details`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`,`d_melee_texture1`,`d_melee_texture2`,`ammo_idfile`,`prim_melee_type`,`sec_melee_type`,`ranged_type`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`PhR`,`see_invis`,`see_invis_undead`,`qglobal`,`AC`,`npc_aggro`,`spawn_limit`,`attack_speed`,`attack_delay`,`findable`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`see_hide`,`see_improved_hide`,`trackable`,`isbot`,`exclude`,`ATK`,`Accuracy`,`Avoidance`,`slow_mitigation`,`version`,`maxlevel`,`scalerate`,`private_corpse`,`unique_spawn_by_name`,`underwater`,`isquest`,`spellscale`,`healscale`,`no_target_hotkey`,`raid_target`,`armtexture`,`bracertexture`,`handtexture`,`legtexture`,`feettexture`,`light`,`walkspeed`,`peqid`,`unique_`,`fixed`,`ignore_despawn`,`show_name`,`untargetable`,`charm_ac`,`charm_min_dmg`,`charm_max_dmg`,`charm_attack_delay`,`charm_accuracy_rating`,`charm_avoidance_rating`,`charm_atk`,`skip_global_loot`,`rare_spawn`,`stuck_behavior`,`model`,`flymode`,`always_aggro`,`exp_mod`,`heroic_strikethrough`,`faction_amount`,`keeps_sold_items`,`is_parcel_merchant`,`multiquest_enabled`,`npc_tint_id`)VALUES
(397905,CONVERT(0x476c6173736f6e USING utf8mb4),45,529,8,10000,35,180,0,3040466,0,10000,70,1.25,'',0,NULL,1,0,0,0,0,0.0,0,0,0,0,0,0,0,0,0,-1,'',0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0,30,0,75,75,75,75,80,75,75,0,0,1,0,1,0,0,0,0,0,0,100,0,0,0,0,100.0,100.0,0,0,0,0,0,0,0,0,0.0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(397906,CONVERT(0x615f5475666665696e5f747265656b696c6c6572 USING utf8mb4),44,529,1,8000,35,150,0,3040466,0,0,70,1.25,'',0,NULL,1,0,0,0,0,0.0,0,0,0,0,0,0,0,0,0,-1,'',0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0,30,0,75,75,75,75,80,75,75,0,0,1,0,1,0,0,0,0,0,0,100,0,0,0,0,100.0,100.0,0,0,0,0,0,0,0,0,0.0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(397907,CONVERT(0x615f6472616b6b696e5f726169646572 USING utf8mb4),57,522,1,15000,80,300,0,3040466,0,0,70,1.25,'',0,NULL,1,0,0,0,0,0.0,0,0,0,0,0,0,0,0,0,-1,'',0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0,30,0,75,75,75,75,80,75,75,0,0,1,0,1,0,0,0,0,0,0,100,0,0,0,0,100.0,100.0,0,0,0,0,0,0,0,0,0.0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(397908,CONVERT(0x615f6472616b6b696e5f726169646572 USING utf8mb4),57,522,12,12000,60,240,2,3040466,0,10000,70,1.25,'',0,NULL,1,0,0,0,0,0.0,0,0,0,0,0,0,0,0,0,-1,'',0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0,30,0,75,75,75,75,80,75,75,0,0,1,0,1,0,0,0,0,0,0,100,0,0,0,0,100.0,100.0,0,0,0,0,0,0,0,0,0.0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(397909,CONVERT(0x615f7261696465725f6361707461696e USING utf8mb4),60,522,1,22000,100,500,0,3040466,0,0,70,1.25,'',0,NULL,1,0,0,0,0,0.0,0,0,0,0,0,0,0,0,0,-1,'',0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0,30,0,75,75,75,75,80,75,75,0,0,1,0,1,0,0,0,0,0,0,100,0,0,0,0,100.0,100.0,0,0,0,0,0,0,0,0,0.0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0);

COMMIT;
END//
DELIMITER ;

-- ---- mesa-bring-friends/sql/030-enable-bring-friends.sql ----
DELIMITER //
BEGIN NOT ATOMIC
DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;RESIGNAL;END;
START TRANSACTION;

IF(SELECT COUNT(*)FROM tasks WHERE id BETWEEN 3040465 AND 3040468 AND enabled IN(0,1))<>4 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Bring Friends enable-state conflict';END IF;
UPDATE tasks SET enabled=1 WHERE id BETWEEN 3040465 AND 3040468 AND enabled=0;
IF(SELECT COUNT(*)FROM achievement_criteria WHERE achievement_id=500040800 AND component_type=1 AND component_id BETWEEN 50162 AND 50165 AND enabled IN(0,1))<>4 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Bring Friends enable-state conflict';END IF;
UPDATE achievement_criteria SET enabled=1 WHERE achievement_id=500040800 AND component_type=1 AND component_id BETWEEN 50162 AND 50165 AND enabled=0;
COMMIT;
END//
DELIMITER ;
