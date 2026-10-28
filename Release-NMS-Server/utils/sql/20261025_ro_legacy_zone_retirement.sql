-- 2026-10-25 Ro legacy-zone retirement: northro(392)/southro(393) -> nro(34)/sro(35)
-- The engine cannot load the legacy "revamped" Ro zones — it bounces players to
-- the classic ones. This retires the legacy zones:
--   1. zone_points: every line targeting 392/393 retargeted to 34/35
--      (freeporteast 40, freeportsewers 30, commonlands 30, oldcommons 30,
--      southro cross-lines, both generations).
--   2. Unique named NPCs stranded in the dead zones moved into the retro zones
--      (LDoN-era uniques with no retro twin — full list below). Camp NPCs that
--      ALREADY exist in the retro zones were deliberately left (no duplicates).
--   3. task_activities zones '393' -> '35' (task 3019; blessing 700127/700136/
--      700208). The '392' rows were fixed in 20261024/25 blessing migrations.
--   4. Two IT63 actor-pad objects (bonfire candidates, task 700208 "bonfire of
--      South Ro") moved into sro.
--   5. Takish_Porter added: clone of PoR_Porter (npc 1120001419) as
--      1120002547, spawngroup 500106, spawn2 1520023822 in sro at
--      (300, 1283, 79). Script quests/sro/Takish_Porter.lua gates on PoR
--      progression and MovePC(376, -1030, 100, 42) into takishruins.
--   6. Wayfarer_Porter.lua (nro + sro) retargeted from 392/393 to the retro
--      camps — code change, not SQL.
-- Rollback: swap zone ids back, restore per-NPC prior coords (see the v231
-- swap table for northro creature values), delete the porter rows.

UPDATE `zone_points` SET `target_zone_id` = 34 WHERE `target_zone_id` = 392;
UPDATE `zone_points` SET `target_zone_id` = 35 WHERE `target_zone_id` = 393;
UPDATE `task_activities` SET `zones` = '35' WHERE `zones` = '393';

-- northro -> nro (anchor spots beside verified nro content)
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 893,  s.y = 2672,  s.z = -25  WHERE s.zone = 'northro' AND n.name = '#Translocator_Ionie'; -- camp, by Wayfarer_Porter
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 909,  s.y = 2685,  s.z = -25  WHERE s.zone = 'northro' AND n.name = '#Verrell_Cogswin';   -- camp
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 925,  s.y = 2698,  s.z = -24  WHERE s.zone = 'northro' AND n.name = '#Havan_Kallir';      -- camp
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 1005, s.y = 2790,  s.z = -24  WHERE s.zone = 'northro' AND n.name = '#Queen_Tak`Yaliz';   -- LDoN Takish raid queen, own clearing by the camp
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 380,  s.y = -165,  s.z = -4   WHERE s.zone = 'northro' AND n.name = 'Dorn_B`Dynn';        -- beside the sand giant
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 352,  s.y = -138,  s.z = -4   WHERE s.zone = 'northro' AND n.name = 'Tak`Valnakor';       -- beside the sand giant
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 866,  s.y = 2648,  s.z = -25  WHERE s.zone = 'northro' AND n.name = 'Herald_of_the_Triumvirate';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 940,  s.y = 2652,  s.z = -24  WHERE s.zone = 'northro' AND n.name = 'Lamriiel_Mistigone';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 955,  s.y = 2640,  s.z = -24  WHERE s.zone = 'northro' AND n.name = 'Peridor_Sargar';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 930,  s.y = 2725,  s.z = -24  WHERE s.zone = 'northro' AND n.name = 'Rargahob_Dursaar';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 970,  s.y = 2737,  s.z = -24  WHERE s.zone = 'northro' AND n.name = 'Reidar_Elsai';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 899,  s.y = 2740,  s.z = -25  WHERE s.zone = 'northro' AND n.name = 'Roriella_Vellestan';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 912,  s.y = 2730,  s.z = -24  WHERE s.zone = 'northro' AND n.name = 'Wenthea_Bruann';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = -505, s.y = -1390, s.z = -1   WHERE s.zone = 'northro' AND n.name = 'Lydl_the_Great';     -- by the crypt mummy
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 477,  s.y = 3445,  s.z = -25  WHERE s.zone = 'northro' AND n.name = 'Guard_Doolin';       -- by Guard_Fintran
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'nro', s.x = 451,  s.y = 3444,  s.z = -25  WHERE s.zone = 'northro' AND n.name = 'Guard_Sheg';

-- southro -> sro (anchor spots beside verified sro content)
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 305,  s.y = 1259,  s.z = 79   WHERE s.zone = 'southro' AND n.name = '#Translocator_Tradil'; -- porter cluster
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1040, s.y = -1430, s.z = -24  WHERE s.zone = 'southro' AND n.name = '#Dimbwicket_Middifoodle'; -- LDoN camp
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1055, s.y = -1460, s.z = -24  WHERE s.zone = 'southro' AND n.name = '#Gnorble_Iceflinger';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1070, s.y = -1470, s.z = -24  WHERE s.zone = 'southro' AND n.name = '#Keelee_Rayin';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1048, s.y = -1445, s.z = -24  WHERE s.zone = 'southro' AND n.name = '#Plinkletop_Cogstopper';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1035, s.y = -1455, s.z = -24  WHERE s.zone = 'southro' AND n.name = '#Tacots_Silentblade';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1028, s.y = -1432, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Becoreen_Pathfinder';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1050, s.y = -1425, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Bryntelanka_Battlebringer';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 15,   s.y = 158,   s.z = -10  WHERE s.zone = 'southro' AND n.name = 'Cazel';               -- beside Sandgiant_Husam
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1030, s.y = -1478, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Dryssa_Hammerstock';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1062, s.y = -1482, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Gadallion';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1075, s.y = -1420, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Herald_of_the_Triumvirate';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1042, s.y = -1488, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Hurgo_Felcind';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1015, s.y = -1440, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Innkeep_Marnan';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1020, s.y = -1452, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Innkeep_Tizzy';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1068, s.y = -1455, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Isslana';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1055, s.y = -1435, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Jeysen_Voon';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1045, s.y = -1465, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Mantrek_Needlebender';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1303, s.y = -2400, s.z = -22  WHERE s.zone = 'southro' AND n.name = 'Mograk';              -- by the orc oracle
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1072, s.y = -1440, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Nura_Dumont';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1038, s.y = -1470, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Rack_Stonebelly';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1058, s.y = -1412, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Ranzall_Netcaster';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1065, s.y = -1428, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Synthan';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1078, s.y = -1445, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Transan';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1082, s.y = -1438, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Tran';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1024, s.y = -1462, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Taldrik_Stumpystout';
UPDATE `spawn2` s JOIN `spawnentry` se ON se.spawngroupID = s.spawngroupID JOIN `npc_types` n ON n.id = se.npcID
  SET s.zone = 'sro', s.x = 1090, s.y = -1432, s.z = -24  WHERE s.zone = 'southro' AND n.name = 'Bristlebanes_Party_Machine'; -- blessing 700136
UPDATE `spawn2` SET zone = 'sro', x = 310, y = 1295, z = 79 WHERE id = 3390203 AND zone = 'southro'; -- blessing Aspect of Erollisi Marr (700127), porter cluster

-- bonfire candidate objects (task 700208 "bonfire of South Ro")
UPDATE `object` SET zoneid = 35, xpos = 345, ypos = 1315, zpos = 79    WHERE id = 227840 AND zoneid = 393;
UPDATE `object` SET zoneid = 35, xpos = 1095, ypos = -1400, zpos = -24 WHERE id = 227842 AND zoneid = 393;

-- Takish_Porter (PoR takishruins zone-in)
DROP TABLE IF EXISTS nms_tmp_takish;
CREATE TABLE nms_tmp_takish AS SELECT * FROM npc_types WHERE id = 1120001419;
UPDATE nms_tmp_takish SET id = 1120002547, name = 'Takish_Porter';
INSERT INTO npc_types SELECT * FROM nms_tmp_takish;
DROP TABLE IF EXISTS nms_tmp_takish;
INSERT INTO `spawngroup` (`id`, `name`, `spawn_limit`, `delay`, `mindelay`, `despawn_timer`) VALUES (500106, 'sro_porter_1120002547', 1, 45000, 15000, 100);
INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES (500106, 1120002547, 100);
INSERT INTO `spawn2` (`id`, `spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `min_expansion`, `max_expansion`) VALUES (1520023822, 500106, 'sro', 0, 300, 1283, 79, 128, 640, -1, -1);
