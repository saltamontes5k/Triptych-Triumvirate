local arrival = require("rof2_dodh_arrival")
local doors = require("rof2_dodh_spell_arc_doors")

function event_enter_zone(e)
    arrival.credit(e.self, 920242)
end

function event_click_door(e)
    return doors.praetorian_exit(e)
end
