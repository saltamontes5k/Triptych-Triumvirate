-- ============================================================================
-- Veeshan's Peak -- restore classic-era combat stats to the zone named and
-- remove the duplicate version-0 "Veeshan1.0" named spawns.
-- ----------------------------------------------------------------------------
-- Problem (audit 2026-09-13): the version-0 (classic) zone carried two
-- overlapping named populations, both using Veeshan 2.0 (Gates-of-Discord
-- revamp) hit point values:
--
--   * classic named  108040-108053  (groups veeshan_5/7/8/9/10/13,
--                     spawn2 20037-20042, ~3.3 day respawn, scripted)
--   * Veeshan1.0 named 108509-108517 (groups Veeshan1.0_08/10/11/12/13/18,
--                     spawn2 58774/58800-58803/58847, 1 day respawn)
--
-- Both sets spawn the same six dragons at the same coordinates. The classic
-- 1080xx set is the scripted, intended v0 encounter; the 1085xx set is the
-- Veeshan1.0 revamp that leaked into v0 (it is not mirrored into the
-- version-100 VP2 instance, which uses its own clones 1500000501-1500000506
-- created by vp2_veeshan_peak.sql).
--
-- Fix:
--   1) Restore classic-era combat stats (level/hp/mindmg/maxdmg/AC) taken from
--      the Alkabor (TakP / EQMac) classic dump, which stores the original
--      values under the same 1085xx id namespace.
--   2) Delete the six duplicate version-0 Veeshan1.0 named spawn2 rows. The
--      spawngroup/spawnentry definitions and the version-100 mirrors are kept.
--
-- Reference (Alkabor classic VP, all six brood): level 65, hp 32000,
--   mindmg 186, maxdmg 765, AC 400, race 49, bodytype 29, 7-day respawn.
--   Live brood hp before this patch: 136,200-225,000 (classic set) and
--   144,500-191,500 (Veeshan1.0 set).
--
-- Idempotent: UPDATEs write absolute values; the DELETE is constrained by
-- id/spawngroupID/zone/version. Re-apply verbatim after any reimport.
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- 1) The six-brood dragons -- restore the classic Alkabor stat block.
--    Applies to both the classic (1080xx) and Veeshan1.0 (1085xx) id sets.
--    Class/race/bodytype/spells/loot are left untouched.
-- ---------------------------------------------------------------------------
UPDATE npc_types
   SET level = 65, hp = 32000, mindmg = 186, maxdmg = 765, AC = 400
 WHERE id IN (108040, 108043, 108047, 108048, 108050, 108053,
              108509, 108510, 108511, 108512, 108513, 108517);

-- ---------------------------------------------------------------------------
-- 2) Non-brood named in the classic 108040-108053 block (Elder Ekron, Kluzen,
--    Magma Basilisk, Milyex Vioren, Qunard, Travenro, Vrabbit Xloren). These
--    are GoD-era / dormant definitions with no classic Alkabor counterpart,
--    so their HP is scaled into the classic band; damage was already close to
--    the classic 186-765 range and is normalised to match.
-- ---------------------------------------------------------------------------
UPDATE npc_types
   SET hp = 32000, mindmg = 186, maxdmg = 765, AC = 400
 WHERE id IN (108041, 108044, 108045, 108046, 108049, 108051, 108052);

-- Vrabbit Xloren (quest giver) was level 70 -> classic level 65.
UPDATE npc_types SET level = 65 WHERE id = 108052;

-- Guardian of Veeshan is the zone guardian; keep it above the brood (2x hp)
-- while still classic-era, and drop the revamp level 70 -> 65.
UPDATE npc_types
   SET level = 65, hp = 64000, mindmg = 200, maxdmg = 850, AC = 400
 WHERE id = 108042;

-- ---------------------------------------------------------------------------
-- 3) Remove the duplicate version-0 Veeshan1.0 named spawns. The classic
--    1080xx named (spawn2 20037-20042) remain the single v0 named population.
-- ---------------------------------------------------------------------------
DELETE FROM spawn2
 WHERE zone = 'veeshan'
   AND version = 0
   AND id IN (58774, 58800, 58801, 58802, 58803, 58847)
   AND spawngroupID IN (48290, 48292, 48293, 48294, 48295, 48300);

COMMIT;
