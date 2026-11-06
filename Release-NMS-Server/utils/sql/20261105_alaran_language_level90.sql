-- 20261105 v347 -- gate the Alaran (VoA-era) AA lines at level 90.
--
-- The Alaran AA set in our peq lineage is four pre-seeded stubs:
--   1684 Knowledge of Alaran Culture            (first rank 14017)
--   1685 Knowledge of Alaran Culture - Advanced (first rank 14018)
--   708  Enchant Alaran Metal                   (first rank 13271, Enchanter-only, grant-only)
--   709  Mass Enchant Alaran Metal              (first rank 13272, Enchanter-only, grant-only)
-- All four: single rank, cost 0, level_req 65, expansion 16 tag, zero effect
-- rows beyond a placeholder SE_TotalHP +10 on the two Knowledge ranks (they
-- teach no language in this data -- Alaran comprehension lives in the language
-- primer books / achievements 1900045-1900049, see v346).
-- As level-65 cost-0 lines they were buyable by anyone with AA points. Until
-- VoA is unlocked we hide them behind a level-90 floor: the buy path enforces
-- aa_ranks.level_req (zone/aa.cpp) and IsBetterAALine ignores level_req, so
-- the dedupe winner map cannot flip on this change. auto_grant_enabled=0 and
-- zero character_owners on all four (verified 2026-11-05).
--
-- Guard: all four rank rows must exist with cost 0. The UPDATE is a floor
-- (only raises values below 90), so benign drift cannot brick the chain.
-- Manifest: database_update_manifest_custom.cpp v347 (keep in sync).

START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS _alaran_gate_guard;
CREATE TEMPORARY TABLE _alaran_gate_guard(
 label VARCHAR(80) PRIMARY KEY,
 ok TINYINT NOT NULL,
 CHECK(ok=1)
) ENGINE=InnoDB;

INSERT INTO _alaran_gate_guard VALUES
('four_rank_rows_exist',((SELECT COUNT(*) FROM aa_ranks WHERE id IN (13271,13272,14017,14018) AND cost=0)=4));

UPDATE aa_ranks SET level_req = 90 WHERE id IN (13271,13272,14017,14018) AND level_req < 90;

DROP TEMPORARY TABLE IF EXISTS _alaran_gate_guard;

COMMIT;
