local key_tasks = require("rof2_dodh_public_key_tasks")

local vule = require("rof2_dodh_vule")

function event_death_zone(e)
    vule.death(e)
    key_tasks.death(e)
end

function event_loot_zone(e) return key_tasks.loot(e) end
