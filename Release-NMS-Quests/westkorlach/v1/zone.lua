local loot = require("rof2_dodh_xill_loot")

function event_death_zone(e)
    loot.death(e, 920236)
end
