-- 2026-10-24  Achievement catalog follow-up to 20261024_achievement_triptych_rehome.sql.
--
-- Two leftovers from retiring the Triptych root:
--
-- 1. Eight imported achievements now sit in the same category as a
--    server-authored copy with the identical name. The server-authored copy is
--    the wired one (achievement_criteria + achievement_components); the imported
--    twin has components but no criteria, so it can never complete, and no
--    character has ever completed or progressed it. Disable the imported twin so
--    each name is listed once:
--
--      90041 "9600170"  ->  90041 disabled (server-authored 9600170 stays live)
--      90047 "9600171"  ->  90047 disabled (server-authored 9600171 stays live)
--      138480 "9600264"  ->  138480 disabled (server-authored 9600264 stays live)
--      139380 "9600277"  ->  139380 disabled (server-authored 9600277 stays live)
--      151880 "9600287"  ->  151880 disabled (server-authored 9600287 stays live)
--      153940 "9600253"  ->  153940 disabled (server-authored 9600253 stays live)
--      153980 "9600286"  ->  153980 disabled (server-authored 9600286 stays live)
--      154880 "9600257"  ->  154880 disabled (server-authored 9600257 stays live)
--
-- 2. Five associations referenced category 95, which does not exist. Four of
--    them point at achievement rows that no longer exist (they were dropped with
--    the DoN..UF import rollback); those rows are removed. The fifth,
--    41000300 "Quarm: Early Bird Bonus (Temporary)", is a real achievement and is
--    filed under Planes of Power -> General. It stays disabled (enabled = 0),
--    which is how it shipped.
--
-- Apply:  mysql -u<user> -p peq < 20261024_achievement_duplicate_and_orphan_cleanup.sql
-- Undo:   20261024_achievement_duplicate_and_orphan_cleanup_rollback.sql
-- After applying, reload the catalog in game:  #reload achievements global

SET NAMES utf8mb4;
START TRANSACTION;

-- 1. Hide the imported twins (only where the server-authored copy is live).
UPDATE achievements a
JOIN (
	SELECT DISTINCT o.id AS id
	FROM achievements o
	JOIN achievements s ON s.name = o.name AND s.id BETWEEN 9500000 AND 9699999 AND s.enabled = 1
	WHERE o.id IN (90041,90047,138480,139380,151880,153940,153980,154880)
) d ON d.id = a.id
SET a.enabled = 0;

-- 2a. Quarm early-bird bonus -> Planes of Power / General.
UPDATE achievement_category_associations
SET category_id = 501, sequence = 1000
WHERE category_id = 95 AND achievement_id = 41000300;

-- 2b. Drop the associations whose achievement rows do not exist.
DELETE FROM achievement_category_associations
WHERE category_id = 95 AND achievement_id IN (41000100,41000200,41000210,41000220);

COMMIT;
