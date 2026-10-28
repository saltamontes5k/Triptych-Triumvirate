-- 20261025_spell_summon_negative_item_decode.sql
--
-- Symptom: mage DoN-era summon item spells (Summon Fireblade, Summon Staff of the
-- North Wind, Summon Dagger of the Deep, Summon Crystal Belt, the Calliav's line,
-- Hammer of Reproach) failed to summon anything; the zone printed
-- "Unable to summon item -992492. Item not found." The same negative encoding also
-- sits on non-mage summon spells (Wand of Phantasmal Modulation, Axe of the Brute,
-- Enchant Planar Alloy, the Modulating Shards, Dispense Fresh Cookie, Summon/Hurl
-- Discus, Secretion of the Mamba, Grant Visor of Gobeker, Omen-Mage-PH).
--
-- Root cause: these rows carry the PEQ Al'Kabor snapshot's negative SummonItem
-- encoding. The real item id is base_value + 1070000. Verified by name match for
-- every row whose decode target exists in items (e.g. spell 5467 Summon Fireblade
-- -992492 -> item 77508 "Summoned: Fireblade"; 5465 -> 77507 Staff of the North
-- Wind; 5477 -> 77509 Dagger of the Deep; 5489 -> 77510 Crystal Belt;
-- 5464/5468/5469/5470/5475 -> 77512-77515 + 77511 Calliav's pieces; 5264 -> 77517
-- Hammer of Reproach; 35945-47 -> 76502; 35934 -> 76507; 36495 -> 76500;
-- 33106/33107 -> 76300; 27465-67 -> 79320-79322; 33783 -> 71980 Fresh Cookie).
-- 13387/13388 (Summon/Hurl Discus -> 79596) and the NPC-only jokes
-- (6608 Prathun's Cone of Cold -> 75018, 33480/37861 Secretion of the Mamba ->
-- 76890) are decoded by the same rule; every UPDATE below is additionally guarded
-- by an EXISTS on the decode target so a row whose target is absent is left
-- untouched.
--
-- Mob::SE_SummonItem (zone/spell_effects.cpp) reads the raw base value with no
-- decode, and Custom:DoItemUpgrades=true (rule_values) feeds it through
-- GetMaxItemUpgrade first; a negative id wraps to ~4.29e9 as uint32, finds no
-- item, and the cast fails. No callers of SE_SummonItem/SE_SummonItemIntoBag
-- decode negatives, so fixing the data is the fix; no code change.
--
-- After applying: regenerate the client data files (export-client-files.bat
-- <client>) so spells_us.txt carries the positive ids, then restart zones
-- (spells_new is loaded at zone boot).
--
-- Rollback (mirror): rerun these same statements with - 1070000 instead of
-- + 1070000, restricted to the same effectid/base conditions.

UPDATE spells_new SET effect_base_value1 = effect_base_value1 + 1070000
WHERE effectid1 IN (32,109) AND effect_base_value1 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value1 + 1070000);

UPDATE spells_new SET effect_base_value2 = effect_base_value2 + 1070000
WHERE effectid2 IN (32,109) AND effect_base_value2 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value2 + 1070000);

UPDATE spells_new SET effect_base_value3 = effect_base_value3 + 1070000
WHERE effectid3 IN (32,109) AND effect_base_value3 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value3 + 1070000);

UPDATE spells_new SET effect_base_value4 = effect_base_value4 + 1070000
WHERE effectid4 IN (32,109) AND effect_base_value4 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value4 + 1070000);

UPDATE spells_new SET effect_base_value5 = effect_base_value5 + 1070000
WHERE effectid5 IN (32,109) AND effect_base_value5 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value5 + 1070000);

UPDATE spells_new SET effect_base_value6 = effect_base_value6 + 1070000
WHERE effectid6 IN (32,109) AND effect_base_value6 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value6 + 1070000);

UPDATE spells_new SET effect_base_value7 = effect_base_value7 + 1070000
WHERE effectid7 IN (32,109) AND effect_base_value7 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value7 + 1070000);

UPDATE spells_new SET effect_base_value8 = effect_base_value8 + 1070000
WHERE effectid8 IN (32,109) AND effect_base_value8 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value8 + 1070000);

UPDATE spells_new SET effect_base_value9 = effect_base_value9 + 1070000
WHERE effectid9 IN (32,109) AND effect_base_value9 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value9 + 1070000);

UPDATE spells_new SET effect_base_value10 = effect_base_value10 + 1070000
WHERE effectid10 IN (32,109) AND effect_base_value10 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value10 + 1070000);

UPDATE spells_new SET effect_base_value11 = effect_base_value11 + 1070000
WHERE effectid11 IN (32,109) AND effect_base_value11 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value11 + 1070000);

UPDATE spells_new SET effect_base_value12 = effect_base_value12 + 1070000
WHERE effectid12 IN (32,109) AND effect_base_value12 < 0
  AND EXISTS (SELECT 1 FROM items i WHERE i.id = effect_base_value12 + 1070000);
