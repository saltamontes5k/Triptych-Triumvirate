-- SoD Kithicor theme faction correction.
-- Hand-maintained data fix (not generator output); the emitting generators
-- (sod_content/gen_vendors.py, sod_content/gen_progression2.py) were
-- patched to stay in sync.
-- Twin content of manifest entry '20261012_sod_kithicor_faction' (v144).
--
-- The v110 vendor pass set faction_reward = 1222 (Cirtan, Bayle's Herald)
-- on every SoD task, and v111's Bahgresh-path tasks inherited it. The
-- Kithicor partisans belong to Herald Silla's war (raspersrealm
-- themeKithicor: 'every quest in the theme raises this faction'). Flip the
-- Kithicor set to 1223; faction_amount keeps the group-task +150 convention.
--
-- Necklaces: Army of Light Pendant 41118 (Scout Talendien 456002) and
-- Army of Obliteration Medallion 41119 (Scout Zialdiruun 456003) are
-- granted by oldkithicor/456002.pl and 456003.pl -- no item rows change.

UPDATE `tasks` SET `faction_reward` = 1223
WHERE `id` IN (303010,303011,303012,303074,303075,303076);
