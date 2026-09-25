-- ---------------------------------------------------------------------------
-- Depths of Darkhollow raid loot - NMS server
--
-- Corrected against raidloot.com (DoD Tier 1 / Tier 2 / Demi-Plane). Every item
-- below already exists in `items`; they were simply absent from every lootdrop.
-- Each boss now drops its real raidloot set (~1-2 items per kill).
--
-- Idempotent: explicit primary keys. Re-running clears and rebuilds each
-- lootdrop's item list, so it converges no matter how many times it is applied.
-- Apply with: mariadb -u <user> -p <db> < dod_raid_loot.sql
-- ---------------------------------------------------------------------------

-- Loot tables (ids kept stable) ----------------------------------------------
INSERT IGNORE INTO `loottable`
	(`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`)
VALUES
	(900301, 'Antraygus, the Sporali King', 8, 800, 0, 0, -1, -1),
	(900302, 'Sendaii, the Hive Queen',     8, 800, 0, 0, -1, -1),
	(900303, 'Bloodeye',                    8, 800, 0, 0, -1, -1),
	(900304, 'Matriarch Shyra',             8, 800, 0, 0, -1, -1),
	(900305, 'Korlach, the Deep Leviathan', 8, 800, 0, 0, -1, -1),
	(900306, 'Emperor Draygun',             8, 800, 0, 0, -1, -1),
	(900307, 'Master Vule - raid drop',     8, 800, 0, 0, -1, -1),
	(900308, 'Mayong Mistmoore - raid drop', 8, 800, 0, 0, -1, -1);

-- Lootdrops -------------------------------------------------------------------
INSERT IGNORE INTO `lootdrop` (`id`,`name`) VALUES
	(900301, 'Antraygus raid loot'),
	(900302, 'Sendaii raid loot'),
	(900303, 'Bloodeye raid loot'),
	(900304, 'Shyra raid loot'),
	(900305, 'Korlach raid loot'),
	(900306, 'Draygun raid loot'),
	(900307, 'Master Vule raid loot'),
	(900308, 'Mayong Mistmoore raid loot');

-- Rebuild item lists (clear first so re-runs converge) -----------------------
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 900301 AND 900308;

INSERT INTO `lootdrop_entries`
	(`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`)
VALUES
	-- Antraygus, the Sporali King (Tier 1)
	(900301, 83486, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Darkhollow Greaves of Tenacity
	(900301, 83487, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Vicious Sporali Chain Vest
	(900301, 83488, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Grimsoul Leggings
	(900301, 83489, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Graypaw Robe
	(900301, 83490, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Shadowblood Ring
	(900301, 83491, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Spiked Sporali Weedbelt
	(900301, 83492, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Heart of Darkhollow Wilds
	(900301, 83493, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Sporali Battle Hammer of Spirits
	-- Sendaii, the Hive Queen (Tier 2)
	(900302, 83540, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Embossed Chitin-Plated Gauntlets
	(900302, 83541, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Elaborate Drachnid-Forged Bands
	(900302, 83542, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Tribal Helm of the Drone
	(900302, 83543, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Embroidered Drachnid Silk Sleeves
	(900302, 83544, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Petrified Drachnid Egg
	(900302, 83545, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Royal Jewel of Protection
	(900302, 83546, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Earring of Frozen Poison
	(900302, 83547, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Envenomed Ritualistic Dagger
	(900302, 83548, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Emblem of the Hive
	(900302, 83549, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Polished Chitin War Horn
	(900302, 89510, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Salt-Encrusted Eyepatch
	-- Bloodeye (Tier 2)
	(900303, 83462, 1, 1, 25, 0, 0, 0, 1, 0, 0, -1, -1), -- Bracer of Blinding Rage
	(900303, 83463, 1, 1, 25, 0, 0, 0, 1, 0, 0, -1, -1), -- Wristband of Seething Rage
	(900303, 83464, 1, 1, 25, 0, 0, 0, 1, 0, 0, -1, -1), -- Stone of Focused Rage
	(900303, 83465, 1, 1, 25, 0, 0, 0, 1, 0, 0, -1, -1), -- Gem of Feral Shielding
	-- Matriarch Shyra (Tier 2)
	(900304, 83494, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Reinforced Helmet of Cold Shadows
	(900304, 83495, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Dreadful Chain Arms of Corruption
	(900304, 83496, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Basilisk Hide Grips
	(900304, 83497, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Jade Water Beach Sandals
	(900304, 83498, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Darter Stone
	(900304, 83499, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Tainted Undershore Rock
	(900304, 83500, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Thick Basilisk Hide Shield
	(900304, 83501, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1), -- Hallowed Bloodclaw of Shadows
	-- Korlach, the Deep Leviathan (Tier 1)
	(900305, 83530, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Imbued Shoulderguards of the Leviathan
	(900305, 83531, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Witheran Scale Mask
	(900305, 83532, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Torn Deathshed Cloak
	(900305, 83533, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Tattered Nargilor-Studded Belt
	(900305, 83534, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Engraved Nargilor Wristguard
	(900305, 83535, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Twisted Bracer of Control
	(900305, 83536, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Blackened Witheran Hide Bracer
	(900305, 83537, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Ancient Wristband of Woven Moss
	(900305, 83538, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Orb of Dark Water
	(900305, 83539, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Shining Longbow of the Leviathan
	(900305, 89308, 1, 1,  9, 0, 0, 0, 1, 0, 0, -1, -1), -- Cord of Nine Lives
	-- Emperor Draygun (Tier 2)
	(900306, 83550, 1, 1, 11, 0, 0, 0, 1, 0, 0, -1, -1), -- Plate Boots of the Lich King
	(900306, 83551, 1, 1, 11, 0, 0, 0, 1, 0, 0, -1, -1), -- Chain Helm of Insanity
	(900306, 83552, 1, 1, 11, 0, 0, 0, 1, 0, 0, -1, -1), -- Leather Sleeves of the Cursed Lich
	(900306, 83553, 1, 1, 11, 0, 0, 0, 1, 0, 0, -1, -1), -- Nargilor-Imbued Silk Mitts
	(900306, 83554, 1, 1, 11, 0, 0, 0, 1, 0, 0, -1, -1), -- Shard of Nargilor Magic
	(900306, 83555, 1, 1, 11, 0, 0, 0, 1, 0, 0, -1, -1), -- Dark Nargilor Shard of Divination
	(900306, 83556, 1, 1, 11, 0, 0, 0, 1, 0, 0, -1, -1), -- Nargilor-Encrusted Ring
	(900306, 83557, 1, 1, 11, 0, 0, 0, 1, 0, 0, -1, -1), -- Lance of the Fallen Shiliskin
	(900306, 83558, 1, 1, 11, 0, 0, 0, 1, 0, 0, -1, -1), -- Buckler of Unliving
	-- Master Vule (Tier 2) - added to the existing 91494 table
	(900307, 83466, 1, 1, 20, 0, 0, 0, 1, 0, 0, -1, -1), -- Vule's Wristcuff
	(900307, 83467, 1, 1, 20, 0, 0, 0, 1, 0, 0, -1, -1), -- Supple Felt Wristwraps
	(900307, 83468, 1, 1, 20, 0, 0, 0, 1, 0, 0, -1, -1), -- Forged Silver Fang
	(900307, 83469, 1, 1, 20, 0, 0, 0, 1, 0, 0, -1, -1), -- Crystallized Teardrop of Vule
	(900307, 88035, 1, 1, 20, 0, 0, 0, 1, 0, 0, -1, -1), -- Vule's Eye
	-- Mayong Mistmoore (Demi-Plane) - added to the existing 110043 table
	(900308, 83652, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Wristplates of the Fallen Saint
	(900308, 83653, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Wristguards of the Vampire Hunter
	(900308, 83654, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Forgotten Artist's Mesh Wristwraps
	(900308, 83655, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Azure Wristcuffs of the Diplomat
	(900308, 83656, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Gaudy Demonhide Buckler
	(900308, 83657, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Moonstone Mind Scepter
	(900308, 83658, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Ali-Ani, the Eyes of Mayong
	(900308, 83659, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Mayong's Sanguine Cloak
	(900308, 83660, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Dometrius, the Master's Burden
	(900308, 83661, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Doomstone Band of Seeing
	(900308, 83662, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Glimmerice, Tserrina's Forgotten Ardor
	(900308, 83663, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Twinfang, the Immortal's Bane
	(900308, 83664, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1), -- Erilynne, the Master's Mistress
	(900308, 83665, 1, 1,  7, 0, 0, 0, 1, 0, 0, -1, -1); -- Vermilion Orb of Clairvoyance

-- Table entries: one boss lootdrop, 1-2 items per kill ------------------------
DELETE FROM `loottable_entries` WHERE `loottable_id` BETWEEN 900301 AND 900306;

INSERT INTO `loottable_entries`
	(`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
VALUES
	(900301, 900301, 1, 2, 1, 100),
	(900302, 900302, 1, 2, 1, 100),
	(900303, 900303, 1, 2, 1, 100),
	(900304, 900304, 1, 2, 1, 100),
	(900305, 900305, 1, 2, 1, 100),
	(900306, 900306, 1, 2, 1, 100);

-- Vule and Mayong use their pre-existing tables; add the DoD raid drop to each
INSERT IGNORE INTO `loottable_entries`
	(`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)
VALUES
	(91494,  900307, 1, 2, 1, 100),
	(110043, 900308, 1, 2, 1, 100);

-- Link the loot tables to the bosses -----------------------------------------
UPDATE `npc_types` SET `loottable_id` = 900301 WHERE `id` = 366028; -- Antraygus, the Sporali King
UPDATE `npc_types` SET `loottable_id` = 900302 WHERE `id` = 357016; -- Sendaii, the Hive Queen
UPDATE `npc_types` SET `loottable_id` = 900303 WHERE `id` = 363029; -- #Bloodeye
UPDATE `npc_types` SET `loottable_id` = 900304 WHERE `id` = 359037; -- Matriarch Shyra
UPDATE `npc_types` SET `loottable_id` = 900305 WHERE `id` = 361048; -- #Korlach, the Deep Leviathan
UPDATE `npc_types` SET `loottable_id` = 900306 WHERE `id` = 350051; -- Emperor_Draygun,_the_Lich_King
UPDATE `npc_types` SET `loottable_id` = 91494  WHERE `id` = 351034; -- #Master_Vule_the_Silent_Tear (existing table)
UPDATE `npc_types` SET `loottable_id` = 110043 WHERE `id` = 351118; -- Mayong_Mistmoore (existing table)