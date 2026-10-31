-- ============================================================================
-- Deity Blessings -- Rank 2 favor items: quest-faithful clicky corrections
-- Date: 2026-10-31
--
-- Follows 20261031_blessing_favor_clicky_icons.sql (v295). Four effects are
-- corrected to match what each favor quest actually calls for, and the two
-- clickies whose real action has no spell-SPA equivalent become scripted
-- clickies handled by global_player.pl (EVENT_ITEM_CLICK_CAST_CLIENT):
--
--   976211 True Karanite Rod of Rainfall -> 44031 "Karanite Rainfall"
--     (existing flavor spell, never cast: the script calls quest::rain(1) to
--     start real rain; no weather SPA exists in this spell set)
--   976214 Innoruuk's Needle of Hatred -> 44035 "Instill Hatred" (new no-op
--     label; the script adds 200 hate via AddToHateList, matching the
--     Innoruuk blessing bundle's {hate=>200}; no usable hate-add spell)
--   976213 Quellious' Wand of Tranquility -> 1541 Wake of Tranquility
--     (the AE pacify the quest content called for)
--   976216 Minor Trinket of Rodcet Nife -> 17 Light Healing (the favor is
--     "Healing Touch": mend wounded creatures; this is the tool for it)
--
-- The Bertoxxulous plague set keeps Blessing: Disease (44014) from v295 and
-- the Eye of Valor keeps Dyn's Dizzying Draught (619). Icons, unlimited
-- charges (maxcharges -1) and the 60s per-item recast are unchanged from
-- v295 and are NOT re-stated here.
--
-- After applying: export-client-files.bat <client> (new spell 44035), then
-- #hotfix (or a zone restart) so zones pick up the item/spell shared memory,
-- and #reload quests global for global_player.pl. Idempotent.
-- ============================================================================
SET NAMES utf8mb4;

-- ---- item corrections -------------------------------------------------------

UPDATE `items` SET `clickeffect`=44031, `casttime_`=0, `casttime`=0 WHERE `id`=976211;
UPDATE `items` SET `clickeffect`=44035, `casttime_`=0, `casttime`=0 WHERE `id`=976214;
UPDATE `items` SET `clickeffect`=1541 WHERE `id`=976213;
UPDATE `items` SET `clickeffect`=17   WHERE `id`=976216;

-- ---- new label spell: 44035 "Instill Hatred" --------------------------------
-- No-op (effect 254), instant, classless, self -- it exists so the needle's
-- item examine and click identity read correctly; the script does the work.

DELETE FROM `db_str`     WHERE `id`=910000014 AND `type`=6;
DELETE FROM `spells_new` WHERE `id`=44035;

DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=12;
UPDATE `tmp_spell` SET
    `id`=44035, `name`='Instill Hatred', `descnum`=910000014,
    `cast_on_you`='Hatred stirs in your heart.', `cast_on_other`=' eyes burn with hatred.',
    `targettype`=6, `goodEffect`=1, `range`=100, `aoerange`=0,
    `cast_time`=0, `recovery_time`=0, `recast_time`=0, `mana`=0,
    `buffdurationformula`=0, `buffduration`=0, `AEDuration`=0,
    `effectid1`=254, `effect_base_value1`=0, `effect_limit_value1`=0, `max1`=0, `formula1`=100,
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

INSERT INTO `db_str` (`id`,`type`,`value`) VALUES
    (910000014, 6, 'Stokes the hatred of your target, turning its wrath upon you.');
