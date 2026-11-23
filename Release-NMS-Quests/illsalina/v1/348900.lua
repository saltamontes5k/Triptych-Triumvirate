local fall = require("rof2_dodh_fall")

function event_damage_taken(e)
    return fall.damage(e)
end
