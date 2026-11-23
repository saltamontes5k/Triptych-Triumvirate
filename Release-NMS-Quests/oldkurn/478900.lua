-- an anchor of the timeshear (478900) -- SoD phased mission driver: Defeat the Dragonbane Phalanx.
-- Static actors + gated boss + wave sequence handled by sod_scene.lua.
local scene = require("sod_scene")

function event_spawn(e)
    scene.on_spawn(e, "phalanx")
end

function event_timer(e)
    if e.timer == "startcheck" or e.timer == "scene" then
        scene.on_tick(e)
    end
end
