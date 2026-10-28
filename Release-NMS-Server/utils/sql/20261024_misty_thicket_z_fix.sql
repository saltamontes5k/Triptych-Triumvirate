-- 2026-10-24 Misty Thicket: raise blessing NPCs from underground to ground level
-- Nettle_Higglesbury (npc_types 600156, spawn2 3390216, at -703, 355) and the
-- an_angry_farmer group (npc_types 344267-344276, all sharing spawn2 3390274 at
-- -705, 345 via one spawn group) spawned at z=3, deep under the terrain.
-- Nearby ground reference: a_black_wolf spawn at (-755, 313) stands on z=59.
-- Only z is touched (floor of 64); x, y, heading unchanged.
-- Rollback: UPDATE spawn2 SET z=3 WHERE id IN (3390216, 3390274);

UPDATE `spawn2` SET `z` = 64
WHERE `id` IN (3390216, 3390274) AND `zone` = 'misty' AND `z` < 64;
