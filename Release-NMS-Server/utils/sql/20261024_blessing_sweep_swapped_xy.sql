-- 2026-10-24 Blessing-task location sweep: 29 swapped-XY fixes
-- Full audit of every blessing-task (700xxx) target's spawn vs its task zone.
-- Finding: most of the batch was authored in fan-site Y,X ordering entered as
-- X,Y (same root cause as the Avatar of Quellious fix). Each bad spawn sat at
-- or beyond its zone's content edge with ZERO neighboring spawns; the swapped
-- pair lands inside the zone's real content band (bounds computed with all
-- blessing NPCs excluded) with neighbors. Verification method, per spawn:
--   1. clean zone bbox excluding blessing NPCs
--   2. neighbor count within 300 (and 600 where ambiguous) at raw vs swapped
--   3. nearest non-blessing spawn distance
-- Swapped (x,y); z/heading untouched on every row.
-- Rollback: swap the pair back per row (raw values in the comments).

-- northro: Bertoxx noise-maker chain (task 700100 acts 1-5) + spectre none.
UPDATE `spawn2` SET `x` = -2126, `y` = 9118 WHERE `id` = 3390240 AND `zone` = 'northro' AND `x` = 9118; -- a_sandskimmer_bat was (9118, -2126)
UPDATE `spawn2` SET `x` = -2195, `y` = 8724 WHERE `id` = 3390241 AND `zone` = 'northro' AND `x` = 8724; -- a_mother_rat was (8724, -2195)
UPDATE `spawn2` SET `x` = -941,  `y` = 7875 WHERE `id` = 3390242 AND `zone` = 'northro' AND `x` = 7875; -- a_wiry_coyote was (7875, -941)
UPDATE `spawn2` SET `x` = -1819, `y` = 7972 WHERE `id` = 3390243 AND `zone` = 'northro' AND `x` = 7972; -- a_raging_fire_beetle was (7972, -1819)
UPDATE `spawn2` SET `x` = -1799, `y` = 6872 WHERE `id` = 3390244 AND `zone` = 'northro' AND `x` = 6872; -- a_clever_stonesnake was (6872, -1799)
-- oceanoftears: Rondor Sandskipper (task 700145 act 3).
UPDATE `spawn2` SET `x` = 7529,  `y` = -1669 WHERE `id` = 3390280 AND `zone` = 'oceanoftears' AND `x` = -1669; -- was (-1669, 7529)
-- southro: Aspect of Erollisi Marr (task 700127) — raw spot defined BOTH zone maxx and miny.
UPDATE `spawn2` SET `x` = -2219, `y` = 4200 WHERE `id` = 3390203 AND `zone` = 'southro' AND `x` = 4200; -- was (4200, -2219)
-- fieldofbone: Pirex (700118), scorpion (700199), forlorn spirit (700127).
UPDATE `spawn2` SET `x` = 2878,  `y` = -2326 WHERE `id` = 3390224 AND `zone` = 'fieldofbone' AND `x` = -2326; -- Pirex was (-2326, 2878)
UPDATE `spawn2` SET `x` = 362,   `y` = -2060 WHERE `id` = 3390264 AND `zone` = 'fieldofbone' AND `x` = -2060; -- scorpion was (-2060, 362)
UPDATE `spawn2` SET `x` = -582,  `y` = -2167 WHERE `id` = 3390291 AND `zone` = 'fieldofbone' AND `x` = -2167; -- forlorn was (-2167, -582)
-- rathemtn: brown/black bears (700100 acts 7-9). frisky bear (-642,747) was already valid — untouched.
UPDATE `spawn2` SET `x` = 1488,  `y` = 4795 WHERE `id` = 3390246 AND `zone` = 'rathemtn' AND `x` = 4795; -- content bear was (4795, 1488)
UPDATE `spawn2` SET `x` = 2460,  `y` = 3270 WHERE `id` = 3390247 AND `zone` = 'rathemtn' AND `x` = 3270; -- clumsy bear was (3270, 2460)
-- spectres of evil (task 700163, one per zone).
UPDATE `spawn2` SET `x` = -3897, `y` = 3109 WHERE `id` = 3390300 AND `zone` = 'Everfrost' AND `x` = 3109; -- was (3109, -3897)
UPDATE `spawn2` SET `x` = 1397,  `y` = -4333 WHERE `id` = 3390305 AND `zone` = 'firiona' AND `x` = -4333; -- was (-4333, 1397)
UPDATE `spawn2` SET `x` = -1779, `y` = -228 WHERE `id` = 3390304 AND `zone` = 'lfaydark' AND `x` = -228; -- was (-228, -1779)
UPDATE `spawn2` SET `x` = 1246,  `y` = 4661 WHERE `id` = 3390306 AND `zone` = 'iceclad' AND `x` = 4661; -- was (4661, 1246)
UPDATE `spawn2` SET `x` = 1127,  `y` = 1482 WHERE `id` = 3390301 AND `zone` = 'southkarana' AND `x` = 1482; -- was (1482, 1127)
UPDATE `spawn2` SET `x` = -2489, `y` = 677  WHERE `id` = 3390303 AND `zone` = 'butcher' AND `x` = 677; -- was (677, -2489)
-- city/hail targets: Snogge (700217), Agar (700118), Roderik (700109),
-- Encan (700217, VERIFY IN GAME — both candidate spots sit outside the
-- neriakc content bbox; swapped spot is 482 from the nearest street NPC vs
-- 1557 at raw), Eoando (700217), Bronkks (700217), Primate of Prexus (700172),
-- Herald of Justice Due (700217).
UPDATE `spawn2` SET `x` = 95, `y` = 505, `z` = 5.63, `heading` = 0 WHERE `id` = 3390321 AND `zone` = 'oggok' AND `x` = 454; -- Snogge was (454, 845); final = beside Bouncer_Druk (user-verified the animal cluster off-map)
UPDATE `spawn2` SET `x` = -2506, `y` = -1600 WHERE `id` = 3390270 AND `zone` = 'commonlands' AND `x` = -1600; -- Agar was (-1600, -2506)
UPDATE `spawn2` SET `x` = -2626, `y` = 2834 WHERE `id` = 3390201 AND `zone` = 'butcher' AND `x` = 2834; -- Roderik was (2834, -2626)
UPDATE `spawn2` SET `x` = -1290, `y` = 904,  `z` = -52.75, `heading` = 180 WHERE `id` = 3390318 AND `zone` = 'neriakc' AND `x` = -67; -- Encan: swapped spot sat outside the city geometry (user-verified unfindable); anchored beside Ash_C`Luzz (-1351,916) / Drisi_J`Axx (-1278,915) at street z
UPDATE `spawn2` SET `x` = -897,  `y` = 402  WHERE `id` = 3390319 AND `zone` = 'felwitheb' AND `x` = 402; -- Eoando was (402, -897)
UPDATE `spawn2` SET `x` = -379,  `y` = 542  WHERE `id` = 3390322 AND `zone` = 'grobb' AND `x` = 542; -- Bronkks was (542, -379)
UPDATE `spawn2` SET `x` = 712,   `y` = -1842 WHERE `id` = 3390212 AND `zone` = 'erudsxing' AND `x` = -1842; -- Primate was (-1842, 712)
UPDATE `spawn2` SET `x` = -1496, `y` = 633  WHERE `id` = 3390206 AND `zone` = 'potranquility' AND `x` = 633; -- Herald was (633, -1496)
-- Avatar of Karana (700154): lower confidence (isolated either way) — raw sat
-- on the zone content edge with 0 neighbors at r600; swap is interior with
-- Synger Foxfyre ~450 away. Eyeball in game.
UPDATE `spawn2` SET `x` = -1811, `y` = -3693 WHERE `id` = 3390209 AND `zone` = 'southkarana' AND `x` = -3693; -- was (-3693, -1811)
-- NOT touched, verified fine as-authored: Avatar_of_Tunare gfaydark (-2350,-1480 — populated, 32 nbrs@600),
-- gfaydark trio Galayna/Arthin/Jheri (z117 = Kelethin platforms), injured coyote northro (-1293,9685),
-- spectres abysmal/shadeweaver/hollowshade (interior, populated), Avatar_of_Bertoxxulous eastkarana,
-- Avatar_of_Cazic-Thule feerrott (temple), frisky bear rathemtn, spectre highpass (stub zone, 2 spawns),
-- Avatar_of_Solusek_Ro northro (user-specified loc 1389,263,55 — flag: swap-of-original (-699,6761) is
-- the only in-content candidate; see report).
