local dragonscale=require('achievement_quest_dragonscale')
local dragonscale_previous_say=event_say
function event_say(e)
 if dragonscale_previous_say then local r=dragonscale_previous_say(e);if r and r~=0 then return r end end
 return dragonscale.say(e)
end
local dragonscale_previous_accepted=event_task_accepted
function event_task_accepted(e)
 if dragonscale_previous_accepted then local r=dragonscale_previous_accepted(e);if r and r~=0 then return r end end
 return dragonscale.accepted(e)
end
local dragonscale_previous_trade=event_trade
function event_trade(e)
 if dragonscale_previous_trade then local r=dragonscale_previous_trade(e);if r and r~=0 then return r end end
 return dragonscale.trade(e)
end
