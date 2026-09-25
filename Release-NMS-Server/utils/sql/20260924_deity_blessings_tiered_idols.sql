-- ============================================================================
-- Deity Blessings -- accept Enchanted / Legendary idols on Rank I delivery
-- Date: 2026-09-24
--
-- Mirrors manifest v74. The task-deliver match compares the raw item id, so
-- the upgrade-tier ids (base + 1,000,000 / base + 2,000,000) must be listed
-- explicitly. Only bases below 1,000,000 are tierable (Custom:DoItemUpgrades),
-- so Veeshan (9910021) and Agnostic (9910023) are intentionally left as-is.
--
-- Idempotent: only rows without an expanded list are updated.
-- ============================================================================

UPDATE `task_activities`
SET `item_id_list` = CONCAT(
        `item_id_list`, '|',
        CAST(`item_id_list` AS UNSIGNED) + 1000000, '|',
        CAST(`item_id_list` AS UNSIGNED) + 2000000)
WHERE `taskid` BETWEEN 700001 AND 700015
  AND `item_id_list` NOT LIKE '%|%';
