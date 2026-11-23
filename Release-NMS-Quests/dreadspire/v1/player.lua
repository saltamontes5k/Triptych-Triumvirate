local admission = require("rof2_dodh_demi_admission")
local scene = require("rof2_dodh_demi_controller")

function event_enter_zone(e)
    admission.enter(e)
    if admission.expedition(e.self) then
        eq.load_encounter("rof2_dodh_demi_raid")
        scene.enter(e.self)
    end
end

function event_click_door(e)
    if scene.door(e) == 1 then return 1 end
    return admission.internal_door(e)
end
