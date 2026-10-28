-- 2026-10-24  Retire the server-authored "Triptych" achievement root.
--
-- The server-authored catalog hung off its own top-level category (9500000
-- "Triptych"). That root carries no icon, so the achievements window renders it
-- as a plain text row in the category tree instead of a tab button, and it
-- duplicates category names that already exist in the stock tree.
--
-- Each leaf that holds achievements is re-filed onto the stock category that
-- carries the same role, then the now-empty Triptych nodes are dropped:
--
--   Exploration (sample)            -> The Hero's Journey / Quests
--   Progression (sample)            -> The Hero's Journey / Progression
--   Original / Exploration (75)     -> EverQuest / Exploration
--   Original / Hunter (50)          -> EverQuest / Hunter
--   Original / Raids (8)            -> EverQuest / Raids
--   Original / General (2)          -> EverQuest / General
--   General / Level (17)            -> General / Level
--   General / Advancement (29)      -> General / Advancement
--   General / Class (98)            -> General / Class
--   General / Keys (27)             -> General / Keys
--
-- Achievement IDs are not touched, so character_achievements,
-- character_achievement_progress and character_achievement_rewards all keep
-- pointing at the same rows. Only the category tree changes.
--
-- Moved rows are appended to the end of the target category (sequence 1000+),
-- so the existing stock ordering is left alone.
--
-- Apply:  mysql -u<user> -p peq < 20261024_achievement_triptych_rehome.sql
-- Undo:   20261024_achievement_triptych_rehome_rollback.sql
-- After applying, reload the catalog in game:  #reload achievements global

SET NAMES utf8mb4;
START TRANSACTION;

-- 1. Re-file the associations.
INSERT INTO achievement_category_associations (category_id, sequence, achievement_id, display_text)
SELECT
	t.tgt,
	1000 + t.rn,
	t.achievement_id,
	t.display_text
FROM (
	SELECT
		m.tgt,
		ca.achievement_id,
		ca.display_text,
		ROW_NUMBER() OVER (PARTITION BY m.tgt ORDER BY ca.achievement_id) AS rn
	FROM (
	SELECT 9500001 AS src, 75 AS tgt
   UNION ALL SELECT 9500002 AS src, 71 AS tgt
   UNION ALL SELECT 9600010 AS src, 102 AS tgt
   UNION ALL SELECT 9600011 AS src, 108 AS tgt
   UNION ALL SELECT 9600012 AS src, 106 AS tgt
   UNION ALL SELECT 9600013 AS src, 101 AS tgt
   UNION ALL SELECT 9600020 AS src, 13 AS tgt
   UNION ALL SELECT 9600021 AS src, 11 AS tgt
   UNION ALL SELECT 9600022 AS src, 12 AS tgt
   UNION ALL SELECT 9600023 AS src, 17 AS tgt
	) m
	JOIN achievement_category_associations ca ON ca.category_id = m.src
) t
ON DUPLICATE KEY UPDATE sequence = VALUES(sequence);

-- 2. Drop the old category links.
DELETE FROM achievement_category_associations WHERE category_id IN (9500000,9500001,9500002,9600000,9600001,9600010,9600011,9600012,9600013,9600020,9600021,9600022,9600023);

-- 3. Drop the Triptych category nodes (root, empty branches and leaves).
DELETE FROM achievement_categories WHERE id IN (9500000,9500001,9500002,9600000,9600001,9600010,9600011,9600012,9600013,9600020,9600021,9600022,9600023);

COMMIT;
