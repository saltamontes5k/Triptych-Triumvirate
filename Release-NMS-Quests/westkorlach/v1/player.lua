local arrival = require("rof2_dodh_arrival")

function event_enter_zone(e)
    arrival.credit(e.self, 920236)
end
