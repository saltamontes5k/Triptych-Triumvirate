-- Merge into existing player.lua, preserving unrelated callbacks.
-- Install only after NPC-bound task-selector API is deployed.
local blightfire=require("achievement_quest_blightfire")
local prior_click_door=event_click_door
function event_click_door(e)
 local result=blightfire.click_door(e)
 if result~=nil then return result end
 if prior_click_door then return prior_click_door(e) end
end
