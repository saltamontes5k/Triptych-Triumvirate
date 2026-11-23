local boss = require("rof2_dodh_xill_boss")

function event_damage_taken(e)
    return boss.damage(e)
end
