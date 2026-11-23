local arrival = require("rof2_dodh_arrival")
local shadows = require("rof2_dodh_shadows")

function event_enter_zone(e)
    arrival.credit(e.self, 920245)
    shadows.watch_escape(e.self)
end

function event_click_door(e)
    return shadows.click(e)
end

function event_task_stage_complete(e)
    shadows.stage(e)
end

function event_timer(e)
    shadows.escape(e)
end
