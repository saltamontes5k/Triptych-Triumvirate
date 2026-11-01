-- 20261101_bindral_illusion_stock.sql
-- Correct #Bindral_Argaff (202431, poknowledge sarnak, merchant 7010100) stock.
-- The v261-263 goldfish batch stocked him with 11 generic level-1 ENC scrolls,
-- but his identity (live EQ: the Legendary Enchanter Illusions turn-in NPC)
-- calls for the enchanter ILLUSION line. This replaces his stock with every
-- ENC-castable illusion scroll: linked spell classes14 1-85 carrying the
-- illusion effect (SPA 58), deduped by spell name with lowest item id winning
-- (15287/59961 both scroll Minor Illusion 287; two "Illusion: Banshee" spell
-- rows collapse to one), slotted by class level then name. 74 slots, under the
-- ~100 shop display cap.
-- Twin: database_update_manifest_custom.cpp entry v300 (keep in sync).
SET NAMES utf8mb4;
START TRANSACTION;

DELETE FROM merchantlist WHERE merchantid = 7010100;

INSERT INTO merchantlist (merchantid, slot, item)
SELECT 7010100,
       ROW_NUMBER() OVER (ORDER BY t.enc_lvl, t.name),
       t.item
FROM (
  SELECT i.id AS item, i.name AS name, s.classes14 AS enc_lvl,
         ROW_NUMBER() OVER (PARTITION BY s.name ORDER BY i.id) AS rn
  FROM items i
  JOIN spells_new s ON s.id = i.scrolleffect
  WHERE s.classes14 BETWEEN 1 AND 85
    AND (s.effectid1 = 58 OR s.effectid2 = 58 OR s.effectid3 = 58
      OR s.effectid4 = 58 OR s.effectid5 = 58 OR s.effectid6 = 58
      OR s.effectid7 = 58 OR s.effectid8 = 58 OR s.effectid9 = 58
      OR s.effectid10 = 58 OR s.effectid11 = 58 OR s.effectid12 = 58)
) t
WHERE t.rn = 1;

COMMIT;
