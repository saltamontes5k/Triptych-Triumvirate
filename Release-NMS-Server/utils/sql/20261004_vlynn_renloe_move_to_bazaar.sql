-- ============================================================================
-- 2026-10-04 Move V`Lynn Renloe to the Bazaar
--
-- V`Lynn Renloe (npc 202291) is the turn-in NPC for task 500001 ("Example
-- Task 1"), a Kelethin/Greater Faydark lowbie chain. He was spawned in the
-- Plane of Knowledge, which lowbies cannot reach, so the final step was
-- impossible. Move him to the Bazaar, which is reachable early.
--
--   spawn2 id 40633        -> bazaar at (101, -780, 3)
--   task_activities step 8 -> zones 54 (gfaydark) -> 151 (bazaar)
--
-- Idempotent.
-- ============================================================================

UPDATE spawn2
SET zone = 'bazaar',
    x    = 101,
    y    = -780,
    z    = 3
WHERE id = 40633;

UPDATE task_activities
SET zones = '151'
WHERE taskid = 500001
  AND activityid = 8;
