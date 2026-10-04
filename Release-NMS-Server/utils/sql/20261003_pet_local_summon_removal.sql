-- 20261003_pet_local_summon_removal.sql
-- Removes the local-summon pet feature (SummonGroupie / SummonFriendlyLocal) introduced by
-- commit "feat(pets): local-summon level scaling...". Pets return to upstream EQEmu behavior:
-- level/HP/AC/damage come from the focus-selected pets/npc_types row, with no owner- or
-- zone-level scaling.
--
-- Deletes:
--   spells_new   44021-44024   Song/Spell: Summon Groupie / Summon Friendly Local (Rk I & II)
--   items        990230-990233 the spell scrolls that teach them
--   pets         SummonGroupie / SummonFriendlyLocal (and Rk II variants)
--   npc_types    1520001400 (SummonedLocal), 1520001401 (SummonedLocal_R2)
--   rule_values  Custom:LocalSummonPetLevelCap / Custom:LocalSummonPetTypes
--
-- The quest script (Release-NMS-Quests/global/Dulia_Jestes.lua) was deleted from the repo, and
-- the Custom:LocalSummonPet* rules were removed from common/ruletypes.h.

START TRANSACTION;

DELETE FROM `spells_new`  WHERE `id` IN (44021, 44022, 44023, 44024);
DELETE FROM `items`       WHERE `id` IN (990230, 990231, 990232, 990233);
DELETE FROM `pets`        WHERE `type` IN ('SummonGroupie', 'SummonFriendlyLocal', 'SummonGroupieRk2', 'SummonFriendlyLocalRk2');
DELETE FROM `npc_types`   WHERE `id` IN (1520001400, 1520001401);
DELETE FROM `rule_values` WHERE `rule_name` IN ('Custom:LocalSummonPetLevelCap', 'Custom:LocalSummonPetTypes');

COMMIT;
