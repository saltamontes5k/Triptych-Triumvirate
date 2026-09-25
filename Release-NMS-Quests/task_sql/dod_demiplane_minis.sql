-- ---------------------------------------------------------------------------
-- Depths of Darkhollow - Demi-Plane Mini Named + Duskstone drops
--
-- Spawns the five Demi-Plane mini-named (Maggotmiser, Madrillah the Ancient,
-- Swirling Bloodspirit, Ur-Goloch, Legionnaire Silkbinder) which are absent
-- from the stock DB, and wires the Duskstone / Third Vampire raidloot set.
--
-- Idempotent: explicit ids, temp-table clone + INSERT IGNORE, loot rebuilt each
-- run. Apply with: mariadb -u <user> -p <db> < dod_demiplane_minis.sql
-- ---------------------------------------------------------------------------

DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc AS SELECT * FROM npc_types WHERE id = 351165;

UPDATE tmp_npc SET id = 900210, name = 'Maggotmiser',              loottable_id = 900410; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900211, name = 'Madrillah_the_Ancient',    loottable_id = 900410; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900212, name = 'Swirling_Bloodspirit',     loottable_id = 900410; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900213, name = 'Ur-Goloch',                loottable_id = 900410; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900214, name = 'Legionnaire_Silkbinder',   loottable_id = 900410; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_npc;

INSERT IGNORE INTO spawngroup (id, name) VALUES
	(900210, 'Maggotmiser_dreadspire'), (900211, 'Madrillah_dreadspire'),
	(900212, 'Bloodspirit_dreadspire'), (900213, 'Ur-Goloch_dreadspire'),
	(900214, 'Silkbinder_dreadspire');

INSERT IGNORE INTO spawnentry (spawngroupID, npcID) VALUES
	(900210, 900210), (900211, 900211), (900212, 900212), (900213, 900213), (900214, 900214);

INSERT IGNORE INTO spawn2
	(id, spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, min_expansion, max_expansion)
VALUES
	(900210, 900210, 'dreadspire', 1, -700, 2900, 128, 0, 640, 0, 0, 0, -1, -1),
	(900211, 900211, 'dreadspire', 1,  850, 2800, 128, 0, 640, 0, 0, 0, -1, -1),
	(900212, 900212, 'dreadspire', 1,    0, 3400, 128, 0, 640, 0, 0, 0, -1, -1),
	(900213, 900213, 'dreadspire', 1, -800, 3200, 128, 0, 640, 0, 0, 0, -1, -1),
	(900214, 900214, 'dreadspire', 1,  900, 3300, 128, 0, 640, 0, 0, 0, -1, -1);

-- Loot: Mini Named (Duskstones + Third Vampire pieces) -----------------------
INSERT IGNORE INTO loottable (id, name, mincash, maxcash, avgcoin, done, min_expansion, max_expansion)
VALUES (900410, 'Demi-Plane Mini Named', 8, 800, 0, 0, -1, -1);

INSERT IGNORE INTO lootdrop (id, name) VALUES (900410, 'Demi-Plane Mini Named loot');

DELETE FROM lootdrop_entries WHERE lootdrop_id = 900410;

INSERT INTO lootdrop_entries
	(lootdrop_id, item_id, item_charges, equip_item, chance, disabled_chance, trivial_min_level, trivial_max_level, multiplier, npc_min_level, npc_max_level, min_expansion, max_expansion)
VALUES
	(900410, 89630, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Duskstone of the Marshes
	(900410, 89631, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Duskstone of the White Cliffs
	(900410, 89632, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Duskstone of the Deserts
	(900410, 89633, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Duskstone of the Sand Flats
	(900410, 89634, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Duskstone of the Mountains
	(900410, 89635, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Duskstone of the Reefs
	(900410, 89636, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Duskstone of the Forests
	(900410, 89637, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Duskstone of the Tundra
	(900410, 89638, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Duskstone of the Oceans
	(900410, 89639, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Mind of the Third Vampire
	(900410, 89640, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Left Eye of the Third Vampire
	(900410, 89641, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1), -- Right Eye of the Third Vampire
	(900410, 89643, 1, 1, 8, 0, 0, 0, 1, 0, 0, -1, -1); -- Fang of the Third Vampire

INSERT IGNORE INTO loottable_entries (loottable_id, lootdrop_id, multiplier, droplimit, mindrop, probability)
VALUES (900410, 900410, 1, 2, 1, 100);