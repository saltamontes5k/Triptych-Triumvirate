-- Plane of Time A trash goes hostile: point the 53 combat mobs (npc_types
-- 219000-219052, all potimea v0) at npc_faction 703 "PoTime KOS"
-- (primaryfaction 1726 "Inhabitants of Time", base -2000) so they con scowls
-- and attack on sight, matching the potimeb trial adds and live behavior.
-- Kills cause no faction hits (npc_faction_entries 703 is empty). Idempotent.
-- Also embedded as custom manifest entry 140; this file is the standalone
-- reference copy.
UPDATE `npc_types` SET `npc_faction_id` = 703 WHERE `id` BETWEEN 219000 AND 219052;
