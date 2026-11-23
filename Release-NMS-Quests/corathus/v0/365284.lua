local key_tasks = require("rof2_dodh_public_key_tasks")

local requesters = require("rof2_dodh_requesters")
function event_say(e)
    if not key_tasks.treddle(e) then requesters.say(e) end
end
