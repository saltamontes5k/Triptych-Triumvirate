-- 333: Dump-parity data fixes (sibling-server tracker sweep 2026-11-04).
-- Twin: common/database/database_update_manifest_custom.cpp v333 (keep in sync).
--
-- 1) name_filter row 'goo': Database::CheckNameFilter matches filter entries
--    as substrings of the whole name, so 'goo' rejects every name containing
--    it - including names starting with "Good". The row blocks no real
--    profanity stem, so it goes; the matcher keeps its fail-closed substring
--    semantics for everything else.
-- 2) PoP Ornate/Elemental patterns + molds stack to 100 (they shipped at
--    stacksize 1). Guarded by stacksize = 1 so the run is idempotent and the
--    already-100 hilt casting molds stay put.
--    items changes only reach zones through the shared segments - rebuild +
--    zone restarts owed. Never run shared_memory.exe against the live stack.
-- 3) Casting time in the spell info window: the window renders the db_str
--    description at spells_new.descnum, so append the cast time to every
--    description whose spell actually has one. Guarded so reruns are no-ops.
--    Client dbstr_us.txt needs a re-export (ultimate-spire) + distribution
--    before players see it.
SET NAMES utf8mb4;

-- name filter: 'goo' substring-blocks every name containing it ("Good...").
DELETE FROM `name_filter` WHERE `name` = 'goo';

-- PoP Ornate/Elemental patterns and molds stack to 100 (idempotent guard).
UPDATE `items`
SET `stacksize` = 100
WHERE `stacksize` = 1
  AND ((`name` LIKE '%Pattern%' OR `name` LIKE '%Mold%')
       AND (`name` LIKE '%Ornate%' OR `name` LIKE '%Elemental%'));

-- cast time into the spell info window description (idempotent guard).
UPDATE `db_str` `ds`
JOIN `spells_new` `sn` ON `ds`.`id` = `sn`.`descnum`
SET `ds`.`value` = CONCAT(`ds`.`value`, '  CastingTime: ', ROUND(`sn`.`cast_time` / 1000, 1), 's')
WHERE `sn`.`cast_time` > 0
  AND `ds`.`value` NOT LIKE '%CastingTime:%';

-- 15 parse dummies on the arena floor beside the two existing training dummies
-- (npc 77002 at -73.5/-979 and -53.5/-979). Same spawngroup/spawn2 shape as
-- those rows; grid sits on their floor; final alignment in-game with #repop.
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_01', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg1 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg1, 'arena', 0, -123.5, -1023.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg1, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_02', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg2 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg2, 'arena', 0, -99.5, -1023.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg2, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_03', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg3 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg3, 'arena', 0, -75.5, -1023.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg3, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_04', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg4 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg4, 'arena', 0, -51.5, -1023.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg4, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_05', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg5 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg5, 'arena', 0, -27.5, -1023.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg5, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_06', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg6 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg6, 'arena', 0, -3.5, -1023.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg6, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_07', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg7 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg7, 'arena', 0, -123.5, -979.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg7, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_08', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg8 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg8, 'arena', 0, -99.5, -979.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg8, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_09', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg9 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg9, 'arena', 0, -27.5, -979.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg9, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_10', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg10 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg10, 'arena', 0, -3.5, -979.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg10, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_11', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg11 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg11, 'arena', 0, -123.5, -935.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg11, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_12', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg12 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg12, 'arena', 0, -99.5, -935.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg12, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_13', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg13 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg13, 'arena', 0, -75.5, -935.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg13, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_14', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg14 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg14, 'arena', 0, -51.5, -935.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg14, 77002, 100);
INSERT INTO `spawngroup` (`name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`) VALUES ('arena_parse_dummy_15', 0, 0, 0, 0, 0, 0, 0, 15000);
SET @sg15 = LAST_INSERT_ID();
INSERT INTO `spawn2` (`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`, `animation`) VALUES (@sg15, 'arena', 0, -27.5, -935.0, 49.9, 0, 640, 0, 0, 0, 1, 0);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (@sg15, 77002, 100);
