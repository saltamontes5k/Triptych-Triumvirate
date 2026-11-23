local blood = require("rof2_dodh_blood_raids")

function event_spawn(e) blood.spawn(e, "draygun") end
function event_timer(e) blood.tick(e, "draygun") end
