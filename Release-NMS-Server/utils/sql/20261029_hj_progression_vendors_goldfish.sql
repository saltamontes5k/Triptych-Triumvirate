-- Hero's Journey progression achievements + PoK vendor/Goldfish Flakes batch (2026-10-29).
-- Achievements: ids 9501000-9501015 under category 71 (The Hero's Journey / Progression),
--   one per NMS progression stage (%STAGE_PREREQUISITES in NMS_progression_utils.pl).
-- Criteria: ids 7000573-7000619, event_type 12 NpcNameKill (engine FNV-1a name hash +
--   zone id; algorithm validated against production criteria 266/267/268).
-- Rewards: sets 9508206-9508221, rewards 9540412-9540443 (AA max(1,points/10) +
--   5 Triunes of Fate, the post-v260 standard).
-- Vendors/loot: Bindral Argaff 202431 merchant 7010100 (11 level-1 ENC scrolls),
--   Phinigel Autropos loottable 10831 -> guaranteed Goldfish Flakes lootdrop 1520008200,
--   Goldfish Flakes 2% zone-wide drop via global_loot 178901 (kedge 64 | powater 216 |
--   thalassius 417), loottable 1520009314 / lootdrop 1520009414.
-- Kedge faction audit: all 101 spawned kedge monsters already resolve to primary faction
--   299 (npc_faction 77); no faction changes required. Only exception: custom quest NPC
--   Herald_of_the_Triumvirate 1120000805 (faction 0), a hail NPC - deliberately left.
-- Manifest twin: entries 261-263 in database_update_manifest_custom.cpp.
SET NAMES utf8mb4;

-- entry 261: 20261029_hj_progression_achievements
INSERT INTO `achievements` (`id`, `name`, `description`, `icon_id`, `points`, `has_reward`, `client_flag`, `version`, `reset_on_version_change`, `enabled`) VALUES
(9501000, 'The First Dragons Fall', 'Slay Lord Nagafen and Lady Vox to prove Norrath ready for the Ruins of Kunark.', 0, 5, 1, 0, 0, 1, 1),
(9501001, 'The Dragons of Kunark', 'Slay Trakanon, Gorenaire, Severilous and Talendor to unlock the Scars of Velious.', 0, 10, 1, 0, 0, 1, 1),
(9501002, 'The Dragons of Velious', 'Slay Klandicar, Zlandicar, Wuoshi, Dozekar the Cursed and Kelorek`Dar to unlock the Shadows of Luclin.', 0, 10, 1, 0, 0, 1, 1),
(9501003, 'The Moon Falls', 'Slay Thought Horror Overfiend, The Insanity Crawler, Grieg Veneficus, Xerkizh the Creator and Emperor Ssraeshza to unlock the Planes of Power.', 0, 10, 1, 0, 0, 1, 1),
(9501004, 'Gates of Discord', 'Slay Saryrn in the Plane of Torment to unlock the Gates of Discord.', 0, 10, 1, 0, 0, 1, 1),
(9501005, 'Omens of War', 'Slay Tunat`Muram Cuu Vauax in Tacvi to unlock the Omens of War.', 0, 15, 1, 0, 0, 1, 1),
(9501006, 'Dragons of Norrath', 'Slay the elemental gods, the Rathe Council and Agnarr the Storm Lord to unlock the Dragons of Norrath.', 0, 10, 1, 0, 0, 1, 1),
(9501007, 'Lost Dungeons of Norrath', 'Slay the elemental gods, the Rathe Council and Agnarr the Storm Lord to unlock the Lost Dungeons of Norrath.', 0, 10, 1, 0, 0, 1, 1),
(9501008, 'Depths of Darkhollow', 'Slay Tunat`Muram Cuu Vauax and Warlord Imal Ojun to unlock the Depths of Darkhollow.', 0, 15, 1, 0, 0, 1, 1),
(9501009, 'Prophecy of Ro', 'Slay the six MPG chamber Masters, Overlord Mata Muram, Vishimtar the Fallen and Mayong Mistmoore to unlock the Prophecy of Ro.', 0, 25, 1, 0, 0, 1, 1),
(9501010, 'The Serpent''s Spine', 'Cut down the Deathknell Enforcer to unlock the Serpent''s Spine.', 0, 15, 1, 0, 0, 1, 1),
(9501011, 'The Buried Sea', 'Slay Dyn`Leth in Ashengate to unlock the Buried Sea.', 0, 15, 1, 0, 0, 1, 1),
(9501012, 'Secrets of Faydwer', 'Slay Solusek Ro and Mayong Mistmoore in Solteris to unlock the Secrets of Faydwer.', 0, 25, 1, 0, 0, 1, 1),
(9501013, 'Seeds of Destruction', 'Slay Kerafyrm the Sleeper in both Sleeper''s Tomb and Crystallos to unlock the Seeds of Destruction.', 0, 25, 1, 0, 0, 1, 1),
(9501014, 'Fabled Nagafen''s Lair', 'Slay Quarm at the end of the Plane of Time.', 0, 25, 1, 0, 0, 1, 1),
(9501015, 'Underfoot', 'Defeat The First Creation in Convorteum to complete the Hero''s Journey.', 0, 50, 1, 0, 0, 1, 1) ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `points`=VALUES(`points`), `has_reward`=VALUES(`has_reward`), `enabled`=VALUES(`enabled`);

INSERT INTO `achievement_criteria` (`id`, `achievement_id`, `component_type`, `component_sequence`, `component_id`, `event_type`, `progress_mode`, `behavior`, `target_id`, `target_id2`, `target_value`, `required_count`, `enabled`) VALUES
(7000573, 9501000, 1, 1, 95010001, 12, 3, 0, 2706819716, 32, 0, 1, 1),
(7000574, 9501000, 1, 2, 95010002, 12, 3, 0, 3715162668, 73, 0, 1, 1),
(7000575, 9501001, 1, 1, 95010003, 12, 3, 0, 603887181, 89, 0, 1, 1),
(7000576, 9501001, 1, 2, 95010004, 12, 3, 0, 1363294263, 86, 0, 1, 1),
(7000577, 9501001, 1, 3, 95010005, 12, 3, 0, 609260812, 94, 0, 1, 1),
(7000578, 9501001, 1, 4, 95010006, 12, 3, 0, 3406750186, 91, 0, 1, 1),
(7000579, 9501002, 1, 1, 95010007, 12, 3, 0, 3453223472, 120, 0, 1, 1),
(7000580, 9501002, 1, 2, 95010008, 12, 3, 0, 3144919919, 123, 0, 1, 1),
(7000581, 9501002, 1, 3, 95010009, 12, 3, 0, 4275337928, 119, 0, 1, 1),
(7000582, 9501002, 1, 4, 95010010, 12, 3, 0, 1744983248, 124, 0, 1, 1),
(7000583, 9501002, 1, 5, 95010011, 12, 3, 0, 3493263801, 117, 0, 1, 1),
(7000584, 9501003, 1, 1, 95010012, 12, 3, 0, 1809363542, 164, 0, 1, 1),
(7000585, 9501003, 1, 2, 95010013, 12, 3, 0, 1452295705, 179, 0, 1, 1),
(7000586, 9501003, 1, 3, 95010014, 12, 3, 0, 15874477, 163, 0, 1, 1),
(7000587, 9501003, 1, 4, 95010015, 12, 3, 0, 3944863641, 162, 0, 1, 1),
(7000588, 9501003, 1, 5, 95010016, 12, 3, 0, 3306848999, 162, 0, 1, 1),
(7000589, 9501004, 1, 1, 95010017, 12, 3, 0, 941980112, 207, 0, 1, 1),
(7000590, 9501005, 1, 1, 95010018, 12, 3, 0, 3310419567, 298, 0, 1, 1),
(7000591, 9501006, 1, 1, 95010019, 12, 3, 0, 3095601045, 215, 0, 1, 1),
(7000592, 9501006, 1, 2, 95010020, 12, 3, 0, 4278813304, 217, 0, 1, 1),
(7000593, 9501006, 1, 3, 95010021, 12, 3, 0, 1565506679, 216, 0, 1, 1),
(7000594, 9501006, 1, 4, 95010022, 12, 3, 0, 1357821557, 222, 0, 1, 1),
(7000595, 9501006, 1, 5, 95010023, 12, 3, 0, 1915976437, 209, 0, 1, 1),
(7000596, 9501007, 1, 1, 95010024, 12, 3, 0, 3095601045, 215, 0, 1, 1),
(7000597, 9501007, 1, 2, 95010025, 12, 3, 0, 4278813304, 217, 0, 1, 1),
(7000598, 9501007, 1, 3, 95010026, 12, 3, 0, 1565506679, 216, 0, 1, 1),
(7000599, 9501007, 1, 4, 95010027, 12, 3, 0, 1357821557, 222, 0, 1, 1),
(7000600, 9501007, 1, 5, 95010028, 12, 3, 0, 1915976437, 209, 0, 1, 1),
(7000601, 9501008, 1, 1, 95010029, 12, 3, 0, 3310419567, 298, 0, 1, 1),
(7000602, 9501008, 1, 2, 95010030, 12, 3, 0, 713511117, 273, 0, 1, 1),
(7000603, 9501009, 1, 1, 95010031, 12, 3, 0, 2586647692, 304, 0, 1, 1),
(7000604, 9501009, 1, 2, 95010032, 12, 3, 0, 4185311589, 305, 0, 1, 1),
(7000605, 9501009, 1, 3, 95010033, 12, 3, 0, 923377503, 306, 0, 1, 1),
(7000606, 9501009, 1, 4, 95010034, 12, 3, 0, 1313857469, 307, 0, 1, 1),
(7000607, 9501009, 1, 5, 95010035, 12, 3, 0, 1276865065, 308, 0, 1, 1),
(7000608, 9501009, 1, 6, 95010036, 12, 3, 0, 2769712176, 309, 0, 1, 1),
(7000609, 9501009, 1, 7, 95010037, 12, 3, 0, 1971141215, 317, 0, 1, 1),
(7000610, 9501009, 1, 8, 95010038, 12, 3, 0, 1888218743, 343, 0, 1, 1),
(7000611, 9501009, 1, 9, 95010039, 12, 3, 0, 1149369763, 351, 0, 1, 1),
(7000612, 9501010, 1, 1, 95010040, 12, 3, 0, 952335429, 381, 0, 1, 1),
(7000613, 9501011, 1, 1, 95010041, 12, 3, 0, 3443005415, 406, 0, 1, 1),
(7000614, 9501012, 1, 1, 95010042, 12, 3, 0, 1788093228, 421, 0, 1, 1),
(7000615, 9501012, 1, 2, 95010043, 12, 3, 0, 1149369763, 421, 0, 1, 1),
(7000616, 9501013, 1, 1, 95010044, 12, 3, 0, 1019833904, 128, 0, 1, 1),
(7000617, 9501013, 1, 2, 95010045, 12, 3, 0, 1019833904, 446, 0, 1, 1),
(7000618, 9501014, 1, 1, 95010046, 12, 3, 0, 944042379, 223, 0, 1, 1),
(7000619, 9501015, 1, 1, 95010047, 12, 3, 0, 3495792815, 491, 0, 1, 1) ON DUPLICATE KEY UPDATE `component_sequence`=VALUES(`component_sequence`), `event_type`=VALUES(`event_type`), `progress_mode`=VALUES(`progress_mode`), `behavior`=VALUES(`behavior`), `target_id`=VALUES(`target_id`), `target_id2`=VALUES(`target_id2`), `enabled`=VALUES(`enabled`);

-- Display components: one per criterion (the loader requires every criterion's
-- (achievement_id, component_type, component_id) to resolve to a component row).
INSERT INTO `achievement_components` (`achievement_id`, `component_type`, `sequence`, `component_id`, `name`, `description`) VALUES
(9501000, 1, 1, 95010001, 'Defeat Lord_Nagafen', ''),
(9501000, 1, 2, 95010002, 'Defeat Lady_Vox', ''),
(9501001, 1, 1, 95010003, 'Defeat Trakanon', ''),
(9501001, 1, 2, 95010004, 'Defeat Gorenaire', ''),
(9501001, 1, 3, 95010005, 'Defeat Severilous', ''),
(9501001, 1, 4, 95010006, 'Defeat Talendor', ''),
(9501002, 1, 1, 95010007, 'Defeat Klandicar', ''),
(9501002, 1, 2, 95010008, 'Defeat Zlandicar', ''),
(9501002, 1, 3, 95010009, 'Defeat Wuoshi', ''),
(9501002, 1, 4, 95010010, 'Defeat Dozekar_the_Cursed', ''),
(9501002, 1, 5, 95010011, 'Defeat Kelorek`Dar', ''),
(9501003, 1, 1, 95010012, 'Defeat Thought_Horror_Overfiend', ''),
(9501003, 1, 2, 95010013, 'Defeat The_Insanity_Crawler', ''),
(9501003, 1, 3, 95010014, 'Defeat Grieg_Veneficus', ''),
(9501003, 1, 4, 95010015, 'Defeat Xerkizh_The_Creator', ''),
(9501003, 1, 5, 95010016, 'Defeat Emperor_Ssraeshza', ''),
(9501004, 1, 1, 95010017, 'Defeat Saryrn', ''),
(9501005, 1, 1, 95010018, 'Defeat Tunat`Muram_Cuu_Vauax', ''),
(9501006, 1, 1, 95010019, 'Defeat Xegony_the_Queen_of_Air', ''),
(9501006, 1, 2, 95010020, 'Defeat Fennin_Ro_the_Tyrant_of_Fire', ''),
(9501006, 1, 3, 95010021, 'Defeat Coirnav_the_Avatar_of_Water', ''),
(9501006, 1, 4, 95010022, 'Defeat A_Rathe_Councilman', ''),
(9501006, 1, 5, 95010023, 'Defeat Agnarr_the_Storm_Lord', ''),
(9501007, 1, 1, 95010024, 'Defeat Xegony_the_Queen_of_Air', ''),
(9501007, 1, 2, 95010025, 'Defeat Fennin_Ro_the_Tyrant_of_Fire', ''),
(9501007, 1, 3, 95010026, 'Defeat Coirnav_the_Avatar_of_Water', ''),
(9501007, 1, 4, 95010027, 'Defeat A_Rathe_Councilman', ''),
(9501007, 1, 5, 95010028, 'Defeat Agnarr_the_Storm_Lord', ''),
(9501008, 1, 1, 95010029, 'Defeat Tunat`Muram_Cuu_Vauax', ''),
(9501008, 1, 2, 95010030, 'Defeat Warlord_Imal_Ojun', ''),
(9501009, 1, 1, 95010031, 'Defeat Master_of_Hate', ''),
(9501009, 1, 2, 95010032, 'Defeat Master_of_Weaponry', ''),
(9501009, 1, 3, 95010033, 'Defeat Master_of_Foresight', ''),
(9501009, 1, 4, 95010034, 'Defeat Master_of_Specialization', ''),
(9501009, 1, 5, 95010035, 'Defeat Master_of_Adaptation', ''),
(9501009, 1, 6, 95010036, 'Defeat Master_of_Destruction', ''),
(9501009, 1, 7, 95010037, 'Defeat Overlord_Mata_Muram', ''),
(9501009, 1, 8, 95010038, 'Defeat Vishimtar_the_Fallen', ''),
(9501009, 1, 9, 95010039, 'Defeat Mayong_Mistmoore', ''),
(9501010, 1, 1, 95010040, 'Defeat Deathknell_Enforcer', ''),
(9501011, 1, 1, 95010041, 'Defeat Dyn`Leth', ''),
(9501012, 1, 1, 95010042, 'Defeat Solusek_Ro', ''),
(9501012, 1, 2, 95010043, 'Defeat Mayong_Mistmoore', ''),
(9501013, 1, 1, 95010044, 'Defeat Kerafyrm', ''),
(9501013, 1, 2, 95010045, 'Defeat Kerafyrm', ''),
(9501014, 1, 1, 95010046, 'Defeat Quarm', ''),
(9501015, 1, 1, 95010047, 'Defeat The_First_Creation', '') ON DUPLICATE KEY UPDATE `sequence`=VALUES(`sequence`), `name`=VALUES(`name`);

INSERT INTO `achievement_category_associations` (`category_id`, `sequence`, `achievement_id`, `display_text`) VALUES
(71, 2001, 9501000, ''),
(71, 2002, 9501001, ''),
(71, 2003, 9501002, ''),
(71, 2004, 9501003, ''),
(71, 2005, 9501004, ''),
(71, 2006, 9501005, ''),
(71, 2007, 9501006, ''),
(71, 2008, 9501007, ''),
(71, 2009, 9501008, ''),
(71, 2010, 9501009, ''),
(71, 2011, 9501010, ''),
(71, 2012, 9501011, ''),
(71, 2013, 9501012, ''),
(71, 2014, 9501013, ''),
(71, 2015, 9501014, ''),
(71, 2016, 9501015, '') ON DUPLICATE KEY UPDATE `sequence`=VALUES(`sequence`);
COMMIT;

-- entry 262: 20261029_hj_progression_rewards
INSERT INTO `rewards` (`reward_id`, `reward_type`, `reward_data_id`, `amount`, `description`, `enabled`) VALUES
(9540412, 2, 0, 1, '1 AA points for a 5-point achievement', 1),
(9540428, 4, 6, 5, '5 Triunes of Fate for a 5-point achievement', 1),
(9540413, 2, 0, 1, '1 AA points for a 10-point achievement', 1),
(9540429, 4, 6, 5, '5 Triunes of Fate for a 10-point achievement', 1),
(9540414, 2, 0, 1, '1 AA points for a 10-point achievement', 1),
(9540430, 4, 6, 5, '5 Triunes of Fate for a 10-point achievement', 1),
(9540415, 2, 0, 1, '1 AA points for a 10-point achievement', 1),
(9540431, 4, 6, 5, '5 Triunes of Fate for a 10-point achievement', 1),
(9540416, 2, 0, 1, '1 AA points for a 10-point achievement', 1),
(9540432, 4, 6, 5, '5 Triunes of Fate for a 10-point achievement', 1),
(9540417, 2, 0, 1, '1 AA points for a 15-point achievement', 1),
(9540433, 4, 6, 5, '5 Triunes of Fate for a 15-point achievement', 1),
(9540418, 2, 0, 1, '1 AA points for a 10-point achievement', 1),
(9540434, 4, 6, 5, '5 Triunes of Fate for a 10-point achievement', 1),
(9540419, 2, 0, 1, '1 AA points for a 10-point achievement', 1),
(9540435, 4, 6, 5, '5 Triunes of Fate for a 10-point achievement', 1),
(9540420, 2, 0, 1, '1 AA points for a 15-point achievement', 1),
(9540436, 4, 6, 5, '5 Triunes of Fate for a 15-point achievement', 1),
(9540421, 2, 0, 2, '2 AA points for a 25-point achievement', 1),
(9540437, 4, 6, 5, '5 Triunes of Fate for a 25-point achievement', 1),
(9540422, 2, 0, 1, '1 AA points for a 15-point achievement', 1),
(9540438, 4, 6, 5, '5 Triunes of Fate for a 15-point achievement', 1),
(9540423, 2, 0, 1, '1 AA points for a 15-point achievement', 1),
(9540439, 4, 6, 5, '5 Triunes of Fate for a 15-point achievement', 1),
(9540424, 2, 0, 2, '2 AA points for a 25-point achievement', 1),
(9540440, 4, 6, 5, '5 Triunes of Fate for a 25-point achievement', 1),
(9540425, 2, 0, 2, '2 AA points for a 25-point achievement', 1),
(9540441, 4, 6, 5, '5 Triunes of Fate for a 25-point achievement', 1),
(9540426, 2, 0, 2, '2 AA points for a 25-point achievement', 1),
(9540442, 4, 6, 5, '5 Triunes of Fate for a 25-point achievement', 1),
(9540427, 2, 0, 5, '5 AA points for a 50-point achievement', 1),
(9540443, 4, 6, 5, '5 Triunes of Fate for a 50-point achievement', 1) ON DUPLICATE KEY UPDATE `amount`=VALUES(`amount`), `description`=VALUES(`description`), `enabled`=VALUES(`enabled`);

INSERT INTO `reward_sets` (`reward_set_id`, `title`, `enabled`) VALUES
(9508206, 'The First Dragons Fall', 1),
(9508207, 'The Dragons of Kunark', 1),
(9508208, 'The Dragons of Velious', 1),
(9508209, 'The Moon Falls', 1),
(9508210, 'Gates of Discord', 1),
(9508211, 'Omens of War', 1),
(9508212, 'Dragons of Norrath', 1),
(9508213, 'Lost Dungeons of Norrath', 1),
(9508214, 'Depths of Darkhollow', 1),
(9508215, 'Prophecy of Ro', 1),
(9508216, 'The Serpent''s Spine', 1),
(9508217, 'The Buried Sea', 1),
(9508218, 'Secrets of Faydwer', 1),
(9508219, 'Seeds of Destruction', 1),
(9508220, 'Fabled Nagafen''s Lair', 1),
(9508221, 'Underfoot', 1) ON DUPLICATE KEY UPDATE `title`=VALUES(`title`), `enabled`=VALUES(`enabled`);

INSERT INTO `reward_options` (`reward_set_id`, `option_id`, `sequence`, `label`, `common_to_all`, `flags`, `enabled`) VALUES
(9508206, 1, 1, 'Claim rewards', 0, 0, 1),
(9508207, 1, 1, 'Claim rewards', 0, 0, 1),
(9508208, 1, 1, 'Claim rewards', 0, 0, 1),
(9508209, 1, 1, 'Claim rewards', 0, 0, 1),
(9508210, 1, 1, 'Claim rewards', 0, 0, 1),
(9508211, 1, 1, 'Claim rewards', 0, 0, 1),
(9508212, 1, 1, 'Claim rewards', 0, 0, 1),
(9508213, 1, 1, 'Claim rewards', 0, 0, 1),
(9508214, 1, 1, 'Claim rewards', 0, 0, 1),
(9508215, 1, 1, 'Claim rewards', 0, 0, 1),
(9508216, 1, 1, 'Claim rewards', 0, 0, 1),
(9508217, 1, 1, 'Claim rewards', 0, 0, 1),
(9508218, 1, 1, 'Claim rewards', 0, 0, 1),
(9508219, 1, 1, 'Claim rewards', 0, 0, 1),
(9508220, 1, 1, 'Claim rewards', 0, 0, 1),
(9508221, 1, 1, 'Claim rewards', 0, 0, 1) ON DUPLICATE KEY UPDATE `enabled`=VALUES(`enabled`);

INSERT INTO `reward_option_entries` (`reward_set_id`, `option_id`, `sequence`, `reward_id`) VALUES
(9508206, 1, 1, 9540412),
(9508206, 1, 2, 9540428),
(9508207, 1, 1, 9540413),
(9508207, 1, 2, 9540429),
(9508208, 1, 1, 9540414),
(9508208, 1, 2, 9540430),
(9508209, 1, 1, 9540415),
(9508209, 1, 2, 9540431),
(9508210, 1, 1, 9540416),
(9508210, 1, 2, 9540432),
(9508211, 1, 1, 9540417),
(9508211, 1, 2, 9540433),
(9508212, 1, 1, 9540418),
(9508212, 1, 2, 9540434),
(9508213, 1, 1, 9540419),
(9508213, 1, 2, 9540435),
(9508214, 1, 1, 9540420),
(9508214, 1, 2, 9540436),
(9508215, 1, 1, 9540421),
(9508215, 1, 2, 9540437),
(9508216, 1, 1, 9540422),
(9508216, 1, 2, 9540438),
(9508217, 1, 1, 9540423),
(9508217, 1, 2, 9540439),
(9508218, 1, 1, 9540424),
(9508218, 1, 2, 9540440),
(9508219, 1, 1, 9540425),
(9508219, 1, 2, 9540441),
(9508220, 1, 1, 9540426),
(9508220, 1, 2, 9540442),
(9508221, 1, 1, 9540427),
(9508221, 1, 2, 9540443) ON DUPLICATE KEY UPDATE `sequence`=VALUES(`sequence`);

INSERT INTO `reward_sources` (`source_type`, `source_id`, `reward_set_id`, `enabled`) VALUES
(1, 9501000, 9508206, 1),
(1, 9501001, 9508207, 1),
(1, 9501002, 9508208, 1),
(1, 9501003, 9508209, 1),
(1, 9501004, 9508210, 1),
(1, 9501005, 9508211, 1),
(1, 9501006, 9508212, 1),
(1, 9501007, 9508213, 1),
(1, 9501008, 9508214, 1),
(1, 9501009, 9508215, 1),
(1, 9501010, 9508216, 1),
(1, 9501011, 9508217, 1),
(1, 9501012, 9508218, 1),
(1, 9501013, 9508219, 1),
(1, 9501014, 9508220, 1),
(1, 9501015, 9508221, 1) ON DUPLICATE KEY UPDATE `reward_set_id`=VALUES(`reward_set_id`), `enabled`=VALUES(`enabled`);
COMMIT;

-- entry 263: 20261029_vendors_goldfish_kedge
-- Bindral Argaff (PoK enchanter 202431) sells all 11 classic level-1 ENC spell scrolls.
UPDATE `npc_types` SET `merchant_id` = 7010100 WHERE `id` = 202431;
DELETE FROM `merchantlist` WHERE `merchantid` = 7010100;
INSERT IGNORE INTO `merchantlist` (`merchantid`, `slot`, `item`) VALUES
(7010100, 1, 15040), -- Spell: Strengthen,
(7010100, 2, 15041), -- Spell: Weaken,
(7010100, 3, 15205), -- Spell: True North,
(7010100, 4, 15208), -- Spell: Lull,
(7010100, 5, 15285), -- Spell: Pendril's Animation,
(7010100, 6, 15286), -- Spell: Shallow Breath,
(7010100, 7, 15287), -- Spell: Minor Illusion,
(7010100, 8, 15288), -- Spell: Minor Shielding,
(7010100, 9, 15289), -- Spell: Taper Enchantment,
(7010100, 10, 15300), -- Spell: Charm
(7010100, 11, 15331); -- Spell: Reclaim Energy

-- Phinigel Autropos (kedge 64001) always drops Goldfish Flakes, matching Faydedar /
-- #Lord Koi`Doken / Kelorek`Dar. Guarded against double-linking.
INSERT INTO `loottable_entries` (`loottable_id`, `lootdrop_id`, `multiplier`, `droplimit`, `mindrop`, `probability`)
SELECT 10831, 1520008200, 1, 1, 1, 100 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `loottable_entries` WHERE `loottable_id` = 10831 AND `lootdrop_id` = 1520008200);

-- Goldfish Flakes 2% zone-wide drop in Kedge Keep (64), Plane of Water (216),
-- Thalassius, the Coral Keep (417).
INSERT IGNORE INTO `loottable` (`id`, `name`, `mincash`, `maxcash`, `avgcoin`) VALUES (1520009314, 'Goldfish_Flakes_Zone_Rare', 0, 0, 0);
INSERT IGNORE INTO `lootdrop` (`id`, `name`, `min_expansion`, `max_expansion`) VALUES (1520009414, 'Goldfish Flakes (Zone Rare)', -1, -1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`, `item_id`, `item_charges`, `equip_item`, `chance`, `multiplier`)
SELECT 1520009414, 121858, 1, 0, 2, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `lootdrop_entries` WHERE `lootdrop_id` = 1520009414 AND `item_id` = 121858);
INSERT INTO `loottable_entries` (`loottable_id`, `lootdrop_id`, `multiplier`, `droplimit`, `mindrop`, `probability`)
SELECT 1520009314, 1520009414, 1, 0, 0, 100 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `loottable_entries` WHERE `loottable_id` = 1520009314 AND `lootdrop_id` = 1520009414);
INSERT IGNORE INTO `global_loot` (`id`, `description`, `loottable_id`, `enabled`, `min_level`, `max_level`, `rare`, `raid`, `race`, `class`, `bodytype`, `zone`, `hot_zone`, `min_expansion`, `max_expansion`, `content_flags`, `content_flags_disabled`)
VALUES (178901, 'Goldfish Flakes rare zone drop (kedge/powater/thalassius)', 1520009314, 1, 0, 0, 0, 0, NULL, NULL, NULL, '64|216|417', 0, -1, -1, NULL, NULL);
COMMIT;

-- Expected post-conditions: 16 achievements / 47 criteria / 16 category associations;
-- 32 rewards, 16 sets, 16 options, 32 entries, 16 sources; 11 merchantlist rows for
-- 7010100; Phinny linked to lootdrop 1520008200; global_loot 178901 on zones 64|216|417.
SELECT 'ach' t, COUNT(*) FROM achievements WHERE id BETWEEN 9501000 AND 9501015
UNION ALL SELECT 'crit', COUNT(*) FROM achievement_criteria WHERE achievement_id BETWEEN 9501000 AND 9501015
UNION ALL SELECT 'assoc', COUNT(*) FROM achievement_category_associations WHERE achievement_id BETWEEN 9501000 AND 9501015
UNION ALL SELECT 'rewards', COUNT(*) FROM rewards WHERE reward_id BETWEEN 9540412 AND 9540443
UNION ALL SELECT 'sets', COUNT(*) FROM reward_sets WHERE reward_set_id BETWEEN 9508206 AND 9508221
UNION ALL SELECT 'sources', COUNT(*) FROM reward_sources WHERE source_type = 1 AND source_id BETWEEN 9501000 AND 9501015
UNION ALL SELECT 'merchant', COUNT(*) FROM merchantlist WHERE merchantid = 7010100
UNION ALL SELECT 'phinny_link', COUNT(*) FROM loottable_entries WHERE loottable_id = 10831 AND lootdrop_id = 1520008200
UNION ALL SELECT 'global', COUNT(*) FROM global_loot WHERE id = 178901;
