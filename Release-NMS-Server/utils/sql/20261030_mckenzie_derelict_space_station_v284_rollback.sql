-- Rollback of v284: Old Man McKenzie's Derelict Space Station (netherbian v66
-- monster mission). Twin of utils/sql/20261030_mckenzie_derelict_space_station_v284.sql.

DELETE FROM `spawn2` WHERE `zone` = 'netherbian' AND `version` = 66;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 5004613 AND 5004766;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 5004613 AND 5004766;
DELETE FROM `task_activities` WHERE `taskid` = 800007;
DELETE FROM `tasks` WHERE `id` = 800007;
DELETE FROM `npc_types` WHERE `id` IN (1520001985,1520001986,1520001987,1520001988,1520001989);
DELETE FROM `shrouds` WHERE `id` = 505;
DELETE FROM `zone` WHERE `zoneidnumber` = 161 AND `version` = 66;

SELECT 'spawn2_left' k, COUNT(*) c FROM `spawn2` WHERE `zone` = 'netherbian' AND `version` = 66
UNION ALL SELECT 'tasks_left', COUNT(*) FROM `tasks` WHERE `id` = 800007
UNION ALL SELECT 'npcs_left', COUNT(*) FROM `npc_types` WHERE `id` BETWEEN 1520001985 AND 1520001989
UNION ALL SELECT 'shrouds_left', COUNT(*) FROM `shrouds` WHERE `id` = 505
UNION ALL SELECT 'zone_left', COUNT(*) FROM `zone` WHERE `zoneidnumber` = 161 AND `version` = 66;
