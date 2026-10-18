-- v155: DoDH static zone-line web (version-0 zone_points).
-- The PEQ import only ever shipped four live corridors for the twenty
-- Depths of Darkhollow zones (nektulos-corathus, corathus-undershore,
-- undershore-illsalin, undershore-stoneroot, stoneroot-hive); everything
-- else - the raid sub-zones, the marketplace/pits/manor/lair satellites,
-- and Dreadspire Keep itself - had no lines at all. Dreadspire's only
-- outbound rows were dead 0,0,0 imports targeting Stoneroot (numbers
-- 30-70) and The Hive (80), and nothing anywhere targeted 351.
-- This wires the walkable graph (8 bidirectional edges / 16 rows):
--   drachnidhive  <-> dreadspire    (map POIs: to_Dreadspire_Keep /
--                                    to_The_Hive)
--   corathus      <-> corathusa     (Sporali Caverns; dod_raids antraygus
--                                    compass/zonein anchors)
--   eastkorlach   <-> eastkorlacha  (Snarlstone Dens; bloodeye anchors)
--   westkorlach   <-> westkorlacha  (Prince's Manor; shyra anchors)
--   westkorlach   <-> westkorlachc  (Lair of the Korlach; korlach anchors)
--   illsalin      <-> illsalinc     (Nargil Pits; draygun anchors)
--   eastkorlach   <-> illsalinb     (Temple of Korlach; council anchors)
--   drachnidhive  <-> drachnidhivec (Queen Sendaii's Lair; sendaii anchors)
-- Zone-in arrival points sit on the paired exit anchor; src rows for
-- sealed-portal anchors are offset +12 x so hailing the portal NPC does
-- not trip the line. Known leftovers (no coordinate source - maps repo
-- has no Brewall files for these): dreadspire<->stoneroot exit pair,
-- illsalin<->illsalina Marketplace, undershore<->shadowspine,
-- nektulos<->nektulosa Shadowed Grove, stoneroot<->westkorlachb,
-- hive->hatchery->cocoons chain, corathus<->corathusb. Corathus Creep's
-- known client-side connection break is untouched (pre-existing).
-- NOTE: fork zone_points orders y BEFORE x in the raw column list; this
-- script uses explicit column names.
-- Twin content of manifest entry '20261013_dodh_zone_links' (v155) in
-- common/database/database_update_manifest_custom.cpp (keep in sync).
-- Rollback = utils/sql/20261013_dodh_zone_links_rollback.sql.

-- ---------------------------------------------------------------------------
-- Prelude (keeps the script re-runnable; also clears the dead imports)
-- ---------------------------------------------------------------------------

DELETE FROM `zone_points`
WHERE `version` = 0 AND `zone` = 'dreadspire'
  AND `number` IN (30, 40, 50, 60, 70, 80);

DELETE FROM `zone_points`
WHERE `version` = 0 AND (
       (`zone` = 'drachnidhive'  AND `number` IN (50, 60))
    OR (`zone` = 'dreadspire'    AND `number` = 90)
    OR (`zone` = 'corathus'      AND `number` = 40)
    OR (`zone` = 'corathusa'     AND `number` = 10)
    OR (`zone` = 'eastkorlach'   AND `number` IN (60, 70))
    OR (`zone` = 'eastkorlacha'  AND `number` = 10)
    OR (`zone` = 'westkorlach'   AND `number` IN (50, 60))
    OR (`zone` = 'westkorlacha'  AND `number` = 10)
    OR (`zone` = 'westkorlachc'  AND `number` = 10)
    OR (`zone` = 'illsalin'      AND `number` = 10)
    OR (`zone` = 'illsalinc'     AND `number` = 10)
    OR (`zone` = 'illsalinb'     AND `number` = 10)
    OR (`zone` = 'drachnidhivec' AND `number` = 10));

-- ---------------------------------------------------------------------------
-- Edges (16 rows)
-- ---------------------------------------------------------------------------

INSERT INTO `zone_points`
  (`zone`,`version`,`number`,`x`,`y`,`z`,`heading`,
   `target_x`,`target_y`,`target_z`,`target_heading`,
   `zoneinst`,`target_zone_id`,`target_instance`,`buffer`,
   `min_expansion`,`max_expansion`,`is_virtual`,`height`,`width`)
VALUES
  -- The Hive <-> Dreadspire Keep (POI pair)
  ('drachnidhive', 0, 50, -1106,   -282,  452, 0, -1350, 1031, -575, 0, 0, 351, 0, 0, -1, -1, 0, 0, 0),
  ('dreadspire',   0, 90, -1350,   1031, -575, 0, -1106, -282,  452, 0, 0, 354, 0, 0, -1, -1, 0, 0, 0),
  -- Corathus Creep <-> Sporali Caverns
  ('corathus',     0, 40,    28,   -337,  -46, 0,   117,   89,  168, 0, 0, 366, 0, 0, -1, -1, 0, 0, 0),
  ('corathusa',    0, 10,   117,     89,  168, 0,    16, -337,  -46, 0, 0, 365, 0, 0, -1, -1, 0, 0, 0),
  -- The Undershore <-> Snarlstone Dens
  ('eastkorlach',  0, 60, -941.87, -1128.98, 184.13, 0, 1455, 502, -82, 0, 0, 363, 0, 0, -1, -1, 0, 0, 0),
  ('eastkorlacha', 0, 10,  1455,    502,  -82, 0, -953.87, -1128.98, 184.13, 0, 0, 362, 0, 0, -1, -1, 0, 0, 0),
  -- Stoneroot Falls <-> Prince's Manor
  ('westkorlach',  0, 50, -1718,   -337,    4, 0,  -503, -201,  12, 0, 0, 359, 0, 0, -1, -1, 0, 0, 0),
  ('westkorlacha', 0, 10,  -503,   -201,   12, 0, -1730, -337,   4, 0, 0, 358, 0, 0, -1, -1, 0, 0, 0),
  -- Stoneroot Falls <-> Lair of the Korlach
  ('westkorlach',  0, 60, -2217,    395,  895, 0,   -34, 1868,  84, 0, 0, 361, 0, 0, -1, -1, 0, 0, 0),
  ('westkorlachc', 0, 10,   -34,   1868,   84, 0, -2229,  395, 895, 0, 0, 358, 0, 0, -1, -1, 0, 0, 0),
  -- Ruins of Illsalin <-> The Nargil Pits
  ('illsalin',     0, 10,   320,   -182,  -32, 0,    -6, -664, -111, 0, 0, 350, 0, 0, -1, -1, 0, 0, 0),
  ('illsalinc',    0, 10,    -6,   -664, -111, 0,   308, -182, -32, 0, 0, 347, 0, 0, -1, -1, 0, 0, 0),
  -- The Undershore <-> Temple of Korlach
  ('eastkorlach',  0, 70,  -988,  -1250,  184, 0,  -207, -171, -21, 0, 0, 349, 0, 0, -1, -1, 0, 0, 0),
  ('illsalinb',    0, 10,  -207,   -171,  -21, 0, -1000, -1250, 184, 0, 0, 362, 0, 0, -1, -1, 0, 0, 0),
  -- The Hive <-> Queen Sendaii's Lair
  ('drachnidhive', 0, 60,  487.91, 202.56, 161.39, 0, 4, -8, -747, 0, 0, 357, 0, 0, -1, -1, 0, 0, 0),
  ('drachnidhivec',0, 10,     4,     -8, -747, 0, 475.91, 202.56, 161.39, 0, 0, 354, 0, 0, -1, -1, 0, 0, 0);
