-- High Inquisitor Xeru (npc 1120002172): custom Seru-clone bonus boss in sseru.
-- Spawns at Seru's bind point (-231.5, -432.9, 202.4) when either Lord
-- Inquisitor Seru form (159690 first form / 159691 leash form) dies, handled
-- by quests/sseru/encounters/xeru_custom.lua. He is script-spawned only --
-- no spawn2/spawngroup rows -- and despawns 2 hours after spawning if
-- unkilled. Loot is granted purely by the encounter script (Fragments of
-- Truth, Enchanted floor / Legendary jackpot per tier), so loottable_id
-- stays 0 and Seru's own table (13516) remains unique to Seru.
--
-- Stat clone of #Lord_Inquisitor_Seru_ (159691), the hard leash form --
-- level 66, 1.2M HP, MR 800 -- because the script's lieutenant-scaling
-- resist boost only lifts resists that sit below its 250 cap.
--
-- Twin of manifest entry 223.

DROP TABLE IF EXISTS nms_tmp_xeru;

CREATE TABLE nms_tmp_xeru AS
  SELECT * FROM npc_types WHERE id = 159691;

UPDATE nms_tmp_xeru
   SET id = 1120002172,
       name = '#High_Inquisitor_Xeru',
       loottable_id = 0;

INSERT INTO npc_types SELECT * FROM nms_tmp_xeru;

DROP TABLE IF EXISTS nms_tmp_xeru;

-- Post-condition: exactly one row, cloned stats, empty loot table.
SELECT id, name, level, hp, loottable_id, npc_faction_id, raid_target
  FROM npc_types
 WHERE id = 1120002172;
