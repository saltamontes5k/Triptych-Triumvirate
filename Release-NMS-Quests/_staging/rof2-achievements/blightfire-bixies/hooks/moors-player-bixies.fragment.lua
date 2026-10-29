-- Compose after the installed job-board fragment; preserve its returned value.
local bixie_scenes=require('achievement_quest_bixie_scenes')
local previous_click=event_click_door
function event_click_door(e)
 local result=bixie_scenes.click_door(e)
 if result~=nil then return result end
 if previous_click then return previous_click(e) end
end
local previous_enter=event_enter_zone
function event_enter_zone(e)
 if previous_enter then previous_enter(e) end
 bixie_scenes.player_enter(e)
end
local previous_timer=event_timer
function event_timer(e)
 if bixie_scenes.player_timer(e) then return end
 if previous_timer then return previous_timer(e) end
end
