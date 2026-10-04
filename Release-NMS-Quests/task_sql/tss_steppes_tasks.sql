-- -------------------------------------------------------------------------
-- The Serpent's Spine :: The Steppes task pass (audit vs Allakhazam 437)
-- Tasks 600596-600609. Zone ids: steppes=399, valdeholm=401, sunderock=403,
-- vergalid=404, crescent=394. Deferring (missing spawns/0-drop items):
-- Altar Escort, The Shattered Gift, Kromtus #3 (lv 105, out of era).
-- Simplifications: Portal #1 loses the Ancient Charm loot step (0 drops);
-- Lost Souls I substitutes Vergalid zealot kills for the named Skullrend;
-- Tribal Chieftains uses the three chieftains that exist, offered by
-- Warden Jakar (Sergeant Aerik is not spawned).
-- Idempotent: explicit primary keys + INSERT IGNORE, so re-running is a no-op.
-- -------------------------------------------------------------------------

INSERT IGNORE INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(600596, 2, 0, 0, 'Rebuild the Portal #1: The Talking Plant', '[1,Slay Wilped the Withered, keeper of the giant crypt.][2,Speak with Moldren the Wise.]', 'Experience', '', 0, 260000, 0, 0, 0, 60, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600597, 2, 0, 0, 'Rebuild the Portal #2: The Library', '[1,Travel to Valdeholm and speak with Wraithguard Lorekeeper Fenegar.][2,Speak with Moldren the Wise.]', 'Experience', '', 0, 260000, 0, 0, 0, 60, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600598, 2, 0, 0, 'Rebuild the Portal #3: The Destroyed Portal', '[1,Drive the Darkfell gnolls from the ruined portal grounds.][2,Speak with Moldren the Wise.]', 'Experience', '', 0, 280000, 0, 0, 0, 62, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600599, 2, 0, 0, 'Serric Lives', '[1,Travel into the Vergalid Mines.][2,Recover a Piece of Serric\'s Tabbard.][3,Deliver the tabbard to Orumot Uluntar.]', 'Experience', '', 0, 280000, 0, 0, 0, 65, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600600, 2, 0, 0, 'Lost Souls I', '[1,Enter the Vergalid Mines.][2,Slay 10 Vergalid zealots.][3,Speak with Captain Gul.]', 'Experience', '', 0, 280000, 0, 0, 0, 65, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600601, 2, 0, 0, 'Lost Souls II', '[1,Return to the Vergalid Mines.][2,Recover a Void Etched Symbol.][3,Deliver the symbol to Captain Gul.]', 'Experience', '', 0, 300000, 0, 0, 0, 70, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600602, 2, 0, 0, 'The Ancient Tablet', '[1,Journey into the Vergalid Mines.][2,Recover Hak`Leth\'s Ancient Tablet.][3,Deliver the tablet to Elder Nezzen Tru`tak.]', 'Experience', '', 0, 280000, 0, 0, 0, 65, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600603, 2, 0, 0, 'Web of Curiosity', '[1,Slay 12 wasp spiders.][2,Speak with Yavia.]', 'Experience', '', 0, 180000, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600604, 2, 0, 0, 'My Pretty', '[1,Slay 20 Darkfell gnolls.][2,Recover a Razor-sharp Obsidian Blade and 5 Yellow Spider Silk.][3,Deliver the blade and silk to Cragnaw.]', 'Experience', '', 0, 200000, 0, 0, 0, 55, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600605, 2, 0, 0, 'Sweeping the Steppes: Goblins', '[1,Provoke the goblins by slaying 12 of their number.][2,Slay the goblins\' pet bear.][3,Report your victory to Warden Jakar in Crescent Reach.]', 'Experience', '', 0, 200000, 0, 0, 0, 60, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600606, 2, 0, 0, 'Cull the Goblins', '[1,Recover 10 Stonemight Ears.][2,Bring the ears to Warden Jakar in Crescent Reach.]', 'Experience', '', 0, 220000, 0, 0, 0, 65, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600607, 2, 0, 0, 'Book For Toegnasher', '[1,Recover two of the ancient parchments the Darkfell carry.][2,Recover the third parchment.][3,Deliver the pages to Toegnasher.]', 'Experience', '', 0, 240000, 0, 0, 0, 70, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600608, 2, 0, 0, 'Scattered Gear', '[1,Recover Wyl`ard\'s Cartography Tools from the Darkfell.][2,Deliver the tools to Cartographer Wyl`ard.]', 'Experience', '', 0, 240000, 0, 0, 0, 70, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600609, 2, 0, 0, 'The Tribal Chieftains', '[1,Slay Stonemight Chieftain Swiftear.][2,Slay Nightmoon Chieftain Blacktooth.][3,Slay Nightmoon Chieftain Snowmane.][4,Report to Warden Jakar in Crescent Reach.]', 'Experience', '', 0, 260000, 0, 0, 0, 70, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1);

INSERT IGNORE INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	-- 600596 Portal #1
	(600596, 0, -1, 1, 2, 'Wilped the Withered', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600596, 1, -1, 2, 4, 'Moldren the Wise', 0, 1, '', '399070', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600597 Portal #2 (hail Fenegar proves the journey to Valdeholm)
	(600597, 0, -1, 1, 4, 'Wraithguard Lorekeeper Fenegar', 0, 1, '', '401081', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '401', -1, 0, 0),
	(600597, 1, -1, 2, 4, 'Moldren the Wise', 0, 1, '', '399070', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600598 Portal #3
	(600598, 0, -1, 1, 2, 'a Darkfell gnoll', 1, 10, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600598, 1, -1, 1, 2, 'a Darkfell shaman', 1, 4, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600598, 2, -1, 2, 4, 'Moldren the Wise', 0, 1, '', '399070', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600599 Serric Lives
	(600599, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -5000, -5000, -500, 5000, 5000, 500, '-1', '0', '404', -1, 0, 0),
	(600599, 1, -1, 2, 3, '', 0, 1, '', '', '36153', 'Pieces of Serric\'s Tabbard', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '404', -1, 0, 0),
	(600599, 2, -1, 3, 1, 'Orumot Uluntar', 0, 1, '', '399123', '36153', 'Piece of Serric\'s Tabbard', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600600 Lost Souls I
	(600600, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -5000, -5000, -500, 5000, 5000, 500, '-1', '0', '404', -1, 0, 0),
	(600600, 1, -1, 2, 2, 'a Vergalid assassin', 1, 5, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '404', -1, 0, 0),
	(600600, 2, -1, 2, 2, 'a Vergalid elite', 1, 5, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '404', -1, 0, 0),
	(600600, 3, -1, 3, 4, 'Captain Gul', 0, 1, '', '399135', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600601 Lost Souls II
	(600601, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -5000, -5000, -500, 5000, 5000, 500, '-1', '0', '404', -1, 0, 0),
	(600601, 1, -1, 2, 3, '', 0, 1, '', '', '36158', 'Void Etched Symbols', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '404', -1, 0, 0),
	(600601, 2, -1, 3, 1, 'Captain Gul', 0, 1, '', '399135', '36158', 'Void Etched Symbol', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600602 The Ancient Tablet
	(600602, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -5000, -5000, -500, 5000, 5000, 500, '-1', '0', '404', -1, 0, 0),
	(600602, 1, -1, 2, 3, '', 0, 1, '', '', '87174', 'Hak`Leth\'s Ancient Tablets', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '404', -1, 0, 0),
	(600602, 2, -1, 3, 1, 'Elder Nezzen Tru`tak', 0, 1, '', '399120', '87174', 'Hak`Leth\'s Ancient Tablet', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600603 Web of Curiosity
	(600603, 0, -1, 1, 2, 'wasp spider', 1, 12, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600603, 1, -1, 2, 4, 'Yavia', 0, 1, '', '399032', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600604 My Pretty
	(600604, 0, -1, 1, 2, 'a Darkfell gnoll', 1, 20, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600604, 1, -1, 2, 3, '', 0, 1, '', '', '88143', 'Razor-sharp Obsidian Blades', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600604, 2, -1, 2, 3, '', 0, 5, '', '', '88144', 'Yellow Spider Silk', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600604, 3, -1, 3, 1, 'Cragnaw', 0, 1, '', '399041', '88143,88144', 'Obsidian Blade and Spider Silk', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600605 Sweeping the Steppes: Goblins
	(600605, 0, -1, 1, 2, 'a Stonemight goblin', 1, 12, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600605, 1, -1, 2, 2, 'a brown bear', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600605, 2, -1, 3, 4, 'Warden Jakar', 0, 1, '', '394200', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '394', -1, 0, 0),
	-- 600606 Cull the Goblins
	(600606, 0, -1, 1, 3, '', 0, 10, '', '', '84241', 'Stonemight Ears', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600606, 1, -1, 2, 1, 'Warden Jakar', 0, 1, '', '394200', '84241', 'Stonemight Ear', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '394', -1, 0, 0),
	-- 600607 Book For Toegnasher
	(600607, 0, -1, 1, 3, '', 0, 2, '', '', '88138', 'Ancient Parchments', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600607, 1, -1, 1, 3, '', 0, 1, '', '', '88139', 'Ancient Parchments', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600607, 2, -1, 2, 1, 'Toegnasher', 0, 1, '', '399100', '88138,88139', 'Ancient Parchments', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600608 Scattered Gear
	(600608, 0, -1, 1, 3, '', 0, 1, '', '', '54659', 'Wyl`ards Cartography Tools', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600608, 1, -1, 2, 1, 'Cartographer Wyl`ard', 0, 1, '', '399071', '54659', 'Wyl`ards Cartography Tools', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	-- 600609 The Tribal Chieftains
	(600609, 0, -1, 1, 2, 'Stonemight Chieftain Swiftear', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '399', -1, 0, 0),
	(600609, 1, -1, 2, 2, 'Nightmoon Chieftain Blacktooth', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '400', -1, 0, 0),
	(600609, 2, -1, 3, 2, 'Nightmoon Chieftain Snowmane', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '400', -1, 0, 0),
	(600609, 3, -1, 4, 4, 'Warden Jakar', 0, 1, '', '394200', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '394', -1, 0, 0);
