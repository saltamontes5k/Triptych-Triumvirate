-- ============================================================================
-- 2026-09-22 Guild Lobby v1 exit doors (36630 / 36632)
-- The version 1 OBJ_GUILD_DOOR rows in guildlobby had dest_zone='NONE',
-- so clicking them did nothing. Point them at the guild hall (0, 20, 3),
-- matching the v0 (11963/11965) and v100 (144531/144533) counterparts.
-- Idempotent UPDATE by door id.
-- ============================================================================

UPDATE doors
SET dest_zone = 'guildhall',
    dest_instance = 0,
    dest_x = 0,
    dest_y = 20,
    dest_z = 3,
    dest_heading = 0
WHERE id IN (36630, 36632);