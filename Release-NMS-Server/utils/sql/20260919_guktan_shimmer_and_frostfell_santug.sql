-- Uklo's Magic (quest 2605) + Santug Claugg seasonal fix
-- Applied to live `peq` 2026-09-19. Idempotent.
--
-- 1) The corrupted gnome explorer (gukbottom spawn2 9847) was suppressed by
--    spawn2_disabled row 198, so `a spectral shimmer` never popped and the
--    Fused Sword Blade (67013) was unobtainable. Re-enable the spawn point.
-- 2) Santug Claugg newbie-city spawns had content_flags = NULL and spawned
--    year-round. Flag them `frostfell`, and clear the 16 conflicting
--    spawn2_disabled workaround rows so they can spawn during the event.
--    (rathemtn 148701 was never disabled, so it is only flagged.)
SET NAMES utf8mb4;
START TRANSACTION;

-- 1) corrupted gnome explorer -> a spectral shimmer (Lower Guk)
UPDATE spawn2_disabled SET disabled = 0 WHERE spawn2_id = 9847;

-- 2a) gate all newbie-city Santug Claugg spawns behind the Frostfell flag
UPDATE spawn2 SET content_flags = 'frostfell'
WHERE id IN (148697,148698,148699,148700,148701,148702,148703,148704,148705,
             148706,148707,148708,148709,148710,148711,148763,148764);

-- 2b) clear the conflicting spawn2_disabled workaround so the flag is the single gate
UPDATE spawn2_disabled SET disabled = 0
WHERE spawn2_id IN (148697,148698,148699,148700,148702,148703,148704,148705,
                    148706,148707,148708,148709,148710,148711,148763,148764);

COMMIT;

-- After applying: #repop gukbottom and the affected city zones (or restart them).
-- Off-season the `frostfell` content flag (content_flags.flag_name='frostfell')
-- is enabled=0, so the Santug rows are filtered out by ContentFilterCriteria.
