local scene = require("rof2_dodh_widdlethorpe_scene")
function event_spawn(e) scene.spawn(e) end
function event_damage_taken(e) return scene.damage(e) end
