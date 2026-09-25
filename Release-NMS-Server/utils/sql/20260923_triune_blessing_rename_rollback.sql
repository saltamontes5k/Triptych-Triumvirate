-- Rollback for 20260923_triune_blessing_rename.sql
-- Restore the original "Echo of X" blessing names.

UPDATE `spells_new` SET `name` = 'Echo of Luck'       WHERE `id` = 17779;
UPDATE `spells_new` SET `name` = 'Echo of Power'      WHERE `id` = 36856;
UPDATE `spells_new` SET `name` = 'Echo of Experience' WHERE `id` = 43002;
UPDATE `spells_new` SET `name` = 'Echo of Aegolism'   WHERE `id` = 43003;
UPDATE `spells_new` SET `name` = 'Echo of Focus'      WHERE `id` = 43004;
UPDATE `spells_new` SET `name` = 'Echo of Selo'       WHERE `id` = 43005;
UPDATE `spells_new` SET `name` = 'Echo of Koadic'     WHERE `id` = 43006;
UPDATE `spells_new` SET `name` = 'Echo of the Brood'  WHERE `id` = 43007;
UPDATE `spells_new` SET `name` = 'Echo of the Grove'  WHERE `id` = 43008;
