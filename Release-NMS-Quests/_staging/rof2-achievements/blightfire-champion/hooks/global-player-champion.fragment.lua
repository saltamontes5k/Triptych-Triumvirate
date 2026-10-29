
-- BEGIN MAY2013 BLIGHTFIRE CHAMPION
local champion_global=require('achievement_quest_blightfire_champion')
local prior_champion_event_task_accepted=event_task_accepted
function event_task_accepted(e)
 if prior_champion_event_task_accepted then prior_champion_event_task_accepted(e)end
 champion_global.player(e)
end
local prior_champion_event_task_complete=event_task_complete
function event_task_complete(e)
 if prior_champion_event_task_complete then prior_champion_event_task_complete(e)end
 champion_global.complete(e)
end
-- END MAY2013 BLIGHTFIRE CHAMPION
