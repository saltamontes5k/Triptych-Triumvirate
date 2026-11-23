local flights = require("rof2_dodh_flights")
local roles = { seeker = 362900, stone = 362901, shattered = 362902 }

function event_enter_zone(e)
    flights.watch(e)
end

function event_task_accepted(e)
    if e.task_id == 920244 then flights.watch(e) end
end

function event_timer(e)
    flights.observe(e, roles)
end
