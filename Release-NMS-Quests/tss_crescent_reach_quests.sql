-- ============================================================================
-- TSS Crescent Reach: new quest content (Hero's Journey newbie arc + 65+
-- drakkin breath quests) for the NMS server.
-- Server: NMS (peq @ 127.0.0.1)  Zone: crescent (id 55)
-- Idempotent: safe to re-run.
--
-- Requires tss_crescent_reach_fixes.sql (Phase 1) to be applied first.
--
-- Allakkazam locs are (y, x, z); every coordinate below has been converted
-- to EQEmu (x, y, z) and validated against existing spawn data in this DB.
--
-- Tasks:
--   600240 Getting to Know You: For Those Gone Before Us
--   600241 Prove Your Worth
--   600242 Heshyrr's Wisdom            600243 Ithakis' Challenge
--   600244 Lizzrel's Path              600245 Myjinn's Enlightenment
--   600246 Reakash's Serenity          600247 Vakk'dra's Shadow
--   600249 Slightly Less Than One-Half of a Baker's Dozen
--   600250 Party Preparation           600251 Web of Fears
--   600252 A Dark Heart                600253 Food for Thought
--   600254 Soul Patrol                 600255 Reclaim the Farm
--   600256 Locked Up Locket
--   600260-600271 Breath quests, ranks 14 (lvl 70) and 15 (lvl 75) x 6 lineages
--   600272 Utenka's Combat Trial (training dummies; no live page exists -
--          reconstructed from the Crescent Reach newbie guide)
--
-- NPC ids 999401-999411, spawngroups 61000001+, spawn2 46000001+,
-- lootdrops 90000101+, recipes 991101+, aa_ranks 20078-20089,
-- spells 50009-50014.
-- ============================================================================

-- ============================================================================
-- SECTION A: TASKS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 600240: Getting to Know You: For Those Gone Before Us (live 3608)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600240;
DELETE FROM tasks WHERE id = 600240;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600240, 2, 0, 0, 'Getting to Know You: For Those Gone Before Us',
	 'Council Aide Mystrana would like you to study a book on the history of the city.',
	 '', '53492', 700, 15000, 0, 0, 0, 1, 85, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600240, 0, 0, 1, 13, '', 0, 1,
	 'Find the book "The Ogres Come of Age" in Gekkdar''s Haunt on the third level',
	 '57975', '55', 0, 0),
	(600240, 1, 0, 2, 4, 'Council Aide Mystrana', 1, 1,
	 'Return to Council Aide Mystrana', '', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600241: Prove Your Worth (live 3675) - gate for all six Councilmember quests
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600241;
DELETE FROM tasks WHERE id = 600241;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600241, 2, 0, 0, 'Prove Your Worth',
	 'Create a banner of the Drakkin for the Council of Six to prove your allegiance to Crescent Reach.',
	 '', NULL, 1000, 50000, 0, 0, 0, 1, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600241, 0, 0, 1, 4, 'Tailor Meikolu', 1, 1,
	 'Speak with Tailor Meikolu in Artisans'' Row', '', '55', 0, 0),
	(600241, 1, 0, 2, 6, 'Drakkin Banner', 1, 1,
	 'Combine the banner pattern, dye and cloth in the Drakkin Sewing Kit', '', '55', 0, 0),
	(600241, 2, 0, 3, 1, 'Tailor Meikolu', 1, 1,
	 'Give the finished Banner Cloth to Tailor Meikolu', '84226', '55', 0, 0),
	(600241, 3, 0, 4, 1, 'Councilmember', 1, 1,
	 'Deliver the Banner of the Drakkin to one of the Councilmembers', '84230', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600242: Heshyrr's Wisdom (live 3673)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600242;
DELETE FROM tasks WHERE id = 600242;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600242, 2, 0, 0, 'Heshyrr''s Wisdom',
	 'Councilmember Heshyrr wants you to listen to the spirits of the city''s past.',
	 '', NULL, 1000, 50000, 0, 0, 0, 1, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600242, 0, 0, 1, 4, 'Spirit of Truth', 1, 1,
	 'Speak with the Spirit of Truth at the rune stones of the Dragon''s Grove',
	 NULL, '55', 0, 0),
	(600242, 1, 0, 2, 4, 'Spirit of Wisdom', 1, 1,
	 'Speak with the Spirit of Wisdom at the rune stones near the tunnel to the city',
	 NULL, '55', 0, 0),
	(600242, 2, 0, 3, 4, 'Yuvill the Spirithunter', 1, 1,
	 'With the Seeker''s Spiritstaff, find the invisible drakkin Yuvill on the third level',
	 NULL, '55', 0, 0),
	(600242, 3, 0, 4, 4, 'Councilmember Heshyrr', 1, 1,
	 'Return to Councilmember Heshyrr', '', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600243: Ithakis' Challenge (live 3925)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600243;
DELETE FROM tasks WHERE id = 600243;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600243, 2, 0, 0, 'Ithakis'' Challenge',
	 'Councilmember Ithakis challenges you to master the arts of fire and forge.',
	 '', NULL, 1000, 50000, 0, 0, 0, 1, 85, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600243, 0, 0, 1, 4, 'Quartermaster Thatun', 1, 1,
	 'Speak with Quartermaster Thatun near the training dummies', '', '55', 0, 0),
	(600243, 1, 0, 2, 2, 'a training dummy', 1, 1,
	 'Destroy a training dummy in hand to hand combat', '', '55', 0, 0),
	(600243, 2, 0, 3, 6, 'Burning Torch', 1, 1,
	 'Light the Torch of the Red Lord with the Breath of the Red Lord in the Flame-Sealed Box',
	 NULL, '55', 0, 0),
	(600243, 3, 0, 4, 4, 'Smithy Drawlyn', 1, 1,
	 'Speak with Smithy Drawlyn in Artisans'' Row', '', '55', 0, 0),
	(600243, 4, 0, 5, 1, 'Smithy Drawlyn', 1, 1,
	 'Give the Flametouched Ceremonial Sword to Smithy Drawlyn', '84210', '55', 0, 0),
	(600243, 5, 0, 6, 4, 'Councilmember Ithakis', 1, 1,
	 'Return to Councilmember Ithakis', '', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600244: Lizzrel's Path (live 3748)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600244;
DELETE FROM tasks WHERE id = 600244;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600244, 2, 0, 0, 'Lizzrel''s Path',
	 'Councilmember Lizzrel asks you to gather three treasures that teach the drakkin ways.',
	 '', NULL, 1000, 50000, 0, 0, 0, 1, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600244, 0, 0, 1, 13, '', 0, 1,
	 'Gather a Poisonous Nettle from the dark bushes of the sporali cave',
	 '84212', '55', 0, 0),
	(600244, 1, 0, 2, 13, '', 0, 1,
	 'Gather a Broadleaf plant from the Dragon''s Grove', '84213', '55', 0, 0),
	(600244, 2, 0, 3, 13, '', 0, 1,
	 'Find a Drakkin Scale on the top floor of the inn', '84214', '55', 0, 0),
	(600244, 3, 0, 4, 1, 'Councilmember Lizzrel', 1, 3,
	 'Deliver the Poisonous Nettle, Broadleaf and Drakkin Scale to Councilmember Lizzrel',
	 '84212;84213;84214', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600245: Myjinn's Enlightenment (live 3890)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600245;
DELETE FROM tasks WHERE id = 600245;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600245, 2, 0, 0, 'Myjinn''s Enlightenment',
	 'Councilmember Myjinn bids you to seek knowledge from three sources and return to be tested.',
	 '', NULL, 1000, 50000, 0, 0, 0, 1, 85, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600245, 0, 0, 1, 4, 'Assistant Geejulin', 1, 1,
	 'Speak with Assistant Geejulin above the library', '', '55', 0, 0),
	(600245, 1, 0, 2, 13, '', 0, 1,
	 'Read the Touch of the Six, hidden in the library on the second level',
	 '84220', '55', 0, 0),
	(600245, 2, 0, 3, 13, '', 0, 1,
	 'Find the book "Veeshan''s Children" by the water of the Dragon''s Grove',
	 '84219', '55', 0, 0),
	(600245, 3, 0, 4, 4, 'Councilmember Myjinn', 1, 1,
	 'Return to Councilmember Myjinn and answer her questions', '', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600246: Reakash's Serenity (live 4203)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600246;
DELETE FROM tasks WHERE id = 600246;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600246, 2, 0, 0, 'Reakash''s Serenity',
	 'Councilmember Reakash asks you to gather offerings of pure water and the mist of the falls.',
	 '', NULL, 1000, 50000, 0, 0, 0, 1, 85, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600246, 0, 0, 1, 13, '', 0, 1,
	 'Draw a Sample of Pure Water from the waterfalls of the Hollow',
	 '84201', '55', 0, 0),
	(600246, 1, 0, 2, 13, '', 0, 1,
	 'Take a Wind Chime from Merchant Wyn''las (no charge)', '84202', '55', 0, 0),
	(600246, 2, 0, 3, 13, '', 0, 1,
	 'Collect the mist of the waterfalls with the Jar of the Windspirit',
	 '84203', '55', 0, 0),
	(600246, 3, 0, 4, 1, 'Councilmember Reakash', 1, 3,
	 'Deliver the water sample, wind chime and jar of mist to Councilmember Reakash',
	 '84201;84202;84203', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600247: Vakk'dra's Shadow (live 3677)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600247;
DELETE FROM tasks WHERE id = 600247;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600247, 2, 0, 0, 'Vakk''dra''s Shadow',
	 'Councilmember Vakk''dra sends you to gather components touched by shadow.',
	 '', NULL, 1000, 50000, 0, 0, 0, 1, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600247, 0, 0, 1, 3, 'an undead fisherman', 1, 1,
	 'Loot an Enchanted Essence of Shadow from an undead fisherman near the falls',
	 '84215', '55', 0, 0),
	(600247, 1, 0, 2, 13, '', 0, 1,
	 'Recover a Dusty Skeleton Bone from the top level of the city',
	 '84216', '55', 0, 0),
	(600247, 2, 0, 3, 4, 'Butcher Katorr', 1, 1,
	 'Ask Butcher Katorr for a Piece of Acrid Meat', '', '55', 0, 0),
	(600247, 3, 0, 4, 1, 'Councilmember Vakk`dra', 1, 3,
	 'Deliver the essence, bone and meat to Councilmember Vakk`dra',
	 '84215;84216;84217', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600249: Slightly Less Than One-Half of a Baker's Dozen (live 3698)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600249;
DELETE FROM tasks WHERE id = 600249;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600249, 2, 0, 0, 'Slightly Less Than One-Half of a Baker''s Dozen',
	 'Baker Shivra needs six truffles from the Mushroom Grove for her special flan.',
	 '', '53487', 0, 50000, 0, 0, 0, 5, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600249, 0, 0, 1, 3, 'sporeling', 1, 6,
	 'Collect 6 Tasty Truffles from the sporelings of the first cave',
	 '52637', '55', 0, 0),
	(600249, 1, 0, 2, 1, 'Baker Shivra', 1, 6,
	 'Return 6 Tasty Truffles to Baker Shivra', '52637', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600250: Party Preparation (live 3699)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600250;
DELETE FROM tasks WHERE id = 600250;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600250, 2, 0, 0, 'Party Preparation',
	 'Baker Shivra needs a crate of her fizzy lemonade that Uliean left in the puma caves.',
	 '', '53488', 0, 50000, 0, 0, 0, 5, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600250, 0, 0, 1, 13, '', 0, 1,
	 'Recover a bottle of Fizzy Lemonade from the crate in the puma cave',
	 '52638', '55', 0, 0),
	(600250, 1, 0, 2, 4, 'Baker Shivra', 1, 1,
	 'Return the lemonade to Baker Shivra', '', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600251: Web of Fears (live 4439)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600251;
DELETE FROM tasks WHERE id = 600251;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600251, 2, 0, 0, 'Web of Fears',
	 'Council Aide Shay asks the city''s champions to cull the spiderlings and destroy their queen.',
	 '', '61662', 1000, 150000, 0, 0, 0, 10, 85, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600251, 0, 0, 1, 2, 'spiderling', 1, 10,
	 'Destroy 10 spiderlings', '', '55', 0, 0),
	(600251, 1, 0, 2, 3, 'spiderling', 1, 5,
	 'Loot 5 Spider Eggs', '54657', '55', 0, 0),
	(600251, 2, 1, 3, 2, 'Canyon Queen', 1, 1,
	 'Defeat the Canyon Queen near the bridge', '', '55', 0, 0),
	(600251, 3, 0, 4, 4, 'Council Aide Shay', 1, 1,
	 'Return to Council Aide Shay', '', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600252: A Dark Heart (live 3653)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600252;
DELETE FROM tasks WHERE id = 600252;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600252, 2, 0, 0, 'A Dark Heart',
	 'Vunder the Dark requires ingredients held by the scaleless apothecary, Shelga.',
	 '', NULL, 20500, 150000, 0, 0, 0, 10, 85, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600252, 0, 0, 1, 2, 'Apothecary Shelga', 1, 1,
	 'Kill Apothecary Shelga in Artisans'' Row while no one is watching', '', '55', 0, 0),
	(600252, 1, 0, 2, 3, 'Apothecary Shelga', 1, 1,
	 'Loot Shelga''s Pouch of Ingredients', '52636', '55', 0, 0),
	(600252, 2, 0, 3, 1, 'Vunder the Dark', 1, 1,
	 'Return Shelga''s Pouch to Vunder the Dark', '52636', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600253: Food for Thought (live 3963)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600253;
DELETE FROM tasks WHERE id = 600253;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600253, 2, 0, 0, 'Food for Thought',
	 'Farmer Lize asks you to recover her trinkets from the chests scattered around the farm.',
	 '', '53499', 0, 200000, 0, 0, 0, 15, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600253, 0, 0, 1, 13, '', 0, 5,
	 'Open the chests around the farm and recover 5 of Lize''s Trinkets',
	 '36196', '55', 0, 0),
	(600253, 1, 0, 2, 1, 'Farmer Lize', 1, 5,
	 'Deliver 5 of Lize''s Trinkets to Farmer Lize', '36196', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600254: Soul Patrol (live 4171)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600254;
DELETE FROM tasks WHERE id = 600254;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600254, 2, 0, 0, 'Soul Patrol',
	 'Farmer Lize asks you to set the tormented spirits of the farm free.',
	 '', '53500', 0, 200000, 0, 0, 0, 15, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600254, 0, 0, 1, 2, 'a skeletal ogre', 1, 10,
	 'Set 10 skeletal ogres of the farm free', '', '55', 0, 0),
	(600254, 1, 0, 2, 4, 'Farmer Lize', 1, 1,
	 'Return to Farmer Lize', '', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600255: Reclaim the Farm (live 3917)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600255;
DELETE FROM tasks WHERE id = 600255;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600255, 2, 0, 0, 'Reclaim the Farm',
	 'Farmer Joen asks you to plant seeds in the farm fields so the farm may live again.',
	 '', '53498', 0, 200000, 0, 0, 0, 15, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600255, 0, 0, 1, 11, 'a fertile field', 1, 10,
	 'Use the Bag of Seeds to plant the fields near the farm', '', '55', 0, 0),
	(600255, 1, 0, 2, 4, 'Farmer Joen', 1, 1,
	 'Return to Farmer Joen and inform him of your work', '', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600256: Locked Up Locket (live 3916)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600256;
DELETE FROM tasks WHERE id = 600256;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600256, 2, 0, 0, 'Locked Up Locket',
	 'Farmer Joen asks you to retrieve the locket he gave Lize from the undead of the farm.',
	 '', '53501', 0, 200000, 0, 0, 0, 15, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600256, 0, 0, 1, 3, 'undead', 1, 1,
	 'Retrieve Lize''s Locket from the undead of the farm', '84232', '55', 0, 0),
	(600256, 1, 0, 2, 1, 'Farmer Joen', 1, 1,
	 'Return the locket to Farmer Joen', '84232', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600272: Utenka's Combat Trial (training dummy practice; reconstructed
--         from the Crescent Reach newbie guide - no live page found)
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600272;
DELETE FROM tasks WHERE id = 600272;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600272, 2, 0, 0, 'Utenka''s Combat Trial',
	 'Champion Utenka asks you to hone your skills on the training dummies.',
	 '', NULL, 500, 25000, 0, 0, 0, 1, 85, 0, 1, 0, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600272, 0, 0, 1, 2, 'a training dummy', 1, 10,
	 'Destroy 10 training dummies', '', '55', 0, 0),
	(600272, 1, 0, 2, 4, 'Champion Utenka', 1, 1,
	 'Return to Champion Utenka', '', '55', 0, 0);

-- ---------------------------------------------------------------------------
-- 600260-600271: Drakkin breath weapon quests, ranks 14 (level 70) and
-- 15 (level 75). Ranks 1-13 (levels 5-65) are auto-granted on this server.
-- Same structure for all six lineages: kill the named, loot its head/skull,
-- deliver it to your lineage dragon in Crescent Reach.
-- ---------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid BETWEEN 600260 AND 600271;
DELETE FROM tasks WHERE id BETWEEN 600260 AND 600271;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600260, 2, 0, 0, 'Breath of Atathus XIV',  'Atathus the Red Lord wants the skull of Velosk of the Vergalid Mines to strengthen your blood.', '', NULL, 5000, 500000, 0, 0, 0, 70, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600261, 2, 0, 0, 'Breath of Atathus XV',   'Atathus the Red Lord wants the head of Kellet, Royal Guard Captain of Valdeholm, to complete your bloodline.', '', NULL, 5000, 750000, 0, 0, 0, 75, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600262, 2, 0, 0, 'Breath of Draton''ra XIV', 'Draton''ra, Master of the Void, wants the skull of Velosk of the Vergalid Mines to strengthen your blood.', '', NULL, 5000, 500000, 0, 0, 0, 70, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600263, 2, 0, 0, 'Breath of Draton''ra XV',  'Draton''ra, Master of the Void, wants the head of Kellet, Royal Guard Captain of Valdeholm, to complete your bloodline.', '', NULL, 5000, 750000, 0, 0, 0, 75, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600264, 2, 0, 0, 'Breath of Osh''vir XIV',   'Osh''vir the Windspirit wants the skull of Velosk of the Vergalid Mines to strengthen your blood.', '', NULL, 5000, 500000, 0, 0, 0, 70, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600265, 2, 0, 0, 'Breath of Osh''vir XV',    'Osh''vir the Windspirit wants the head of Kellet, Royal Guard Captain of Valdeholm, to complete your bloodline.', '', NULL, 5000, 750000, 0, 0, 0, 75, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600266, 2, 0, 0, 'Breath of Venesh XIV',     'Venesh the Greenblood wants the skull of Velosk of the Vergalid Mines to strengthen your blood.', '', NULL, 5000, 500000, 0, 0, 0, 70, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600267, 2, 0, 0, 'Breath of Venesh XV',      'Venesh the Greenblood wants the head of Kellet, Royal Guard Captain of Valdeholm, to complete your bloodline.', '', NULL, 5000, 750000, 0, 0, 0, 75, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600268, 2, 0, 0, 'Breath of Mysaphar XIV',   'Mysaphar, Seeker of All, wants the skull of Velosk of the Vergalid Mines to strengthen your blood.', '', NULL, 5000, 500000, 0, 0, 0, 70, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600269, 2, 0, 0, 'Breath of Mysaphar XV',    'Mysaphar, Seeker of All, wants the head of Kellet, Royal Guard Captain of Valdeholm, to complete your bloodline.', '', NULL, 5000, 750000, 0, 0, 0, 75, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600270, 2, 0, 0, 'Breath of Keikolin XIV',   'Keikolin the Enlightened wants the skull of Velosk of the Vergalid Mines to strengthen your blood.', '', NULL, 5000, 500000, 0, 0, 0, 70, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1),
	(600271, 2, 0, 0, 'Breath of Keikolin XV',    'Keikolin the Enlightened wants the head of Kellet, Royal Guard Captain of Valdeholm, to complete your bloodline.', '', NULL, 5000, 750000, 0, 0, 0, 75, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

-- Kill activities: Velosk prowls in Vergalid Mines (zone 425), Kellet rules
-- Valdeholm (zone 421). Deliver to the matching lineage dragon (zone 55).
INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600260, 0, 0, 1, 3, 'Velosk', 1, 1, 'Collect 1 Skull of Velosk', '64103', '425', 0, 0),
	(600260, 1, 0, 2, 1, 'Atathus the Red Lord', 1, 1, 'Deliver 1 Skull of Velosk to Atathus the Red Lord', '64103', '55', 0, 0),
	(600261, 0, 0, 1, 3, 'Kellet', 1, 1, 'Collect 1 Head of Kellet', '64104', '421', 0, 0),
	(600261, 1, 0, 2, 1, 'Atathus the Red Lord', 1, 1, 'Deliver 1 Head of Kellet to Atathus the Red Lord', '64104', '55', 0, 0),
	(600262, 0, 0, 1, 3, 'Velosk', 1, 1, 'Collect 1 Skull of Velosk', '64103', '425', 0, 0),
	(600262, 1, 0, 2, 1, 'Draton`ra, Master of the Void', 1, 1, 'Deliver 1 Skull of Velosk to Draton`ra, Master of the Void', '64103', '55', 0, 0),
	(600263, 0, 0, 1, 3, 'Kellet', 1, 1, 'Collect 1 Head of Kellet', '64104', '421', 0, 0),
	(600263, 1, 0, 2, 1, 'Draton`ra, Master of the Void', 1, 1, 'Deliver 1 Head of Kellet to Draton`ra, Master of the Void', '64104', '55', 0, 0),
	(600264, 0, 0, 1, 3, 'Velosk', 1, 1, 'Collect 1 Skull of Velosk', '64103', '425', 0, 0),
	(600264, 1, 0, 2, 1, 'Osh`vir the Windspirit', 1, 1, 'Deliver 1 Skull of Velosk to Osh`vir the Windspirit', '64103', '55', 0, 0),
	(600265, 0, 0, 1, 3, 'Kellet', 1, 1, 'Collect 1 Head of Kellet', '64104', '421', 0, 0),
	(600265, 1, 0, 2, 1, 'Osh`vir the Windspirit', 1, 1, 'Deliver 1 Head of Kellet to Osh`vir the Windspirit', '64104', '55', 0, 0),
	(600266, 0, 0, 1, 3, 'Velosk', 1, 1, 'Collect 1 Skull of Velosk', '64103', '425', 0, 0),
	(600266, 1, 0, 2, 1, 'Venesh the Greenblood', 1, 1, 'Deliver 1 Skull of Velosk to Venesh the Greenblood', '64103', '55', 0, 0),
	(600267, 0, 0, 1, 3, 'Kellet', 1, 1, 'Collect 1 Head of Kellet', '64104', '421', 0, 0),
	(600267, 1, 0, 2, 1, 'Venesh the Greenblood', 1, 1, 'Deliver 1 Head of Kellet to Venesh the Greenblood', '64104', '55', 0, 0),
	(600268, 0, 0, 1, 3, 'Velosk', 1, 1, 'Collect 1 Skull of Velosk', '64103', '425', 0, 0),
	(600268, 1, 0, 2, 1, 'Mysaphar, Seeker of All', 1, 1, 'Deliver 1 Skull of Velosk to Mysaphar, Seeker of All', '64103', '55', 0, 0),
	(600269, 0, 0, 1, 3, 'Kellet', 1, 1, 'Collect 1 Head of Kellet', '64104', '421', 0, 0),
	(600269, 1, 0, 2, 1, 'Mysaphar, Seeker of All', 1, 1, 'Deliver 1 Head of Kellet to Mysaphar, Seeker of All', '64104', '55', 0, 0),
	(600270, 0, 0, 1, 3, 'Velosk', 1, 1, 'Collect 1 Skull of Velosk', '64103', '425', 0, 0),
	(600270, 1, 0, 2, 1, 'Keikolin the Enlightened', 1, 1, 'Deliver 1 Skull of Velosk to Keikolin the Enlightened', '64103', '55', 0, 0),
	(600271, 0, 0, 1, 3, 'Kellet', 1, 1, 'Collect 1 Head of Kellet', '64104', '421', 0, 0),
	(600271, 1, 0, 2, 1, 'Keikolin the Enlightened', 1, 1, 'Deliver 1 Head of Kellet to Keikolin the Enlightened', '64104', '55', 0, 0);

-- ============================================================================
-- SECTION B: NEW NPCs + SPAWNS
--   999401 Spirit of Truth          (rune stones, SW Dragon's Grove)
--   999402 Spirit of Wisdom         (rune stones near the tunnel to the city)
--   999403 Velosk                   (rare PH swap in Vergalid Mines)
--   999404 a_shimmering_parchment   (library 2nd level - Touch of the Six)
--   999405 a_stack_of_old_books     (NE water, Dragon's Grove - Veeshan's Children)
--   999406 a_dusty_grimoire         (Gekkdar's Haunt - The Ogres Come of Age)
--   999407 a_discarded_water_bottle (waterfall pond, the Hollow)
--   999408 a_dusty_bone_pile        (top level x2 - Dusty Skeleton Bone)
--   999409 a_dark_green_bush        (sporali cave - Poisonous Nettle)
--   999410 a_broadleaf_plant        (Dragon's Grove x2 - Broadleaf)
--   999411 a_small_pile_of_scales   (inn top floor - Drakkin Scale)
-- ============================================================================
DELETE FROM spawn2 WHERE id BETWEEN 46000001 AND 46000020;
DELETE FROM spawnentry WHERE spawngroupID BETWEEN 61000001 AND 61000020;
DELETE FROM spawngroup WHERE id BETWEEN 61000001 AND 61000020;
DELETE FROM npc_types WHERE id BETWEEN 999401 AND 999411;

INSERT INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana,
	gender, texture, helmtexture, size, loottable_id, merchant_id, npc_faction_id,
	npc_spells_id, attack_speed, STR, STA, AGI, DEX, WIS, _INT, CHA, MR, CR, DR, FR, PR, Corrup)
VALUES
	(999401, 'Spirit_of_Truth', '', 45, 485, 1, 33, 32767, 0, 0, 0, 0, 6, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25),
	(999402, 'Spirit_of_Wisdom', '', 45, 485, 1, 33, 32767, 0, 0, 0, 0, 6, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25),
	(999403, 'Velosk', 'the Bone Sculptor', 73, 60, 1, 1, 156000, 0, 0, 0, 0, 9, 92401, 0, 0, 0, 100, 255, 220, 180, 180, 200, 200, 100, 200, 150, 100, 150, 200, 100),
	(999404, 'a_shimmering_parchment', '', 1, 383, 61, 33, 30, 0, 0, 0, 0, 2, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25),
	(999405, 'a_stack_of_old_books', '', 1, 383, 61, 33, 30, 0, 0, 0, 0, 4, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25),
	(999406, 'a_dusty_grimoire', '', 1, 383, 61, 33, 30, 0, 0, 0, 0, 4, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25),
	(999407, 'a_discarded_water_bottle', '', 1, 383, 61, 33, 30, 0, 0, 0, 0, 2, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25),
	(999408, 'a_dusty_bone_pile', '', 1, 383, 61, 33, 30, 0, 0, 0, 0, 4, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25),
	(999409, 'a_dark_green_bush', '', 1, 463, 61, 33, 30, 0, 0, 0, 0, 6, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25),
	(999410, 'a_broadleaf_plant', '', 1, 463, 61, 33, 30, 0, 0, 0, 0, 6, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25),
	(999411, 'a_small_pile_of_scales', '', 1, 383, 61, 33, 30, 0, 0, 0, 0, 3, 0, 0, 0, 0, 100, 75, 75, 75, 75, 75, 75, 75, 25, 25, 25, 25, 25, 25);

INSERT INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
VALUES
	(61000001, 'CR_Spirit_of_Truth', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000002, 'CR_Spirit_of_Wisdom', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000003, 'CR_Parchment', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000004, 'CR_Books_NE_Water', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000005, 'CR_Dusty_Grimoire', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000006, 'CR_Water_Bottle', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000007, 'CR_Bone_Pile_1', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000008, 'CR_Bone_Pile_2', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000009, 'CR_Green_Bush', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000010, 'CR_Broadleaf_1', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000011, 'CR_Broadleaf_2', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0),
	(61000012, 'CR_Scale_Pile', 1, 0, 0, 0, 0, 0, 20000, 5000, 0, 0, 0);

INSERT INTO spawnentry (spawngroupID, npcID, chance, condition_value_filter, min_time, max_time, min_expansion, max_expansion)
VALUES
	(61000001, 999401, 100, -1, 0, 0, -1, -1),
	(61000002, 999402, 100, -1, 0, 0, -1, -1),
	(61000003, 999404, 100, -1, 0, 0, -1, -1),
	(61000004, 999405, 100, -1, 0, 0, -1, -1),
	(61000005, 999406, 100, -1, 0, 0, -1, -1),
	(61000006, 999407, 100, -1, 0, 0, -1, -1),
	(61000007, 999408, 100, -1, 0, 0, -1, -1),
	(61000008, 999408, 100, -1, 0, 0, -1, -1),
	(61000009, 999409, 100, -1, 0, 0, -1, -1),
	(61000010, 999410, 100, -1, 0, 0, -1, -1),
	(61000011, 999410, 100, -1, 0, 0, -1, -1),
	(61000012, 999411, 100, -1, 0, 0, -1, -1);

-- Locations: AZA (y,x,z) converted to EQEmu (x,y,z); z from live /loc data
-- or snapped to nearby NPC anchors in this zone.
INSERT INTO spawn2 (id, spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation, min_expansion, max_expansion, content_flags, content_flags_disabled)
VALUES
	-- Spirit of Truth: AZA (-592.35, 143.16, -12.31)
	(46000001, 61000001, 'crescent', 0, 143.16, -592.35, -12.31, 0, 600, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	-- Spirit of Wisdom: AZA (-886.09, -1268.01, -158.97)
	(46000002, 61000002, 'crescent', 0, -1268.01, -886.09, -158.97, 0, 600, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	-- Touch of the Six: AZA (-1396, -1430, -55) next to Tenish
	(46000003, 61000003, 'crescent', 0, -1430.0, -1396.0, -55.2, 0, 600, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	-- Veeshan's Children: NE water of the grove, AZA (+318, -942)
	(46000004, 61000004, 'crescent', 0, -942.0, 318.0, -150.0, 0, 600, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	-- The Ogres Come of Age: AZA (-1453, -1193, 116), Gekkdar's Haunt throne area
	(46000005, 61000005, 'crescent', 0, -1193.0, -1453.0, 114.0, 0, 600, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	-- Water bottle: AZA (-1642, -2387, -218), waterfall pond
	(46000006, 61000006, 'crescent', 0, -2387.0, -1642.0, -218.0, 0, 300, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	-- Bone piles: AZA (-1454, -1164, +113) and (-1355, -1230, +113)
	(46000007, 61000007, 'crescent', 0, -1164.0, -1454.0, 113.0, 0, 600, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	(46000008, 61000008, 'crescent', 0, -1230.0, -1355.0, 113.0, 0, 600, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	-- Green bush: AZA (-836, -2412), sporali cave (z snapped to nearby sourcap sporeling)
	(46000009, 61000009, 'crescent', 0, -2412.0, -836.0, -158.0, 0, 300, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	-- Broadleaf: AZA (-284.30, -879.98, -133.82) and (-321.33, -454.70, -105.88)
	(46000010, 61000010, 'crescent', 0, -879.98, -284.30, -133.82, 0, 300, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	(46000011, 61000011, 'crescent', 0, -454.70, -321.33, -105.88, 0, 300, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL),
	-- Drakkin scale: top floor of the Jade Dragon's Den (inn), z follows the
	-- zone's third-floor height pattern (snapped near Vunder's floor height)
	(46000012, 61000012, 'crescent', 0, -1500.0, -1560.0, 113.0, 0, 600, 0, 0, 0, 0, 0, 0, -1, -1, NULL, NULL);

-- Velosk: rare PH swap on the existing bone grafters of Vergalid Mines
-- (spawn groups 76316 / 76498 / 76539 currently only spawn 'a_bone_grafter'
-- at chance 50 each; shift to 97/3 so Velosk is a 3% rare on those points).
UPDATE spawnentry
SET chance = 97
WHERE spawngroupID IN (76316, 76498, 76539)
  AND npcID IN (404092, 404156, 404171);

-- Yuvill the Spirithunter (394256) spawns with texture 3 (invisible). The
-- Seeker's Spiritstaff has no see-invis click effect in this database, so
-- an invisible Yuvill would brick Heshyrr's Wisdom. Make him targetable;
-- his script still gates the step on carrying the staff.
UPDATE npc_types SET texture = 0 WHERE id = 394256;

DELETE FROM spawnentry
WHERE spawngroupID IN (76316, 76498, 76539)
  AND npcID = 999403;

INSERT INTO spawnentry (spawngroupID, npcID, chance, condition_value_filter, min_time, max_time, min_expansion, max_expansion)
VALUES
	(76316, 999403, 3, -1, 0, 0, -1, -1),
	(76498, 999403, 3, -1, 0, 0, -1, -1),
	(76539, 999403, 3, -1, 0, 0, -1, -1);

-- ============================================================================
-- SECTION C: LOOT
-- ============================================================================
DELETE FROM lootdrop_entries WHERE lootdrop_id BETWEEN 90000101 AND 90000105;
DELETE FROM lootdrop WHERE id BETWEEN 90000101 AND 90000105;
DELETE FROM loottable_entries WHERE lootdrop_id BETWEEN 90000101 AND 90000105;

INSERT INTO lootdrop (id, name, min_expansion, max_expansion, content_flags, content_flags_disabled)
VALUES
	(90000101, 'CR_Undead_Fisherman_Essence', -1, -1, NULL, NULL),
	(90000102, 'CR_Apothecary_Shelga_Pouch', -1, -1, NULL, NULL),
	(90000103, 'CR_Sporeling_Truffle', -1, -1, NULL, NULL),
	(90000104, 'CR_Spiderling_Egg', -1, -1, NULL, NULL),
	(90000105, 'CR_Farm_Undead_Locket', -1, -1, NULL, NULL);

INSERT INTO lootdrop_entries (lootdrop_id, item_id, item_charges, equip_item, chance, disabled_chance, trivial_min_level, trivial_max_level, multiplier, npc_min_level, npc_max_level, min_expansion, max_expansion, content_flags, content_flags_disabled)
VALUES
	(90000101, 84215, 1, 0, 100, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
	(90000102, 52636, 1, 0, 100, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
	(90000103, 52637, 1, 0, 55, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
	(90000104, 54657, 1, 0, 45, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
	(90000105, 84232, 1, 0, 25, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL);

-- Attach to existing loottables:
--   90141 an_undead_fisherman   90142 undead footman / risen elder
--   90171 sourcap sporeling     90173 sporeling        90148 spiderlings
DELETE FROM loottable_entries
WHERE loottable_id IN (90141, 92401, 90171, 90173, 90148)
  AND lootdrop_id BETWEEN 90000101 AND 90000105;

INSERT INTO loottable_entries (loottable_id, lootdrop_id, multiplier, droplimit, mindrop, probability)
VALUES
	(90141, 90000101, 1, 1, 1, 100),
	(92401, 90000102, 1, 1, 1, 100),
	(90171, 90000103, 1, 2, 1, 100),
	(90173, 90000103, 1, 2, 1, 100),
	(90148, 90000104, 1, 1, 1, 100),
	(90142, 90000105, 1, 1, 1, 100);

-- ============================================================================
-- SECTION D: TRADESKILL RECIPES (both combines are nofail quest steps)
-- ============================================================================
DELETE FROM tradeskill_recipe_entries WHERE recipe_id IN (991101, 991102);
DELETE FROM tradeskill_recipe WHERE id IN (991101, 991102);

INSERT INTO tradeskill_recipe (id, name, tradeskill, skillneeded, trivial, nofail, replace_container, notes, must_learn, learned_by_item_id, quest, enabled, min_expansion, max_expansion, content_flags, content_flags_disabled)
VALUES
	(991101, 'Drakkin Banner', 63, 0, 5, 1, 0, 'Prove Your Worth - combine in Drakkin Sewing Kit', 0, 0, 1, 1, -1, -1, NULL, NULL),
	(991102, 'Burning Torch', 63, 0, 5, 1, 0, 'Ithakis'' Challenge - combine in Flame-Sealed Box', 0, 0, 1, 1, -1, -1, NULL, NULL);

INSERT INTO tradeskill_recipe_entries (recipe_id, item_id, successcount, failcount, componentcount, salvagecount, iscontainer)
VALUES
	(991101, 84223, 0, 0, 1, 0, 0),   -- Banner Pattern
	(991101, 84224, 0, 0, 1, 0, 0),   -- Shimmering Dye
	(991101, 84225, 0, 0, 1, 0, 0),   -- Bolt of Fine Cloth
	(991101, 84226, 1, 0, 0, 0, 0),   -- -> Banner Cloth
	(991101, 84227, 0, 0, 0, 0, 1),   -- in Drakkin Sewing Kit (kept)
	(991102, 84205, 0, 0, 1, 0, 0),   -- Torch of the Red Lord
	(991102, 84206, 0, 0, 1, 0, 0),   -- Breath of the Red Lord
	(991102, 84228, 1, 0, 0, 0, 0),   -- -> Burning Torch of the Red Lord
	(991102, 84207, 0, 0, 0, 0, 1);   -- in Flame-Sealed Box (kept)

-- ============================================================================
-- SECTION E: DRAKKIN BREATH AA RANKS 14-15 (levels 70 / 75)
--   AA ability ids: 590 Atathus, 591 Draton'ra, 592 Osh'vir, 593 Venesh,
--                   594 Mysaphar, 595 Keikolin
--   Existing chains end at rank 13 (level_req 65): ids 20000/20013/20026/
--   20039/20052/20065 + 12. New rank 14 rows link onto those and rank 15
--   onto rank 14.
-- ============================================================================
DELETE FROM aa_ranks WHERE id BETWEEN 20078 AND 20089;

UPDATE aa_ranks SET next_id = 20078 WHERE id = 20012;  -- Atathus 13 -> 14
UPDATE aa_ranks SET next_id = 20080 WHERE id = 20025;  -- Draton'ra 13 -> 14
UPDATE aa_ranks SET next_id = 20082 WHERE id = 20038;  -- Osh'vir 13 -> 14
UPDATE aa_ranks SET next_id = 20084 WHERE id = 20051;  -- Venesh 13 -> 14
UPDATE aa_ranks SET next_id = 20086 WHERE id = 20064;  -- Mysaphar 13 -> 14
UPDATE aa_ranks SET next_id = 20088 WHERE id = 20077;  -- Keikolin 13 -> 14

INSERT INTO aa_ranks (id, upper_hotkey_sid, lower_hotkey_sid, title_sid, desc_sid, cost, level_req, spell, spell_type, recast_time, expansion, prev_id, next_id)
VALUES
	(20078, 5150, 5150, 5150, 5150, 0, 70, 11126, 256, 600, 13, 20012, 20079),
	(20079, 5150, 5150, 5150, 5150, 0, 75, 50009, 256, 600, 13, 20078, 0),
	(20080, 5165, 5165, 5165, 5165, 0, 70, 11141, 256, 600, 13, 20025, 20081),
	(20081, 5165, 5165, 5165, 5165, 0, 75, 50010, 256, 600, 13, 20080, 0),
	(20082, 5180, 5180, 5180, 5180, 0, 70, 11156, 256, 600, 13, 20038, 20083),
	(20083, 5180, 5180, 5180, 5180, 0, 75, 50011, 256, 600, 13, 20082, 0),
	(20084, 5195, 5195, 5195, 5195, 0, 70, 11171, 256, 600, 13, 20051, 20085),
	(20085, 5195, 5195, 5195, 5195, 0, 75, 50012, 256, 600, 13, 20084, 0),
	(20086, 5210, 5210, 5210, 5210, 0, 70, 11186, 256, 600, 13, 20064, 20087),
	(20087, 5210, 5210, 5210, 5210, 0, 75, 50013, 256, 600, 13, 20086, 0),
	(20088, 5225, 5225, 5225, 5225, 0, 70, 11201, 256, 600, 13, 20077, 20089),
	(20089, 5225, 5225, 5225, 5225, 0, 75, 50014, 256, 600, 13, 20088, 0);

-- ============================================================================
-- SECTION F: RANK-15 BREATH SPELLS (50009-50014)
--   Cloned from each lineage's rank-14 spell (11126/11141/11156/11171/11186/
--   11201) with damage scaled ~12% beyond (614->692, 462->521), matching the
--   544->614 progression of ranks 13->14.
-- ============================================================================
DROP TEMPORARY TABLE IF EXISTS tmp_spell_clone;
CREATE TEMPORARY TABLE tmp_spell_clone AS SELECT * FROM spells_new WHERE id = 11126;
UPDATE tmp_spell_clone SET id = 50009, effect_base_value1 = -692, effect_base_value2 = -521;
INSERT INTO spells_new SELECT * FROM tmp_spell_clone WHERE NOT EXISTS (SELECT 1 FROM spells_new WHERE id = 50009);
DROP TEMPORARY TABLE tmp_spell_clone;

DROP TEMPORARY TABLE IF EXISTS tmp_spell_clone;
CREATE TEMPORARY TABLE tmp_spell_clone AS SELECT * FROM spells_new WHERE id = 11141;
UPDATE tmp_spell_clone SET id = 50010, effect_base_value1 = -692, effect_base_value2 = -521;
INSERT INTO spells_new SELECT * FROM tmp_spell_clone WHERE NOT EXISTS (SELECT 1 FROM spells_new WHERE id = 50010);
DROP TEMPORARY TABLE tmp_spell_clone;

DROP TEMPORARY TABLE IF EXISTS tmp_spell_clone;
CREATE TEMPORARY TABLE tmp_spell_clone AS SELECT * FROM spells_new WHERE id = 11156;
UPDATE tmp_spell_clone SET id = 50011, effect_base_value1 = -692, effect_base_value2 = -521;
INSERT INTO spells_new SELECT * FROM tmp_spell_clone WHERE NOT EXISTS (SELECT 1 FROM spells_new WHERE id = 50011);
DROP TEMPORARY TABLE tmp_spell_clone;

DROP TEMPORARY TABLE IF EXISTS tmp_spell_clone;
CREATE TEMPORARY TABLE tmp_spell_clone AS SELECT * FROM spells_new WHERE id = 11171;
UPDATE tmp_spell_clone SET id = 50012, effect_base_value1 = -692, effect_base_value2 = -521;
INSERT INTO spells_new SELECT * FROM tmp_spell_clone WHERE NOT EXISTS (SELECT 1 FROM spells_new WHERE id = 50012);
DROP TEMPORARY TABLE tmp_spell_clone;

DROP TEMPORARY TABLE IF EXISTS tmp_spell_clone;
CREATE TEMPORARY TABLE tmp_spell_clone AS SELECT * FROM spells_new WHERE id = 11186;
UPDATE tmp_spell_clone SET id = 50013, effect_base_value1 = -692, effect_base_value2 = -521;
INSERT INTO spells_new SELECT * FROM tmp_spell_clone WHERE NOT EXISTS (SELECT 1 FROM spells_new WHERE id = 50013);
DROP TEMPORARY TABLE tmp_spell_clone;

DROP TEMPORARY TABLE IF EXISTS tmp_spell_clone;
CREATE TEMPORARY TABLE tmp_spell_clone AS SELECT * FROM spells_new WHERE id = 11201;
UPDATE tmp_spell_clone SET id = 50014, effect_base_value1 = -692, effect_base_value2 = -521;
INSERT INTO spells_new SELECT * FROM tmp_spell_clone WHERE NOT EXISTS (SELECT 1 FROM spells_new WHERE id = 50014);
DROP TEMPORARY TABLE tmp_spell_clone;

-- ============================================================================
-- SECTION G: NPC MATCH LISTS
--   target_name is display-only; deliver/speak/kill/loot matching uses
--   npc_match_list (NPC ids or partial name fragments). Without it,
--   deliver/speak activities match ANY npc.
-- ============================================================================
UPDATE task_activities SET npc_match_list = '394187' WHERE taskid = 6802 AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394227' WHERE taskid = 505746 AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394187' WHERE taskid = 505746 AND activityid = 2;
UPDATE task_activities SET npc_match_list = '394187' WHERE taskid = 600240 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394114' WHERE taskid = 600241 AND activityid IN (0, 2);
UPDATE task_activities SET npc_match_list = 'Councilmember' WHERE taskid = 600241 AND activityid = 3;
UPDATE task_activities SET npc_match_list = '999401' WHERE taskid = 600242 AND activityid = 0;
UPDATE task_activities SET npc_match_list = '999402' WHERE taskid = 600242 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394256' WHERE taskid = 600242 AND activityid = 2;
UPDATE task_activities SET npc_match_list = '394010' WHERE taskid = 600242 AND activityid = 3;
UPDATE task_activities SET npc_match_list = '394255' WHERE taskid = 600243 AND activityid = 0;
UPDATE task_activities SET npc_match_list = 'a_training_dummy' WHERE taskid = 600243 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394161' WHERE taskid = 600243 AND activityid IN (3, 4);
UPDATE task_activities SET npc_match_list = '394192' WHERE taskid = 600243 AND activityid = 5;
UPDATE task_activities SET npc_match_list = '394179' WHERE taskid = 600244 AND activityid = 3;
UPDATE task_activities SET npc_match_list = '394123' WHERE taskid = 600245 AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394142' WHERE taskid = 600245 AND activityid = 3;
UPDATE task_activities SET npc_match_list = '394111' WHERE taskid = 600246 AND activityid = 3;
UPDATE task_activities SET npc_match_list = 'an_undead_fisherman' WHERE taskid = 600247 AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394183' WHERE taskid = 600247 AND activityid = 2;
UPDATE task_activities SET npc_match_list = '394186' WHERE taskid = 600247 AND activityid = 3;
UPDATE task_activities SET npc_match_list = 'sporeling' WHERE taskid = 600249 AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394178' WHERE taskid = 600249 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394178' WHERE taskid = 600250 AND activityid = 1;
UPDATE task_activities SET npc_match_list = 'spiderling' WHERE taskid = 600251 AND activityid IN (0, 1);
UPDATE task_activities SET npc_match_list = 'Canyon_Queen' WHERE taskid = 600251 AND activityid = 2;
UPDATE task_activities SET npc_match_list = '394107' WHERE taskid = 600251 AND activityid = 3;
UPDATE task_activities SET npc_match_list = 'Apothecary_Shelga' WHERE taskid = 600252 AND activityid IN (0, 1);
UPDATE task_activities SET npc_match_list = '394027' WHERE taskid = 600252 AND activityid = 2;
UPDATE task_activities SET npc_match_list = '394119' WHERE taskid = 600253 AND activityid = 1;
UPDATE task_activities SET npc_match_list = 'a_skeletal_ogre' WHERE taskid = 600254 AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394119' WHERE taskid = 600254 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394037' WHERE taskid = 600255 AND activityid = 1;
UPDATE task_activities SET npc_match_list = 'undead' WHERE taskid = 600256 AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394037' WHERE taskid = 600256 AND activityid = 1;
UPDATE task_activities SET npc_match_list = 'a_training_dummy' WHERE taskid = 600272 AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394015' WHERE taskid = 600272 AND activityid = 1;
UPDATE task_activities SET npc_match_list = 'Velosk' WHERE taskid IN (600260, 600262, 600264, 600266, 600268, 600270) AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394075' WHERE taskid = 600260 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394080' WHERE taskid = 600262 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394201' WHERE taskid = 600264 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394118' WHERE taskid = 600266 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394261' WHERE taskid = 600268 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394258' WHERE taskid = 600270 AND activityid = 1;
UPDATE task_activities SET npc_match_list = 'Kellet' WHERE taskid IN (600261, 600263, 600265, 600267, 600269, 600271) AND activityid = 0;
UPDATE task_activities SET npc_match_list = '394075' WHERE taskid = 600261 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394080' WHERE taskid = 600263 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394201' WHERE taskid = 600265 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394118' WHERE taskid = 600267 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394261' WHERE taskid = 600269 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394258' WHERE taskid = 600271 AND activityid = 1;

-- TradeSkill activities match on the recipe id carried in item_id_list.
UPDATE task_activities SET item_id_list = '991101' WHERE taskid = 600241 AND activityid = 1;
UPDATE task_activities SET item_id_list = '991102' WHERE taskid = 600243 AND activityid = 2;

-- Match-list delimiter is '|', not ';'.
UPDATE task_activities SET item_id_list = REPLACE(item_id_list, ';', '|')
WHERE taskid IN (2,505746,6802,600240,600241,600242,600243,600244,600245,600246,
                 600247,600248,600249,600250,600251,600252,600253,600254,600255,
                 600256,600260,600261,600262,600263,600264,600265,600266,600267,
                 600268,600269,600270,600271,600272);
UPDATE task_activities SET npc_match_list = 'undead|skeletal' WHERE taskid = 600256 AND activityid = 0;
