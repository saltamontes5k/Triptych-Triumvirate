-- ---------------------------------------------------------------------------
-- Depths of Darkhollow - mission clicky loot (NMS server)
--
-- Pragmatic distribution for the DoD group-mission clickies whose missions are
-- not implemented: each item is attached as a drop on a thematically matching
-- existing DoD rare (guaranteed) or instance trash (low chance). No mission
-- arcs are added.
--
-- Scope is the 19 items with no existing source. The remaining mission clickies
-- are already covered elsewhere:
--   * 83307, 83436, 86507, 86515, 86545, 86567, 86635, 86643, 86687, 86715
--     -> utils/sql/peq_sync_B6a_DoD.sql (additive trash loot)
--   * 83863 Faithful Templar Belt -> task 500302 "Preemptive Strike" reward
--
-- Idempotent; collision-free ids (910207-910225). Apply with:
--   mariadb -u <user> -p <db> < dod_mission_loot.sql
-- ---------------------------------------------------------------------------

-- 1. Lootdrops (one per item) -------------------------------------------------
DELETE FROM `loottable_entries` WHERE `lootdrop_id` BETWEEN 910207 AND 910225;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 910207 AND 910225;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 910207 AND 910225;

INSERT INTO `lootdrop` (`id`,`name`,`min_expansion`,`max_expansion`) VALUES
 (910207,'dod_mission_ring_of_dissipation',-1,-1),
 (910208,'dod_mission_blood_fire_wand',-1,-1),
 (910209,'dod_mission_bony_dark_web_ring',-1,-1),
 (910210,'dod_mission_blood_rage_choker',-1,-1),
 (910211,'dod_mission_dark_void_shoulders',-1,-1),
 (910212,'dod_mission_light_amphibian_hide_slippers',-1,-1),
 (910213,'dod_mission_blood_fire_signet',-1,-1),
 (910214,'dod_mission_wurine_ring_of_vigor',-1,-1),
 (910215,'dod_mission_ragepaw_earring_of_vigor',-1,-1),
 (910216,'dod_mission_nighthowl_earring',-1,-1),
 (910217,'dod_mission_shoulderpads_of_levitation',-1,-1),
 (910218,'dod_mission_grand_illsalin_robe',-1,-1),
 (910219,'dod_mission_moonshimmer_earring',-1,-1),
 (910220,'dod_mission_illsalin_royalty_garment',-1,-1),
 (910221,'dod_mission_webweaver_robes',-1,-1),
 (910222,'dod_mission_earring_of_diminutiveness',-1,-1),
 (910223,'dod_mission_mask_of_reassuredness',-1,-1),
 (910224,'dod_mission_stout_mottled_mask',-1,-1),
 (910225,'dod_mission_dark_web_belt',-1,-1);

-- 2. Items (equip_item 0 = it drops, it is not worn by the NPC) ---------------
-- Named/chest targets drop at 100; instance trash drops at 5.
INSERT INTO `lootdrop_entries`
 (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
 (910207,86707,1,0,100,0,0,0,1,0,0,-1,-1), -- Ring of Dissipation      <- westkorlachc rare
 (910208,83827,1,0,  5,0,0,0,1,0,0,-1,-1), -- Blood Fire Wand          <- drachnidhivea trash
 (910209,83781,1,0,  5,0,0,0,1,0,0,-1,-1), -- Bony Dark Web Ring       <- drachnidhiveb trash
 (910210,83774,1,0,100,0,0,0,1,0,0,-1,-1), -- Blood Rage Choker        <- drachnidhive rare
 (910211,83869,1,0,100,0,0,0,1,0,0,-1,-1), -- Dark Void Shoulders      <- eastkorlach rare
 (910212,83953,1,0,  5,0,0,0,1,0,0,-1,-1), -- Light Amphibian Slippers <- illsalinb trash
 (910213,83825,1,0,  5,0,0,0,1,0,0,-1,-1), -- Blood Fire Signet        <- corathusa trash
 (910214,86537,1,0,100,0,0,0,1,0,0,-1,-1), -- Wurine Ring of Vigor     <- drachnidhive rare
 (910215,86583,1,0,100,0,0,0,1,0,0,-1,-1), -- Ragepaw Earring of Vigor <- eastkorlacha rare
 (910216,86605,1,0,100,0,0,0,1,0,0,-1,-1), -- Nighthowl Earring        <- eastkorlach rare
 (910217,86673,1,0,100,0,0,0,1,0,0,-1,-1), -- Shoulderpads of Levitation <- westkorlachc chest
 (910218,83976,1,0, 25,0,0,0,1,0,0,-1,-1), -- Grand Illsalin Robe      <- illsalinc ornate chest
 (910219,86597,1,0,100,0,0,0,1,0,0,-1,-1), -- Moonshimmer Earring      <- eastkorlach rare
 (910220,83968,1,0, 25,0,0,0,1,0,0,-1,-1), -- Illsalin Royalty Garment <- illsalinb guardian
 (910221,83720,1,0,  5,0,0,0,1,0,0,-1,-1), -- Webweaver Robes          <- drachnidhivea trash
 (910222,86735,1,0,100,0,0,0,1,0,0,-1,-1), -- Earring of Diminutiveness <- westkorlacha rare
 (910223,86575,1,0,100,0,0,0,1,0,0,-1,-1), -- Mask of Reassuredness    <- eastkorlacha chest
 (910224,86627,1,0,100,0,0,0,1,0,0,-1,-1), -- Stout Mottled Mask       <- eastkorlacha rare
 (910225,83783,1,0,100,0,0,0,1,0,0,-1,-1); -- Dark Web Belt            <- drachnidhive rare

-- 3. Attach each lootdrop to its target loot table ----------------------------
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
 (91668, 910207, 1, 0, 0, 100), -- #High_Priest_Trelikin (westkorlachc)
 (91574, 910208, 1, 0, 0, 100), -- a_drachnid_augurer (drachnidhivea)
 (91583, 910209, 1, 0, 0, 100), -- a_drachnid_guardian (drachnidhiveb)
 (91572, 910210, 1, 0, 0, 100), -- #Drithnak_the_Exiled (drachnidhive)
 (91765, 910211, 1, 0, 0, 100), -- #Commander_Zygurth (eastkorlach)
 (91413, 910212, 1, 0, 0, 100), -- a_Praetorian_Guard (illsalinb)
 (91826, 910213, 1, 0, 0, 100), -- a_sporali_defender (corathusa)
 (91567, 910214, 1, 0, 0, 100), -- #a_skinwalker_instructor (drachnidhive)
 (91777, 910215, 1, 0, 0, 100), -- #Rage_Biter (eastkorlacha)
 (91766, 910216, 1, 0, 0, 100), -- #General_Veronhar (eastkorlach)
 (91657, 910217, 1, 0, 0, 100), -- #a_dark_mystical_chest (westkorlachc)
 (91430, 910218, 1, 0, 0, 100), -- an_ornate_chest (illsalinc)
 (91767, 910219, 1, 0, 0, 100), -- #Grelang (eastkorlach)
 (91415, 910220, 1, 0, 0, 100), -- Laboratory_Guardian (illsalinb)
 (91575, 910221, 1, 0, 0, 100), -- a_drachnid_champion (drachnidhivea)
 (91655, 910222, 1, 0, 0, 100), -- #Prince_Drillien (westkorlacha)
 (91776, 910223, 1, 0, 0, 100), -- #an_ornate_chest (eastkorlacha)
 (91777, 910224, 1, 0, 0, 100), -- #Rage_Biter (eastkorlacha)
 (91538, 910225, 1, 0, 0, 100); -- #a_drachnid_prophet (drachnidhive)
