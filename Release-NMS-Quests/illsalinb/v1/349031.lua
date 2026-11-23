local council = require("rof2_dodh_council")

function event_spawn(e) council.spawn_member(e) end
function event_damage_taken(e) return council.member_damage(e) end
function event_combat(e) council.combat(e) end
function event_timer(e) council.tick(e) end
