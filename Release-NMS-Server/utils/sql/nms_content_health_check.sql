-- ============================================================================
-- Triptych content health check - verifies the DATA each custom-manifest
-- version is supposed to deliver, without trusting db_version. Coverage is
-- full for v18-v42 plus targeted checks for v50 (the alternate-currency
-- self-heal), v62-v63 (the Fabled season schema), v71 (blessing renames)
-- and v93-v96 (the Nautilus Vault).
--
-- Why this exists: we have now twice found servers whose custom_version was
-- stamped PAST an entry whose content never landed (a half-apply healed by a
-- later resync; a wholesale-skip healed by the v23-25 repairs). The version
-- number is a claim; this file is the audit. Every line prints its own
-- expectation - anything that misses its expected value identifies exactly
-- which payload is absent.
--
-- Expected custom_version on a fully-booted server: 96. A fresh import only
-- reaches that once the first `world` boot applies the outstanding custom
-- migrations (v35-v96). So "96" is correct only after first boot.
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

-- The literal tracks CUSTOM_BINARY_DATABASE_VERSION in common/version.h: bump BOTH together.
SELECT 'db_version.custom_version (expect 445)' AS what, custom_version AS value FROM db_version LIMIT 1;

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

-- ---- v39: #Echo_of_Chardok (Veeshan's Peak key / Cipher essence branch) ---------------
SELECT 'v39 chardok echo npc (expect 1)' AS what, COUNT(*) AS value FROM npc_types WHERE id = 103161;
SELECT 'v39 chardok echo spawn2 (expect 3)' AS what, COUNT(*) AS value FROM spawn2 s JOIN spawnentry e ON e.spawngroupID = s.spawngroupID WHERE e.npcID = 103161 AND s.zone = 'chardok';

-- ---- v40: era zones unlocked through Secrets of Faydwer (per-account gates govern) ----
SELECT 'v40 OoW zones open (expect 24)' AS what, COUNT(DISTINCT short_name) AS value FROM zone WHERE expansion = 8 AND min_status = 0;
SELECT 'v40 eras<=14 still locked at 255 (expect 0)' AS what, COUNT(*) AS value FROM zone WHERE expansion <= 14 AND min_status = 255;

-- ---- v41: Echo of Memory -> Triune of Fate rename --------------------------------------
SELECT 'v41 triune currency (expect Triune of Fate)' AS what, `value` AS value FROM db_str WHERE id = 6 AND type = 17 LIMIT 1;
SELECT 'v41 triune drop rule (expect 150)' AS what, rule_value AS value FROM rule_values WHERE rule_name = 'Custom:TriuneOfFateDropChance' LIMIT 1;

-- ---- v42: Drakkin breath weapons (and similar slot-3 resist damage spells) always stack -
-- The rule is one comma string. Assert every breath-family id 11112-11201 is listed plus
-- the four spore/oil spells v42 scoped -- a truncated or rewritten value fails here.
--
-- The old form of this assertion also demanded id 50011, one of the custom rank-14/15
-- breath clones v42's comment mentions (50009-50014, "from tss_crescent_reach_quests.sql").
-- Those spells do not exist in this tree or in peq.spells_new (0 rows in 50000-50100, and
-- no such SQL file in HEAD), so the assertion was testing a comment rather than the data.
-- v42 itself never ran here either: its check is "rule_value missing 11112", and the base
-- PEQ rule already carried the whole family, so it was skipped by design.
SELECT 'v42 breath family in always-stack (expect 90)' AS what,
       (SELECT COUNT(*) FROM spells_new s
         WHERE s.id BETWEEN 11112 AND 11201
           AND CONCAT(',', (SELECT rule_value FROM rule_values WHERE rule_name = 'Spells:AlwaysStackSpells'), ',')
               LIKE CONCAT('%,', s.id, ',%')) AS value;
SELECT 'v42 spore and oil spells in always-stack (expect 4)' AS what,
       (SELECT COUNT(*) FROM spells_new s
         WHERE s.id IN (7176,7708,8260,11495)
           AND CONCAT(',', (SELECT rule_value FROM rule_values WHERE rule_name = 'Spells:AlwaysStackSpells'), ',')
               LIKE CONCAT('%,', s.id, ',%')) AS value;

-- ---- v50: alternate-currency rows + client strings self-heal -----------------------------
-- The base release-peq.sql import ships only alternate_currency ids 1 and 6 and no db_str
-- names for ids 4/5 or 30-39; v50 restores the upstream PEQ rows. Both halves are asserted
-- so a half-applied migration (rows without names, or names without rows) is caught. The
-- names are what the client's Alt. Currency tab reads; without them Radiant/Ebon crystals
-- render as "db unknown". Regenerate client files with export_client_files after this lands.
SELECT 'v50 alternate_currency 4/5/10-39 (expect 29)' AS what, COUNT(*) AS value FROM alternate_currency WHERE id IN (4,5,10,11,12,13,14,16,17,18,20,21,22,23,24,25,27,28,29,30,31,32,33,34,35,36,37,38,39);
SELECT 'v50 alt-currency strings 4,5,30-39 x17/18 (expect 24)' AS what, COUNT(*) AS value FROM db_str WHERE type IN (17,18) AND id IN (4,5,30,31,32,33,34,35,36,37,38,39);
SELECT 'v50 radiant crystal name (expect Radiant Crystal)' AS what, `value` AS value FROM db_str WHERE id = 4 AND type = 17 LIMIT 1;
SELECT 'v50 ebon crystal name (expect Ebon Crystal)' AS what, `value` AS value FROM db_str WHERE id = 5 AND type = 17 LIMIT 1;

-- ---- v62/v63: Fabled season ----------------------------------------------------------
-- v62 creates fabled_npcs (content schema); the 472-row roster is seeded by hand from
-- utils/sql/fabled_roster_seed.sql (NOT part of the migration), so the row count is only
-- correct after that seed is applied. v63 creates fabled_season and its single id=1 row.
SELECT 'v62 fabled_npcs tbl (expect 1)' AS what, COUNT(*) AS value FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fabled_npcs';
SELECT 'v62 fabled roster seeded (expect 472)' AS what, COUNT(*) AS value FROM fabled_npcs;
SELECT 'v62 fabled roster enabled (expect 472)' AS what, COUNT(*) AS value FROM fabled_npcs WHERE enabled = 1;
SELECT 'v63 fabled_season tbl (expect 1)' AS what, COUNT(*) AS value FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'fabled_season';
SELECT 'v63 fabled_season row 1 (expect 1)' AS what, COUNT(*) AS value FROM fabled_season WHERE id = 1;
SELECT 'v63 fabled_season inactive (expect 0)' AS what, active AS value FROM fabled_season WHERE id = 1;

-- ---- v71: bazaar "Echo of X" blessings renamed to "Triune of X" --------------------------
SELECT 'v71 triune blessings renamed (expect 9)' AS what, COUNT(*) AS value FROM spells_new WHERE id IN (17779,36856,43002,43003,43004,43005,43006,43007,43008) AND `name` LIKE 'Triune of %';

-- ---- v93: Nautilus Vault player table ------------------------------------------------
SELECT 'v93 character_nms_vault (expect 1)' AS what, COUNT(*) AS value
  FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'character_nms_vault';
SELECT 'v93 vault primary key named cols (expect 3)' AS what, COUNT(*) AS value
  FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'character_nms_vault'
    AND index_name = 'PRIMARY'
    AND column_name IN ('character_id', 'slot', 'bag_slot');
SELECT 'v93 vault primary key total cols (expect 3)' AS what, COUNT(*) AS value
  FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'character_nms_vault'
    AND index_name = 'PRIMARY';
SELECT 'v93 vault unique indexes (expect 1)' AS what, COUNT(DISTINCT index_name) AS value
  FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'character_nms_vault'
    AND non_unique = 0;

-- ---- v94: vault per-instance item state -----------------------------------------------
-- Without these six columns a vault round trip silently returned a different item than the
-- one deposited (attunement, ornamentation and custom_data were dropped), and every vault
-- SELECT/REPLACE references them - EnsureTables keeps the vault disabled until they exist.
SELECT 'v94 vault instance columns (expect 6)' AS what, COUNT(*) AS value
  FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'character_nms_vault'
    AND column_name IN ('instnodrop', 'custom_data', 'ornament_icon',
                        'ornament_idfile', 'ornament_hero_model', 'guid');

-- ---- v95: Nautilus Vault inventory key ----------------------------------------------------
-- Identity is items.id 9011009. Runtime matching is id >= 9011009 AND id % 1000000 = 11009,
-- so stock 11013 (Boots of Quickness) is never the vault key. norent must be nonzero (1):
-- NoRent == 0 is deleted after a long camp.
SELECT 'v95 vault item (expect 1)' AS what, COUNT(*) AS value
  FROM items WHERE id = 9011009 AND Name = 'Nautilus Vault';
SELECT 'v95 vault norent (expect 1)' AS what, norent AS value
  FROM items WHERE id = 9011009;
SELECT 'v95 vault nodrop (expect 0)' AS what, nodrop AS value
  FROM items WHERE id = 9011009;
SELECT 'v95 vault key contract (expect 1)' AS what, COUNT(*) AS value
  FROM items WHERE id = 9011009 AND itemclass = 0 AND itemtype = 33 AND bagslots = 0
    AND bagtype = 0 AND book = 0 AND slots = 0 AND nodrop = 0 AND norent = 1
    AND notransfer = 1 AND fvnodrop = 1 AND attuneable = 0 AND loregroup = -1
    AND clicktype = 1 AND clickeffect = 1 AND clickname = 'Open Nautilus Vault'
    AND casttime = 0 AND maxcharges = -1;

-- ---- v96: NautilusVault rule on ----------------------------------------------------------
SELECT 'v96 Custom:NautilusVault rule (expect 1)' AS what, COUNT(*) AS value
  FROM rule_values WHERE rule_name = 'Custom:NautilusVault' AND rule_value IN ('true', '1');

-- ---- v402: dedicated Vault Merchant template -----------------------------------------------
-- The vault merchant clone (zone/nms_vault.cpp) picks this row by name; it must exist,
-- be merchant-stocked from Dorinan's list, parcel-capable, and born protected
-- (8-ability immunity string + untargetable). The real Loremaster_Dorinan (115015)
-- must stay untouched: the live Thurgadina spell banker keeps no immunities.
SELECT 'v402 vault merchant template (expect 1)' AS what, COUNT(*) AS value
  FROM npc_types WHERE id = 1120002610 AND name = 'Vault Merchant'
    AND merchant_id = 115015 AND is_parcel_merchant = 1 AND untargetable = 1;
SELECT 'v402 vault merchant immunity string (expect 1)' AS what, COUNT(*) AS value
  FROM npc_types WHERE id = 1120002610
    AND special_abilities = '19,1^20,1^24,1^25,1^35,1^47,1^48,1^57,1';
SELECT 'v402 Dorinan still unprotected (expect 1)' AS what, COUNT(*) AS value
  FROM npc_types WHERE id = 115015 AND name = 'Loremaster_Dorinan'
    AND merchant_id = 115015 AND untargetable = 0
    AND (special_abilities = '' OR special_abilities IS NULL);

-- ---- v422: AA rank tail (nine missing terminal ranks) ---------------------------------
SELECT 'v422 aa ranks present (expect 9)' AS what,
       COUNT(*) AS value FROM aa_ranks
 WHERE id IN (13298,13303,8441,13314,13282,8431,10771,14263,13319);
SELECT 'v422 aa rank effects (expect 23)' AS what,
       COUNT(*) AS value FROM aa_rank_effects
 WHERE rank_id IN (13298,13303,8441,13314,13282,8431,10771,14263,13319);
SELECT 'v422 ranks at our cap (expect 9)' AS what,
       COUNT(*) AS value FROM aa_ranks
 WHERE id IN (13298,13303,8441,13314,13282,8431,10771,14263,13319)
   AND level_req = 85 AND expansion = 16;

-- ---- v423: spell id columns widened past the smallint ceiling -------------------------
SELECT 'v423 character_buffs.spell_id (expect int(11))' AS what,
       COLUMN_TYPE AS value FROM information_schema.COLUMNS
 WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'character_buffs' AND COLUMN_NAME = 'spell_id';
SELECT 'v423 narrow spell id columns left (expect 0)' AS what,
       COUNT(*) AS value FROM information_schema.COLUMNS
 WHERE TABLE_SCHEMA = DATABASE()
   AND ((TABLE_NAME='blocked_spells' AND COLUMN_NAME='spellid')
     OR (TABLE_NAME='character_memmed_spells' AND COLUMN_NAME='spell_id')
     OR (TABLE_NAME='character_spells' AND COLUMN_NAME='spell_id')
     OR (TABLE_NAME='ldon_trap_templates' AND COLUMN_NAME='spell_id')
     OR (TABLE_NAME='npc_spells_entries' AND COLUMN_NAME='spellid'))
   AND DATA_TYPE IN ('smallint','mediumint','tinyint');

-- ---- v424: tutorial zone unlocked (last v40 straggler) --------------------------------
SELECT 'v424 tutoriala unlocked (expect 0)' AS what,
       COUNT(*) AS value FROM zone WHERE zoneidnumber = 188 AND min_status = 255;

-- ---- v425: baking rock salt correction (16 rows off Clockwork Observer Boots) ---------
SELECT 'v425 rock salt entries (expect 16)' AS what,
       COUNT(*) AS value FROM tradeskill_recipe_entries
 WHERE item_id = 75856 AND id IN (12394,12437,13396,13422,13431,13456,13464,13487,13503,13521,13530,13578,13701,13732,15147,15164);
SELECT 'v425 boot entries left (expect 0)' AS what,
       COUNT(*) AS value FROM tradeskill_recipe_entries
 WHERE item_id = 65445 AND id IN (12394,12437,13396,13422,13431,13456,13464,13487,13503,13521,13530,13578,13701,13732,15147,15164);

-- ---- v426/v427: spirit shroud catalogue (Imp Wizard + captured forms) ----------------
SELECT 'v426 imp wizard template (expect 1)' AS what,
       COUNT(*) AS value FROM spirit_shroud_templates WHERE id = 20105;
SELECT 'v426 imp wizard links (expect 7)' AS what,
       COUNT(*) AS value FROM spirit_shroud_abilities WHERE template_id = 20105 AND rank_id BETWEEN 48000 AND 48006;
SELECT 'v426 imp wizard aa ranks (expect 7)' AS what,
       COUNT(*) AS value FROM aa_ranks WHERE id BETWEEN 48000 AND 48006;
-- Counts track the latest catalogue migration: v437 (hallucination forms), v439 (ladder
-- backport) and v440 (ladder stats) each grow the catalogue, so 476 / 164 -- the v427-era
-- numbers -- began failing the moment v437 landed. These are bumped to the current state and
-- any migration that adds forms or links must bump them again.
-- The enabled/disabled split is the sharper check: an import that lands entirely disabled
-- passes a total-count test while being invisible to players.
SELECT 'v440 shroud templates total (expect 496)' AS what,
       COUNT(*) AS value FROM spirit_shroud_templates;
SELECT 'v440 shroud templates enabled,disabled (expect 468,28)' AS what,
       CONCAT(SUM(`enabled` = 1), ',', SUM(`enabled` = 0)) AS value FROM spirit_shroud_templates;
SELECT 'v427 catalogue aa ranks (expect 59)' AS what,
       COUNT(*) AS value FROM aa_ranks WHERE id BETWEEN 48100 AND 48158;
SELECT 'v440 catalogue links (expect 35130)' AS what,
       COUNT(*) AS value FROM spirit_shroud_abilities WHERE template_id <> 20105;
SELECT 'v440 catalogue forms with links (expect 468)' AS what,
       COUNT(DISTINCT template_id) AS value FROM spirit_shroud_abilities;

-- ---- v429: four reconstruction tradeskill packages (220 recipes) ---------------------
SELECT 'v429 imported recipes (expect 220)' AS what,
       COUNT(*) AS value FROM tradeskill_recipe WHERE id BETWEEN 9000001 AND 9000220;
SELECT 'v429 imported entries (expect 1056)' AS what,
       COUNT(*) AS value FROM tradeskill_recipe_entries WHERE recipe_id BETWEEN 9000001 AND 9000220;

-- ---- v445: AA rows attached to ranks that do not exist (orphan cleanup) ---------------
-- Both tables are loaded whole at boot, so an orphan row is inert debris that also hides a
-- pruned-rank gap. v445 removed 60 prereq rows and 1 effect row; these keep them gone.
SELECT 'v445 AA orphan prereq rows (expect 0)' AS what,
       COUNT(*) AS value FROM aa_rank_prereqs p LEFT JOIN aa_ranks r ON r.id = p.rank_id WHERE r.id IS NULL;
SELECT 'v445 AA orphan effect rows (expect 0)' AS what,
       COUNT(*) AS value FROM aa_rank_effects e LEFT JOIN aa_ranks r ON r.id = e.rank_id WHERE r.id IS NULL;

-- ---- v448: blind immunity for raid targets and the curated list ----------------------
-- Token 58,1 (SpecialAbility::BlindImmunity) on every raid_target = 1 row at level >= 45
-- outside the SoD band 478700-478749 plus the 78 raid_target = 0 curated-list rows;
-- 14,1 / 17,1 fill the list's charm/fear gaps. Manifest sentinels: 73057, 214083, 39159.
SELECT 'v448 blind-immune raid population (expect 3108)' AS what,
       COUNT(*) AS value
  FROM npc_types
 WHERE level >= 45 AND id NOT BETWEEN 478700 AND 478749
   AND (raid_target = 1 OR id IN (124010,208074,209026,162177,162244,212023,113457,113562,71072,200055,223142,126160,126373,72003,223166,702065,124071,216048,216094,124011,129003,39159,113118,754259,218058,218127,158014,158010,158015,158012,176088,124037,72090,72000,108040,108512,1500000501,406150,162065,162227,71065,96073,96089,217054,217076,218042,218130,128045,128132,128143,491260,72004,86014,86170,452121,1120002003,71021,124105,163057,163075,163097,163156,163231,205091,293214,108043,108517,1500000502,128093,128293,1520000004,300066,216043,76007,151255,186107,223167,227331,2000552,179141,179158,179180,179037,179152,179154,87151,212014,124072,158013,71075,117073,114583,128089,128095,446090,446214,154138,154145,154161,128041,128241,446211,113215,754229,120084,216041,124077,124076,73057,1120002001,124020,124008,159690,159691,124103,124074,220006,220015,32040,1120001072,124017,114106,114586,114618,76011,186111,1120000800,1120000801,206046,206074,308010,309061,306019,304017,307007,128054,128120,128145,251901,305004,351118,421098,218050,218053,128090,128259,1520000001,108047,108513,1500000503,71057,103056,284067,218096,108048,108510,452150,1500000506,64001,293113,293212,291111,291115,291117,291102,103080,103218,212061,71059,300043,300103,223201,103055,214052,214109,223168,725041,214113,212026,212063,176002,211074,207001,223076,124075,201074,201500,94009,94142,452108,1120002004,179032,179157,108050,108509,1500000504,71076,284074,284097,212025,421097,725038,120005,294343,294577,71012,218019,91093,452133,1120002005,214026,214108,223077,1520001313,218038,124104,204065,221008,223075,72002,711088,158008,158016,158125,158011,164078,128043,128243,446210,89154,89181,89196,452079,1120002002,218045,218131,128092,128292,1520000003,127001,127098,202377,298014,298055,158009,214083,214110,214111,214116,214117,214118,214129,223078,223164,1520001314,112025,102112,102126,102134,105182,1120001070,1120001071,128091,128291,1520000002,343094,292068,292069,294595,124155,128042,128242,446213,273736,284092,119112,206067,206068,215056,162190,212055,108053,108511,1500000505,755060,128044,128244,446212,123115,124073,284080))
   AND CONCAT('^', COALESCE(special_abilities,''), '^') REGEXP '(^|\\^)58,1\\^';
SELECT 'v448 in-scope rows still blindable (expect 0)' AS what,
       COUNT(*) AS value
  FROM npc_types
 WHERE level >= 45 AND id NOT BETWEEN 478700 AND 478749
   AND (raid_target = 1 OR id IN (124010,208074,209026,162177,162244,212023,113457,113562,71072,200055,223142,126160,126373,72003,223166,702065,124071,216048,216094,124011,129003,39159,113118,754259,218058,218127,158014,158010,158015,158012,176088,124037,72090,72000,108040,108512,1500000501,406150,162065,162227,71065,96073,96089,217054,217076,218042,218130,128045,128132,128143,491260,72004,86014,86170,452121,1120002003,71021,124105,163057,163075,163097,163156,163231,205091,293214,108043,108517,1500000502,128093,128293,1520000004,300066,216043,76007,151255,186107,223167,227331,2000552,179141,179158,179180,179037,179152,179154,87151,212014,124072,158013,71075,117073,114583,128089,128095,446090,446214,154138,154145,154161,128041,128241,446211,113215,754229,120084,216041,124077,124076,73057,1120002001,124020,124008,159690,159691,124103,124074,220006,220015,32040,1120001072,124017,114106,114586,114618,76011,186111,1120000800,1120000801,206046,206074,308010,309061,306019,304017,307007,128054,128120,128145,251901,305004,351118,421098,218050,218053,128090,128259,1520000001,108047,108513,1500000503,71057,103056,284067,218096,108048,108510,452150,1500000506,64001,293113,293212,291111,291115,291117,291102,103080,103218,212061,71059,300043,300103,223201,103055,214052,214109,223168,725041,214113,212026,212063,176002,211074,207001,223076,124075,201074,201500,94009,94142,452108,1120002004,179032,179157,108050,108509,1500000504,71076,284074,284097,212025,421097,725038,120005,294343,294577,71012,218019,91093,452133,1120002005,214026,214108,223077,1520001313,218038,124104,204065,221008,223075,72002,711088,158008,158016,158125,158011,164078,128043,128243,446210,89154,89181,89196,452079,1120002002,218045,218131,128092,128292,1520000003,127001,127098,202377,298014,298055,158009,214083,214110,214111,214116,214117,214118,214129,223078,223164,1520001314,112025,102112,102126,102134,105182,1120001070,1120001071,128091,128291,1520000002,343094,292068,292069,294595,124155,128042,128242,446213,273736,284092,119112,206067,206068,215056,162190,212055,108053,108511,1500000505,755060,128044,128244,446212,123115,124073,284080))
   AND CONCAT('^', COALESCE(special_abilities,''), '^') NOT REGEXP '(^|\\^)58,1\\^';
SELECT 'v448 list blind-immune (expect 291)' AS what,
       COUNT(*) AS value
  FROM npc_types
 WHERE id IN (124010,208074,209026,162177,162244,212023,113457,113562,71072,200055,223142,126160,126373,72003,223166,702065,124071,216048,216094,124011,129003,39159,113118,754259,218058,218127,158014,158010,158015,158012,176088,124037,72090,72000,108040,108512,1500000501,406150,162065,162227,71065,96073,96089,217054,217076,218042,218130,128045,128132,128143,491260,72004,86014,86170,452121,1120002003,71021,124105,163057,163075,163097,163156,163231,205091,293214,108043,108517,1500000502,128093,128293,1520000004,300066,216043,76007,151255,186107,223167,227331,2000552,179141,179158,179180,179037,179152,179154,87151,212014,124072,158013,71075,117073,114583,128089,128095,446090,446214,154138,154145,154161,128041,128241,446211,113215,754229,120084,216041,124077,124076,73057,1120002001,124020,124008,159690,159691,124103,124074,220006,220015,32040,1120001072,124017,114106,114586,114618,76011,186111,1120000800,1120000801,206046,206074,308010,309061,306019,304017,307007,128054,128120,128145,251901,305004,351118,421098,218050,218053,128090,128259,1520000001,108047,108513,1500000503,71057,103056,284067,218096,108048,108510,452150,1500000506,64001,293113,293212,291111,291115,291117,291102,103080,103218,212061,71059,300043,300103,223201,103055,214052,214109,223168,725041,214113,212026,212063,176002,211074,207001,223076,124075,201074,201500,94009,94142,452108,1120002004,179032,179157,108050,108509,1500000504,71076,284074,284097,212025,421097,725038,120005,294343,294577,71012,218019,91093,452133,1120002005,214026,214108,223077,1520001313,218038,124104,204065,221008,223075,72002,711088,158008,158016,158125,158011,164078,128043,128243,446210,89154,89181,89196,452079,1120002002,218045,218131,128092,128292,1520000003,127001,127098,202377,298014,298055,158009,214083,214110,214111,214116,214117,214118,214129,223078,223164,1520001314,112025,102112,102126,102134,105182,1120001070,1120001071,128091,128291,1520000002,343094,292068,292069,294595,124155,128042,128242,446213,273736,284092,119112,206067,206068,215056,162190,212055,108053,108511,1500000505,755060,128044,128244,446212,123115,124073,284080)
   AND CONCAT('^', COALESCE(special_abilities,''), '^') REGEXP '(^|\\^)58,1\\^';
SELECT 'v448 list charm-immune (expect 291)' AS what,
       COUNT(*) AS value
  FROM npc_types
 WHERE id IN (124010,208074,209026,162177,162244,212023,113457,113562,71072,200055,223142,126160,126373,72003,223166,702065,124071,216048,216094,124011,129003,39159,113118,754259,218058,218127,158014,158010,158015,158012,176088,124037,72090,72000,108040,108512,1500000501,406150,162065,162227,71065,96073,96089,217054,217076,218042,218130,128045,128132,128143,491260,72004,86014,86170,452121,1120002003,71021,124105,163057,163075,163097,163156,163231,205091,293214,108043,108517,1500000502,128093,128293,1520000004,300066,216043,76007,151255,186107,223167,227331,2000552,179141,179158,179180,179037,179152,179154,87151,212014,124072,158013,71075,117073,114583,128089,128095,446090,446214,154138,154145,154161,128041,128241,446211,113215,754229,120084,216041,124077,124076,73057,1120002001,124020,124008,159690,159691,124103,124074,220006,220015,32040,1120001072,124017,114106,114586,114618,76011,186111,1120000800,1120000801,206046,206074,308010,309061,306019,304017,307007,128054,128120,128145,251901,305004,351118,421098,218050,218053,128090,128259,1520000001,108047,108513,1500000503,71057,103056,284067,218096,108048,108510,452150,1500000506,64001,293113,293212,291111,291115,291117,291102,103080,103218,212061,71059,300043,300103,223201,103055,214052,214109,223168,725041,214113,212026,212063,176002,211074,207001,223076,124075,201074,201500,94009,94142,452108,1120002004,179032,179157,108050,108509,1500000504,71076,284074,284097,212025,421097,725038,120005,294343,294577,71012,218019,91093,452133,1120002005,214026,214108,223077,1520001313,218038,124104,204065,221008,223075,72002,711088,158008,158016,158125,158011,164078,128043,128243,446210,89154,89181,89196,452079,1120002002,218045,218131,128092,128292,1520000003,127001,127098,202377,298014,298055,158009,214083,214110,214111,214116,214117,214118,214129,223078,223164,1520001314,112025,102112,102126,102134,105182,1120001070,1120001071,128091,128291,1520000002,343094,292068,292069,294595,124155,128042,128242,446213,273736,284092,119112,206067,206068,215056,162190,212055,108053,108511,1500000505,755060,128044,128244,446212,123115,124073,284080)
   AND CONCAT('^', COALESCE(special_abilities,''), '^') REGEXP '(^|\\^)14,1\\^';
SELECT 'v448 list fear-immune (expect 291)' AS what,
       COUNT(*) AS value
  FROM npc_types
 WHERE id IN (124010,208074,209026,162177,162244,212023,113457,113562,71072,200055,223142,126160,126373,72003,223166,702065,124071,216048,216094,124011,129003,39159,113118,754259,218058,218127,158014,158010,158015,158012,176088,124037,72090,72000,108040,108512,1500000501,406150,162065,162227,71065,96073,96089,217054,217076,218042,218130,128045,128132,128143,491260,72004,86014,86170,452121,1120002003,71021,124105,163057,163075,163097,163156,163231,205091,293214,108043,108517,1500000502,128093,128293,1520000004,300066,216043,76007,151255,186107,223167,227331,2000552,179141,179158,179180,179037,179152,179154,87151,212014,124072,158013,71075,117073,114583,128089,128095,446090,446214,154138,154145,154161,128041,128241,446211,113215,754229,120084,216041,124077,124076,73057,1120002001,124020,124008,159690,159691,124103,124074,220006,220015,32040,1120001072,124017,114106,114586,114618,76011,186111,1120000800,1120000801,206046,206074,308010,309061,306019,304017,307007,128054,128120,128145,251901,305004,351118,421098,218050,218053,128090,128259,1520000001,108047,108513,1500000503,71057,103056,284067,218096,108048,108510,452150,1500000506,64001,293113,293212,291111,291115,291117,291102,103080,103218,212061,71059,300043,300103,223201,103055,214052,214109,223168,725041,214113,212026,212063,176002,211074,207001,223076,124075,201074,201500,94009,94142,452108,1120002004,179032,179157,108050,108509,1500000504,71076,284074,284097,212025,421097,725038,120005,294343,294577,71012,218019,91093,452133,1120002005,214026,214108,223077,1520001313,218038,124104,204065,221008,223075,72002,711088,158008,158016,158125,158011,164078,128043,128243,446210,89154,89181,89196,452079,1120002002,218045,218131,128092,128292,1520000003,127001,127098,202377,298014,298055,158009,214083,214110,214111,214116,214117,214118,214129,223078,223164,1520001314,112025,102112,102126,102134,105182,1120001070,1120001071,128091,128291,1520000002,343094,292068,292069,294595,124155,128042,128242,446213,273736,284092,119112,206067,206068,215056,162190,212055,108053,108511,1500000505,755060,128044,128244,446212,123115,124073,284080)
   AND CONCAT('^', COALESCE(special_abilities,''), '^') REGEXP '(^|\\^)17,1\\^';

-- v476 dual-charm pets: absolute cap, both bag items, all six merchantlist rows,
-- and the two world-boot-injected rule rows
SELECT 'v476 AbsolutePetLimit (expect 15)' AS what, rule_value AS value FROM rule_values WHERE rule_name = 'Custom:AbsolutePetLimit' AND ruleset_id = 1;
SELECT 'v476 dual satchels present (expect 2)' AS what, COUNT(*) AS value FROM items WHERE id IN (899989, 899990) AND name LIKE '%Dual Syncrosatchel%';
SELECT 'v476+479 dual satchel merchant rows (expect 12)' AS what, COUNT(*) AS value FROM merchantlist WHERE item IN (899989, 899990);
SELECT 'v476 dual-charm rules injected (expect 2)' AS what, COUNT(*) AS value FROM rule_values WHERE rule_name IN ('Custom:BardDualCharmPets', 'Custom:EnchanterTwoPets');
SELECT 'v479 dual satchel slots (expect 2)' AS what, COUNT(*) AS value FROM items WHERE id IN (899989, 899990) AND bagslots = 8;


-- v484-v488 GoD fixes (2026-11-22). Run after a world boot applies the migrations.
SELECT 'v484 Bury/Strike stun, not FD (expect 2)' AS what, COUNT(*) AS value
  FROM spells_new WHERE id IN (5001, 5010) AND effectid2 = 21 AND effect_base_value2 = 1000;
SELECT 'v484 Bazu/Murk 350pct (expect 2)' AS what, COUNT(*) AS value
  FROM spells_new WHERE id IN (6457, 6458) AND effect_base_value1 = 350;
SELECT 'v484 Spiritual Possession counters (expect 6)' AS what, COUNT(*) AS value
  FROM spells_new WHERE id = 891 AND effect_base_value7 = 1 AND effect_base_value12 = 1;
SELECT 'v485 task text fixes (expect 4)' AS what,
  (SELECT COUNT(*) FROM tasks WHERE id=15 AND description LIKE '%restored power to the Depleted Clockwork Power Pack%') +
  (SELECT COUNT(*) FROM tasks WHERE id=27 AND description LIKE '%[2,Enter the Purifying Plant and locate Ansharu within.]%') +
  (SELECT COUNT(*) FROM tasks WHERE id=32 AND description LIKE '%Stonespiritist Ekikoa%') +
  (SELECT COUNT(*) FROM tasks WHERE id=33 AND completion_emote LIKE '%made your way through Tipt%') AS value;
SELECT 'v486 Destructive Protection unequippable (expect 12)' AS what, COUNT(*) AS value
  FROM items WHERE id IN (67736,67737,67738,67739,1067736,1067737,1067738,1067739,2067736,2067737,2067738,2067739) AND slots = 0;
SELECT 'v486 Kod'taz see-all NPCs (expect 6)' AS what, COUNT(*) AS value
  FROM npc_types WHERE id IN (293114,293115,293116,293117,293118,293119) AND see_invis = 100 AND see_improved_hide = 1;
SELECT 'v487/v488 task variant turn-ins (expect >120)' AS what, COUNT(*) AS value
  FROM task_activities WHERE item_id_list REGEXP '(^|,)1[0-9]{6}' AND item_id_list REGEXP '(^|,)2[0-9]{6}';


SELECT 'v490 Wrath of the Ikaav no FD (expect 1)' AS what, COUNT(*) AS value
  FROM spells_new WHERE id = 888 AND effectid3 = 254;


SELECT 'v491 GoD base+enchanted heroics (expect 128)' AS what, COUNT(*) AS value
  FROM items i JOIN (SELECT 68810 id UNION ALL SELECT 1068810 UNION ALL SELECT 68811 UNION ALL SELECT 1068811) x
    ON i.id = x.id
 WHERE i.heroic_str > 0 OR i.heroic_sta > 0 OR i.heroic_agi > 0;


SELECT 'v492 GoD guide clicky (expect 1)' AS what, COUNT(*) AS value
  FROM items WHERE id = 9015301 AND clickeffect = 7652;
SELECT 'v493 Kod'taz 16h events (expect 3)' AS what, COUNT(*) AS value
  FROM spawn2 WHERE id IN (264345,45000632,137085) AND respawntime = 57600;
SELECT 'v493 Kod'taz ground spawns all versions (expect 14)' AS what, COUNT(*) AS value
  FROM ground_spawns WHERE zoneid = 293 AND version = -1;
SELECT 'v493 Forlorn Relic Devotees (expect 8 new spawns)' AS what, COUNT(*) AS value
  FROM spawn2 WHERE spawngroupID BETWEEN 39040 AND 39047;
