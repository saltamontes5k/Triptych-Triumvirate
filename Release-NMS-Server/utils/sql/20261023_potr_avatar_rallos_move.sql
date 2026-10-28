-- 2026-10-23 Plane of Tranquility: move Avatar of Rallos Zek next to Dubbel Strohbarrel
-- The avatar (npc_types 344218, spawn2 3390208) spawned at (0, -186, -14), an
-- unreachable spot for players. Moved 12 units west of Dubbel Strohbarrel
-- (-1750, 499, -912.25), facing him. No pathgrid, no condition gating on the spawn.
-- Rollback: UPDATE spawn2 SET x=0, y=-186, z=-14, heading=0 WHERE id=3390208;

UPDATE `spawn2` SET `x` = -1762, `y` = 497, `z` = -912.25, `heading` = 57
WHERE `id` = 3390208 AND `zone` = 'potranquility';
