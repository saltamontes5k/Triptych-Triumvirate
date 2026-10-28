-- 2026-10-24 Solusek Ro blessing-quest location fixes
-- 1) Tober_Grandim (npc 344225, spawn2 3390222), Lauren (344277, 3390278) and
--    Tyler (344278, 3390279) in northkarana (blessing tasks 700145/700154,
--    zone 13) all spawned at z=-53, under the terrain. Raised to z=14.5
--    (ground level — an initial pass at z=0 was still ~14 units under;
--    a grizzly bear anchor 180u away stands at 14.5). x/y/heading untouched.
-- 2) Avatar_of_Solusek_Ro (npc 344220, spawn2 3390210) has its only spawn in
--    northro (North Desert of Ro, zoneidnumber 392 — blessing task 700208) at
--    (6761, -699, 141), far outside the playable map, so the avatar was
--    effectively missing. Moved to (1389, 263, 55).
-- Rollback: restore z=-53 on the three; x=6761, y=-699, z=141 on the avatar.

UPDATE `spawn2` SET `z` = 14.5
WHERE `id` IN (3390222, 3390278, 3390279) AND `zone` = 'northkarana' AND `z` <= 0;
UPDATE `spawn2` SET `x` = 1389, `y` = 263, `z` = 55
WHERE `id` = 3390210 AND `zone` = 'northro' AND `x` = 6761;
