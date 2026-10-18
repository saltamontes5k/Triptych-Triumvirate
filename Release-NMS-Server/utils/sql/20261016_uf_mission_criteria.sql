-- Phase 2 UF group-mission hooks: the five server group missions (tasks 304000-304004) are
-- credited to the matching zone 'Hero of ...' mission component. The server names differ from
-- the client mission names, so the mapping is by zone. Generated 2026-10-16.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO achievement_criteria (achievement_id, component_type, component_sequence, component_id, event_type, progress_mode, behavior, target_id, target_id2, target_value, required_count, enabled) VALUES
  (1748103, 1, 1, 1148103, 4, 3, 0, 304004, 0, 0, 1, 1),
  (1748203, 1, 1, 1148203, 4, 3, 0, 304001, 0, 0, 1, 1),
  (1748503, 1, 1, 1148503, 4, 3, 0, 304002, 0, 0, 1, 1),
  (1748603, 1, 1, 1148603, 4, 3, 0, 304000, 0, 0, 1, 1),
  (1748703, 1, 1, 1148703, 4, 3, 0, 304003, 0, 0, 1, 1)
ON DUPLICATE KEY UPDATE progress_mode=VALUES(progress_mode), behavior=VALUES(behavior), target_value=VALUES(target_value), required_count=VALUES(required_count), enabled=VALUES(enabled);
COMMIT;
