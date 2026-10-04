-- ============================================================================
-- 2026-09-26 Player-house interiors: safe points sat far below the map floor.
--
-- The house key (item 9015300) calls MoveZoneInstance() with no coordinates,
-- which resolves to ZoneMode::ZoneToSafeCoords (zone/zoning.cpp) -- so the
-- destination zone's safe_x/y/z is the arrival point, and phinterior*/zone.lua
-- rings the furniture placement slots around that arrival. Every interior had
-- safe_z 23-33 units below the actual .map floor, so owners and guests zoned in
-- under the world.
--
-- The values below are the map floor at each zone's safe X/Y, verified against
-- the base/*.map geometry. The two treehouse zones had no floor at their old
-- X/Y (102,87), so they move to the zone origin (floor 0, ~21 units headroom).
--
-- Companion compiled migration: manifest_entries_custom version 79.
-- Idempotent: only rewrites rows still carrying the broken negative Z.
-- ============================================================================

UPDATE zone SET safe_z = 0.0
WHERE short_name IN (
  'phinterior1a1','phinterior1a2','phinterior1a3',
  'phinterior1b1','phinterior1b2','phinterior1b3',
  'phinterior1c1','phinterior1d1',
  'phinterior3a1','phinterior3a2','phinterior3a3',
  'phinterior6a1','phinterior6a2','phinterior6a3'
) AND safe_z < 0;

UPDATE zone SET safe_x = 0, safe_y = 0, safe_z = 0
WHERE short_name IN ('phinteriortree','phinteriortree3br') AND safe_z < 0;

UPDATE zone SET safe_z = -4.0
WHERE short_name = 'plhogrinteriors1a1' AND safe_z < 0;
