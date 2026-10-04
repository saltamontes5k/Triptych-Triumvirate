-- -------------------------------------------------------------------------
-- The Serpent's Spine :: Blackfeather Roost mini-task pass
-- Audit vs Allakhazam zone 436: adds the six missing roost tasks
-- (Explore the Roost!, Harass the Harpies!, Cause some mayhem, Strike a Blow,
-- A Small Wager, Destroy! Knock the nests down!). Lucian's Vengeance,
-- While You're Roosting and Rites of Passage are Hero's Journey
-- achievements on live and are auto-satisfied by these tasks.
-- All activity NPCs/items already exist in peq: Adrian (398022),
-- Lucian (398023), Dorinda (398039), Gayatri (398065), harpy/griffon/nest
-- mobs, Royal Trinket 28678, Gayatri's Heart 13617.
-- Activities use zoneidnumber: roost=398.
-- Idempotent: explicit primary keys + INSERT IGNORE, so re-running is a no-op.
-- -------------------------------------------------------------------------

INSERT IGNORE INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(600590, 2, 0, 0, 'Explore the Roost!', '[1,Search the nest on the ledge.][2,Sneak into the harpy grove.][3,Explore the cliffs.][4,Search atop the Harpy Mesa.]', 'Experience', '', 0, 120000, 0, 0, 0, 35, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600591, 2, 0, 0, 'Harass the Harpies!', '[1,Slay 10 blackfeather griffons.][2,Speak with Adrian.]', 'Experience', '', 0, 150000, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600592, 2, 0, 0, 'Cause some mayhem - Kill Gayatri', '[1,Slay Gayatri.][2,Deliver Gayatri\'s Heart to Lucian.]', 'Experience', '', 0, 180000, 0, 0, 0, 45, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600593, 2, 0, 0, 'Strike a Blow - Kill Harpies and Griffons!', '[1,Slay 24 harpies.][2,Slay 5 blackfeather griffons.][3,Speak with Lucian.]', 'Experience', '', 0, 180000, 0, 0, 0, 45, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600594, 2, 0, 0, 'A Small Wager', '[1,Steal a Royal Trinket from the Queen\'s throne room.][2,Deliver the Royal Trinket to Dorinda.]', 'Experience', '', 0, 210000, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
	(600595, 2, 0, 0, 'Destroy! Knock the nests down!', '[1,Destroy the small harpy nests.][2,Destroy the large harpy nests.][3,Destroy the ornate harpy nests on the mesa.][4,Speak with Lucian.]', 'Experience', '', 0, 240000, 0, 0, 0, 55, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1);

INSERT IGNORE INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	-- 600590 Explore the Roost!: four landmark searches (fan Y,X -> EQEmu X,Y)
	(600590, 0, -1, 1, 5, '', 0, 1, '', '', '', '', 0, -1025, 3110, 0, -825, 3310, 500, '-1', '0', '398', -1, 0, 0),
	(600590, 1, -1, 2, 5, '', 0, 1, '', '', '', '', 0, 1000, 3650, 0, 1200, 3850, 500, '-1', '0', '398', -1, 0, 0),
	(600590, 2, -1, 3, 5, '', 0, 1, '', '', '', '', 0, -3051, 4655, 0, -2851, 4855, 500, '-1', '0', '398', -1, 0, 0),
	(600590, 3, -1, 4, 5, '', 0, 1, '', '', '', '', 0, 835, 5850, 0, 1035, 6050, 500, '-1', '0', '398', -1, 0, 0),
	-- 600591 Harass the Harpies!: griffon cull, report to Adrian
	(600591, 0, -1, 1, 2, 'blackfeather griffon', 1, 10, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600591, 1, -1, 2, 4, 'Adrian', 0, 1, '', '398022', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	-- 600592 Cause some mayhem: Gayatri falls, heart to Lucian
	(600592, 0, -1, 1, 2, 'Gayatri', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600592, 1, -1, 2, 1, 'Lucian', 0, 1, '', '398023', '13617', 'Gayatri\'s Heart', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	-- 600593 Strike a Blow: harpy and griffon cull, report to Lucian
	(600593, 0, -1, 1, 2, 'a harpy', 1, 12, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600593, 1, -1, 1, 2, 'restless harpy', 1, 6, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600593, 2, -1, 1, 2, 'wandering harpy', 1, 4, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600593, 3, -1, 1, 2, 'highborn harpy', 1, 2, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600593, 4, -1, 2, 2, 'blackfeather griffon', 1, 5, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600593, 5, -1, 3, 4, 'Lucian', 0, 1, '', '398023', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	-- 600594 A Small Wager: steal the trinket, deliver to Dorinda
	(600594, 0, -1, 1, 3, '', 0, 1, '', '', '28678', 'Royal Trinket', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600594, 1, -1, 2, 1, 'Dorinda', 0, 1, '', '398039', '28678', 'Royal Trinket', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	-- 600595 Destroy!: nest demolition by variant, report to Lucian
	(600595, 0, -1, 1, 2, 'a small plain harpy nest', 1, 1, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600595, 1, -1, 1, 2, 'a small normal harpy nest', 1, 4, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600595, 2, -1, 1, 2, 'a small sturdy harpy nest', 1, 4, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600595, 3, -1, 2, 2, 'a large normal harpy nest', 1, 8, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600595, 4, -1, 2, 2, 'a large plain harpy nest', 1, 6, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600595, 5, -1, 2, 2, 'a large sturdy harpy nest', 1, 8, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600595, 6, -1, 3, 2, 'an ornate harpy nest', 1, 5, '', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0),
	(600595, 7, -1, 4, 4, 'Lucian', 0, 1, '', '398023', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '398', -1, 0, 0);

-- The Collector auto-generated placeholder at the live Royal Trinket spot
-- (x -200, y 6384, z 255, Queen Eletyl's throne room) carried item 1001.
-- Repoint it to the Royal Trinket.
UPDATE `ground_spawns`
	SET `item` = 28678, `name` = 'Royal_Trinket',
	    `respawn_timer` = 600, `comment` = 'Royal Trinket - Queen throne room'
	WHERE `id` = 369 AND `item` = 1001;
