-- =====================================================================
--  Lavastorm: DoN camps finalized (v0 only)
--  Triptych Triumvirate
--
--  Consolidates and supersedes:
--    * lavastorm_keepers_and_porter_fix.sql (Keepers part)
--    * lavastorm_dark_reign_at_vacax.sql    (never applied; Dark Reign +
--                                            Wayfarers/Wendel part)
--
--  What this does, all pinned to `version = 0`:
--    A. Deletes duplicate/orphaned v0 rows so each camp NPC has one spawn:
--         - 38278 old Captain_Aleeth_Zyrv   (45000331 is the live copy)
--         - 38276 old Daleynn_Spiritshadow  (45000347 is the live copy)
--         - 38270/38271/38272 upstream Wayfarer pools (the six custom
--           100% single-NPC rows already cover all six Wayfarers)
--    B. Moves the whole Norrath's Keepers camp to 712, 1242, 41, including
--       Wendel_Skyreach (45000346). They were previously camped on the
--       Lavastorm druid ring (1392,1003,129), right on the port-in, and the
--       guards killed players as they landed.
--    C. Moves the six v0 Wayfarers' Mercenaries to -144, 311, 1.
--    D. Gathers every Dark Reign v0 row onto the merchant camp at
--       941, -393, 3, including Officer_Vacax (45000332), which the old
--       script skipped.
--    E. Adds v0 spawns for the three NPCs that only existed on v1:
--         27086 #Bianca_Galbraith, 27088 #Boldger_Bristlebeard,
--         27092 #Pericolo_L`Morte
--
--  Ground notes:
--    * Keeper camp 712,1242: the requested z = 41 is ~145 units below the
--      plateau the x/y sits on, so the NPCs were inside geometry. The z values
--      below are the SERVER collision-mesh ground (maps/base/lavastorm.map,
--      sampled per loc) + 2. They run z 174-188.
--    * Wayfarer camp -144,311,1: z = 1 matches the mesh ground there
--      (mesh ground -2..2; Sidern_Delangan sits far below at z -94).
--    * Dark Reign pocket x 920-990, y -450..-350: ground z 0.18..5.79, so the
--      camp's existing z = 3 is kept.
--
--  The v1 set is deliberately untouched (v1 scripts still resolve from
--  lavastorm/v1/<Name>.lua, and the new v0 NPC spawns use brand-new rows).
--
--  ID blocks used (checked free in the live peq DB):
--    spawn2      45000641-45000643
--    spawngroup  60005201-60005203
--    spawngroup  60005120-60005122 (Part F repair: this block had been wiped,
--                  leaving Limann/Bitral/Jeryx with no spawngroup and thus
--                  unspawned; Youra's 60005170 survived because it was part of
--                  the upstream set alongside Elanye/Varein's 60005169/71)
--
--  Applied to the live peq DB. Safe to re-run: scoped DELETEs/UPDATEs plus
--  INSERT IGNORE. After applying: #repop in Lavastorm and #reload quest.
--  Note: spawn table changes need a lavastorm zone REBOOT to load; #repop
--  alone only respawns the set cached at boot.
-- =====================================================================


-- =====================================================================
-- PART A - remove duplicate / orphaned v0 rows
-- =====================================================================

-- Old auto-named duplicates; the custom rows 45000331 / 45000347 are the
-- copies the camp keeps. Each spawngroup below is used only by its one row.
DELETE FROM `spawn2`     WHERE `id` IN (38278, 38276) AND `version` = 0;
DELETE FROM `spawnentry` WHERE `spawngroupID` IN (15990, 15981);
DELETE FROM `spawngroup` WHERE `id` IN (15990, 15981);

-- Upstream Wayfarer pools (Limann/Youra/Elanye, Bitral, Jeryx/Varein).
-- The custom rows 45000453/45000454/45000455/45000620/45000621/45000622
-- spawn all six individually at 100% (their spawngroups are backfilled in
-- Part F; three of them had been wiped).
DELETE FROM `spawn2`     WHERE `id` IN (38270, 38271, 38272) AND `version` = 0;
DELETE FROM `spawnentry` WHERE `spawngroupID` IN (15979, 15991, 16071);
DELETE FROM `spawngroup` WHERE `id` IN (15979, 15991, 16071);


-- =====================================================================
-- PART B - Norrath's Keepers camp (faction 1040) -> 712, 1242 (plateau)
--
-- The x/y were requested as 712, 1242. The z here is the SERVER collision-mesh
-- ground (maps/base/lavastorm.map, sampled per loc) + 2. The originally
-- requested z = 41 is ~145 units below this plateau and leaves the NPCs inside
-- geometry (there is no z = 41 surface at 712, 1242).
-- =====================================================================

-- Named faction NPCs, fanned around 712, 1242.
UPDATE `spawn2` SET `x` = 702, `y` = 1242, `z` = 185, `heading` = 64  WHERE `id` = 38280    AND `version` = 0; -- Chieftain_Relae_Aderi
UPDATE `spawn2` SET `x` = 688, `y` = 1224, `z` = 180, `heading` = 96  WHERE `id` = 45000334 AND `version` = 0; -- Private_Nylaen_Kel`Ther
UPDATE `spawn2` SET `x` = 682, `y` = 1251, `z` = 179, `heading` = 32  WHERE `id` = 38281    AND `version` = 0; -- Keeper_Dilar_Nelune
UPDATE `spawn2` SET `x` = 695, `y` = 1269, `z` = 183, `heading` = 448 WHERE `id` = 38282    AND `version` = 0; -- Lieutenant_Ekiltu_Verlor
UPDATE `spawn2` SET `x` = 718, `y` = 1271, `z` = 188, `heading` = 384 WHERE `id` = 38283    AND `version` = 0; -- Captain_Areha_Burina
UPDATE `spawn2` SET `x` = 724, `y` = 1254, `z` = 187, `heading` = 320 WHERE `id` = 38290    AND `version` = 0; -- Tatsujiro_the_Serene (merchant)
UPDATE `spawn2` SET `x` = 732, `y` = 1264, `z` = 187, `heading` = 288 WHERE `id` = 38273    AND `version` = 0; -- #Kanetheus_Forestwalker
UPDATE `spawn2` SET `x` = 738, `y` = 1244, `z` = 186, `heading` = 256 WHERE `id` = 38274    AND `version` = 0; -- #Gordish_Frozenheart

-- Guard / Scout pools (3 NPCs each).
UPDATE `spawn2` SET `x` = 712, `y` = 1196, `z` = 186, `heading` = 0   WHERE `id` = 38232    AND `version` = 0; -- Keepers Guard/Scout pool
UPDATE `spawn2` SET `x` = 740, `y` = 1220, `z` = 186, `heading` = 320 WHERE `id` = 38233    AND `version` = 0; -- Keepers Guard/Scout pool
UPDATE `spawn2` SET `x` = 670, `y` = 1239, `z` = 174, `heading` = 96  WHERE `id` = 38350    AND `version` = 0; -- Keepers Guard/Scout pool

-- Wendel_Skyreach (DoN merchant) stays with the Keepers.
UPDATE `spawn2` SET `x` = 728, `y` = 1234, `z` = 187, `heading` = 192 WHERE `id` = 45000346 AND `version` = 0; -- Wendel_Skyreach

-- Bianca / Boldger also exist as v0 rows (created in Part E on a fresh DB; moved
-- here when the camps already exist from an earlier run).
UPDATE `spawn2` SET `x` = 752, `y` = 1239, `z` = 185, `heading` = 224 WHERE `id` = 45000642 AND `version` = 0; -- #Bianca_Galbraith
UPDATE `spawn2` SET `x` = 752, `y` = 1257, `z` = 186, `heading` = 240 WHERE `id` = 45000643 AND `version` = 0; -- #Boldger_Bristlebeard


-- =====================================================================
-- PART C - v0 Wayfarers' Mercenaries -> -144, 311, 1 (faction 0)
--
-- One distinct loc per row so the single-NPC spawns do not stack.
-- =====================================================================

UPDATE `spawn2` SET `x` = -184, `y` = 280, `z` = 1, `heading` = 32  WHERE `id` = 45000453 AND `version` = 0; -- Wayfarers_Mercenary_Limann
UPDATE `spawn2` SET `x` = -196, `y` = 308, `z` = 1, `heading` = 0   WHERE `id` = 45000454 AND `version` = 0; -- Wayfarers_Mercenary_Bitral
UPDATE `spawn2` SET `x` = -188, `y` = 330, `z` = 1, `heading` = 96  WHERE `id` = 45000455 AND `version` = 0; -- Wayfarers_Mercenary_Jeryx
UPDATE `spawn2` SET `x` = -95,  `y` = 288, `z` = 1, `heading` = 128 WHERE `id` = 45000620 AND `version` = 0; -- Wayfarers_Mercenary_Elanye
UPDATE `spawn2` SET `x` = -88,  `y` = 310, `z` = 1, `heading` = 160 WHERE `id` = 45000621 AND `version` = 0; -- Wayfarers_Mercenary_Youra
UPDATE `spawn2` SET `x` = -95,  `y` = 332, `z` = 1, `heading` = 192 WHERE `id` = 45000622 AND `version` = 0; -- Wayfarers_Mercenary_Varein


-- =====================================================================
-- PART D - Dark Reign (faction 1322) -> 941, -393, 3
-- =====================================================================

-- Command group (Officer_Vacax 45000332 is the anchor and is finally moved).
UPDATE `spawn2` SET `x` = 966, `y` = -426, `z` = 3, `heading` = 0   WHERE `id` = 45000330 AND `version` = 0; -- General_Lereh_Dirr
UPDATE `spawn2` SET `x` = 943, `y` = -402, `z` = 3, `heading` = 128 WHERE `id` = 45000333 AND `version` = 0; -- Commander_Zaerr_Ty`Dar
UPDATE `spawn2` SET `x` = 976, `y` = -388, `z` = 3, `heading` = 320 WHERE `id` = 45000331 AND `version` = 0; -- Captain_Aleeth_Zyrv
UPDATE `spawn2` SET `x` = 941, `y` = -393, `z` = 3, `heading` = 0   WHERE `id` = 45000332 AND `version` = 0; -- Officer_Vacax_Rol`Tas
UPDATE `spawn2` SET `x` = 930, `y` = -418, `z` = 3, `heading` = 64  WHERE `id` = 38279    AND `version` = 0; -- Officer_Sirrikis_Ryktor
UPDATE `spawn2` SET `x` = 988, `y` = -372, `z` = 3, `heading` = 192 WHERE `id` = 38289    AND `version` = 0; -- Xeib_Darkskies

-- Faction members and camp staff.
UPDATE `spawn2` SET `x` = 938, `y` = -440, `z` = 3, `heading` = 32  WHERE `id` = 38277    AND `version` = 0; -- #Talontar
UPDATE `spawn2` SET `x` = 952, `y` = -368, `z` = 3, `heading` = 448 WHERE `id` = 38275    AND `version` = 0; -- Celrak_Blightblood
UPDATE `spawn2` SET `x` = 956, `y` = -384, `z` = 3, `heading` = 384 WHERE `id` = 45000347 AND `version` = 0; -- Daleynn_Spiritshadow
UPDATE `spawn2` SET `x` = 926, `y` = -416, `z` = 3, `heading` = 32  WHERE `id` = 45000345 AND `version` = 0; -- Voltak_Shadethorn (merchant)

-- Dark Reign Guard pools (3 NPCs each).
UPDATE `spawn2` SET `x` = 920, `y` = -430, `z` = 3, `heading` = 0   WHERE `id` = 38252    AND `version` = 0; -- Dark_Reign_Guard pool
UPDATE `spawn2` SET `x` = 942, `y` = -449, `z` = 3, `heading` = 320 WHERE `id` = 38253    AND `version` = 0; -- Dark_Reign_Guard pool
UPDATE `spawn2` SET `x` = 986, `y` = -361, `z` = 3, `heading` = 224 WHERE `id` = 38333    AND `version` = 0; -- Dark_Reign_Guard pool


-- =====================================================================
-- PART E - v0 spawns for the three v1-only NPCs
-- =====================================================================

INSERT IGNORE INTO `spawngroup` (`id`, `name`, `spawn_limit`, `dist`) VALUES
(60005201, 'lavastorm_don_good_bianca',    0, 0),
(60005202, 'lavastorm_don_good_boldger',   0, 0),
(60005203, 'lavastorm_don_dark_pericolo',  0, 0);

INSERT IGNORE INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES
(60005201, 27086, 100),
(60005202, 27088, 100),
(60005203, 27092, 100);

INSERT IGNORE INTO `spawn2`
(`id`, `spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `variance`, `pathgrid`) VALUES
(45000641, 60005203, 'lavastorm', 0, 952,  -408, 3,   128, 640, 0, 0), -- #Pericolo_L`Morte (Dark Reign)
(45000642, 60005201, 'lavastorm', 0, 752,  1239, 185, 224, 640, 0, 0), -- #Bianca_Galbraith (Keepers)
(45000643, 60005202, 'lavastorm', 0, 752,  1257, 186, 240, 640, 0, 0); -- #Boldger_Bristlebeard (Keepers)


-- =====================================================================
-- PART F - repair the wiped Wayfarer spawngroup block (2026-10-02)
--
-- Part C moves six v0 Wayfarer rows, but spawngroups 60005120/60005121/
-- 60005122 (Limann/Bitral/Jeryx) did not exist, so those three never
-- spawned. Backfill them with the same values as the surviving sibling
-- 60005170. Also drop Talwyn_Flamecaller's dead duplicate row 45000456:
-- it pointed at never-created spawngroup 60005123 and duplicated the
-- working upstream spawn 38291 at the exact same loc.
-- =====================================================================

INSERT IGNORE INTO `spawngroup` (`id`, `name`, `spawn_limit`, `dist`) VALUES
(60005120, 'lavastorm_don_wayfarer_limann', 0, 0),
(60005121, 'lavastorm_don_wayfarer_bitral', 0, 0),
(60005122, 'lavastorm_don_wayfarer_jeryx',  0, 0);

UPDATE IGNORE `spawngroup` SET
  `delay` = 45000, `mindelay` = 15000, `despawn` = 0, `despawn_timer` = 100, `wp_spawns` = 0
WHERE `id` IN (60005120, 60005121, 60005122);

DELETE FROM `spawn2`     WHERE `id` = 45000456 AND `version` = 0;
DELETE FROM `spawnentry` WHERE `spawngroupID` = 60005123 AND `npcID` = 27111;


-- =====================================================================
-- VERIFY
-- =====================================================================
-- Keepers (named + guard pools + Wendel), expect z 41, x/y near 712,1242:
-- SELECT s2.id, nt.name, s2.x, s2.y, s2.z FROM spawn2 s2
--   JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID
--  WHERE s2.zone='lavastorm' AND s2.version=0 AND nt.npc_faction_id=1040 ORDER BY s2.x;
--
-- Dark Reign (16 rows incl. Pericolo), expect z 3, x 920-988:
-- SELECT s2.id, nt.name, s2.x, s2.y, s2.z FROM spawn2 s2
--   JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID
--  WHERE s2.zone='lavastorm' AND s2.version=0 AND nt.npc_faction_id=1322 ORDER BY s2.x;
--
-- Wayfarers, expect 6 rows at z 1 near -144,311:
-- SELECT s2.id, nt.name, s2.x, s2.y, s2.z FROM spawn2 s2
--   JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID
--  WHERE s2.zone='lavastorm' AND s2.version=0 AND nt.name LIKE '%Wayfarer%' ORDER BY s2.id;
--
-- Deleted rows must be gone and the v1 set unchanged:
-- SELECT id FROM spawn2 WHERE id IN (38270,38271,38272,38276,38278);
-- SELECT id, version, x, y, z FROM spawn2 WHERE id IN (250644,250645,250654,264696,264697) ORDER BY id;


-- =====================================================================
-- ROLLBACK (pre-change v0 positions; deleted rows are irrecoverable unless
-- restored from the spawn2_bak_* tables)
-- =====================================================================
-- Dark Reign
-- UPDATE `spawn2` SET `x` = 955, `y` = -385, `z` = 3 WHERE `id` = 45000330 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 974, `y` = -395, `z` = 3 WHERE `id` = 45000333 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 962, `y` = -399, `z` = 3 WHERE `id` = 45000331 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 935, `y` = -405, `z` = 3 WHERE `id` = 38278 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 942, `y` = -415, `z` = 3 WHERE `id` = 38279 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 985, `y` = -410, `z` = 3 WHERE `id` = 38289 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 945, `y` = -355, `z` = 3 WHERE `id` = 38277 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 940, `y` = -370, `z` = 3 WHERE `id` = 38275 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 930, `y` = -360, `z` = 3 WHERE `id` = 38276 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 920, `y` = -390, `z` = 3 WHERE `id` = 45000347 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 920, `y` = -425, `z` = 3 WHERE `id` = 45000345 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 905, `y` = -370, `z` = 3 WHERE `id` = 38252 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 941, `y` = -440, `z` = 3 WHERE `id` = 38253 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 960, `y` = -330, `z` = 3 WHERE `id` = 38333 AND `version` = 0;
-- Wayfarers + Wendel (v0)
-- UPDATE `spawn2` SET `x` = -25, `y` = 2219, `z` = 71 WHERE `id` = 38270 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = -48, `y` = 2268, `z` = 70 WHERE `id` = 38271 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = -51, `y` = 2224, `z` = 68 WHERE `id` = 38272 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = -20.807211, `y` = 2241.131348, `z` = 70 WHERE `id` = 45000620 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = -9.289207, `y` = 2220.938965, `z` = 73 WHERE `id` = 45000621 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = -56.073338, `y` = 2236.316895, `z` = 70 WHERE `id` = 45000622 AND `version` = 0;
-- UPDATE `spawn2` SET `x` = 962, `y` = -390, `z` = 3 WHERE `id` = 45000346 AND `version` = 0;
-- new v0-only rows
-- DELETE FROM `spawn2` WHERE `id` IN (45000641,45000642,45000643);
