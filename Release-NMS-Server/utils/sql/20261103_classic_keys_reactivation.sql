-- Classic key quest reactivation (2026-11-03). Research verdict: the quest scripts, key
-- items, loot wiring and the Hand of Glory combine (recipe 9823) are ALL already live in
-- this DB (dump-grep claims to the contrary were stale-file artifacts; verified live).
-- What is actually broken is door-side + one walk-in pad:
--   1) trakanon HOWLER (the Sebilis gate) and cobaltscar TFSWITCH200 (the Skyshrine gate)
--      are unkeyed - key them to their classic keys: Trakanon Idol 20883 and Shrine Key
--      28602 (Ziglark/Wenglawks chain).
--   2) veeshan VEDOOR101 entry doors (doorid 56/57) carry dead keyitem=1 (item id 1 does
--      not exist) - key them to Key of Veeshan 20884 (Emperor Ganak chain; SoV stage
--      completion also keyrings 20884 via NMS_progression_utils.pl).
--   3) eastwastes zone_point 13 (ids 585/2644) is an unkeyed walk-in into Sleeper's Tomb
--      co-located with the keyed SHRINEGLOBE202 door (keyitem 27265 Sleeper's Key, Jaled
--      Dar's shade chain) - same bypass class as the umbral VT pad fixed in v313. Delete;
--      the globe is the only entry.
-- Guarded/idempotent: updates match full identity + current value; delete matches point
-- identity. RoK/SoV atlas progression gates still stack on every keyed door.
-- Twin of manifest entry 315.
SET NAMES utf8mb4;

UPDATE `doors` SET `keyitem` = 20883
WHERE `zone` = 'trakanon' AND `doorid` = 12 AND `name` = 'HOWLER' AND `dest_zone` = 'sebilis' AND `keyitem` = 0;

UPDATE `doors` SET `keyitem` = 28602
WHERE `zone` = 'cobaltscar' AND `doorid` = 36 AND `name` = 'TFSWITCH200' AND `dest_zone` = 'skyshrine' AND `keyitem` = 0;

UPDATE `doors` SET `keyitem` = 20884
WHERE `zone` = 'veeshan' AND `name` = 'VEDOOR101' AND `keyitem` = 1;

DELETE FROM `zone_points`
WHERE `zone` = 'eastwastes' AND `number` = 13 AND `target_zone_id` = 128;
