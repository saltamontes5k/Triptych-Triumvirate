local preemptive = require("rof2_dodh_preemptive")

function event_damage_taken(e)
    return preemptive.damage(e)
end
