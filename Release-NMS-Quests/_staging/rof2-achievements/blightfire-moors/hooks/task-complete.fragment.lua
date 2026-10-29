-- Append to existing global_player.lua; preserve the original callback.
local blightfire=require("achievement_quest_blightfire")
local previous_task_complete=event_task_complete
function event_task_complete(e)
 local result=previous_task_complete and previous_task_complete(e)
 if result and result~=0 then return result end
 blightfire.task_complete(e)
 return 0
end
