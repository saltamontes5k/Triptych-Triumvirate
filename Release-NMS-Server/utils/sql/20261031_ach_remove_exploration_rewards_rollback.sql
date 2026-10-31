-- Rollback for 20261031_ach_remove_exploration_rewards.sql: restore the
-- per-zone (exploration) claimable reward sets, their sources and options,
-- and any in-flight selections from the nms_ach_exploration_rewards_*
-- backups, and reseed the retired Achievements:ExplorationRewards rule row.
-- Only meaningful with the pre-removal server binary: the post-removal
-- binary refuses exploration claims in code (QueueRewards, SendRewardDisplay,
-- RestorePendingRewardSelection, ClaimReward) regardless of the rule.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT IGNORE INTO reward_sets
SELECT * FROM nms_ach_exploration_rewards_sets;
INSERT IGNORE INTO reward_options
SELECT * FROM nms_ach_exploration_rewards_options;
INSERT IGNORE INTO reward_option_entries
SELECT * FROM nms_ach_exploration_rewards_option_entries;
INSERT IGNORE INTO reward_sources
SELECT * FROM nms_ach_exploration_rewards_sources;
INSERT IGNORE INTO character_achievement_reward_selections
SELECT * FROM nms_ach_exploration_rewards_selections;

INSERT IGNORE INTO rule_values (ruleset_id, rule_name, rule_value, notes) VALUES
	(1, 'Achievements:ExplorationRewards', 'true',
	'Retired 2026-10-31 with the exploration reward removal; restored by rollback');

COMMIT;
