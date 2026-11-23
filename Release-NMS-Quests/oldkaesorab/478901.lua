-- an anchor of the timeshear (478901) -- SoD phased mission driver: An Impenetrable Shield.
-- Static actors + gated boss + wave sequence handled by sod_scene.lua.
local scene = require("sod_scene")

function event_spawn(e)
    scene.on_spawn(e, "shield")
end

function event_timer(e)
    if e.timer == "startcheck" or e.timer == "scene" then
        scene.on_tick(e)
    end
end
