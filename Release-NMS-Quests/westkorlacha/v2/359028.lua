local ilsuras = require("rof2_dodh_ilsuras")

function event_damage_taken(e)
    return ilsuras.damage(e)
end

function event_say(e)
    ilsuras.hail(e)
end
