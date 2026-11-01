-- ============================================================================
-- Convorteum raid requester fix - Convorteum_Herald_Dagna npc_types row
-- ----------------------------------------------------------------------------
-- The Underfoot finale (Convorteum) was unrequestable: NPC 480260 had a fully
-- wired requester script (Release-NMS-Quests/brellsrest/480260.lua, gates on
-- uf.prog.brell_audience from the Audience with Brell raid, Amulet of Brell
-- 88393 backflag) and a committed spawn (20260930_uf_convorteum.sql:
-- spawngroup 1520008521 'uf_war_camp_dagna' -> spawn2 1520018404, Brell's Rest
-- war camp 56,468,152.6) -- but NO npc_types row. The committed migration
-- cloned Dagna from npc 480060, which does not exist, so its
-- "INSERT INTO uf_conv_add SELECT * FROM npc_types WHERE id = 480060" loaded
-- zero rows and the npc silently never landed.
--
-- This migration creates the missing npc_types row, cloned from A_Knight_of_
-- Luclin (12000157, clean flag NPC - no loot/merchant attachments), with the
-- stats the 20260930 migration intended (level 85, see_invis 1, aggroradius
-- 0, no loot/faction/spells). Placement is left entirely to the existing
-- committed spawn - no new spawngroup/spawnentry/spawn2 here.
--
-- Idempotent: INSERT IGNORE. npc_types 480260 verified unused at time of
-- writing (the 20260930 clone silently produced nothing).
--
-- Twin of ManifestEntry .version = 298 in
-- common/database/database_update_manifest_custom.cpp (keep in sync).
-- Rollback:
--   DELETE FROM npc_types WHERE id = 480260;
-- ============================================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- Convorteum_Herald_Dagna (480260) - the row 20260930_uf_convorteum.sql meant to create
DROP TEMPORARY TABLE IF EXISTS tmp_npc;
CREATE TEMPORARY TABLE tmp_npc LIKE npc_types;
INSERT INTO tmp_npc SELECT * FROM npc_types WHERE id = 12000157;
UPDATE tmp_npc SET id = 480260, name = 'Convorteum_Herald_Dagna', lastname = 'Keeper of the Convorteum Door',
	race = 12, level = 85, hp = 40000, mindmg = 0, maxdmg = 100, AC = 500,
	loottable_id = 0, npc_faction_id = 0, npc_spells_id = 0, aggroradius = 0, see_invis = 1,
	special_abilities = '', raid_target = 0;
INSERT IGNORE INTO npc_types SELECT * FROM tmp_npc;
DROP TEMPORARY TABLE IF EXISTS tmp_npc;

COMMIT;
