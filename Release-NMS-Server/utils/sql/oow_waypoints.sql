-- ============================================================================
-- Omens of War — Discord waypoints
-- ----------------------------------------------------------------------------
-- Adds the OoW zones to the waypoint window under the "Discord" category (8),
-- alongside the existing Wall of Slaughter entry. Category names are rendered
-- client-side (eqgame_dll/waypoint_window.cpp): 7 = Taelosia, 8 = Discord.
-- Category 9 ("Special") is reserved/empty for future use.
--
-- The server auto-spawns the #TPTriggerN waypoint NPC (26999) in any zone with
-- a nms_waypoints row and global/#TPTriggerN.pl unlocks it on proximity, so no
-- spawn SQL is required. Restart the affected zones after applying.
--
-- Idempotent: INSERT IGNORE.
-- ============================================================================

-- Categories (7/8 already exist; add reserved 9)
INSERT IGNORE INTO nms_waypoints_categories (id, name) VALUES
  (7, 'Taelosia'),
  (8, 'Discord'),
  (9, 'Special');

-- Discord (OoW) waypoints. Wall of Slaughter already exists (category 8).
INSERT IGNORE INTO nms_waypoints (shortname, long_name, category, x, y, z, heading) VALUES
  ('draniksscar',    'Dranik''s Scar',            8, -1468, -1519,  260, 0),
  ('causeway',       'Nobles'' Causeway',         8,  -239, -1674,  317, 0),
  ('provinggrounds', 'Muramite Proving Grounds',  8,  -124, -5676, -306, 0),
  ('bloodfields',    'The Bloodfields',           8, -1763,  2140, -928, 0);
