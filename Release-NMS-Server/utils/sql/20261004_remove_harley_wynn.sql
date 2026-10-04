-- ============================================================================
-- 2026-10-04 Remove Harley Wynn (Guild Lobby gambling NPC)
--
--   spawn2      2141248  (guildlobby, spawngroup 5004028)
--   spawnentry  spawngroupID 5004028
--   spawngroup  5004028
--   npc_types   344049   Harley_Wynn ("Lucky Draw")
--
-- The runtime quest script guildlobby/Harley_Wynn.pl is removed alongside this.
-- Idempotent.
-- ============================================================================

DELETE FROM spawn2     WHERE id = 2141248;
DELETE FROM spawnentry WHERE spawngroupID = 5004028;
DELETE FROM spawngroup WHERE id = 5004028;
DELETE FROM npc_types  WHERE id = 344049;
