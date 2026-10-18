-- ============================================================================
-- TBS / Katta Castrum faction wiring   (manifest v164)
--
-- Stock PEQ left every Katta Castrum NPC on faction 839 ("Katta Castrum"),
-- so Combine citizens, Shissar, and the water/undead denizens all conned the
-- same and killing one moved everything.  This splits the zone into three
-- self-contained groups, following the overhaul_<faction_list_id> convention
-- already used by overhaul_1140 / overhaul_1170:
--
--     1520000109  overhaul_1161  "Combine Citizens"   races 566
--     1520000110  overhaul_548   "Shissar of Chelsith" races 563 + 374
--     1520000111  overhaul_1165  "Katta Elementals"   races 431/475/476/477/478
--     1520000064  overhaul_1170  "Combine Empire Merchants" (all 23 vendors)
--
-- faction_list 548/1161/1165/1170 already exist; only 1161 and 1165 are
-- missing their faction_base_data row (548/1170 are already primed).  Each
-- group carries a single self-hit (-1) so kills move that faction only; there
-- are no cross-faction hits by design.
--
-- Every repoint is scoped to the zone's npc_types id range (416000-416999),
-- so overhaul_1140's members elsewhere are never touched.
--
-- Standalone twin of the manifest entry '20261017_tbs_katta_faction' (v164).
-- ============================================================================

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- 1. Base values for the two unprimed factions
-- ---------------------------------------------------------------------------
INSERT INTO `faction_base_data` (`client_faction_id`,`min`,`max`) VALUES
  (1161,-2000,2000),
  (1165,-2000,2000)
ON DUPLICATE KEY UPDATE `min`=VALUES(`min`), `max`=VALUES(`max`);

-- ---------------------------------------------------------------------------
-- 2. npc_faction groups + kill credit
-- ---------------------------------------------------------------------------
INSERT INTO `npc_faction` (`id`,`name`,`primaryfaction`,`ignore_primary_assist`) VALUES
  (1520000109,'overhaul_1161',1161,0),
  (1520000110,'overhaul_548', 548, 0),
  (1520000111,'overhaul_1165',1165,0);

INSERT INTO `npc_faction_entries`
  (`npc_faction_id`,`faction_id`,`value`,`npc_value`,`temp`) VALUES
  (1520000109,1161,-1,1,0),
  (1520000110,548, -1,1,0),
  (1520000111,1165,-1,1,0);

-- ---------------------------------------------------------------------------
-- 3. Repoints (zone-scoped; merchants last so they win over the race match)
-- ---------------------------------------------------------------------------
-- Shissar + Zhisza undead
UPDATE `npc_types` SET `npc_faction_id` = 1520000110
  WHERE `id` BETWEEN 416000 AND 416999 AND `race` IN (563,374);

-- Drowned / deep / whisperer / funnel denizens
UPDATE `npc_types` SET `npc_faction_id` = 1520000111
  WHERE `id` BETWEEN 416000 AND 416999 AND `race` IN (431,475,476,477,478);

-- Combine citizens (every race-566 NPC except the 23 vendors)
UPDATE `npc_types` SET `npc_faction_id` = 1520000109
  WHERE `id` BETWEEN 416000 AND 416999 AND `race` = 566
    AND `id` NOT IN (
      416019,416036,416038,416039,416041,416042,416044,416047,416049,416050,
      416053,416054,416057,416059,416060,416061,416064,416066,416068,416070,
      416071,416076,416078
    );

-- The 23 vendors
UPDATE `npc_types` SET `npc_faction_id` = 1520000064
  WHERE `id` IN (
    416019,416036,416038,416039,416041,416042,416044,416047,416049,416050,
    416053,416054,416057,416059,416060,416061,416064,416066,416068,416070,
    416071,416076,416078
  );
