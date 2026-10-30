-- ============================================================================
-- 2026-10-29 Player housing: committed building pose on a plot
--
-- 0x711a (placement commit) carries the pose the player dragged the building
-- to. NULL means "use the lot marker's own position".
--
-- Companion compiled migration: manifest_entries_custom version 274.
-- Idempotent.
-- ============================================================================

SET @have_column := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'nms_plot'
    AND COLUMN_NAME = 'house_x'
);

SET @ddl := IF(
  @have_column = 0,
  'ALTER TABLE `nms_plot` ADD COLUMN `house_x` float DEFAULT NULL, ADD COLUMN `house_y` float DEFAULT NULL, ADD COLUMN `house_z` float DEFAULT NULL, ADD COLUMN `house_heading` float DEFAULT NULL',
  'DO 0'
);

PREPARE housing_274 FROM @ddl;
EXECUTE housing_274;
DEALLOCATE PREPARE housing_274;
