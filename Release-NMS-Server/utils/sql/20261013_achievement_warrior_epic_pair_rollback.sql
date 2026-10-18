-- ============================================================================
-- Rollback for 20261013_achievement_warrior_epic_pair
--
-- Removes exactly the 4 warrior-pair criteria added by the forward migration,
-- so the 1.0 component returns to 'Own Jagged Blade of War' only.
-- Twin manifest entry: 153 in
--   common/database/database_update_manifest_custom.cpp (keep in sync)
-- ============================================================================
SET NAMES utf8mb4;

DELETE FROM `achievement_criteria`
WHERE (`achievement_id`, `target_id`) IN (
  (9600047, 10909),   -- Blade of Tactics (classic)
  (9600047, 66176),   -- Blade of Tactics (EQS new-model)
  (9600047, 10910),   -- Blade of Strategy (classic)
  (9600047, 66177)    -- Blade of Strategy (EQS new-model)
);
