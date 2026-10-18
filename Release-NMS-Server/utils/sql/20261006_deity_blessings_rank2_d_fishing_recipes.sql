-- ============================================================================
-- Deity Blessings -- Rank 2 "Deity Favors": fishing drops + Brell recipes
-- Date: 2026-10-06
--
-- 8 blessed fish added to the fishing loot tables of their zones and 5 new
-- tradeskill recipes for Brell's feast (the Silver Fork 932874, Silk Thread
-- 3188, Block of Ore 3781, Cream 1839, 1 Lb. Saltwater Crab 1449+ and Metal
-- Camp Chair 935705 recipes already exist live and are reused).
--
-- Recipe ids 992011-992015. Idempotent.
-- ============================================================================

DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` BETWEEN 992011 AND 992015;
DELETE FROM `tradeskill_recipe`         WHERE `id` BETWEEN 992011 AND 992015;

DELETE FROM `fishing` WHERE
    (`zoneid`=98  AND `Itemid`=976230) OR
    (`zoneid`=409 AND `Itemid`=976231) OR
    (`zoneid`=96  AND `Itemid`=976232) OR
    (`zoneid`=110 AND `Itemid`=976233) OR
    (`zoneid`=78  AND `Itemid`=976234) OR
    (`zoneid`=279 AND `Itemid`=976235) OR
    (`zoneid`=64  AND `Itemid`=976236) OR
    (`zoneid`=224 AND `Itemid`=976237);

INSERT INTO `fishing` (`zoneid`,`Itemid`,`skill_level`,`chance`,`npc_id`,`npc_chance`) VALUES
    (98,  976230, 0, 3, 0, 0),  -- Blessed Barren Flounder, Erud's Crossing
    (409, 976231, 0, 3, 0, 0),  -- Blessed Gunthak Mackerel, Ocean of Tears
    (96,  976232, 0, 3, 0, 0),  -- Blessed Timorous Tuna, Timorous Deep
    (110, 976233, 0, 3, 0, 0),  -- Blessed Iceclad Cutlassfish, Iceclad
    (78,  976234, 0, 3, 0, 0),  -- Blessed Kunark Mullet, Field of Bone
    (279, 976235, 0, 3, 0, 0),  -- Blessed 15 lb. Tuna, Abysmal Sea
    (64,  976236, 0, 3, 0, 0),  -- Blessed Kedge Grunion, Kedge Keep
    (224, 976237, 0, 3, 0, 0);  -- Blessed Ovate Jellyfish, Gulf of Gunthak

INSERT INTO `tradeskill_recipe`
    (`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,`must_learn`,`learned_by_item_id`,`quest`,`enabled`,`min_expansion`,`max_expansion`)
VALUES
    (992011,'Silk Napkin',61,0,17,0,0,0,0,0,1,-1,-1),
    (992012,'Unfired Plain Dining Plate',69,0,17,0,0,0,0,0,1,-1,-1),
    (992013,'Plain Dining Plate',69,0,21,0,0,0,0,0,1,-1,-1),
    (992014,'Kiola Nut Brew',65,0,17,0,0,0,0,0,1,-1,-1),
    (992015,'Celebratory Seafood Medley',60,0,17,0,0,0,0,0,1,-1,-1);

INSERT INTO `tradeskill_recipe_entries`
    (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
    -- Silk Napkin: Silk Thread + 4x Spiderling Silk (sewing kits)
    (992011,16486,0,0,1,0,0),
    (992011,13099,0,0,4,0,0),
    (992011,976240,1,0,0,0,0),
    (992011,16,   0,0,0,0,1),
    (992011,17165,0,0,0,0,1),
    -- Unfired Plain Dining Plate: sketch + clay + water (pottery wheel)
    (992012,16958,0,0,1,0,0),
    (992012,16900,0,0,1,0,0),
    (992012,13006,0,0,1,0,0),
    (992012,976241,1,0,0,0,0),
    (992012,21,   0,0,0,0,1),
    (992012,54257,0,0,0,0,1),
    -- Plain Dining Plate: fire the unfired plate (kiln)
    (992013,976241,0,0,1,0,0),
    (992013,16906,0,0,1,0,0),
    (992013,976242,1,0,0,0,0),
    (992013,22,   0,0,0,0,1),
    (992013,54254,0,0,0,0,1),
    -- Kiola Nut Brew (brew barrel / portable drink barrel)
    (992014,13006,0,0,1,0,0),
    (992014,16595,0,0,1,0,0),
    (992014,16590,0,0,1,0,0),
    (992014,16596,0,0,1,0,0),
    (992014,16598,0,0,1,0,0),
    (992014,13340,0,0,1,0,0),
    (992014,976243,1,0,0,0,0),
    (992014,17179,0,0,0,0,1),
    (992014,17763,0,0,0,0,1),
    -- Celebratory Seafood Medley: crab patty + cream + 2 fresh fish (oven)
    (992015,51176,0,0,1,0,0),
    (992015,9726, 0,0,1,0,0),
    (992015,13019,0,0,2,0,0),
    (992015,976244,1,0,0,0,0),
    (992015,54256,0,0,0,0,1);

-- ---------------------------------------------------------------------------
-- Agnostic rank-1 hand-in moves to the Tranquil Keeper (PoT, 344201): the
-- whole unaligned path (cause binding + blank idol) is served there only.
-- ---------------------------------------------------------------------------
UPDATE `task_activities` SET `npc_match_list`='344201'
WHERE `taskid`=700017 AND `activityid`=0 AND `npc_match_list`<>'344201';
