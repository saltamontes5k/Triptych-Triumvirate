-- ============================================================================
-- 2026-10-30  TBS Blacksail aug line wiring (v287)
--
-- Twin of ManifestEntry .version = 287 in
-- common/database/database_update_manifest_custom.cpp (keep in sync).
--
-- Makes "Jonas Dagmire's Skeletal Hand" (tasks 625010-625048, Blacksail
-- Smugglers faction 1169) completable end to end:
--
--   1. Doubloon economy: the 27 bone-bearing tasks pay 10 Doubloons
--      (alternate_currency 10 -> item 79910) via the task currency reward
--      path. Halon Griere sells the Bone Joint Compound (79918) for 10
--      Doubloons; nothing anywhere paid Doubloons out before this.
--   2. Faction wiring: the 15 quest NPCs (13 givers + Halon Griere +
--      Merchant Wain + Shental Darkmind) carry npc_faction 1520000063
--      (primaryfaction 1169) so they con on Blacksail Smugglers standing;
--      killing a member lowers 1169 by 50 (Allakhazam-documented behavior
--      for Halon/Wain/Shental); the Bone Joint Compound row gets the live
--      Indifferent gate (faction_required 0). A fresh player starts at -100
--      and needs ~10 task completions to buy the first container.
--   3. Task completability:
--      - 625043: Lock of Siren Hair (28520) had zero droppers in buriedsea
--        (Sirens Grotto only) -- added a 10% lootdrop to the five
--        buriedsea siren/drowned loottables (93545/93582/93585/93588/93589).
--      - 625038: Fire Totem Piece (54748) dropped at 0.015-0.026% -- raised
--        to 15% (sea turtles, lootdrop 112698) and 35% (Tidewater
--        elementalists, 112787); the water piece is a 75.7% named drop.
--      - 625027/625034: buriedsea spawn supply was under the kill goalcounts
--        (17 Sharpeye recruits vs gc 20; 6 each tigers/raptors/basilisks vs
--        gc 10) -- 26 new spawns (recruits +8, tigers +6, raptors +6,
--        basilisks +6), matching the existing respawntime 640 / version 0.
--      - 625014 package/bill items are handled by quest scripts
--        (Murderous_Mal.pl hands out 88232; Silverlip_Slim.pl in barren
--        hands back 88233) -- no DB rows needed for that one.
--   4. Recipe cleanup: the leftover duplicate Jonas set 991100/991103-991106
--      (991101/991102 were overwritten by unrelated recipes) is disabled;
--      the live set 992000-992006 gets a real tradeskill (69 = blacksmithing;
--      combines already worked -- component matching ignores the field).
--   5. jardelshook leftovers: zone jardelshook is unreachable (no waypoints,
--      no zone_points) and carried 132 stale PEQ spawns (spawngroups
--      95146-95277, including 4 dead duplicate quest givers) -- removed.
--      The 2026-10-16 Echo spawn (spawngroup 1520004232) is kept.
--
-- Idempotency: applies once via the manifest check (task 625010 sentinel).
-- Re-running the file by hand is safe for every UPDATE/DELETE; the INSERT
-- blocks use reserved id bands and will duplicate-key on re-run.
--
-- Rollback: utils/sql/20261030_tbs_blacksail_augline_wiring_rollback.sql
-- restores sections 1-4. Section 5 is a permanent cleanup (restore source:
-- release-peq.zip jardelshook spawns).
-- ============================================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- ---------------------------------------------------------------------------
-- 1. Doubloon funding: 10 Doubloons on each of the 27 bone-bearing tasks
--    (9 Jardel's Hook single-bone tasks + 18 island bone tasks).
-- ---------------------------------------------------------------------------
UPDATE `tasks` SET `reward_point_type` = 10, `reward_points` = 10 WHERE `id` IN (
    625010, 625011, 625012, 625013, 625014, 625015, 625016, 625017, 625018,
    625021, 625022, 625023, 625026, 625027, 625028, 625031, 625032, 625033,
    625036, 625037, 625038, 625041, 625042, 625043, 625046, 625047, 625048
);

-- ---------------------------------------------------------------------------
-- 2. Faction wiring: quest NPCs onto Blacksail Smugglers (1169).
-- ---------------------------------------------------------------------------
UPDATE `npc_types` SET `npc_faction_id` = 1520000063 WHERE `id` IN (
    422004,  -- #Trophy_Hunter_Locke  (Monkey Rock)
    422009,  -- Shental_Darkmind
    422012,  -- Merchant_Wain         (Maiden's Grave)
    422019,  -- Brynden_Snow          (Suncrest Ridge)
    423079,  -- Bilgewater_Bill       (Jardel's Hook)
    423091,  -- Murderous_Mal         (Jardel's Hook)
    423105,  -- Scurv-acious_Bella_Straw (Jardel's Hook)
    423107,  -- #Logan_Grimm          (Blacksail Folly)
    423122,  -- Darius_Blythe         (Jardel's Hook)
    423124,  -- #Halon_Griere         (vendor)
    423144,  -- Johnny_the_Black_Crow (Redfeather Isle)
    423146,  -- Rickan                (Redfeather Isle)
    423148,  -- #Sid_Hacke            (Jardel's Hook / Deadbone Reef)
    423152,  -- Captain_Pete          (Maiden's Grave)
    423900   -- Pirate_Symthe         (Maiden's Grave)
);

-- Killing a Blacksail Smugglers member lowers Blacksail Smugglers by 50.
INSERT INTO `npc_faction_entries` (`npc_faction_id`, `faction_id`, `value`, `npc_value`, `temp`) VALUES
    (1520000063, 1169, -50, 0, 0);

-- Live Indifferent gate on the Bone Joint Compound row only; the rest of
-- Halon's stock keeps the -1100 no-gate sentinel.
UPDATE `merchantlist` SET `faction_required` = 0 WHERE `merchantid` = 423124 AND `item` = 79918;

-- ---------------------------------------------------------------------------
-- 3a. 625043: Lock of Siren Hair (28520) droppers in buriedsea.
--     One new lootdrop per loottable, 10% chance, appended at probability
--     100 / droplimit 1 so normal loot is untouched.
-- ---------------------------------------------------------------------------
INSERT INTO `lootdrop` (`id`, `name`) VALUES
    (1520009420, 'jdas_siren_hair_enticer'),
    (1520009421, 'jdas_siren_hair_pirate'),
    (1520009422, 'jdas_siren_hair_razorfin'),
    (1520009423, 'jdas_siren_hair_tormentor'),
    (1520009424, 'jdas_siren_hair_spitfire');

INSERT INTO `lootdrop_entries` (`lootdrop_id`, `item_id`, `item_charges`, `equip_item`, `chance`, `disabled_chance`, `trivial_min_level`, `trivial_max_level`, `multiplier`, `npc_min_level`, `npc_max_level`, `min_expansion`, `max_expansion`, `content_flags`, `content_flags_disabled`) VALUES
    (1520009420, 28520, 1, 0, 10, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (1520009421, 28520, 1, 0, 10, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (1520009422, 28520, 1, 0, 10, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (1520009423, 28520, 1, 0, 10, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL),
    (1520009424, 28520, 1, 0, 10, 0, 0, 0, 1, 0, 0, -1, -1, NULL, NULL);

INSERT INTO `loottable_entries` (`loottable_id`, `lootdrop_id`, `multiplier`, `droplimit`, `mindrop`, `probability`) VALUES
    (93582, 1520009420, 1, 1, 0, 100),  -- a_siren_enticer x3
    (93545, 1520009421, 1, 1, 0, 100),  -- a_drowned_pirate x2
    (93585, 1520009422, 1, 1, 0, 100),  -- a_siren_razorfin
    (93589, 1520009423, 1, 1, 0, 100),  -- a_siren_tormentor
    (93588, 1520009424, 1, 1, 0, 100);  -- a_siren_spitfire

-- ---------------------------------------------------------------------------
-- 3b. 625038: Fire Totem Piece (54748) drop chances.
-- ---------------------------------------------------------------------------
UPDATE `lootdrop_entries` SET `chance` = 15 WHERE `lootdrop_id` = 112698 AND `item_id` = 54748;
UPDATE `lootdrop_entries` SET `chance` = 35 WHERE `lootdrop_id` = 112787 AND `item_id` = 54748;

-- ---------------------------------------------------------------------------
-- 3c. 625027 / 625034: spawn supply in buriedsea. New spawngroups
--     1900000100-1900000125, spawn2 1520028400-1520028425, one spawn each,
--     respawntime 640 / version 0 to match the existing population.
-- ---------------------------------------------------------------------------
INSERT INTO `spawngroup` (`id`, `name`, `spawn_limit`, `dist`, `max_x`, `min_x`, `max_y`, `min_y`, `delay`, `mindelay`, `despawn`, `despawn_timer`, `wp_spawns`) VALUES
    (1900000100, 'blacksail_aug_rec1', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000101, 'blacksail_aug_rec2', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000102, 'blacksail_aug_rec3', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000103, 'blacksail_aug_rec4', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000104, 'blacksail_aug_rec5', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000105, 'blacksail_aug_rec6', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000106, 'blacksail_aug_rec7', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000107, 'blacksail_aug_rec8', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000108, 'blacksail_aug_tig1', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000109, 'blacksail_aug_tig2', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000110, 'blacksail_aug_tig3', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000111, 'blacksail_aug_tig4', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000112, 'blacksail_aug_tig5', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000113, 'blacksail_aug_tig6', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000114, 'blacksail_aug_rap1', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000115, 'blacksail_aug_rap2', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000116, 'blacksail_aug_rap3', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000117, 'blacksail_aug_rap4', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000118, 'blacksail_aug_rap5', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000119, 'blacksail_aug_rap6', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000120, 'blacksail_aug_bas1', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000121, 'blacksail_aug_bas2', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000122, 'blacksail_aug_bas3', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000123, 'blacksail_aug_bas4', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000124, 'blacksail_aug_bas5', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0),
    (1900000125, 'blacksail_aug_bas6', 0, 0, 0, 0, 0, 0, 45000, 15000, 0, 100, 0);

INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`, `condition_value_filter`, `min_time`, `max_time`, `min_expansion`, `max_expansion`, `content_flags`, `content_flags_disabled`) VALUES
    -- Sharpeye recruits +8 (task 625027, gc 20): 17 -> 25
    (1900000100, 423227, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000101, 423238, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000102, 423244, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000103, 423308, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000104, 423313, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000105, 423317, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000106, 423320, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000107, 423327, 100, 1, 0, 0, -1, -1, NULL, NULL),
    -- Firemaw tigers +6 (task 625034 act 0, gc 10): 6 -> 12
    (1900000108, 423085, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000109, 423085, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000110, 423101, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000111, 423101, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000112, 423136, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000113, 423136, 100, 1, 0, 0, -1, -1, NULL, NULL),
    -- Sharpfang raptors +6 (task 625034 act 1, gc 10): 6 -> 12
    (1900000114, 423071, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000115, 423071, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000116, 423071, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000117, 423100, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000118, 423100, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000119, 423100, 100, 1, 0, 0, -1, -1, NULL, NULL),
    -- Darkclaw basilisks +6 (task 625034 act 2, gc 10): 6 -> 12
    (1900000120, 423114, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000121, 423114, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000122, 423128, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000123, 423128, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000124, 423180, 100, 1, 0, 0, -1, -1, NULL, NULL),
    (1900000125, 423180, 100, 1, 0, 0, -1, -1, NULL, NULL);

INSERT INTO `spawn2` (`id`, `spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`) VALUES
    -- Sharpeye recruits: inside the eastern pocket (x ~1090-1550, y ~4350-4890)
    (1520028400, 1900000100, 'buriedsea', 0, 1180.000, 4420.000, 318.000, 511, 640),
    (1520028401, 1900000101, 'buriedsea', 0, 1120.000, 4520.000, 312.000, 511, 640),
    (1520028402, 1900000102, 'buriedsea', 0, 1500.000, 4400.000, 314.000, 380, 640),
    (1520028403, 1900000103, 'buriedsea', 0, 1130.000, 4740.000, 316.000, 511, 640),
    (1520028404, 1900000104, 'buriedsea', 0, 1125.000, 4765.000, 312.000, 160, 640),
    (1520028405, 1900000105, 'buriedsea', 0, 1290.000, 4745.000, 309.000, 511, 640),
    (1520028406, 1900000106, 'buriedsea', 0, 1285.000, 4790.000, 312.000, 220, 640),
    (1520028407, 1900000107, 'buriedsea', 0, 1340.000, 4860.000, 319.000,  95, 640),
    -- Firemaw tigers: main band (x -4400..-2600, y -1500..70)
    (1520028408, 1900000108, 'buriedsea', 0, -2960.000, -1380.000, 315.000, 511, 640),
    (1520028409, 1900000109, 'buriedsea', 0, -4050.000, -300.000, 309.000, 511, 640),
    (1520028410, 1900000110, 'buriedsea', 0, -3150.000, -1290.000, 320.000, 511, 640),
    (1520028411, 1900000111, 'buriedsea', 0, -4180.000, -100.000, 308.000, 511, 640),
    (1520028412, 1900000112, 'buriedsea', 0, -3400.000, -1200.000, 311.000, 511, 640),
    (1520028413, 1900000113, 'buriedsea', 0, -3100.000, -1350.000, 318.000, 511, 640),
    -- Sharpfang raptors: main band
    (1520028414, 1900000114, 'buriedsea', 0, -2800.000, -1270.000, 309.000, 511, 640),
    (1520028415, 1900000115, 'buriedsea', 0, -3350.000, -1220.000, 309.000, 511, 640),
    (1520028416, 1900000116, 'buriedsea', 0, -4100.000, -200.000, 309.000, 511, 640),
    (1520028417, 1900000117, 'buriedsea', 0, -2950.000, -1180.000, 338.000, 511, 640),
    (1520028418, 1900000118, 'buriedsea', 0, -3900.000, -250.000, 340.000, 511, 640),
    (1520028419, 1900000119, 'buriedsea', 0, -4150.000, -130.000, 339.000, 511, 640),
    -- Darkclaw basilisks: main band
    (1520028420, 1900000120, 'buriedsea', 0, -3050.000, -1200.000, 330.000, 511, 640),
    (1520028421, 1900000121, 'buriedsea', 0, -3990.000, -30.000, 306.500, 511, 640),
    (1520028422, 1900000122, 'buriedsea', 0, -3200.000, -1450.000, 306.500, 511, 640),
    (1520028423, 1900000123, 'buriedsea', 0, -4000.000, -70.000, 310.000, 511, 640),
    (1520028424, 1900000124, 'buriedsea', 0, -4250.000, 45.000, 305.000, 511, 640),
    (1520028425, 1900000125, 'buriedsea', 0, -4300.000, 50.000, 305.000, 511, 640);

-- ---------------------------------------------------------------------------
-- 4. Recipe cleanup: disable the clobbered duplicate Jonas set; give the
--    live set a real tradeskill (69 = blacksmithing).
-- ---------------------------------------------------------------------------
UPDATE `tradeskill_recipe` SET `enabled` = 0 WHERE `id` IN (991100, 991103, 991104, 991105, 991106);
UPDATE `tradeskill_recipe` SET `tradeskill` = 69 WHERE `id` BETWEEN 992000 AND 992006;

-- ---------------------------------------------------------------------------
-- 5. jardelshook leftovers: 132 stale PEQ spawns (spawngroups 95146-95277),
--    including 4 dead duplicate quest givers. The zone is unreachable and
--    the Echo spawn (spawngroup 1520004232) is kept.
-- ---------------------------------------------------------------------------
DELETE se FROM `spawnentry` se JOIN `spawngroup` sg ON se.spawngroupID = sg.id WHERE sg.id BETWEEN 95146 AND 95277;
DELETE s2 FROM `spawn2` s2 WHERE s2.zone = 'jardelshook' AND s2.spawngroupID BETWEEN 95146 AND 95277;
DELETE FROM `spawngroup` WHERE `id` BETWEEN 95146 AND 95277;

COMMIT;
