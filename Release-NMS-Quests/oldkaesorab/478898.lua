-- an anchor of the timeshear (478908) -- SoD phased mission driver: The Brood of an Emperor.
-- Static actors + gated boss + wave sequence handled by sod_scene.lua.
local scene = require("sod_scene")

function event_spawn(e)
    scene.on_spawn(e, "brood")
end

function event_timer(e)
    if e.timer == "startcheck" or e.timer == "scene" then
        scene.on_tick(e)
    end
end
