-- ============================================================================
-- 2026-10-04 Christine absorbs the Sunrise Hills Realtor
--
-- Christine (npc 712000, neighborhood) now handles the housing duties. The
-- separate Sunrise_Hills_Realtor (npc 712024) is removed along with its spawn.
--
--   spawn2      45010123  (neighborhood, spawngroup 60010118)
--   spawnentry  spawngroupID 60010118
--   spawngroup  60010118  "Sunrise_Hills_Realtor_sg"
--   npc_types   712024
--
-- The quest script neighborhood/Christine.lua replaces
-- neighborhood/Sunrise_Hills_Realtor.lua.
-- Idempotent.
-- ============================================================================

DELETE FROM spawn2      WHERE id = 45010123;
DELETE FROM spawnentry  WHERE spawngroupID = 60010118;
DELETE FROM spawngroup  WHERE id = 60010118;
DELETE FROM npc_types   WHERE id = 712024;
