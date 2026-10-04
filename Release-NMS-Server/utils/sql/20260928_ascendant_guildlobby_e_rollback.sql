-- Rollback for 20260928_ascendant_guildlobby_e.sql
DELETE FROM spawn2 WHERE id = 2141248;
DELETE FROM spawnentry WHERE spawngroupID = 5004028;
DELETE FROM spawngroup WHERE id = 5004028;
DELETE FROM npc_types WHERE id = 344049;
DELETE FROM content_flags WHERE flag_name = 'april_fools';
DELETE FROM items WHERE id = 121857;
