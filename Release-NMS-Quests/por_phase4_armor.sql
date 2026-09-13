-- Prophecy of Ro - Phase 4: Spirit Mark Armor
-- Stock Lady Usher (merchant 369005) with the Crafting Molds and wire the seven
-- Spirit Marks onto the Arcstone named.
-- Idempotent.

-- --- Lady Usher sells the molds -------------------------------------------------
DELETE FROM `merchantlist` WHERE `merchantid`=369005;
INSERT INTO `merchantlist`
 (`merchantid`,`slot`,`item`,`faction_required`,`level_required`,`min_status`,`max_status`,`alt_currency_cost`,`classes_required`,`probability`,`bucket_name`,`bucket_value`,`bucket_comparison`,`min_expansion`,`max_expansion`)
VALUES
 (369005,1,85659,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Crafting Mold: Spirit Helm
 (369005,2,85660,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Crafting Mold: Spirit Sleeves
 (369005,3,85661,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Crafting Mold: Spirit Gloves
 (369005,4,85662,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Crafting Mold: Spirit Boots
 (369005,5,85663,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Crafting Mold: Spirit Bracers
 (369005,6,85664,-100,0,0,255,0,65535,100,'','',0,-1,-1), -- Crafting Mold: Spirit Leggings
 (369005,7,85665,-100,0,0,255,0,65535,100,'','',0,-1,-1); -- Crafting Mold: Spirit Chest

-- --- Spirit Marks on the Arcstone named ----------------------------------------
DELETE FROM `loottable_entries` WHERE `lootdrop_id`=910014;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id`=910014;
DELETE FROM `lootdrop` WHERE `id`=910014;
INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES (910014,'por_spirit_marks',-1,-1);
INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910014,85655,1,0,30,0,0,0,1,0,0,-1,-1), -- Spirit Mark of Air (arms)
 (910014,85658,1,0,30,0,0,0,1,0,0,-1,-1), -- Spirit Mark of Battle (chest)
 (910014,85654,1,0,30,0,0,0,1,0,0,-1,-1), -- Spirit Mark of Earth (gloves)
 (910014,85652,1,0,30,0,0,0,1,0,0,-1,-1), -- Spirit Mark of Fire (legs)
 (910014,85656,1,0,30,0,0,0,1,0,0,-1,-1), -- Spirit Mark of Scale (wrist)
 (910014,85657,1,0,30,0,0,0,1,0,0,-1,-1), -- Spirit Mark of Vision (helm)
 (910014,85653,1,0,30,0,0,0,1,0,0,-1,-1); -- Spirit Mark of Water (feet)

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (91870,910014,1,0,0,100), -- #Embra
 (91876,910014,1,0,0,100), -- #Seedstep
 (91877,910014,1,0,0,100), -- #Shekar
 (91881,910014,1,0,0,100), -- #Thorn
 (91882,910014,1,0,0,100); -- #Willowalk
