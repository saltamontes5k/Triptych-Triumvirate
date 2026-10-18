-- Rollback for the UF group-mission hooks.
SET NAMES utf8mb4;
START TRANSACTION;
DELETE FROM achievement_criteria WHERE achievement_id=1748103 AND component_type=1 AND component_id=1148103 AND event_type=4;
DELETE FROM achievement_criteria WHERE achievement_id=1748203 AND component_type=1 AND component_id=1148203 AND event_type=4;
DELETE FROM achievement_criteria WHERE achievement_id=1748503 AND component_type=1 AND component_id=1148503 AND event_type=4;
DELETE FROM achievement_criteria WHERE achievement_id=1748603 AND component_type=1 AND component_id=1148603 AND event_type=4;
DELETE FROM achievement_criteria WHERE achievement_id=1748703 AND component_type=1 AND component_id=1148703 AND event_type=4;
COMMIT;
