-- an anchor of the timeshear (478909) -- SoD phased mission driver: The Price of Knowledge.
-- Static actors + gated boss + wave sequence handled by sod_scene.lua.
local scene = require("sod_scene")

function event_spawn(e)
    scene.on_spawn(e, "knowledge")
end

function event_timer(e)
    if e.timer == "startcheck" or e.timer == "scene" then
        scene.on_tick(e)
    end
end
