-- ============================================================================
-- The Provisioner (Bazaar) -- NPC that hands out gear from the adventurer pool
-- Date: 2026-10-10
--
-- Water elemental in the Bazaar who gives one suitable piece of donated gear
-- per account every 8 hours, matched to an empty equipment slot. The quest
-- script is quests/bazaar/The_Provisioner.pl.
--
-- npc_types.id 1120001417, spawngroup 5004102, zone 'bazaar' at (68, -786, 3).
-- Idempotent. Twin of ManifestEntry .version = 104 in
-- common/database/database_update_manifest_custom.cpp
-- ============================================================================

DELETE FROM `spawnentry` WHERE `spawngroupID` = 5004102;
DELETE FROM `spawn2`      WHERE `spawngroupID` = 5004102;
DELETE FROM `spawngroup`  WHERE `id` = 5004102;
DELETE FROM `npc_types`   WHERE `id` = 1120001417;

INSERT INTO `npc_types` (
  `id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`,
  `gender`, `texture`, `size`, `runspeed`, `see_invis`, `qglobal`, `npc_spells_id`,
  `npc_faction_id`, `merchant_id`, `loottable_id`, `findable`, `trackable`, `isquest`
) VALUES (
  1120001417, 'The_Provisioner', 'Keeper of Gifts', 70, 75, 1, 24, 100000, 0,
  2, 2, 6, 0, 1, 0, 0,
  0, 0, 0, 1, 1, 1
);

INSERT INTO `spawngroup` (`id`, `name`, `spawn_limit`, `dist`, `delay`, `mindelay`, `despawn`)
VALUES (5004102, 'bazaar-The_Provisioner', 0, 0, 45000, 15000, 0);

INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`)
VALUES (5004102, 1120001417, 100);

INSERT INTO `spawn2` (
  `spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`,
  `respawntime`, `variance`, `pathgrid`, `_condition`, `cond_value`,
  `animation`, `min_expansion`, `max_expansion`
) VALUES (
  5004102, 'bazaar', 0, 68, -786, 3, 0,
  640, 0, 0, 0, 1,
  0, -1, -1
);
