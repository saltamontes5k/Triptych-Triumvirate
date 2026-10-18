-- AA rank expansion cap to Underfoot (2026-10-04)
--
-- Why: CanUseAlternateAdvancementRank (zone/aa.cpp:2207-2210) hides any rank whose
-- expansion bit isn't in the player's expansion mask (pp.expansions = World:ExpansionSettings
-- = 524287 = expansions 1-19). The EQS custom block is tagged expansion 99999999, and the
-- code's `1 << (expansion - 1)` overflows to bit 30 on x86, which 524287 does not include —
-- so all custom ranks were invisible (Fury of Magic showed 9 of 19 ranks, etc.). Per design
-- decision, nothing may be tagged higher than Underfoot: every rank is now expansion <= 16,
-- which 524287 fully covers. Data-only; takes effect as zones reboot.
--
-- Applied live 2026-10-04: 3712 rows retagged
--   (532 @ exp 17, 242 @ 18, 52 @ 19, 22 @ 20, 37 @ 21, 2827 @ 99999999).

CREATE TABLE IF NOT EXISTS aa_ranks_expansion_backup_20261004 AS
SELECT id, expansion FROM aa_ranks WHERE expansion > 16;

UPDATE aa_ranks SET expansion = 16 WHERE expansion > 16;

-- Rollback (restores every retagged row from the backup):
-- UPDATE aa_ranks r
-- JOIN aa_ranks_expansion_backup_20261004 b ON b.id = r.id
-- SET r.expansion = b.expansion;
