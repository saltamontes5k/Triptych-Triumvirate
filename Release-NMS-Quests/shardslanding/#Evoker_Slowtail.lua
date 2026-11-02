
local shard_arc = require("shards_partisan")
local shard_previous_event_say = event_say
function event_say(e)
    if shard_previous_event_say then local old_result=shard_previous_event_say(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.say(e)
end
