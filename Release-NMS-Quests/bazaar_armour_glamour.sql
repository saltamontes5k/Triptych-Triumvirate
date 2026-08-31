-- ------------------------------------------------------------------
-- Purveyor of Armour Glamour: armour ornament NPC for the Bazaar
-- Companion to the existing Purveyor of Glamour (weapon ornaments).
-- Hail her for info; hand in 5000pp for a random Hero Forge
-- armour ornament, or pay 2 Echo of Memory for a random one.
--
-- Applies to db 'peq'. Safe to re-run (deletes its own rows first).
--   npc_types  id 1120001110
--   spawngroup id 5003550
--   spawn2     id 2141650  (zone bazaar, version 0)
-- Spawn point: right next to existing Purveyor, x 149.28 / y -592.26 / z 3.23
-- ------------------------------------------------------------------

DELETE FROM spawnentry WHERE spawngroupID = 5003550;
DELETE FROM spawn2     WHERE id = 2141650;
DELETE FROM spawngroup WHERE id = 5003550;
DELETE FROM npc_types  WHERE id = 1120001110;

INSERT INTO npc_types (
	id, name, lastname, level, race, class, bodytype, hp, mana,
	gender, texture, helmtexture, size, hp_regen_rate, mana_regen_rate,
	loottable_id, merchant_id, npc_faction_id,
	mindmg, maxdmg, attack_count, npcspecialattks, special_abilities, aggroradius,
	face, d_melee_texture1, d_melee_texture2, ammo_idfile,
	STR, STA, DEX, AGI, `_INT`, WIS, CHA,
	trackable, isbot, exclude, version, scalerate, isquest,
	spellscale, healscale, exp_mod
) VALUES (
	1120001110, 'Purveyor_of_Armour_Glamour', 'Armour Ornaments', 70, 5, 1, 1, 43854, 0,
	1, 1, 0, 6, 0, 0,
	0, 0, 0,
	0, 0, -1, '', '24,1^25,1^35,1^39,1', 0,
	0, 11113, 10754, 'IT10',
	75, 75, 75, 75, 80, 75, 75,
	1, 0, 1, 0, 100, 0,
	100, 100, 100
);

INSERT INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
VALUES (5003550, 'bazaar-Purveyor_of_Armour_Glamour000', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0);

INSERT INTO spawnentry (spawngroupID, npcID, chance, condition_value_filter, min_time, max_time, min_expansion, max_expansion)
VALUES (5003550, 1120001110, 100, 1, 0, 0, -1, -1);

INSERT INTO spawn2 (
	id, spawngroupID, zone, version, x, y, z, heading,
	respawntime, variance, pathgrid, path_when_zone_idle,
	`_condition`, cond_value, animation, min_expansion, max_expansion
) VALUES (
	2141650, 5003550, 'bazaar', 0, 149.280000, -592.260000, 3.230000, 321.250000,
	1200, 0, 0, 0,
	0, 1, 0, -1, -1
);
