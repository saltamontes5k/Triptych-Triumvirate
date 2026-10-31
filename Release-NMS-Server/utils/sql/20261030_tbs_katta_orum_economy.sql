-- ============================================================================
-- 2026-10-31  TBS Katta Castrum: Orum economy + Combine Empire Merchants
--             wiring (v291)
--
-- Twin of ManifestEntry .version = 291 in
-- common/database/database_update_manifest_custom.cpp (keep in sync).
--
--   1. The 12 Orux missions (620100-620111) become repeatable and pay
--      10 Orum (alternate_currency 11 -> item 79911) per completion via
--      the task currency path -- repeating missions was the live faction
--      and currency farm. Faction 1170 +10 re-awards on every completion.
--      The one-time script-side Orum payouts are removed from the assigner
--      scripts (separate files).
--   2. Killing a Combine Empire Merchants member (the 23 Katta vendors or
--      Researcher Higgins in barren) lowers Combine Empire Merchants by
--      50 -- Allakhazam documents the Masters/Traders as kill-lower
--      targets.
--   3. The Solteris access arc (625050-625063) awards Combine Empire
--      Merchants at the live amounts (+25, finale +50) instead of
--      Crusade of the Scale. The ring-chain rewards are untouched.
--   4. The 23 vendor rows keep the -1100 no-gate sentinel (documented
--      decision: the server-wide convention; faction 1170 stays a task
--      progression track).
--
-- Idempotency: applies once via the manifest check (task 620100 sentinel).
-- Every statement is idempotent on manual re-run.
--
-- Rollback: utils/sql/20261030_tbs_katta_orum_economy_rollback.sql
-- ============================================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- 1. Repeatable missions paying Orum.
UPDATE `tasks` SET `repeatable` = 1, `reward_point_type` = 11, `reward_points` = 10 WHERE `id` BETWEEN 620100 AND 620111;
-- The 12 missions shipped as type 1, which in this fork is TaskType::Shared,
-- not a solo mission: solo AssignTask was intercepted as a shared-task
-- request and silently dropped. They are solo dz-entry missions (the
-- assigner scripts' [enter] hop creates the instance), so they are quests.
UPDATE `tasks` SET `type` = 2 WHERE `id` BETWEEN 620100 AND 620111 AND `type` = 1;

-- 2. Merchant kill penalty.
INSERT INTO `npc_faction_entries` (`npc_faction_id`, `faction_id`, `value`, `npc_value`, `temp`) VALUES
    (1520000064, 1170, -50, 0, 0);

-- 3. Solteris access arc awards the merchants faction.
UPDATE `tasks` SET `faction_reward` = 1170, `faction_amount` = 25 WHERE `id` BETWEEN 625050 AND 625062;
UPDATE `tasks` SET `faction_reward` = 1170, `faction_amount` = 50 WHERE `id` = 625063;

COMMIT;
