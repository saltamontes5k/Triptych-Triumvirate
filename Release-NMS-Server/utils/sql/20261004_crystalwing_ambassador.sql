-- ============================================================================
-- 2026-10-04 Crystalwing Scholar -> Ambassador of the Crystalwing
--
-- The Plane of Knowledge gatekeeper to Crescent Reach (npc 202533) is renamed.
-- Its quest script is renamed to match: poknowledge/Ambassador_of_the_Crystalwing.lua
-- (EQEmu loads quest scripts by NPC name).
-- Idempotent.
-- ============================================================================

UPDATE npc_types
SET name     = 'Ambassador_of_the_Crystalwing',
    lastname = 'Port and Embassy'
WHERE id = 202533;
