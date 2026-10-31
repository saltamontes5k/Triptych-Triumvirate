-- ============================================================================
-- Deity Blessings -- Rank 2 favor items: working clickies + themed icons
-- Date: 2026-10-31
--
-- The rank-2 favor items (976210-976244, authored in v113 as Spiderling Silk
-- 13099 clones) shipped with no click effect and Spiderling Silk's spider-web
-- icon. This migration gives every item a themed icon and the items that read
-- as clickies real click effects.
--
-- Icons are lifted from the stock Allakhazam 10th Anniversary originals that
-- already exist live (38487-38496, 38945-38949, 40411-40418, 42889-42899,
-- 60390-60394, 88366-88367), except Eye of Valor which gets the Gargoyle Eye
-- (10014) eye icon per design request.
--
-- Click effects reuse live spells. The originals' own clicky spells (7651/
-- 7653 "Use Ability" and the Dire* 17647-17654 set) are cosmetic no-ops --
-- their only payload is SE_CHA +1 -- so they are replaced: the blessing-kit
-- spells (44014/44015/44016/44017/44029), Dyn's Dizzying Draught (619), the
-- instant fire nuke Flame Lick (33661), the instant lifetap Lifedraw (6853),
-- and the authentic Call of Karana (1553, a level-16-capped charm) which is
-- the Karanite rod's real original spell.
--
-- All clickies are unlimited (maxcharges -1, clicktype 1) with a 60-second
-- per-item recast (recastdelay 60, recasttype -1 = RECAST_TYPE_UNLINKED_ITEM).
-- Unlimited charges protect favor tasks: the avatar scripts summon these with
-- charges=1 and never re-give, so a finite maxcharges would drain existing
-- instances to "out of charges" after one click. The True Karanite Rod keeps
-- a 5s cast so the charm is not instant.
--
-- Item data (icon/clicky) is server-sent from these rows, so existing holders
-- pick the fix up on relog/zone-in. No client file changes.
--
-- Idempotent: absolute-value UPDATEs only.
-- ============================================================================
SET NAMES utf8mb4;

-- ---- clickies -------------------------------------------------------------

-- Eye of Valor (Mithaniel Marr): gargoyle-eye icon, stun
UPDATE `items` SET
    `icon`=943, `clickeffect`=619, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=0, `casttime`=0, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id`=976210;

-- True Karanite Rod of Rainfall (Karana): authentic charm, 5s wind-up
UPDATE `items` SET
    `icon`=2454, `clickeffect`=1553, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=5000, `casttime`=5000, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id`=976211;

-- Flames of Solusek Ro: instant fire nuke
UPDATE `items` SET
    `icon`=1082, `clickeffect`=33661, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=0, `casttime`=0, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id`=976212;

-- Quellious' Wand of Tranquility: 10% self mend
UPDATE `items` SET
    `icon`=810, `clickeffect`=44016, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=0, `casttime`=0, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id`=976213;

-- Innoruuk's Needle of Hatred: instant lifetap
UPDATE `items` SET
    `icon`=2884, `clickeffect`=6853, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=0, `casttime`=0, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id`=976214;

-- Minor Trinket of Rodcet Nife: 4% self balm
UPDATE `items` SET
    `icon`=1882, `clickeffect`=44029, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=0, `casttime`=0, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id`=976216;

-- Cazic-Thule's three wands (his Fear/Disease/Root kit; the wands' original
-- "Use Ability" spell was a no-op)
UPDATE `items` SET
    `icon`=1550, `clickeffect`=44017, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=0, `casttime`=0, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id`=976222;

UPDATE `items` SET
    `icon`=1459, `clickeffect`=44014, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=0, `casttime`=0, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id`=976223;

UPDATE `items` SET
    `icon`=1282, `clickeffect`=44015, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=0, `casttime`=0, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id`=976224;

-- Bertoxxulous plague set (originals were no-op clickies; now real disease)
UPDATE `items` SET
    `icon`=1006, `clickeffect`=44014, `clicktype`=1, `clicklevel`=0, `clicklevel2`=0,
    `casttime_`=0, `casttime`=0, `recastdelay`=60, `recasttype`=-1, `maxcharges`=-1
WHERE `id` IN (976225, 976226, 976227, 976228, 976229);

-- ---- icons only -----------------------------------------------------------

UPDATE `items` SET `icon`=2461 WHERE `id`=976215; -- Bag of Mysterious Seeds (orig 38488)
UPDATE `items` SET `icon`=778  WHERE `id`=976217; -- Brell's Party Plans (orig 42899)
UPDATE `items` SET `icon`=778  WHERE `id`=976218; -- Book of Love Vol 1 (orig 60391)
UPDATE `items` SET `icon`=789  WHERE `id`=976219; -- Book of Love Vol 2 (orig 60392)
UPDATE `items` SET `icon`=865  WHERE `id`=976220; -- Book of Love Vol 3 (orig 60393)
UPDATE `items` SET `icon`=1019 WHERE `id`=976221; -- Strawberry-Jumjum Pie (orig 60394)
UPDATE `items` SET `icon`=775  WHERE `id`=976230; -- Blessed Barren Flounder (orig 40414)
UPDATE `items` SET `icon`=774  WHERE `id`=976231; -- Blessed Gunthak Mackerel (orig 40413)
UPDATE `items` SET `icon`=775  WHERE `id`=976232; -- Blessed Timorous Tuna (orig 40412)
UPDATE `items` SET `icon`=775  WHERE `id`=976233; -- Blessed Iceclad Cutlassfish (orig 40415)
UPDATE `items` SET `icon`=775  WHERE `id`=976234; -- Blessed Kunark Mullet (orig 40411)
UPDATE `items` SET `icon`=775  WHERE `id`=976235; -- Blessed 15 lb. Saltwater Tuna
UPDATE `items` SET `icon`=775  WHERE `id`=976236; -- Blessed Kedge Grunion
UPDATE `items` SET `icon`=819  WHERE `id`=976237; -- Blessed Ovate Jellyfish (orig 40418)
UPDATE `items` SET `icon`=790  WHERE `id`=976240; -- Silk Napkin (orig 42889)
UPDATE `items` SET `icon`=1013 WHERE `id`=976241; -- Unfired Plain Dining Plate (orig 42890)
UPDATE `items` SET `icon`=1013 WHERE `id`=976242; -- Plain Dining Plate (orig 42891)
UPDATE `items` SET `icon`=1939 WHERE `id`=976243; -- Kiola Nut Brew (orig 42892)
UPDATE `items` SET `icon`=785  WHERE `id`=976244; -- Celebratory Seafood Medley (orig 42893)
