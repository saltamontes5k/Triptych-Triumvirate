local key_tasks = require("rof2_dodh_public_key_tasks")

function event_encounter_load(e) key_tasks.load(e) end
function event_timer(e) key_tasks.tick(e) end
