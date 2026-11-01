-- 20261101_pok_werewolf_dedupe.sql
-- Remove the seven werewolf (race 14) duplicate class-merchants from poknowledge.
-- Each is an 'a'-suffixed werewolf twin of a stock PoK class vendor that still
-- stands in the zone (Elementalist_Somat, Illusionist_Jerup, Illusionist_Sevat,
-- Wanderer_Astobin, Wanderer_Qenda, Vicar_Thiran). Verified before removal:
-- every id is poknowledge-exclusive, each spawngroup is dedicated 1:1, all
-- loottable_id = 0, and 202469 Wanderer_Astobina's quest script (name-based,
-- a subset of stock Wanderer_Astobin's) is deleted from both quests copies.
-- Known content loss: 202466 Elementalist_Siewtha was the only vendor of spells
-- 16341 Elemental Silence, 21646 Talisman of Return, 21669 Burnout V,
-- 28430 Sun Storm, 28431 Servant of Marr, 28462 Imbue Earth, 59639 Burning Sand.
-- Twin: database_update_manifest_custom.cpp entry v299 (keep in sync).
SET NAMES utf8mb4;
START TRANSACTION;

-- spawn entries for the werewolf twins (each group holds only its one npc)
DELETE FROM spawnentry WHERE npcID IN (202465,202466,202467,202468,202469,202470,202471);

-- their spawn points
DELETE FROM spawn2 WHERE id IN (241657,241658,241659,241660,241661,241662,241663);

-- and the now-empty dedicated spawngroups
DELETE FROM spawngroup WHERE id IN (259491,259492,259493,259494,259495,259496,259497);

-- shop inventories
DELETE FROM merchantlist WHERE merchantid IN (202465,202466,202467,202468,202469,202470,202471);

-- the npc rows themselves (no other zone references these ids)
DELETE FROM npc_types WHERE id IN (202465,202466,202467,202468,202469,202470,202471);

COMMIT;
