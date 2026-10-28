-- Rollback for 20261024_achievement_duplicate_and_orphan_cleanup.sql.
-- Re-enables the eight imported twins and puts the five category-95
-- associations back exactly as they were.
--
-- Apply:  mysql -u<user> -p peq < 20261024_achievement_duplicate_and_orphan_cleanup_rollback.sql
-- After applying, reload the catalog in game:  #reload achievements global

SET NAMES utf8mb4;
START TRANSACTION;

UPDATE achievements SET enabled = 1 WHERE id IN (90041,90047,138480,139380,151880,153940,153980,154880);

UPDATE achievement_category_associations
SET category_id = 95, sequence = 1
WHERE category_id = 501 AND achievement_id = 41000300 AND sequence = 1000;

INSERT INTO achievement_category_associations (category_id, sequence, achievement_id, display_text) VALUES
	(95, 0, 41000100, ''),
	(95, 2, 41000200, ''),
	(95, 3, 41000210, ''),
	(95, 4, 41000220, '');

COMMIT;
