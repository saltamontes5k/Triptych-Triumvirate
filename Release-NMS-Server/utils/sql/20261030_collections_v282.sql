-- v282: the Rasper collection lines (SoF faycite/circum/oculus + SoD themes).
-- Sources: raspersrealm colCursed/colBlessed/colCircum/colOculus/miscCollection;
-- Bonzz oculus.htm + fallen.htm for the combine chains. Every piece,
-- intermediate, final and container item already exists in the item table;
-- this migration adds the missing combines, wires the SoD task rewards,
-- fixes two SoF reward miswires and authors the 20 missing SoD tasks.

INSERT INTO tradeskill_recipe (id, name, tradeskill, skillneeded, trivial, nofail, replace_container, notes, must_learn, learned_by_item_id, quest, enabled) VALUES
(1600000000, 'Cursed Obsidian Faycite', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000001, 'Blessed Celestine Faycite', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000002, 'Dull Were-Orc Knuckle Bone', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000003, 'Polished Were-Orc Knuckle Bone', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000004, 'Smooth Were-Orc Knuckle Bone', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000005, 'Worn Were-Orc Knuckle Bone', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000006, 'Normal Were-Orc Knuckle Bone', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000007, 'Were-Orc Bone Circum', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000008, 'Ancient Emerald Faycite', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000009, 'Ancient Citrine Faycite', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000010, 'Ancient Aquamarine Faycite', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000011, 'Ancient Amber Faycite', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000012, 'Ancient Sapphire Faycite', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000013, 'Ancient Garnet Faycite', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000014, 'Ancient Amethyst Faycite', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000015, 'Ancient Faycite Bone Circum (Emerald)', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000016, 'Ancient Faycite Bone Circum (Citrine)', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000017, 'Ancient Faycite Bone Circum (Aquamarine)', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000018, 'Ancient Faycite Bone Circum (Amber)', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000019, 'Ancient Faycite Bone Circum (Sapphire)', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000020, 'Ancient Faycite Bone Circum (Garnet)', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000021, 'Ancient Faycite Bone Circum (Amethyst)', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000022, 'Intraternal Timing Control Mechanism', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000023, 'Two Dimensional Rotational Cam Pivot', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000024, 'Three Dimensional Rotational Cam Pivot', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000025, 'Four Dimensional Spatial Pivot', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000026, 'Convex Focal Disc Mark II', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000027, 'Zeka Stabilized Rotator', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000028, 'Beza Stabilized Rotator', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000029, 'Azia Stabilized Rotator', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000030, 'Model XLII Spatial Temporal Oculus', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000031, 'Crest Upper Field', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000032, 'Heraldic Keep', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000033, 'Crest Left Field', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000034, 'Crest Right Field', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000035, 'Crest Lower Field', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000036, 'Bayle''s Heraldic Crest', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000037, 'Blood of Medicine', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000038, 'Blood of Oblivion', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000039, 'Blood of Light', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000040, 'Blood of the Fallen', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000041, 'Iksar Left Leg Bone Assembly', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000042, 'Iksar Right Leg Bone Assembly', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000043, 'Iksar Left Arm Bone Assembly', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000044, 'Iksar Right Arm Bone Assembly', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000045, 'Iksar Torso Bone Assembly', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000046, 'Baron Yosig''s Skeleton', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000047, 'Miniature Rallosian Left Bracer', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000048, 'Miniature Rallosian Right Bracer', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000049, 'Miniature Rallosian Boot', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000050, 'Miniature Rallosian Helm', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000051, 'Miniature Rallosian Gloves', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000052, 'Miniature Rallosian Vambraces', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000053, 'Miniature Rallosian Greaves', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000054, 'Miniature Rallosian Breastplate', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000055, 'Rallosian Battle Figure', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000056, 'Babel Crystal', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000057, 'Entropy Crystal', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000058, 'Turmoil Crystal', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000059, 'Chaos Crystal', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000060, 'Anarchy Crystal', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000061, 'Bedlam Crystal', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000062, 'Dark Soul Crystal', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000063, 'Timeshear Orange Moon Fragment', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000064, 'Timeshear Blue Moon Fragment', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000065, 'Timeshear Green Hexagonal Fragment', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000066, 'Timeshear Purple Octagonal Fragment', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000067, 'Timeshear Red Hexagonal Fragment', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000068, 'Timeshear Black Square Fragment', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1),
(1600000069, 'Timeshear', 68, 0, 0, 1, 0, 'Rasper collection combine', 0, 0, 0, 1);

INSERT INTO tradeskill_recipe_entries (recipe_id, item_id, successcount, failcount, componentcount, salvagecount, iscontainer) VALUES
(1600000000, 79579, 1, 0, 0, 0, 0),
(1600000000, 79570, 0, 0, 1, 0, 0),
(1600000000, 79571, 0, 0, 1, 0, 0),
(1600000000, 79572, 0, 0, 1, 0, 0),
(1600000000, 79573, 0, 0, 1, 0, 0),
(1600000000, 79574, 0, 0, 1, 0, 0),
(1600000000, 79575, 0, 0, 1, 0, 0),
(1600000000, 79576, 0, 0, 1, 0, 0),
(1600000000, 79577, 0, 0, 1, 0, 0),
(1600000000, 79578, 0, 0, 0, 0, 1),
(1600000001, 79590, 1, 0, 0, 0, 0),
(1600000001, 79580, 0, 0, 1, 0, 0),
(1600000001, 79581, 0, 0, 1, 0, 0),
(1600000001, 79582, 0, 0, 1, 0, 0),
(1600000001, 79583, 0, 0, 1, 0, 0),
(1600000001, 79584, 0, 0, 1, 0, 0),
(1600000001, 79585, 0, 0, 1, 0, 0),
(1600000001, 79586, 0, 0, 1, 0, 0),
(1600000001, 79587, 0, 0, 1, 0, 0),
(1600000001, 79588, 0, 0, 1, 0, 0),
(1600000001, 79589, 0, 0, 0, 0, 1),
(1600000002, 79710, 1, 0, 0, 0, 0),
(1600000002, 79705, 0, 0, 1, 0, 0),
(1600000002, 79699, 0, 0, 0, 0, 1),
(1600000003, 79711, 1, 0, 0, 0, 0),
(1600000003, 79706, 0, 0, 1, 0, 0),
(1600000003, 79699, 0, 0, 0, 0, 1),
(1600000004, 79712, 1, 0, 0, 0, 0),
(1600000004, 79707, 0, 0, 1, 0, 0),
(1600000004, 79699, 0, 0, 0, 0, 1),
(1600000005, 79713, 1, 0, 0, 0, 0),
(1600000005, 79708, 0, 0, 1, 0, 0),
(1600000005, 79699, 0, 0, 0, 0, 1),
(1600000006, 79714, 1, 0, 0, 0, 0),
(1600000006, 79709, 0, 0, 1, 0, 0),
(1600000006, 79699, 0, 0, 0, 0, 1),
(1600000007, 79722, 1, 0, 0, 0, 0),
(1600000007, 79710, 0, 0, 1, 0, 0),
(1600000007, 79711, 0, 0, 1, 0, 0),
(1600000007, 79712, 0, 0, 1, 0, 0),
(1600000007, 79713, 0, 0, 1, 0, 0),
(1600000007, 79714, 0, 0, 1, 0, 0),
(1600000007, 79700, 0, 0, 0, 0, 1),
(1600000008, 79715, 1, 0, 0, 0, 0),
(1600000008, 79703, 0, 0, 1, 0, 0),
(1600000008, 79704, 0, 0, 1, 0, 0),
(1600000008, 79701, 0, 0, 0, 0, 1),
(1600000009, 79716, 1, 0, 0, 0, 0),
(1600000009, 79730, 0, 0, 1, 0, 0),
(1600000009, 79731, 0, 0, 1, 0, 0),
(1600000009, 79732, 0, 0, 1, 0, 0),
(1600000009, 79701, 0, 0, 0, 0, 1),
(1600000010, 79717, 1, 0, 0, 0, 0),
(1600000010, 79733, 0, 0, 1, 0, 0),
(1600000010, 79734, 0, 0, 1, 0, 0),
(1600000010, 79735, 0, 0, 1, 0, 0),
(1600000010, 79701, 0, 0, 0, 0, 1),
(1600000011, 79718, 1, 0, 0, 0, 0),
(1600000011, 79736, 0, 0, 1, 0, 0),
(1600000011, 79737, 0, 0, 1, 0, 0),
(1600000011, 79738, 0, 0, 1, 0, 0),
(1600000011, 79739, 0, 0, 1, 0, 0),
(1600000011, 79701, 0, 0, 0, 0, 1),
(1600000012, 79719, 1, 0, 0, 0, 0),
(1600000012, 79740, 0, 0, 1, 0, 0),
(1600000012, 79741, 0, 0, 1, 0, 0),
(1600000012, 79742, 0, 0, 1, 0, 0),
(1600000012, 79701, 0, 0, 0, 0, 1),
(1600000013, 79720, 1, 0, 0, 0, 0),
(1600000013, 79743, 0, 0, 1, 0, 0),
(1600000013, 79744, 0, 0, 1, 0, 0),
(1600000013, 79745, 0, 0, 1, 0, 0),
(1600000013, 79701, 0, 0, 0, 0, 1),
(1600000014, 79721, 1, 0, 0, 0, 0),
(1600000014, 79746, 0, 0, 1, 0, 0),
(1600000014, 79747, 0, 0, 1, 0, 0),
(1600000014, 79748, 0, 0, 1, 0, 0),
(1600000014, 79749, 0, 0, 1, 0, 0),
(1600000014, 79701, 0, 0, 0, 0, 1),
(1600000015, 79723, 1, 0, 0, 0, 0),
(1600000015, 79722, 0, 0, 1, 0, 0),
(1600000015, 79715, 0, 0, 1, 0, 0),
(1600000015, 79702, 0, 0, 0, 0, 1),
(1600000016, 79724, 1, 0, 0, 0, 0),
(1600000016, 79723, 0, 0, 1, 0, 0),
(1600000016, 79716, 0, 0, 1, 0, 0),
(1600000016, 79702, 0, 0, 0, 0, 1),
(1600000017, 79725, 1, 0, 0, 0, 0),
(1600000017, 79724, 0, 0, 1, 0, 0),
(1600000017, 79717, 0, 0, 1, 0, 0),
(1600000017, 79702, 0, 0, 0, 0, 1),
(1600000018, 79726, 1, 0, 0, 0, 0),
(1600000018, 79725, 0, 0, 1, 0, 0),
(1600000018, 79718, 0, 0, 1, 0, 0),
(1600000018, 79702, 0, 0, 0, 0, 1),
(1600000019, 79727, 1, 0, 0, 0, 0),
(1600000019, 79726, 0, 0, 1, 0, 0),
(1600000019, 79719, 0, 0, 1, 0, 0),
(1600000019, 79702, 0, 0, 0, 0, 1),
(1600000020, 79728, 1, 0, 0, 0, 0),
(1600000020, 79727, 0, 0, 1, 0, 0),
(1600000020, 79720, 0, 0, 1, 0, 0),
(1600000020, 79702, 0, 0, 0, 0, 1),
(1600000021, 79729, 1, 0, 0, 0, 0),
(1600000021, 79728, 0, 0, 1, 0, 0),
(1600000021, 79721, 0, 0, 1, 0, 0),
(1600000021, 79702, 0, 0, 0, 0, 1),
(1600000022, 79782, 1, 0, 0, 0, 0),
(1600000022, 79761, 0, 0, 1, 0, 0),
(1600000022, 79762, 0, 0, 1, 0, 0),
(1600000022, 79764, 0, 0, 1, 0, 0),
(1600000022, 79765, 0, 0, 1, 0, 0),
(1600000022, 79763, 0, 0, 1, 0, 0),
(1600000022, 79760, 0, 0, 0, 0, 1),
(1600000023, 79783, 1, 0, 0, 0, 0),
(1600000023, 79767, 0, 0, 1, 0, 0),
(1600000023, 79768, 0, 0, 1, 0, 0),
(1600000023, 79760, 0, 0, 0, 0, 1),
(1600000024, 79784, 1, 0, 0, 0, 0),
(1600000024, 79783, 0, 0, 1, 0, 0),
(1600000024, 79766, 0, 0, 1, 0, 0),
(1600000024, 79769, 0, 0, 1, 0, 0),
(1600000024, 79760, 0, 0, 0, 0, 1),
(1600000025, 79788, 1, 0, 0, 0, 0),
(1600000025, 79784, 0, 0, 1, 0, 0),
(1600000025, 79777, 0, 0, 1, 0, 0),
(1600000025, 79778, 0, 0, 1, 0, 0),
(1600000025, 79760, 0, 0, 0, 0, 1),
(1600000026, 79789, 1, 0, 0, 0, 0),
(1600000026, 79788, 0, 0, 1, 0, 0),
(1600000026, 79782, 0, 0, 1, 0, 0),
(1600000026, 79760, 0, 0, 0, 0, 1),
(1600000027, 79785, 1, 0, 0, 0, 0),
(1600000027, 79771, 0, 0, 1, 0, 0),
(1600000027, 79774, 0, 0, 1, 0, 0),
(1600000027, 79779, 0, 0, 1, 0, 0),
(1600000027, 79760, 0, 0, 0, 0, 1),
(1600000028, 79787, 1, 0, 0, 0, 0),
(1600000028, 79773, 0, 0, 1, 0, 0),
(1600000028, 79776, 0, 0, 1, 0, 0),
(1600000028, 79781, 0, 0, 1, 0, 0),
(1600000028, 79760, 0, 0, 0, 0, 1),
(1600000029, 79786, 1, 0, 0, 0, 0),
(1600000029, 79772, 0, 0, 1, 0, 0),
(1600000029, 79775, 0, 0, 1, 0, 0),
(1600000029, 79780, 0, 0, 1, 0, 0),
(1600000029, 79760, 0, 0, 0, 0, 1),
(1600000030, 79790, 1, 0, 0, 0, 0),
(1600000030, 79770, 0, 0, 1, 0, 0),
(1600000030, 79789, 0, 0, 1, 0, 0),
(1600000030, 79785, 0, 0, 1, 0, 0),
(1600000030, 79786, 0, 0, 1, 0, 0),
(1600000030, 79787, 0, 0, 1, 0, 0),
(1600000030, 79760, 0, 0, 0, 0, 1),
(1600000031, 42722, 1, 0, 0, 0, 0),
(1600000031, 42700, 0, 0, 1, 0, 0),
(1600000031, 42701, 0, 0, 1, 0, 0),
(1600000031, 42702, 0, 0, 1, 0, 0),
(1600000031, 42703, 0, 0, 1, 0, 0),
(1600000031, 42704, 0, 0, 1, 0, 0),
(1600000031, 42705, 0, 0, 1, 0, 0),
(1600000031, 42728, 0, 0, 0, 0, 1),
(1600000032, 42723, 1, 0, 0, 0, 0),
(1600000032, 42706, 0, 0, 1, 0, 0),
(1600000032, 42707, 0, 0, 1, 0, 0),
(1600000032, 42708, 0, 0, 1, 0, 0),
(1600000032, 42709, 0, 0, 1, 0, 0),
(1600000032, 42710, 0, 0, 1, 0, 0),
(1600000032, 42712, 0, 0, 1, 0, 0),
(1600000032, 42728, 0, 0, 0, 0, 1),
(1600000033, 42724, 1, 0, 0, 0, 0),
(1600000033, 42711, 0, 0, 1, 0, 0),
(1600000033, 42713, 0, 0, 1, 0, 0),
(1600000033, 42714, 0, 0, 1, 0, 0),
(1600000033, 42717, 0, 0, 1, 0, 0),
(1600000033, 42728, 0, 0, 0, 0, 1),
(1600000034, 42725, 1, 0, 0, 0, 0),
(1600000034, 42715, 0, 0, 1, 0, 0),
(1600000034, 42716, 0, 0, 1, 0, 0),
(1600000034, 42720, 0, 0, 1, 0, 0),
(1600000034, 42721, 0, 0, 1, 0, 0),
(1600000034, 42728, 0, 0, 0, 0, 1),
(1600000035, 42726, 1, 0, 0, 0, 0),
(1600000035, 42718, 0, 0, 1, 0, 0),
(1600000035, 42719, 0, 0, 1, 0, 0),
(1600000035, 42728, 0, 0, 0, 0, 1),
(1600000036, 42727, 1, 0, 0, 0, 0),
(1600000036, 42722, 0, 0, 1, 0, 0),
(1600000036, 42723, 0, 0, 1, 0, 0),
(1600000036, 42724, 0, 0, 1, 0, 0),
(1600000036, 42725, 0, 0, 1, 0, 0),
(1600000036, 42726, 0, 0, 1, 0, 0),
(1600000036, 42729, 0, 0, 0, 0, 1),
(1600000037, 42754, 1, 0, 0, 0, 0),
(1600000037, 42745, 0, 0, 1, 0, 0),
(1600000037, 42749, 0, 0, 1, 0, 0),
(1600000037, 42748, 0, 0, 1, 0, 0),
(1600000037, 42747, 0, 0, 1, 0, 0),
(1600000037, 42746, 0, 0, 1, 0, 0),
(1600000037, 42744, 0, 0, 1, 0, 0),
(1600000037, 42751, 0, 0, 1, 0, 0),
(1600000037, 42750, 0, 0, 1, 0, 0),
(1600000037, 42756, 0, 0, 0, 0, 1),
(1600000038, 42753, 1, 0, 0, 0, 0),
(1600000038, 42743, 0, 0, 1, 0, 0),
(1600000038, 42741, 0, 0, 1, 0, 0),
(1600000038, 42737, 0, 0, 1, 0, 0),
(1600000038, 42739, 0, 0, 1, 0, 0),
(1600000038, 42742, 0, 0, 1, 0, 0),
(1600000038, 42738, 0, 0, 1, 0, 0),
(1600000038, 42740, 0, 0, 1, 0, 0),
(1600000038, 42756, 0, 0, 0, 0, 1),
(1600000039, 42752, 1, 0, 0, 0, 0),
(1600000039, 42730, 0, 0, 1, 0, 0),
(1600000039, 42731, 0, 0, 1, 0, 0),
(1600000039, 42732, 0, 0, 1, 0, 0),
(1600000039, 42735, 0, 0, 1, 0, 0),
(1600000039, 42736, 0, 0, 1, 0, 0),
(1600000039, 42733, 0, 0, 1, 0, 0),
(1600000039, 42734, 0, 0, 1, 0, 0),
(1600000039, 42756, 0, 0, 0, 0, 1),
(1600000040, 42755, 1, 0, 0, 0, 0),
(1600000040, 42754, 0, 0, 1, 0, 0),
(1600000040, 42753, 0, 0, 1, 0, 0),
(1600000040, 42752, 0, 0, 1, 0, 0),
(1600000040, 42756, 0, 0, 0, 0, 1),
(1600000041, 42776, 1, 0, 0, 0, 0),
(1600000041, 42757, 0, 0, 1, 0, 0),
(1600000041, 42760, 0, 0, 1, 0, 0),
(1600000041, 42774, 0, 0, 1, 0, 0),
(1600000041, 42782, 0, 0, 0, 0, 1),
(1600000042, 42777, 1, 0, 0, 0, 0),
(1600000042, 42758, 0, 0, 1, 0, 0),
(1600000042, 42761, 0, 0, 1, 0, 0),
(1600000042, 42775, 0, 0, 1, 0, 0),
(1600000042, 42782, 0, 0, 0, 0, 1),
(1600000043, 42778, 1, 0, 0, 0, 0),
(1600000043, 42765, 0, 0, 1, 0, 0),
(1600000043, 42762, 0, 0, 1, 0, 0),
(1600000043, 42770, 0, 0, 1, 0, 0),
(1600000043, 42782, 0, 0, 0, 0, 1),
(1600000044, 42780, 1, 0, 0, 0, 0),
(1600000044, 42766, 0, 0, 1, 0, 0),
(1600000044, 42768, 0, 0, 1, 0, 0),
(1600000044, 42771, 0, 0, 1, 0, 0),
(1600000044, 42782, 0, 0, 0, 0, 1),
(1600000045, 42779, 1, 0, 0, 0, 0),
(1600000045, 42763, 0, 0, 1, 0, 0),
(1600000045, 42764, 0, 0, 1, 0, 0),
(1600000045, 42772, 0, 0, 1, 0, 0),
(1600000045, 42773, 0, 0, 1, 0, 0),
(1600000045, 42782, 0, 0, 0, 0, 1),
(1600000046, 42781, 1, 0, 0, 0, 0),
(1600000046, 42776, 0, 0, 1, 0, 0),
(1600000046, 42777, 0, 0, 1, 0, 0),
(1600000046, 42778, 0, 0, 1, 0, 0),
(1600000046, 42780, 0, 0, 1, 0, 0),
(1600000046, 42779, 0, 0, 1, 0, 0),
(1600000046, 42759, 0, 0, 1, 0, 0),
(1600000046, 42769, 0, 0, 1, 0, 0),
(1600000046, 42767, 0, 0, 1, 0, 0),
(1600000046, 42782, 0, 0, 0, 0, 1),
(1600000047, 42811, 1, 0, 0, 0, 0),
(1600000047, 42783, 0, 0, 1, 0, 0),
(1600000047, 42784, 0, 0, 1, 0, 0),
(1600000047, 42785, 0, 0, 1, 0, 0),
(1600000047, 42820, 0, 0, 0, 0, 1),
(1600000048, 42812, 1, 0, 0, 0, 0),
(1600000048, 42786, 0, 0, 1, 0, 0),
(1600000048, 42787, 0, 0, 1, 0, 0),
(1600000048, 42788, 0, 0, 1, 0, 0),
(1600000048, 42820, 0, 0, 0, 0, 1),
(1600000049, 42813, 1, 0, 0, 0, 0),
(1600000049, 42789, 0, 0, 1, 0, 0),
(1600000049, 42790, 0, 0, 1, 0, 0),
(1600000049, 42791, 0, 0, 1, 0, 0),
(1600000049, 42820, 0, 0, 0, 0, 1),
(1600000050, 42814, 1, 0, 0, 0, 0),
(1600000050, 42792, 0, 0, 1, 0, 0),
(1600000050, 42793, 0, 0, 1, 0, 0),
(1600000050, 42794, 0, 0, 1, 0, 0),
(1600000050, 42820, 0, 0, 0, 0, 1),
(1600000051, 42815, 1, 0, 0, 0, 0),
(1600000051, 42795, 0, 0, 1, 0, 0),
(1600000051, 42796, 0, 0, 1, 0, 0),
(1600000051, 42797, 0, 0, 1, 0, 0),
(1600000051, 42798, 0, 0, 1, 0, 0),
(1600000051, 42820, 0, 0, 0, 0, 1),
(1600000052, 42816, 1, 0, 0, 0, 0),
(1600000052, 42799, 0, 0, 1, 0, 0),
(1600000052, 42800, 0, 0, 1, 0, 0),
(1600000052, 42801, 0, 0, 1, 0, 0),
(1600000052, 42802, 0, 0, 1, 0, 0),
(1600000052, 42820, 0, 0, 0, 0, 1),
(1600000053, 42817, 1, 0, 0, 0, 0),
(1600000053, 42803, 0, 0, 1, 0, 0),
(1600000053, 42804, 0, 0, 1, 0, 0),
(1600000053, 42805, 0, 0, 1, 0, 0),
(1600000053, 42806, 0, 0, 1, 0, 0),
(1600000053, 42820, 0, 0, 0, 0, 1),
(1600000054, 42818, 1, 0, 0, 0, 0),
(1600000054, 42807, 0, 0, 1, 0, 0),
(1600000054, 42808, 0, 0, 1, 0, 0),
(1600000054, 42809, 0, 0, 1, 0, 0),
(1600000054, 42810, 0, 0, 1, 0, 0),
(1600000054, 42820, 0, 0, 0, 0, 1),
(1600000055, 42819, 1, 0, 0, 0, 0),
(1600000055, 42811, 0, 0, 1, 0, 0),
(1600000055, 42812, 0, 0, 1, 0, 0),
(1600000055, 42813, 0, 0, 1, 0, 0),
(1600000055, 42814, 0, 0, 1, 0, 0),
(1600000055, 42815, 0, 0, 1, 0, 0),
(1600000055, 42816, 0, 0, 1, 0, 0),
(1600000055, 42817, 0, 0, 1, 0, 0),
(1600000055, 42818, 0, 0, 1, 0, 0),
(1600000055, 42821, 0, 0, 0, 0, 1),
(1600000056, 42844, 1, 0, 0, 0, 0),
(1600000056, 42822, 0, 0, 1, 0, 0),
(1600000056, 42823, 0, 0, 1, 0, 0),
(1600000056, 42824, 0, 0, 1, 0, 0),
(1600000056, 42825, 0, 0, 1, 0, 0),
(1600000056, 42851, 0, 0, 0, 0, 1),
(1600000057, 42845, 1, 0, 0, 0, 0),
(1600000057, 42826, 0, 0, 1, 0, 0),
(1600000057, 42827, 0, 0, 1, 0, 0),
(1600000057, 42828, 0, 0, 1, 0, 0),
(1600000057, 42829, 0, 0, 1, 0, 0),
(1600000057, 42851, 0, 0, 0, 0, 1),
(1600000058, 42846, 1, 0, 0, 0, 0),
(1600000058, 42830, 0, 0, 1, 0, 0),
(1600000058, 42831, 0, 0, 1, 0, 0),
(1600000058, 42832, 0, 0, 1, 0, 0),
(1600000058, 42833, 0, 0, 1, 0, 0),
(1600000058, 42851, 0, 0, 0, 0, 1),
(1600000059, 42847, 1, 0, 0, 0, 0),
(1600000059, 42834, 0, 0, 1, 0, 0),
(1600000059, 42835, 0, 0, 1, 0, 0),
(1600000059, 42836, 0, 0, 1, 0, 0),
(1600000059, 42837, 0, 0, 1, 0, 0),
(1600000059, 42851, 0, 0, 0, 0, 1),
(1600000060, 42848, 1, 0, 0, 0, 0),
(1600000060, 42838, 0, 0, 1, 0, 0),
(1600000060, 42839, 0, 0, 1, 0, 0),
(1600000060, 42840, 0, 0, 1, 0, 0),
(1600000060, 42851, 0, 0, 0, 0, 1),
(1600000061, 42849, 1, 0, 0, 0, 0),
(1600000061, 42841, 0, 0, 1, 0, 0),
(1600000061, 42842, 0, 0, 1, 0, 0),
(1600000061, 42843, 0, 0, 1, 0, 0),
(1600000061, 42851, 0, 0, 0, 0, 1),
(1600000062, 42850, 1, 0, 0, 0, 0),
(1600000062, 42844, 0, 0, 1, 0, 0),
(1600000062, 42845, 0, 0, 1, 0, 0),
(1600000062, 42846, 0, 0, 1, 0, 0),
(1600000062, 42847, 0, 0, 1, 0, 0),
(1600000062, 42848, 0, 0, 1, 0, 0),
(1600000062, 42849, 0, 0, 1, 0, 0),
(1600000062, 42851, 0, 0, 0, 0, 1),
(1600000063, 42878, 1, 0, 0, 0, 0),
(1600000063, 42852, 0, 0, 1, 0, 0),
(1600000063, 42853, 0, 0, 1, 0, 0),
(1600000063, 42885, 0, 0, 0, 0, 1),
(1600000064, 42879, 1, 0, 0, 0, 0),
(1600000064, 42854, 0, 0, 1, 0, 0),
(1600000064, 42855, 0, 0, 1, 0, 0),
(1600000064, 42885, 0, 0, 0, 0, 1),
(1600000065, 42880, 1, 0, 0, 0, 0),
(1600000065, 42856, 0, 0, 1, 0, 0),
(1600000065, 42857, 0, 0, 1, 0, 0),
(1600000065, 42858, 0, 0, 1, 0, 0),
(1600000065, 42859, 0, 0, 1, 0, 0),
(1600000065, 42860, 0, 0, 1, 0, 0),
(1600000065, 42885, 0, 0, 0, 0, 1),
(1600000066, 42881, 1, 0, 0, 0, 0),
(1600000066, 42861, 0, 0, 1, 0, 0),
(1600000066, 42862, 0, 0, 1, 0, 0),
(1600000066, 42863, 0, 0, 1, 0, 0),
(1600000066, 42864, 0, 0, 1, 0, 0),
(1600000066, 42865, 0, 0, 1, 0, 0),
(1600000066, 42866, 0, 0, 1, 0, 0),
(1600000066, 42867, 0, 0, 1, 0, 0),
(1600000066, 42868, 0, 0, 1, 0, 0),
(1600000066, 42885, 0, 0, 0, 0, 1),
(1600000067, 42882, 1, 0, 0, 0, 0),
(1600000067, 42869, 0, 0, 1, 0, 0),
(1600000067, 42870, 0, 0, 1, 0, 0),
(1600000067, 42871, 0, 0, 1, 0, 0),
(1600000067, 42872, 0, 0, 1, 0, 0),
(1600000067, 42873, 0, 0, 1, 0, 0),
(1600000067, 42885, 0, 0, 0, 0, 1),
(1600000068, 42883, 1, 0, 0, 0, 0),
(1600000068, 42874, 0, 0, 1, 0, 0),
(1600000068, 42875, 0, 0, 1, 0, 0),
(1600000068, 42876, 0, 0, 1, 0, 0),
(1600000068, 42877, 0, 0, 1, 0, 0),
(1600000068, 42885, 0, 0, 0, 0, 1),
(1600000069, 42884, 1, 0, 0, 0, 0),
(1600000069, 42878, 0, 0, 1, 0, 0),
(1600000069, 42879, 0, 0, 1, 0, 0),
(1600000069, 42880, 0, 0, 1, 0, 0),
(1600000069, 42881, 0, 0, 1, 0, 0),
(1600000069, 42882, 0, 0, 1, 0, 0),
(1600000069, 42883, 0, 0, 1, 0, 0),
(1600000069, 42886, 0, 0, 0, 0, 1);

-- Four SoF task rewards were miswired onto duplicates (Rasper colOculus +
-- colCircum): Breaking Things Down grants the Sidewards Axis Spring IV,
-- Disable the Recycler the second Azia Clockwise Capping Rotator, and the
-- Intelligence Gathering / Cut Off the Head pair sat one step past the
-- Sapphire/Garnet boundary.
UPDATE tasks SET reward_id_list = '79781' WHERE id = 300020;
UPDATE tasks SET reward_id_list = '79772' WHERE id = 300030;
UPDATE tasks SET reward_id_list = '79742' WHERE id = 301107;
UPDATE tasks SET reward_id_list = '79743' WHERE id = 301108;

-- The Bloodbind Cauldron (Silla Herald's container on live) was the one
-- collection container with no purchase source; slot it onto the PoK
-- restock list beside the rest of the collection containers.
INSERT INTO merchantlist (merchantid, slot, item, faction_required) VALUES (999999, 780, 42756, 0);

-- SoD theme tasks existed with empty reward_id_list; each now pays its
-- collection piece (Rasper miscCollection.html).
UPDATE tasks SET reward_id_list = '42700' WHERE id = 303070;
UPDATE tasks SET reward_id_list = '42701' WHERE id = 303107;
UPDATE tasks SET reward_id_list = '42702' WHERE id = 303108;
UPDATE tasks SET reward_id_list = '42703' WHERE id = 303116;
UPDATE tasks SET reward_id_list = '42704' WHERE id = 303109;
UPDATE tasks SET reward_id_list = '42705' WHERE id = 303106;
UPDATE tasks SET reward_id_list = '42707' WHERE id = 303111;
UPDATE tasks SET reward_id_list = '42710' WHERE id = 303114;
UPDATE tasks SET reward_id_list = '42706' WHERE id = 303110;
UPDATE tasks SET reward_id_list = '42712' WHERE id = 303115;
UPDATE tasks SET reward_id_list = '42708' WHERE id = 303112;
UPDATE tasks SET reward_id_list = '42709' WHERE id = 303113;
UPDATE tasks SET reward_id_list = '42713' WHERE id = 303100;
UPDATE tasks SET reward_id_list = '42714' WHERE id = 303101;
UPDATE tasks SET reward_id_list = '42711' WHERE id = 303105;
UPDATE tasks SET reward_id_list = '42717' WHERE id = 303102;
UPDATE tasks SET reward_id_list = '42718' WHERE id = 303104;
UPDATE tasks SET reward_id_list = '42719' WHERE id = 303119;
UPDATE tasks SET reward_id_list = '42720' WHERE id = 303118;
UPDATE tasks SET reward_id_list = '42721' WHERE id = 303117;
UPDATE tasks SET reward_id_list = '42715' WHERE id = 303000;
UPDATE tasks SET reward_id_list = '42716' WHERE id = 303001;
UPDATE tasks SET reward_id_list = '42730' WHERE id = 303124;
UPDATE tasks SET reward_id_list = '42731' WHERE id = 303121;
UPDATE tasks SET reward_id_list = '42732' WHERE id = 303120;
UPDATE tasks SET reward_id_list = '42733' WHERE id = 303122;
UPDATE tasks SET reward_id_list = '42734' WHERE id = 303123;
UPDATE tasks SET reward_id_list = '42735' WHERE id = 303074;
UPDATE tasks SET reward_id_list = '42736' WHERE id = 303075;
UPDATE tasks SET reward_id_list = '42737' WHERE id = 303130;
UPDATE tasks SET reward_id_list = '42738' WHERE id = 303133;
UPDATE tasks SET reward_id_list = '42739' WHERE id = 303135;
UPDATE tasks SET reward_id_list = '42740' WHERE id = 303131;
UPDATE tasks SET reward_id_list = '42741' WHERE id = 303076;
UPDATE tasks SET reward_id_list = '42742' WHERE id = 303132;
UPDATE tasks SET reward_id_list = '42743' WHERE id = 303134;
UPDATE tasks SET reward_id_list = '42744' WHERE id = 303141;
UPDATE tasks SET reward_id_list = '42745' WHERE id = 303142;
UPDATE tasks SET reward_id_list = '42746' WHERE id = 303143;
UPDATE tasks SET reward_id_list = '42747' WHERE id = 303144;
UPDATE tasks SET reward_id_list = '42748' WHERE id = 303145;
UPDATE tasks SET reward_id_list = '42749' WHERE id = 303146;
UPDATE tasks SET reward_id_list = '42750' WHERE id = 303125;
UPDATE tasks SET reward_id_list = '42751' WHERE id = 303126;
UPDATE tasks SET reward_id_list = '42783' WHERE id = 303148;
UPDATE tasks SET reward_id_list = '42784' WHERE id = 303156;
UPDATE tasks SET reward_id_list = '42785' WHERE id = 303149;
UPDATE tasks SET reward_id_list = '42786' WHERE id = 303157;
UPDATE tasks SET reward_id_list = '42787' WHERE id = 303152;
UPDATE tasks SET reward_id_list = '42788' WHERE id = 303154;
UPDATE tasks SET reward_id_list = '42789' WHERE id = 303155;
UPDATE tasks SET reward_id_list = '42790' WHERE id = 303150;
UPDATE tasks SET reward_id_list = '42791' WHERE id = 303158;
UPDATE tasks SET reward_id_list = '42792' WHERE id = 303153;
UPDATE tasks SET reward_id_list = '42793' WHERE id = 303159;
UPDATE tasks SET reward_id_list = '42794' WHERE id = 303151;
UPDATE tasks SET reward_id_list = '42795' WHERE id = 303147;
UPDATE tasks SET reward_id_list = '42796' WHERE id = 303031;
UPDATE tasks SET reward_id_list = '42797' WHERE id = 303034;
UPDATE tasks SET reward_id_list = '42798' WHERE id = 303035;
UPDATE tasks SET reward_id_list = '42799' WHERE id = 303164;
UPDATE tasks SET reward_id_list = '42800' WHERE id = 303165;
UPDATE tasks SET reward_id_list = '42801' WHERE id = 303166;
UPDATE tasks SET reward_id_list = '42802' WHERE id = 303169;
UPDATE tasks SET reward_id_list = '42803' WHERE id = 303170;
UPDATE tasks SET reward_id_list = '42804' WHERE id = 303171;
UPDATE tasks SET reward_id_list = '42805' WHERE id = 303030;
UPDATE tasks SET reward_id_list = '42806' WHERE id = 303032;
UPDATE tasks SET reward_id_list = '42807' WHERE id = 303033;
UPDATE tasks SET reward_id_list = '42808' WHERE id = 303167;
UPDATE tasks SET reward_id_list = '42809' WHERE id = 303168;
UPDATE tasks SET reward_id_list = '42810' WHERE id = 303163;
UPDATE tasks SET reward_id_list = '42822' WHERE id = 303175;
UPDATE tasks SET reward_id_list = '42823' WHERE id = 303176;
UPDATE tasks SET reward_id_list = '42824' WHERE id = 303177;
UPDATE tasks SET reward_id_list = '42825' WHERE id = 303172;
UPDATE tasks SET reward_id_list = '42826' WHERE id = 303174;
UPDATE tasks SET reward_id_list = '42827' WHERE id = 303179;
UPDATE tasks SET reward_id_list = '42828' WHERE id = 303173;
UPDATE tasks SET reward_id_list = '42829' WHERE id = 303178;
UPDATE tasks SET reward_id_list = '42830' WHERE id = 303180;
UPDATE tasks SET reward_id_list = '42832' WHERE id = 303181;
UPDATE tasks SET reward_id_list = '42833' WHERE id = 303183;
UPDATE tasks SET reward_id_list = '42834' WHERE id = 303186;
UPDATE tasks SET reward_id_list = '42835' WHERE id = 303182;
UPDATE tasks SET reward_id_list = '42836' WHERE id = 303184;
UPDATE tasks SET reward_id_list = '42837' WHERE id = 303185;
UPDATE tasks SET reward_id_list = '42838' WHERE id = 303042;
UPDATE tasks SET reward_id_list = '42839' WHERE id = 303043;
UPDATE tasks SET reward_id_list = '42840' WHERE id = 303044;
UPDATE tasks SET reward_id_list = '42841' WHERE id = 303045;
UPDATE tasks SET reward_id_list = '42842' WHERE id = 303046;
UPDATE tasks SET reward_id_list = '42843' WHERE id = 303047;
UPDATE tasks SET reward_id_list = '42861' WHERE id = 303071;
UPDATE tasks SET reward_id_list = '42862' WHERE id = 303072;
UPDATE tasks SET reward_id_list = '42863' WHERE id = 303073;
UPDATE tasks SET reward_id_list = '42864' WHERE id = 303080;
UPDATE tasks SET reward_id_list = '42865' WHERE id = 303005;
UPDATE tasks SET reward_id_list = '42866' WHERE id = 303081;
UPDATE tasks SET reward_id_list = '42867' WHERE id = 303002;
UPDATE tasks SET reward_id_list = '42868' WHERE id = 303003;
UPDATE tasks SET reward_id_list = '42852' WHERE id = 303011;
UPDATE tasks SET reward_id_list = '42853' WHERE id = 303012;
UPDATE tasks SET reward_id_list = '42869' WHERE id = 303022;
UPDATE tasks SET reward_id_list = '42870' WHERE id = 303021;
UPDATE tasks SET reward_id_list = '42871' WHERE id = 303024;
UPDATE tasks SET reward_id_list = '42872' WHERE id = 303020;
UPDATE tasks SET reward_id_list = '42873' WHERE id = 303023;
UPDATE tasks SET reward_id_list = '42856' WHERE id = 303160;
UPDATE tasks SET reward_id_list = '42857' WHERE id = 303161;
UPDATE tasks SET reward_id_list = '42858' WHERE id = 303162;
UPDATE tasks SET reward_id_list = '42859' WHERE id = 303077;
UPDATE tasks SET reward_id_list = '42860' WHERE id = 303036;
UPDATE tasks SET reward_id_list = '42854' WHERE id = 303041;
UPDATE tasks SET reward_id_list = '42855' WHERE id = 303040;
UPDATE tasks SET reward_id_list = '42874' WHERE id = 303048;
UPDATE tasks SET reward_id_list = '42875' WHERE id = 303049;
UPDATE tasks SET reward_id_list = '42876' WHERE id = 303050;
UPDATE tasks SET reward_id_list = '42877' WHERE id = 303051;

-- Twenty-five missing tasks: the Field of Scale set (Baron Yosig's Skeleton
-- pieces), Blunting the Spears (Turmoil Crystal Fragment) and the five
-- Circum missions adapted to the Mechamatic Guardian's live population.
-- Kill targets verified against live spawns.
INSERT INTO tasks (id, type, duration, duration_code, title, description, reward_text, reward_id_list, cash_reward, exp_reward, reward_method, reward_points, reward_point_type, min_level, max_level, level_spread, min_players, max_players, repeatable, faction_reward, completion_emote, replay_timer_group, replay_timer_seconds, request_timer_group, request_timer_seconds, dz_template_id, lock_activity_id, faction_amount, enabled) VALUES
(303200, 0, 0, 0, 'Drake Scourge', 'Tynoc wants the sokokar drakes that harry the Burynai caravans culled.', 'Experience', '42757', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303201, 0, 0, 0, 'Broodling in the Hand', 'Tynoc wants hands on a sokokar brood before the war reaches them first.', 'Experience', '42760', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303202, 0, 0, 0, 'Sarnak Recovery (Burynai)', 'The Burynai ask the Sebilian trackers shadowing their digs to be dealt with.', 'Experience', '42774', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303203, 0, 0, 0, 'Idle Hands', 'The sarnak conscripts dig where the iksar dead lie. Tynoc wants the shovels stopped.', 'Experience', '42765', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303204, 0, 0, 0, 'Supplies', 'Intercept the Sebilian messengers carrying the siege ledgers.', 'Experience', '42762', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303205, 0, 0, 0, 'Parley with Ganak', 'Ganak''s parley requires the Sebilian scaleblades broken first.', 'Experience', '42770', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303206, 0, 0, 0, 'Dark Sentry', 'Take out the Sebilian commanders directing the night sentries.', 'Experience', '42758', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303207, 0, 0, 0, 'The Grudge', 'The racnars have taken to the iksar dead. Settle the grudge.', 'Experience', '42761', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303208, 0, 0, 0, 'Sarnak Recovery (Kurn)', 'Recover what the scaled guardians of Kurn''s Tower carry.', 'Experience', '42775', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303209, 0, 0, 0, 'Evil Afoot', 'The bonecasters raise the war dead after dark. End the casting.', 'Experience', '42766', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303210, 0, 0, 0, 'Raising Cabilis', 'Raising Cabilis begins with breaking the Sebilian crusader line.', 'Experience', '42768', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303211, 0, 0, 0, 'Food Supplies', 'The bloodclaws raid the Burynai grain carts. Stop the raids.', 'Experience', '42771', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303212, 0, 0, 0, 'The Grand Illusion', 'The hierophants weave a grand illusion over the field. Tear it down.', 'Experience', '42763', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303213, 0, 0, 0, 'Purify the Body', 'Purify the field by putting the Sebilian liches down.', 'Experience', '42764', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303214, 0, 0, 0, 'Cutting Off The Arms', 'Cut the arms off the Sebilian war machine, starting with its patrol leaders.', 'Experience', '42772', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303215, 0, 0, 0, 'Sarnak Recovery (Sokokar)', 'The escaped sarnak know the sokokar runs. Catch them before they talk.', 'Experience', '42773', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303216, 0, 0, 0, 'Havoc in the Hatchery', 'Wreak havoc in the Kaesora hatchery before the brood matures.', 'Experience', '42759', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303217, 0, 0, 0, 'Lost and Found', 'Recover what the corrupt defilers looted from the hatchery vaults.', 'Experience', '42769', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303218, 0, 0, 0, 'The Skull of the Ancient', 'The Skull of the Ancient lies with the tower guardians of Kurn''s Tower.', 'Experience', '42767', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303219, 0, 0, 0, 'Blunting the Spears', 'Herald Argoth wants the discordian kyv archers blunted before they loose on the camp.', 'Experience', '42831', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303220, 0, 0, 0, 'Disposing of Unwanted Things', 'Overvolt wants the steamwork blasters, reavers and repairers cleared out of the Guardian.', 'Experience', '79730', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303221, 0, 0, 0, 'Engine Room Schematics', 'Overvolt needs the shock steamworks swept while he copies the engine schematics.', 'Experience', '79731', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303222, 0, 0, 0, 'Security? Yeah Right', 'Overvolt doubts the Guardian''s security detail. Prove it -- break the steam sentinels.', 'Experience', '79732', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303223, 0, 0, 0, 'Tracking the Steamworks', 'Overvolt tracks the Guardian''s patrol routes. Thin the sweepers and dusters, then drop Scout Clockwork Arakyd.', 'Experience', '79733', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1),
(303224, 0, 0, 0, 'Mechamatic Memory Manipulation', 'Overvolt wants the shockblasters that guard the memory banks pulled apart.', 'Experience', '79734', 0, 250000, 0, 0, 0, 75, 0, 0, 0, 0, 1, 0, '', 0, 0, 0, 0, 0, -1, 0, 1);

INSERT INTO task_activities (taskid, activityid, req_activity_id, step, activitytype, target_name, goalmethod, goalcount, description_override, npc_match_list, item_id_list, item_list, dz_switch_id, min_x, min_y, min_z, max_x, max_y, max_z, skill_list, spell_list, zones, zone_version, optional, list_group) VALUES
(303200, 0, -1, 1, 2, 'the sokokar flocks', 0, 10, 'Slay 10 of the sokokar flocks', '452000|452001|452004|452006|452009|452279', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303200, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303201, 0, -1, 1, 2, 'the sokokar broods', 0, 10, 'Slay 10 of the sokokar broods', '452151|452258', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303201, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303202, 0, -1, 1, 2, 'the Sebilian trackers', 0, 12, 'Slay 12 of the Sebilian trackers', '452021|452024|452026', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303202, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303203, 0, -1, 1, 2, 'the sarnak conscripts', 0, 12, 'Slay 12 of the sarnak conscripts', '452018|452041', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303203, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303204, 0, -1, 1, 2, 'the Sebilian messengers', 0, 10, 'Slay 10 of the Sebilian messengers', '452211|452282|452286', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303204, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303205, 0, -1, 1, 2, 'the Sebilian scaleblades', 0, 12, 'Slay 12 of the Sebilian scaleblades', '452058|452081|452107|452115|452141|452174|452209|452224|452244|452247|452248|452250|452252|452261|452265|452271|452273', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303205, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303206, 0, -1, 1, 2, 'the Sebilian commanders', 0, 8, 'Slay 8 of the Sebilian commanders', '452037|452066|452084|452255|452259|452267', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303206, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303207, 0, -1, 1, 2, 'the racnars', 0, 10, 'Slay 10 of the racnars', '452059|452099', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303207, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303208, 0, -1, 1, 2, 'the scaled guardians', 0, 12, 'Slay 12 of the scaled guardians', '455001|455004|455050', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldkurn', -1, 0, 0),
(303208, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303209, 0, -1, 1, 2, 'the Sebilian bonecasters', 0, 12, 'Slay 12 of the Sebilian bonecasters', '452017|452039|452042|452051|452055|452092|452097|452098|452109|452184|452186|452197|452219|452225|452231|452234|452238|452241|452243|452266|452270|452274|452275|452277|452278', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303209, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303210, 0, -1, 1, 2, 'the Sebilian crusaders', 0, 12, 'Slay 12 of the Sebilian crusaders', '452025|452030|452048|452164|452165|452166|452168|452172|452173|452175|452176', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303210, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303211, 0, -1, 1, 2, 'the Sebilian bloodclaws', 0, 10, 'Slay 10 of the Sebilian bloodclaws', '452038|452049|452050|452227', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303211, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303212, 0, -1, 1, 2, 'the Sebilian hierophants', 0, 10, 'Slay 10 of the Sebilian hierophants', '452032|452196', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303212, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303213, 0, -1, 1, 2, 'the Sebilian liches', 0, 10, 'Slay 10 of the Sebilian liches', '452034|452190|452223', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303213, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303214, 0, -1, 1, 2, 'the Sebilian patrol leaders', 0, 8, 'Slay 8 of the Sebilian patrol leaders', '452045', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303214, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303215, 0, -1, 1, 2, 'the escaped sarnak', 0, 10, 'Slay 10 of the escaped sarnak', '452019|452239', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303215, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303216, 0, -1, 1, 2, 'the sokokar broodlings', 0, 10, 'Slay 10 of the sokokar broodlings', '454039', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldkaesorab', -1, 0, 0),
(303216, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303217, 0, -1, 1, 2, 'the corrupt defilers', 0, 10, 'Slay 10 of the corrupt defilers', '454029|454033|454047', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldkaesorab', -1, 0, 0),
(303217, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303218, 0, -1, 1, 2, 'the tower guardians', 0, 10, 'Slay 10 of the tower guardians', '455021|455023|455027|455040|455053|455055|455061|455063|455070|455073|455076|455078|455081|455127|455131|455132|455135|455137|455138|455145', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldkurn', -1, 0, 0),
(303218, 1, -1, 2, 4, 'Tynoc, Herald of Scale', 0, 1, 'Return to Tynoc, Herald of Scale', '452153', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldfieldofbone', -1, 0, 0),
(303219, 0, -1, 1, 2, 'the discordian kyv', 0, 15, 'Slay 15 of the discordian kyv', '472010|472012|472014|472016|472035', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldbloodfield', -1, 0, 0),
(303219, 1, -1, 2, 4, 'Herald Argoth', 0, 1, 'Return to Herald Argoth', '472002', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'oldbloodfield', -1, 0, 0),
(303220, 0, -1, 1, 2, 'the steamwork laborers', 0, 25, 'Slay 25 of the steamwork laborers', '447004|447009|447011|447002|447007|447022|447003|447008|447013', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'guardian', -1, 0, 0),
(303220, 1, -1, 2, 4, 'Overvolt Rigster the IV', 0, 1, 'Return to Overvolt Rigster the IV', '442008', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'dragonscale', -1, 0, 0),
(303221, 0, -1, 1, 2, 'the shock steamworks', 0, 25, 'Slay 25 of the shock steamworks', '447038|447053|447054|447032|447041|447046', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'guardian', -1, 0, 0),
(303221, 1, -1, 2, 4, 'Overvolt Rigster the IV', 0, 1, 'Return to Overvolt Rigster the IV', '442008', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'dragonscale', -1, 0, 0),
(303222, 0, -1, 1, 2, 'the mechano steam sentinels', 0, 8, 'Slay 8 of the mechano steam sentinels', '447030|447042|447063', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'guardian', -1, 0, 0),
(303222, 1, -1, 2, 4, 'Overvolt Rigster the IV', 0, 1, 'Return to Overvolt Rigster the IV', '442008', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'dragonscale', -1, 0, 0),
(303223, 0, -1, 1, 2, 'the steamwork patrollers', 0, 15, 'Slay 15 of the steamwork patrollers', '447029|447031|447057|447058|447065|447068', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'guardian', -1, 0, 0),
(303223, 1, -1, 2, 4, 'Overvolt Rigster the IV', 0, 1, 'Return to Overvolt Rigster the IV', '442008', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'dragonscale', -1, 0, 0),
(303224, 0, -1, 1, 2, 'the steamwork shockblasters', 0, 20, 'Slay 20 of the steamwork shockblasters', '447026|447027|447052', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'guardian', -1, 0, 0),
(303224, 1, -1, 2, 4, 'Overvolt Rigster the IV', 0, 1, 'Return to Overvolt Rigster the IV', '442008', '', '', 0, 0, 0, 0, 0, 0, 0, -1, 0, 'dragonscale', -1, 0, 0);
