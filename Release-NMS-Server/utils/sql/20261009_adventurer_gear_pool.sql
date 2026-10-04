-- ============================================================================
-- Adventurer gear pool
-- Date: 2026-10-09
--
-- Donated stat gear (validated by the philanthropist item handler) is stored
-- here instead of being parceled/destroyed immediately. The Provisioner in the
-- Bazaar hands out one suitable piece per account every 8 hours, matching the
-- item to an empty equipment slot the adventurer actually needs. Rows expire
-- after 30 days (pruned opportunistically when The Provisioner is used).
--
-- Idempotent. Twin of ManifestEntry .version = 103 in
-- common/database/database_update_manifest_custom.cpp
-- ============================================================================

CREATE TABLE IF NOT EXISTS `philanthropist_item_pool` (
  `id`               INT NOT NULL AUTO_INCREMENT,
  `item_id`          INT NOT NULL DEFAULT 0,
  `quantity`         INT NOT NULL DEFAULT 1,
  `reqlevel`         INT NOT NULL DEFAULT 0,
  `classes`          INT NOT NULL DEFAULT 65535,
  `races`            INT NOT NULL DEFAULT 65535,
  `slots`            INT NOT NULL DEFAULT 0,
  `stat_value`       INT NOT NULL DEFAULT 0,
  `donor_char_id`    INT NOT NULL DEFAULT 0,
  `donor_account_id` INT NOT NULL DEFAULT 0,
  `donor_name`       VARCHAR(64) NOT NULL DEFAULT '',
  `created_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pip_created` (`created_at`)
) ENGINE=InnoDB;
