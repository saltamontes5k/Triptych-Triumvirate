local sisters = require("rof2_dodh_sisters")
local ids = require("rof2_dodh_raid_ids")

function event_spawn(e) sisters.spawn(e) end
function event_timer(e) sisters.tick(e) end
function event_say(e) sisters.say(e, ids.sister_handbag) end
function event_damage_taken(e) return -1 end
