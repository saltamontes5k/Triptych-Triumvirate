-- ============================================================================
-- SoF faction wiring — Secrets of Faydwer player-faction block, phase 0
--
-- Problem (audited 2026-09-23):
--   * The 2026-09 faction overhaul created correctly-primed npc_faction rows
--     for the SoF player factions but left npc_faction_entries EMPTY, so kill
--     credit is dead SoF-wide (SetFactionLevel early-returns on an empty
--     entries list — zone/client.cpp:9846).
--   * Task givers and faction vendors are stranded on hostile mob groups
--     (1520000073 "Minions of Meldrath") or on npc_faction_id=0, so vendor
--     gating (client_packet.cpp:2221 checks the NPC's PRIMARY faction) can
--     never key on the intended player faction.
--   * No npc_faction group exists at all for Ak`Anon Strike Force (1190).
--   * Crystallos trash sits on npc_faction 526 (Melalafen / Loping wildlife),
--     so any CoV kill credit there would mis-credit festival critters.
--
-- Fix:
--   1. New group 1520000091 for Ak`Anon Strike Force NPCs (no kill entries —
--      ASF gains faction from tasks only, per live-era design).
--   2. New group 1520000092 for Crystallos denizens (preserves the old con
--      primary 526; gains Crusaders of Veeshan kill credit).
--   3. Repoint task givers + faction vendors onto their faction's group.
--   4. Add kill-credit entries for the documented sources:
--        steamworks + Dragonscale minotaurs (1520000073) -> Brownie Rebels
--        Guardian Defense Forces trash   (1520000076) -> Ladies of the Light
--        Wind nymphs                     (1520000075) -> Ladies of the Light
--        Crystallos denizens             (1520000092) -> Crusaders of Veeshan
--   Deferred: Fang Breakers per-kill credit (group 1520000074 mixes wereorcs
--   with neutral wildlife and quest NPCs; revisit with the Phase 1 name audit
--   — Fang tasks/missions alone provide ~+700, so nothing is blocked).
--
-- Kill-credit conventions copied from working classic rows (e.g. npc_faction
-- 92/97): gains = positive value, npc_value 0; the mob's own-faction hit =
-- negative value, npc_value 1.
--
-- Idempotent: explicit primary keys + INSERT IGNORE; UPDATEs converge.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. New npc_faction groups
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO `npc_faction` (`id`, `name`, `primaryfaction`, `ignore_primary_assist`) VALUES
	(1520000091, 'sof_1190_akanon_strike_force', 1190, 0),
	(1520000092, 'sof_1188_crystallos_denizens', 526, 0);

-- ---------------------------------------------------------------------------
-- 2. Repoint task givers + vendors onto their faction groups
-- ---------------------------------------------------------------------------

-- Ak`Anon Strike Force (1190): Fortress Mechanotus + Dragonscale givers/vendors
UPDATE `npc_types` SET `npc_faction_id` = 1520000091 WHERE `id` IN (
	-- Mechanotus: Cogwittle, Springfap, Gurtrude, Gearpaq, Gearflinger,
	--             Flizcog, Warmarshal, Cogsloose, Diggleknob
	436000, 436001, 436003, 436004, 436006, 436007, 436010, 436011, 436012,
	-- Dragonscale: Derek Wolfblood, Vending Unit V, Overvolt Rigster IV,
	--             Supplier Mark LXXXVIII, Vending Unit II, Mamenil, Nanzie,
	--             Bobbenpin, Sigglik, Brislebum
	442005, 442006, 442008, 442009, 442012, 442013, 442014, 442015, 442017, 442018
);

-- Ladies of the Light (1185): Fenden Helter, Qandieal, Erradien, Seridyn (vendor)
-- (Kaerra 442105 and Patron of the Arts 443009 are already on 1520000067)
UPDATE `npc_types` SET `npc_faction_id` = 1520000067 WHERE `id` IN (
	442096, 442099, 442100, 442104
);

-- Crusaders of Veeshan (1188): Sydria the Elder, Tonas, Jashy, Vesiss, Aring
-- (Dwindlix 442007 is already on 1520000068)
UPDATE `npc_types` SET `npc_faction_id` = 1520000068 WHERE `id` IN (
	442032, 442048, 442102, 442120, 442140
);

-- Brownie Rebels (1189): Karri, Millick, Little Bo, Gymrie, Lymrit
UPDATE `npc_types` SET `npc_faction_id` = 1520000069 WHERE `id` IN (
	438007, 438011, 438013, 438018, 438019
);

-- Crystallos trash: off the Melalafen grab-bag group, onto the dedicated group
UPDATE `npc_types` SET `npc_faction_id` = 1520000092
WHERE `npc_faction_id` = 526 AND `id` BETWEEN 446000 AND 446199;

-- ---------------------------------------------------------------------------
-- 3. Kill credit entries
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO `npc_faction_entries`
	(`npc_faction_id`, `faction_id`, `value`, `npc_value`, `temp`) VALUES
	-- Minions of Meldrath (steamworks, Dragonscale minotaurs): -> Brownie Rebels
	(1520000073, 1189,   5, 0, 0),
	(1520000073, 1194,  -5, 1, 0),
	-- Guardian Defense Forces trash: -> Ladies of the Light
	(1520000076, 1185,   5, 0, 0),
	(1520000076, 1198,  -5, 1, 0),
	-- Wind nymphs: -> Ladies of the Light
	(1520000075, 1185,   5, 0, 0),
	(1520000075, 1197,  -5, 1, 0),
	-- Crystallos denizens: -> Crusaders of Veeshan
	(1520000092, 1188,   5, 0, 0),
	(1520000092,  526,  -5, 1, 0);
