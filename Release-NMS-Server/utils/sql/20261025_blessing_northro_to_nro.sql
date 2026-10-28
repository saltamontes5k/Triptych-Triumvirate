-- 2026-10-25 Blessing spawns: move out of legacy 'northro' into playable 'nro'
-- This server uses the classic 'nro' (zoneidnumber 34, "Northern Desert of Ro")
-- — 'northro' (zoneidnumber 392, "North Desert of Ro") is a legacy zone with no
-- player routing, which is why the Avatar of Solusek Ro read as "missing".
-- Seven blessing spawns sat in northro:
--   Avatar_of_Solusek_Ro (3390210, task 700208) -> user-verified nro loc
--     (1389, 263, 55).
--   The six 392-task creature targets re-anchor beside matching nro wildlife
--     (nro has coyotes, fire beetles, rattlesnakes, armadillos; no bats or
--     rats, so those two anchor on the closest critter clusters):
--     3390240 sandskimmer bat  -> (668, 1898, 6)    gila/spiderling cluster
--     3390241 mother rat       -> (484, 2812, -17)  beside an armadillo
--     3390242 wiry coyote      -> (1020, -1398, -24) beside a_coyote + gila monster
--     3390243 raging fire beetle -> (630, 3941, -19) beside a_fire_beetle
--     3390244 clever stonesnake  -> (883, -1406, -12) beside giant rattlesnake
--     3390260 injured coyote   -> (226, 3815, -19)  beside northern a_coyote pair
-- Task wiring: the eight task_activities rows with zones='392' now say '34'
-- (700100 acts 1-5, 700199 act 6, 700208 acts 0+11).
-- Rollback: set zone='northro' and restore prior coords (raw values were the
-- fan-site-swapped pairs; see 20261024_blessing_sweep_swapped_xy.sql).

UPDATE `spawn2` SET `zone` = 'nro', `x` = 1389, `y` = 263,  `z` = 55   WHERE `id` = 3390210 AND `zone` = 'northro';
UPDATE `spawn2` SET `zone` = 'nro', `x` = 668,  `y` = 1898, `z` = 6    WHERE `id` = 3390240 AND `zone` = 'northro';
UPDATE `spawn2` SET `zone` = 'nro', `x` = 484,  `y` = 2812, `z` = -17  WHERE `id` = 3390241 AND `zone` = 'northro';
UPDATE `spawn2` SET `zone` = 'nro', `x` = 1020, `y` = -1398, `z` = -24 WHERE `id` = 3390242 AND `zone` = 'northro';
UPDATE `spawn2` SET `zone` = 'nro', `x` = 630,  `y` = 3941, `z` = -19  WHERE `id` = 3390243 AND `zone` = 'northro';
UPDATE `spawn2` SET `zone` = 'nro', `x` = 883,  `y` = -1406, `z` = -12 WHERE `id` = 3390244 AND `zone` = 'northro';
UPDATE `spawn2` SET `zone` = 'nro', `x` = 226,  `y` = 3815, `z` = -19  WHERE `id` = 3390260 AND `zone` = 'northro';
UPDATE `task_activities` SET `zones` = '34' WHERE `zones` = '392';

-- RELATED (flagged, NOT changed here): legacy zone_points rows still route
-- into 392 — freeporteast line 40 and freeportsewers line 30 target the dead
-- zone. If players report zoning east out of Freeport and arriving nowhere,
-- those lines need retargeting to 34 (nro). Check before changing: other
-- routing may already cover those exits.
