-- ============================================================================
-- Rollback for 20261005_ascendant_origin_aa.sql
--
-- Restores the Lucky Coin "Manifest Experience" AA and puts Lesson of the
-- Devoted back behind grant_only.
--
-- SQL revert: 20261005_ascendant_origin_aa.sql added the spell 121861 and
-- repointed the AA at it. Spell 121860 and the Lucky Coin item 121857 were left
-- in place, so dropping 121861 and restoring the spell pointer is enough to
-- bring the Lucky Coin AA back. The one thing SQL cannot undo is the retirement
-- of quests/global/spells/121860.pl -- see below for that step.
--
-- The client string files are not SQL: after running this, either re-run
-- `export-client-files.bat <EQ-client-folder>` or restore the dbstr_us.txt
-- copies from git.
--
-- quests/global/spells/121860.pl was retired to an inert no-op by the same
-- change, because nothing casts spell 121860 once rank 41000 points at 121861.
-- SQL cannot restore a file, so to fully restore the Lucky Coin AA also run:
--     git checkout HEAD -- Release-NMS-Quests/global/spells/121860.pl
--     git checkout HEAD -- export/Release-NMS-Quests/global/spells/121860.pl
-- (the copy under Release-NMS-Server/Build/bin/Release/quests/ is a build
--  output and is refreshed by the next build)
--
-- Idempotent.
-- ============================================================================
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- 1. Drop the Origin spell
-- ---------------------------------------------------------------------------
DELETE FROM spells_new WHERE id = 121861;

-- ---------------------------------------------------------------------------
-- 2. aa_ability 31082 back to Manifest Experience
-- ---------------------------------------------------------------------------
UPDATE aa_ability
SET name     = 'Manifest Experience',
    category = 9,
    type     = 4
WHERE id = 31082;

-- ---------------------------------------------------------------------------
-- 3. aa_ranks 41000 back to the Lucky Coin spell wiring
-- ---------------------------------------------------------------------------
UPDATE aa_ranks
SET spell       = 121860,
    spell_type  = 121860,
    cost        = 0,
    level_req   = 45,
    recast_time = 1,
    expansion   = 0,
    prev_id     = -1,
    next_id     = -1,
    title_sid   = 41000,
    desc_sid    = 41000
WHERE id = 41000;

-- ---------------------------------------------------------------------------
-- 4. Lesson of the Devoted back to grant_only
--    (aa_ranks 1371.cost was already 0 before the forward migration.)
-- ---------------------------------------------------------------------------
UPDATE aa_ability
SET grant_only = 1
WHERE id = 481;

UPDATE aa_ranks
SET cost = 0
WHERE id = 1371;

-- ---------------------------------------------------------------------------
-- 5. db_str strings back to the Lucky Coin text
-- ---------------------------------------------------------------------------
DELETE FROM db_str WHERE id = 41000 AND type IN (1, 2, 3, 4);
INSERT INTO db_str (id, type, value) VALUES
    (41000, 1, 'Manifest Experience: Lucky Token'),
    (41000, 2, 'Manifest'),
    (41000, 3, 'Experience'),
    (41000, 4, 'Manifest your Alternative Advancement Experience Points into a Lucky Coin to try your luck with Harley Wynn.  Each click transmutes 3 AA points into a Lucky Coin.');
