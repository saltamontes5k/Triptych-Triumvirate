-- Remove the orphaned "Fury of Magic" duplicate rank chain (2026-10-04)
--
-- A 16-rank chain headed at aa_ranks 1107 (enum name aaFuryofMagic2, zone/aa.h:462)
-- existed with NO owning aa_ability row — unreachable, never trainable. Its title
-- string (db_str 1107) reads "Fury of Magic" and its aa_rank_effects carry the same
-- SPA 294 (spell crit damage) as the live Fury of Magic line (ability 215), as an
-- alternate iteration: identical first 9 ranks, slightly different mid-curve
-- (17/19/21 vs 16/17/18), ending at 29% at rank 16 vs the live line's 35% at 19.
-- Fully redundant with the live line -> deleted.
--
-- Note: the other formerly-suspect "orphan" chain at 6057 was verified NOT orphaned —
-- it is the live tail of Punch Mastery (ability 3511, first_rank 6020).
--
-- Applied live 2026-10-04: 16 ranks + 16 effects + 16 prereqs removed.
-- Full-row backups: aa_ranks_orphan_fom2_backup_20261004,
-- aa_rank_effects_orphan_fom2_backup_20261004, aa_rank_prereqs_orphan_fom2_backup_20261004.

DELETE FROM aa_rank_prereqs WHERE rank_id IN
  (1107,1108,1109,5286,5287,5288,6403,6404,6405,12432,12433,12434,12556,12557,12558,16489);
DELETE FROM aa_rank_effects WHERE rank_id IN
  (1107,1108,1109,5286,5287,5288,6403,6404,6405,12432,12433,12434,12556,12557,12558,16489);
DELETE FROM aa_ranks WHERE id IN
  (1107,1108,1109,5286,5287,5288,6403,6404,6405,12432,12433,12434,12556,12557,12558,16489);

-- Rollback (reinserts the exact prior rows):
-- INSERT INTO aa_ranks SELECT * FROM aa_ranks_orphan_fom2_backup_20261004;
-- INSERT INTO aa_rank_effects SELECT * FROM aa_rank_effects_orphan_fom2_backup_20261004;
-- INSERT INTO aa_rank_prereqs SELECT * FROM aa_rank_prereqs_orphan_fom2_backup_20261004;
