-- Rename the bazaar blessing buffs granted by Mal'zeth V'Tide ("Master of Buffs")
-- from "Echo of X" to "Triune of X".
-- Date: 2026-09-23
-- Spell IDs are unchanged; only the player-visible names change.
-- Idempotent: plain UPDATEs.

UPDATE `spells_new` SET `name` = 'Triune of Luck'       WHERE `id` = 17779;
UPDATE `spells_new` SET `name` = 'Triune of Power'      WHERE `id` = 36856;
UPDATE `spells_new` SET `name` = 'Triune of Experience' WHERE `id` = 43002;
UPDATE `spells_new` SET `name` = 'Triune of Aegolism'   WHERE `id` = 43003;
UPDATE `spells_new` SET `name` = 'Triune of Focus'      WHERE `id` = 43004;
UPDATE `spells_new` SET `name` = 'Triune of Selo'       WHERE `id` = 43005;
UPDATE `spells_new` SET `name` = 'Triune of Koadic'     WHERE `id` = 43006;
UPDATE `spells_new` SET `name` = 'Triune of the Brood'  WHERE `id` = 43007;
UPDATE `spells_new` SET `name` = 'Triune of the Grove'  WHERE `id` = 43008;
