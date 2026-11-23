local arrival = require("rof2_dodh_arrival")
local boss = require("rof2_dodh_xill_boss")

function event_enter_zone(e)
    arrival.credit(e.self, 920238)
    boss.watch(e.self, 920238)
end

function event_timer(e)
    boss.tick(e, 920238)
end
