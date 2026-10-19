-- Rollback for 20261019_blessing_heal_spells.sql
-- Removes the classless blessing percent-heal spells. The plugin change must be
-- rolled back separately (deity_blessings.pl).
-- After applying: shared-memory.bat, export-client-files.bat <client>, restart
-- the zone layer.

DELETE FROM `db_str`     WHERE `id` IN (910000010,910000011,910000012,910000013) AND `type`=6;
DELETE FROM `spells_new` WHERE `id` IN (44016,44019,44029,44030);
