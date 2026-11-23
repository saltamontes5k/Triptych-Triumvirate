local vule = require("rof2_dodh_vule")

function event_damage_taken(e) return vule.damage(e) end
function event_combat(e) vule.combat(e) end
function event_timer(e) vule.tick(e) end
