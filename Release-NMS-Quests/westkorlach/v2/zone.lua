local boss = require("rof2_dodh_xill_boss")
local loot = require("rof2_dodh_xill_loot")

function event_death_zone(e)
    boss.death(e)
    loot.death(e, 920238)
end
