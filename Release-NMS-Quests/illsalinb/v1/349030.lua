local council = require("rof2_dodh_council")

function event_damage_taken(e) return council.avatar_damage(e) end
function event_combat(e) council.avatar_combat(e) end
