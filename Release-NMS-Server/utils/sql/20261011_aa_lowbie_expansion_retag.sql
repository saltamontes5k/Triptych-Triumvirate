-- Re-tag low-level AA ranks mis-flagged as Underfoot (16) to Planes of Power (4)
-- so level 1-50 adventurers can buy them (48 rows). Also embedded as custom
-- manifest entry 138; this file is the standalone reference copy.
UPDATE `aa_ranks` SET `expansion` = 4 WHERE `expansion` = 16 AND `level_req` <= 50;
