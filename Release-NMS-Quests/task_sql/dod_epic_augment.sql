-- ---------------------------------------------------------------------------
-- Depths of Darkhollow - "An Epic Augment" turn-in
--
-- The 16 Shard of the Ancients augments (89471-89486) had no quest NPC. This
-- adds "The_Keeper_of_Ancients" in the Demi-Plane (dreadspire v1) who consumes
-- the complete set and forges the reward augment.
--
-- NOTE: the live reward for this quest could not be determined from available
-- sources, so the reward item (900500 "An Epic Augment") is an NMS-authored
-- functional stand-in with stats scaled to the DoD raid tier. Adjust as needed.
--
-- Idempotent: explicit ids + INSERT IGNORE / temp-table clone guard.
-- ---------------------------------------------------------------------------

-- Reward item ----------------------------------------------------------------
INSERT IGNORE INTO items
	(id, Name, itemtype, slots, augtype, classes, races, reqlevel, reclevel, ac, hp, mana, endur,
	 astr, asta, aagi, adex, awis, aint, acha, mr, fr, cr, dr, pr, magic, nodrop, weight, size, icon)
VALUES
	(900503, 'An Epic Augment', 54, 24576, 536870912, 65535, 65535, 70, 75, 40, 400, 400, 400,
	 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 1, 1, 0, 0, 1443);

-- Keeper NPC -----------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc AS SELECT * FROM npc_types WHERE id = 351165;
UPDATE tmp_npc SET id = 900215, name = 'The_Keeper_of_Ancients', loottable_id = 0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_npc;

INSERT IGNORE INTO spawngroup (id, name) VALUES (900215, 'Keeper_of_Ancients_dreadspire');
INSERT IGNORE INTO spawnentry (spawngroupID, npcID) VALUES (900215, 900215);
INSERT IGNORE INTO spawn2
	(id, spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, min_expansion, max_expansion)
VALUES
	(900215, 900215, 'dreadspire', 1, 1250, -1100, -560, 0, 640, 0, 0, 0, -1, -1);

-- Shard source ---------------------------------------------------------------
-- The 16 shards had no drop source; make them a shared rare drop from the
-- Demi-Plane named (900401-900408) and mini-named (900410).
INSERT IGNORE INTO lootdrop (id, name) VALUES (900411, 'Shard of the Ancients (Demi-Plane quest)');

DELETE FROM lootdrop_entries WHERE lootdrop_id = 900411;

INSERT INTO lootdrop_entries
	(lootdrop_id, item_id, item_charges, equip_item, chance, disabled_chance, trivial_min_level, trivial_max_level, multiplier, npc_min_level, npc_max_level, min_expansion, max_expansion)
VALUES
	(900411, 89471, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89472, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89473, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89474, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89475, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89476, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89477, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89478, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89479, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89480, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89481, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89482, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89483, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89484, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89485, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1),
	(900411, 89486, 1, 1, 6, 0, 0, 0, 1, 0, 0, -1, -1);

INSERT IGNORE INTO loottable_entries (loottable_id, lootdrop_id, multiplier, droplimit, mindrop, probability) VALUES
	(900401, 900411, 1, 1, 0, 60),
	(900402, 900411, 1, 1, 0, 60),
	(900403, 900411, 1, 1, 0, 60),
	(900404, 900411, 1, 1, 0, 60),
	(900405, 900411, 1, 1, 0, 60),
	(900406, 900411, 1, 1, 0, 60),
	(900407, 900411, 1, 1, 0, 60),
	(900408, 900411, 1, 1, 0, 60),
	(900410, 900411, 1, 1, 0, 60);