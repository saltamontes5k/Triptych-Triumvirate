-- ============================================================================
-- Rollback of 20261030_tbs_katta_orum_economy.sql (v291).
-- Safe on an already-rolled-back database (no-ops).
-- ============================================================================

SET NAMES utf8mb4;
START TRANSACTION;

UPDATE `tasks` SET `repeatable` = 0, `reward_point_type` = 0, `reward_points` = 0 WHERE `id` BETWEEN 620100 AND 620111;
UPDATE `tasks` SET `type` = 1 WHERE `id` BETWEEN 620100 AND 620111;

DELETE FROM `npc_faction_entries` WHERE `npc_faction_id` = 1520000064 AND `faction_id` = 1170 AND `value` = -50;

UPDATE `tasks` SET `faction_reward` = 1095, `faction_amount` = 100 WHERE `id` BETWEEN 625050 AND 625063;

COMMIT;
