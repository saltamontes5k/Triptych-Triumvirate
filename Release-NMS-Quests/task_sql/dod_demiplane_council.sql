-- ---------------------------------------------------------------------------
-- Depths of Darkhollow - Demi-Plane named + Council of Nine
--
-- Adds the missing Demi-Plane of Blood named (only Hatchet the Torturer was
-- spawned) plus a functional Council of Nine event, and wires their raidloot
-- item sets (all items already exist in `items`).
--
-- NPC bodies for the new named are cloned from Hatchet the Torturer (351165) so
-- they inherit sane race/appearance/flags. Idempotent: explicit ids + DROP
-- TEMPORARY TABLE guard; loot lists are cleared and rebuilt each run.
-- ---------------------------------------------------------------------------

-- 1. Demi-Plane named NPCs (dreadspire v1) ------------------------------------
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc AS SELECT * FROM npc_types WHERE id = 351165;

UPDATE tmp_npc SET id = 900201, name = 'Zi-Thuuli_of_the_Granite_Claw', loottable_id = 900401; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900202, name = 'Sanguimanus_the_Redfang',      loottable_id = 900403; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900203, name = 'The_Wailing_Sisters',          loottable_id = 900404; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900204, name = 'Devlin_Rochester',             loottable_id = 900405; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900205, name = 'Roley_DeFarge',                loottable_id = 900406; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900206, name = 'Tris_Wallow_III',              loottable_id = 900407; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900207, name = 'The_Performer',                loottable_id = 900408; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900208, name = 'The_Council_of_Nine',          loottable_id = 900409; INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
UPDATE tmp_npc SET id = 900209, name = 'a_councilor_of_the_nine',      loottable_id = 0;      INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_npc;

-- Hatchet already exists; just give it its raid loot table
UPDATE npc_types SET loottable_id = 900402 WHERE id = 351165;

-- 2. Spawns -------------------------------------------------------------------
INSERT IGNORE INTO spawngroup (id, name) VALUES
	(900201, 'Zi-Thuuli_dreadspire'), (900202, 'Sanguimanus_dreadspire'),
	(900203, 'Wailing_Sisters_dreadspire'), (900204, 'Devlin_dreadspire'),
	(900205, 'Roley_dreadspire'), (900206, 'Tris_dreadspire'),
	(900207, 'Performer_dreadspire'), (900208, 'Council_of_Nine_eastkorlach');

INSERT IGNORE INTO spawnentry (spawngroupID, npcID) VALUES
	(900201, 900201), (900202, 900202), (900203, 900203), (900204, 900204),
	(900205, 900205), (900206, 900206), (900207, 900207), (900208, 900208);

INSERT IGNORE INTO spawn2
	(id, spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, min_expansion, max_expansion)
VALUES
	(900201, 900201, 'dreadspire', 1, -100, 2800, 128, 0, 640, 0, 0, 0, -1, -1),
	(900202, 900202, 'dreadspire', 1,  650, 2600, 128, 0, 640, 0, 0, 0, -1, -1),
	(900203, 900203, 'dreadspire', 1,  100, 3200, 128, 0, 640, 0, 0, 0, -1, -1),
	(900204, 900204, 'dreadspire', 1, -350, 3000, 128, 0, 640, 0, 0, 0, -1, -1),
	(900205, 900205, 'dreadspire', 1,  700, 3100, 128, 0, 640, 0, 0, 0, -1, -1),
	(900206, 900206, 'dreadspire', 1, -500, 2700, 128, 0, 640, 0, 0, 0, -1, -1),
	(900207, 900207, 'dreadspire', 1,  550, 2450, 128, 0, 640, 0, 0, 0, -1, -1),
	(900208, 900208, 'eastkorlach', 0, -1000, -1250, 184, 0, 640, 0, 0, 0, -1, -1);

-- 3. Loot tables --------------------------------------------------------------
INSERT IGNORE INTO loottable (id, name, mincash, maxcash, avgcoin, done, min_expansion, max_expansion) VALUES
	(900401, 'Zi-Thuuli of the Granite Claw', 8, 800, 0, 0, -1, -1),
	(900402, 'Hatchet the Torturer',           8, 800, 0, 0, -1, -1),
	(900403, 'Sanguimanus the Redfang',        8, 800, 0, 0, -1, -1),
	(900404, 'The Wailing Sisters',            8, 800, 0, 0, -1, -1),
	(900405, 'Devlin Rochester',               8, 800, 0, 0, -1, -1),
	(900406, 'Roley DeFarge',                  8, 800, 0, 0, -1, -1),
	(900407, 'Tris Wallow III',                8, 800, 0, 0, -1, -1),
	(900408, 'The Performer',                  8, 800, 0, 0, -1, -1),
	(900409, 'The Council of Nine',            8, 800, 0, 0, -1, -1);

INSERT IGNORE INTO lootdrop (id, name) VALUES
	(900401, 'Zi-Thuuli raid loot'), (900402, 'Hatchet raid loot'),
	(900403, 'Sanguimanus raid loot'), (900404, 'Wailing Sisters raid loot'),
	(900405, 'Devlin raid loot'), (900406, 'Roley raid loot'),
	(900407, 'Tris raid loot'), (900408, 'Performer raid loot'),
	(900409, 'Council of Nine raid loot');

DELETE FROM lootdrop_entries WHERE lootdrop_id BETWEEN 900401 AND 900409;

INSERT INTO lootdrop_entries
	(lootdrop_id, item_id, item_charges, equip_item, chance, disabled_chance, trivial_min_level, trivial_max_level, multiplier, npc_min_level, npc_max_level, min_expansion, max_expansion)
VALUES
	-- Zi-Thuuli of the Granite Claw
	(900401, 83564, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83565, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83566, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83567, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83577, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83579, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83585, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83586, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83593, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83595, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900401, 83601, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	-- Hatchet the Torturer
	(900402, 83572, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83573, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83574, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83575, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83576, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83581, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83587, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83590, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83594, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83596, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900402, 83599, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	-- Sanguimanus the Redfang
	(900403, 83560, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83561, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83562, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83563, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83580, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83583, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83584, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83591, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83592, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83598, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900403, 83643, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	-- The Wailing Sisters
	(900404, 83568, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83569, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83570, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83571, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83578, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83582, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83588, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83589, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83597, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83600, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	(900404, 83602, 1, 1, 9, 0, 0, 0, 1, 0, 0, -1, -1),
	-- Devlin Rochester
	(900405, 83604, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83608, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83613, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83616, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83622, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83624, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83627, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83633, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83637, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83640, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83645, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 83649, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900405, 88036, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	-- Roley DeFarge
	(900406, 83603, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83607, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83612, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83615, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83617, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83622, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83625, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83629, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83631, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83634, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83639, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83641, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900406, 83646, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	-- Tris Wallow III
	(900407, 83606, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83610, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83614, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83620, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83621, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83626, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83628, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83632, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83638, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83647, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83648, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 83651, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900407, 88036, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	-- The Performer
	(900408, 83605, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83609, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83611, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83618, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83619, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83623, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83630, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83635, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83636, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83642, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83644, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 83650, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	(900408, 88036, 1, 1, 7, 0, 0, 0, 1, 0, 0, -1, -1),
	-- The Council of Nine
	(900409, 83502, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1),
	(900409, 83503, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1),
	(900409, 83504, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1),
	(900409, 83505, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1),
	(900409, 83506, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1),
	(900409, 83507, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1),
	(900409, 83508, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1),
	(900409, 83509, 1, 1, 12, 0, 0, 0, 1, 0, 0, -1, -1);

INSERT IGNORE INTO loottable_entries (loottable_id, lootdrop_id, multiplier, droplimit, mindrop, probability) VALUES
	(900401, 900401, 1, 2, 1, 100),
	(900402, 900402, 1, 2, 1, 100),
	(900403, 900403, 1, 2, 1, 100),
	(900404, 900404, 1, 2, 1, 100),
	(900405, 900405, 1, 2, 1, 100),
	(900406, 900406, 1, 2, 1, 100),
	(900407, 900407, 1, 2, 1, 100),
	(900408, 900408, 1, 2, 1, 100),
	(900409, 900409, 1, 2, 1, 100);

-- ===========================================================================
-- G2 (instance): the Council of Nine raid also runs in illsalinb version 1
-- ---------------------------------------------------------------------------
-- The stock illsalinb v1 encounter (#The_Presence_of_the_Nine, #Avatar_of_the_
-- Council, 9x The_Council) is the instanced raid. The custom open-world Council
-- (900208, eastkorlach v0) above is unchanged. Give the instance boss the raid
-- loot table; illsalinb/#Avatar_of_the_Council.lua grants the Curse of Blood.
-- Idempotent.
-- ===========================================================================
UPDATE `npc_types` SET `loottable_id` = 900409 WHERE `id` = 349030; -- #Avatar_of_the_Council (illsalinb v1)