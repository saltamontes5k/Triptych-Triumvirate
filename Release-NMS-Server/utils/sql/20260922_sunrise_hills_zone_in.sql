-- ============================================================================
-- 2026-09-22 Sunrise Hills (neighborhood, zone 712) zone-in point
-- Move the zone-in/safe point to (2035, -3006, 4), directly outside the
-- guild gate (door 34089 / OBJ_GUILDGATE at 2034.34, -3010.55).
-- Idempotent UPDATE by short_name.
-- ============================================================================

UPDATE zone
SET safe_x = 2035,
    safe_y = -3006,
    safe_z = 4
WHERE short_name = 'neighborhood';