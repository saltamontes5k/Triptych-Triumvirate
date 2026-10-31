-- Retire the per-zone (exploration) achievement rewards: every achievement
-- whose enabled criteria are all ZoneEnter (event_type 5) loses its
-- selectable reward set (298 achievements / 178 claimable sets). Zone-enter
-- achievements still track, complete, and award points. NOT touched: the
-- expansion traveler metas (Ruins of Kunark Explorer 200090, Scars of
-- Velious Explorer 300050, Shadows of Luclin Explorer 400050, Planes of
-- Power Explorer 500050), Trailblazer (9500040), and the Norrathian
-- Explorer title chain (9600255 -> title 301001): none of those are
-- zone-enter achievements. The Achievements:ExplorationRewards rule is
-- retired with the feature (world also deletes the orphaned rule_values row
-- at boot). Purged rows snapshot into the nms_ach_exploration_rewards_*
-- tables for the rollback. Manifest twin: entry 292.
SET NAMES utf8mb4;
START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS tmp_exploration_achievements;
CREATE TEMPORARY TABLE tmp_exploration_achievements (
	achievement_id INT UNSIGNED NOT NULL PRIMARY KEY);

-- Enabled-criteria mirror of AchievementManager::IsExplorationOnly
-- (achievement_manager.cpp: disabled criteria never load).
INSERT IGNORE INTO tmp_exploration_achievements
SELECT a.id
FROM achievements a
WHERE EXISTS (
		SELECT 1 FROM achievement_criteria c
		WHERE c.achievement_id = a.id AND c.enabled = 1)
AND NOT EXISTS (
		SELECT 1 FROM achievement_criteria c
		WHERE c.achievement_id = a.id AND c.enabled = 1
		AND c.event_type <> 5);

DROP TEMPORARY TABLE IF EXISTS tmp_exploration_reward_sets;
CREATE TEMPORARY TABLE tmp_exploration_reward_sets (
	reward_set_id INT UNSIGNED NOT NULL PRIMARY KEY);

INSERT IGNORE INTO tmp_exploration_reward_sets
SELECT rs.reward_set_id
FROM reward_sources rs
JOIN tmp_exploration_achievements t ON t.achievement_id = rs.source_id
WHERE rs.source_type = 1;

-- Backups (idempotent; re-runs find nothing new to snapshot).
CREATE TABLE IF NOT EXISTS nms_ach_exploration_rewards_sources (
	source_type TINYINT UNSIGNED NOT NULL,
	source_id INT UNSIGNED NOT NULL,
	reward_set_id INT UNSIGNED NOT NULL,
	enabled TINYINT UNSIGNED NOT NULL DEFAULT 1,
	PRIMARY KEY (source_type, source_id));
INSERT IGNORE INTO nms_ach_exploration_rewards_sources
SELECT rs.source_type, rs.source_id, rs.reward_set_id, rs.enabled
FROM reward_sources rs
JOIN tmp_exploration_reward_sets t ON t.reward_set_id = rs.reward_set_id;

CREATE TABLE IF NOT EXISTS nms_ach_exploration_rewards_sets (
	reward_set_id INT UNSIGNED NOT NULL PRIMARY KEY,
	title VARCHAR(255) NOT NULL DEFAULT '',
	enabled TINYINT UNSIGNED NOT NULL DEFAULT 1);
INSERT IGNORE INTO nms_ach_exploration_rewards_sets
SELECT rset.reward_set_id, rset.title, rset.enabled
FROM reward_sets rset
JOIN tmp_exploration_reward_sets t ON t.reward_set_id = rset.reward_set_id;

CREATE TABLE IF NOT EXISTS nms_ach_exploration_rewards_options (
	reward_set_id INT UNSIGNED NOT NULL,
	option_id INT UNSIGNED NOT NULL,
	sequence INT UNSIGNED NOT NULL DEFAULT 0,
	label VARCHAR(255) NOT NULL DEFAULT '',
	common_to_all TINYINT UNSIGNED NOT NULL DEFAULT 0,
	flags TINYINT UNSIGNED NOT NULL DEFAULT 0,
	enabled TINYINT UNSIGNED NOT NULL DEFAULT 1,
	class_mask INT UNSIGNED NOT NULL DEFAULT 65535,
	PRIMARY KEY (reward_set_id, option_id));
INSERT IGNORE INTO nms_ach_exploration_rewards_options
SELECT ro.reward_set_id, ro.option_id, ro.sequence, ro.label,
	ro.common_to_all, ro.flags, ro.enabled, ro.class_mask
FROM reward_options ro
JOIN tmp_exploration_reward_sets t ON t.reward_set_id = ro.reward_set_id;

CREATE TABLE IF NOT EXISTS nms_ach_exploration_rewards_option_entries (
	reward_set_id INT UNSIGNED NOT NULL,
	option_id INT UNSIGNED NOT NULL,
	sequence INT UNSIGNED NOT NULL DEFAULT 0,
	reward_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (reward_set_id, option_id, reward_id));
INSERT IGNORE INTO nms_ach_exploration_rewards_option_entries
SELECT oe.reward_set_id, oe.option_id, oe.sequence, oe.reward_id
FROM reward_option_entries oe
JOIN tmp_exploration_reward_sets t ON t.reward_set_id = oe.reward_set_id;

CREATE TABLE IF NOT EXISTS nms_ach_exploration_rewards_selections (
	character_id INT UNSIGNED NOT NULL,
	achievement_id INT UNSIGNED NOT NULL,
	reward_set_id INT UNSIGNED NOT NULL,
	selected_option_id INT UNSIGNED NOT NULL DEFAULT 0,
	status TINYINT UNSIGNED NOT NULL DEFAULT 0,
	attempt_count INT UNSIGNED NOT NULL DEFAULT 0,
	claimed_at INT UNSIGNED NOT NULL DEFAULT 0,
	last_attempt_at INT UNSIGNED NOT NULL DEFAULT 0,
	last_error VARCHAR(255) NOT NULL DEFAULT '',
	PRIMARY KEY (character_id, achievement_id, reward_set_id));
INSERT IGNORE INTO nms_ach_exploration_rewards_selections
SELECT csr.character_id, csr.achievement_id, csr.reward_set_id,
	csr.selected_option_id, csr.status, csr.attempt_count, csr.claimed_at,
	csr.last_attempt_at, csr.last_error
FROM character_achievement_reward_selections csr
JOIN tmp_exploration_achievements t ON t.achievement_id = csr.achievement_id;

-- Purge, children first. No reward set in this purge is sourced by any
-- non-exploration achievement (verified: no reward_sources row count > 1).
DELETE oe FROM reward_option_entries oe
JOIN tmp_exploration_reward_sets t ON t.reward_set_id = oe.reward_set_id;
DELETE ro FROM reward_options ro
JOIN tmp_exploration_reward_sets t ON t.reward_set_id = ro.reward_set_id;
DELETE rset FROM reward_sets rset
JOIN tmp_exploration_reward_sets t ON t.reward_set_id = rset.reward_set_id;
DELETE rs FROM reward_sources rs
JOIN tmp_exploration_reward_sets t ON t.reward_set_id = rs.reward_set_id
WHERE rs.source_type = 1;
DELETE csr FROM character_achievement_reward_selections csr
JOIN tmp_exploration_achievements t ON t.achievement_id = csr.achievement_id;

-- The rule is retired from the code; drop its seeded row (world also
-- self-deletes orphaned rule rows at boot).
DELETE FROM rule_values WHERE rule_name = 'Achievements:ExplorationRewards';

DROP TEMPORARY TABLE IF EXISTS tmp_exploration_reward_sets;
DROP TEMPORARY TABLE IF EXISTS tmp_exploration_achievements;

COMMIT;
