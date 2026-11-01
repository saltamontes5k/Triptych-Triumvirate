-- ============================================================================
-- 2026-11-01: drop the backup/scratch table family from the live peq DB
-- ============================================================================
-- NOT a content migration: no manifest entry, no db_version bump, no restart,
-- no shared-memory rebuild. These tables are never read by world/zone.
--
-- All 27 tables were CREATE TABLE ... AS SELECT rollback snapshots taken before
-- spawn/content moves that have since been live and verified:
--   * DoN-camp / PoK-porter / PoK-priest spawn moves (2026-09-29 -> 10-02),
--     re-verified by the DoN audit 2026-10-05. Sources documenting them as
--     restore points: utils/sql/20260929_lavastorm_don_camp_z33.sql,
--     Release-NMS-Quests/utility/sql_scripts/don_camp_and_pok_ports.sql.
--   * Lavastorm void spawn fix (2026-10-12): spawn2_bak_20261012_lavastorm_void.
--   * AA dedupe / level-req banding (2026-10-04 / 2026-10-13): the
--     aa_*_backup_20261004 set and aa_ranks_lvlreq_bak_20261013.
--     ROLLBACK for the banding was utils/sql/20261013_aa_level_req_banding_rollback.sql,
--     which read from aa_ranks_lvlreq_bak_20261013 — that rollback path is now
--     gone with the table.
--   * Untracked session snapshots (2026-10-13): bak_20261013_disco_assoc,
--     bak_20261013_disco_nt, items_bakglamor (items-wide snapshot taken before
--     the glamour/ornament augtype normalize, v148).
--   * PoW PoP-ized retune (2026-10-24): bk_20261024_powar_{npc_types,items,spawn2}.
--   * Classic expansion achievements batch (2026-10-25): nms_ach_copper_triune_backup
--     (8 rows of the `rewards` table).
--   * Scratch: tradeskill_recipe_entries_backup_7_16_2023, new_table.
--
-- Kept: merchantlist_temp (the local Spire admin tool has an auto-generated
-- controller/model targeting it; the release flow already drops it on staging).
--
-- CAVEAT for stale-dump rebuilds: manifest entry v149
-- (20261013_aa_level_req_banding) uses the EXISTENCE of aa_ranks_lvlreq_bak_20261013
-- as its applicability check. Live db_version.custom_version was 301 at drop
-- time, so no boot ever re-evaluates it. Only if a dump with custom_version < 149
-- were ever re-imported would v149 re-run (and its ascending-band re-catch would
-- sweep already-banded aa_ranks rows down a tier). The shipped release zip has
-- custom_version >= 160, so that path is unreachable in practice.
--
-- Pre-drop safety copy: Temp\opencode\bak_tables_dump_20261101.sql (all 27
-- tables, ~40 MB). Post-drop verified: zero matches for %bak%/%backup%/bk_%/
-- new_table; spawn2/spawngroup/spawnentry/npc_types/aa_ranks/rewards row
-- counts identical before and after; db_version.custom_version unchanged.
-- ============================================================================

DROP TABLE IF EXISTS aa_ranks_expansion_backup_20261004;
DROP TABLE IF EXISTS aa_ranks_lvlreq_bak_20261013;
DROP TABLE IF EXISTS aa_ranks_orphan_fom2_backup_20261004;
DROP TABLE IF EXISTS aa_ranks_stale_backup_20261004;
DROP TABLE IF EXISTS aa_rank_effects_orphan_fom2_backup_20261004;
DROP TABLE IF EXISTS aa_rank_effects_stale_backup_20261004;
DROP TABLE IF EXISTS aa_rank_prereqs_orphan_fom2_backup_20261004;
DROP TABLE IF EXISTS aa_rank_prereqs_stale_backup_20261004;
DROP TABLE IF EXISTS bak_20261013_disco_assoc;
DROP TABLE IF EXISTS bak_20261013_disco_nt;
DROP TABLE IF EXISTS bk_20261024_powar_items;
DROP TABLE IF EXISTS bk_20261024_powar_npc_types;
DROP TABLE IF EXISTS bk_20261024_powar_spawn2;
DROP TABLE IF EXISTS items_bakglamor;
DROP TABLE IF EXISTS new_table;
DROP TABLE IF EXISTS nms_ach_copper_triune_backup;
DROP TABLE IF EXISTS npc_types_bak_pok_priest_202534;
DROP TABLE IF EXISTS spawn2_bak_20260929_don_camp;
DROP TABLE IF EXISTS spawn2_bak_20261012_lavastorm_void;
DROP TABLE IF EXISTS spawn2_bak_don_camps_v0_2026;
DROP TABLE IF EXISTS spawn2_bak_don_pok_2026;
DROP TABLE IF EXISTS spawn2_bak_pok_priest_202534;
DROP TABLE IF EXISTS spawnentry_bak_don_camps_v0_2026;
DROP TABLE IF EXISTS spawnentry_bak_pok_priest_202534;
DROP TABLE IF EXISTS spawngroup_bak_don_camps_v0_2026;
DROP TABLE IF EXISTS spawngroup_bak_pok_priest_202534;
DROP TABLE IF EXISTS tradeskill_recipe_entries_backup_7_16_2023;
