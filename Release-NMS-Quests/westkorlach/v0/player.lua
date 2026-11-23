local doors = require("rof2_dodh_spell_arc_doors")

function event_click_door(e)
    return doors.xill(e)
end

local widdlethorpe = require("rof2_dodh_widdlethorpe_routes")
function event_enter_zone() widdlethorpe.load() end
function event_enter_area(e) widdlethorpe.area(e) end
