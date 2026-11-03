-- 20261103_curio_traps_v316.sql - "The Hoard Remembers" curio click-traps.
--
-- Makes the old raid-master warnings true: clicking on the treasure piles and
-- statue/bookcase props of Veeshan's Peak, and the floating crystal pedestals
-- and bookcases of Plane of Air, now does very bad things (see
-- quests/<zone>/player.pl: DTS via Veeshan/Xegony flavor, guardian adds,
-- buff wipe, Color Cloud AOE paralyze, the shipped Drunken Stupor brew spell
-- 7536, port-to-poair, and bookcase port-to-PoK).
--
-- The props themselves are static zone mesh (object table is empty for both
-- zones), so the traps are trigger DOORS placed on the prop clusters
-- (anchored on lair boss / crystal-room NPC coords). Door models are
-- zone-native and VISIBLE on purpose: doors whose model name the client
-- cannot resolve have no click geometry (live-tested 2026-11-03: a player
-- clicking all over Xygoz's lair against invisible-model doors produced no
-- OP_ClickDoor at all), so each trap renders as a real, clickable curio -
-- VP treasure piles use VECOINS101, statues/shelves use VEDRSTAT101;
-- poair crystals use POTRANQROCK505 at size 40, bookcases use POAFLYBK502
-- (the flying book). All are models the zone's own doors already render,
-- so the client provably has them.
--
-- Door bands: veeshan existing max doorid = 239; poair existing max = 22
-- (plus a duplicated stock doorid 1; the duplicate rows differ in `version`)
-- - 601+ is clear in both zones.
--
-- Idempotent: doors has UNIQUE KEY DoorIndex (zone, doorid, version), so
-- INSERT IGNORE is a safe no-op on re-run. NOTE: the INSERT ... SELECT
-- derived-table form of this migration misfired silently at world boot
-- (statements eaten inside QueryDatabaseMulti; the rule row on the live DB
-- came from the rule bootstrap, doors never landed) while running fine via
-- the mysql CLI - the plain VALUES form below avoids whatever ate the batch.
--
-- Twin of ManifestEntry .version = 316 (keep in sync).
--
-- Rollback:
--   DELETE FROM doors WHERE zone = 'veeshan' AND doorid BETWEEN 601 AND 612 AND doorid MOD 2 = 1;
--   DELETE FROM doors WHERE zone = 'veeshan' AND doorid BETWEEN 601 AND 612 AND doorid MOD 2 = 0;
--   DELETE FROM doors WHERE zone = 'poair'   AND doorid BETWEEN 601 AND 611;
--   DELETE FROM rule_values WHERE rule_name = 'Custom:CurioTraps';

SET NAMES utf8mb4;

INSERT IGNORE INTO doors (doorid, zone, version, name, pos_x, pos_y, pos_z, heading,
                          opentype, lockpick, keyitem, door_param, size,
                          client_version_mask, close_timer_ms, min_expansion, max_expansion) VALUES
(601, 'veeshan', 0, 'VECOINS101', -217.6, 1406.0, 457.8, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(602, 'veeshan', 0, 'VEDRSTAT101', -193.6, 1430.0, 457.8, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(603, 'veeshan', 0, 'VECOINS101', 550.0, 1451.0, 289.9, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(604, 'veeshan', 0, 'VEDRSTAT101', 574.0, 1475.0, 289.9, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(605, 'veeshan', 0, 'VECOINS101', -572.8, 1158.6, 689.4, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(606, 'veeshan', 0, 'VEDRSTAT101', -548.8, 1182.6, 689.4, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(607, 'veeshan', 0, 'VECOINS101', -208.0, 308.0, 465.5, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(608, 'veeshan', 0, 'VEDRSTAT101', -184.0, 332.0, 465.5, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(609, 'veeshan', 0, 'VECOINS101', 1196.9, 1324.4, 779.6, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(610, 'veeshan', 0, 'VEDRSTAT101', 1220.9, 1348.4, 779.6, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(611, 'veeshan', 0, 'VECOINS101', -1325.5, -1167.2, 299.9, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(612, 'veeshan', 0, 'VEDRSTAT101', -1301.5, -1143.2, 299.9, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(601, 'poair', 0, 'POTRANQROCK505', -1205.0, 465.0, 6.4, 0, 58, -1, 0, 0, 40, 4294967295, 5000, -1, -1),
(602, 'poair', 0, 'POTRANQROCK505', 1456.0, -652.0, 16.4, 0, 58, -1, 0, 0, 40, 4294967295, 5000, -1, -1),
(603, 'poair', 0, 'POTRANQROCK505', 1455.0, -533.0, 46.4, 0, 58, -1, 0, 0, 40, 4294967295, 5000, -1, -1),
(604, 'poair', 0, 'POTRANQROCK505', 1493.0, -447.0, 46.4, 0, 58, -1, 0, 0, 40, 4294967295, 5000, -1, -1),
(605, 'poair', 0, 'POTRANQROCK505', 1099.0, -398.0, 5.1, 0, 58, -1, 0, 0, 40, 4294967295, 5000, -1, -1),
(606, 'poair', 0, 'POTRANQROCK505', 1220.0, -382.0, 46.4, 0, 58, -1, 0, 0, 40, 4294967295, 5000, -1, -1),
(607, 'poair', 0, 'POTRANQROCK505', -1032.0, -307.0, 334.9, 0, 58, -1, 0, 0, 40, 4294967295, 5000, -1, -1),
(608, 'poair', 0, 'POTRANQROCK505', -1700.0, 761.0, 46.4, 0, 58, -1, 0, 0, 40, 4294967295, 5000, -1, -1),
(609, 'poair', 0, 'POAFLYBK502', -1225.0, 505.0, 6.4, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(610, 'poair', 0, 'POAFLYBK502', 1436.0, -495.0, 46.4, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(611, 'poair', 0, 'POAFLYBK502', -1720.0, 770.0, 46.4, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1);

INSERT INTO rule_values (ruleset_id, rule_name, rule_value, notes)
VALUES (1, 'Custom:CurioTraps', 'true',
        'The Hoard Remembers: curio click-traps in veeshan (treasure piles/statues/bookcases, doors 601-612) and poair (floating crystals/bookcases, doors 601-611). DTS (Veeshan/Xegony flavor), guardian adds, buff wipe, Color Cloud AOE paralyze, Drunken Stupor spell 7536, port-to-poair, bookcase port-to-PoK. Per-char 120s cooldown, GMs exempt. Handler: quests veeshan/player.pl + poair/player.pl.')
ON DUPLICATE KEY UPDATE rule_value = VALUES(rule_value);
