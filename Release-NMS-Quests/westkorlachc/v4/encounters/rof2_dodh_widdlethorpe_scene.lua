local scene = require("rof2_dodh_widdlethorpe_scene")
function event_encounter_load(e) scene.load(e) end
function event_timer(e) if e.timer == "widdlethorpe_scene" then scene.tick() end end
