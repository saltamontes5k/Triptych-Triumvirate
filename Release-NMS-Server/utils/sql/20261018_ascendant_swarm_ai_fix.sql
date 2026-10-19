-- Ascendant swarm-pet port follow-up: restore movement/aggro.
--
-- The rows copied by entry 166 kept Ascendant's npc_types aggro/speed fields
-- (aggroradius 0, runspeed 0, npc_aggro 0). Every working swarm pet in this DB
-- uses 55 / 1.25 / 1 (see SwarmPetDG1-3, SummonEye, animateDead). With 0 the
-- ported pets could not close or acquire, so doppelgangers stood in place and
-- took hits instead of fighting.
--
-- Twin of manifest entry 167. Applies to the 53 npc_types rows added by entry 166.

UPDATE `npc_types`
SET `aggroradius` = 55,
    `assistradius` = 0,
    `runspeed` = 1.25,
    `npc_aggro` = 1
WHERE `id` IN (
  954,955,956,957,958,959,960,961,962,963,1412,1413,1419,1420,1421,1318,1319,1320,1321,1322,1323,1324,1325,1326,1327,1328,1329,1330,1331,1332,1333,1334,1348,1349,1350,1351,1352,1353,1354,1355,1356,1357,1358,1359,1360,1361,1362,1363,1364,1414,1415,1416,1417
);
