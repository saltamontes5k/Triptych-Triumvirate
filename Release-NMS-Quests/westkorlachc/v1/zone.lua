local scene = require("rof2_dodh_widdlethorpe_scene")
function event_death_zone(e) scene.death(e) end
function event_loot_zone(e) return scene.loot(e) end
