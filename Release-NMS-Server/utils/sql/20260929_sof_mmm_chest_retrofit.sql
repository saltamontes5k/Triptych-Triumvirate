-- ============================================================================
-- Secrets of Faydwer -- Meldrath's Majestic Mansion raid chest retrofit.
--
-- The MMM win chest (Treasure_of_Meldrath, 460507) shipped as a hail NPC that
-- granted per-character loot via SummonItem + a claim bucket. The Steam Factory
-- chests use the Anguish/Solteris convention -- a punchable Ornate_Chest whose
-- loot lives on a loottable and is protected by an expedition loot event. This
-- brings 460507 onto the same convention.
--
--   * 460507 becomes a clone of the Anguish Ornate_Chest (race 378, class 62,
--     hp 7375) carrying loottable 1520007740.
--   * 1520007740: 12x Oil Stained Crystal (36621) + one of five armor pieces
--     + a 10% Prismatic Faycite (37445) -- the exact payload the hail granted.
--   * 460506.lua spawns it with eq.unique_spawn + SetLootEventBySpawnID.
--
-- Idempotent. Script side: quests/mechanotus/460506.lua + 460507.lua.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Chest NPC -> punchable Ornate_Chest clone
-- ---------------------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS sof_mmm_chest;
CREATE TEMPORARY TABLE sof_mmm_chest AS SELECT * FROM npc_types WHERE id = 317112;
UPDATE sof_mmm_chest SET id = 460507, name = 'Treasure_of_Meldrath',
    loottable_id = 1520007740, npc_faction_id = 0 WHERE id = 317112;
DELETE FROM `npc_types` WHERE `id` = 460507;
INSERT INTO `npc_types` SELECT * FROM sof_mmm_chest;
DROP TEMPORARY TABLE sof_mmm_chest;

-- ---------------------------------------------------------------------------
-- 2. Chest loot (1520007740-1520007742)
-- ---------------------------------------------------------------------------
DELETE FROM `loottable_entries` WHERE `loottable_id` BETWEEN 1520007740 AND 1520007749;
DELETE FROM `lootdrop_entries` WHERE `lootdrop_id` BETWEEN 1520007740 AND 1520007749;
DELETE FROM `lootdrop` WHERE `id` BETWEEN 1520007740 AND 1520007749;
DELETE FROM `loottable` WHERE `id` BETWEEN 1520007740 AND 1520007749;

INSERT INTO `loottable` (`id`,`name`,`mincash`,`maxcash`,`avgcoin`) VALUES
(1520007740,'SoF_MMM_Meldrath_Chest',80000,160000,80000);
INSERT INTO `lootdrop` (`id`,`name`) VALUES
(1520007740,'SoF_MMM_Meldrath_Crystals'),
(1520007741,'SoF_MMM_Meldrath_Armor'),
(1520007742,'SoF_MMM_Meldrath_Prismatic');
INSERT INTO `lootdrop_entries` (`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`) VALUES
(1520007740,36621,1,0,100),
(1520007741,102556,1,0,30),(1520007741,102564,1,0,30),(1520007741,102573,1,0,30),
(1520007741,102580,1,0,30),(1520007741,102588,1,0,30),
(1520007742,37445,1,0,10);
INSERT INTO `loottable_entries` (`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`) VALUES
(1520007740,1520007740,12,0,0,100),
(1520007740,1520007741,1,0,1,100),
(1520007740,1520007742,1,0,0,100);
