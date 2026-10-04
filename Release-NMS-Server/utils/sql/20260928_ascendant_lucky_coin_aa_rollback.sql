-- Rollback for 20260928_ascendant_lucky_coin_aa.sql
UPDATE aa_ranks SET spell = 27086, spell_type = 27086 WHERE id = 41000;
UPDATE db_str SET value = 'Manifest your Alternative Advancement Experienece Points into a Lucky Token to try your luck witht Harly Wynn.  Each click transmutes 3 AA points into a Lucky Token.' WHERE id = 41000 AND type = 4;
DELETE FROM spells_new WHERE id = 121860;
