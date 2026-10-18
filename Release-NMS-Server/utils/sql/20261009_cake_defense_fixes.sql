-- 121 (fix-pack 2, 2026-10-09): Cake Defense full active kit + test-round-2 fixes.
-- Idempotent; folded into the v121 manifest entry as well.
--   * Full active kit: cake-named AA lines binding the EXISTING DoD shroud
--     spells. Final kit per user (2026-10-09): Birthday Blowout (Gale Force
--     8328), Sugar Rush (Gift of Speed V 8294), Molasses Glaze (Lethargy I
--     7536), Stale Crust Aura (Malaise I 8300), Powdered Sugar Bolt (Mana
--     Bolt V 7780), Espresso Infusion (Pure Thought IV 8174), Food Coma
--     (Sleep II 7532), Angry Sprinkle Swarm (Swarm of Pain III 7547).
--     Removed by request: Angel Food Float, Crumb Sweep, Return to the
--     Bakery, Candle Glow. Passives intentionally not mirrored.
--   * Birthday Cake 25 stats matched to the live Air Elemental Illusionist 25
--     template (HP 510 / mana 883 / endurance 553).
--   * Adventurers get FleeingImmunity (special_abilities 21,1); the baker is
--     melee/aggro immune (19,1^24,1^25,1) so stray swings can't tag him.
--   * (Real-buff strip and icing re-assert live in the controller script.)

DELETE FROM `aa_rank_effects` WHERE `rank_id` BETWEEN 90303 AND 90314;
DELETE FROM `aa_ranks` WHERE `id` BETWEEN 90303 AND 90314;
DELETE FROM `aa_ability` WHERE `id` BETWEEN 90104 AND 90115;
DELETE FROM `db_str` WHERE `id` BETWEEN 90104 AND 90115;
DELETE FROM `shroud_abilities` WHERE `progression` = 'Confections' AND `aa_id` BETWEEN 90104 AND 90115;

INSERT INTO `aa_ability` (`id`,`name`,`category`,`classes`,`races`,`drakkin_heritage`,`deities`,`status`,`type`,`charges`,`grant_only`,`first_rank_id`,`enabled`,`reset_on_death`,`auto_grant_enabled`) VALUES
(90104,'Birthday Blowout',-1,65535,65535,127,131071,0,1,0,0,90303,1,0,0),
(90105,'Sugar Rush',-1,65535,65535,127,131071,0,1,0,0,90304,1,0,0),
(90106,'Molasses Glaze',-1,65535,65535,127,131071,0,1,0,0,90305,1,0,0),
(90108,'Stale Crust Aura',-1,65535,65535,127,131071,0,1,0,0,90307,1,0,0),
(90109,'Powdered Sugar Bolt',-1,65535,65535,127,131071,0,1,0,0,90308,1,0,0),
(90110,'Espresso Infusion',-1,65535,65535,127,131071,0,1,0,0,90309,1,0,0),
(90112,'Food Coma',-1,65535,65535,127,131071,0,1,0,0,90311,1,0,0),
(90114,'Angry Sprinkle Swarm',-1,65535,65535,127,131071,0,1,0,0,90313,1,0,0);

INSERT INTO `aa_ranks` (`id`,`upper_hotkey_sid`,`lower_hotkey_sid`,`title_sid`,`desc_sid`,`cost`,`level_req`,`spell`,`spell_type`,`recast_time`,`expansion`,`prev_id`,`next_id`) VALUES
(90303,90104,90104,90104,90104,1,1,8328,0,120,0,-1,-1),
(90304,90105,90105,90105,90105,1,1,8294,0,2,0,-1,-1),
(90305,90106,90106,90106,90106,1,1,7536,0,9,0,-1,-1),
(90307,90108,90108,90108,90108,1,1,8300,0,10,0,-1,-1),
(90308,90109,90109,90109,90109,1,1,7780,0,6,0,-1,-1),
(90309,90110,90110,90110,90110,1,1,8174,0,2,0,-1,-1),
(90311,90112,90112,90112,90112,1,1,7532,0,6,0,-1,-1),
(90313,90114,90114,90114,90114,1,1,7547,0,6,0,-1,-1);

INSERT INTO `shroud_abilities` (`progression`,`min_level`,`kind`,`aa_id`,`display_order`) VALUES
('Confections',1,'active',90104,3),
('Confections',1,'active',90105,4),
('Confections',1,'active',90106,5),
('Confections',1,'active',90108,6),
('Confections',1,'active',90109,7),
('Confections',1,'active',90110,8),
('Confections',1,'active',90112,9),
('Confections',1,'active',90114,10);

INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
(90104,1,'Birthday Blowout'),
(90104,2,'Confection'),
(90104,3,'Blowout'),
(90104,4,'Unleash a shockwave of party candles, stunning everything nearby. (All Classes)'),
(90105,1,'Sugar Rush'),
(90105,2,'Confection'),
(90105,3,'Rush'),
(90105,4,'Pure sugar in the bloodstream: 25% haste for 30 minutes. (All Classes)'),
(90106,1,'Molasses Glaze'),
(90106,2,'Confection'),
(90106,3,'Glaze'),
(90106,4,'Coat your enemy in molasses, slowing their attack speed by 35%. (All Classes)'),
(90108,1,'Stale Crust Aura'),
(90108,2,'Confection'),
(90108,3,'Aura'),
(90108,4,'A crust of staleness lowers the target''s poison, magic, fire and cold resistances. (All Classes)'),
(90109,1,'Powdered Sugar Bolt'),
(90109,2,'Confection'),
(90109,3,'Bolt'),
(90109,4,'Hurl a bolt of superheated powdered sugar at your enemy. (All Classes)'),
(90110,1,'Espresso Infusion'),
(90110,2,'Confection'),
(90110,3,'Infusion'),
(90110,4,'A connoisseur''s roast: steady mana regeneration for 15 minutes. (All Classes)'),
(90112,1,'Food Coma'),
(90112,2,'Confection'),
(90112,3,'Coma'),
(90112,4,'So dull the target falls asleep where it stands. (All Classes)'),
(90114,1,'Angry Sprinkle Swarm'),
(90114,2,'Confection'),
(90114,3,'Swarm'),
(90114,4,'A swarm of angry sprinkles: damage every tick for 5 ticks. (All Classes)');

UPDATE `shrouds` SET `hp` = 510, `mana` = 883, `endurance` = 553 WHERE `id` = 500;

UPDATE `npc_types` SET `special_abilities` = '21,1' WHERE `id` IN (1520001810,1520001811,1520001812);
UPDATE `npc_types` SET `special_abilities` = '19,1^24,1^25,1' WHERE `id` = 1520001801;

-- 2026-10-09 follow-up: the cake AA rows were inserted with upper/lower
-- hotkey_sid = -1. The RoF2 client renders an AA hotbutton from those two
-- dbstr sids, so every cake ability dropped onto a hotbar came out blank
-- (the guide content and the older 90300 row all set hotkey_sid = title_sid).
-- Point each rank's hotkey sids at its own name string.
UPDATE `aa_ranks` SET `upper_hotkey_sid` = `title_sid`, `lower_hotkey_sid` = `title_sid`
WHERE `id` BETWEEN 90300 AND 90313 AND `title_sid` BETWEEN 90101 AND 90114;

-- Cake form is 3x the original model size (2.0 -> 6.0).
UPDATE `shrouds` SET `size` = 6.0 WHERE `id` = 500;
