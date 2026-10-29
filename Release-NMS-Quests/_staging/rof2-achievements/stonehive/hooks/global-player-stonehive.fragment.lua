local stone_pickup_before=event_player_pickup
function event_player_pickup(e)
 local r;if stone_pickup_before then r=stone_pickup_before(e)end
 if r==nil or r==0 then require('achievement_quest_stonehive').pickup(e)end
 return r
end
local stone_accepted_before=event_task_accepted
function event_task_accepted(e)
 if stone_accepted_before then stone_accepted_before(e)end
 require('achievement_quest_stonehive').accepted(e)
end
local stone_complete_before=event_task_complete
function event_task_complete(e)
 local result;if stone_complete_before then result=stone_complete_before(e)end
 if result==nil or result==0 then require('achievement_quest_stonehive').complete(e)end
 return result
end
local stone_enter_before=event_enter_zone
function event_enter_zone(e)
 if stone_enter_before then stone_enter_before(e)end
 require('achievement_quest_stonehive').enter(e)
end
local stone_timer_before=event_timer
function event_timer(e)
 if stone_timer_before then stone_timer_before(e)end
 require('achievement_quest_stonehive').timer(e)
end
local stone_fail_before=event_task_fail
function event_task_fail(e)
 if stone_fail_before then stone_fail_before(e)end
 require('achievement_quest_stonehive').failed(e)
end
