-- Rollback for 20261028_achievements_triune_all_rewards.sql / manifest
-- entry 260. Restores the snapshotted platinum rewards. Claimed Triunes
-- stay delivered (character_alt_currency is not touched).
SET NAMES utf8mb4;
START TRANSACTION;

UPDATE `rewards` r
JOIN nms_ach_copper_triune_backup b ON b.`reward_id` = r.`reward_id`
SET r.`reward_type` = 3,
	r.`reward_data_id` = 0,
	r.`amount` = b.`amount`,
	r.`description` = b.`description`;

DROP TABLE nms_ach_copper_triune_backup;

COMMIT;
