-- ============================================================================
-- Dire Charm level rebalance
--   Native Enchanter ........................ below level 67   (max1 55 -> 66)
--   Druid / Necromancer / Tome / Ascendant .. below level 61   (max1 46 -> 60)
--
-- The charm cap lives in spells_new.max1 on the SE_Charm (effectid1 = 22) slot;
-- for SE_Charm the "Max" column is the maximum charmable NPC level.
--
-- Ascendant ranks 41500-41502 carry only Pet Illusion spells and resolve their
-- charm through a nested tome rank, so they inherit the tome cap (2761/2760/
-- 2759) and need no change here.
--
-- The boosted enc-dru / enc-nec ranks 42332/42333 intentionally share spell
-- 43990 with the native Enchanter charm ("raised to the Enchanter standard",
-- see ascendant_insight_trainer.pl), so they move to 66 together with it.
--
-- Idempotent. Rollback: 20260929_dire_charm_levels_rollback.sql
-- ============================================================================
SET NAMES utf8mb4;

-- ---- Spell charm caps ----
-- 2759 native+tome NEC, 2760 native+tome DRU, 2761 tome ENC -> 60
UPDATE spells_new SET max1 = 60 WHERE id IN (2759,2760,2761) AND effectid1 = 22;
-- 43990 native ENC (+ boosted enc-dru/enc-nec) -> 66
UPDATE spells_new SET max1 = 66 WHERE id = 43990 AND effectid1 = 22;

-- ---- AA tooltips (db_str type 4 = AA description) ----
-- Native ENC (aa_ranks 145 desc_sid 145)
UPDATE db_str SET value = REPLACE(value, 'below level 47', 'below level 67')
WHERE id = 145 AND type = 4;
-- Native DRU/NEC (aa_ranks 960/961); Ascendant DRU/NEC reuse these desc_sids
UPDATE db_str SET value = REPLACE(value, 'below level 47', 'below level 61')
WHERE id IN (960,961) AND type = 4;

-- ---- Ascendant ENC tooltip ----
-- aa_ranks 41500 (Dire Charm (Ascendant), Enchanter) shares native ENC's
-- desc_sid (145) but resolves to the 60-cap tome spell, so it needs its own
-- level-61 text. Repoint only that rank's description.
DELETE FROM db_str WHERE id = 54016 AND type = 4;
INSERT INTO db_str (id, type, value) VALUES
(54016, 4, 'This ability gives you the chance to permanently charm any NPC which is either below level 61, or considers Light Blue to the caster. You may not have an animation active at the same time as dire charm, but may use the pets, charms, and even dire charms of other classes. /alt activate 31084');
UPDATE aa_ranks SET desc_sid = 54016 WHERE id = 41500;
