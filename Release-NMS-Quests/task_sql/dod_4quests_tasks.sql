-- ---------------------------------------------------------------------------
-- Depths of Darkhollow quest tasks - NMS server
--
-- Tasks:
--   500300 A Rogue's Trust          DoD Level 68 Spell #1
--   500301 The Lost Notebook        DoD Level 69 Spell #1
--   500302 Preemptive Strike        DoD Level 70 Spell #1
--   500303 The Depths of Darkhollow werewolf-skull solo task
--
-- Rewards are script-summoned with class splits, so reward_id_list is empty.
-- Idempotent: explicit primary keys + INSERT IGNORE, so re-running is a no-op.
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO `tasks`
	(`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,`min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,`request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,`faction_amount`,`enabled`)
VALUES
	(500300, 2, 21600, 0, 'A Rogue\'s Trust', '[1,Seek out the great scout Meldrek at his post on the field outside the city of Xill and ask him about an alternate entrance into the city.][2,Lay waste to twenty-five drachnids in the hidden lairs beyond Xill.][3,Tear out four drachnid hearts for proof of their deaths.][4,Return to Kelliad with the drachnid hearts to claim your reward.]', 'A Warped Mask for melee or a Pain-Suffused Mask for casters.', '', 0, 0, 0, 0, 0, 65, 125, 0, 0, 0, 1, 0, 'You hand Kelliad the four drachnid hearts. He nods slowly and presses a mask into your hands.', 0, 0, 0, 0, 0, -1, 0, 1),
	(500301, 2, 21600, 0, 'The Lost Notebook', '[1,Find the secret entrance into the Hive.][2,Collect the nine sections of Cicero\'s Notebook from the drachnids of the Hive and return them to Brovil Pallivineg.]', 'A Hive Sentinel Collar or a Drachnid Collective Mask.', '', 0, 0, 0, 0, 0, 69, 125, 0, 0, 0, 1, 0, 'Brovil Pallivineg fits the last section into place, restoring Cicero\'s great work.', 0, 0, 0, 0, 0, -1, 0, 1),
	(500302, 2, 7200, 0, 'Preemptive Strike', '[1,Enter the Nargilor Pits of Illsalin and find where Draygun keeps his living shiliskin captives.][2,Find the Living Shiliskin Captives.][3,Clear your way to the Guardian of the Pit.][4,Kill ten Captured Shilgrave Legion Soldiers.][5,Return to Jarzarrad with news of your victory.]', 'Cavefish Goggles or a Faithful Templar Belt.', '', 0, 0, 0, 0, 0, 70, 125, 0, 0, 0, 1, 0, 'Jarzarrad nods slowly, pleased. Emperor Draygun\'s power will wane for want of sustenance.', 0, 0, 0, 0, 0, -1, 0, 1),
	(500303, 2, 0, 0, 'The Depths of Darkhollow', '[1,Find Fibblebrap in the Creep of Corathus.][2,Learn the fate of Elder Longshadow in Undershore.][3,Survive the Korlach Leviathan below Stoneroot Falls.][4,Fulfill Jarzarrad\'s Prophecy in the Ruins of Illsalin.][5,Rescue the Ecologist of Expedition 328 from the Hive.]', 'An Ancient Werewolf Skull.', '', 0, 0, 0, 0, 0, 70, 95, 0, 0, 0, 1, 0, 'The waters stir and the spirit of Den Lord Rakban rises, manifesting his power through you.', 0, 0, 0, 0, 0, -1, 0, 1);