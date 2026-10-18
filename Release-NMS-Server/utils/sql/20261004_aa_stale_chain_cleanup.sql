-- Remove stale duplicate AA rank chains (2026-10-04)
-- All verified unreachable (no owning aa_ability, no external links, no
-- character ownership) and redundant with live same-name lines:
--   Shield Block x2 (6428/12813 heads) vs live 435/762/3802
--   Infused by Rage (6284 head) vs live 3731 + 23731
--   Alternately Advanced Firework old heads (17787-88, 18990-93) vs live 17788 @ 18994
--   Glyph of the Master / Arcane Secrets stubs 7020-7032 vs live 7016 / 587
--   Invitation of Blood fragment 1382 (no live line; recover if ever wanted)
-- Full-row backups: aa_ranks_stale_backup_20261004, aa_rank_effects_stale_backup_20261004,
-- aa_rank_prereqs_stale_backup_20261004.

DELETE FROM aa_rank_prereqs WHERE rank_id IN (1382,6284,6285,6428,6429,6430,7020,7021,7022,7023,7024,7025,7026,7027,7028,7030,7031,7032,7112,7113,7114,10007,10008,10009,10568,12472,12473,12474,12813,12814,12815,13238,13239,13240,14279,15719,17787,18990,18991,18992,18993);
DELETE FROM aa_rank_effects WHERE rank_id IN (1382,6284,6285,6428,6429,6430,7020,7021,7022,7023,7024,7025,7026,7027,7028,7030,7031,7032,7112,7113,7114,10007,10008,10009,10568,12472,12473,12474,12813,12814,12815,13238,13239,13240,14279,15719,17787,18990,18991,18992,18993);
DELETE FROM aa_ranks WHERE id IN (1382,6284,6285,6428,6429,6430,7020,7021,7022,7023,7024,7025,7026,7027,7028,7030,7031,7032,7112,7113,7114,10007,10008,10009,10568,12472,12473,12474,12813,12814,12815,13238,13239,13240,14279,15719,17787,18990,18991,18992,18993);

-- Rollback:
-- INSERT INTO aa_ranks SELECT * FROM aa_ranks_stale_backup_20261004;
-- INSERT INTO aa_rank_effects SELECT * FROM aa_rank_effects_stale_backup_20261004;
-- INSERT INTO aa_rank_prereqs SELECT * FROM aa_rank_prereqs_stale_backup_20261004;
