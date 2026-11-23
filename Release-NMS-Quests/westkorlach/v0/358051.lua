local routes = require("rof2_dodh_widdlethorpe_routes")
function event_say(e) routes.say(e) end
function event_task_accepted(e) routes.accepted(e) end
