-- Revert the 9500013 reward pilot: restore the automatic entry rows and drop
-- the selectable set. Rewards already delivered stay in
-- character_achievement_rewards, so the restored automatic path will not grant
-- them twice; a claim made while the set was live keeps its grant and simply
-- stops being presented.

SET NAMES utf8mb4;
START TRANSACTION;

-- 1. Recreate the automatic rows from the single option (sequence preserved).
INSERT INTO reward_source_entries (source_type, source_id, sequence, reward_id)
SELECT 1, 9500013, sequence, reward_id
FROM reward_option_entries
WHERE reward_set_id = 9506001 AND option_id = 1;

-- 2. Drop every selection row that points at the pilot set.
DELETE FROM character_achievement_reward_selections
WHERE reward_set_id = 9506001;

-- 3. Remove the mapping and the definitions.
DELETE FROM reward_sources
WHERE source_type = 1 AND source_id = 9500013;
DELETE FROM reward_option_entries WHERE reward_set_id = 9506001;
DELETE FROM reward_options WHERE reward_set_id = 9506001;
DELETE FROM reward_sets WHERE reward_set_id = 9506001;

COMMIT;

SELECT 'auto_rows' AS what, COUNT(*) AS n FROM reward_source_entries WHERE source_type = 1 AND source_id = 9500013
UNION ALL SELECT 'sources', COUNT(*) FROM reward_sources WHERE source_type = 1 AND source_id = 9500013
UNION ALL SELECT 'sets', COUNT(*) FROM reward_sets WHERE reward_set_id = 9506001;
