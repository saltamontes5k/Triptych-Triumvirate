-- 2026-10-25 Blessing sweep Z-axis follow-up (companion to v231 swapped-XY sweep)
-- Ten blessing spawns sat 30-110 units below (or above) their local ground.
-- Method: for each, compare z against the nearest non-blessing spawns — only
-- dense, z-consistent clusters produced a fix; mixed-terrain or sparse spots
-- were left as-authored (see "left alone" notes). x/y untouched here.
-- Rollback: restore the old z per row.

UPDATE `spawn2` SET `z` = 72   WHERE `id` = 3390306 AND `zone` = 'iceclad' AND `z` = -39;   -- spectre of evil: 15 nbrs within 150 avg z72 (was 111 below)
UPDATE `spawn2` SET `z` = 116  WHERE `id` = 3390243 AND `zone` = 'northro' AND `z` = 23;    -- raging fire beetle: decaying skeletons 126-315u @ z108-130
UPDATE `spawn2` SET `z` = 97   WHERE `id` = 3390200 AND `zone` = 'eastkarana' AND `z` = 2;  -- Avatar of Bertoxxulous: war wolf 22u away @ z96.6, gnoll reavers @ z97-115
UPDATE `spawn2` SET `z` = 36   WHERE `id` = 3390270 AND `zone` = 'commonlands' AND `z` = -36; -- Agar Treebs: 10 nbrs within 150 @ z35.7
UPDATE `spawn2` SET `z` = 86   WHERE `id` = 3390241 AND `zone` = 'northro' AND `z` = 23;    -- mother rat: decaying skeletons 230-358u @ z76-99
UPDATE `spawn2` SET `z` = 90   WHERE `id` = 3390242 AND `zone` = 'northro' AND `z` = 23;    -- wiry coyote: guard/inn cluster 293-307u @ z89-91
UPDATE `spawn2` SET `z` = 0    WHERE `id` = 3390258 AND `zone` = 'nektulos' AND `z` = -34;  -- injured drake: 19 nbrs within 150 @ z-1.8
UPDATE `spawn2` SET `z` = -103 WHERE `id` = 3390305 AND `zone` = 'firiona' AND `z` = -140;  -- spectre of evil: guards/translocator 61-77u @ z-103
UPDATE `spawn2` SET `z` = 42   WHERE `id` = 3390301 AND `zone` = 'southkarana' AND `z` = 20; -- spectre of evil: 24 nbrs within 150 @ z41-43
UPDATE `spawn2` SET `z` = 41   WHERE `id` = 3390321 AND `zone` = 'oggok' AND `z` = 78;      -- Snogge: city content 137-192u @ z38-41

-- Left alone after review (z matches local terrain or evidence too weak):
--   aviak guard + Innoruuk's Flame lakerathe (content at both z -42 and +54 nearby),
--   brown bear rathemtn (kodiaks at z 0-16 right there), clumsy bear rathemtn (sparse),
--   Cazic avatar feerrott (matches snakes at z -20), Rondor OoT (between island levels -220/-119),
--   everfrost spectre (matches frostfell goblins @ z-55), abysmal spectre (top deck of the ship),
--   Mithaniel potr (only 2 nbrs, 47-unit diff — weak), Branack (matches anchor Dooly at z-40),
--   Jheri gfaydark (Kelethin platform family, matches Galayna/Arthin at z117).
