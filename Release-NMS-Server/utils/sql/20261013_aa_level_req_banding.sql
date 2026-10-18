-- ============================================================================
-- AA level-requirement banding -- progression-server relabel of aa_ranks
--
-- Why
--   This server progresses faster than retail, so AAs authored behind the
--   70-85 level wall arrive long after the content they belong with. Every
--   rank gated at 70+ is pulled down to the matching earlier band so the AA
--   curve tracks the level curve.
--
-- Bands (old level_req -> new):
--   70-75 -> 60   (903 ranks)
--   76-80 -> 65   (2854 ranks; the bulk is the SoD-era cluster sitting at 80)
--   81-85 -> 70   (12 ranks)
--   86+   -> 75   (0 ranks today; catch-all kept for safety)
--
--   Nothing below 70 is touched, including the level_req = 0 grant-only
--   rows and the 51 default. aa_ability has no level_req column -- the
--   character-level gate for training a rank lives on aa_ranks.level_req
--   only.
--
-- Mechanics
--   The exact pre-change value of every affected rank is snapshotted into
--   aa_ranks_lvlreq_bak_20261013, so the rollback restores originals rather
--   than inverting the bands. The UPDATEs MUST run in ascending band order:
--   the 81-85 band writes 70s, and the 70-75 band matches 70 -- apply the
--   70-75 band first and the freshly-written 70s get swept down to 60 with
--   it (that exact mis-order shipped to the live DB once and was restored
--   from the snapshot). Ascending, each write's destination (60/65/70/75)
--   lies below every remaining band's input range, so no write can ever be
--   re-caught.
--
-- Rollback: 20261013_aa_level_req_banding_rollback.sql
-- Twin manifest entry: 149 in
--   common/database/database_update_manifest_custom.cpp (keep in sync)
-- Idempotent (bands empty on re-run). Pure SQL -- no client file or export
-- changes. Zones load aa_ranks at boot, so running zones need a restart;
-- clients see the new requirement the next time they zone in.
-- ============================================================================
SET NAMES utf8mb4;

-- 1. Snapshot every rank we might touch (level_req >= 70) so the rollback is
--    exact, not band-inverse.
DROP TABLE IF EXISTS aa_ranks_lvlreq_bak_20261013;
CREATE TABLE aa_ranks_lvlreq_bak_20261013 AS
SELECT id, level_req FROM aa_ranks WHERE level_req >= 70;

-- 2. Bands, ascending -- see the order note above; do not reorder.
UPDATE aa_ranks SET level_req = 60 WHERE level_req BETWEEN 70 AND 75;
UPDATE aa_ranks SET level_req = 65 WHERE level_req BETWEEN 76 AND 80;
UPDATE aa_ranks SET level_req = 70 WHERE level_req BETWEEN 81 AND 85;
UPDATE aa_ranks SET level_req = 75 WHERE level_req >= 86;
