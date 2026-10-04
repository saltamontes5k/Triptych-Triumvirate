-- ============================================================================
-- Remove Ascendant Gambling (Harley Wynn) from the live database
--
-- Complements the repo removal of:
--   plugins/ascendant_gambling.pl
--   quests/guildlobby/Harley_Wynn.pl
--
-- It rolls back the gambling half of 20260928_ascendant_guildlobby_e.sql.
--
-- Intentionally KEPT:
--   * content_flags 'april_fools'      (used by ascendant_april_fools.pl + guildlobby zone_controller)
--   * aa_ranks 41000 / spell 121861    (Origin, via 20261005_ascendant_origin_aa.sql)
--   * spells_new 121860                (left in place by the Origin migration; nothing casts it)
--   * quests/global/spells/121860.pl   (inert no-op)
--
-- Rollback: re-run 20260928_ascendant_guildlobby_e.sql (idempotent) to recreate
-- the Harley Wynn spawn and the Lucky Coin item.
--
-- Idempotent.
-- ============================================================================
SET NAMES utf8mb4;

-- Harley Wynn spawn chain (see 20260928_ascendant_guildlobby_e.sql)
DELETE FROM spawn2     WHERE id = 2141248;
DELETE FROM spawnentry WHERE spawngroupID = 5004028;
DELETE FROM spawngroup WHERE id = 5004028;
DELETE FROM npc_types  WHERE id = 344049;

-- Lucky Coin item bought/sold by Harley Wynn
DELETE FROM items WHERE id = 121857;

-- NOTE: content_flags 'april_fools' is deliberately NOT deleted.
