-- Spirit Shroud catalog per live DoD layout (Bonzz taxonomy).
-- 8 progressions, 34 creature templates, level tiers 5-70 (every 5th).
-- Stats are derived from base_data (level x class) at apply time in SQL so the
-- shroud window's stats pane shows real numbers instead of placeholders.
-- Races/textures/sizes sampled from live npc_types; Imp keeps race 130 (the
-- model proven working in this client).
-- Overseer shrouds and anniversary/claim shrouds (Runed Gargoyle, Gnoll) are
-- intentionally NOT included.

DELETE FROM `shrouds`;

INSERT INTO `shrouds`
	(`name`, `progression`, `branch`, `level`, `race`, `gender`, `class`, `texture`, `helmet_texture`, `size`, `hp`, `mana`, `endurance`)
SELECT
	CONCAT(t.`name`, ' ', b.`level`),
	t.`progression`,
	t.`name`,
	b.`level`,
	t.`race`,
	2,
	t.`class`,
	t.`texture`,
	255,
	t.`size`,
	CAST(ROUND(5 + b.`hp` + b.`hp_fac` * 75) AS SIGNED),                       -- ~STA 75
	CASE WHEN b.`mana` > 0 THEN CAST(ROUND(b.`mana` + b.`mana_fac` * 75) AS SIGNED) ELSE 0 END, -- ~INT/WIS 75
	CAST(ROUND(b.`end` + b.`end_fac` * 75) AS SIGNED)
FROM (
	-- Aberrations
	SELECT 'Imp Wizard' AS `name`, 'Aberrations' AS `progression`, 130 AS `race`, 12 AS `class`, 1 AS `texture`, 5 AS `size`
	UNION ALL SELECT 'Evil Eye Psion', 'Aberrations', 21, 14, 0, 6
	UNION ALL SELECT 'Evil Eye Sorcerer', 'Aberrations', 21, 12, 0, 6
	UNION ALL SELECT 'Imp Trickster', 'Aberrations', 130, 14, 1, 5
	UNION ALL SELECT 'Gargoyle Fighter', 'Aberrations', 464, 1, 3, 2.5
	-- Animals
	UNION ALL SELECT 'Bear Beast', 'Animals', 43, 1, 0, 6
	UNION ALL SELECT 'Wolf Beast', 'Animals', 42, 16, 0, 6
	UNION ALL SELECT 'Tiger Beast', 'Animals', 439, 16, 4, 4
	UNION ALL SELECT 'Werewolf Beast', 'Animals', 14, 16, 0, 6
	-- Elementals
	UNION ALL SELECT 'Earth Elemental Fighter', 'Elementals', 209, 1, 0, 6
	UNION ALL SELECT 'Water Elemental Cleric', 'Elementals', 211, 2, 0, 6
	UNION ALL SELECT 'Fire Elemental Wizard', 'Elementals', 212, 12, 0, 6
	UNION ALL SELECT 'Air Elemental Illusionist', 'Elementals', 210, 14, 0, 6
	-- Goblinoid
	UNION ALL SELECT 'Goblin Rogue', 'Goblinoid', 433, 9, 7, 3
	UNION ALL SELECT 'Orc Brute', 'Goblinoid', 54, 1, 0, 8
	UNION ALL SELECT 'Goblin Cleric', 'Goblinoid', 433, 2, 7, 3
	UNION ALL SELECT 'Goblin Wizard', 'Goblinoid', 433, 12, 7, 3
	UNION ALL SELECT 'Orc Battle Rager', 'Goblinoid', 54, 16, 0, 8
	-- Humanoid
	UNION ALL SELECT 'Kobold Cleric', 'Humanoid', 455, 2, 2, 3
	UNION ALL SELECT 'Kobold Rogue', 'Humanoid', 455, 9, 2, 3
	UNION ALL SELECT 'Minotaur Brute', 'Humanoid', 470, 1, 0, 2.5
	UNION ALL SELECT 'Minotaur Berserker', 'Humanoid', 470, 16, 0, 2.5
	-- Nature Spirits
	UNION ALL SELECT 'Fairy Trickster', 'Nature Spirits', 473, 14, 0, 1.5
	UNION ALL SELECT 'Fairy Wizard', 'Nature Spirits', 473, 12, 0, 1.5
	UNION ALL SELECT 'Fairy Cleric', 'Nature Spirits', 473, 2, 0, 1.5
	UNION ALL SELECT 'Sporali Spore Wielder', 'Nature Spirits', 456, 14, 2, 5
	UNION ALL SELECT 'Sporali Cleric', 'Nature Spirits', 456, 2, 2, 5
	-- Reptiles
	UNION ALL SELECT 'Basilisk Beast', 'Reptiles', 91, 16, 1, 10
	UNION ALL SELECT 'Scaled Wolf Beast', 'Reptiles', 42, 16, 0, 6
	UNION ALL SELECT 'Raptor Beast', 'Reptiles', 163, 16, 1, 5
	-- Undead
	UNION ALL SELECT 'Skeleton Wizard', 'Undead', 161, 12, 0, 6
	UNION ALL SELECT 'Zombie Fighter', 'Undead', 70, 1, 0, 6
	UNION ALL SELECT 'Scarecrow Mind Bender', 'Undead', 82, 14, 0, 6
	UNION ALL SELECT 'Spectre Ethereal Stalker', 'Undead', 85, 12, 0, 10
) t
JOIN base_data b
	ON b.`level` IN (5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70)
	AND b.`class` = t.`class`
ORDER BY t.`progression`, t.`name`, b.`level`;

-- Sanity: expect 34 templates x 14 levels = 476 rows.
SELECT COUNT(*) AS shroud_rows, COUNT(DISTINCT `progression`) AS progressions, COUNT(DISTINCT `branch`) AS templates
FROM `shrouds`;
