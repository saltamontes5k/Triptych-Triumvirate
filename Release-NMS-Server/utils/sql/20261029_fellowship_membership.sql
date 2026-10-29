-- RoF2 fellowship: fellowship_membership (custom schema v270)
-- Twin of ManifestEntry .version = 270 in common/database/database_update_manifest_custom.cpp

-- Native fellowship persistence. Apply to the active character database.
-- Additive and repeatable; leaves existing character/housing data untouched.
CREATE TABLE IF NOT EXISTS fellowship_guard (
 id TINYINT UNSIGNED NOT NULL PRIMARY KEY
) ENGINE=InnoDB;
INSERT IGNORE INTO fellowship_guard (id) VALUES (1);
CREATE TABLE IF NOT EXISTS fellowships (
 id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 leader_id INT UNSIGNED NOT NULL,
 motd VARCHAR(1023) NOT NULL DEFAULT '',
 revision BIGINT UNSIGNED NOT NULL DEFAULT 1,
 created_at BIGINT UNSIGNED NOT NULL,
 campfire_zone_id INT UNSIGNED NOT NULL DEFAULT 0,
 campfire_instance_id INT UNSIGNED NOT NULL DEFAULT 0,
 campfire_type INT UNSIGNED NOT NULL DEFAULT 0,
 campfire_x FLOAT NOT NULL DEFAULT 0,
 campfire_y FLOAT NOT NULL DEFAULT 0,
 campfire_z FLOAT NOT NULL DEFAULT 0,
 campfire_heading FLOAT NOT NULL DEFAULT 0,
 campfire_expires_at BIGINT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS fellowship_members (
 character_id INT UNSIGNED NOT NULL PRIMARY KEY,
 fellowship_id INT UNSIGNED NOT NULL,
 share_experience TINYINT UNSIGNED NOT NULL DEFAULT 0,
 joined_at BIGINT UNSIGNED NOT NULL,
 KEY fellowship_members_group (fellowship_id),
 CONSTRAINT fellowship_member_group_fk FOREIGN KEY (fellowship_id)
  REFERENCES fellowships(id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS fellowship_invitations (
 target_id INT UNSIGNED NOT NULL,
 fellowship_id INT UNSIGNED NOT NULL,
 inviter_id INT UNSIGNED NOT NULL,
 expires_at BIGINT UNSIGNED NOT NULL,
 PRIMARY KEY (target_id, inviter_id),
 KEY fellowship_invitation_group (fellowship_id),
 CONSTRAINT fellowship_invitation_group_fk FOREIGN KEY (fellowship_id)
  REFERENCES fellowships(id) ON DELETE CASCADE
) ENGINE=InnoDB;
