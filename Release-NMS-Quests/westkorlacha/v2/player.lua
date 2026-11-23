local arrival = require("rof2_dodh_arrival")
local ilsuras = require("rof2_dodh_ilsuras")

function event_enter_zone(e)
    arrival.credit(e.self, 920239)
    ilsuras.enter(e)
end

function event_zone(e)
    ilsuras.leave(e)
end

function event_click_door(e)
    return ilsuras.click(e)
end

function event_timer(e)
    ilsuras.tick(e)
end
