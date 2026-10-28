-- 2026-10-24 Quellious deity quest fixes (blessing task 700181, Alla quest 4832)
-- 1) Avatar_of_Quellious_the_Tranquil (npc 600155, spawn2 3390214, potranquility)
--    spawned at (-1452, 2107, -710) — X/Y swapped (fan-site Y,X ordering read as
--    X,Y; the fan-site Y,X trap). Correct spot in the Plane of Earth quarter,
--    beside the earth NPCs at z -711: (2045, -1466, -711), facing the quarter.
-- 2) Tomee_Stenk (npc 344296, spawn2 3390316, qeynos) floated at (290, -71, 4);
--    moved beside Ghul_Rustem (npc 1146 at -28, -307, 6): (-38, -300, 6),
--    facing him.
-- 3) Quellious Wand of Tranquility (custom item 976213, granted by
--    Avatar_of_Quellious_the_Tranquil.pl) was a dead prop: spider-web icon 782,
--    clickeffect -1. Now: wand icon 1282 (matches stock 60395), casts Wake of
--    Tranquility (spell 1541, AE calm), instant click, unlimited charges
--    (maxcharges -1, matching stock Wand of Tranquility 26768 semantics).
-- 4) Strawberry-Jumjum Pie (custom item 976221) icon 782 (spider web) -> 1019,
--    the icon used by the entire stock Jumjum pie family.
-- NOTE: item icon/click changes require a shared-memory rebuild (or server
-- restart) to reach clients; spawn moves need #repop in the zone.
-- Rollback: restore the per-row original values from the comments above.

UPDATE `spawn2` SET `x` = 2045, `y` = -1466, `z` = -711, `heading` = 22
WHERE `id` = 3390214 AND `zone` = 'potranquility' AND `x` = -1452;
UPDATE `spawn2` SET `x` = -38, `y` = -300, `z` = 6, `heading` = 39
WHERE `id` = 3390316 AND `zone` = 'qeynos' AND `x` = 290;
UPDATE `items` SET `icon` = 1282, `clickeffect` = 1541, `casttime_` = 0, `maxcharges` = -1
WHERE `id` = 976213 AND `clickeffect` = -1;
UPDATE `items` SET `icon` = 1019
WHERE `id` = 976221 AND `icon` = 782;
