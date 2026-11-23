local blood = require("rof2_dodh_blood_raids")

function event_spawn(e) blood.spawn(e, "bloodeye") end
function event_damage_taken(e) return blood.damage(e, "bloodeye") end
