-- The Serpent's Spine - Charm of Lore (Allakhazam quest 3666) + missing artifact sources
-- Idempotent. Apply to the live `peq` DB.
--
-- Quest: Librarian Hemfar (394227), Crescent Reach. 37 artifacts (58715-58750, 58767),
-- reward: Serpent Seeker's Charm of Lore (53505, granted by #Librarian_Hemfar.pl)
-- plus the Cartographer title (titles 4102, granted by script at 37 turn-ins).
--
-- New content to make every artifact obtainable:
--   raid   999300 #Beltron_the_Shade_King   (frostcrypt)  -> 58735 Runed Sash of the Wraithguard
--   raid   999301 #Harfange_the_Black       (frostcrypt)  -> 58736 Krithgorian Royal Crest
--   raid   999302 #Lethar_the_Black         (ashengate)   -> 58746 Ebonheart of Lethar the Black
--   raid   999303 #Ambersnout_the_Aberration(ashengate)   -> 58748 Ambersnout's Snout
--   group  999304 #Obsidian                 (sunderock)   -> 58737 Lock of Veldyn's Hair
--   group  999305 #Sulfurog                 (sunderock)   -> 58740 Relicstone Torch
--   group  999306 #Direwind_Gust            (direwind)    -> 58742 Direwind Totem
--   object 999307 a_book_on_a_table         (crescent)    -> 58750 Linguist's Note
--   ground spawn (icefall)                                -> 58733 Shattered Krithgor Keystone
--   loot additions: 58747 Elddar Moonlocket -> Dyn`Leth (406150, dedicated loottable 970009),
--                   58742 Direwind Totem    -> #Severan_the_Direwind_Caller (405132, loottable 92975)
--   subquest: task 600230 "A Fair Trade" - Shrynn (397275) trades the Dromrek Worry Stone
--             (58729) for a Drakkin Youngling Sword (58768, already drops on dromreks);
--             harpy guards spawn beside him per live.
--
-- Locations use server x,y (Allakhazam lists are player /loc order = y,x; swapped accordingly).

-- ===========================================================================
-- Task 3666: Charm of Lore
-- ===========================================================================
DELETE FROM `task_activities` WHERE `taskid` = 3666;
DELETE FROM `tasks` WHERE `id` = 3666;

INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3666,2,0,0,'Charm of Lore','Librarian Hemfar of Crescent Reach collects artifacts from across the Serpent''s Spine. Bring him relics from the wilds; each one he scribes will strengthen the Serpent Seeker''s Charm of Lore. Find the last pieces in Goru`kar Mesa, Sunderock Springs, Frostcrypt and Ashengate.','Cartographer','',0,10000,0,0,0,5,110,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (3666,0,-1,1,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Broken Nokk Insignia','394227','58715','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,1,-1,2,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Ancient Jewelry Box','394227','58716','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,2,-1,3,1,'#Librarian_Hemfar',0,1,'Give Hemfar Murdunk''s Rites Beads','394227','58717','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,3,-1,4,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Ancient Blighted Bark','394227','58718','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,4,-1,5,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Preserved Kithicor Baneleaf','394227','58719','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,5,-1,6,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Petrified Leather Boot Sole','394227','58720','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,6,-1,7,1,'#Librarian_Hemfar',0,1,'Give Hemfar Devan''s Feathered Arrow','394227','58721','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,7,-1,8,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Thunderhorn of the Tribe','394227','58722','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,8,-1,9,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Sliver of Goru`kar''s Willowstaff','394227','58723','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,9,-1,10,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Sparkling Windwillow Leaf','394227','58724','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,10,-1,11,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Cracked Waterspring Scepter','394227','58725','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,11,-1,12,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Silvered Blackfeather Plume','394227','58726','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,12,-1,13,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Split Ravenoak Bow','394227','58727','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,13,-1,14,1,'#Librarian_Hemfar',0,1,'Give Hemfar Oread''s Willow Whipvine','394227','58728','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,14,-1,15,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Dromrek Worry Stone','394227','58729','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,15,-1,16,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Muddy Royal Scroll','394227','58730','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,16,-1,17,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Wulfnor Crown Gem','394227','58731','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,17,-1,18,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Cursed Lorekeeper''s Quill','394227','58732','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,18,-1,19,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Shattered Krithgor Keystone','394227','58733','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,19,-1,20,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Illegible Diary of Lorekeeper Baeldon','394227','58734','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,20,-1,21,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Runed Sash of the Wraithguard','394227','58735','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,21,-1,22,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Krithgorian Royal Crest','394227','58736','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,22,-1,23,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Lock of Veldyn''s Hair','394227','58737','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,23,-1,24,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Elven Child''s Vinewand','394227','58738','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,24,-1,25,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Trinket of the Scale','394227','58739','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,25,-1,26,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Relicstone Torch','394227','58740','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,26,-1,27,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Vergalid Scale','394227','58741','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,27,-1,28,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Direwind Totem','394227','58742','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,28,-1,29,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Gate Guardian Core','394227','58743','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,29,-1,30,1,'#Librarian_Hemfar',0,1,'Give Hemfar Doomfount''s Essence','394227','58744','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,30,-1,31,1,'#Librarian_Hemfar',0,1,'Give Hemfar Oblivion''s Dark Core','394227','58745','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,31,-1,32,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Ebonheart of Lethar the Black','394227','58746','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,32,-1,33,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Elddar Moonlocket','394227','58747','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,33,-1,34,1,'#Librarian_Hemfar',0,1,'Give Hemfar Ambersnout''s Snout','394227','58748','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,34,-1,35,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Core of the Tyrant','394227','58749','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,35,-1,36,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Linguist''s Note','394227','58750','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3666,36,-1,37,1,'#Librarian_Hemfar',0,1,'Give Hemfar the Preserved Hairy Halfling Foot','394227','58767','',0, 0,0,0,0,0,0,'','','',-1,0,0);

-- ===========================================================================
-- Task 600230: A Fair Trade (Shrynn subquest for the Dromrek Worry Stone)
-- ===========================================================================
DELETE FROM `task_activities` WHERE `taskid` = 600230;
DELETE FROM `tasks` WHERE `id` = 600230;

INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (600230,2,0,0,'A Fair Trade','Shrynn, the drakkin collector perched in northwest Goru`kar Mesa, wants the Drakkin Youngling Sword carried off by the dromrek giants near the Steppes pass. He will trade his old Dromrek Worry Stone for it.','Dromrek Worry Stone','',0,5000,0,0,0,40,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 (600230,0,-1,1,1,'#Shrynn',0,1,'Give Shrynn the Drakkin Youngling Sword','397275','58768','',0, 0,0,0,0,0,0,'','','',-1,0,0);

-- ===========================================================================
-- Cartographer title (granted by #Librarian_Hemfar.pl at 37 artifacts)
-- ===========================================================================
DELETE FROM `titles` WHERE `id` = 4102;
INSERT INTO `titles`
 (`id`,`skill_id`,`min_skill_value`,`max_skill_value`,`min_aa_points`,`max_aa_points`,
  `class`,`gender`,`char_id`,`status`,`item_id`,`prefix`,`suffix`,`title_set`)
VALUES
 (4102,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,'','Cartographer',4102);

-- ===========================================================================
-- Loot tables 970001-970010 (new named mobs + loot additions)
-- ===========================================================================
DELETE FROM `loottable_entries` WHERE `loottable_id` IN (970001,970002,970003,970004,970005,970006,970007,970008,970009);
DELETE FROM `loottable_entries` WHERE `loottable_id` = 92975 AND `lootdrop_id` = 970010;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` IN (970001,970002,970003,970004,970005,970006,970007,970008,970009,970010);
DELETE FROM `lootdrop` WHERE `id` IN (970001,970002,970003,970004,970005,970006,970007,970008,970009,970010);
DELETE FROM `loottable` WHERE `id` IN (970001,970002,970003,970004,970005,970006,970007,970008,970009);

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`) VALUES
 (970001,'tss_beltron_loot',0,0,0,0,-1,-1),
 (970002,'tss_harfange_loot',0,0,0,0,-1,-1),
 (970003,'tss_lethar_loot',0,0,0,0,-1,-1),
 (970004,'tss_ambersnout_loot',0,0,0,0,-1,-1),
 (970005,'tss_obsidian_loot',0,0,0,0,-1,-1),
 (970006,'tss_sulfurog_loot',0,0,0,0,-1,-1),
 (970007,'tss_direwind_gust_loot',0,0,0,0,-1,-1),
 (970008,'tss_book_loot',0,0,0,0,-1,-1);

INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES
 (970001,'tss_beltron_drop',-1,-1),
 (970002,'tss_harfange_drop',-1,-1),
 (970003,'tss_lethar_drop',-1,-1),
 (970004,'tss_ambersnout_drop',-1,-1),
 (970005,'tss_obsidian_drop',-1,-1),
 (970006,'tss_sulfurog_drop',-1,-1),
 (970007,'tss_direwind_gust_drop',-1,-1),
 (970008,'tss_book_drop',-1,-1),
 (970009,'tss_elddar_moonlocket',-1,-1),
 (970010,'tss_direwind_totem',-1,-1);

INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,
  `trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 -- Beltron the Shade King: Runed Sash + frostcrypt relics
 (970001,58735,1,0,100,0,0,0,1,0,0,-1,-1),
 (970001,52676,1,0,30,0,0,0,1,0,0,-1,-1),
 (970001,10037,1,0,20,0,0,0,1,0,0,-1,-1),
 (970001,32862,1,0,15,0,0,0,1,0,0,-1,-1),
 -- Harfange the Black: Krithgorian Royal Crest + relics
 (970002,58736,1,0,100,0,0,0,1,0,0,-1,-1),
 (970002,52676,1,0,30,0,0,0,1,0,0,-1,-1),
 (970002,10036,1,0,20,0,0,0,1,0,0,-1,-1),
 -- Lethar the Black: Ebonheart + dragon hoard
 (970003,58746,1,0,100,0,0,0,1,0,0,-1,-1),
 (970003,52676,1,0,30,0,0,0,1,0,0,-1,-1),
 (970003,10037,1,0,20,0,0,0,1,0,0,-1,-1),
 -- Ambersnout the Aberration: Snout + ooze bits
 (970004,58748,1,0,100,0,0,0,1,0,0,-1,-1),
 (970004,52610,1,0,40,0,0,0,1,0,0,-1,-1),
 -- Obsidian: Lock of Veldyn's Hair
 (970005,58737,1,0,100,0,0,0,1,0,0,-1,-1),
 (970005,10023,1,0,20,0,0,0,1,0,0,-1,-1),
 -- Sulfurog: Relicstone Torch + ooze gems
 (970006,58740,1,0,100,0,0,0,1,0,0,-1,-1),
 (970006,10022,1,0,30,0,0,0,1,0,0,-1,-1),
 (970006,10036,1,0,20,0,0,0,1,0,0,-1,-1),
 -- Direwind Gust: Direwind Totem
 (970007,58742,1,0,100,0,0,0,1,0,0,-1,-1),
 -- a book on a table: Linguist's Note
 (970008,58750,1,0,100,0,0,0,1,0,0,-1,-1),
 -- Dyn`Leth: Elddar Moonlocket (Charm of Lore)
 (970009,58747,1,0,100,0,0,0,1,0,0,-1,-1),
 -- Severan the Direwind Caller: Direwind Totem (event drop)
 (970010,58742,1,0,25,0,0,0,1,0,0,-1,-1);

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (970001,970001,1,0,0,100),
 (970002,970002,1,0,0,100),
 (970003,970003,1,0,0,100),
 (970004,970004,1,0,0,100),
 (970005,970005,1,0,0,100),
 (970006,970006,1,0,0,100),
 (970007,970007,1,0,0,100),
 (970008,970008,1,0,0,100);

-- Dyn`Leth: dedicated loottable (93022 is shared with Magmaraug) cloned + Moonlocket
INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`)
SELECT 970009,'tss_dynleth_loot',`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`
FROM `loottable` WHERE `id` = 93022;

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
SELECT 970009,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`
FROM `loottable_entries` WHERE `loottable_id` = 93022;

INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (970009,970009,1,0,0,100);

UPDATE `npc_types` SET `loottable_id` = 970009 WHERE `id` = 406150;

-- Severan the Direwind Caller: add the Direwind Totem drop
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (92975,970010,1,0,0,100);

-- ===========================================================================
-- New NPCs 999300-999307
-- ===========================================================================
DELETE FROM `npc_types` WHERE `id` BETWEEN 999300 AND 999307;

INSERT INTO npc_types (`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, `loottable_id`, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override`)
SELECT 999300, '#Beltron_the_Shade_King', 'the Shade King', 85, `race`, `class`, `bodytype`, 2200000, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, 970001, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, 3000, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override` FROM npc_types WHERE id = 600110;

INSERT INTO npc_types (`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, `loottable_id`, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override`)
SELECT 999301, '#Harfange_the_Black', 'the Black', 84, 453, `class`, `bodytype`, 2000000, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, 970002, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, 2800, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override` FROM npc_types WHERE id = 600110;

INSERT INTO npc_types (`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, `loottable_id`, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override`)
SELECT 999302, '#Lethar_the_Black', `lastname`, 82, `race`, `class`, `bodytype`, 2500000, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, 970003, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, 3200, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, 376, `npc_aggro`, `spawn_limit`, `attack_speed`, 20, 1, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override` FROM npc_types WHERE id = 406150;

INSERT INTO npc_types (`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, `loottable_id`, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override`)
SELECT 999303, '#Ambersnout_the_Aberration', `lastname`, 80, `race`, `class`, `bodytype`, 1500000, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, 14, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, 970004, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, 1500, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, 1, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override` FROM npc_types WHERE id = 403119;

INSERT INTO npc_types (`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, `loottable_id`, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override`)
SELECT 999304, '#Obsidian', `lastname`, 68, `race`, `class`, `bodytype`, 50000, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, 970005, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, 900, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, 1, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override` FROM npc_types WHERE id = 403063;

INSERT INTO npc_types (`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, `loottable_id`, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override`)
SELECT 999305, '#Sulfurog', `lastname`, 72, `race`, `class`, `bodytype`, 30000, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, 10, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, 970006, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, 1000, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, 1, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override` FROM npc_types WHERE id = 403119;

INSERT INTO npc_types (`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, `loottable_id`, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override`)
SELECT 999306, '#Direwind_Gust', `lastname`, 77, `race`, `class`, `bodytype`, 10000, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, 970007, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, 1, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override` FROM npc_types WHERE id = 405085;

INSERT INTO npc_types (`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, `loottable_id`, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override`)
SELECT 999307, 'a_book_on_a_table', `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, 970008, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`, `summon_timer_override` FROM npc_types WHERE id = 394040;

-- ===========================================================================
-- Spawns: spawngroups 923000-923008, spawn2 450500-450508
-- ===========================================================================
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 923000 AND 923008;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 923000 AND 923008;
DELETE FROM `spawn2` WHERE `id` BETWEEN 450500 AND 450508;

INSERT INTO `spawngroup`
 (`id`,`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,`delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`)
VALUES
 (923000,'tss_beltron',1,0,0,0,0,0,0,0,0,0,0),
 (923001,'tss_harfange',1,0,0,0,0,0,0,0,0,0,0),
 (923002,'tss_lethar',1,0,0,0,0,0,0,0,0,0,0),
 (923003,'tss_ambersnout',1,0,0,0,0,0,0,0,0,0,0),
 (923004,'tss_obsidian',1,0,0,0,0,0,0,0,0,0,0),
 (923005,'tss_sulfurog',1,0,0,0,0,0,0,0,0,0,0),
 (923006,'tss_direwind_gust',1,0,0,0,0,0,0,0,0,0,0),
 (923007,'tss_book',1,0,0,0,0,0,0,0,0,0,0),
 (923008,'tss_shrynn_guards',3,0,0,0,0,0,0,0,0,0,0);

INSERT INTO `spawn2`
 (`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`,
  `pathgrid`,`path_when_zone_idle`,`_condition`,`cond_value`,`animation`,`min_expansion`,`max_expansion`,
  `content_flags`,`content_flags_disabled`)
VALUES
 -- frostcrypt royal crypt area (web raid instance #2 bosses)
 (450500,923000,'frostcrypt',0, 0.0, 1955.0, -254.5, 0, 7200, 0, 0, 0, 0, 1, 0, -1, -1, '', ''),
 (450501,923001,'frostcrypt',0, -140.0, 1955.0, -254.5, 0, 7200, 0, 0, 0, 0, 1, 0, -1, -1, '', ''),
 -- ashengate: Lethar near Dyn`Leth, Ambersnout in the west wing near Magmaraug
 (450502,923002,'ashengate',0, 880.0, 1560.0, -90.0, 0, 7200, 0, 0, 0, 0, 1, 0, -1, -1, '', ''),
 (450503,923003,'ashengate',0, 720.0, 1380.0, -77.875, 0, 7200, 0, 0, 0, 0, 1, 0, -1, -1, '', ''),
 -- sunderock: Obsidian in Basilisk Canyon, Sulfurog by the budding pod
 (450504,923004,'sunderock',0, -940.0, -3310.0, 5.0, 0, 640, 0, 0, 0, 0, 1, 0, -1, -1, '', ''),
 (450505,923005,'sunderock',0, 1010.0, 2980.0, 350.0, 0, 640, 0, 0, 0, 0, 1, 0, -1, -1, '', ''),
 -- direwind: Direwind Gust beside Severan the Direwind Caller
 (450506,923006,'direwind',0, 1300.0, 1730.0, 412.875, 0, 640, 0, 0, 0, 0, 1, 0, -1, -1, '', ''),
 -- crescent: book on a table, second level of the inn
 (450507,923007,'crescent',0, -1605.0, -1510.0, -87.5, 0, 640, 0, 0, 0, 0, 1, 0, -1, -1, '', ''),
 -- mesa: Shrynn's harpy guards
 (450508,923008,'mesa',0, 2860.0, 1700.0, 98.625, 0, 640, 0, 0, 0, 0, 1, 0, -1, -1, '', '');

INSERT INTO `spawnentry` (`spawngroupID`,`npcid`,`chance`) VALUES
 (923000,999300,100),
 (923001,999301,100),
 (923002,999302,100),
 (923003,999303,100),
 (923004,999304,100),
 (923005,999305,100),
 (923006,999306,25),
 (923007,999307,100),
 (923008,397248,100),
 (923008,397254,100),
 (923008,397252,100);

-- ===========================================================================
-- Ground spawn: Shattered Krithgor Keystone, Icefall Glacier near the spell vendors
-- ===========================================================================
DELETE FROM `ground_spawns` WHERE `id` = 3500;
INSERT INTO `ground_spawns`
 (`id`,`zoneid`,`version`,`max_x`,`max_y`,`max_z`,`min_x`,`min_y`,`heading`,`name`,`item`,
  `max_allowed`,`comment`,`respawn_timer`,`fix_z`,`min_expansion`,`max_expansion`,
  `content_flags`,`content_flags_disabled`)
VALUES
 (3500,175,0, -1150,-2030,0, -1160,-2040, 0,'IT63_ACTORDEF',58733,1,
  'Shattered Krithgor Keystone - Charm of Lore artifact',640,1,-1,-1,'','');
