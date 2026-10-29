-- Rollback for 20261028_achievements_expansion_triune_rewards.sql and
-- manifest entry 259. Restores points/2 platinum coin rewards (amount in
-- copper) for the classic-expansion claimable sets. Claimed Triunes stay
-- delivered; character_alt_currency is not touched.
SET NAMES utf8mb4;
START TRANSACTION;

UPDATE rewards r
JOIN reward_option_entries oe ON oe.reward_id = r.reward_id
JOIN reward_sources rs
	ON rs.reward_set_id = oe.reward_set_id AND rs.source_type = 1
JOIN achievements a ON a.id = rs.source_id
SET r.reward_type = 3,
	r.reward_data_id = 0,
	r.amount = a.points * 500,
	r.description = CONCAT(a.points / 2, ' platinum for a ', a.points, '-point achievement')
WHERE r.reward_id BETWEEN 9540000 AND 9540411
	AND r.reward_type = 4
	AND r.reward_data_id = 6
	AND r.amount = 5;


COMMIT;
