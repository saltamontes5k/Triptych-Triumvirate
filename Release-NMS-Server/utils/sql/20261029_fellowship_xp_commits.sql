-- RoF2 fellowship: fellowship_xp_commits (custom schema v272)
-- Twin of ManifestEntry .version = 272 in common/database/database_update_manifest_custom.cpp

-- Audit receipts commit in the SAME transaction as character XP and all bank
-- mutations. No pending replay: rollback loses neither bank credit nor debit.
-- Runtime retains latest256 receipts percharacter automatically.
CREATE TABLE IF NOT EXISTS fellowship_xp_commits (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 character_id INT UNSIGNED NOT NULL,
 normal_before BIGINT UNSIGNED NOT NULL,
 normal_after BIGINT UNSIGNED NOT NULL,
 aa_before BIGINT UNSIGNED NOT NULL,
 aa_after BIGINT UNSIGNED NOT NULL,
 aa_points_before INT UNSIGNED NOT NULL,
 aa_points_after INT UNSIGNED NOT NULL,
 committed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 KEY character_receipts(character_id,id)
) ENGINE=InnoDB;
