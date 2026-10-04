-- ============================================================================
-- Ascendant Shard drops only from actual named raid targets (global-loot rule)
-- Date: 2026-10-07
-- Follow-up to 20261003_ascendant_tome_shard_drops (v99).
--
-- v99 gated the shard (global_loot id 178717) on `raid` = 1, which matches
-- npc_types.raid_target. That set also contains trigger / trap / chest objects,
-- so shards dropped from them:
--   #Trap_Uqua_*, #Gas_Chamber_*, #Door_Cheater_*, #Trigger_Ikkinz_*,
--   #curse_trigger, #noqufiel_trigger, Dresolik_Trigger, #COD_Trigger,
--   lockout_ikkinz, lockout_uqua, the *_Spawner controllers
--   (#Awisano/#Birak/#Galronar/#Warlord_Spawner, Tarn_Icewind_Spawner,
--   Area4spawner), Rhorious_Chest_Spawner (untargetable), and the
--   Treasure_of_* raid chests.
--
-- Fix: gate on the canonical named flag instead -- global_loot.rare = 1 maps
-- to npc_types.rare_spawn (zone/global_loot_manager.cpp PassesRules). Backfill
-- rare_spawn on the real named raid targets and drop the object/trigger names.
--
-- NOTE: a blanket '#'-prefix exclusion is deliberately NOT used. EQS names many
-- genuine bosses with '#" (#Overlord_Mata_Muram, #The_Fabled_Warlord,_Rallos_Zek,
-- #Brell_Serilis, #Rottrued_the_Twisted, ...), so a '#' rule would suppress the
-- shard on the very bosses it should drop from.
--
-- rare_spawn has no side effect here: for raid_target mobs the scale manager
-- (npc_scale_manager.cpp GetNPCScalingType) returns "Raid" before it ever reads
-- rare_spawn, and no other global_loot rule uses a non-zero `rare`.
--
-- Idempotent. Twin of ManifestEntry .version = 101 in
-- common/database/database_update_manifest_custom.cpp
-- ============================================================================

UPDATE `global_loot` SET `rare` = 1 WHERE `id` = 178717;

UPDATE `npc_types`
   SET `rare_spawn` = 1
 WHERE `raid_target` = 1
   AND `untargetable` = 0
   AND `hp` >= 1000
   AND `name` NOT LIKE '%Trap%'
   AND `name` NOT LIKE '%Trigger%'
   AND `name` NOT LIKE '%Gas_Chamber%'
   AND `name` NOT LIKE '%Door%'
   AND `name` NOT LIKE '%Cheater%'
   AND `name` NOT LIKE 'lockout%'
   AND `name` NOT LIKE '%Spawner%'
   AND `name` NOT LIKE '%controller%'
   AND `name` NOT LIKE 'Treasure_of_%';
