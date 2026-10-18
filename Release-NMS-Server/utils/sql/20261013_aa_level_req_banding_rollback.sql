-- ============================================================================
-- Rollback for 20261013_aa_level_req_banding.sql
--
-- Restores every aa_ranks row the banding migration touched to its exact
-- original level_req from the aa_ranks_lvlreq_bak_20261013 snapshot, then
-- drops the snapshot.
--
-- If the snapshot table is missing (already dropped by hand) there is nothing
-- to restore from; the forward migration's header lists the bands if a
-- band-inverse rollback is acceptable.
--
-- Idempotent.
-- ============================================================================
SET NAMES utf8mb4;

UPDATE aa_ranks r
JOIN aa_ranks_lvlreq_bak_20261013 b ON r.id = b.id
SET r.level_req = b.level_req;

DROP TABLE IF EXISTS aa_ranks_lvlreq_bak_20261013;
