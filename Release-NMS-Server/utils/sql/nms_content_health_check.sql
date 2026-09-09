-- ============================================================================
-- Triptych content health check - verifies the DATA every custom-manifest
-- version (v18 through v34) is supposed to deliver, without trusting
-- db_version.
--
-- Why this exists: we have now twice found servers whose custom_version was
-- stamped PAST an entry whose content never landed (a half-apply healed by a
-- later resync; a wholesale-skip healed by the v23-25 repairs). The version
-- number is a claim; this file is the audit. Every line prints its own
-- expectation - anything that misses its expected value identifies exactly
-- which payload is absent.
--
-- Expected custom_version on a fully-booted server: 34. NOTE: the shipped
-- dump (release-peq.sql) is stamped 33 - a fresh import reads 33 until the
-- first `world` boot applies v34. So "34" is correct only after first boot.
--
-- Run (Windows / MariaDB):
--   "C:\Program Files\MariaDB 12.3\bin\mariadb.exe" -u <user> -p <dbname> < nms_content_health_check.sql
-- Or from any mysql/mariadb client: source nms_content_health_check.sql
--
-- Single-DB assumption: this fork runs with `content_database` unset, so all
-- player-schema and content-schema objects live in the one database. If a
-- split deployment ever runs this file, player-schema rows (account, trader,
-- character_illusions, ...) will not exist in the content DB.
--
-- READ-ONLY: SELECT/SHOW only. Safe on any server, any number of times.
-- ============================================================================

SELECT 'db_version.custom_version (expect 34 once a v34 binary has booted)' AS what, custom_version AS value FROM db_version LIMIT 1;

-- ---- v18 / v23: Beastlord spell merchant + scrolls -------------------------
SELECT 'v23 bl merchant npc (expect 1)' AS what, COUNT(*) AS value FROM npc_types WHERE id = 1120001300;
SELECT 'v23 bl scrolls (expect 38)' AS what, COUNT(*) AS value FROM merchantlist WHERE merchantid = 1120001300;

-- ---- v18 / v24: merchant spawns --------------------------------------------
SELECT 'v24 spawngroups (expect 2)' AS what, COUNT(*) AS value FROM spawngroup WHERE name IN ('fv_Beastlord_Spell_Merchant','ot_Beastlord_Spell_Merchant');
SELECT 'v24 spawn2 rows (expect 2)' AS what, COUNT(*) AS value FROM spawn2 WHERE spawngroupID IN (SELECT id FROM spawngroup WHERE name IN ('fv_Beastlord_Spell_Merchant','ot_Beastlord_Spell_Merchant'));

-- ---- v18 / v25: data payload ------------------------------------------------
SELECT 'v25 whitelist has aa516 (expect 1)' AS what, COUNT(*) AS value FROM rule_values WHERE rule_name = 'Custom:AA339Whitelist' AND rule_value LIKE '%aa516%';
SELECT 'v25 bl GMs class (expect 34,34)' AS what, GROUP_CONCAT(class) AS value FROM npc_types WHERE id IN (93152, 84202);

-- ---- v19 / v22: factions + rules --------------------------------------------
SELECT 'v19 factions (expect 929,929,929,929)' AS what, GROUP_CONCAT(npc_faction_id) AS value FROM npc_types WHERE id IN (46016,46017,46061,46089);
SELECT 'v19 faction 2000507 (expect 79)' AS what, npc_faction_id AS value FROM npc_types WHERE id = 2000507;
SELECT 'v19 buy cost mod (expect 1.0)' AS what, rule_value AS value FROM rule_values WHERE rule_name = 'Merchant:BuyCostMod';
SELECT 'v19 db_str 15594 fixed (expect 1)' AS what, COUNT(*) AS value FROM db_str WHERE id = 15594 AND type = 4 AND value LIKE '%additional damage%';

-- ---- v20: Sateal in the Bazaar -----------------------------------------------
-- v20 runs a blanket UPDATE on name='Sateal_Deirosap'; the dump carries two such
-- NPCs (151001 and 151200), so the correct count is 2.
SELECT 'v20 sateal titled (expect 2)' AS what, COUNT(*) AS value FROM npc_types WHERE name = 'Sateal_Deirosap' AND lastname = 'Smithing Supplies';

-- ---- v21 / v22: data payload --------------------------------------------------
SELECT 'v22 bazaar cancombat (expect 0,0)' AS what, GROUP_CONCAT(cancombat) AS value FROM zone WHERE short_name = 'bazaar';
SELECT 'v22 bazaar safe_x (expect -134.13 x2)' AS what, GROUP_CONCAT(safe_x) AS value FROM zone WHERE short_name = 'bazaar';
SELECT 'v22 hastened AA (expect 1600,2000)' AS what, GROUP_CONCAT(base1) AS value FROM aa_rank_effects WHERE rank_id IN (12899,12900) AND slot = 1 AND base2 = 57;
SELECT 'v22 aa next_id (expect -1)' AS what, next_id AS value FROM aa_ranks WHERE id = 12900;
SELECT 'v22 quegmor moved (expect -76.12)' AS what, ROUND(z,2) AS value FROM spawn2 WHERE id = 14745;

-- ---- v26: Bazaar armour-glamour NPC -------------------------------------------
SELECT 'v26 glamour npc (expect 1)' AS what, COUNT(*) AS value FROM npc_types WHERE id = 1120001110 AND name = 'Purveyor_of_Armour_Glamour';
SELECT 'v26 glamour spawngroup (expect 1)' AS what, COUNT(*) AS value FROM spawngroup WHERE id = 5003550;
SELECT 'v26 glamour spawn2 (expect 1)' AS what, COUNT(*) AS value FROM spawn2 WHERE id = 2141650;

-- ---- v27: account offline flag -------------------------------------------------
SELECT 'v27 account.offline col (expect 1)' AS what, COUNT(*) AS value FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'account' AND COLUMN_NAME = 'offline';

-- ---- v28: trader offline schema -------------------------------------------------
SELECT 'v28 trader.character_id col (expect 1)' AS what, COUNT(*) AS value FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'trader' AND COLUMN_NAME = 'character_id';
SELECT 'v28 trader.item_unique_id col (expect 1)' AS what, COUNT(*) AS value FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'trader' AND COLUMN_NAME = 'item_unique_id';

-- ---- v29: item_unique_id on inventory / sharedbank -------------------------------
SELECT 'v29 inventory.item_unique_id col (expect 1)' AS what, COUNT(*) AS value FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'inventory' AND COLUMN_NAME = 'item_unique_id';
SELECT 'v29 sharedbank.item_unique_id col (expect 1)' AS what, COUNT(*) AS value FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sharedbank' AND COLUMN_NAME = 'item_unique_id';

-- ---- v30: parcels item_unique_id + evolve_amount --------------------------------
SELECT 'v30 character_parcels cols (expect 2)' AS what, COUNT(*) AS value FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'character_parcels' AND COLUMN_NAME IN ('item_unique_id','evolve_amount');

-- ---- v31: inventory_snapshots item_unique_id ------------------------------------
SELECT 'v31 inventory_snapshots.item_unique_id col (expect 1)' AS what, COUNT(*) AS value FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'inventory_snapshots' AND COLUMN_NAME = 'item_unique_id';

-- ---- v32: offline-bazaar tables ---------------------------------------------------
SELECT 'v32 item_unique_id_reservations tbl (expect 1)' AS what, COUNT(*) AS value FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'item_unique_id_reservations';
SELECT 'v32 offline_character_sessions tbl (expect 1)' AS what, COUNT(*) AS value FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'offline_character_sessions';
SELECT 'v32 character_offline_transactions tbl (expect 1)' AS what, COUNT(*) AS value FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'character_offline_transactions';

-- ---- v33: character_illusions -------------------------------------------------------
SELECT 'v33 character_illusions tbl (expect 1)' AS what, COUNT(*) AS value FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'character_illusions';

-- ---- v34: npc_types summon_timer_override --------------------------------------------
SELECT 'v34 npc_types.summon_timer_override col (expect 1)' AS what, COUNT(*) AS value FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'npc_types' AND COLUMN_NAME = 'summon_timer_override';
