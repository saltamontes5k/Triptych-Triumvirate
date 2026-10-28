-- Convert the remaining achievement rewards to claimable single-option sets.
--
-- Every achievement that still auto-grants (source_type = 1 rows in
-- reward_source_entries) and has no selectable set yet becomes one set with one
-- selectable option. The achievement window then opens the claimable lane
-- (OP_AchievementReward 0x6411) with a working Choose instead of the read-only
-- preview, and rewards are delivered on claim.
--
-- Already-covered achievements are skipped by the reward_sources guard, so this
-- is safe after the 9500013 pilot (set 9506001) and after 9500040 (set 9506000).
-- New set ids are 9507001.. by source_id order; the block is reserved and must
-- never be reused for different content once a player has claim rows.
--
-- Exit conditions are fail-closed: the assertion step below inserts a duplicate
-- primary key when a converted option would load with no enabled reward, which
-- aborts the transaction instead of shipping content that would make every zone
-- refuse to start (AchievementManager::Load -> zone/main.cpp "refusing to start").
--
-- Twin of common/database/database_update_manifest_custom.cpp entry 220.
-- Rollback: 20261024_achievement_reward_claims_rollback.sql

SET NAMES utf8mb4;
START TRANSACTION;

-- Deterministic achievement -> set mapping. One temporary table is the single
-- source of the ids: every later statement joins it, so the numbering can never
-- diverge between sets, options, entries, sources and seeded selections.
DROP TEMPORARY TABLE IF EXISTS tmp_ach_reward_sets;
CREATE TEMPORARY TABLE tmp_ach_reward_sets (
  achievement_id INT(10) UNSIGNED NOT NULL,
  set_id         INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (achievement_id),
  UNIQUE KEY tmp_ach_reward_sets_set (set_id)
) ENGINE=InnoDB;

INSERT INTO tmp_ach_reward_sets (achievement_id, set_id)
SELECT e.source_id, 9507000 + ROW_NUMBER() OVER (ORDER BY e.source_id)
FROM (SELECT DISTINCT source_id FROM reward_source_entries WHERE source_type = 1) e
JOIN achievements a ON a.id = e.source_id
WHERE NOT EXISTS (
  SELECT 1 FROM reward_sources s
  WHERE s.source_type = 1 AND s.source_id = e.source_id
);

-- 1. Sets. Title is the achievement name so the claim tab reads naturally.
INSERT INTO reward_sets (reward_set_id, title, enabled)
SELECT m.set_id, LEFT(a.name, 255), 1
FROM tmp_ach_reward_sets m
JOIN achievements a ON a.id = m.achievement_id;

-- 2. One selectable option per set. common_to_all must be 0: the loader rejects
--    a set with no selectable option and ClaimReward only matches non-common
--    options, so 1 here would make the zone fail to load the catalog.
INSERT INTO reward_options
  (reward_set_id, option_id, sequence, label, common_to_all, flags, enabled)
SELECT m.set_id, 1, 1, 'Claim rewards', 0, 0, 1
FROM tmp_ach_reward_sets m;

-- 3. Move the grants, preserving their original order.
INSERT INTO reward_option_entries
  (reward_set_id, option_id, sequence, reward_id)
SELECT m.set_id, 1, e.sequence, e.reward_id
FROM reward_source_entries e
JOIN tmp_ach_reward_sets m ON m.achievement_id = e.source_id
WHERE e.source_type = 1;

-- 4. Map each achievement to its set.
INSERT INTO reward_sources (source_type, source_id, reward_set_id, enabled)
SELECT 1, m.achievement_id, m.set_id, 1
FROM tmp_ach_reward_sets m;

-- 5. Fail closed if any converted option would have no enabled, structurally
--    valid reward. The duplicate primary key aborts the transaction.
INSERT INTO reward_sets (reward_set_id, title, enabled)
SELECT m.set_id, 'ASSERTION FAILED: empty reward option', 1
FROM tmp_ach_reward_sets m
WHERE NOT EXISTS (
  SELECT 1
  FROM reward_option_entries oe
  JOIN rewards r ON r.reward_id = oe.reward_id AND r.enabled = 1
  WHERE oe.reward_set_id = m.set_id
    AND oe.option_id = 1
    AND r.amount > 0
    AND r.reward_type <= 5
    AND (r.reward_type NOT IN (0, 4, 5) OR r.reward_data_id > 0)
    AND NOT (r.reward_type = 1 AND r.reward_data_id > 1)
)
LIMIT 1;

-- 6. Suppress phantom claims for characters whose whole bundle is already in
--    the ledger. Only fully delivered pairs are seeded: a mixed pair must stay
--    claimable so the undelivered reward is retried instead of forfeited.
INSERT IGNORE INTO character_achievement_reward_selections
  (character_id, achievement_id, reward_set_id, selected_option_id,
   status, attempt_count, claimed_at)
SELECT l.character_id, l.achievement_id, m.set_id, 1, 1, 1, MAX(l.granted_at)
FROM character_achievement_rewards l
JOIN tmp_ach_reward_sets m ON m.achievement_id = l.achievement_id
JOIN reward_option_entries oe
  ON oe.reward_set_id = m.set_id
 AND oe.option_id = 1
 AND oe.reward_id = l.reward_id
JOIN (
  SELECT reward_set_id, COUNT(*) AS option_entries
  FROM reward_option_entries
  WHERE option_id = 1
  GROUP BY reward_set_id
) c ON c.reward_set_id = m.set_id
GROUP BY l.character_id, l.achievement_id, m.set_id
HAVING SUM(l.status <> 1) = 0
   AND COUNT(*) = MAX(c.option_entries);

-- 7. Retire the automatic entries. The catalog rejects a source that is both
--    automatic and selectable, so this must commit with step 4.
DELETE e
FROM reward_source_entries e
JOIN tmp_ach_reward_sets m ON m.achievement_id = e.source_id
WHERE e.source_type = 1;

DROP TEMPORARY TABLE IF EXISTS tmp_ach_reward_sets;

COMMIT;

-- Post-conditions. Expected on the current live DB: sets 372, options 372,
-- entries 726, sources 372, auto_rows_left 0, seeded_selections 174,
-- empty_options 0.
SELECT 'sets' AS what, COUNT(*) AS n FROM reward_sets WHERE reward_set_id BETWEEN 9507001 AND 9507999
UNION ALL SELECT 'options', COUNT(*) FROM reward_options WHERE reward_set_id BETWEEN 9507001 AND 9507999
UNION ALL SELECT 'entries', COUNT(*) FROM reward_option_entries WHERE reward_set_id BETWEEN 9507001 AND 9507999
UNION ALL SELECT 'sources', COUNT(*) FROM reward_sources WHERE source_type = 1 AND reward_set_id BETWEEN 9507001 AND 9507999
UNION ALL SELECT 'auto_rows_left', COUNT(*) FROM reward_source_entries WHERE source_type = 1
UNION ALL SELECT 'seeded_selections', COUNT(*) FROM character_achievement_reward_selections WHERE reward_set_id BETWEEN 9507001 AND 9507999
UNION ALL SELECT 'empty_options', COUNT(*) FROM (
  SELECT o.reward_set_id FROM reward_options o
  WHERE o.reward_set_id BETWEEN 9507001 AND 9507999 AND o.option_id = 1
    AND NOT EXISTS (
      SELECT 1 FROM reward_option_entries oe JOIN rewards r ON r.reward_id = oe.reward_id AND r.enabled = 1
      WHERE oe.reward_set_id = o.reward_set_id AND oe.option_id = 1)
) z;
