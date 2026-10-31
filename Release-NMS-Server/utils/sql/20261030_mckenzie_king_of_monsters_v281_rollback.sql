-- Rollback for 281: Old Man McKenzie's King of the Monsters (moors v40).
-- Removes the mission's rows; the cloned v0 spawn rows, zone row and all
-- stock npc_types are untouched (the whelps/controller/froglok are
-- mission-only ids and the v40 rows are mission-only).

DELETE FROM `spawnentry` WHERE `spawngroupID` = 5004504;
DELETE FROM `spawn2` WHERE `spawngroupID` = 5004504;
DELETE FROM `spawngroup` WHERE `id` = 5004504;

DELETE FROM `task_activities` WHERE `taskid` = 800005;
DELETE FROM `tasks` WHERE `id` = 800005;

DELETE FROM `npc_faction_entries` WHERE `npc_faction_id` = 1520000112;
DELETE FROM `npc_faction` WHERE `id` = 1520000112;

DELETE FROM `npc_types` WHERE `id` BETWEEN 1520001970 AND 1520001977;

DELETE FROM `shrouds` WHERE `id` = 503;

DELETE FROM `spawn2` WHERE `zone` = 'moors' AND `version` = 40;
DELETE FROM `zone` WHERE `zoneidnumber` = 395 AND `version` = 40;
