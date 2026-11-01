
local shard_arc = require("shards_partisan")
local shard_previous_event_killed_merit = event_killed_merit
function event_killed_merit(e)
    if shard_previous_event_killed_merit then local old_result=shard_previous_event_killed_merit(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.killed(e)
end
local shard_previous_event_death = event_death
function event_death(e)
    if shard_previous_event_death then local old_result=shard_previous_event_death(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.death(e)
end
