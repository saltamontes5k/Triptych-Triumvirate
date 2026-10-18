-- ============================================================================
-- Rollback for 20261013_achievement_duplicate_item_alternatives
--
-- Removes exactly the 13 duplicate-name OR-alternative criteria added by the
-- forward migration. Written as an explicit (achievement_id, target_id) list so
-- it can never touch a criterion the forward migration did not create.
-- Twin manifest entry: 156 in
--   common/database/database_update_manifest_custom.cpp (keep in sync)
-- ============================================================================
SET NAMES utf8mb4;

DELETE FROM `achievement_criteria`
WHERE (`achievement_id`, `target_id`) IN (
  (9600047, 66175),   -- Warrior: Epic 1.0        -> Jagged Blade of War
  (9600048, 66176),   -- Warrior: Epic 1.5        -> Blade of Tactics
  (9600054, 800001),  -- Paladin: Epic 1.0        -> Fiery Defender
  (9600061, 800000),  -- Shadow Knight: Epic 1.0  -> Innoruuk's Curse
  (9600063, 22944),   -- Shadow Knight: Epic 2.0  -> Innoruuk's Voice
  (9600067, 36224),   -- Monk: Epic 1.0           -> Celestial Fists
  (9600067, 1683),    -- Monk: Epic 1.0           -> Celestial Fists (all-class)
  (9600076, 36223),   -- Shaman: Epic 1.0         -> Spear of Fate
  (9600091, 8495),    -- Beastlord: Epic 1.0      -> Claw of the Savage Spirit
  (9600152, 69312),   -- Cipher of Veeshan
  (9600157, 19719),   -- Ring of the Shissar
  (9600168, 67709),   -- Polished Stone Key
  (9600170, 88043)    -- Formal Dinner Invitation
);
