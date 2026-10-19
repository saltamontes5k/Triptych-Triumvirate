-- Dire Charm AA descriptions in db_str (source for client dbstr_us.txt).
--
-- 145/4  AA 46 (enchanter) casts spell 43990: a plain SE_Charm with max level 66,
--        unresistable, permanent (buffdurationformula 50). The old text claimed
--        "below 67 or Light Blue", but 43990 takes the generic level-check path,
--        not the 2759/2760/2761 dire-charm special case.
-- 54014  AA 20046 (cross-class enc) casts 2761.
-- 54015  AA 20317 (cross-class dru) casts 2760.
-- 54013  AA 20318 (cross-class nec) casts 2759.
-- 54013/54014/54015 had only type 1 (name), so the AA window showed
-- "db unknown" for their description pane.
--
-- For 2759/2760/2761 the server bypasses max_value (see Mob::IsImmuneToSpell):
-- charm is allowed when the target is level 46 or below, or cons light blue or
-- lower. That is the rule described below.
--
-- Twin of manifest entry 168. The client file is regenerated with:
--   export_client_files.exe dbstr
-- and copied to the client's dbstr_us.txt / Resources/dbstr_us.txt.

INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
  (145, 4, 'Permanently charms a single NPC up to level 66. The charm is unresistable, lasts until it breaks, the target dies, or you zone, and cannot be used while an animation is active. 15 minute reuse. /alt activate 46'),
  (54014, 4, 'Permanently charms a single NPC that is level 46 or below, or that cons light blue or lower to you. The charm is unresistable, lasts until it breaks, the target dies, or you zone, and cannot be used while an animation is active. /alt activate 20046'),
  (54015, 4, 'Permanently charms a single animal that is level 46 or below, or that cons light blue or lower to you. The charm is unresistable, lasts until it breaks, the target dies, or you zone, and cannot be used while another druid pet is active. /alt activate 20317'),
  (54013, 4, 'Permanently charms a single undead that is level 46 or below, or that cons light blue or lower to you. The charm is unresistable, lasts until it breaks, the target dies, or you zone, and cannot be used while another necromancer pet is active. /alt activate 20318')
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`);
