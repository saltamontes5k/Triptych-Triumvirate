-- Starvation debuff spell (2026-11-06) -- v355
-- Twin of the manifest v355 entry in
-- common/database/database_update_manifest_custom.cpp (keep in sync).
-- The nethack-style hunger clock (Custom:StarvationDeath,
-- zone/nms_starvation.cpp) needs a dedicated detrimental curse:
-- SE_MovementSpeed -75 crawl plus all seven stats -150, formula 6/3600
-- long duration that the server refreshes on every consumption tick.
-- Cloned from Sticky Icing (44025, already in-band and client-safe).
-- Band 44036 verified free (44000-44035 in use; client ceiling 45000).
-- Idempotent: guard the insert on the id being absent.
SET NAMES utf8mb4;

-- SE map (common/spdat.h): 3 = MovementSpeed, 4 = STR, 5 = DEX, 6 = AGI,
-- 7 = STA, 8 = INT, 9 = WIS, 10 = CHA. basediff 1000 = effectively
-- unresistable; the server reapplies every consumption tick regardless.
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=44025;
UPDATE `tmp_spell` SET
    `id`=44036,
    `name`='Starvation',
    `cast_on_you`='Hunger breaks your body. You can barely crawl.',
    `spell_fades`='',
    `buffdurationformula`=6,
    `buffduration`=3600,
    `effectid1`=3,  `effect_base_value1`=-75,
    `effectid2`=4,  `effect_base_value2`=-150,
    `effectid3`=5,  `effect_base_value3`=-150,
    `effectid4`=6,  `effect_base_value4`=-150,
    `effectid5`=7,  `effect_base_value5`=-150,
    `effectid6`=8,  `effect_base_value6`=-150,
    `effectid7`=9,  `effect_base_value7`=-150,
    `effectid8`=10, `effect_base_value8`=-150,
    `effectid9`=254, `effectid10`=254, `effectid11`=254, `effectid12`=254,
    `formula1`=100, `formula2`=100, `formula3`=100, `formula4`=100,
    `formula5`=100, `formula6`=100, `formula7`=100, `formula8`=100,
    `goodEffect`=0,
    `targettype`=5,
    `basediff`=1000,
    `nodispell`=1,
    `deleteable`=0,
    `classes1`=255, `classes2`=255, `classes3`=255, `classes4`=255,
    `classes5`=255, `classes6`=255, `classes7`=255, `classes8`=255,
    `classes9`=255, `classes10`=255, `classes11`=255, `classes12`=255,
    `classes13`=255, `classes14`=255, `classes15`=255, `classes16`=255
WHERE `id`=44025;
INSERT INTO `spells_new`
SELECT * FROM `tmp_spell`
WHERE NOT EXISTS (SELECT 1 FROM `spells_new` WHERE `id` = 44036);
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
