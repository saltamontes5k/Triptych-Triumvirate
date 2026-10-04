-- Rollback for 20260929_dire_charm_levels.sql
SET NAMES utf8mb4;

-- Restore original spell charm caps
UPDATE spells_new SET max1 = 46 WHERE id IN (2759,2760,2761) AND effectid1 = 22;
UPDATE spells_new SET max1 = 55 WHERE id = 43990 AND effectid1 = 22;

-- Restore original AA tooltip level text
UPDATE db_str SET value = REPLACE(value, 'below level 67', 'below level 47')
WHERE id = 145 AND type = 4;
UPDATE db_str SET value = REPLACE(value, 'below level 61', 'below level 47')
WHERE id IN (960,961) AND type = 4;

-- Restore Ascendant ENC description to native ENC's shared string and drop the extra row
UPDATE aa_ranks SET desc_sid = 145 WHERE id = 41500;
DELETE FROM db_str WHERE id = 54016 AND type = 4;
