-- Gates of Discord - Muramite Armor Infusion Solvent Merchant (Nalasrine Twinklecoil)
-- =============================================================================
-- Problem: The class "Abysmal" armor quests (EQQuests exp 07) require buying
-- "Nalasrine's <material> Solvent/Strengthener/Solution" from Nalasrine
-- Twinklecoil (Abysmal Sea, ~10,500pp) and combining it with the raw Muramite
-- material (Muramite Metal Sheet 54093 / Chain Link 54094 / Leather Padding
-- 54095 / Silk Thread 54096) in a forge/loom (no-fail) to make the
-- Infused Muramite material (54101-54104) that the final class armor combines
-- need.  Without these the whole armor quest line dead-ends.
--
-- State found in release DB:
--   * Infused items ARE crafted by tradeskill recipes:
--       R4994 54093 + 54097 -> 54101 (Infused Muramite Metal)
--       R4993 54094 + 54098 -> 54102 (Infused Muramite Chain)
--       R2790 54095 + 54099 -> 54103 (Infused Muramite Leather)
--       R2791 54096 + 54100 -> 54104 (Infused Muramite Thread)
--   * Final armor recipes consume Infused + Reworked (e.g. R5039 54102+54140 -> 67726).
--   * But the catalyst items 54097-54100 are NOT sold by any merchantlist,
--     and merchantlist 9763 (Nalasrine Twinklecoil, npc id 16272, merchant
--     npc name "9763_Nalasrine_Twinklecoil_Trade") has ZERO rows.
--
-- Fix: stock her merchant list with the four solvents (~10,500pp each) and
-- make sure her npc_types.merchant_id points at list 9763.
-- =============================================================================

-- 1) Nalasrine Twinklecoil (Abysmal Sea, npc id 16272) must use merchant list 9763.
UPDATE npc_types SET merchant_id = 9763 WHERE id = 16272 AND merchant_id = 0;

-- 2) Stock the four infusion solvents on merchant list 9763 (slots 0-3).
INSERT INTO merchantlist (merchantid, slot, item, faction_required, level_required, min_status, max_status, alt_currency_cost, classes_required, probability, bucket_name, bucket_value, bucket_comparison, min_expansion, max_expansion)
VALUES
  (9763, 0, 54097, -100, 0, 0, 255, 0, 65535, 100, '', '', 0, -1, -1), -- Nalasrine's Superior Plate Solvent
  (9763, 1, 54098, -100, 0, 0, 255, 0, 65535, 100, '', '', 0, -1, -1), -- Nalasrine's Thick Chain Solvent
  (9763, 2, 54099, -100, 0, 0, 255, 0, 65535, 100, '', '', 0, -1, -1), -- Nalasrine's Enforcing Tanning Solution
  (9763, 3, 54100, -100, 0, 0, 255, 0, 65535, 100, '', '', 0, -1, -1)  -- Nalasrine's Perfected Silk Strengthener
ON DUPLICATE KEY UPDATE item = VALUES(item);

-- 3) Price each solvent at ~10,500pp (10,500g = 1,050,000 copper).
UPDATE items SET price = 1050000 WHERE id IN (54097, 54098, 54099, 54100);
