-- ============================================================================
-- 2026-10-30 Interior furniture (v1)
--
-- One row per placed furniture item in a house interior. The 0x1045 world actor's
-- record num is the row id, and the actor GUID packs the row id into the bytes the
-- building GUID leaves zero, so every placed item is addressable for pickup.
--
-- `nms_housing_placeable` is the GM-curated allowlist that gates placement: an item
-- is placeable only when a GM added it here (#housing placeable <item_id>). No item
-- metadata or itemtype heuristic decides it, so no item becomes placeable by accident.
--
-- Wire layouts follow the public RoF2 housing reconstruction's protocol/STRUCTS.md
-- (placement begin 60 B / commit 96 B, world item = bare ActorRecord); no overlay
-- code is ported. See docs/rof2-housing-upstream-adoption.md.
--
-- Companion compiled migration: manifest_entries_custom version 289. Idempotent.
-- ============================================================================

CREATE TABLE IF NOT EXISTS `nms_house_item` (
  `id`             int(10) unsigned NOT NULL AUTO_INCREMENT,
  `door_id`        int(10) unsigned NOT NULL,
  `item_id`        int(10) unsigned NOT NULL,
  `charges`        int(11) NOT NULL DEFAULT 1,
  `pos_x`          float NOT NULL DEFAULT 0,
  `pos_y`          float NOT NULL DEFAULT 0,
  `pos_z`          float NOT NULL DEFAULT 0,
  `heading`        float NOT NULL DEFAULT 0,
  `pitch`          float NOT NULL DEFAULT 0,
  `roll`           float NOT NULL DEFAULT 0,
  `scale`          float NOT NULL DEFAULT 1,
  `placement_type` int(10) unsigned NOT NULL DEFAULT 0,
  `placed_by`      int(10) unsigned NOT NULL DEFAULT 0,
  `placed_at`      datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `door_id` (`door_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nms_housing_placeable` (
  `item_id`  int(10) unsigned NOT NULL,
  `added_by` int(10) unsigned NOT NULL DEFAULT 0,
  `added_at` datetime DEFAULT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
