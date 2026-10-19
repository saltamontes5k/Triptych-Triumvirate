-- ============================================================================
-- Deity Blessings -- classless percent-heal spells
-- Date: 2026-10-19
--
-- The rank-1 blessing "group heal" was cast as Cantata of Rodcet (18006), a
-- level-81 bard group song. Spells:BuffLevelRestrictions=true rejects a group
-- buff on any target below level 62 (Mob::CheckSpellLevelRestriction) and the
-- failure message is suppressed for bard songs, so the proc was completely
-- silent -- including for a level-60 Rodcet follower whose rank-1 kit is
-- nothing but that heal.
--
-- These replacements are classless (classes 255), instant (no buff slot, so
-- the buff level gate never applies) and heal a percentage of the target's
-- maximum HP via SE_PercentalHeal (147):
--
--   44016  Blessing: Mend       self     10%
--   44019  Blessing: Renewal    group    10%
--   44029  Blessing: Balm       self      4%
--   44030  Blessing: Grace      self      8%
--
-- Companion change: Release-NMS-Plugins/deity_blessings.pl casts these in
-- place of 18006 / Healing (12) and routes {heal}/{heal_if_hurt} through the
-- matching percent spell so every blessing heal is visible in the log.
--
-- After applying: shared-memory.bat, export-client-files.bat <client>,
-- restart the zone layer.
-- Idempotent. Rollback: 20261019_blessing_heal_spells_rollback.sql
-- ============================================================================
SET NAMES utf8mb4;

DELETE FROM `db_str`     WHERE `id` IN (910000010,910000011,910000012,910000013) AND `type`=6;
DELETE FROM `spells_new` WHERE `id` IN (44016,44019,44029,44030);
-- ---- 44016 Blessing: Mend (10%) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=12;
UPDATE `tmp_spell` SET
    `id`=44016, `name`='Blessing: Mend', `descnum`=910000010,
    `cast_on_you`='You feel a gentle mending.', `cast_on_other`=' feels a gentle mending.',
    `targettype`=6, `goodEffect`=1, `range`=100, `aoerange`=0,
    `cast_time`=0, `recovery_time`=0, `recast_time`=0, `mana`=0,
    `buffdurationformula`=0, `buffduration`=0, `AEDuration`=0,
    `effectid1`=147, `effect_base_value1`=10, `effect_limit_value1`=0, `max1`=0, `formula1`=100,
    `effectid2`=254, `effect_base_value2`=0, `max2`=0, `formula2`=100,
    `resisttype`=0, `skill`=5,
    `classes1`=255,
    `classes2`=255,
    `classes3`=255,
    `classes4`=255,
    `classes5`=255,
    `classes6`=255,
    `classes7`=255,
    `classes8`=255,
    `classes9`=255,
    `classes10`=255,
    `classes11`=255,
    `classes12`=255,
    `classes13`=255,
    `classes14`=255,
    `classes15`=255,
    `classes16`=255
WHERE `id`=12;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;
-- ---- 44019 Blessing: Renewal (10%) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=12;
UPDATE `tmp_spell` SET
    `id`=44019, `name`='Blessing: Renewal', `descnum`=910000011,
    `cast_on_you`='You feel a wave of renewal.', `cast_on_other`=' is renewed.',
    `targettype`=41, `goodEffect`=1, `range`=100, `aoerange`=0,
    `cast_time`=0, `recovery_time`=0, `recast_time`=0, `mana`=0,
    `buffdurationformula`=0, `buffduration`=0, `AEDuration`=0,
    `effectid1`=147, `effect_base_value1`=10, `effect_limit_value1`=0, `max1`=0, `formula1`=100,
    `effectid2`=254, `effect_base_value2`=0, `max2`=0, `formula2`=100,
    `resisttype`=0, `skill`=5,
    `classes1`=255,
    `classes2`=255,
    `classes3`=255,
    `classes4`=255,
    `classes5`=255,
    `classes6`=255,
    `classes7`=255,
    `classes8`=255,
    `classes9`=255,
    `classes10`=255,
    `classes11`=255,
    `classes12`=255,
    `classes13`=255,
    `classes14`=255,
    `classes15`=255,
    `classes16`=255
WHERE `id`=12;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;
-- ---- 44029 Blessing: Balm (4%) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=12;
UPDATE `tmp_spell` SET
    `id`=44029, `name`='Blessing: Balm', `descnum`=910000012,
    `cast_on_you`='You feel a soothing balm.', `cast_on_other`=' is soothed.',
    `targettype`=6, `goodEffect`=1, `range`=100, `aoerange`=0,
    `cast_time`=0, `recovery_time`=0, `recast_time`=0, `mana`=0,
    `buffdurationformula`=0, `buffduration`=0, `AEDuration`=0,
    `effectid1`=147, `effect_base_value1`=4, `effect_limit_value1`=0, `max1`=0, `formula1`=100,
    `effectid2`=254, `effect_base_value2`=0, `max2`=0, `formula2`=100,
    `resisttype`=0, `skill`=5,
    `classes1`=255,
    `classes2`=255,
    `classes3`=255,
    `classes4`=255,
    `classes5`=255,
    `classes6`=255,
    `classes7`=255,
    `classes8`=255,
    `classes9`=255,
    `classes10`=255,
    `classes11`=255,
    `classes12`=255,
    `classes13`=255,
    `classes14`=255,
    `classes15`=255,
    `classes16`=255
WHERE `id`=12;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;
-- ---- 44030 Blessing: Grace (8%) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=12;
UPDATE `tmp_spell` SET
    `id`=44030, `name`='Blessing: Grace', `descnum`=910000013,
    `cast_on_you`='You are touched by grace.', `cast_on_other`=' is touched by grace.',
    `targettype`=6, `goodEffect`=1, `range`=100, `aoerange`=0,
    `cast_time`=0, `recovery_time`=0, `recast_time`=0, `mana`=0,
    `buffdurationformula`=0, `buffduration`=0, `AEDuration`=0,
    `effectid1`=147, `effect_base_value1`=8, `effect_limit_value1`=0, `max1`=0, `formula1`=100,
    `effectid2`=254, `effect_base_value2`=0, `max2`=0, `formula2`=100,
    `resisttype`=0, `skill`=5,
    `classes1`=255,
    `classes2`=255,
    `classes3`=255,
    `classes4`=255,
    `classes5`=255,
    `classes6`=255,
    `classes7`=255,
    `classes8`=255,
    `classes9`=255,
    `classes10`=255,
    `classes11`=255,
    `classes12`=255,
    `classes13`=255,
    `classes14`=255,
    `classes15`=255,
    `classes16`=255
WHERE `id`=12;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;
-- ---- examine text ----
INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
    (910000010, 6, 'Mends your wounds for 10% of your maximum health.'),
    (910000011, 6, 'Mends the wounds of your group for 10% of each member''s maximum health.'),
    (910000012, 6, 'Mends your wounds for 4% of your maximum health.'),
    (910000013, 6, 'Mends your wounds for 8% of your maximum health.');
