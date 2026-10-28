-- Roll back the bulk achievement reward conversion (manifest entry 187).
--
-- Restores reward_source_entries for every set in the 9507001+ block and deletes
-- that block. Selections recorded against those sets are deleted with it, so a
-- claim made while the sets were live is not presented again; the delivered
-- rewards stay in character_achievement_rewards, so the restored automatic path
-- will not grant them twice.

SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO reward_source_entries (source_type, source_id, sequence, reward_id)
SELECT 1, s.source_id, oe.sequence, oe.reward_id
FROM reward_option_entries oe
JOIN reward_sources s
  ON s.source_type = 1 AND s.reward_set_id = oe.reward_set_id
WHERE oe.reward_set_id BETWEEN 9507001 AND 9507999
  AND oe.option_id = 1;

DELETE FROM character_achievement_reward_selections
WHERE reward_set_id BETWEEN 9507001 AND 9507999;

DELETE FROM reward_sources
WHERE source_type = 1 AND reward_set_id BETWEEN 9507001 AND 9507999;
DELETE FROM reward_option_entries WHERE reward_set_id BETWEEN 9507001 AND 9507999;
DELETE FROM reward_options WHERE reward_set_id BETWEEN 9507001 AND 9507999;
DELETE FROM reward_sets WHERE reward_set_id BETWEEN 9507001 AND 9507999;

COMMIT;

SELECT 'auto_rows' AS what, COUNT(*) AS n FROM reward_source_entries WHERE source_type = 1
UNION ALL SELECT 'sources', COUNT(*) FROM reward_sources WHERE source_type = 1
UNION ALL SELECT 'sets', COUNT(*) FROM reward_sets WHERE reward_set_id BETWEEN 9507001 AND 9507999;
