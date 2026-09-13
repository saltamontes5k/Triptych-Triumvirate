-- ============================================================================
-- NMS expansion zone unlock - clear the hard min_status lock for released eras
-- ----------------------------------------------------------------------------
-- The per-account expansion gates are the intended lock:
--   Release-NMS-Plugins/NMS_progression_utils.pl  (is_eligible_for_zone)
--   quests/global/global_player.pl                (bounce to Bazaar on enter/connect/door)
-- The base import ALSO hard-locked every zone from Lost Dungeons (exp 6) through
-- Secrets of Faydwer (exp 14) with zone.min_status = 255. Client::CanEnterZone
-- denies any status-0 character from a 255 zone (see zone/zoning.cpp), so those
-- per-account gates never got a chance to run. The motivating case is Omens of War:
-- the Tunat`Muram Cuu Vauax kill sets the OoW account flag correctly, but the zone
-- still rejected the player.
--
-- Setting min_status = 0 for the released eras (expansion <= 14) lets the
-- per-account gates govern access. Expansions > 14 stay hard-locked at 255.
--
-- Idempotent: only touches rows still at 255. Re-apply after any reimport.
-- ============================================================================

UPDATE zone SET min_status = 0 WHERE expansion <= 14 AND min_status = 255;
