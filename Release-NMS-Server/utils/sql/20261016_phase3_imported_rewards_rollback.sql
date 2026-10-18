-- Rollback for the imported-set Phase 3 rewards.
SET NAMES utf8mb4;
START TRANSACTION;
DELETE FROM reward_source_entries WHERE source_type=1 AND source_id NOT BETWEEN 9500000 AND 9699999;
DELETE FROM rewards WHERE reward_id BETWEEN 9530000 AND 9530023;
DELETE FROM titles WHERE title_set BETWEEN 301003 AND 301011;
COMMIT;
