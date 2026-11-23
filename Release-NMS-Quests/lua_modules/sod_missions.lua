-- sod_missions.lua -- SoD mission scene configs (v466).
-- Re-authored from nightstalker6669's native-scene missions:
--   Murdunk (their migrations/rathe, task 920222, zone 476 korascian):
--     exact interception shape -- pool 44, 45s waves, 35 kills, max 9
--     escaped, escape point (-950, 3111, -15), troops at (25, -1, z).
--   Rain of Ruin / Safe Passage (their sod/kithicor volume, tasks
--     920191/920192): army battle + refugee defense in oldkithicor.
--   The Undead Surge (their sod/oceangreen volume): village defense.
-- start_players is 1 across the board -- multiclass solos wild here.
-- Scene driving lives in sod_scene.lua; task ids live in the 3041xx band.

local D = {}

D.troop_bases = {
    475015, 475026, 475027, 475028, 475030, 475031, 475032, 475033,
}

D.missions = {
    murdunk = {
        task        = 304114,
        zone        = "korascian",
        version     = 61,
        controller  = 478870,
        name        = "Murdunk's Last March",
        mode        = "intercept",
        troops      = {
            478850, 478851, 478852, 478853, 478854, 478855, 478856, 478857,
            478858, 478859, 478860, 478861, 478862, 478863, 478864, 478865,
        },
        origins     = { 25.0, -1.0, 5.625 },   -- per-troop z jitter added by driver
        escape      = { -950, 3111, -15 },
        escape_radius     = 8,
        escape_tolerance  = 12,
        pool              = 44,
        interval_seconds  = 45,
        required_kills    = 35,
        max_escaped       = 9,
        start_players     = 1,
        wave_size         = 2,
        fail_guard        = nil,
        win_line    = "The march on Murdunk's encampment is broken -- not one column slipped through!",
        fail_line   = "Too many Rallosians reached Murdunk's encampment. The march resumes!",
        start_line  = "Rallosian reinforcements are on the march -- intercept them before they reach Murdunk's encampment!",
    },

    rain_of_ruin = {
        task        = 304115,
        zone        = "oldkithicor",
        version     = 61,
        controller  = 478871,
        name        = "Rain of Ruin",
        mode        = "battle",
        troops      = {
            478866, 478867, 478868, 478869,   -- Obliteration assault clones
        },
        origins     = { -1500.0, 2200.0, 20.0 },
        escape      = nil,
        pool              = 40,
        interval_seconds  = 40,
        required_kills    = 30,
        max_escaped       = 999,
        start_players     = 1,
        wave_size         = 3,
        fail_guard        = { npcs = { 478874, 478875, 478876 }, label = "the Army of Light camp" },
        fail_line   = "The Army of Light camp has burned. The woods belong to the Obliteration.",
        win_line    = "The Obliteration assault breaks against the Light's line -- the woods hold!",
        start_line  = "The Obliteration comes in force -- hold the Army of Light camp!",
    },

    safe_passage = {
        task        = 304116,
        zone        = "oldkithicor",
        version     = 61,
        controller  = 478872,
        name        = "Safe Passage",
        mode        = "defend",
        troops      = {
            478866, 478867, 478868, 478869,
        },
        origins     = { -1500.0, 2200.0, 20.0 },
        escape      = nil,
        pool              = 24,
        interval_seconds  = 35,
        required_kills    = 18,
        max_escaped       = 999,
        start_players     = 1,
        wave_size         = 2,
        fail_guard        = { npcs = { 478874, 478875, 478876 }, label = "the refugee column" },
        fail_line   = "The refugee column is lost. Safe passage dies with it.",
        win_line    = "The refugees breathe again -- the road to the rift is open.",
        start_line  = "Refugees are moving for the rift -- shield the column from the Obliteration hunters!",
    },

    undead_surge = {
        task        = 304118,
        zone        = "oceangreenvillage",
        version     = 61,
        controller  = 478873,
        name        = "The Undead Surge",
        mode        = "battle",
        troops      = {
            467047, 467048, 467051, 467054, 467057,   -- plague dead of the village
        },
        origins     = { 10.0, -20.0, 3.0 },
        escape      = nil,
        pool              = 36,
        interval_seconds  = 40,
        required_kills    = 28,
        max_escaped       = 999,
        start_players     = 1,
        wave_size         = 3,
        fail_guard        = { npcs = { 478877, 478878 }, label = "the village watchfire" },
        fail_line   = "The watchfire falls -- the village is overrun by the plague dead.",
        win_line    = "The surge recedes -- the watchfire still burns!",
        start_line  = "The plague dead rise in the village streets -- hold the watchfire!",
    },
}

-- Shared actor rows for the mission npcs (see migration v466):
--   478870 murdunk controller   478871 rain_of_ruin controller
--   478872 safe_passage ctrl    478873 undead_surge controller
--   478850-865 Rallosian reinforcement troops (clones of the 475xxx
--              Rallosian line, renamed)
--   478866-869 Obliteration assault clones (oldkithicor strike mobs)
--   478874-876 a Kithicor refugee (Light-camp civilians)
--   478877-878 oceangreen village watchmen (guard npcs)

-- ---- Phased group missions (v472): their five FoS mission controllers
-- re-authored. Actors spawn at scene start; bosses stay invul until their
-- gate sets fall; Brood runs its four defender-wave sequence. Kill/talk/
-- loot credit rides the engine task activities (npc_match lists).
D.missions.audience = {
    task = 304119, zone = "oldkurn", version = 61, controller = 478897,
    name = "Audience with the Warmaster", mode = "phased",
    static_actors = {
        { npc = 478902, pos = { -225.5, -23.625, 233.75, 379.0 }, gate = true },
        { npc = 478902, pos = { -324.0, -74.125, 234.97, 459.0 }, gate = true },
        { npc = 478903, pos = { -130.875, -17.5, 232.59, 404.75 }, gate = true },
        { npc = 478903, pos = { -231.875, 36.375, 233.75, 251.0 }, gate = true },
    },
    boss = { npc = 478904, pos = { -222.625, -23.25, 263.75, 378.0 } },
    win_line  = "Thessila the Dark falls -- the Warmaster's audience is over.",
    fail_line = "The audience is dispelled. The gates of Kurn close again.",
    start_line = "Thessila's honor guard bars the way -- cut them down to reach the Dark!",
}
D.missions.brood = {
    task = 304120, zone = "oldkaesorab", version = 61, controller = 478898,
    name = "The Brood of an Emperor", mode = "phased",
    static_actors = {
        { npc = 478905, pos = { 325.0, 16.125, -131.63, 382.0 }, egg = true },
        { npc = 478905, pos = { 678.625, 2.25, -23.37, 378.0 }, egg = true },
        { npc = 478905, pos = { 18.125, -34.75, 2.61, 426.0 }, egg = true },
        { npc = 478905, pos = { 256.375, -275.125, -51.02, 251.0 }, egg = true },
        { npc = 478905, pos = { 232.875, 274.0, -55.19, 439.0 }, egg = true },
        { npc = 478905, pos = { 516.0, 184.375, -51.49, 381.0 }, egg = true },
        { npc = 478905, pos = { 521.375, -164.25, -51.49, 378.0 }, egg = true },
        { npc = 478905, pos = { 104.875, 131.625, -21.53, 380.0 }, egg = true },
        { npc = 478905, pos = { 134.0, -147.0, -21.53, 501.0 }, egg = true },
        { npc = 478905, pos = { 487.0, -10.875, -87.19, 380.0 }, egg = true },
        { npc = 478905, pos = { 318.5, -131.5, -87.94, 310.0 }, egg = true },
        { npc = 478905, pos = { 365.125, 157.5, -87.94, 129.0 }, egg = true },
        { npc = 478905, pos = { 197.0, 40.0, -96.84, 254.0 }, egg = true },
        { npc = 478905, pos = { 417.875, -102.25, -51.48, 317.0 }, egg = true },
        { npc = 478905, pos = { 410.0, 67.75, -97.64, 321.0 }, egg = true },
        { npc = 478905, pos = { 142.5, 3.75, -30.44, 127.0 }, egg = true },
        { npc = 478905, pos = { 589.875, -13.875, -25.87, 355.0 }, egg = true },
        { npc = 478905, pos = { 625.375, 65.5, -23.37, 274.0 }, egg = true },
        { npc = 478905, pos = { 469.0, -219.625, -51.49, 508.0 }, egg = true },
        { npc = 478905, pos = { 17.625, 35.125, 2.51, 331.0 }, egg = true },
        { npc = 478905, pos = { 485.875, -29.125, -22.99, 380.0 }, egg = true },
    },
    waves = {
        { { npc = 478906, pos = { 18.125, -34.75, 3.86, 426.0 } },
          { npc = 478906, pos = { 34.5, -5.25, 3.82, 377.0 } },
          { npc = 478906, pos = { 32.125, 6.0, 3.79, 378.0 } },
          { npc = 478906, pos = { 17.625, 35.125, 3.76, 331.0 } } },
        { { npc = 478907, pos = { 18.125, -34.75, 5.11, 426.0 } } },
        { { npc = 478908, pos = { 18.125, -34.75, 3.86, 426.0 } },
          { npc = 478908, pos = { 34.5, -5.25, 3.82, 377.0 } } },
        { { npc = 478909, pos = { 18.125, -34.75, 3.86, 426.0 } } },
    },
    win_line  = "The emperor's brood burns -- no hatchling will fly for the Discord.",
    fail_line = "The defenders recover the field. The brood survives.",
    start_line = "Sarnak defenders pour toward the eggs -- smash the brood and break the waves!",
}
D.missions.knowledge = {
    task = 304121, zone = "oldkaesoraa", version = 61, controller = 478899,
    name = "The Price of Knowledge", mode = "phased",
    static_actors = {
        { npc = 478910, pos = { 283.0, -2031.0, -156.25, 217.0 } },
        { npc = 478910, pos = { 121.875, -2034.75, -164.26, 275.0 } },
        { npc = 478910, pos = { 36.625, -2123.0, -196.26, 399.0 } },
        { npc = 478910, pos = { 217.0, -2105.25, -196.26, 2.0 } },
        { npc = 478910, pos = { -2425.0, -1447.0, -756.26, 111.0 } },
        { npc = 478910, pos = { -2434.875, -877.75, -766.25, 134.0 } },
        { npc = 478911, pos = { 199.5, -1853.0, -166.25, 113.0 }, beguiler = true },
        { npc = 478911, pos = { 277.5, -2124.5, -196.26, 144.0 }, beguiler = true },
        { npc = 478911, pos = { -2505.375, -766.875, -766.25, 458.0 }, beguiler = true },
    },
    boss = { npc = 478912, pos = { -2284.0, -991.0, -767.0, 0.0 } },
    win_line  = "Gordak's enchantment is claimed -- the library's price is paid.",
    fail_line = "The scholars are lost. The library keeps its secrets.",
    start_line = "Wounded scholars call from the stacks -- find them, break the beguilers, and take Gordak's price.",
}
D.missions.phalanx = {
    task = 304122, zone = "oldkurn", version = 62, controller = 478900,
    name = "Defeat the Dragonbane Phalanx", mode = "phased",
    static_actors = {
        { npc = 478913, pos = { -243.5, -139.875, 45.75, 0.0 } },
        { npc = 478913, pos = { -239.1, -139.875, 45.75, 0.0 } },
        { npc = 478913, pos = { -248.5, -139.875, 45.75, 0.0 } },
        { npc = 478914, pos = { -243.5, -144.875, 45.75, 0.0 } },
        { npc = 478914, pos = { -243.5, -134.875, 45.75, 0.0 } },
        { npc = 478914, pos = { -239.1, -144.875, 45.75, 0.0 } },
        { npc = 478914, pos = { -239.1, -134.875, 45.75, 0.0 } },
        { npc = 478915, pos = { -248.5, -144.875, 45.75, 0.0 } },
        { npc = 478916, pos = { -244.25, 120.75, 45.75, 0.0 } },
        { npc = 478916, pos = { -249.25, 120.75, 45.75, 0.0 } },
        { npc = 478916, pos = { -244.25, 115.75, 45.75, 0.0 } },
        { npc = 478916, pos = { -244.25, 125.75, 45.75, 0.0 } },
        { npc = 478917, pos = { -239.25, 120.75, 45.75, 0.0 } },
        { npc = 478917, pos = { -249.25, 115.75, 45.75, 0.0 } },
        { npc = 478917, pos = { -249.25, 125.75, 45.75, 0.0 } },
    },
    win_line  = "The phalanx breaks -- Jaled`Dar will hear of this field.",
    fail_line = "The phalanx holds. Withdraw and return with sharper blades.",
    start_line = "The Dragonbane Phalanx stands in ranks -- shatter them!",
}
D.missions.shield = {
    task = 304123, zone = "oldkaesorab", version = 62, controller = 478901,
    name = "An Impenetrable Shield", mode = "phased",
    static_actors = {
        { npc = 478918, pos = { 18.125, -34.75, 3.86, 426.0 } },
        { npc = 478919, pos = { 516.0, 184.375, -50.24, 381.0 } },
        { npc = 478920, pos = { 487.0, -10.875, -85.94, 380.0 } },
        { npc = 478921, pos = { 410.0, 67.75, -95.77, 321.0 } },
    },
    boss = { npc = 478922, pos = { 672.625, -3.75, -20.37, 0.0 } },
    win_line  = "The guardian falls -- the Shimmering Dragonbane Shield is won.",
    fail_line = "The guardians hold the hatchery. The shield stays theirs.",
    start_line = "Four protectors guard the hatchery's prize -- break them and face the guardian!",
}

D.controller_for = function(zone, version)
    for key, cfg in pairs(D.missions) do
        if cfg.zone == zone and cfg.version == version then
            return key, cfg
        end
    end
    return nil
end

return D
