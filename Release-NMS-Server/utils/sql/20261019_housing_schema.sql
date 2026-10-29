-- ============================================================================
-- 2026-10-19 Player housing: neighborhood + plot tables
--
-- The RoF2 client's native real-estate windows need server state that does not
-- exist in this tree. These two tables are the minimum: one row per neighborhood
-- (which guild, if any, owns it) and one row per lot marker.
--
-- Plots are seeded from the lot markers already present in the neighborhood zone:
-- doors rows named OBP_LOTSQUARE (opentype 160), one per doorid. The door row
-- carries the lot's world position, which is what the client sends on click.
--
-- plot_type: 0 = player plot, 1 = guild plot (matches the client's owner type
-- field where 4 = Player and 8 = Guild, scaled to our own storage).
--
-- Companion compiled migration: manifest_entries_custom version 161.
-- The `house_item_id` column is added by 20261029_housing_house_item.sql (version 264).
-- Idempotent.
-- ============================================================================

CREATE TABLE IF NOT EXISTS `nms_neighborhood` (
  `id`               int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name`             varchar(64)      NOT NULL,
  `guild_id`         int(10) unsigned NOT NULL DEFAULT 0,
  `max_player_plots` int(10) unsigned NOT NULL DEFAULT 0,
  `max_guild_plots`  int(10) unsigned NOT NULL DEFAULT 0,
  `zone`             varchar(32)      NOT NULL DEFAULT 'neighborhood',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nms_plot` (
  `id`                int(10) unsigned NOT NULL AUTO_INCREMENT,
  `neighborhood_id`   int(10) unsigned NOT NULL,
  `door_id`           int(10) unsigned NOT NULL,
  `plot_type`         tinyint(3) unsigned NOT NULL DEFAULT 0,
  `owner_char_id`     int(10) unsigned NOT NULL DEFAULT 0,
  `owner_guild_id`    int(10) unsigned NOT NULL DEFAULT 0,
  `house_id`          int(10) unsigned NOT NULL DEFAULT 0,
  `house_zone`        varchar(32)      NOT NULL DEFAULT '',
  `purchased_at`      datetime         DEFAULT NULL,
  `upkeep_paid_until` datetime         DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `door_id` (`door_id`),
  KEY `neighborhood_id` (`neighborhood_id`),
  KEY `owner_char_id` (`owner_char_id`),
  KEY `owner_guild_id` (`owner_guild_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `nms_neighborhood` (`name`, `guild_id`, `max_player_plots`, `max_guild_plots`, `zone`)
VALUES ('Sunrise Hills', 0, 0, 0, 'neighborhood');

-- Seed one plot per lot marker (version 0 rows only; version 100 duplicates the same lots).
INSERT IGNORE INTO `nms_plot` (`neighborhood_id`, `door_id`, `plot_type`)
SELECT nb.`id`, d.`doorid`, 0
FROM `doors` d
JOIN `nms_neighborhood` nb ON nb.`name` = 'Sunrise Hills'
WHERE d.`zone` = 'neighborhood'
  AND d.`name` = 'OBP_LOTSQUARE'
  AND d.`version` = 0;

-- Plot capacity is derived from the seeded lot count.
UPDATE `nms_neighborhood` nb
SET nb.`max_player_plots` = (
      SELECT COUNT(*) FROM `nms_plot` p
      WHERE p.`neighborhood_id` = nb.`id` AND p.`plot_type` = 0
    ),
    nb.`max_guild_plots` = (
      SELECT COUNT(*) FROM `nms_plot` p
      WHERE p.`neighborhood_id` = nb.`id` AND p.`plot_type` = 1
    )
WHERE nb.`name` = 'Sunrise Hills';
