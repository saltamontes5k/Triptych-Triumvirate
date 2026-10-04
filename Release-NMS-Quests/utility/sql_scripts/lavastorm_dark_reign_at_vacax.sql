-- =====================================================================
--  SUPERSEDED by lavastorm_don_camps_v0.sql (2026-10-02).
--  This file was never applied. It also carried the old Wayfarer dedup gap
--  (left 38270/38271/38272 in place) and skipped Officer_Vacax (45000332);
--  lavastorm_don_camps_v0.sql fixes both. Kept for history only.
-- =====================================================================
--  Lavastorm: Dark Reign gathered at Officer Vacax + Wayfarers / Wendel
--  Triptych Triumvirate
--
--  Part 1: the Dark Reign spawns were strung across the DoN merchant camp
--          (x 905-985, y -440..-330). Gather all 15 into one block on the
--          walkable ground around Officer Vacax Rol`Tas (spawn2 45000332).
--
--  Part 2: move the v0 Wayfarers' Mercenaries, and Wendel_Skyreach with them,
--          to the 1392, 1003, 129 spot.
--
--  Ground verified against the PLAYER map (C:\Games\EQTriune\maps\lavastorm.txt,
--  whose coordinates are the negative of server coords):
--    * Dark Reign pocket: walkable strip x 920-990, y -450..-350, ground z
--      0.18..5.79. Every position below sits on real map vertices; the camp's
--      existing z = 3 is kept.
--    * 1392, 1003 area: ground z 117.98..124.58, so z = 129 stands just above
--      the highest ground, matching the Keepers already placed there.
--
--  v0 ONLY. Every statement pins `version = 0`.
--
--  DELIBERATELY NOT TOUCHED - the v1 Wayfarer rows. On the v1 set the Wayfarers
--  live at 2219-2276 and Athir (264694) is v1-only:
--     264281 Wayfarers_Mercenary_Youra   264282 ..._Elanye   264283 ..._Varein
--     264694 Wayfarers_Mercenary_Athir
--  Beware 264281's spawngroup (paw-phhhhhhhh000) is a mixed pool that also
--  holds a_Rosch_Mas_Gnoll and a_Nisch_Mas_Gnoll -- moving that row would drag
--  two Paw gnolls along with it. It is v1 and stays put.
--  Note it also follows that Wayfarers_Mercenary_Athir does not exist on v0 at
--  all, so Athir cannot be placed in the v0 camp.
-- =====================================================================


-- =====================================================================
-- PART 1 - Dark Reign gathered around Officer Vacax Rol`Tas
-- =====================================================================

-- Command group.
UPDATE `spawn2` SET `x` = 966, `y` = -426, `z` = 3, `heading` = 0   WHERE `id` = 45000330 AND `version` = 0; -- General_Lereh_Dirr
UPDATE `spawn2` SET `x` = 943, `y` = -402, `z` = 3, `heading` = 128 WHERE `id` = 45000333 AND `version` = 0; -- Commander_Zaerr_Ty`Dar
UPDATE `spawn2` SET `x` = 976, `y` = -388, `z` = 3, `heading` = 320 WHERE `id` = 45000331 AND `version` = 0; -- Captain_Aleeth_Zyrv
UPDATE `spawn2` SET `x` = 954, `y` = -374, `z` = 3, `heading` = 256 WHERE `id` = 38278 AND `version` = 0; -- Captain_Aleeth_Zyrv (2nd copy)
UPDATE `spawn2` SET `x` = 930, `y` = -418, `z` = 3, `heading` = 64  WHERE `id` = 38279 AND `version` = 0; -- Officer_Sirrikis_Ryktor
UPDATE `spawn2` SET `x` = 988, `y` = -372, `z` = 3, `heading` = 192 WHERE `id` = 38289 AND `version` = 0; -- Xeib_Darkskies

-- Faction members and camp staff.
UPDATE `spawn2` SET `x` = 938, `y` = -440, `z` = 3, `heading` = 32  WHERE `id` = 38277 AND `version` = 0; -- #Talontar
UPDATE `spawn2` SET `x` = 952, `y` = -368, `z` = 3, `heading` = 448 WHERE `id` = 38275 AND `version` = 0; -- Celrak_Blightblood
UPDATE `spawn2` SET `x` = 940, `y` = -410, `z` = 3, `heading` = 96  WHERE `id` = 38276 AND `version` = 0; -- Daleynn_Spiritshadow
UPDATE `spawn2` SET `x` = 956, `y` = -384, `z` = 3, `heading` = 384 WHERE `id` = 45000347 AND `version` = 0;-- Daleynn_Spiritshadow (2nd copy)
UPDATE `spawn2` SET `x` = 926, `y` = -416, `z` = 3, `heading` = 32  WHERE `id` = 45000345 AND `version` = 0;-- Voltak_Shadethorn (merchant)

-- Dark Reign Guard pools (3 NPCs each), on the pocket's edge.
UPDATE `spawn2` SET `x` = 920, `y` = -430, `z` = 3, `heading` = 0   WHERE `id` = 38252 AND `version` = 0; -- Dark_Reign_Guard pool
UPDATE `spawn2` SET `x` = 942, `y` = -449, `z` = 3, `heading` = 320 WHERE `id` = 38253 AND `version` = 0; -- Dark_Reign_Guard pool
UPDATE `spawn2` SET `x` = 986, `y` = -361, `z` = 3, `heading` = 224 WHERE `id` = 38333 AND `version` = 0; -- Dark_Reign_Guard pool


-- =====================================================================
-- PART 2 - v0 Wayfarers' Mercenaries + Wendel_Skyreach -> 1392, 1003, 129
--
-- Each row gets its OWN position so the shared pools do not stack two NPCs on
-- the same spot: 38270 spawns 3 NPCs (Limann 100%, Youra 50%, Elanye 50%).
-- =====================================================================

UPDATE `spawn2` SET `x` = 1392, `y` = 975,  `z` = 129, `heading` = 32  WHERE `id` = 38270 AND `version` = 0; -- pool: Limann / Youra / Elanye
UPDATE `spawn2` SET `x` = 1368, `y` = 1008, `z` = 129, `heading` = 0   WHERE `id` = 38271 AND `version` = 0; -- Wayfarers_Mercenary_Bitral
UPDATE `spawn2` SET `x` = 1400, `y` = 1022, `z` = 129, `heading` = 128 WHERE `id` = 38272 AND `version` = 0; -- pool: Jeryx / Varein
UPDATE `spawn2` SET `x` = 1416, `y` = 990,  `z` = 129, `heading` = 64  WHERE `id` = 45000620 AND `version` = 0;-- Wayfarers_Mercenary_Elanye (dup row)
UPDATE `spawn2` SET `x` = 1428, `y` = 1010, `z` = 129, `heading` = 160 WHERE `id` = 45000621 AND `version` = 0;-- Wayfarers_Mercenary_Youra (dup row)
UPDATE `spawn2` SET `x` = 1352, `y` = 995,  `z` = 129, `heading` = 96  WHERE `id` = 45000622 AND `version` = 0;-- Wayfarers_Mercenary_Varein (dup row)

-- Wendel_Skyreach (DoN merchant) moves with the Wayfarers.
UPDATE `spawn2` SET `x` = 1392, `y` = 1042, `z` = 129, `heading` = 192 WHERE `id` = 45000346 AND `version` = 0;-- Wendel_Skyreach


-- =====================================================================
-- VERIFY
-- =====================================================================
-- Dark Reign: expect 15 rows, x 920-988, y -449..-361, z 3.
-- SELECT s2.id, nt.name, s2.x, s2.y, s2.z FROM spawn2 s2
--   JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID
--  WHERE s2.zone='lavastorm' AND s2.version=0 AND nt.npc_faction_id=1322
--  ORDER BY s2.x;
--
-- Wayfarers + Wendel: expect 7 v0 rows, all z 129 near 1392, 1003.
-- SELECT s2.id, nt.name, s2.x, s2.y, s2.z FROM spawn2 s2
--   JOIN spawnentry se ON se.spawngroupID=s2.spawngroupID
--   JOIN npc_types nt ON nt.id=se.npcID
--  WHERE s2.zone='lavastorm' AND s2.version=0
--    AND (nt.name LIKE '%Wayfarer%' OR nt.name LIKE '%Wendel%')
--  ORDER BY s2.id;
--
-- v1 Wayfarer rows must be unchanged (expect 2219..2276 and x -56..-9):
-- SELECT id, version, x, y, z FROM spawn2
--  WHERE id IN (264281,264282,264283,264694) ORDER BY id;


-- =====================================================================
-- ROLLBACK - positions before this script ran.
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
