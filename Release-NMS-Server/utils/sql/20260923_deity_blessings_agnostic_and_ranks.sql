-- ============================================================================
-- Deity Blessings -- Agnostic naming, repeatable ranks, Rank I delivery gate
-- Date: 2026-09-23
--
-- Mirrors manifest v73. Corrects databases where the custom blessing spells
-- predate the v72 ensure (keeps Disease single target), renames the Agnostic
-- idol chain (dropping the deity qualifier), makes every devotion task
-- repeatable so a change of faith can re-earn from scratch, restricts the
-- Rank I idol hand-in to the Bazaar keeper (344200), and re-asserts that the
-- blessing buffs always stack.
--
-- Idempotent: plain UPDATEs.
-- ============================================================================

-- Disease must be single target even if 50018 already existed.
UPDATE `spells_new` SET `targettype`=5 WHERE `id`=50018;

-- Re-source the Damage Shield from Nettle Shield (5358) for databases where
-- 50022 predates v72 and still carries the Magician DS fire-resist component.
DELETE FROM `spells_new` WHERE `id`=50022;
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=5358;
UPDATE `tmp_spell` SET `id`=50022, `name`='Blessing: Damage Shield', `descnum`=910000009,
  `classes1`=255,`classes2`=255,`classes3`=255,`classes4`=255,`classes5`=255,`classes6`=255,
  `classes7`=255,`classes8`=255,`classes9`=255,`classes10`=255,`classes11`=255,`classes12`=255,
  `classes13`=255,`classes14`=255,`classes15`=255,`classes16`=255 WHERE `id`=5358;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- Agnostic naming (drop the deity qualifier on the idol chain).
UPDATE `items`             SET `Name` = 'Unfired Idol' WHERE `id`=9910022;
UPDATE `items`             SET `Name` = 'Fired Idol'   WHERE `id`=9910023;
UPDATE `tradeskill_recipe` SET `name` = 'Unfired Idol' WHERE `id`=992009;
UPDATE `tradeskill_recipe` SET `name` = 'Fired Idol'   WHERE `id`=992010;
UPDATE `tasks`
   SET `title`='Devotion to the Cause',
       `description`='Deliver a forged idol of the Cause to the Keeper of Devotion.'
 WHERE `id`=700017;

-- All devotion ranks are repeatable so a change of faith re-earns from scratch.
UPDATE `tasks` SET `repeatable`=1 WHERE `id` BETWEEN 700001 AND 700017;

-- Rank I idols are only accepted by the Bazaar keeper (344200).
UPDATE `task_activities` SET `npc_match_list`='344200' WHERE `taskid` BETWEEN 700001 AND 700017;

-- Ensure the blessing buffs always stack (safe if v72 already appended them).
UPDATE `rule_values`
SET `rule_value` = CONCAT(`rule_value`, ',50018,50019,50020,50021,50022')
WHERE `rule_name` = 'Spells:AlwaysStackSpells'
  AND `rule_value` NOT LIKE '%50022%';
