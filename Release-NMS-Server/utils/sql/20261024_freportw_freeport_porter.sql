-- 2026-10-24 West Freeport: Freeport Porter to the Prophecy of Ro city
-- Freeport_Porter (npc 1120002385) is a clone of the southro PoR_Porter
-- (1120001419; race 8 halfling, level 35) joining the expansion-porter family.
-- He stands beside Glyssa Sonshaw (npc 9067, spawn2 9064, group 1441, at
-- -651, 164, -52.13 heading 316) in classic freportw at (-646, 170, -52.1),
-- facing her. Hail -> [ready] in quests/freportw/Freeport_Porter.lua ports to
-- freeportwest (zone 383) at the East Commonlands gate arrival (339, 12, -23).
-- Deliberately ungated: freeportwest is already walk-in via the ungated
-- commonlands zone line (zone_points 1577, min/max expansion -1).
-- Spawngroup 500105 continues the porter band 500100-500104; spawn2
-- 1520023801 continues the 1520023xxx generated band.
-- Twin of manifest entry 230. Rollback: 20261024_freportw_freeport_porter_rollback.sql.

DROP TABLE IF EXISTS nms_tmp_freeport_porter;

CREATE TABLE nms_tmp_freeport_porter AS
  SELECT * FROM npc_types WHERE id = 1120001419;

UPDATE nms_tmp_freeport_porter
   SET id = 1120002385,
       name = 'Freeport_Porter';

INSERT INTO npc_types SELECT * FROM nms_tmp_freeport_porter;

DROP TABLE IF EXISTS nms_tmp_freeport_porter;

INSERT INTO `spawngroup` (`id`, `name`, `spawn_limit`, `delay`, `mindelay`, `despawn_timer`)
VALUES (500105, 'freportw_porter_1120002385', 1, 45000, 15000, 100);

INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`)
VALUES (500105, 1120002385, 100);

INSERT INTO `spawn2` (`id`, `spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `min_expansion`, `max_expansion`)
VALUES (1520023801, 500105, 'freportw', 0, -646, 170, -52.1, 60, 640, -1, -1);

-- Post-condition: porter cloned once, single spawn point beside Glyssa.
SELECT n.id, n.name, n.lastname, s.zone, s.x, s.y, s.z, s.heading
  FROM npc_types n
  JOIN spawnentry se ON se.npcID = n.id
  JOIN spawn2 s ON s.spawngroupID = se.spawngroupID
 WHERE n.id = 1120002385;
