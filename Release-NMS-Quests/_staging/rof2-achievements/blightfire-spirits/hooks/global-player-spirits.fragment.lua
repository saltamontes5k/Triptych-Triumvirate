
-- BEGIN MAY2013 BLIGHTFIRE SPIRITS
local global_spirits=require('achievement_quest_blightfire_spirits')
local original_spirits_accepted=event_task_accepted
function event_task_accepted(e)
 if original_spirits_accepted then original_spirits_accepted(e)end
 global_spirits.player_accepted(e)
end
local original_spirits_stage=event_task_stage_complete
function event_task_stage_complete(e)
 if original_spirits_stage then original_spirits_stage(e)end
 global_spirits.player_event(e)
end
local original_spirits_enter=event_enter_zone
function event_enter_zone(e)
 if original_spirits_enter then original_spirits_enter(e)end
 global_spirits.player_enter(e)
end
local original_spirits_timer=event_timer
function event_timer(e)
 if global_spirits.player_timer(e)then return end
 if original_spirits_timer then return original_spirits_timer(e)end
end
-- END MAY2013 BLIGHTFIRE SPIRITS
