local dragonscale=require('achievement_quest_dragonscale')
local dragonscale_previous_spawn=event_spawn
function event_spawn(e)
 if dragonscale_previous_spawn then local r=dragonscale_previous_spawn(e);if r and r~=0 then return r end end
 return dragonscale.actor_spawn(e)
end
