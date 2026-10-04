-- -------------------------------------------------------------------------
-- The Serpent's Spine :: Stone Hive completion pass (Warwing + Vreshnar gaps)
-- Audit vs Allakhazam zone 433: adds the missing Warwing #1-4 task series
-- and Scout Vreshnar #2/#3, which were absent from the 600440-600483 block.
-- All activity NPCs/items already exist in peq: Warwing Wendlez (396123),
-- Neezzee (396180), Queen Pelzia (396209), Scout Neauza (396229),
-- Scout Vreshnar (395211, Blightfire Moors hub), bixie parts 54616-54620,
-- Bixie War Plans 21793, Saving Salve 54623, Muddied Bixie Plans 54624.
-- Activities use zoneidnumber: stonehive=396, moors=395.
-- Idempotent: explicit primary keys + INSERT IGNORE, so re-running is a no-op.
-- -------------------------------------------------------------------------

INSERT IGNORE INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(600584, 2, 0, 0, 'Warwing #1: Who\'s Who?', '[1,Find Bixie Neezzee in the war council chamber.][2,Slay Neezzee.][3,Speak with Warwing Wendlez.]', 'Experience', '', 0, 150000, 0, 0, 0, 30, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600585, 2, 0, 0, 'Warwing #2: Infiltrate the Hive', '[1,Retrieve the Bixie War Plans from the war council chamber.][2,Bring the Bixie War Plans to Warwing Wendlez.]', 'Experience', '', 0, 150000, 0, 0, 0, 30, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600586, 2, 0, 0, 'Warwing #3: Honey, I\'m Home!', '[1,Collect 2 Intact Bixie Wings and 2 Intact Bixie Flesh and 1 Intact Bixie Scent Gland and 2 Intact Bixie Antennae and 1 Intact Stone Hive Insignia.][2,Bring the disguise components to Warwing Wendlez.]', 'Experience', '', 0, 210000, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600587, 2, 0, 0, 'Warwing #4: The Queen Bixie', '[1,Slay Queen Pelzia.][2,Speak with Warwing Wendlez.]', 'Experience', '', 0, 210000, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600588, 2, 0, 0, 'Scout Vreshnar #2: The Saving Salve', '[1,Slay a bixie enthraller and loot a Saving Salve.][2,Deliver the Saving Salve to Scout Neauza.]', 'Experience', '', 0, 90000, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600589, 2, 0, 0, 'Scout Vreshnar #3: Plans or No Plans', '[1,Take the Muddied Bixie Plans to Scout Vreshnar in Blightfire Moors.]', 'Experience', '', 0, 90000, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1);

INSERT IGNORE INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	-- 600584 Warwing #1: hail Neezzee, slay her, report to Warwing
	(600584, 0, -1, 1, 4, 'Neezzee', 0, 1, '', '396180', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600584, 1, -1, 2, 2, 'Neezzee', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600584, 2, -1, 3, 4, 'Warwing Wendlez', 0, 1, '', '396123', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	-- 600585 Warwing #2: ground spawn plans in the war room, hand them in
	(600585, 0, -1, 1, 3, '', 0, 1, '', '', '21793', 'Bixie War Plans', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600585, 1, -1, 2, 1, 'Warwing Wendlez', 0, 1, '', '396123', '21793', 'Bixie War Plans', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	-- 600586 Warwing #3: disguise components (prelootable) handed to Warwing
	(600586, 0, -1, 1, 3, '', 0, 2, '', '', '54616', 'Intact Bixie Wings', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600586, 1, -1, 1, 3, '', 0, 2, '', '', '54617', 'Intact Bixie Flesh', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600586, 2, -1, 1, 3, '', 0, 1, '', '', '54618', 'Intact Bixie Scent Gland', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600586, 3, -1, 1, 3, '', 0, 2, '', '', '54619', 'Intact Bixie Antennae', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600586, 4, -1, 1, 3, '', 0, 1, '', '', '54620', 'Intact Stone Hive Insignia', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600586, 5, -1, 2, 1, 'Warwing Wendlez', 0, 8, '', '396123', '54616,54617,54618,54619,54620', 'Bixie Disguise Components', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	-- 600587 Warwing #4: Queen Pelzia falls, report to Warwing
	(600587, 0, -1, 1, 2, 'Queen Pelzia', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600587, 1, -1, 2, 4, 'Warwing Wendlez', 0, 1, '', '396123', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	-- 600588 Scout Vreshnar #2: enthraller salve cure, delivered to Neauza
	(600588, 0, -1, 1, 2, 'a bixie enthraller', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	(600588, 1, -1, 2, 1, 'Scout Neauza', 0, 1, '', '396229', '54623', 'Saving Salve', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '396', -1, 0, 0),
	-- 600589 Scout Vreshnar #3: plans carried back to Vreshnar (Blightfire hub)
	(600589, 0, -1, 1, 1, 'Scout Vreshnar', 0, 1, '', '395211', '54624', 'Muddied Bixie Plans', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '395', -1, 0, 0);

-- The Collector auto-generated placeholder at the live war-plans spot
-- (x -11, y -183, z 409) carried item 1001 and version 1, so it never
-- spawned. Repoint it to the Bixie War Plans on the live version (0).
UPDATE `ground_spawns`
	SET `item` = 21793, `name` = 'Bixie_War_Plans', `version` = 0,
	    `respawn_timer` = 600, `comment` = 'Bixie War Plans - war council chamber'
	WHERE `id` = 366 AND `item` = 1001;
