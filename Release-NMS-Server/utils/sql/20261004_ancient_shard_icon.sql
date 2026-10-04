-- ============================================================================
-- 2026-10-04 Ancient Shard of Ascendant Power icon
--
-- Give the Ancient Shard of Ascendant Power (item 121856) the Faceted Sunshard
-- icon (item 37416, icon id 2245) instead of its old icon (855).
-- Idempotent.
-- ============================================================================

UPDATE items
SET icon = 2245
WHERE id = 121856;
