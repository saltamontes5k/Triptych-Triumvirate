-- 2026-10-25 Quellious/Karana blessing-quest polish (from live testing)
-- 1) Nettle_Higglesbury (spawn2 3390216) + the an_angry_farmer group
--    (3390274) raised z 64 -> 74 (user-verified floor; 64 was still under
--    the misty terrain).
-- 2) New spell 44031 "Karanite Rainfall" — clone of Wake of Karana (1725)
--    with effectid1 = 528 (SE_StartRain, new engine SPA in spdat.h +
--    spell_effects.cpp). Self-cast that starts rain; requires the matching
--    line in the client spells_us.txt (patched in ClientFiles/, export/,
--    and the live client install, backups at *.bak-karanite).
-- 3) True Karanite Rod of Rainfall (976211): spider-web icon/clicky fixed —
--    icon 602 (Goldenrod), clickeffect 44031, instant, unlimited charges.
-- Quest/script behavior (code, not SQL): global/spells/1541.pl counts the
-- Quellious wand click on each miscreant (700181 acts 4/5) and depops them;
-- global/spells/44031.pl counts rod casts in the six "rain on X" zones
-- (700154 acts 2-7: Everfrost 30, Abysmal Sea 279, Gunthak 224,
-- Butcherblock 68, Scarlet Desert 175, PoK 202); mistythicket/an_angry_farmer.pl
-- takes the Strawberry-Jumjum Pie (700181 act 2, goalcount 10);
-- freportw/#Atler_Flamejabber.pl added (was missing entirely — that was the
-- "hail gives no dialogue" bug); Nettle script gained blessing dialogue.
-- Rollback: delete spell 44031; restore z=64, rod icon 782 / clickeffect -1.

DROP TABLE IF EXISTS nms_tmp_krain;
CREATE TABLE nms_tmp_krain AS SELECT * FROM spells_new WHERE id = 1725;
UPDATE nms_tmp_krain SET id = 44031, name = 'Karanite Rainfall', effectid1 = 528;
INSERT INTO spells_new SELECT * FROM nms_tmp_krain;
DROP TABLE IF EXISTS nms_tmp_krain;

UPDATE `spawn2` SET `z` = 74
WHERE `id` IN (3390216, 3390274) AND `zone` = 'misty' AND `z` < 74;

UPDATE `items` SET `icon` = 602, `clickeffect` = 44031, `casttime_` = 0, `maxcharges` = -1
WHERE `id` = 976211;
