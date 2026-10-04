-- ============================================================================
-- Triune blessing counter
-- Date: 2026-10-08
--
-- Lifetime server-wide tally of philanthropy at Ben Affactor (Guild Lobby):
--   * every 2,000pp donated          -> +2h to the four Triune world buffs
--   * every 4 pieces of level-0 gear -> +2h to the four Triune world buffs
-- The four buffs are 17779 (Luck), 36856 (Power), 43002 (Experience),
-- 43005 (Selo). Remainders carry; only newly-crossed thresholds award.
-- A world announcement is posted at most once per 24h (last_announced_at).
--
-- Idempotent. Twin of ManifestEntry .version = 102 in
-- common/database/database_update_manifest_custom.cpp
-- ============================================================================

CREATE TABLE IF NOT EXISTS `triune_blessing_counter` (
  `id`                TINYINT  NOT NULL PRIMARY KEY DEFAULT 1,
  `pp_total`          BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `item_total`        BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `ticks_awarded`     BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `last_announced_at` INT UNSIGNED NOT NULL DEFAULT 0, -- unix epoch, 24h throttle
  `updated_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT IGNORE INTO `triune_blessing_counter` (`id`) VALUES (1);
