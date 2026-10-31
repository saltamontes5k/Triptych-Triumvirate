-- v279: one mercenary per (owner, slot).
-- The table only had PRIMARY(MercID), so two rows could claim the same slot for one owner.
-- Existing duplicates are meant to break this migration -- the shipped database has none
-- (4 rows, 4 distinct pairs). Matches the public rof2-mercenaries 001_owned_roster.sql.
ALTER TABLE `mercs` ADD UNIQUE KEY `merc_owned_slot` (`OwnerCharacterID`,`Slot`);
