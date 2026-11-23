local shadows = require("rof2_dodh_shadows")

function event_damage_taken(e)
    return shadows.damage(e)
end

function event_timer(e)
    shadows.cast(e)
end
