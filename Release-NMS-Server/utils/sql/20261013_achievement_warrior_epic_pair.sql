-- ============================================================================
-- Achievement criteria: Warrior epic 1.0 pair alias for Jagged Blade of War
--
-- Why
--   titles.cpp recognizes the warrior epic 1.0 in three forms - Jagged Blade of
--   War plus the Blade of Tactics / Blade of Strategy pair that combines into
--   it:
--     if (title_set_class[title_set] == Class::Warrior) { ...insert
--       "Blade of Tactics"/"Blade of Strategy"... }
--   The achievement path has no equivalent, so a Warrior holding only the pair
--   never satisfies 'Own Jagged Blade of War' (9600047 / component 9650047).
--
-- What
--   Adds both halves to that one component, in both id families:
--     Blade of Tactics   10909 (classic) / 66176 (EQS new-model)
--     Blade of Strategy  10910 (classic) / 66177 (EQS new-model)
--   The runtime tier mapping (id % 1000000) covers the Enchanted/Legendary
--   copies of each, so only the four base ids are inserted.
--
--   Mirrors titles.cpp exactly, including that either half counts on its own -
--   so Blade of Tactics now also completes Epic 1.0 in addition to its own
--   Epic 1.5 component. Class gating stays on target_id2 (copied from the
--   existing criterion), and behavior/progress_mode/required_count are copied
--   so the AchievementManager's per-component policy check still passes.
--
-- Rollback: 20261013_achievement_warrior_epic_pair_rollback.sql
-- Twin manifest entry: 153 in
--   common/database/database_update_manifest_custom.cpp (keep in sync)
-- Idempotent: guarded by the count check and ON DUPLICATE KEY UPDATE.
-- ============================================================================
SET NAMES utf8mb4;

INSERT INTO `achievement_criteria` (
  `achievement_id`, `component_type`, `component_sequence`, `component_id`,
  `event_type`, `progress_mode`, `behavior`, `target_id`, `target_id2`,
  `target_value`, `required_count`, `enabled`
)
SELECT
  c.`achievement_id`, c.`component_type`, c.`component_sequence`, c.`component_id`,
  c.`event_type`, c.`progress_mode`, c.`behavior`, t.`id`, c.`target_id2`,
  c.`target_value`, c.`required_count`, c.`enabled`
FROM `achievement_criteria` c
JOIN `items` t ON t.`id` IN (10909, 66176, 10910, 66177)
WHERE c.`achievement_id` = 9600047 AND c.`component_id` = 9650047
ON DUPLICATE KEY UPDATE
  `component_sequence` = VALUES(`component_sequence`),
  `progress_mode` = VALUES(`progress_mode`),
  `behavior` = VALUES(`behavior`),
  `target_value` = VALUES(`target_value`),
  `required_count` = VALUES(`required_count`),
  `enabled` = VALUES(`enabled`);
