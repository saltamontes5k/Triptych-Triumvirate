-- 20261104_throne_of_the_first_brood_v331.sql - NetHack thrones in Veeshan's Peak.
--
-- Adds clickable throne triggers (the NetHack throne table, adapted - see
-- quests/veeshan/player.pl curio_throne: 2/3 nothing ("out of place" /
-- "very comfortable" once crowned), 1/3 a fate from the adapted table of 11,
-- crowning via Crown of King Tranix + the curio_crowned bucket, and door 630
-- = Phara Dar's Queen Throne running the Vlad's Throne homage - a pure curse
-- table: level drain, grease, acid drench (Torbas' Acid Blast), demon-summon,
-- bless/curse, forced lair teleport. NO wishes - the throne only threatens).
--
-- Thrones are unclickable statics, so each throne gets a trigger DOOR beside
-- it, rendered as VEBRAZ101 (royal brazier - zone-native model, proven
-- clickable; invisible/unknown-model doors have no click geometry on this
-- client, live-tested 2026-11-03). Coords are boss-adjacent royal-seat
-- offsets; Z = LAIR FLOOR (trash-mob spawn2 z near the boss - bosses hover;
-- Phara Dar's floor is ~280.5 while her body is at 299.9). Final alignment
-- to the actual static thrones is done in-game with the #door plugin.
--
-- Doorids: 621 Druushk, 622 Hoshkar, 623 Nexona, 624 Silverwing, 625 Xygoz,
-- 626 Phara Dar (regular seat), 630 Queen Throne (Phara Dar, Vlad table).
-- Band 613-640 was verified empty at authoring (stock max doorid 239, v316
-- traps 601-612).
--
-- Idempotent: INSERT IGNORE against UNIQUE KEY DoorIndex (zone, doorid,
-- version). Plain VALUES form - INSERT ... SELECT misfires inside
-- QueryDatabaseMulti at world boot (see v316 notes).
--
-- Twin of ManifestEntry .version = 331 (keep in sync).
--
-- Rollback:
--   DELETE FROM doors WHERE zone = 'veeshan' AND doorid IN (621,622,623,624,625,630) AND name = 'VEBRAZ101';

SET NAMES utf8mb4;

INSERT IGNORE INTO doors (doorid, zone, version, name, pos_x, pos_y, pos_z, heading,
                          opentype, lockpick, keyitem, door_param, size,
                          client_version_mask, close_timer_ms, min_expansion, max_expansion) VALUES
(621, 'veeshan', 0, 'VEBRAZ101', -220.6, 1433.0, 445.0, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(622, 'veeshan', 0, 'VEBRAZ101', 547.0, 1478.0, 260.0, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(623, 'veeshan', 0, 'VEBRAZ101', -575.8, 1185.6, 683.0, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(624, 'veeshan', 0, 'VEBRAZ101', -211.0, 335.0, 465.5, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(625, 'veeshan', 0, 'VEBRAZ101', 1193.9, 1351.4, 763.0, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(626, 'veeshan', 0, 'VEBRAZ101', -1313.5, -1180.2, 280.5, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1),
(630, 'veeshan', 0, 'VEBRAZ101', -1338.5, -1170.2, 280.5, 0, 58, -1, 0, 0, 100, 4294967295, 5000, -1, -1);
