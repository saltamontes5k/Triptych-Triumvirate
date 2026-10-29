-- 2026-10-29 merc broker rewire: split the species catalogs across vendors +
-- invisible contract brokers so no shop exceeds the MAX_MERC=100 entry cap
-- (the shop handler silently refuses more).
--
-- Seasonal (peq_halloween-gated spawns beside Hadya Ware):
--   Hadya (27, 99): Dark Elf pirate rogue+cleric, Gnome pirate wizard+cleric,
--     Human pirate tank+wizard, Ogre pirate tank+rogue, Swinetor tank
--   Broker Ahlanna (28, 99): Swinetor healer/melee/caster, Skeleton x4,
--     Shissar tank/healer
--   Broker Dorva (29, 22): Shissar melee/caster
-- Non-seasonal (beside Facesmasher Brog):
--   Brog (25, 99): Minotaur/Siren/Scrykin/Satyr originals + Bazu tank,
--     Gelidran melee, Ikaav healer, Pyrilen healer+caster
--   Broker Gex (30, 99): Goblin x4, Nihil x4, Aviak tank+healer
--   Broker Rul (31, 88): Aviak melee/caster, Dragorn x4, Gelidran healer
-- Scarecrow liaison (26) unchanged. Twin generator: none (hand-written;
-- line ladder = (cat,tier) IN ((1,1)..(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2))).
-- Rollback: reverse DELETEs + re-run 20261028_merc_species_contracts.sql.

DELETE FROM `merc_merchant_template_entries`
 WHERE `merc_merchant_template_id` IN (25, 27, 28, 29, 30, 31);
DELETE FROM `merc_merchant_entries` WHERE `merchant_id` BETWEEN 1500200100 AND 1500200103;
DELETE FROM `merc_merchant_templates` WHERE `merc_merchant_template_id` IN (28, 29, 30, 31);
DELETE FROM `spawn2` WHERE `id` BETWEEN 45020092 AND 45020095;
DELETE FROM `spawnentry` WHERE `spawngroupID` BETWEEN 60020085 AND 60020088;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 60020085 AND 60020088;
DELETE FROM `npc_types` WHERE `id` BETWEEN 1500200100 AND 1500200103;

UPDATE `merc_merchant_templates` SET `name` = 'Seasonal Contracts - Hadya Ware'
 WHERE `merc_merchant_template_id` = 27;

INSERT INTO `merc_merchant_templates`
 (`merc_merchant_template_id`,`name`,`qglobal`) VALUES
 (28, 'Halloween Contracts - Broker Ahlanna', ''),
 (29, 'Halloween Contracts - Broker Dorva', ''),
 (30, 'Monster Contracts - Broker Gex', ''),
 (31, 'Monster Contracts - Broker Rul', '');

INSERT INTO `merc_merchant_entries`
 (`merc_merchant_template_id`,`merchant_id`) VALUES
 (28, 1500200100), (29, 1500200101), (30, 1500200102), (31, 1500200103);

-- Invisible (race 127) class-71 brokers; con indifferent (faction 0).
INSERT INTO `npc_types`
 (`id`,`name`,`lastname`,`level`,`race`,`class`,`texture`,`helmtexture`,
  `size`,`gender`,`hp`,`findable`,`npc_faction_id`) VALUES
 (1500200100, 'Contract_Broker_Ahlanna', 'Halloween Contract Broker', 80, 127, 71, 0, 0, 0, 0, 7200, 1, 0),
 (1500200101, 'Contract_Broker_Dorva', 'Halloween Contract Broker', 80, 127, 71, 0, 0, 0, 0, 7200, 1, 0),
 (1500200102, 'Monster_Contract_Broker_Gex', 'Monster Contract Broker', 80, 127, 71, 0, 0, 0, 0, 7200, 1, 0),
 (1500200103, 'Monster_Contract_Broker_Rul', 'Monster Contract Broker', 80, 127, 71, 0, 0, 0, 0, 7200, 1, 0);

INSERT INTO `spawngroup`
 (`id`,`name`,`spawn_limit`,`dist`,`max_x`,`min_x`,`max_y`,`min_y`,
  `delay`,`mindelay`,`despawn`,`despawn_timer`,`wp_spawns`) VALUES
 (60020085, 'poknowledge60020085', 0, 0, 0, 0, 0, 0, 0, 15000, 0, 100, 0),
 (60020086, 'poknowledge60020086', 0, 0, 0, 0, 0, 0, 0, 15000, 0, 100, 0),
 (60020087, 'poknowledge60020087', 0, 0, 0, 0, 0, 0, 0, 15000, 0, 100, 0),
 (60020088, 'poknowledge60020088', 0, 0, 0, 0, 0, 0, 0, 15000, 0, 100, 0);

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
 (60020085, 1500200100, 100), (60020086, 1500200101, 100),
 (60020087, 1500200102, 100), (60020088, 1500200103, 100);

INSERT INTO `spawn2`
 (`id`,`spawngroupID`,`zone`,`version`,`x`,`y`,`z`,`heading`,
  `respawntime`,`variance`,`pathgrid`,`_condition`,`cond_value`,`animation`,
  `min_expansion`,`max_expansion`,`content_flags`) VALUES
 (45020092, 60020085, 'poknowledge', 0, -16.0, -47.0, -156.625, 300, 640, 0, 0, 0, 0, 0, -1, -1, 'peq_halloween'),
 (45020093, 60020086, 'poknowledge', 0, 12.0, -47.0, -156.625, 60, 640, 0, 0, 0, 0, 0, -1, -1, 'peq_halloween'),
 (45020094, 60020087, 'poknowledge', 0, 1084.0, -447.0, -122.875, 220, 640, 0, 0, 0, 0, 0, -1, -1, NULL),
 (45020095, 60020088, 'poknowledge', 0, 1084.0, -475.0, -122.875, 140, 640, 0, 0, 0, 0, 0, -1, -1, NULL);

-- ---- catalog wiring (11-entry ladders per line) ----

-- Hadya (27): seasonal pirates (existing catalogs) + Swinetor tank
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=6 AND MS.class_id=9
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=6 AND MS.class_id=2
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=12 AND MS.class_id=12
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=12 AND MS.class_id=2
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=1 AND MS.class_id=1
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=1 AND MS.class_id=12
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=10 AND MS.class_id=1
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=10 AND MS.class_id=9
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=696 AND MS.class_id=1
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

-- Broker Ahlanna (28): Swinetor healer/melee/caster, Skeleton x4, Shissar tank/healer
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 28, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=696 AND MS.class_id=2
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 28, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=696 AND MS.class_id=9
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 28, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=696 AND MS.class_id=12
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 28, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=60 AND MS.class_id=1
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 28, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=60 AND MS.class_id=2
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 28, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=60 AND MS.class_id=9
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 28, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=60 AND MS.class_id=12
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 28, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=217 AND MS.class_id=1
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 28, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=217 AND MS.class_id=2
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

-- Broker Dorva (29): Shissar melee/caster
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 29, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=217 AND MS.class_id=9
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 29, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=217 AND MS.class_id=12
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

-- Hadya (27) Ogre melee line (authored by 20261029_ogre_melee_line.sql / v268):
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=10 AND MS.class_id=9
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

-- Brog (25): originals + Bazu tank, Gelidran melee, Ikaav healer, Pyrilen healer+caster
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 25, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE (MY.race_id, MS.class_id) IN ((574,1),(564,2),(495,12),(529,9),(409,1),(417,9),(394,2),(411,2),(411,12))
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

-- Broker Gex (30): Goblin x4, Nihil x4, Aviak tank
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 30, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE (MY.race_id, MS.class_id) IN ((433,1),(433,2),(433,9),(433,12),(385,1),(385,2),(385,9),(385,12),(13,1))
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

-- Broker Rul (31): Aviak healer/melee/caster, Dragorn x4, Gelidran healer
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 31, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE (MY.race_id, MS.class_id) IN ((13,2),(13,9),(13,12),(413,1),(413,2),(413,9),(413,12),(417,2))
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

-- verification: per-group counts and per-liaison totals
SELECT E.merc_merchant_template_id g, COUNT(*) c,
       MAX(ME.merchant_id) liaison
FROM merc_merchant_template_entries E
 LEFT JOIN merc_merchant_entries ME ON ME.merc_merchant_template_id=E.merc_merchant_template_id
WHERE E.merc_merchant_template_id IN (25,26,27,28,29,30,31)
GROUP BY E.merc_merchant_template_id;
