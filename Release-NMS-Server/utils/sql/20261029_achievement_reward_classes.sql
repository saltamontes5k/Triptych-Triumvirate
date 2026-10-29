-- ============================================================================
-- 2026-10-29 Achievement reward options: per-class eligibility
--
-- reward_options gains class_mask, a bitmask of classes that may see and claim
-- an option (bit 0 = Warrior .. bit 15 = Berserker). The default 65535 keeps
-- every existing option unrestricted. On this multiclass server the check uses
-- the character's permanent class bits, so an option is eligible when any one of
-- the character's classes is in the mask.
--
-- Companion compiled migration: manifest_entries_custom version 267.
-- Idempotent.
-- ============================================================================

SET @have_column := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'reward_options'
    AND COLUMN_NAME = 'class_mask'
);

SET @sql := IF(@have_column = 0,
  'ALTER TABLE reward_options ADD COLUMN class_mask INT UNSIGNED NOT NULL DEFAULT 65535 AFTER enabled',
  'SELECT "reward_options.class_mask already present" AS note');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
