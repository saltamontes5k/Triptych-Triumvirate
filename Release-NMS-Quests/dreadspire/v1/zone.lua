local admission = require("rof2_dodh_demi_admission")
local scene = require("rof2_dodh_demi_controller")

function event_loot_zone(e) return admission.can_loot(e) end
function event_death_zone(e)
    scene.death(e)
end
