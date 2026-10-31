-- Rollback for 283: Old Man McKenzie's Midnight Snack (skyshrine v41).
-- Removes the mission's rows; the skyshrine v0 zone row and all stock
-- npc_types are untouched (the controller/chasers/golem/cake are
-- mission-only ids and the v41 rows are mission-only).

DELETE FROM `spawnentry` WHERE `spawngroupID` = 5004505;
DELETE FROM `spawn2` WHERE `spawngroupID` = 5004505;
DELETE FROM `spawngroup` WHERE `id` = 5004505;

DELETE FROM `task_activities` WHERE `taskid` = 800006;
DELETE FROM `tasks` WHERE `id` = 800006;

DELETE FROM `npc_types` WHERE `id` BETWEEN 1520001978 AND 1520001984;

DELETE FROM `shrouds` WHERE `id` = 504;

DELETE FROM `spawn2` WHERE `zone` = 'skyshrine' AND `version` = 41;
DELETE FROM `zone` WHERE `zoneidnumber` = 114 AND `version` = 41;
