-- 2026-10-24 West Freeport: move Branack Welk next to Dooly Jonkers (classic geometry)
-- Branack_Welk (npc_types 344295, spawn2 3390315, blessing-tree NPC) spawned at
-- (-200, -888, -20), inside unreachable terrain. An intermediate attempt at
-- (-1535, 478, -112) was wrong: those coordinates belong to the REVAMPED
-- freeportwest geometry — this server runs classic freportw, where that spot
-- does not exist. Final placement is ~11 units WSW of Dooly_Jonkers (npc 9076,
-- spawn2 9073, at -644, 108, -40), on his z, facing him.
-- No pathgrid, no condition gating, no quest script references.
-- Rollback: UPDATE spawn2 SET x=-200, y=-888, z=-20, heading=0 WHERE id=3390315;

UPDATE `spawn2` SET `x` = -654, `y` = 104, `z` = -40, `heading` = 48
WHERE `id` = 3390315 AND `zone` = 'freportw';
