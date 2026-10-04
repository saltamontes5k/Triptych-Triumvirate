-- ============================================================================
-- 2026-10-04 Guild Lobby -> Neighborhood zone-in
--
-- The Guild Lobby irongate switch (OBJ_IRONGATESWITCH, doorid 77) drops players
-- at (332, -219, 0) in the neighborhood, away from the housing area. Point it at
-- the Sunrise Hills housing district instead.
--
-- Rows: id 152408 (v0), 36665 (v1), 152409 (v100).
-- Idempotent.
-- ============================================================================

UPDATE doors
SET dest_x = 2032,
    dest_y = -3002,
    dest_z = 4,
    dest_heading = 0
WHERE zone = 'guildlobby'
  AND dest_zone = 'neighborhood'
  AND doorid = 77;
