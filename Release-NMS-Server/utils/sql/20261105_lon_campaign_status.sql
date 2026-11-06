-- v334 (2026-11-05) -- lon_campaign_status: the card game's campaign /
-- scenario progression. The client reports it with
-- AccountCommand_SetCampaignStatus (0x19F) -- one status per difficulty,
-- from the one won down to 1, at every scenario completion -- but the
-- service only cached it in the Session for the reward tier and dropped
-- it on disconnect, so every card-game login rebuilt the campaign map
-- from nothing and progression reset after every logout. One row per
-- account x campaign x difficulty; REPLACE per report.
-- Twin: common/database/database_update_manifest_custom.cpp v334 (keep in sync).

CREATE TABLE IF NOT EXISTS `lon_campaign_status` (
  `account_id` int unsigned NOT NULL,
  `campaign_id` int NOT NULL,
  `difficulty` int NOT NULL,
  `status` int NOT NULL DEFAULT 0,
  `archetype` int NOT NULL DEFAULT 0,
  `extra` varchar(64) NOT NULL DEFAULT '',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`,`campaign_id`,`difficulty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- The campaign status map (preference 0x1054) alone can be tens of KB; the old
-- 4096 cap silently dropped it (and every preference sent after it in the set).
-- BLOB: MariaDB caps VARBINARY at 65532 bytes (ER_TOO_BIG_FIELDLENGTH), which is
-- what made this entry fail half-applied on live peq; BLOB holds all 65535 bytes.
ALTER TABLE `lon_account_pref` MODIFY `value` BLOB NOT NULL;

-- One flag per account gates the Oathbound Fighter/Priest progression-starter gift
-- (GrantOnLogin re-runs at every card login; without it every login would re-grant).
ALTER TABLE `lon_account` ADD COLUMN `progression_granted` tinyint unsigned NOT NULL DEFAULT 0;
