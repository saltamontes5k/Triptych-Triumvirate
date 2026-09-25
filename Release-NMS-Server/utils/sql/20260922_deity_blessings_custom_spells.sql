-- ============================================================================
-- Deity Blessings -- collision-free buff effect spells (stack with everything)
-- Date: 2026-09-22
--
-- Custom, unscribable clones of the buff-type blessing effects. Their IDs are
-- added to Spells:AlwaysStackSpells so a blessing never conflicts with any
-- player spell line (different spell ids -> rule short-circuits to "no conflict").
--
--  50018 Blessing: Disease       (from Scourge 31; single target)
--  50019 Blessing: Root          (from Root 230)
--  50020 Blessing: Fear          (from Fear 229)
--  50021 Blessing: Snare         (from Cryomantic Snare 12721)
--  50022 Blessing: Damage Shield (from Nettle Shield 5358 -- Druid DS, SPA 59 only)
-- ============================================================================

DELETE FROM `spells_new` WHERE `id` IN (50018,50019,50020,50021,50022);
DELETE FROM `db_str`     WHERE `id` IN (910000005,910000006,910000007,910000008,910000009) AND `type`=6;

-- ---- Blessing: Disease (Scourge) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=31;
UPDATE `tmp_spell` SET `id`=50018, `name`='Blessing: Disease', `descnum`=910000005,
  `targettype`=5,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=31;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- Blessing: Root (Root) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=230;
UPDATE `tmp_spell` SET `id`=50019, `name`='Blessing: Root', `descnum`=910000006,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=230;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- Blessing: Fear (Fear) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=229;
UPDATE `tmp_spell` SET `id`=50020, `name`='Blessing: Fear', `descnum`=910000007,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=229;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- Blessing: Snare (Cryomantic Snare) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=12721;
UPDATE `tmp_spell` SET `id`=50021, `name`='Blessing: Snare', `descnum`=910000008,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=12721;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- Blessing: Damage Shield (Nettle Shield -- Druid DS, no fire resist) ----
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=5358;
UPDATE `tmp_spell` SET `id`=50022, `name`='Blessing: Damage Shield', `descnum`=910000009,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=5358;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- ---- descriptions ----
INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
    (910000005, 6, 'A blessing of decay seeps into your foe, rotting flesh over time.'),
    (910000006, 6, 'A blessing of stone grips your foe, holding it in place.'),
    (910000007, 6, 'A blessing of dread overwhelms your foe, sending it fleeing.'),
    (910000008, 6, 'A blessing of the wilds tangles your foe, slowing its movement.'),
    (910000009, 6, 'A divine blessing shields you, injuring those who strike you.');

-- ---- never collide with any other spell line ----
UPDATE `rule_values`
SET `rule_value` = CONCAT(`rule_value`, ',50018,50019,50020,50021,50022')
WHERE `rule_name` = 'Spells:AlwaysStackSpells'
  AND `rule_value` NOT LIKE '%50018%';
