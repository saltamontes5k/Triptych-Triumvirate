-- Rollback of 20261024_freportw_freeport_porter.sql (manifest entry 230):
-- removes the Freeport Porter npc, its spawn point, group, and entry.

DELETE FROM `spawn2` WHERE `id` = 1520023801;
DELETE FROM `spawnentry` WHERE `spawngroupID` = 500105;
DELETE FROM `spawngroup` WHERE `id` = 500105;
DELETE FROM `npc_types` WHERE `id` = 1120002385;
DROP TABLE IF EXISTS nms_tmp_freeport_porter;
