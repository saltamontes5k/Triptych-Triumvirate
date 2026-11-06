-- v348 / v349 (2026-11-05) -- repair for the v334 payload that never ran.
-- Twin of database_update_manifest_custom.cpp v348 (lon_account_pref width) and
-- v349 (lon_account.progression_granted). APPLY BOTH before the card service logs
-- in again: without the column, GrantOnLogin's SELECT fails and every gift
-- (starter deck, Oathbound progression pair, monthly packs, bought deliveries)
-- is withheld silently; without the width, the campaign status preference
-- (0x1054, tens of KB) cannot be stored and scenario progression resets again.
--
-- Why v334 was not enough: its check asked only for lon_campaign_status, and the
-- runner only walks versions above db_version.custom_version
-- (common/database/database_update.cpp:159). Once custom_version passed 334 the
-- remaining two statements in that entry could never run again, even though
-- lon_campaign_status existed.
--
-- Idempotent by hand too: run the SHOW first, apply only what is missing.

-- Expect varbinary(4096) -> blob. BLOB, not varbinary(65535): MariaDB caps VARBINARY
-- at 65532 bytes, and that ER_TOO_BIG_FIELDLENGTH is what killed the v334 run.
SHOW COLUMNS FROM `lon_account_pref` LIKE 'value';
ALTER TABLE `lon_account_pref` MODIFY `value` BLOB NOT NULL;

-- Expect the handler names in SHOW CREATE TABLE -> then the flag.
SHOW COLUMNS FROM `lon_account` LIKE 'progression_granted';
ALTER TABLE `lon_account` ADD COLUMN `progression_granted` tinyint unsigned NOT NULL DEFAULT 0;
