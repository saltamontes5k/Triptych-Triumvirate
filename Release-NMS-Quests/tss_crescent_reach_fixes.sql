-- ============================================================================
-- TSS Crescent Reach: Phase 1 fixes for existing content
-- Server: NMS (peq @ 127.0.0.1)  Zone: crescent (id 55), moors (id 238)
-- Idempotent: safe to re-run.
--
-- 1. Task 2  "Welcome to Crescent Reach" - activities were placeholder data
--    (kill orcs in Gorge of King Xorbb / locate Antonica Spires). Rewritten
--    to the live flow: find Masters' Hall -> speak Initiate Dakkan ->
--    speak Innkeeper Fathus.
-- 2. Task 505746 - retitled to "Getting to Know You: The City Charter" and
--    activities rewritten (live quest 3605): speak Hemfar -> collect the
--    charter (57974) from the bookshelf -> deliver it to Mystrana.
-- 3. Task 6802 "Getting to Know You: The Council's Aid" - referenced by
--    #Innkeeper_Fathus.pl but did not exist. Created (live quest 3674).
-- 4. Zone references in tasks 600070-600104: '394'/'395' are The Grey /
--    The Nest in this database. Kills and loot happen in crescent (55) and
--    moors (238).
-- 5. "Oh Brother!" (Boawb -> Reakash) created as task 600248 - the elixir
--    hand-off had no task and no hand-in target.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Task 2: Welcome to Crescent Reach
-- ----------------------------------------------------------------------------
UPDATE tasks
SET title        = 'Welcome to Crescent Reach',
    description  = 'Familiarize yourself with the city of Crescent Reach.',
    type         = 2,
    duration     = 0,
    duration_code = 0,
    min_level    = 1,
    max_level    = 85,
    repeatable   = 1,
    cash_reward  = 300,   -- 3 gold
    exp_reward   = 5000,
    enabled      = 1
WHERE id = 2;

DELETE FROM task_activities WHERE taskid = 2;

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, zones, zone_version, optional,
	 min_x, min_y, min_z, max_x, max_y, max_z)
VALUES
	-- Find the Masters' Hall (guild building at the bottom of the path).
	-- Explore box around the guild hall: AZA loc (-450, -1150, -135) y,x,z
	-- -> EQEmu x=-1150, y=-450, z=-135
	(2, 0, 0, 1, 5, 'the Masters Hall', 1, 1,
	 'Find the Masters'' Hall down the path from the Dragon''s Grove',
	 '55', 0, 0, -1230, -530, -215, -1070, -370, -55),
	(2, 1, 0, 2, 4, 'Initiate Dakkan', 1, 1,
	 'Speak with Initiate Dakkan', '55', 0, 0, 0, 0, 0, 0, 0, 0),
	(2, 2, 0, 3, 4, 'Innkeeper Fathus', 1, 1,
	 'Speak with Innkeeper Fathus in the Jade Dragon''s Den', '55', 0, 0, 0, 0, 0, 0, 0, 0);

-- ----------------------------------------------------------------------------
-- 2. Task 505746: Getting to Know You: The City Charter
-- ----------------------------------------------------------------------------
UPDATE tasks
SET title        = 'Getting to Know You: The City Charter',
    description  = 'Learn how the city of Crescent Reach is run by retrieving the city charter.',
    type         = 2,
    duration     = 0,
    duration_code = 0,
    min_level    = 1,
    max_level    = 85,
    repeatable   = 1,
    cash_reward  = 0,
    exp_reward   = 10000,
    enabled      = 1
WHERE id = 505746;

DELETE FROM task_activities WHERE taskid = 505746;

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(505746, 0, 0, 1, 4, 'Librarian Hemfar', 1, 1,
	 'Speak with Librarian Hemfar about the charter', '', '55', 0, 0),
	(505746, 1, 0, 2, 13, '', 0, 1,
	 'Take a copy of the Crescent Reach City Charter from the bookshelf upstairs',
	 '57974', '55', 0, 0),
	(505746, 2, 0, 3, 1, 'Council Aide Mystrana', 1, 1,
	 'Return the City Charter to Council Aide Mystrana', '', '55', 0, 0);

-- ----------------------------------------------------------------------------
-- 3. Task 6802: Getting to Know You: The Council's Aid
-- ----------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 6802;
DELETE FROM tasks WHERE id = 6802;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(6802, 2, 0, 0, 'Getting to Know You: The Council''s Aid',
	 'Innkeeper Fathus has asked you to deliver a note of introduction to Council Aide Mystrana.',
	 '', NULL, 200, 5000, 0, 0, 0, 1, 85, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(6802, 0, 0, 1, 1, 'Council Aide Mystrana', 1, 1,
	 'Deliver the Crescent Citizen''s Declaration to Council Aide Mystrana',
	 NULL, '55', 0, 0);

-- ----------------------------------------------------------------------------
-- 4. Fix zone references on the existing custom tasks.
--    crescent = 55 (The Hollows content is merged into the city zone),
--    moors    = 238 (Blightfire Moors).
-- ----------------------------------------------------------------------------
UPDATE task_activities
SET zones = '55'
WHERE taskid IN (600070, 600071, 600072, 600073, 600074, 600075,
                 600090, 600091, 600092, 600093,
                 600100, 600101, 600102, 600103, 600104)
  AND zones = '394';

UPDATE task_activities
SET zones = '238'
WHERE taskid IN (600070, 600071, 600072,
                 600102, 600103, 600104)
  AND zones = '395';

-- ----------------------------------------------------------------------------
-- 5. Task 600248: Oh Brother! (Disgruntled Boawb -> Councilmember Reakash)
--    The elixir (85092) turn-in previously had no task or hand-in target.
-- ----------------------------------------------------------------------------
DELETE FROM task_activities WHERE taskid = 600248;
DELETE FROM tasks WHERE id = 600248;

INSERT INTO tasks
	(id, type, duration, duration_code, title, description, reward_text,
	 reward_id_list, cash_reward, exp_reward, reward_method, reward_points,
	 reward_point_type, min_level, max_level, level_spread, min_players,
	 max_players, repeatable, faction_reward, completion_emote,
	 replay_timer_group, replay_timer_seconds, request_timer_group,
	 request_timer_seconds, dz_template_id, lock_activity_id, faction_amount,
	 enabled)
VALUES
	(600248, 2, 0, 0, 'Oh Brother!',
	 'Disgruntled Boawb wants you to deliver an elixir to Councilmember Reakash on his behalf.',
	 '', NULL, 0, 10000, 0, 0, 0, 1, 85, 0, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities
	(taskid, activityid, req_activity_id, step, activitytype, target_name,
	 goalmethod, goalcount, description_override, item_id_list, zones, zone_version, optional)
VALUES
	(600248, 0, 0, 1, 1, 'Councilmember Reakash', 1, 1,
	 'Deliver Atathus` Elixir of Life to Councilmember Reakash',
	 NULL, '55', 0, 0);

-- Deliver activities must pin the expected item via item_id_list, else any
-- item handed to the target npc completes them.
UPDATE task_activities SET item_id_list = '85088' WHERE taskid = 6802 AND activityid = 0;
UPDATE task_activities SET item_id_list = '57974' WHERE taskid = 505746 AND activityid = 2;

-- Task 2 speak steps + Oh Brother! deliver: pin NPC and item.
UPDATE task_activities SET npc_match_list = '394147' WHERE taskid = 2 AND activityid = 1;
UPDATE task_activities SET npc_match_list = '394185' WHERE taskid = 2 AND activityid = 2;
UPDATE task_activities SET npc_match_list = '394111', item_id_list = '85092' WHERE taskid = 600248 AND activityid = 0;

-- Match-list delimiter is '|', not ';'.
UPDATE task_activities SET item_id_list = REPLACE(item_id_list, ';', '|')
WHERE taskid IN (2,505746,6802,600240,600241,600242,600243,600244,600245,600246,
                 600247,600248,600249,600250,600251,600252,600253,600254,600255,
                 600256,600260,600261,600262,600263,600264,600265,600266,600267,
                 600268,600269,600270,600271,600272);
UPDATE task_activities SET npc_match_list = 'undead|skeletal' WHERE taskid = 600256 AND activityid = 0;
