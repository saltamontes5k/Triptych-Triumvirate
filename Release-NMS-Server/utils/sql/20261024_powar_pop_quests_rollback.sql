-- ============================================================================
-- 20261024_powar_pop_quests_rollback.sql — full reversal of the PoW PoP-ized
-- migration. Restores npc_types/items/spawn2 from the bk_20261024_powar_*
-- snapshot tables, then removes everything the forward pass added.
-- ============================================================================
-- Forward: 20261024_powar_pop_quests.sql
-- ============================================================================

-- Restore tuned NPCs (level/hp/dmg/loot assignment)
UPDATE npc_types nt
JOIN bk_20261024_powar_npc_types bk ON bk.id = nt.id
SET nt.level = bk.level,
    nt.hp = bk.hp,
    nt.maxlevel = bk.maxlevel,
    nt.mindmg = bk.mindmg,
    nt.maxdmg = bk.maxdmg,
    nt.npcspecialattks = bk.npcspecialattks,
    nt.slow_mitigation = bk.slow_mitigation,
    nt.raid_target = bk.raid_target,
    nt.loottable_id = bk.loottable_id;

-- Restore retuned items
UPDATE items it
JOIN bk_20261024_powar_items bk ON bk.id = it.id
SET it.reqlevel = bk.reqlevel,
    it.reclevel = bk.reclevel,
    it.clicklevel2 = bk.clicklevel2,
    it.ac = bk.ac,
    it.hp = bk.hp,
    it.mana = bk.mana,
    it.endur = bk.endur,
    it.dr = bk.dr;

-- Restore boss respawn timers
UPDATE spawn2 s2
JOIN bk_20261024_powar_spawn2 bk ON bk.id = s2.id
SET s2.respawntime = bk.respawntime,
    s2.variance = bk.variance;

-- Remove new content (children before parents)
DELETE FROM spawnentry WHERE spawngroupID BETWEEN 1520009200 AND 1520009215;
DELETE FROM spawn2 WHERE spawngroupID BETWEEN 1520009200 AND 1520009215;
DELETE FROM spawngroup WHERE id BETWEEN 1520009200 AND 1520009215;

DELETE FROM lootdrop_entries WHERE lootdrop_id BETWEEN 1520009400 AND 1520009413;
DELETE FROM lootdrop WHERE id BETWEEN 1520009400 AND 1520009413;
DELETE FROM loottable_entries WHERE loottable_id BETWEEN 1520009300 AND 1520009313;
DELETE FROM loottable WHERE id BETWEEN 1520009300 AND 1520009313;

DELETE FROM items WHERE id BETWEEN 9921000 AND 9921015;

DELETE FROM npc_types WHERE id BETWEEN 1120002500 AND 1120002546;

DELETE FROM faction_list WHERE id IN (5060, 5061);

-- Drop the snapshot tables last
DROP TABLE IF EXISTS bk_20261024_powar_npc_types;
DROP TABLE IF EXISTS bk_20261024_powar_items;
DROP TABLE IF EXISTS bk_20261024_powar_spawn2;
