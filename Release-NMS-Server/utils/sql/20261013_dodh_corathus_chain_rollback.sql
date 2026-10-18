-- Rollback of v154 (utils/sql/20261013_dodh_corathus_chain.sql).
-- Removes Scavenger Hunting (505762) and the caster Parts for Bellfast
-- variant (505763), and restores the PEQ pre-migration recipe entries:
-- 938046/938047 both made 33296 from 3x scrap 32731, and 1520007506 did not
-- exist. Player progress on the two tasks is deleted with them (accepted
-- task rows die with the task definition).

DELETE FROM `task_activities` WHERE `taskid` IN (505762, 505763);
DELETE FROM `tasks`           WHERE `id`      IN (505762, 505763);

DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` = 1520007506;
DELETE FROM `tradeskill_recipe`         WHERE `id`         = 1520007506;

DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` IN (938046, 938047);

-- PEQ original: 3x scrap 32731 -> 33296, twice over.
INSERT INTO `tradeskill_recipe_entries`
  (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
  (938046, 32731, 0, 0, 1, 0, 0),
  (938046, 32731, 0, 0, 1, 0, 0),
  (938046, 32731, 0, 0, 1, 0, 0),
  (938046, 33296, 1, 0, 0, 0, 0),
  (938047, 32731, 0, 0, 1, 0, 0),
  (938047, 32731, 0, 0, 1, 0, 0),
  (938047, 32731, 0, 0, 1, 0, 0),
  (938047, 32731, 0, 0, 1, 0, 0),
  (938047, 33296, 1, 0, 0, 0, 0);
