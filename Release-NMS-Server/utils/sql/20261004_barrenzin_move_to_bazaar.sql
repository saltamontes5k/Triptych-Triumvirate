-- ============================================================================
-- 2026-10-04 Move Barrenzin to the Bazaar
--
-- Barrenzin (npc 202330) is a low-level task NPC (task set 207: "Ambushed!"
-- 5210, "The Cabilisian Trade Route" 5206). He spawned in the Plane of
-- Knowledge, which low-level players cannot reach, so his tasks were
-- impossible to finish. Move him to the Bazaar, which is reachable early.
--
--   spawn2 id 40639 -> bazaar at (131, -807, 3)
--   task_activities 5206/6 and 5210/4 -> zones 202 (poknowledge) -> 151 (bazaar)
--
-- The quest script is moved from poknowledge/Barrenzin.pl to
-- bazaar/Barrenzin.pl (EQEmu loads NPC scripts by name per zone).
-- Idempotent.
-- ============================================================================

UPDATE spawn2
SET zone = 'bazaar',
    x    = 131,
    y    = -807,
    z    = 3
WHERE id = 40639;

UPDATE task_activities
SET zones = '151'
WHERE (taskid = 5206 AND activityid = 6)
   OR (taskid = 5210 AND activityid = 4);
