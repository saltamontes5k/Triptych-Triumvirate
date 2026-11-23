-- an anchor of the timeshear (478873) -- SoD mission scene driver: The Undead Surge.
-- The scene framework (lua_modules/sod_scene.lua) spawns waves, marches
-- troops, accounts escapes and resolves win/fail; the engine's kill-count
-- task activity (npc_match_list) is the credit of record.
local scene = require("sod_scene")

function event_spawn(e)
    scene.on_spawn(e, "undead_surge")
end

function event_timer(e)
    if e.timer == "startcheck" or e.timer == "scene" then
        scene.on_tick(e)
    end
end
