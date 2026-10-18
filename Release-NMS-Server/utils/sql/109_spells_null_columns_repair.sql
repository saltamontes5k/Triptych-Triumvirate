-- Custom migration 109: repair NULL spell columns that crash the shared-memory
-- spell serializer (Strings::ToInt/strn0cpy on NULL -> access violation mid-fill,
-- leaving a truncated shared/spells file). Affects the crafted AA spells
-- (Companion's Veil, Crystalize Essence, Glyph of the Gambler / Frantic Infusion,
-- Invitation of Blood) and any other row inserted with NULL message/desc columns.
-- Twin of database_update_manifest_custom.cpp entry 109.

UPDATE spells_new
SET you_cast = '', other_casts = '', cast_on_you = '', cast_on_other = '', spell_fades = ''
WHERE you_cast IS NULL OR other_casts IS NULL OR cast_on_you IS NULL
   OR cast_on_other IS NULL OR spell_fades IS NULL;

UPDATE spells_new SET teleport_zone = '' WHERE teleport_zone IS NULL;

UPDATE spells_new SET typedescnum = -1, effectdescnum = -1
WHERE typedescnum IS NULL OR effectdescnum IS NULL;

UPDATE spells_new SET name = '' WHERE name IS NULL;
UPDATE spells_new SET player_1 = '' WHERE player_1 IS NULL;
