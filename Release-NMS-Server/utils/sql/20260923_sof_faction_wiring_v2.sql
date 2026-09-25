-- ============================================================================
-- SoF faction wiring — ROLLBACK of 20260923_sof_faction_wiring.sql + REDO
-- on collision-free ids.
--
-- What went wrong with the first apply:
--   npc_faction ids 1520000091/92 were NOT free (already used by the overhaul
--   as overhaul_1229 / overhaul_1232, SoD-era groups). INSERT IGNORE silently
--   skipped the new rows, and the subsequent UPDATEs then moved SoF givers,
--   vendors, and Crystallos trash onto those foreign groups.
--
-- Rollback restores every touched row to its audited pre-apply value
-- (captured in the pre-apply queries; 442006 confirmed 0 from the
-- release-peq.sql dump, npc_types column 24), then rebuilds the change on
-- 1520000102 / 1520000103 (max id at time of writing: 1520000101).
--
-- The npc_faction_entries rows on 1520000073 / 1520000075 / 1520000076 were
-- correct and are KEPT (not touched here).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Rollback repoints
-- ---------------------------------------------------------------------------
UPDATE `npc_types` SET `npc_faction_id` = 1520000073 WHERE `id` IN (
	436000, 436001, 436003, 436004, 436006, 436007, 436010, 436011, 436012,
	442005, 442013, 442014, 442015, 442017, 442018,
	442096, 442099, 442100,
	438011, 438018, 438019
);

UPDATE `npc_types` SET `npc_faction_id` = 0 WHERE `id` IN (
	442006, 442008, 442009, 442012,
	442032, 442048, 442102, 442104, 442120, 442140,
	438007, 438013
);

UPDATE `npc_types` SET `npc_faction_id` = 526
WHERE `npc_faction_id` = 1520000092 AND `id` BETWEEN 446000 AND 446199;

-- Remove the two entries that landed on the foreign group
DELETE FROM `npc_faction_entries`
WHERE `npc_faction_id` = 1520000092 AND `faction_id` IN (1188, 526);

-- ---------------------------------------------------------------------------
-- 2. REDO on free ids (plain INSERT: an id collision must ERROR, not skip)
-- ---------------------------------------------------------------------------
INSERT INTO `npc_faction` (`id`, `name`, `primaryfaction`, `ignore_primary_assist`) VALUES
	(1520000102, 'sof_1190_akanon_strike_force', 1190, 0),
	(1520000103, 'sof_1188_crystallos_denizens',  526, 0);

-- Ak`Anon Strike Force (1190) givers + vendors
UPDATE `npc_types` SET `npc_faction_id` = 1520000102 WHERE `id` IN (
	436000, 436001, 436003, 436004, 436006, 436007, 436010, 436011, 436012,
	442005, 442006, 442008, 442009, 442012, 442013, 442014, 442015, 442017, 442018
);

-- Ladies of the Light (1185) givers + vendor
UPDATE `npc_types` SET `npc_faction_id` = 1520000067 WHERE `id` IN (
	442096, 442099, 442100, 442104
);

-- Crusaders of Veeshan (1188) vendors
UPDATE `npc_types` SET `npc_faction_id` = 1520000068 WHERE `id` IN (
	442032, 442048, 442102, 442120, 442140
);

-- Brownie Rebels (1189) givers + vendors
UPDATE `npc_types` SET `npc_faction_id` = 1520000069 WHERE `id` IN (
	438007, 438011, 438013, 438018, 438019
);

-- Crystallos trash: dedicated group (preserves con primary 526)
UPDATE `npc_types` SET `npc_faction_id` = 1520000103
WHERE `npc_faction_id` = 526 AND `id` BETWEEN 446000 AND 446199;

-- ---------------------------------------------------------------------------
-- 3. Kill credit entries
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO `npc_faction_entries`
	(`npc_faction_id`, `faction_id`, `value`, `npc_value`, `temp`) VALUES
	(1520000103, 1188,   5, 0, 0),
	(1520000103,  526,  -5, 1, 0);
