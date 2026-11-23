local arrival = require("rof2_dodh_arrival")
local scenes = require("rof2_dodh_scene_driver")

function event_enter_zone(e)
    arrival.credit(e.self, 920232)
    scenes.enter(e.self, 920232)
    eq.set_timer("dodh_scene_tick", 1000, e.self)
end

function event_timer(e)
    if e.timer == "dodh_scene_tick" then scenes.tick() end
end
