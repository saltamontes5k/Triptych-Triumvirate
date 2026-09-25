-- ---------------------------------------------------------------------------
-- Depths of Darkhollow quest task activities - NMS server
--
-- Matches the tasks in dod_4quests_tasks.sql (500300 - 500303).
-- Scripted steps (activitytype 255) are advanced by the event NPC scripts.
-- 500300 act0 (type 4) auto-advances when hailing #Meldrek (358031).
-- Idempotent: explicit primary keys + INSERT IGNORE, so re-running is a no-op.
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO `task_activities`
	(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,`min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
	(500300, 0, -1, 1, 4, '', 0, 1, 'Seek out Meldrek at his post outside the city of Xill and ask him about an alternate entrance into the city.', '358031', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(500300, 1, -1, 2, 2, 'Drachnids', 0, 25, '', '359012|359013|359017|359018|359019|359020|359021|359022|359023|359024|359025|359027|359029', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '0', '359', -1, 0, 0),
	(500300, 2, -1, 3, 3, 'a drachnid', 0, 4, '', '', '83363|85029', 'Drachnid Heart', 0, 0, 0, 0, 0, 0, 0, '-1', '', '359', -1, 0, 0),
	(500300, 3, -1, 4, 255, '', 0, 1, 'Return to Kelliad with the drachnid hearts to claim your reward.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(500301, 0, -1, 1, 255, '', 0, 1, 'Find the secret entrance into the Hive.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '354', -1, 0, 0),
	(500301, 1, -1, 2, 255, '', 0, 1, 'Collect the nine sections of Cicero\'s Notebook from the drachnids of the Hive and return them to Brovil Pallivineg.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '365', -1, 0, 0),
	(500302, 0, -1, 1, 255, '', 0, 1, 'Enter the Nargilor Pits of Illsalin and find where Draygun keeps his living shiliskin captives.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	(500302, 1, -1, 2, 255, '', 0, 1, 'Find the Living Shiliskin Captives.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	(500302, 2, -1, 3, 255, '', 0, 1, 'Clear your way to the Guardian of the Pit.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	(500302, 3, -1, 4, 255, '', 0, 1, 'Kill ten Captured Shilgrave Legion Soldiers.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	(500302, 4, -1, 5, 255, '', 0, 1, 'Return to Jarzarrad with news of your victory.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '362', -1, 0, 0),
	(500303, 0, -1, 1, 255, '', 0, 1, 'Find Fibblebrap in the Creep of Corathus.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '365', -1, 0, 0),
	(500303, 1, -1, 2, 255, '', 0, 1, 'Learn the fate of Elder Longshadow in Undershore.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '362', -1, 0, 0),
	(500303, 2, -1, 3, 255, '', 0, 1, 'Survive the Korlach Leviathan below Stoneroot Falls.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 0, 0),
	(500303, 3, -1, 4, 255, '', 0, 1, 'Fulfill Jarzarrad\'s Prophecy in the Ruins of Illsalin.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '347', -1, 0, 0),
	(500303, 4, -1, 5, 255, '', 0, 1, 'Rescue the Ecologist of Expedition 328 from the Hive.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '354', -1, 0, 0),
	(500303, 5, -1, 5, 255, '', 0, 1, 'Wrap all werewolf skull fragments in the funeral shroud of Den Lord Rakban.', '', '', '', 0, 0, 0, 0, 0, 0, 0, '-1', '', '358', -1, 1, 0);