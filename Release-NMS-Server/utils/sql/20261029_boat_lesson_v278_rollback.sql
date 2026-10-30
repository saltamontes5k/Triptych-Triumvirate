-- Rollback of 278: Old Man McKenzie's Boat Lesson (oot v29 monster mission).
-- Twin of 20261029_boat_lesson_v278.sql. Leaves oot v0 and the world zone
-- row untouched; removes only the version 29 instance content.

DELETE FROM `spawn2` WHERE `spawngroupID` = 5004503;
DELETE FROM `spawnentry` WHERE `spawngroupID` = 5004503;
DELETE FROM `spawngroup` WHERE `id` = 5004503;
DELETE FROM `npc_types` WHERE `id` IN (1520001940,1520001950,1520001951);
DELETE FROM `task_activities` WHERE `taskid` = 800004;
DELETE FROM `tasks` WHERE `id` = 800004;
DELETE FROM `shrouds` WHERE `id` = 502;
DELETE FROM `spawn2` WHERE `zone` = 'oot' AND `version` = 29;
DELETE FROM `zone` WHERE `zoneidnumber` = 69 AND `version` = 29;

-- verification: everything back to zero
SELECT 'zone29' k, COUNT(*) c FROM `zone` WHERE `zoneidnumber` = 69 AND `version` = 29
UNION ALL SELECT 'spawn29', COUNT(*) FROM `spawn2` WHERE `zone` = 'oot' AND `version` = 29
UNION ALL SELECT 'shroud502', COUNT(*) FROM `shrouds` WHERE `id` = 502
UNION ALL SELECT 'task', COUNT(*) FROM `tasks` WHERE `id` = 800004
UNION ALL SELECT 'npcs', COUNT(*) FROM `npc_types` WHERE `id` IN (1520001940,1520001950,1520001951)
UNION ALL SELECT 'ctrlspawn', COUNT(*) FROM `spawn2` WHERE `spawngroupID` = 5004503;
