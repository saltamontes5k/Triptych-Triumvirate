-- Swap the classic-expansion achievement coin reward (points/2 platinum) for
-- a flat 5 Triunes of Fate (alternate currency 6, item 46779). Scope: the
-- 206 claimable sets of 20261025_achievements_expansion_classic (rewards
-- 9540000-9540411). AA components untouched. Manifest twin: entry 259.
SET NAMES utf8mb4;
START TRANSACTION;

UPDATE `rewards` r
JOIN `reward_option_entries` oe ON oe.`reward_id` = r.`reward_id`
JOIN `reward_sources` rs
	ON rs.`reward_set_id` = oe.`reward_set_id` AND rs.`source_type` = 1
JOIN `achievements` a ON a.`id` = rs.`source_id`
SET r.`reward_type` = 4,
	r.`reward_data_id` = 6,
	r.`amount` = 5,
	r.`description` = CONCAT('5 Triunes of Fate for a ', a.`points`, '-point achievement')
WHERE r.`reward_id` BETWEEN 9540000 AND 9540411
	AND r.`reward_type` = 3;

COMMIT;

-- Expected post-conditions: 0 copper rows left in the block, 206 alternate-
-- currency rows crediting currency 6 at amount 5.
SELECT SUM(reward_type = 3) AS copper_left,
	SUM(`reward_type` = 4 AND `reward_data_id` = 6 AND `amount` = 5) AS triune_rows
FROM `rewards`
WHERE `reward_id` BETWEEN 9540000 AND 9540411;
