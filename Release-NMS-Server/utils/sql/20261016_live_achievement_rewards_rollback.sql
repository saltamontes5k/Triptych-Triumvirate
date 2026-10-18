-- Rollback for 20261016_live_achievement_rewards.sql.
SET NAMES utf8mb4;
START TRANSACTION;
DELETE FROM reward_source_entries WHERE source_type=1 AND reward_id BETWEEN 9510000 AND 9510103;
DELETE FROM rewards WHERE reward_id BETWEEN 9510000 AND 9510103;
DELETE FROM titles WHERE title_set IN (301001, 301002);
COMMIT;
