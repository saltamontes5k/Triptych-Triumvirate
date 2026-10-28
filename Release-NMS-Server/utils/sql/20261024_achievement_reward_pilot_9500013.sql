-- Pilot: make Explorer: Antonica Heartlands (9500013) a claimable reward.
--
-- Today 9500013 has two automatic reward_source_entries rows (9510004 = 2 AA,
-- 9510005 = 12,500 copper). They are granted at completion, so the achievement
-- window only ever opens the read-only preview lane: the "Select a Reward"
-- window appears with no Choose, because there is nothing left to claim.
--
-- This file moves those two grants into one single-option selectable set, so
-- the same window becomes the claimable lane (OP_AchievementReward 0x6411) and
-- the AA/coin are delivered when the player clicks Choose.
--
-- Set 9506001 sits above Trailblazer's 9506000 and below the 9507001+ block
-- reserved for the bulk conversion of the other 372 achievements.
--
-- Single-shot: reward_sets has a primary key, so a second run aborts on the
-- duplicate set insert and the transaction rolls back.
--
-- Apply:  mariadb --host=... --user=... --database=peq < <this file>
-- Revert: 20261024_achievement_reward_pilot_9500013_rollback.sql

SET NAMES utf8mb4;
START TRANSACTION;

-- 1. Set. Title is the achievement name so the claim tab reads naturally.
INSERT INTO reward_sets (reward_set_id, title, enabled)
VALUES (9506001, 'Explorer: Antonica Heartlands', 1);

-- 2. One selectable option. common_to_all must be 0: the loader rejects a set
--    that has no selectable option, and ClaimReward only matches non-common
--    options. Do not "simplify" this to common_to_all = 1.
INSERT INTO reward_options
  (reward_set_id, option_id, sequence, label, common_to_all, flags, enabled)
VALUES (9506001, 1, 1, 'Claim rewards', 0, 0, 1);

-- 3. Preserve the original grant order (2 AA first, then 12.5 platinum).
INSERT INTO reward_option_entries
  (reward_set_id, option_id, sequence, reward_id)
SELECT 9506001, 1, sequence, reward_id
FROM reward_source_entries
WHERE source_type = 1 AND source_id = 9500013;

-- 4. Map the achievement to the set.
INSERT INTO reward_sources (source_type, source_id, reward_set_id, enabled)
VALUES (1, 9500013, 9506001, 1);

-- 5. Suppress phantom claims for characters whose whole bundle is already in
--    the ledger. Only fully delivered pairs are seeded: a mixed pair must stay
--    claimable so the undelivered reward is retried instead of forfeited.
INSERT IGNORE INTO character_achievement_reward_selections
  (character_id, achievement_id, reward_set_id, selected_option_id,
   status, attempt_count, claimed_at)
SELECT l.character_id, l.achievement_id, 9506001, 1, 1, 1, MAX(l.granted_at)
FROM character_achievement_rewards l
JOIN reward_option_entries oe
  ON oe.reward_set_id = 9506001
 AND oe.option_id = 1
 AND oe.reward_id = l.reward_id
WHERE l.achievement_id = 9500013
GROUP BY l.character_id, l.achievement_id
HAVING SUM(l.status <> 1) = 0
   AND COUNT(*) = (
     SELECT COUNT(*) FROM reward_option_entries x
     WHERE x.reward_set_id = 9506001 AND x.option_id = 1
   );

-- 6. Retire the automatic entries. The catalog rejects a source that is both
--    automatic and selectable, so this must commit with step 4.
DELETE FROM reward_source_entries
WHERE source_type = 1 AND source_id = 9500013;

COMMIT;

-- Post-conditions. Expected: sets 1, options 1, entries 2, sources 1,
-- auto_rows_left 0, seeded_selections 0 (nobody has completed 9500013).
SELECT 'sets' AS what, COUNT(*) AS n FROM reward_sets WHERE reward_set_id = 9506001
UNION ALL SELECT 'options', COUNT(*) FROM reward_options WHERE reward_set_id = 9506001
UNION ALL SELECT 'entries', COUNT(*) FROM reward_option_entries WHERE reward_set_id = 9506001
UNION ALL SELECT 'sources', COUNT(*) FROM reward_sources WHERE source_type = 1 AND source_id = 9500013
UNION ALL SELECT 'auto_rows_left', COUNT(*) FROM reward_source_entries WHERE source_type = 1 AND source_id = 9500013
UNION ALL SELECT 'seeded_selections', COUNT(*) FROM character_achievement_reward_selections WHERE reward_set_id = 9506001;
