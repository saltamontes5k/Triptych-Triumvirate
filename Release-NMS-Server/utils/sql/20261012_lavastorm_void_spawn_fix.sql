-- =====================================================================
--  Lavastorm (zone 27) v0 - bring every off-map spawn back onto the map
--  2026-10-12
--
--  Context
--  -------
--  zone row 202 (version 0) has map_file_name = NULL, so the server loads
--  maps/base/lavastorm.map, whose geometry only spans x -1116..1611 and
--  y -3071..1655.  Any v0 spawn outside that is floating in the void.
--  (The version 1 row 9016 uses map_file_name = lavastorm_v1, a different
--  map spanning y -62..4007, so the 16 remaining v1-only rows are correct
--  there and are deliberately not touched.)
--
--  Before: 71 of 417 lavastorm spawn2 rows had no map triangle under them:
--    * 500001-500014 - second copies of the DoN camp NPCs, placed at the
--      v1 coordinates.  The camps at (670-760,1196-1271) [Norrath's
--      Keepers], (920-990,-450..-350) [Dark Reign] and (-196..-88,280-332)
--      [Wayfarers] already hold every one of these NPCs, so the void rows
--      are removed rather than duplicated.
--    * 38289 Xeib_Darkskies / 38290 Tatsujiro_the_Serene - the two DoN
--      camp merchants; both were at y>3000 and therefore unreachable (this
--      is why the Norrath's Keepers merchant read as 'missing').
--    * 39 non-camp rows (magma war drakes, scorched lavaspinner elites,
--      swirling smoke, burnt guardians/protectors, lavaspiders, cinder/
--      Solusek goblins, #Head_Miner_Bibol, Talwyn_Flamecaller, Symbell_Sunara,
--      Laura_Rako) - moved next to the nearest on-map cluster of the same
--      NPC family (primary noun), falling back to the nearest on-map spawn.
--    * 910032 DoN_Porter - moved onto the Lavastorm waypoint
--      (nms_waypoints.h: 'Lavastorm Mountains (Druid Ring)' 1318,918,119).
--
--  After: zero version-0 spawn2 rows are off the base map.
--
--  Coordinates use the server frame (X,Y,Z) = fan-site (Y,X,Z) swapped.
--  Applied to the live peq DB 2026-10-12.  Idempotent (scoped DELETE/UPDATE).
--  Needs a lavastorm zone reboot for spawn2 changes to load; #repop alone
--  only respawns what the zone cached at boot.
-- =====================================================================
SET NAMES utf8mb4;

-- Safety snapshot of every row this file touches (56 rows).
DROP TABLE IF EXISTS spawn2_bak_20261012_lavastorm_void;
CREATE TABLE spawn2_bak_20261012_lavastorm_void AS
  SELECT * FROM spawn2 WHERE zone = 'lavastorm' AND id IN (500001, 500002, 500003, 500004, 500005, 500006, 500007, 500008, 500009, 500010, 500011, 500012, 500013, 500014, 38290, 38289, 910032, 38218, 38223, 38224, 38225, 38230, 38235, 38237, 38238, 38240, 38243, 38244, 38245, 38246, 38247, 38265, 38268, 38288, 38291, 38299, 38301, 38302, 38309, 38310, 38312, 38320, 38329, 38332, 38335, 38338, 38340, 38341, 38342, 38343, 38344, 38345, 38346, 38354, 38359, 38360);

-- 1. Remove the 500001-500014 void duplicates (camps already have these NPCs).
DELETE FROM spawn2 WHERE zone = 'lavastorm' AND version = 0 AND id BETWEEN 500001 AND 500014;

-- 2. Return the two DoN camp merchants to their camps.
UPDATE spawn2 SET x = 724, y = 1254, z = 187, heading = 320 WHERE zone = 'lavastorm' AND version = 0 AND id = 38290; -- Tatsujiro_the_Serene (Norrath's Keepers merchant)
UPDATE spawn2 SET x = 988, y = -372, z = 3, heading = 192 WHERE zone = 'lavastorm' AND version = 0 AND id = 38289; -- Xeib_Darkskies (Dark Reign merchant)

-- 3. DoN porter onto the Lavastorm druid-ring waypoint.
UPDATE spawn2 SET x = 1306, y = 918, z = 119, heading = 90 WHERE zone = 'lavastorm' AND version = 0 AND id = 910032; -- DoN_Porter

-- 4. Non-camp off-map rows -> nearest on-map family cluster.
UPDATE spawn2 SET x = -270, y = 1651, z = 68.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38218; -- a_burnt_guardian
UPDATE spawn2 SET x = -258, y = 1651, z = 68.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38223; -- a_burnt_guardian
UPDATE spawn2 SET x = -282, y = 1651, z = 68.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38224; -- a_burnt_guardian
UPDATE spawn2 SET x = -270, y = 1639, z = 68.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38225; -- a_burnt_protector
UPDATE spawn2 SET x = -258, y = 1639, z = 68.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38230; -- a_burnt_protector
UPDATE spawn2 SET x = 847.282593, y = 1224.514404, z = 182.9832 WHERE zone = 'lavastorm' AND version = 0 AND id = 38235; -- a_cinder_goblin_cleric|a_cinder_goblin_warrior|a_cinder
UPDATE spawn2 SET x = 859.282593, y = 1224.514404, z = 182.9832 WHERE zone = 'lavastorm' AND version = 0 AND id = 38237; -- a_cinder_goblin_wizard
UPDATE spawn2 SET x = -282, y = 1639, z = 68.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38238; -- a_burnt_protector
UPDATE spawn2 SET x = 835.282593, y = 1224.514404, z = 182.9832 WHERE zone = 'lavastorm' AND version = 0 AND id = 38240; -- a_cinder_goblin_warrior|a_cinder_goblin_wizard
UPDATE spawn2 SET x = -1053.875, y = 621.875, z = -90.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38243; -- a_lesser_lavaspinner
UPDATE spawn2 SET x = 720, y = 1647.125, z = 100.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38244; -- a_scorched_lavaspinner_elite
UPDATE spawn2 SET x = 732, y = 1647.125, z = 100.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38245; -- a_scorched_lavaspinner_elite
UPDATE spawn2 SET x = 708, y = 1647.125, z = 100.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38246; -- a_scorched_lavaspinner_elite
UPDATE spawn2 SET x = 720, y = 1635.125, z = 100.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38247; -- a_scorched_lavaspinner_elite
UPDATE spawn2 SET x = -1041.875, y = 621.875, z = -90.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38265; -- Symbell_Sunara
UPDATE spawn2 SET x = 136.875, y = 1425.625, z = 67.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38268; -- Laura_Rako
UPDATE spawn2 SET x = 493, y = 1028, z = -74.375 WHERE zone = 'lavastorm' AND version = 0 AND id = 38288; -- #Head_Miner_Bibol
UPDATE spawn2 SET x = -270, y = 1627, z = 68.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38291; -- Talwyn_Flamecaller
UPDATE spawn2 SET x = 670.759583, y = 1012.115173, z = 176.558121 WHERE zone = 'lavastorm' AND version = 0 AND id = 38299; -- a_magma_war_drake
UPDATE spawn2 SET x = -110.034805, y = 1233.834229, z = 62.521423 WHERE zone = 'lavastorm' AND version = 0 AND id = 38301; -- a_swirling_smoke
UPDATE spawn2 SET x = -393, y = 1216, z = 123.699997 WHERE zone = 'lavastorm' AND version = 0 AND id = 38302; -- a_magma_war_drake
UPDATE spawn2 SET x = 682.759583, y = 1012.115173, z = 176.558121 WHERE zone = 'lavastorm' AND version = 0 AND id = 38309; -- #Scorchwing|a_magma_war_drake
UPDATE spawn2 SET x = 658.759583, y = 1012.115173, z = 176.558121 WHERE zone = 'lavastorm' AND version = 0 AND id = 38310; -- a_magma_war_drake
UPDATE spawn2 SET x = 174, y = 632, z = 102.141296 WHERE zone = 'lavastorm' AND version = 0 AND id = 38312; -- a_magma_basilisk_warrior
UPDATE spawn2 SET x = 732, y = 1635.125, z = 100.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38320; -- a_scorched_lavaspinner_elite
UPDATE spawn2 SET x = -1065.875, y = 621.875, z = -90.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38329; -- a_lesser_lavaspinner
UPDATE spawn2 SET x = 708, y = 1635.125, z = 100.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38332; -- a_scorched_lavaspinner_elite
UPDATE spawn2 SET x = -381, y = 1216, z = 123.699997 WHERE zone = 'lavastorm' AND version = 0 AND id = 38335; -- a_magma_war_drake
UPDATE spawn2 SET x = -98.034805, y = 1233.834229, z = 62.521423 WHERE zone = 'lavastorm' AND version = 0 AND id = 38338; -- a_swirling_smoke
UPDATE spawn2 SET x = -1053.875, y = 633.875, z = -90.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38340; -- a_lavaspinner
UPDATE spawn2 SET x = -172.75, y = 1516.75, z = 74.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38341; -- a_lavaspinner
UPDATE spawn2 SET x = -160.75, y = 1516.75, z = 74.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38342; -- a_greater_lavaspinner
UPDATE spawn2 SET x = -695, y = 977, z = 59.099998 WHERE zone = 'lavastorm' AND version = 0 AND id = 38343; -- a_magma_basilisk_warrior
UPDATE spawn2 SET x = -828, y = 1050, z = 40.200001 WHERE zone = 'lavastorm' AND version = 0 AND id = 38344; -- a_magma_basilisk_warrior
UPDATE spawn2 SET x = -683, y = 977, z = 59.099998 WHERE zone = 'lavastorm' AND version = 0 AND id = 38345; -- a_magma_basilisk_warrior
UPDATE spawn2 SET x = 720, y = 1623.125, z = 100.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38346; -- a_greater_lavaspinner
UPDATE spawn2 SET x = -122.034805, y = 1233.834229, z = 62.521423 WHERE zone = 'lavastorm' AND version = 0 AND id = 38354; -- a_swirling_smoke
UPDATE spawn2 SET x = -184.75, y = 1516.75, z = 74.875 WHERE zone = 'lavastorm' AND version = 0 AND id = 38359; -- a_lavaspinner
UPDATE spawn2 SET x = 398, y = 1505, z = 53.625 WHERE zone = 'lavastorm' AND version = 0 AND id = 38360; -- a_Solusek_goblin_fighter

-- =====================================================================
-- VERIFY - both must return zero rows:
--   (collision-mesh check is external; at minimum confirm nothing has y>1655)
-- SELECT s2.id, nt.name, s2.x, s2.y FROM spawn2 s2
--   JOIN spawnentry se ON se.spawngroupID = s2.spawngroupID
--   JOIN npc_types nt ON nt.id = se.npcID
--  WHERE s2.zone='lavastorm' AND s2.version=0 AND s2.y > 1655;
--
-- Merchants at camp, porter on the waypoint:
-- SELECT id, x, y, z FROM spawn2 WHERE zone='lavastorm' AND id IN (38289,38290,910032);

-- =====================================================================
-- ROLLBACK
--   DELETE FROM spawn2 WHERE zone='lavastorm' AND id BETWEEN 500001 AND 500014;
--   Then re-insert the deleted 14 rows and restore the other 42 from
--   spawn2_bak_20261012_lavastorm_void (56 rows).  The two merchants,
--   porter and 39 moved rows keep their id, so a plain
--   UPDATE ... SELECT from the backup restores everything:
--     UPDATE spawn2 s JOIN spawn2_bak_20261012_lavastorm_void b ON b.id = s.id
--        SET s.x = b.x, s.y = b.y, s.z = b.z, s.heading = b.heading
--      WHERE s.zone = 'lavastorm' AND s.version = b.version;
--     INSERT INTO spawn2 SELECT * FROM spawn2_bak_20261012_lavastorm_void b
--      WHERE b.id BETWEEN 500001 AND 500014
--        AND NOT EXISTS (SELECT 1 FROM spawn2 s WHERE s.id = b.id);
-- =====================================================================
