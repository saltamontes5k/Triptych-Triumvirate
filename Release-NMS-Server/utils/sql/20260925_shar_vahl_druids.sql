-- ============================================================================
-- 2026-09-25 Shar Vahl Druids: Dark Elf / Troll / Ogre / Iksar
-- ----------------------------------------------------------------------------
-- Druids of Iksar (128), Troll (9), Ogre (10) and Dark Elf (6) start in their
-- racial home city, where they die-loop. Move them to Shar Vahl (zone 155),
-- mirroring the existing Paladin/Ranger rows, and grant the shaman guild
-- summons (18551 Dar Khura Guild Summons) so they can begin the Shar Vahl
-- citizenship chain with Elder Spiritist Grawleh.
--
-- start_zones holds exactly one row per (player_choice, class, deity, race),
-- so this UPDATE replaces the home city (Neriak 41/384, Grobb 52, Oggok 49,
-- Cabilis 82) with Shar Vahl for all 17 deity rows per race. Coordinates are
-- the Vah Shir Shaman start/bind so they no longer loop.
--
-- Idempotent: the UPDATE is repeatable and the INSERTs are guarded.
-- ============================================================================

UPDATE `start_zones`
SET `zone_id`    = 155,
    `start_zone` = 155,
    `x`          = 100,
    `y`          = 55,
    `z`          = -259.5,
    `heading`    = 0,
    `bind_id`    = 155,
    `bind_x`     = 85,
    `bind_y`     = -1135,
    `bind_z`     = -188
WHERE `player_class` = 6
  AND `player_race` IN (6, 9, 10, 128);

INSERT INTO `starting_items`
    (`class_list`,`race_list`,`deity_list`,`zone_id_list`,`item_id`,`item_charges`,`inventory_slot`,`status`)
SELECT '6','6','0','155',18551,1,-1,0 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `starting_items`
    WHERE `item_id` = 18551 AND `class_list` = '6' AND `race_list` = '6' AND `zone_id_list` = '155'
);

INSERT INTO `starting_items`
    (`class_list`,`race_list`,`deity_list`,`zone_id_list`,`item_id`,`item_charges`,`inventory_slot`,`status`)
SELECT '6','9','0','155',18551,1,-1,0 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `starting_items`
    WHERE `item_id` = 18551 AND `class_list` = '6' AND `race_list` = '9' AND `zone_id_list` = '155'
);

INSERT INTO `starting_items`
    (`class_list`,`race_list`,`deity_list`,`zone_id_list`,`item_id`,`item_charges`,`inventory_slot`,`status`)
SELECT '6','10','0','155',18551,1,-1,0 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `starting_items`
    WHERE `item_id` = 18551 AND `class_list` = '6' AND `race_list` = '10' AND `zone_id_list` = '155'
);

INSERT INTO `starting_items`
    (`class_list`,`race_list`,`deity_list`,`zone_id_list`,`item_id`,`item_charges`,`inventory_slot`,`status`)
SELECT '6','128','0','155',18551,1,-1,0 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `starting_items`
    WHERE `item_id` = 18551 AND `class_list` = '6' AND `race_list` = '128' AND `zone_id_list` = '155'
);

-- The character-create city dropdown is populated from char_create_combinations
-- (world sends it to the client; CheckCharCreateInfoSoF validates against it).
-- Point those Druid combos at Shar Vahl so the client offers/returns zone 155.
-- PK is (race, class, deity, start_zone) and each combo has one row, so no
-- collision. 68 rows (17 deities x 4 races).
UPDATE `char_create_combinations`
SET `start_zone` = 155
WHERE `class` = 6 AND `race` IN (6, 9, 10, 128);
