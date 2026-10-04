-- ============================================================================
-- Secrets of Faydwer — Meldrath's Majestic Mansion raid expedition (2026-09-26)
--
-- Rasper reference: raspersrealm.com/Everquest/SoF/raidMMM.html
--   * Requested from Clockwork Warmarshal (436010, Fortress Mechanotus),
--     phrase "Wish to have the honors"; 54-person raid; entry = mansion door
--     (OBJ_MMC_MAINDR, doorid 3) in the northeast of Mechanotus.
--   * The raid lives in an INSTANCE of mechanotus (version 1) — the world
--     zone (v0) is low level and gets no raid content. Zone v0 is untouched.
--
-- Content modelled this pass:
--   Sixton Farqudot opener -> Meldrath phase 1 (adds: patchwork obliterators,
--   emergency repair mechanics, malaise/tick-tock scripted AEs) -> 40%
--   transition -> steamsuited Meldrath + elite troopers (+ support-unit AE,
--   buzzkills at 15%) -> Treasure of Meldrath + per-character
--   sof_meldrath_defeated bucket (gates Little Bo's Rk. III vendor stock).
--   The five earlier MMM events (Breakneck, Battle Room, Brinda, Krond,
--   Bargangle) are NOT implemented yet — documented in
--   docs/sof-faction-calibration.md.
--
-- Script side: quests/mechanotus/{436010,365034,460500,460506,460507}.lua
-- (the Sixton opener script is 460500.lua -- it was originally misfiled as
-- 365100.lua, which npc id the engine would never bind to #Sixton_Farqudot).
-- Idempotent: UPDATEs converge; INSERTs use explicit ids verified free.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Raid boss stats (365034 was a bare PEQ stub: 15k hp, cleric, maxdmg 4)
-- ---------------------------------------------------------------------------
UPDATE `npc_types` SET
	`class` = 1, `hp` = 2200000, `maxdmg` = 5500, `AC` = 576, `ATK` = 250,
	`Accuracy` = 250, `attack_speed` = 0, `slow_mitigation` = 80,
	`aggroradius` = 0, `assistradius` = 0, `special_abilities` =
	'1,1^4,1^8,1^13,1^14,1^15,1^16,1^17,1^21,1^24,1^31,1',
	`see_invis` = 1, `MR` = 150, `CR` = 150, `DR` = 150, `FR` = 150, `PR` = 150,
	`raid_target` = 1, `spawn_limit` = 0
WHERE `id` = 365034;

-- ---------------------------------------------------------------------------
-- 2. Encounter NPCs (ids verified free; stats follow this server's authored
--    raid-boss envelope — see #Remal_the_Black 35165)
-- ---------------------------------------------------------------------------
INSERT INTO `npc_types`
	(`id`, `name`, `lastname`, `level`, `race`, `class`, `hp`, `gender`, `texture`,
	 `size`, `npc_faction_id`, `mindmg`, `maxdmg`, `AC`, `ATK`, `Accuracy`,
	 `slow_mitigation`, `aggroradius`, `special_abilities`, `runspeed`, `raid_target`,
	 `isquest`, `show_name`, `findable`)
VALUES
	-- Sixton Farqudot: opener mini-boss, hits ~6.5k on live
	(460500, '#Sixton_Farqudot', '', 75, 577, 1, 450000, 0, 2, 4, 1520000073,
	 50, 4200, 550, 220, 220, 50, 70, '1,1^4,1^8,1^13,1^14,1^15,1^16,1^17,1^21,1', 1.25, 1, 0, 1, 0),
	-- Patchwork obliterators: mezzable add stream (phase 1)
	(460501, '#a_patchwork_obliterator', '', 75, 570, 1, 130000, 0, 1, 12, 1520000073,
	 50, 3200, 500, 180, 180, 0, 70, '', 1.25, 0, 0, 1, 0),
	-- Tormented revenant: punish add (spawned periodically during phase 1)
	(460502, 'a_tormented_revenant', '', 73, 12, 1, 90000, 0, 0, 6, 1520000073,
	 50, 2600, 480, 170, 170, 0, 0, '', 1.25, 0, 0, 1, 0),
	-- Emergency repair mechanic: channels heals into Meldrath until killed
	(460503, 'an_emergency_repair_mechanic', '', 75, 577, 1, 160000, 0, 1, 4, 1520000073,
	 50, 1000, 500, 150, 150, 0, 0, '', 1.25, 0, 0, 1, 0),
	-- Steamwork buzzkills: mezzable swarm at 15% of phase 2
	(460504, '#a_steamwork_buzzkill', '', 78, 457, 1, 110000, 0, 3, 3, 1520000073,
	 50, 3000, 520, 180, 180, 0, 70, '', 1.25, 0, 0, 1, 0),
	-- Elite troopers: hostile flankers of phase-2 steamsuited Meldrath
	(460505, 'an_elite_trooper', '', 80, 457, 1, 280000, 0, 4, 5, 1520000073,
	 50, 5000, 560, 220, 220, 80, 70, '1,1^4,1^8,1^13,1^14,1^15,1^16,1^17,1^21,1', 1.25, 0, 0, 1, 0),
	-- Phase 2: Meldrath in the steamsuit (passive until troopers fall)
	(460506, '#Meldrath_the_Malignant_steamsuited', 'Meldrath the Malignant', 75, 570, 1,
	 1700000, 0, 1, 14, 1520000073, 50, 6000, 576, 250, 250, 80, 0,
	 '1,1^4,1^8,1^13,1^14,1^15,1^16,1^17,1^21,1^24,1^31,1', 1.25, 1, 0, 1, 0),
	-- Treasure: hail-chest granting the Meldrath chest loot
	(460507, 'Treasure_of_Meldrath', '', 75, 574, 1, 5, 0, 1, 3, 0,
	 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 1, 1, 0);

-- ---------------------------------------------------------------------------
-- 3. Instance spawns (mechanotus version 1 — the mansion hall at z~678,
--    just past OBJ_MMC_MAINDR). v0 spawns are NOT touched.
-- ---------------------------------------------------------------------------
DELETE FROM `spawnentry` WHERE `spawngroupID` IN (990101, 990102);
DELETE FROM `spawn2` WHERE `spawngroupID` IN (990101, 990102);
DELETE FROM `spawngroup` WHERE `id` IN (990101, 990102);

INSERT INTO `spawngroup`
	(`id`, `name`, `spawn_limit`, `delay`, `mindelay`, `despawn`)
VALUES
	(990101, 'mmm_sixton', 1, 28800, 28800, 0),
	(990102, 'mmm_meldrath_p1', 1, 28800, 28800, 0);

INSERT INTO `spawnentry` (`spawngroupID`, `npcID`, `chance`) VALUES
	(990101, 460500, 100),
	(990102, 365034, 100);

INSERT INTO `spawn2`
	(`spawngroupID`, `zone`, `version`, `x`, `y`, `z`, `heading`, `respawntime`, `_condition`, `cond_value`)
VALUES
	(990101, 'mechanotus', 1, 14, 1545, 678.05, 0, 28800, 0, 1),
	(990102, 'mechanotus', 1, 14, 1620, 678.05, 0, 28800, 0, 1);

-- ---------------------------------------------------------------------------
-- 4. Entry door: OBJ_MMC_MAINDR (doorid 3) in mechanotus becomes the
--    expedition dz switch 2100 (v0 world copy + v1 instance copy)
-- ---------------------------------------------------------------------------
UPDATE `doors` SET `dz_switch_id` = 2100 WHERE `zone` = 'mechanotus' AND `doorid` = 3;
