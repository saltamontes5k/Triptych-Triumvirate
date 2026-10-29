
-- BEGIN MAY2013 BLIGHTFIRE WELCOME
local welcome_global=require('achievement_quest_blightfire_welcome')
local previous_welcome_event_task_accepted=event_task_accepted
function event_task_accepted(e)
 if previous_welcome_event_task_accepted then previous_welcome_event_task_accepted(e)end
 welcome_global.player_accepted(e)
end
local previous_welcome_event_task_stage_complete=event_task_stage_complete
function event_task_stage_complete(e)
 if previous_welcome_event_task_stage_complete then previous_welcome_event_task_stage_complete(e)end
 welcome_global.player_event(e)
end
local previous_welcome_event_enter_zone=event_enter_zone
function event_enter_zone(e)
 if previous_welcome_event_enter_zone then previous_welcome_event_enter_zone(e)end
 welcome_global.player_event(e)
end
local previous_welcome_event_task_complete=event_task_complete
function event_task_complete(e)
 if previous_welcome_event_task_complete then previous_welcome_event_task_complete(e)end
 welcome_global.task_complete(e)
end
local previous_welcome_timer=event_timer
function event_timer(e)
 if welcome_global.player_timer(e)then return end
 if previous_welcome_timer then return previous_welcome_timer(e)end
end
-- END MAY2013 BLIGHTFIRE WELCOME
