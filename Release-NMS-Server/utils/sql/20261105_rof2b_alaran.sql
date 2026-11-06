-- 20261105 rof2b port: Alaran language achievement training (Shards Landing
-- addition). Source: github.com/nightstalker6669/EQEmu branch rof2-achievements,
--   extensions/rof2/achievements/content/shards-landing/sql/030-alaran-language-
--   achievements.sql (GPL-3.0), ported 2026-11-05.
-- Upstream ships this as a stored procedure; flattened here for our manifest
-- pipeline. Adaptations: their `achievement_associations` shape guard dropped
-- (no such table in our schema; the same constraint is carried by the
-- achievement_components guard) and their `reward_source_entries` guard renamed
-- to our `reward_option_entries`. The definitions themselves (1900045-1900049)
-- are expected to pre-exist from the stock lineage, as upstream assumes.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS alaran_training_expected;
CREATE TEMPORARY TABLE alaran_training_expected(
 achievement_id INT UNSIGNED PRIMARY KEY,
 achievement_name VARCHAR(128) NOT NULL,
 component_name VARCHAR(255) NOT NULL
);
INSERT INTO alaran_training_expected VALUES
(1900045,'Alaran Language Aware','Alaran Language: 25'),
(1900046,'Alaran Language Novice','Alaran Language: 50'),
(1900047,'Alaran Language Fluent','Alaran Language: 71'),
(1900048,'Alaran Language Expert','Alaran Language: 90'),
(1900049,'Alaran Language Master','Alaran Language: 100 - Update by clicking language primer books');

DROP TEMPORARY TABLE IF EXISTS _alaran_guard;
CREATE TEMPORARY TABLE _alaran_guard(label VARCHAR(80) PRIMARY KEY, ok TINYINT NOT NULL, CHECK(ok=1)) ENGINE=InnoDB;
INSERT INTO _alaran_guard VALUES('achievement_identity',(SELECT COUNT(*) FROM achievements a JOIN alaran_training_expected e
 ON e.achievement_id=a.id WHERE BINARY a.name=BINARY e.achievement_name
 AND a.points=10 AND a.has_reward=0 AND a.enabled IN(0,1) AND a.version=0)=5);
INSERT INTO _alaran_guard VALUES('component_shape',((SELECT COUNT(*) FROM achievement_components WHERE achievement_id BETWEEN 1900045 AND 1900049 AND component_type=1)=5
 AND (SELECT COUNT(*) FROM achievement_components c JOIN alaran_training_expected e
 ON e.achievement_id=c.achievement_id WHERE c.component_type=1 AND c.sequence=1
 AND c.component_id=e.achievement_id AND BINARY c.name=BINARY e.component_name AND c.description='')=5));
INSERT INTO _alaran_guard VALUES('criteria_shape',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id BETWEEN 1900045 AND 1900049
 AND NOT(component_type=1 AND component_sequence=1 AND component_id=achievement_id
 AND event_type=0 AND progress_mode=3 AND behavior=0 AND target_id=0 AND target_id2=0
 AND target_value=0 AND required_count=1 AND enabled IN(0,1)))
 AND NOT EXISTS(SELECT achievement_id FROM achievement_criteria WHERE achievement_id BETWEEN 1900045 AND 1900049 GROUP BY achievement_id HAVING COUNT(*)>1)));
INSERT INTO _alaran_guard VALUES('reward_policy',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=1 AND source_id BETWEEN 1900045 AND 1900049)
));

INSERT INTO achievement_criteria(achievement_id,component_type,component_sequence,
 component_id,event_type,progress_mode,behavior,target_id,target_id2,target_value,required_count,enabled)
SELECT e.achievement_id,1,1,e.achievement_id,0,3,0,0,0,0,1,1 FROM alaran_training_expected e
WHERE NOT EXISTS(SELECT 1 FROM achievement_criteria c WHERE c.achievement_id=e.achievement_id) ORDER BY e.achievement_id;
UPDATE achievement_criteria SET enabled=1 WHERE achievement_id BETWEEN 1900045 AND 1900049;
UPDATE achievements SET enabled=1 WHERE id BETWEEN 1900045 AND 1900049;

DROP TEMPORARY TABLE IF EXISTS alaran_training_expected;
DROP TEMPORARY TABLE IF EXISTS _alaran_guard;
COMMIT;
