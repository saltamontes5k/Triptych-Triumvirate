-- ============================================================================
-- 20261024_powar_pop_quests.sql  —  Plane of War, PoP-ized (Bonzz pow.htm)
-- ============================================================================
-- Tunes the existing `powar` zone (zoneid 213) content down to PoP-era
-- difficulty for PoP-flagged level 65s, and installs the data needed by the
-- new Release-NMS-Quests/powar/ scripts (Bonzz's Plane of War quest guide).
--
-- Safety notes:
--  * Every combat npc_types row touched here is powar-exclusive (verified
--    spawn2/spawnentry zone_count = 1), so in-place retunes cannot leak.
--  * The old loottables these NPCs carried (6130 A_Diaku_Warrior, 3007
--    Tagrin_Maldric, 2083 Tallon_Zek, 7490 A_Zek_Initiate, 104951) are SHARED
--    with other zones. They are left untouched; powar NPCs get fresh
--    loottables in the 1520009300+ band instead.
--  * Pre-change npc_types/items values are snapshotted into
--    bk_20261024_powar_* tables; the rollback twin restores from them.
--  * Guide locs arrived as EQ-style Y,X,Z locs and are converted to EQEmu
--    X,Y,Z below (e.g. guide "-1525, -1665" -> X=-1665, Y=-1525).
--
-- ID bands used (verified free against live DB at author time):
--   npc_types        1120002500-1120002545 (explicit ids — scripts and
--                    spawnentry rows reference them; RE-VERIFY max before apply)
--   spawngroup       1520009200+
--   loottable        1520009300+
--   lootdrop         1520009400+
--   items            9921000+
--   faction_list     5060, 5061
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Phase 0: backup snapshots (rollback source)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bk_20261024_powar_npc_types AS
SELECT id, name, level, hp, maxlevel, mindmg, maxdmg, npcspecialattks,
       slow_mitigation, raid_target, loottable_id
FROM npc_types
WHERE id IN (
  1520001001,1520001002,1520001003,1520001004,1520001005,1520001006,
  1520001007,1520001008,1520001009,1520001010,1520001011,1520001012,
  1520001013,1520001014,1520001015,1520001016,1520001017,
  1520001201,1520001202,1520001203,1520001204,1520001205,1520001206,
  1520001207,1520001208,1520001209,1520001210,
  1520001301,1520001302,1520001303,1520001304,1520001305,1520001306,
  1520001307,1520001308,1520001309,1520001310,1520001311,1520001312,
  1520001313,1520001314
);

CREATE TABLE IF NOT EXISTS bk_20261024_powar_items AS
SELECT id, name, reqlevel, reclevel, clicklevel2, ac, hp, mana, endur, dr
FROM items
WHERE id IN (127560, 1127560, 2127560, 88464, 97459, 97466, 97472, 97473);

CREATE TABLE IF NOT EXISTS bk_20261024_powar_spawn2 AS
SELECT id, zone, respawntime, variance
FROM spawn2
WHERE id IN (1520005001, 1520003030, 1520005013, 1520005014);

-- ---------------------------------------------------------------------------
-- Phase 1: NPC retune (PoP-era, one-group quest nameds, 2-group raid)
--   trash 61-64 | elites 63-65 | event bosses 65 | raid bosses 65
-- ---------------------------------------------------------------------------
UPDATE npc_types SET level=62, maxlevel=62, hp=15000, mindmg=20, maxdmg=90  WHERE id=1520001001; -- a_zekarian_warrior
UPDATE npc_types SET level=63, maxlevel=63, hp=17000, mindmg=20, maxdmg=90  WHERE id=1520001002; -- a_zekarian_guardian
UPDATE npc_types SET level=61, maxlevel=61, hp=13000, mindmg=20, maxdmg=90  WHERE id=1520001003; -- a_zekarian_patroller
UPDATE npc_types SET level=63, maxlevel=63, hp=17000, mindmg=20, maxdmg=90  WHERE id=1520001004; -- a_zekarian_death_knight
UPDATE npc_types SET level=63, maxlevel=63, hp=16000, mindmg=20, maxdmg=90  WHERE id=1520001005; -- a_tamrelian_soldier
UPDATE npc_types SET level=62, maxlevel=62, hp=13000, mindmg=20, maxdmg=90  WHERE id=1520001006; -- a_tamrelian_pawn
UPDATE npc_types SET level=63, maxlevel=63, hp=15000, mindmg=20, maxdmg=90  WHERE id=1520001007; -- a_tamrelian_archer
UPDATE npc_types SET level=63, maxlevel=63, hp=16000, mindmg=20, maxdmg=90  WHERE id=1520001008; -- a_rulnavian_soldier
UPDATE npc_types SET level=64, maxlevel=64, hp=19000, mindmg=25, maxdmg=95  WHERE id=1520001009; -- a_rulnavian_defender
UPDATE npc_types SET level=64, maxlevel=64, hp=17000, mindmg=25, maxdmg=95  WHERE id=1520001010; -- a_gindan_blademaster
UPDATE npc_types SET level=64, maxlevel=64, hp=16000, mindmg=25, maxdmg=95  WHERE id=1520001011; -- a_gindan_flayer
UPDATE npc_types SET level=65, maxlevel=65, hp=19000, mindmg=25, maxdmg=100 WHERE id=1520001012; -- a_gindan_darkblade
UPDATE npc_types SET level=62, maxlevel=62, hp=12000, mindmg=20, maxdmg=85  WHERE id=1520001013; -- a_war_boar
UPDATE npc_types SET level=63, maxlevel=63, hp=14000, mindmg=20, maxdmg=90  WHERE id=1520001014; -- a_chaos_boar
UPDATE npc_types SET level=62, maxlevel=62, hp=10000, mindmg=15, maxdmg=80  WHERE id=1520001015; -- a_war_crow
UPDATE npc_types SET level=63, maxlevel=63, hp=12000, mindmg=15, maxdmg=80  WHERE id=1520001016; -- a_war_wraith
UPDATE npc_types SET level=65, maxlevel=65, hp=22000, mindmg=30, maxdmg=110 WHERE id=1520001017; -- an_iron_sentinel
UPDATE npc_types SET level=64, maxlevel=64, hp=19000, mindmg=25, maxdmg=95  WHERE id=1520001305; -- a_Decorin_taskmaster
UPDATE npc_types SET level=62, maxlevel=62, hp=14000, mindmg=20, maxdmg=85  WHERE id=1520001306; -- a_greedy_miner
UPDATE npc_types SET level=63, maxlevel=63, hp=12000, mindmg=20, maxdmg=85  WHERE id=1520001307; -- a_mindless_miner

UPDATE npc_types SET level=63, maxlevel=63, hp=35000, mindmg=40, maxdmg=150 WHERE id=1520001302; -- a_Zekarian_colossus (Body of a Colossus fight)
UPDATE npc_types SET level=63, maxlevel=63, hp=20000, mindmg=35, maxdmg=130 WHERE id=1520001303; -- Jergamund_the_Slaver
UPDATE npc_types SET level=64, maxlevel=64, hp=20000, mindmg=40, maxdmg=140 WHERE id=1520001304; -- a_guardian_of_Narikor
UPDATE npc_types SET level=64, maxlevel=64, hp=30000, mindmg=40, maxdmg=140 WHERE id=1520001308; -- Araneae_the_Clever
UPDATE npc_types SET level=63, maxlevel=63, hp=16000, mindmg=25, maxdmg=95  WHERE id=1520001309; -- a_Rulnavian_machinist
UPDATE npc_types SET level=63, maxlevel=63, hp=18000, mindmg=30, maxdmg=100 WHERE id=1520001310; -- a_golem_smith
UPDATE npc_types SET level=63, maxlevel=63, hp=16000, mindmg=25, maxdmg=95  WHERE id=1520001311; -- a_Tamrelian_spy
UPDATE npc_types SET level=63, maxlevel=63, hp=16000, mindmg=25, maxdmg=95  WHERE id=1520001312; -- a_Tamrelian_wall_defender
UPDATE npc_types SET level=65, maxlevel=65, hp=40000, mindmg=45, maxdmg=150 WHERE id=1520001201; -- Commander_Gannar_Dolm
UPDATE npc_types SET level=65, maxlevel=65, hp=40000, mindmg=45, maxdmg=150 WHERE id=1520001202; -- Commander_Inasch_Praeva
UPDATE npc_types SET level=64, maxlevel=64, hp=30000, mindmg=40, maxdmg=140 WHERE id=1520001203; -- Gyrup_the_Caller
UPDATE npc_types SET level=64, maxlevel=64, hp=30000, mindmg=40, maxdmg=140 WHERE id=1520001204; -- Kijarl_Arcanist_of_Rulnavis
UPDATE npc_types SET level=64, maxlevel=64, hp=25000, mindmg=40, maxdmg=140 WHERE id=1520001205; -- Rolfron_Zek_Lord_of_Despair
UPDATE npc_types SET level=64, maxlevel=64, hp=30000, mindmg=40, maxdmg=140 WHERE id=1520001206; -- Slave_Driver_Thokk
UPDATE npc_types SET level=65, maxlevel=65, hp=45000, mindmg=45, maxdmg=155 WHERE id=1520001207; -- The_Barb
UPDATE npc_types SET level=65, maxlevel=65, hp=45000, mindmg=45, maxdmg=155 WHERE id=1520001208; -- The_Blade
UPDATE npc_types SET level=65, maxlevel=65, hp=55000, mindmg=55, maxdmg=190, npcspecialattks='S'          WHERE id=1520001210; -- The_Heart_of_Narikor
UPDATE npc_types SET level=65, maxlevel=65, hp=65000, mindmg=55, maxdmg=200, npcspecialattks='S'          WHERE id=1520001301; -- The_Judicator
UPDATE npc_types SET level=65, maxlevel=65, hp=110000, mindmg=55, maxdmg=220, npcspecialattks='S'         WHERE id=1520001209; -- The_Grandmaster
UPDATE npc_types SET level=65, maxlevel=65, hp=260000, mindmg=90, maxdmg=340, npcspecialattks='S', slow_mitigation=35, raid_target=1 WHERE id=1520001313; -- Tallon_Zek
UPDATE npc_types SET level=65, maxlevel=65, hp=190000, mindmg=90, maxdmg=340, npcspecialattks='S', slow_mitigation=35, raid_target=1 WHERE id=1520001314; -- Vallon_Zek

-- ---------------------------------------------------------------------------
-- Phase 2: factions (buckets in scripts gate the actual quest steps; these
-- rows just make insignia turn-ins show up on /con and #faction)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO faction_list (id, name, base) VALUES
  (5060, 'Castle Tamrel', 0),
  (5061, 'Castle Rulnavis', 0);

-- ---------------------------------------------------------------------------
-- Phase 3: items
--   a) PoP-ize the Zekarian bow (req 95 -> 65, stats trimmed to top-of-PoP;
--      the +1M/+2M Enchanted/Legendary upgrade chain keeps working)
--   b) lower click level 80 -> 65 on the PoW clickies
--   c) author the Grandmaster's Tower + Zek raid drops (items 9921000+)
-- ---------------------------------------------------------------------------
UPDATE items SET reqlevel=65, reclevel=65, ac=5, hp=75, mana=75, endur=75, dr=20
WHERE id IN (127560, 1127560, 2127560);

UPDATE items SET clicklevel2=65 WHERE id IN (88464, 97459, 97466, 97472, 97473);

INSERT IGNORE INTO items (id, name, ac, hp, mana, endur, astr, asta, aint, attack, dr, damage, delay, `range`, icon, idfile, itemtype, slots, weight, size, lore, loregroup, magic, classes, races, reqlevel, reclevel, norent, stacksize, proceffect, clickeffect, focuseffect) VALUES
(9921000, 'Fiery Helm of Rallos Zek', 40, 125, 75, 75, 15, 15, 0, 15, 0, 0, 0, 0, 5770, 'IT63', 10, 4, 5, 3, 'Forged in the war fields of Rallos Zek', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1),
(9921001, 'Grandmaster''s Gambit Ring', 15, 100, 100, 100, 0, 0, 0, 10, 0, 0, 0, 0, 3546, 'IT63', 11, 32768, 1, 1, 'A trophy of the perfect game', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1),
(9921002, 'Board Master''s War Girdle', 25, 110, 0, 110, 0, 20, 0, 15, 0, 0, 0, 0, 4002, 'IT63', 10, 1048576, 3, 1, 'Girt with the tactics of a hundred matches', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1),
(9921003, 'Cloak of the Endgame', 20, 90, 90, 90, 0, 0, 10, 10, 0, 0, 0, 0, 4001, 'IT63', 10, 256, 3, 1, 'Every match ends here', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1),
(9921010, 'Volley of Tallon Zek', 5, 100, 0, 0, 10, 10, 0, 20, 0, 40, 40, 200, 1379, 'IT10641', 5, 2048, 25, 3, 'Struck with the surety of Tallon''s aim', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1),
(9921011, 'Lens of Tallon Zek', 10, 150, 125, 125, 0, 0, 15, 15, 0, 0, 0, 0, 4001, 'IT63', 11, 256, 1, 2, 'Through it, every target looks already falling', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1),
(9921012, 'Crown of Vallon Zek', 45, 150, 125, 125, 0, 0, 20, 10, 0, 0, 0, 0, 5770, 'IT63', 10, 4, 5, 3, 'It whispers which of your foes is lying', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1),
(9921013, 'Sigil of Doubt', 35, 130, 110, 110, 0, 0, 0, 15, 0, 0, 0, 0, 4002, 'IT63', 10, 64, 3, 1, 'Worn on the shoulder of the one who hesitates last', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1),
(9921014, 'Warlord''s Greatblade', 0, 125, 0, 0, 20, 15, 0, 25, 0, 55, 40, 0, 3546, 'IT63', 2, 8192, 30, 6, 'Two hands, one war', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1),
(9921015, 'Mantle of the War Fields', 30, 120, 100, 100, 0, 0, 0, 15, 0, 0, 0, 0, 4001, 'IT63', 10, 256, 4, 1, 'Cut from the colors of a broken army', -1, 1, 65535, 65535, 65, 65, 1, 1, -1, -1, -1);

-- ---------------------------------------------------------------------------
-- Phase 4: loot redesign (fresh PoW loottables; shared peq tables untouched)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO loottable (id, name, mincash, maxcash) VALUES
  (1520009300, 'PoWar_Field_Trash',      500,  2000),
  (1520009301, 'PoWar_Mines_Trash',      500,  2000),
  (1520009302, 'PoWar_Castle_Trash',     500,  2000),
  (1520009303, 'PoWar_Named_Small',      5000, 15000),
  (1520009304, 'PoWar_Jergamund',        5000, 15000),
  (1520009305, 'PoWar_Judicator',        20000, 50000),
  (1520009306, 'PoWar_Heart_of_Narikor', 20000, 50000),
  (1520009307, 'PoWar_Grandmaster',      20000, 50000),
  (1520009308, 'PoWar_Tallon_Zek',       30000, 60000),
  (1520009309, 'PoWar_Vallon_Zek',       30000, 60000),
  (1520009310, 'PoWar_Icecore',          10000, 20000),
  (1520009311, 'PoWar_Tar_Targets',      500,  2000),
  (1520009312, 'PoWar_Tamrelian_Charger', 500, 2000),
  (1520009313, 'PoWar_Yendan_Servant',   500,  2000);

INSERT IGNORE INTO lootdrop (id, name) VALUES
  (1520009400, 'PoWar_Field_Trash_Drop'),
  (1520009401, 'PoWar_Mines_Trash_Drop'),
  (1520009402, 'PoWar_Castle_Trash_Drop'),
  (1520009403, 'PoWar_Named_Small_Drop'),
  (1520009404, 'PoWar_Jergamund_Drop'),
  (1520009405, 'PoWar_Judicator_Drop'),
  (1520009406, 'PoWar_Heart_Drop'),
  (1520009407, 'PoWar_Grandmaster_Drop'),
  (1520009408, 'PoWar_Tallon_Drop'),
  (1520009409, 'PoWar_Vallon_Drop'),
  (1520009410, 'PoWar_Icecore_Drop'),
  (1520009411, 'PoWar_Tar_Target_Drop'),
  (1520009412, 'PoWar_Charger_Drop'),
  (1520009413, 'PoWar_Kindling_Drop');

INSERT IGNORE INTO lootdrop_entries (lootdrop_id, item_id, item_charges, equip_item, chance) VALUES
  -- Field of Strife trash (zekarians, tamrelians, boars, crow, wraith)
  (1520009400, 97422, 1, 0, 4),      -- Vallon Soldier Insignia
  (1520009400, 88465, 1, 0, 4),      -- Tallon Soldier Insignia
  (1520009400, 88466, 1, 0, 1),      -- Tallon Captain Insignia
  (1520009400, 97456, 1, 0, 8),      -- Tamrelian Sword Pieces
  (1520009400, 97453, 1, 0, 8),      -- Tamrelian Armor Pieces
  (1520009400, 97461, 1, 0, 5),      -- Field of Blood Kindling
  (1520009400, 97426, 1, 0, 8),      -- Battle Report Page
  (1520009400, 17843, 1, 0, 2),      -- Broken Weapon
  -- Mines trash (gindans, taskmasters, miners)
  (1520009401, 97484, 1, 0, 10),     -- Narikor Iron Ore
  (1520009401, 97485, 1, 0, 6),      -- Narikor Tin Ore
  (1520009401, 97479, 1, 0, 3),      -- Narikor Guard's Tooth
  (1520009401, 67996, 1, 0, 2.5),    -- Shining Gem of Striking
  (1520009401, 86221, 1, 0, 5),      -- Sulfurous Iron Ore
  (1520009401, 17843, 1, 0, 2),      -- Broken Weapon
  -- Castle trash (rulnavians, machinist, golem smith, spy, wall defenders)
  (1520009402, 97422, 1, 0, 4),
  (1520009402, 88465, 1, 0, 4),
  (1520009402, 88466, 1, 0, 1),
  (1520009402, 97456, 1, 0, 8),
  (1520009402, 97453, 1, 0, 8),
  (1520009402, 17843, 1, 0, 2),
  -- Small nameds across the zone
  (1520009403, 127556, 1, 0, 20),    -- Zekarian Diamond
  (1520009403, 67996, 1, 0, 10),     -- Shining Gem of Striking
  (1520009404, 97496, 1, 0, 100),    -- Captured Slaver
  (1520009405, 127598, 1, 0, 100),   -- The Warlord's Blessing
  (1520009406, 86160, 1, 0, 100),    -- The Heart of Narikor
  (1520009406, 127556, 1, 0, 50),    -- Zekarian Diamond
  (1520009407, 9921000, 1, 0, 100),  -- Fiery Helm of Rallos Zek
  (1520009407, 9921001, 1, 0, 100),  -- Grandmaster's Gambit Ring
  (1520009407, 9921002, 1, 0, 100),  -- Board Master's War Girdle
  (1520009407, 9921003, 1, 0, 100),  -- Cloak of the Endgame
  (1520009408, 9921010, 1, 0, 100),  -- Volley of Tallon Zek
  (1520009408, 9921011, 1, 0, 100),  -- Lens of Tallon Zek
  (1520009408, 127556, 1, 0, 100),   -- Zekarian Diamond
  (1520009409, 9921012, 1, 0, 100),  -- Crown of Vallon Zek
  (1520009409, 9921013, 1, 0, 100),  -- Sigil of Doubt
  (1520009409, 9921014, 1, 0, 50),   -- Warlord's Greatblade
  (1520009409, 9921015, 1, 0, 50),   -- Mantle of the War Fields
  (1520009410, 86292, 1, 0, 100),    -- Gorod's Medallion
  (1520009410, 86293, 1, 0, 100),    -- Aelfgir's Signet Ring
  (1520009411, 97446, 1, 0, 100),    -- Charred Soldier's Bones
  (1520009411, 97447, 1, 0, 35),     -- Charred Captain's Bones
  (1520009412, 97441, 1, 0, 100),    -- Successful Defensive Report Page
  (1520009413, 97461, 1, 0, 100);    -- Field of Blood Kindling

INSERT IGNORE INTO loottable_entries (loottable_id, lootdrop_id, multiplier, droplimit, mindrop, probability) VALUES
  (1520009300, 1520009400, 1, 0, 0, 100),
  (1520009301, 1520009401, 1, 0, 0, 100),
  (1520009302, 1520009402, 1, 0, 0, 100),
  (1520009303, 1520009403, 1, 0, 0, 100),
  (1520009304, 1520009401, 1, 0, 0, 100),
  (1520009304, 1520009404, 1, 0, 0, 100),
  (1520009305, 1520009405, 1, 0, 0, 100),
  (1520009305, 1520009403, 1, 0, 0, 100),
  (1520009306, 1520009406, 1, 0, 0, 100),
  (1520009306, 1520009403, 1, 0, 0, 100),
  (1520009307, 1520009407, 1, 0, 0, 100),
  (1520009307, 1520009403, 1, 0, 0, 100),
  (1520009308, 1520009408, 1, 0, 0, 100),
  (1520009309, 1520009409, 1, 0, 0, 100),
  (1520009310, 1520009410, 1, 0, 0, 100),
  (1520009311, 1520009411, 1, 0, 0, 100),
  (1520009312, 1520009412, 1, 0, 0, 100),
  (1520009313, 1520009413, 1, 0, 0, 100);

-- Reassign powar NPCs off the shared peq tables
UPDATE npc_types SET loottable_id=1520009300 WHERE id IN (1520001001,1520001002,1520001003,1520001004,1520001005,1520001006,1520001007,1520001008,1520001013,1520001014,1520001015,1520001016,1520001306,1520001307);
UPDATE npc_types SET loottable_id=1520009301 WHERE id IN (1520001010,1520001011,1520001012,1520001305);
UPDATE npc_types SET loottable_id=1520009302 WHERE id IN (1520001009,1520001017,1520001309,1520001310,1520001311,1520001312);
UPDATE npc_types SET loottable_id=1520009303 WHERE id IN (1520001201,1520001202,1520001203,1520001204,1520001205,1520001206,1520001207,1520001208,1520001302,1520001304,1520001308);
UPDATE npc_types SET loottable_id=1520009304 WHERE id=1520001303; -- Jergamund (mines drop + Captured Slaver)
UPDATE npc_types SET loottable_id=1520009305 WHERE id=1520001301; -- Judicator
UPDATE npc_types SET loottable_id=1520009306 WHERE id=1520001210; -- Heart of Narikor
UPDATE npc_types SET loottable_id=1520009307 WHERE id=1520001209; -- Grandmaster
UPDATE npc_types SET loottable_id=1520009308 WHERE id=1520001313; -- Tallon
UPDATE npc_types SET loottable_id=1520009309 WHERE id=1520001314; -- Vallon

-- ---------------------------------------------------------------------------
-- Phase 5: new NPCs (Bonzz cast fill-ins + script-spawned templates)
-- Explicit ids: quest scripts and spawnentry rows reference them.
-- Clones use INSERT ... SELECT so every visual (race/model/textures) comes
-- from an NPC the client already renders in these zones.
-- ---------------------------------------------------------------------------
-- 5a. static quest-givers and event targets
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002500, 'Forgetender_Bolgorn', '', 65, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 0, 0, 0, 0, 0, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 1, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001107;

INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002501, 'Cooper_Jolris', '', 65, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 0, 0, 0, 0, 0, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 1, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001105;

INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002502, 'Diviner_of_the_Worthy', '', 65, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 0, 0, 0, 0, 0, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 1, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001106;

INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002503, 'an_unimpressed_slaver', '', 63, race, class, bodytype, 14000, 0, gender, texture, helmtexture, size, 0, 79, 20, 90, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001305;

INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002506, 'Lieutenant_Ess_Pekky', '', 65, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 0, 0, 0, 0, 0, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 1, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001102;

INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002507, 'General_Ugor_Gronno', 'New Colonel of Castle Tamrel', 65, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 0, 0, 0, 0, 0, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 1, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001117;

INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002508, 'a_shamanic_resonance', '', 62, race, class, bodytype, 3000, 0, gender, texture, helmtexture, size, 0, 79, 10, 60, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 62, 0, 1, model, 0, 0, 0 FROM npc_types WHERE id=1520001016;

INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002509, 'Soke_of_Storms', 'Goblin of the Blacksmith Depths', 65, race, class, bodytype, 60000, 0, gender, texture, helmtexture, size, 0, 0, 40, 130, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 0, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001011;

INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002510, 'Icecore', 'Shade of the Frozen Deep', 63, race, class, bodytype, 40000, 0, gender, texture, helmtexture, size, 1520009310, 0, 35, 130, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001016;

-- (Zayenaekk already exists in pojustice as peq npc 201281 — the quest
-- script attaches to him; no duplicate is added here.)

INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002512, 'Zayenaek', 'Emissary of War', 65, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 0, 0, 0, 0, 0, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 1, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001002;

-- 5b. script-spawned templates (quest::unique_spawn targets, no static spawns)
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002513, 'Herald_of_War', 'Voice of the War Fields', 65, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 0, 0, 0, 0, 0, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 1, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001107;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002514, 'a_furious_legionnaire', '', 65, race, class, bodytype, 35000, 0, gender, texture, helmtexture, size, 0, 79, 45, 150, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001004;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002515, 'a_shade_of_judgment', '', 63, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 0, 79, 20, 90, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001016;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002516, 'a_slaver_captain', '', 64, race, class, bodytype, 22000, 0, gender, texture, helmtexture, size, 0, 79, 30, 110, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 64, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001305;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002517, 'a_motivator', '', 63, race, class, bodytype, 15000, 0, gender, texture, helmtexture, size, 0, 79, 25, 100, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001012;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002518, 'High_Tactician_Drelg', 'High Tactician of Castle Tamrel', 65, race, class, bodytype, 90000, 0, gender, texture, helmtexture, size, 0, 79, 55, 210, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 0, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001004;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002519, 'an_honor_guard', '', 63, race, class, bodytype, 16000, 0, gender, texture, helmtexture, size, 0, 79, 25, 100, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001012;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002520, 'a_blood_guard', '', 63, race, class, bodytype, 16000, 0, gender, texture, helmtexture, size, 0, 79, 25, 100, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001012;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002521, 'a_possessed_colossus', '', 60, race, class, bodytype, 40000, 0, gender, texture, helmtexture, size, 0, 0, 0, 0, 0, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 60, 0, 1, model, 0, 0, 0 FROM npc_types WHERE id=1520001302;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002522, 'a_battle_image', 'Trial of the First Seal', 62, race, class, bodytype, 10000, 0, gender, texture, helmtexture, size, 0, 79, 20, 85, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 62, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001009;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002523, 'a_charging_image', 'Trial of the First Seal', 62, race, class, bodytype, 9000, 0, gender, texture, helmtexture, size, 0, 79, 20, 85, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 62, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001005;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002524, 'a_sneaky_goblin_image', 'Trial of the Second Seal', 62, race, class, bodytype, 9000, 0, gender, texture, helmtexture, size, 0, 79, 20, 85, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 62, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001011;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002525, 'a_giant_image', 'Trial of the Second Seal', 63, race, class, bodytype, 14000, 0, gender, texture, helmtexture, size, 0, 79, 25, 95, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001017;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002526, 'a_hendin_image', 'Trial of the Third Seal', 62, race, class, bodytype, 10000, 0, gender, texture, helmtexture, size, 0, 79, 20, 85, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 62, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001001;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002527, 'an_orc_ally', 'Trial Ally', 58, race, class, bodytype, 6000, 0, gender, texture, helmtexture, size, 0, 0, 10, 60, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 58, 0, 1, model, 0, 0, 0 FROM npc_types WHERE id=1520001005;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002528, 'a_bloodtusk_ally_image', 'Trial Ally', 60, race, class, bodytype, 7000, 0, gender, texture, helmtexture, size, 0, 0, 10, 60, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 60, 0, 1, model, 0, 0, 0 FROM npc_types WHERE id=1520001010;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002529, 'a_tamrelian_infiltrator', '', 63, race, class, bodytype, 14000, 0, gender, texture, helmtexture, size, 0, 79, 25, 100, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001311;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002530, 'a_zekarian_knight', 'Chess Piece', 64, race, class, bodytype, 20000, 0, gender, texture, helmtexture, size, 0, 79, 30, 120, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 64, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001004;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002531, 'a_zekarian_rook', 'Chess Piece', 64, race, class, bodytype, 26000, 0, gender, texture, helmtexture, size, 0, 79, 30, 120, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 64, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001302;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002532, 'a_tamrelian_charger', '', 62, race, class, bodytype, 10000, 0, gender, texture, helmtexture, size, 1520009312, 79, 20, 85, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 62, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001013;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002533, 'a_tamrelian_assailant', '', 63, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 1520009311, 79, 25, 95, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001005;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002534, 'a_tamrelian_assaulter', '', 63, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 1520009311, 79, 25, 95, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001005;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002535, 'a_yendan_forest_servant', '', 62, race, class, bodytype, 9000, 0, gender, texture, helmtexture, size, 1520009313, 79, 20, 85, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 62, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001013;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002536, 'Edmuund_the_Bold', 'The Test Unbound', 65, race, class, bodytype, 60000, 0, gender, texture, helmtexture, size, 0, 79, 50, 180, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 0, 1, model, 0, 1, 1 FROM npc_types WHERE id=1520001014;
-- Rallosian raid adds (event_damage weakness handled in scripts)
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002537, 'a_Rallosian_Archer', 'Weak to stun and blunt', 63, race, class, bodytype, 14000, 0, gender, texture, helmtexture, size, 0, 79, 25, 100, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001007;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002538, 'a_Rallosian_Marauder', 'Weak to stun and blunt', 63, race, class, bodytype, 15000, 0, gender, texture, helmtexture, size, 0, 79, 25, 100, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001010;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002539, 'a_Rallosian_Slavebringer', 'Weak to stun and blunt', 63, race, class, bodytype, 15000, 0, gender, texture, helmtexture, size, 0, 79, 25, 100, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001012;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002540, 'a_Rallosian_Warmaster', 'Weak to snare and slash', 64, race, class, bodytype, 18000, 0, gender, texture, helmtexture, size, 0, 79, 30, 115, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 64, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001001;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002541, 'a_Rallosian_Lifetaker', 'Weak to snare and slash', 64, race, class, bodytype, 18000, 0, gender, texture, helmtexture, size, 0, 79, 30, 115, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 64, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001004;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002542, 'a_Rallosian_Flamespeaker', 'Weak to cold and pierce', 63, race, class, bodytype, 14000, 0, gender, texture, helmtexture, size, 0, 79, 25, 100, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 63, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001016;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002543, 'a_Rallosian_Warbrute', 'Weak to fire and hand to hand', 65, race, class, bodytype, 22000, 0, gender, texture, helmtexture, size, 0, 79, 35, 125, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001017;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002544, 'a_Rallosian_Provost', 'Weak to fire and hand to hand', 65, race, class, bodytype, 22000, 0, gender, texture, helmtexture, size, 0, 79, 35, 125, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 65, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001017;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002545, 'a_Rallosian_skirmisher', 'Kite it - backstab cures nowhere', 62, race, class, bodytype, 12000, 0, gender, texture, helmtexture, size, 0, 79, 20, 95, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 62, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001003;
INSERT IGNORE INTO npc_types (id, name, lastname, level, race, class, bodytype, hp, mana, gender, texture, helmtexture, size, loottable_id, npc_faction_id, mindmg, maxdmg, aggroradius, attack_speed, attack_delay, STR, STA, DEX, AGI, _INT, WIS, CHA, maxlevel, isquest, show_name, model, see_invis, findable, trackable)
SELECT 1120002546, 'a_Rallosian_priest', 'Weak to charm - heals the warhost', 62, race, class, bodytype, 12000, 3000, gender, texture, helmtexture, size, 0, 79, 20, 95, 70, 1.0, 30, STR, STA, DEX, AGI, _INT, WIS, CHA, 62, 0, 1, model, 0, 0, 1 FROM npc_types WHERE id=1520001016;

-- 5c. spawngroups + spawn points for the static additions
INSERT IGNORE INTO spawngroup (id, name, spawn_limit, dist) VALUES
  (1520009200, 'PoWar_Forgetender_Bolgorn', 1, 0),
  (1520009201, 'PoWar_Cooper_Jolris', 1, 0),
  (1520009202, 'PoWar_Diviner_of_the_Worthy', 1, 0),
  (1520009203, 'PoWar_Unimpressed_Slaver_1', 1, 0),
  (1520009204, 'PoWar_Unimpressed_Slaver_2', 1, 0),
  (1520009205, 'PoWar_Unimpressed_Slaver_3', 1, 0),
  (1520009206, 'PoWar_Lieutenant_Ess_Pekky', 1, 0),
  (1520009207, 'PoWar_General_Ugor_Gronno', 1, 0),
  (1520009208, 'PoWar_Resonance_SW_Room', 1, 0),
  (1520009209, 'PoWar_Resonance_South_of_SW', 1, 0),
  (1520009210, 'PoWar_Resonance_Back_West', 1, 0),
  (1520009211, 'PoWar_Resonance_NE_Room', 1, 0),
  (1520009212, 'PoWar_Soke_of_Storms', 1, 0),
  (1520009213, 'PoWar_Icecore', 1, 0),
  (1520009215, 'PoWar_Zayenaek', 1, 0);

INSERT IGNORE INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid) VALUES
  (1520009200, 'powar', 0, -160.0, -3130.0, -103.0, 0, 600, 120, 0),
  (1520009201, 'powar', 0, 450.0, -2800.0, -131.0, 0, 600, 120, 0),
  (1520009202, 'powar', 0, 150.0, -3005.0, -102.0, 0, 600, 120, 0),
  (1520009203, 'powar', 0, -247.0, -3254.0, -102.0, 0, 900, 300, 0),
  (1520009204, 'powar', 0, -147.0, -2954.0, -102.0, 0, 900, 300, 0),
  (1520009205, 'powar', 0, 97.0, -3104.0, -102.0, 0, 900, 300, 0),
  (1520009206, 'powar', 0, -1500.0, -1740.0, 27.0, 0, 600, 0, 0),
  (1520009207, 'powar', 0, -1930.0, -950.0, 85.0, 0, 600, 0, 0),
  (1520009208, 'powar', 0, -1730.0, -1685.0, 25.0, 0, 7200, 0, 0),
  (1520009209, 'powar', 0, -1940.0, -1795.0, 25.0, 0, 7200, 0, 0),
  (1520009210, 'powar', 0, -2020.0, -1205.0, 25.0, 0, 7200, 0, 0),
  (1520009211, 'powar', 0, -1690.0, -735.0, 25.0, 0, 7200, 0, 0),
  (1520009212, 'potactics', 0, 1000.0, 1335.0, -325.0, 0, 300, 60, 0),
  (1520009213, 'ponightmare', 0, 4400.0, -5800.0, 0.0, 0, 7200, 1800, 0),
  (1520009215, 'povalor', 0, -260.0, 1560.0, 70.0, 0, 600, 0, 0);

INSERT IGNORE INTO spawnentry (spawngroupID, npcID, chance) VALUES
  (1520009200, 1120002500, 100),
  (1520009201, 1120002501, 100),
  (1520009202, 1120002502, 100),
  (1520009203, 1120002503, 100),
  (1520009204, 1120002503, 100),
  (1520009205, 1120002503, 100),
  (1520009206, 1120002506, 100),
  (1520009207, 1120002507, 100),
  (1520009208, 1120002508, 100),
  (1520009209, 1120002508, 100),
  (1520009210, 1120002508, 100),
  (1520009211, 1120002508, 100),
  (1520009212, 1120002509, 100),
  (1520009213, 1120002510, 100),
  (1520009215, 1120002512, 100);

-- ---------------------------------------------------------------------------
-- Phase 6: boss respawn timers (rare-style placeholders for the Judicator
-- spawn-on-trash-kill mechanic; the rest are long-cycle event bosses)
-- ---------------------------------------------------------------------------
UPDATE spawn2 SET respawntime=10800, variance=3600 WHERE id=1520005001; -- The_Judicator
UPDATE spawn2 SET respawntime=21600, variance=7200 WHERE id=1520003030; -- The_Grandmaster
UPDATE spawn2 SET respawntime=259200, variance=43200 WHERE id IN (1520005013, 1520005014); -- Tallon / Vallon
