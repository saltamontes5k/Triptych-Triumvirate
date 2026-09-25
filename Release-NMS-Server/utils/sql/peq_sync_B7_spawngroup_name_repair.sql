-- ============================================================================
-- B7 repair: spawngroup name collisions
-- Generated as part of the PEQ additive sync (see tools/db_additive_sync.py).
--
-- `spawngroup.name` is UNIQUE. Of the 1,079 upstream-only spawngroups, 28 could
-- not be inserted because a local group already carries the same name under a
-- different id. Their spawn2/spawnentry landed referencing the absent upstream id.
--
-- Of those 28:
--   * 15 (paw v1, lavastorm v1) carry a zone/version not present locally ->
--     re-point their spawn2/spawnentry at the existing same-name local group so
--     the revamped-version spawns become live.
--   * 13 are same-version duplicates of spawns the local group already has ->
--     delete the duplicate rows.
--
-- Additive-safe: every id touched here was absent locally before the sync, so
-- only rows inserted by this sync are modified/removed. No NMS content changes.
-- ============================================================================

-- 1. Re-point new-version spawn2 (paw/lavastorm v1) onto the existing local groups
UPDATE `spawn2` SET `spawngroupID` = CASE `spawngroupID`
 WHEN 287817 THEN 60005169 WHEN 287819 THEN 60005171
 WHEN 117754 THEN 60005153 WHEN 117757 THEN 60005154 WHEN 117761 THEN 60005155
 WHEN 117776 THEN 60005156 WHEN 117782 THEN 60005157 WHEN 117787 THEN 60005158
 WHEN 117885 THEN 60005159 WHEN 117968 THEN 60005160 WHEN 117969 THEN 60005161
 WHEN 117971 THEN 60005162 WHEN 117977 THEN 60005165 WHEN 117978 THEN 60005166
 WHEN 117979 THEN 60005167 END
WHERE `spawngroupID` IN (287817,287819,117754,117757,117761,117776,117782,117787,117885,117968,117969,117971,117977,117978,117979);

-- spawnentry: add any missing NPC links under the local id, then drop the dangling ones
UPDATE IGNORE `spawnentry` SET `spawngroupID` = CASE `spawngroupID`
 WHEN 287817 THEN 60005169 WHEN 287819 THEN 60005171
 WHEN 117754 THEN 60005153 WHEN 117757 THEN 60005154 WHEN 117761 THEN 60005155
 WHEN 117776 THEN 60005156 WHEN 117782 THEN 60005157 WHEN 117787 THEN 60005158
 WHEN 117885 THEN 60005159 WHEN 117968 THEN 60005160 WHEN 117969 THEN 60005161
 WHEN 117971 THEN 60005162 WHEN 117977 THEN 60005165 WHEN 117978 THEN 60005166
 WHEN 117979 THEN 60005167 END
WHERE `spawngroupID` IN (287817,287819,117754,117757,117761,117776,117782,117787,117885,117968,117969,117971,117977,117978,117979);
DELETE FROM `spawnentry` WHERE `spawngroupID` IN (287817,287819,117754,117757,117761,117776,117782,117787,117885,117968,117969,117971,117977,117978,117979);

-- 2. Drop same-version duplicate spawns (local group already carries them)
DELETE FROM `spawn2` WHERE `spawngroupID` IN
 (225,218,216,3288121,3288098,3288110,3288097,3288017,3288016,5419,985,3287852,3287853);
DELETE FROM `spawnentry` WHERE `spawngroupID` IN
 (225,218,216,3288121,3288098,3288110,3288097,3288017,3288016,5419,985,3287852,3287853);
