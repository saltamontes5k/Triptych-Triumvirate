-- ------------------------------------------------------------------
-- Hazel: level-based buff bot NPC for the Bazaar (NMS custom)
-- Hail her for a full bar of level-appropriate buffs.
--
-- Applies to db 'peq'. Safe to re-run (deletes its own rows first).
--   npc_types  id 151256
--   spawngroup id 5003834
--   spawn2     id 3388069  (zone bazaar, version 0)
-- Spawn point: bank plaza, x 97 / y -800 / z 4.75
-- ------------------------------------------------------------------

DELETE FROM spawnentry WHERE spawngroupID = 5003834;
DELETE FROM spawn2     WHERE id = 3388069;
DELETE FROM spawngroup WHERE id = 5003834;
DELETE FROM npc_types  WHERE id = 151256;

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
	151256, 'Hazel', 'Buff Bot', 65, 4, 1, 1, 9999999, 0,
	1, 1, 0, 5, 10000, 10000,
	0, 0, 0,
	15, 51, -1, '', 50,
	0, 75, 75, 75, 75, 80, 75, 75,
	1, 0, 0, 0, 0,
	1, 0, 1, 1, 100, 1,
	100, 100, 100
);

INSERT INTO spawngroup (id, name, spawn_limit, dist, max_x, min_x, max_y, min_y, delay, mindelay, despawn, despawn_timer, wp_spawns)
VALUES (5003834, 'bazaar_hazel_buffbot', 0, 0, 0, 0, 0, 0, 0, 15000, 0, 100, 0);

INSERT INTO spawnentry (spawngroupID, npcID, chance, condition_value_filter, min_time, max_time, min_expansion, max_expansion)
VALUES (5003834, 151256, 100, 1, 0, 0, -1, -1);

INSERT INTO spawn2 (
	id, spawngroupID, zone, version, x, y, z, heading,
	respawntime, variance, pathgrid, path_when_zone_idle,
	`_condition`, cond_value, animation, min_expansion, max_expansion
) VALUES (
	3388069, 5003834, 'bazaar', 0, 97.000000, -800.000000, 4.750000, 126,
	1200, 0, 0, 0,
	0, 1, 0, -1, -1
);
