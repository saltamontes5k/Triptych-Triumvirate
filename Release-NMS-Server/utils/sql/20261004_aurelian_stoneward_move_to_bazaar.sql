-- ============================================================================
-- 2026-10-04 Move Aurelian Stoneward (progression NPC) to the Bazaar
--
-- Aurelian Stoneward (npc 344050, "Master of Progression") spawned in the Guild
-- Lobby. Move him into the Bazaar alongside the other item/service NPCs.
--
--   spawn2 id 2141240 -> bazaar at (-7, -661, 27)
--
-- The quest script moves from guildlobby/Aurelian_Stoneward.pl to
-- bazaar/Aurelian_Stoneward.pl (EQEmu loads NPC scripts by name per zone).
-- Idempotent.
-- ============================================================================

UPDATE spawn2
SET zone = 'bazaar',
    x    = -7,
    y    = -661,
    z    = 27
WHERE id = 2141240;
