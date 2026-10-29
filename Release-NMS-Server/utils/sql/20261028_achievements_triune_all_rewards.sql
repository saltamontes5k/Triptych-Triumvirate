-- Convert every remaining achievement-sourced copper (platinum) reward to a
-- flat 5 Triunes of Fate (alternate currency 6, item 46779): the entry-220
-- claimable sets and the Trailblazer coin purse. The 9540000+
-- classic-expansion block was converted earlier (entry 259). Task-sourced
-- reward rows are untouched. Originals snapshot into
-- nms_ach_copper_triune_backup for the rollback. Manifest twin: entry 260.
SET NAMES utf8mb4;
START TRANSACTION;

CREATE TABLE IF NOT EXISTS nms_ach_copper_triune_backup (
	reward_id INT UNSIGNED PRIMARY KEY,
	amount INT UNSIGNED NOT NULL,
	description VARCHAR(255) NOT NULL);

INSERT IGNORE INTO nms_ach_copper_triune_backup
SELECT r.`reward_id`, r.`amount`, r.`description`
FROM `rewards` r
JOIN `reward_option_entries` oe ON oe.`reward_id` = r.`reward_id`
JOIN `reward_sources` rs
	ON rs.`reward_set_id` = oe.`reward_set_id` AND rs.`source_type` = 1
WHERE r.`reward_type` = 3 AND r.`reward_id` < 9540000
AND NOT EXISTS (SELECT 1 FROM nms_ach_copper_triune_backup b WHERE b.`reward_id` = r.`reward_id`);

UPDATE `rewards` r
JOIN `reward_option_entries` oe ON oe.`reward_id` = r.`reward_id`
JOIN `reward_sources` rs
	ON rs.`reward_set_id` = oe.`reward_set_id` AND rs.`source_type` = 1
JOIN `achievements` a ON a.`id` = rs.`source_id`
SET r.`reward_type` = 4,
	r.`reward_data_id` = 6,
	r.`amount` = 5,
	r.`description` = CONCAT('5 Triunes of Fate for a ', a.`points`, '-point achievement')
WHERE r.`reward_type` = 3
	AND r.`reward_id` < 9540000;

COMMIT;
