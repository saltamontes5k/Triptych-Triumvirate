-- ============================================================================
-- Arcane Overkill (Wizard universal AA 20776) -> tome item 121848
-- Date: 2026-10-18
--
-- The Ascendant insight trainer refuses to sell any aa_custom_mapping row with
-- no tome_item_id ("not item-backed yet"). Arcane Overkill (original AA 776,
-- universal 20776, Greater credit tier, illegible 121605 = Exalted Wizard
-- Advancement) had no "Tome of Advancement" item in the imported catalog, so
-- the Wizard trainer listed it and then failed at the buy confirmation.
--
-- Adds the missing Exalted-tier tome by cloning the Call of Xuzl (Exalted)
-- tome (121769) and points the mapping at it. The companion change is
-- plugins/ascendant_tome_translator.pl: 121848 added to $tomes{2048}{2}.
--
-- Idempotent.
-- ============================================================================

CREATE TEMPORARY TABLE tmp_ao_tome SELECT * FROM items WHERE id = 121769;
UPDATE tmp_ao_tome
   SET id = 121848,
       Name = 'Tome of Advancement - Arcane Overkill (Exalted)',
       lore = 'A tome containing the secrets of Arcane Overkill'
 WHERE id = 121769;
INSERT IGNORE INTO items SELECT * FROM tmp_ao_tome;
DROP TEMPORARY TABLE tmp_ao_tome;

UPDATE aa_custom_mapping
   SET tome_item_id = 121848
 WHERE universal_aa_id = 20776;
