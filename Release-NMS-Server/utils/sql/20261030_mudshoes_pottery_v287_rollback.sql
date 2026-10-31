-- Rollback of 287: Mudshoes' Pottery Trial (beholder v80 tradeskill shroud
-- mission). Inverse of 20261030_mudshoes_pottery_v287.sql. The zone v80 row
-- is dropped by (zoneidnumber, version) so the auto id does not matter.
-- Run the db_version step only if no later custom version has been applied.

SET NAMES utf8mb4;

DELETE FROM `grid_entries` WHERE `gridid` IN (1520000001,1520000002) AND `zoneid` = 16;
DELETE FROM `grid` WHERE `id` IN (1520000001,1520000002) AND `zoneid` = 16;

DELETE FROM `spawn2` WHERE `id` IN (1520028328,1520028329);
DELETE FROM `spawnentry` WHERE `spawngroupID` IN (5004767,5004768);
DELETE FROM `spawngroup` WHERE `id` IN (5004767,5004768);

DELETE FROM `npc_types` WHERE `id` IN
	(1520001990,1520001991,1520001992,1520001993,1520001994,1520001996,1520001997,1520001998,1520001999);

DELETE FROM `spells_new` WHERE `id` IN (44032, 44033, 44034);

DELETE FROM `shrouds` WHERE `id` = 506 OR `progression` = 'Earthenwares';

DELETE FROM `zone` WHERE `zoneidnumber` = 16 AND `version` = 80;

-- Only run this when 287 is the newest applied custom version.
UPDATE db_version SET custom_version = 286 WHERE custom_version = 287;
