-- Depths of Darkhollow: "Spies Like Them" (mission 08).
--
-- Giver: Tisthal_Gimblecranz (365288) in Corathus Creep (corathus, 365).
-- Flow:  loot the Unreadable Book (84057) from Geeble_Tripcrank in the
--        eastern tower of the open Hive -> zone into the "Coven of Skinwalkers"
--        instance (drachnidhive version 6) -> slay 32 skinwalkers -> hand the
--        book back to Tisthal for the lore and the mission reward (85528).
--
-- The Coven of Skinwalkers instance is a new drachnidhive zone version whose
-- population is copied from the open Hive's skinwalker spawngroups, so every
-- coordinate is known-valid for the zone.
--
-- Zones:  drachnidhive (354) version 0 = The Hive (open), version 6 = Coven of Skinwalkers
--         corathus (365) = Corathus Creep
-- Items:  84057 Unreadable Book (drops from Geeble, delivered to Tisthal)
--         85528 mission reward
--         83708/83709/83724/83717 = instance chest loot (83693/83725 absent from this DB)
-- Ids:    zone 9148, npc 354352 (chest) / 354353 (Geeble), loottables 910242/910243,
--         lootdrops 910242/910243, task 505794

-- ---------------------------------------------------------------- cleanup
DELETE FROM spawn2 WHERE zone = 'drachnidhive' AND version IN (0, 6)
	AND spawngroupID IN (SELECT id FROM spawngroup WHERE name IN ('geeble_tripcrank_spies', 'skinwalker_coven_chest'));
DELETE FROM spawnentry WHERE spawngroupID IN (SELECT id FROM spawngroup WHERE name IN ('geeble_tripcrank_spies', 'skinwalker_coven_chest'));
DELETE FROM spawngroup WHERE name IN ('geeble_tripcrank_spies', 'skinwalker_coven_chest');
DELETE FROM spawn2 WHERE zone = 'drachnidhive' AND version = 6;
DELETE FROM npc_types WHERE id IN (354352, 354353);
DELETE FROM loottable_entries WHERE loottable_id IN (910242, 910243);
DELETE FROM lootdrop_entries WHERE lootdrop_id IN (910242, 910243);
DELETE FROM loottable WHERE id IN (910242, 910243);
DELETE FROM lootdrop WHERE id IN (910242, 910243);
DELETE FROM zone WHERE id = 9148;
DELETE FROM task_activities WHERE taskid = 505794;
DELETE FROM tasks WHERE id = 505794;

-- ---------------------------------------------------------------- zone: Coven of Skinwalkers (drachnidhive v6)
CREATE TEMPORARY TABLE _tmp_zone AS SELECT * FROM zone WHERE id = 6010;
UPDATE _tmp_zone SET id = 9148, version = 6, long_name = 'The Hive: Coven of Skinwalkers';
INSERT INTO zone SELECT * FROM _tmp_zone;
DROP TEMPORARY TABLE _tmp_zone;

-- ---------------------------------------------------------------- spawns: instance population (skinwalker spawngroups from the open Hive)
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation, min_expansion, max_expansion)
SELECT s2.spawngroupID, 'drachnidhive', 6, s2.x, s2.y, s2.z, s2.heading, s2.respawntime, s2.variance, s2.pathgrid, s2.path_when_zone_idle, s2._condition, s2.cond_value, s2.animation, s2.min_expansion, s2.max_expansion
FROM spawn2 s2
WHERE s2.zone = 'drachnidhive' AND s2.version = 0
	AND s2.spawngroupID IN (
		SELECT DISTINCT s2b.spawngroupID
		FROM spawn2 s2b
		JOIN spawnentry se ON se.spawngroupID = s2b.spawngroupID
		JOIN npc_types n ON n.id = se.npcID
		WHERE s2b.zone = 'drachnidhive' AND s2b.version = 0 AND n.name LIKE 'a_skinwalker\_%'
	);

-- ---------------------------------------------------------------- npc: Geeble_Tripcrank (open Hive, eastern tower)
CREATE TEMPORARY TABLE _tmp_npc AS SELECT * FROM npc_types WHERE id = 354054;
UPDATE _tmp_npc SET id = 354353, name = 'Geeble_Tripcrank', level = 70, race = 12, class = 1, npc_faction_id = 1357, loottable_id = 910242;
INSERT INTO npc_types SELECT * FROM _tmp_npc;
DROP TEMPORARY TABLE _tmp_npc;

-- ---------------------------------------------------------------- npc: instance chest
CREATE TEMPORARY TABLE _tmp_chest AS SELECT * FROM npc_types WHERE id = 354201;
UPDATE _tmp_chest SET id = 354352, name = 'a_skinwalker_chest', level = 68, loottable_id = 910243;
INSERT INTO npc_types SELECT * FROM _tmp_chest;
DROP TEMPORARY TABLE _tmp_chest;

-- ---------------------------------------------------------------- spawn groups
INSERT INTO spawngroup (name) VALUES ('geeble_tripcrank_spies');
SET @sg_geeble = LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@sg_geeble, 354353, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation, min_expansion, max_expansion)
VALUES (@sg_geeble, 'drachnidhive', 0, 1200, -400, 90, 0, 900, 0, 0, 0, 0, 1, 0, -1, -1);

INSERT INTO spawngroup (name) VALUES ('skinwalker_coven_chest');
SET @sg_chest = LAST_INSERT_ID();
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (@sg_chest, 354352, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation, min_expansion, max_expansion)
VALUES (@sg_chest, 'drachnidhive', 6, 500, -400, 90, 0, 900, 0, 0, 0, 0, 1, 0, -1, -1);

-- ---------------------------------------------------------------- loot
INSERT INTO lootdrop (id, name) VALUES (910242, 'Geeble_Tripcrank_Spies');
INSERT INTO lootdrop_entries (lootdrop_id, item_id, item_charges, equip_item, chance, multiplier, npc_min_level, npc_max_level, min_expansion, max_expansion)
VALUES (910242, 84057, 1, 0, 100, 1, 0, 0, -1, -1);
INSERT INTO loottable (id, name) VALUES (910242, 'Geeble_Tripcrank_Spies');
INSERT INTO loottable_entries (loottable_id, lootdrop_id, multiplier, droplimit, mindrop, probability)
VALUES (910242, 910242, 1, 0, 1, 100);

INSERT INTO lootdrop (id, name) VALUES (910243, 'Coven_of_Skinwalkers_Chest');
INSERT INTO lootdrop_entries (lootdrop_id, item_id, item_charges, equip_item, chance, multiplier, npc_min_level, npc_max_level, min_expansion, max_expansion)
VALUES
	(910243, 83708, 1, 0, 100, 1, 0, 0, -1, -1),
	(910243, 83709, 1, 0, 60, 1, 0, 0, -1, -1),
	(910243, 83724, 1, 0, 60, 1, 0, 0, -1, -1),
	(910243, 83717, 1, 0, 60, 1, 0, 0, -1, -1);
INSERT INTO loottable (id, name) VALUES (910243, 'Coven_of_Skinwalkers_Chest');
INSERT INTO loottable_entries (loottable_id, lootdrop_id, multiplier, droplimit, mindrop, probability)
VALUES (910243, 910243, 1, 0, 1, 100);

-- ---------------------------------------------------------------- task: Spies Like Them
INSERT INTO tasks (id, type, duration, duration_code, title, description, reward_text, reward_id_list, cash_reward, exp_reward, reward_method, reward_points, reward_point_type, min_level, max_level, level_spread, min_players, max_players, repeatable, faction_reward, completion_emote, replay_timer_group, replay_timer_seconds, request_timer_group, request_timer_seconds, dz_template_id, lock_activity_id, faction_amount, enabled)
VALUES (505794, 2, 0, 0,
	'Spies Like Them',
	'Geeble Tripcrank has been meeting with the skinwalkers. Recover his Unreadable Book from the eastern tower of the Hive, then descend into the Coven of Skinwalkers and put an end to their plotting.',
	'You have broken the skinwalker spy ring.',
	'85528', 0, 0, 0, 0, 0, 68, 0, 0, 1, 6, 1, 0, '', 0, 0, 0, 0, 0, 0, 0, 1);

INSERT INTO task_activities (taskid, activityid, req_activity_id, step, activitytype, target_name, goalmethod, goalcount, description_override, npc_match_list, item_id_list, item_list, dz_switch_id, min_x, min_y, min_z, max_x, max_y, max_z, skill_list, spell_list, zones, zone_version, optional, list_group)
VALUES
	(505794, 0, -1, 1, 3, 'Geeble Tripcrank''s Unreadable Book', 0, 1,
		'Recover the Unreadable Book from Geeble Tripcrank in the eastern tower of the Hive.',
		'354353', '84057', '', 0, 0, 0, 0, 0, 0, 0, '', '', '354', -1, 0, 0),
	(505794, 1, 0, 2, 2, 'skinwalkers', 0, 32,
		'Slay the skinwalkers within the Coven of Skinwalkers.',
		'354044|354046|354054|354061|354067|354071|354080|354081|354084|354088|354089|354097|354101|354147|354148|354154|354158|354161|354162|354163|354165|354170|354171|354172|354175|354200|354205|354209|354223|354224|354225|354226|354230|354231|354232|354271|354272|354276|354279|354282|354283|354285|354286|354295|354296|354297|354298|354299|354302|354327|354330|354332|354334|354335|354337|354343|354344|354345|354347|354349|354350|354351',
		'', '', 0, 0, 0, 0, 0, 0, 0, '', '', '354', -1, 0, 0),
	(505794, 2, 1, 3, 1, 'Tisthal Gimblecranz', 0, 1,
		'Return the Unreadable Book to Tisthal Gimblecranz in Corathus Creep.',
		'365288', '84057', '', 0, 0, 0, 0, 0, 0, 0, '', '', '-1', -1, 0, 0);
