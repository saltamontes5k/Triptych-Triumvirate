-- ============================================================================
-- Plane of War (powar, zoneidnumber 213) - PoP access wiring (Phase 1)
-- ----------------------------------------------------------------------------
-- Zone access + Plane of Tranquility portal. No coordinates required.
--
--   * zone 213: enable the engine zone-flag gate (flag_needed='1'), set the
--     level-65 requirement, and align safe_heading with the upstream value.
--     NOTE: safe_x/safe_y/safe_z are deliberately left at 0,0,0 so a GM can
--     stage in and scout the zone before spawns/return portal are placed.
--   * doors: potranquility doorid 19 (WARPORT500, the Plane of War stone)
--     currently has dest_zone='NONE'; point it at 'powar'.
--
-- The per-account gate is granted at runtime by
-- quests/potranquility/player.lua (door_requirements[19]) from the
-- 'pop.flags.rallos' account bucket, which #Rallos_Zek_the_Warlord.lua
-- (NPC 214113) already sets in the static instance.
--
-- Idempotent. Content-only: does not touch db_version.custom_version.
-- Re-apply after any reimport.
-- ============================================================================

UPDATE zone
SET flag_needed  = '1',
    min_level    = 65,
    safe_heading = 280
WHERE zoneidnumber = 213;

UPDATE doors
SET dest_zone     = 'powar',
    dest_instance = 0
WHERE zone = 'potranquility'
  AND doorid = 19
  AND name = 'WARPORT500';
