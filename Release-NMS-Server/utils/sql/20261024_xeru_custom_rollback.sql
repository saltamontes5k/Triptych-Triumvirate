-- Rollback of 20261024_xeru_custom.sql (manifest entry 223).
-- Removes the script-spawned High Inquisitor Xeru npc_types row. The name
-- guard keeps the delete from ever touching a repurposed id.

DELETE FROM npc_types
 WHERE id = 1120002172
   AND name = '#High_Inquisitor_Xeru';

DROP TABLE IF EXISTS nms_tmp_xeru;

-- Post-condition: zero rows.
SELECT id, name FROM npc_types WHERE id = 1120002172;
