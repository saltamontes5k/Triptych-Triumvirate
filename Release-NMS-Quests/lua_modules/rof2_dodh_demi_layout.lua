-- Correlate these positions with FLOOR-PROJECTION.private.json.
-- Native proof and materialization remain staged separately.
local ballroom = {5.7186, 2996.5088, 100.0, 384}
local function room(x, y, z, guard, cache_x)
    return {
        entry = {x, y, z, 0}, reward = 1, guard = guard,
        anchors = {{cache_x, y, z, 0}, {x - 9, y + 7, z, 0}, {x, y - 9, z, 0}},
    }
end

return {
    redfang = {
        screechers = {260139, 260141, 260142, 260154, 260155, 260157},
        window = {21.706, -740.024, -271.54, 0},
    },
    hatchet = {
        boss = {npc = 351165, spawn = 260044},
        -- Client slot numbers are scoped to version 1 by the encounter.
        trap_doors = {
            [37] = {403.696, 3006.59, -64.1409}, [38] = {438.061, 2954.99, -64.2117},
            [39] = {440.052, 3058.3, -64.1539}, [40] = {344.275, 3007.57, -64.123},
        },
        footholds = {
            {338.405, 2913.59, -60.2479, 308}, {356.334, 3100.46, -60.2479, 46},
            {451.826, 3099.91, -60.4076, 454}, {478.238, 2949.01, -60.0141, 74},
        },
    },
    devlin = {
        room = {pose = {0.0963,-95.0545,-1101.0,0}, hall = {1,-73,-1101,128}},
        rack = {0,-114,-1100.25,0},
    },
    tris = {
        -- Local placement in the west hall. No period coordinate was recovered.
        room = {pose = {-103,3235,100,128}},
        wolves = {{-124,3227,100,128},{-111,3219,100,0},{-93,3224,100,0},{-80,3227,100,384}},
        guard = {-75,3244,100,384},
        reward = {-88,3235,100,128},
        spirit = {-80,3235,100,128},
    },
    roley = {
        ballroom = ballroom,
        -- The v1 template has no dancer types. These ten installed ballroom
        -- placements are a local reconstruction of the historical clear.
        dancers = {
            [260029]=351145,[260032]=351145,[260039]=351145,[260042]=351145,[260047]=351145,
            [260055]=351145,[260026]=351146,[260033]=351146,[260010]=351155,[260015]=351155,
        },
        branch_rooms = {
            room(-299,3109,100,351146,-294), room(284.5,2545.375,67,351148,285.5),
            {
                entry = {195,3072,90.75,0}, guard = 351143, reward = 1, zombie = 351162,
                anchors = {{192,3076,90.875,0}, {184,3072,93,0}, {203,3072,90.75,0}, {199,3063,90.75,0}},
            },
        },
        branch_exits = {ballroom, ballroom, ballroom},
    },
    performer = {
        stage = {pose = {0,3540,100,256}},
        doorway = {{slot=35, row=39213},{slot=36, row=39214}},
        -- Main entrance, inside the room and clear of the false floor.
        entrances = {{-24,3442,100,0},{0,3436,100,0},{24,3442,100,0}},
        band = {
            {type=351152, name="Aelfric_the_Flautist", pose={-11,3543,100,256}},
            {type=351153, name="Britton_Harmony", pose={-5,3549,100,256}},
            {type=351154, name="Seth_Kimble", pose={5,3549,100,256}},
            {type=351153, name="Randal_Reedsea", pose={11,3543,100,256}},
        },
        reward = {18,3519,100,256},
        spirit = {26,3519,100,256},
    },
    mayong = {
        throne = {-695.769,2933.7725,482.9997,128},
        guard_poses = {
            {-673,2918,473,128}, {-673,2958,473,128}, {-643,2918,473,128},
            {-642.8349,2957.8349,473,128}, {-658.7119,3011.8689,473,128},
            {-668.923,2861.1338,473,128}, {-568.8509,2857.3069,473,128},
        },
    },
}
