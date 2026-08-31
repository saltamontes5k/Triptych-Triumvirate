-- ------------------------------------------------------------------
-- Greengrocer: halfling campfire provisioner for the Bazaar (NMS custom)
-- Hail him for a stack of Heroes' Blessing and Legends' Blessing.
--
-- Applies to db 'peq'. Safe to re-run (deletes its own rows first).
--   npc_types  id 151257
--   spawngroup id 5003835
--   spawn2     id 3388070  (zone bazaar, version 0)
-- Spawn point: beside the campfire, x -108 / y -820 / z 3.9
-- ------------------------------------------------------------------

DELETE FROM spawnentry WHERE spawngroupID = 5003835;
DELETE FROM spawn2     WHERE id = 3388070;
DELETE FROM spawngroup WHERE id = 5003835;
DELETE FROM npc_types  WHERE id = 151257;

INSERT INTO npc_types (
	id, name, lastname, level, race, class, bodytype, hp, mana,
	gender, texture, helmtexture, size, hp_regen_rate, mana_regen_rate,
	loottable_id, merchant_id, npc_faction_id,
	mindmg, maxdmg, attack_count, npcspecialattks, aggroradius,
	attack_speed, STR, STA, DEX, AGI, `_INT`, WIS, CHA,
	see_invis_undead, qglobal, AC, npc_aggro, spawn_limit,
	trackable, isbot, exclude, version, scalerate, isquest,
	spellscale, healscale, exp_mod
) VALUES (
	151257, 'Greengrocer', 'Blessing Peddler', 65, 11, 1, 1, 9999999, 0,
	0, 1, 0, 3.5, 10000, 10000,
	0, 0, 0,
	15, 51, -1, '', 50,
	0, 75, 75, 75, 75, 80, 75, 75,
	1, 0, 0, 0, 0,
	1, 0, 1, 1, 100, 1,
	100, 100, 100
);

INSERT INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
VALUES (5003835, 'bazaar_greengrocer', 0, 0, 0, 0, 0, 0, 0, 15000, 0, 100, 0);

INSERT INTO spawnentry (spawngroupID, npcID, chance, condition_value_filter, min_time, max_time, min_expansion, max_expansion)
VALUES (5003835, 151257, 100, 1, 0, 0, -1, -1);

INSERT INTO spawn2 (
	id, spawngroupID, zone, version, x, y, z, heading,
	respawntime, variance, pathgrid, path_when_zone_idle,
	`_condition`, cond_value, animation, min_expansion, max_expansion
) VALUES (
	3388070, 5003835, 'bazaar', 0, -108.000000, -820.000000, 3.900000, 250,
	1200, 0, 0, 0,
	0, 1, 0, -1, -1
);
