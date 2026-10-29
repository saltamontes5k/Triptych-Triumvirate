-- RoF2 fellowship: fellowship_vitality (custom schema v271)
-- Twin of ManifestEntry .version = 271 in common/database/database_update_manifest_custom.cpp

-- Character-owned banks deliberately survive fellowship departure/disband.
-- Cached caps are refreshed by zone login/progression. Unknown offline caps use
-- bounded safety ceilings, a server policy rather than a claim of Live parity.
CREATE TABLE IF NOT EXISTS fellowship_vitality (
 character_id INT UNSIGNED NOT NULL PRIMARY KEY,
 normal_pool BIGINT UNSIGNED NOT NULL DEFAULT 0,
 aa_pool INT UNSIGNED NOT NULL DEFAULT 0,
 normal_cap BIGINT UNSIGNED NOT NULL DEFAULT 1000000000000,
 aa_cap INT UNSIGNED NOT NULL DEFAULT 2000000000
) ENGINE=InnoDB;
