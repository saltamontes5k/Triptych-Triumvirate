-- Rollback for the DoN..UF imported achievement slice (20261016).
-- Removes every imported row; the server-authored 950xxxx/960xxxx set is untouched.
SET NAMES utf8mb4;
START TRANSACTION;
DELETE c FROM achievement_criteria c JOIN achievements a ON a.id=c.achievement_id WHERE a.id NOT BETWEEN 9500000 AND 9699999;
DELETE ca FROM achievement_category_associations ca JOIN achievements a ON a.id=ca.achievement_id WHERE a.id NOT BETWEEN 9500000 AND 9699999;
DELETE comp FROM achievement_components comp JOIN achievements a ON a.id=comp.achievement_id WHERE a.id NOT BETWEEN 9500000 AND 9699999;
DELETE FROM achievements WHERE id NOT BETWEEN 9500000 AND 9699999;
DELETE FROM achievement_associations WHERE component_id NOT BETWEEN 9650000 AND 9659999;
DELETE FROM achievement_categories WHERE id NOT BETWEEN 9500000 AND 9699999;
DELETE FROM character_achievements WHERE achievement_id NOT BETWEEN 9500000 AND 9699999;
DELETE FROM character_achievement_progress WHERE achievement_id NOT BETWEEN 9500000 AND 9699999;
DELETE FROM character_achievement_rewards WHERE achievement_id NOT BETWEEN 9500000 AND 9699999;
DELETE FROM character_achievement_reward_selections WHERE achievement_id NOT BETWEEN 9500000 AND 9699999;
DELETE FROM character_achievement_pending_updates WHERE achievement_id NOT BETWEEN 9500000 AND 9699999;
COMMIT;
