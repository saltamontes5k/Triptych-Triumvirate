
-- BEGIN MAY2013 BLIGHTFIRE SPIRITS
local spirits_doors=require('achievement_quest_blightfire_spirits')
local original_spirits_door=event_click_door
function event_click_door(e)
 local result=spirits_doors.click_door(e)
 if result~=nil then return result end
 if original_spirits_door then return original_spirits_door(e)end
end
-- END MAY2013 BLIGHTFIRE SPIRITS
