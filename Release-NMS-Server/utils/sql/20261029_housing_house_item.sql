-- ============================================================================
-- 2026-10-29 Player housing: the item that built the building on a lot
--
-- Placement consumes the house item, but the 0x626e placement preview that draws
-- the building needs the item's idfile as the world model. The lot therefore has
-- to remember which item was used, so the preview can be re-sent on every later
-- zone-in.
--
-- Companion compiled migration: manifest_entries_custom version 264.
-- Idempotent.
-- ============================================================================

SET @have_column := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'nms_plot'
    AND COLUMN_NAME = 'house_item_id'
);

SET @ddl := IF(
  @have_column = 0,
  'ALTER TABLE `nms_plot` ADD COLUMN `house_item_id` int(10) unsigned NOT NULL DEFAULT 0 AFTER `house_zone`',
  'DO 0'
);

PREPARE housing_264 FROM @ddl;
EXECUTE housing_264;
DEALLOCATE PREPARE housing_264;
