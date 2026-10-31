-- v280: per-zone mercenary permission.
-- merc.cpp already refuses hire and unsuspend when Zone::AllowMercs() is false, and
-- npc.cpp only loads liaison data when it is true; the flag simply never had a source, so
-- every zone allowed mercs. Default 1 keeps that behaviour for existing rows.
ALTER TABLE `zone` ADD COLUMN `allow_mercs` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1;
