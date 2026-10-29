-- ============================================================================
-- Expansion waypoints, batch 2 (2026-10-28)
-- ----------------------------------------------------------------------------
-- Adds TBS/TSS/SoD/VoA-era zones to the Magic Map waypoint window under the
-- maintainer's category layout: 6 = The Planes (arcstone, the devastation),
-- 0 = Antonica (TSS overworlds, The Hive, Ruins of Takish-Hiz),
-- 2 = Odus (TBS/VoA/TDS zones; same category as Toxxulia Forest),
-- 1 = Faydwer (Dragonscale Hills, Loping Plains). Category names are rendered
-- client-side (eqgame_dll/waypoint_window.cpp), so no DB category row is new.
--
-- Coordinates are each zone's safe point (zone table) except drachnidhive,
-- which has no safe point — it uses the static zone's westkorlach exit
-- corridor (zone_points v0, number 60). stonesnake's z comes from the FSP
-- spawns sitting on its safe point (zone table z is NULL there).
--
-- The server auto-spawns the #TPTriggerN waypoint NPC (26999) in any zone with
-- a nms_waypoints row and global/#TPTriggerN.pl unlocks it on proximity, so no
-- spawn SQL is required. Restart the affected zones after applying.
--
-- Idempotent: INSERT IGNORE (shortname is UNIQUE).
-- ============================================================================

INSERT IGNORE INTO nms_waypoints (shortname, long_name, category, x, y, z, heading) VALUES
  -- The Planes
  ('arcstone',      'Arcstone, Isle of Spirits', 6,  1630,  -279,    5, 0),
  ('devastation',   'The Devastation',           6,  1390,   216,   53, 0),
  -- Antonica
  ('crescent',      'Crescent Reach',            0,    -8,    11,    2, 0),
  ('sunderock',     'Sunderock Springs',         0,  -393, -3454,    4, 0),
  ('icefall',       'Icefall Glacier',           0,   765, -1871,  -46, 0),
  ('direwind',      'Direwind Cliffs',           0,  -329, -1845,   10, 0),
  ('corathus',      'Corathus Creep',            0,    16,  -337,  -46, 0),
  ('westkorlach',   'Stoneroot Falls',           0, -2229,   395,  895, 0),
  ('drachnidhive',  'The Hive',                  0,   487,   202,  161, 0),
  ('takishruins',   'Ruins of Takish-Hiz',       0,  -983,   269,   62, 0),
  -- Odus
  ('buriedsea',     'The Buried Sea',            2,  3130, -1721,  308, 0),
  ('barren',        'Barren Coast',              2,  1203,   698,   54, 0),
  ('kattacastrum',  'Katta Castrum',             2,    -2,  -425,  -20, 0),
  ('brellsrest',    'Brell''s Rest',             2,   116,  -700,   53, 0),
  ('underquarry',   'The Underquarry',           2,    46,  -190, -196, 0),
  ('fungalforest',  'Fungal Forest',             2,  2704,   233,  342, 0),
  ('stonesnake',    'Volska''s Husk',            2,    50,    24,   -5, 0),
  -- Faydwer
  ('dragonscale',   'Dragonscale Hills',         1, -1954,  3916,   19, 0),
  ('lopingplains',  'Loping Plains',             1, -3698, -1289,  722, 0);
