-- ============================================================================
-- Achievement criteria: exact-name duplicate items are OR alternatives
--
-- Why
--   The achievement importer resolves item components by exact name and is
--   designed to emit one criterion per matching item id
--   (utils/scripts/import_achievement_resources.py, _emit_item_name_criteria:
--   "Every exact-name duplicate item ID is an OR alternative for the same
--   component"). This database instead carries exactly one criterion per
--   component (1613 criteria across 1613 components), so an item that exists
--   under two ids can never satisfy its criterion.
--
--   The visible symptom is the epic achievements. The criteria target the
--   classic epic ids (10099 Fiery Defender, 10908 Jagged Blade of War, ...)
--   while the duplicate-name EQS new-model items players actually hold - and
--   augment - are separate ids (800001, 66175, ...), so the OwnItem criterion
--   reads 0 forever. Augments are not involved: the augmented epics simply
--   happen to be the duplicate-id ones.
--
-- What
--   Copies every enabled OwnItem (event_type 7) criterion onto each other item
--   sharing its exact, case-insensitive name, preserving
--   behavior/progress_mode/required_count so the AchievementManager's
--   per-component policy check still passes. Class gating stays on target_id2.
--   The all-class Celestial Fists (1683) is included alongside the Monk 1.0
--   target (36224) to match the importer's name join; titles.cpp excludes
--   all-class duplicates, the achievement path deliberately does not.
--
-- Rollback: 20261013_achievement_duplicate_item_alternatives_rollback.sql
-- Twin manifest entry: 156 in
--   common/database/database_update_manifest_custom.cpp (keep in sync)
-- Idempotent: the anti-join skips alternatives that already exist.
-- ============================================================================
SET NAMES utf8mb4;

INSERT INTO `achievement_criteria` (
  `achievement_id`, `component_type`, `component_sequence`, `component_id`,
  `event_type`, `progress_mode`, `behavior`, `target_id`, `target_id2`,
  `target_value`, `required_count`, `enabled`
)
SELECT
  c.`achievement_id`, c.`component_type`, c.`component_sequence`, c.`component_id`,
  c.`event_type`, c.`progress_mode`, c.`behavior`, alt.`id`, c.`target_id2`,
  c.`target_value`, c.`required_count`, c.`enabled`
FROM `achievement_criteria` c
JOIN `items` t ON t.`id` = c.`target_id`
JOIN `items` alt ON LOWER(alt.`Name`) = LOWER(t.`Name`) AND alt.`id` <> t.`id`
LEFT JOIN `achievement_criteria` e
  ON e.`achievement_id` = c.`achievement_id`
 AND e.`component_type` = c.`component_type`
 AND e.`component_id` = c.`component_id`
 AND e.`event_type` = c.`event_type`
 AND e.`target_id` = alt.`id`
 AND e.`target_id2` = c.`target_id2`
WHERE c.`enabled` = 1 AND c.`event_type` = 7 AND e.`id` IS NULL
ON DUPLICATE KEY UPDATE
  `component_sequence` = VALUES(`component_sequence`),
  `progress_mode` = VALUES(`progress_mode`),
  `behavior` = VALUES(`behavior`),
  `target_value` = VALUES(`target_value`),
  `required_count` = VALUES(`required_count`),
  `enabled` = VALUES(`enabled`);
