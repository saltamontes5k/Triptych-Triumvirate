-- Prophecy of Ro - Phase 4: complete Theater of Blood class-armor drop coverage
-- For each class set, attach any item with no drop source to the same trash
-- loottables that already carry that set. Generated from the live DB.

-- BARD (of Vesagran): 2 missing -> tables [92153, 92168]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910100;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910100;
DELETE FROM `lootdrop` WHERE `id`=910100;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910100,'por_tob_bard',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910100,39935,1,0,25,0,0,0,1,0,0,-1,-1), (910100,39936,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92153,910100,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92168,910100,1,0,0,100);

-- BEASTLORD (Spirit Totem Etched): 4 missing -> tables [92171, 92179]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910101;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910101;
DELETE FROM `lootdrop` WHERE `id`=910101;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910101,'por_tob_beastlord',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910101,39982,1,0,25,0,0,0,1,0,0,-1,-1), (910101,39983,1,0,25,0,0,0,1,0,0,-1,-1), (910101,39984,1,0,25,0,0,0,1,0,0,-1,-1), (910101,39985,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92171,910101,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92179,910101,1,0,0,100);

-- BERSERKER (Vengeful Blood-Alloy): 3 missing -> tables [92158, 92160]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910102;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910102;
DELETE FROM `lootdrop` WHERE `id`=910102;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910102,'por_tob_berserker',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910102,39987,1,0,25,0,0,0,1,0,0,-1,-1), (910102,39991,1,0,25,0,0,0,1,0,0,-1,-1), (910102,39992,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92158,910102,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92160,910102,1,0,0,100);

-- CLERIC (of Superior Divinity): 2 missing -> tables [92164, 92180]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910103;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910103;
DELETE FROM `lootdrop` WHERE `id`=910103;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910103,'por_tob_cleric',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910103,39893,1,0,25,0,0,0,1,0,0,-1,-1), (910103,39894,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92164,910103,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92180,910103,1,0,0,100);

-- DRUID (Everliving Bramble): 2 missing -> tables [92159, 92166]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910104;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910104;
DELETE FROM `lootdrop` WHERE `id`=910104;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910104,'por_tob_druid',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910104,39921,1,0,25,0,0,0,1,0,0,-1,-1), (910104,39922,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92159,910104,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92166,910104,1,0,0,100);

-- ENCHANTER (of Eternal Eloquence): 1 missing -> tables [92174, 92177, 94190]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910105;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910105;
DELETE FROM `lootdrop` WHERE `id`=910105;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910105,'por_tob_enchanter',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910105,39978,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92174,910105,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92177,910105,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (94190,910105,1,0,0,100);

-- MAGICIAN (Primal Element): 2 missing -> tables [92154, 92155]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910106;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910106;
DELETE FROM `lootdrop` WHERE `id`=910106;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910106,'por_tob_magician',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910106,39970,1,0,25,0,0,0,1,0,0,-1,-1), (910106,39971,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92154,910106,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92155,910106,1,0,0,100);

-- MONK (Transcended Immortality): 2 missing -> tables [92169, 92184]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910107;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910107;
DELETE FROM `lootdrop` WHERE `id`=910107;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910107,'por_tob_monk',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910107,39928,1,0,25,0,0,0,1,0,0,-1,-1), (910107,39929,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92169,910107,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92184,910107,1,0,0,100);

-- NECROMANCER (Whispered Death): 1 missing -> tables [91005, 92175, 92176]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910108;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910108;
DELETE FROM `lootdrop` WHERE `id`=910108;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910108,'por_tob_necromancer',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910108,39956,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (91005,910108,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92175,910108,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92176,910108,1,0,0,100);

-- RANGER (Petrified Heartwood): 2 missing -> tables [92161, 92182]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910110;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910110;
DELETE FROM `lootdrop` WHERE `id`=910110;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910110,'por_tob_ranger',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910110,39907,1,0,25,0,0,0,1,0,0,-1,-1), (910110,39908,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92161,910110,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92182,910110,1,0,0,100);

-- ROGUE (Entropic Nightshade): 2 missing -> tables [92163, 92183]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910111;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910111;
DELETE FROM `lootdrop` WHERE `id`=910111;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910111,'por_tob_rogue',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910111,39942,1,0,25,0,0,0,1,0,0,-1,-1), (910111,39943,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92163,910111,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92183,910111,1,0,0,100);

-- SHADOWKNIGHT (Wailing Hatred): 2 missing -> tables [92165, 92170]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910112;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910112;
DELETE FROM `lootdrop` WHERE `id`=910112;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910112,'por_tob_shadowknight',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910112,39914,1,0,25,0,0,0,1,0,0,-1,-1), (910112,39915,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92165,910112,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92170,910112,1,0,0,100);

-- SHAMAN (Spirit Blessed): 3 missing -> tables [92172, 92173]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910113;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910113;
DELETE FROM `lootdrop` WHERE `id`=910113;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910113,'por_tob_shaman',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910113,39945,1,0,25,0,0,0,1,0,0,-1,-1), (910113,39949,1,0,25,0,0,0,1,0,0,-1,-1), (910113,39950,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92172,910113,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92173,910113,1,0,0,100);

-- WARRIOR (of Eternity): 2 missing -> tables [92162, 92167]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910114;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910114;
DELETE FROM `lootdrop` WHERE `id`=910114;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910114,'por_tob_warrior',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910114,39886,1,0,25,0,0,0,1,0,0,-1,-1), (910114,39887,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92162,910114,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92167,910114,1,0,0,100);

-- WIZARD (Phenomenal Power): 2 missing -> tables [92156, 92157]
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910115;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910115;
DELETE FROM `lootdrop` WHERE `id`=910115;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910115,'por_tob_wizard',-1,-1);
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`) VALUES (910115,39963,1,0,25,0,0,0,1,0,0,-1,-1), (910115,39964,1,0,25,0,0,0,1,0,0,-1,-1);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92156,910115,1,0,0,100);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES (92157,910115,1,0,0,100);
