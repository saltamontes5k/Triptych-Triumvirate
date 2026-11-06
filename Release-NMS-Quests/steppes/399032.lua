
-- May2013 Steppes tasks; retain the original giver prefix/callbacks.
local steppes_previous_say=event_say
function event_say(e)
 if steppes_previous_say then local r=steppes_previous_say(e);if r and r~=0 then return r end end
 require('achievement_quest_steppes').say(e)
end
local steppes_previous_trade=event_trade
function event_trade(e)
 if steppes_previous_trade then return steppes_previous_trade(e)end
 require('achievement_quest_steppes').trade(e)
end
local steppes_previous_spawn=event_spawn
function event_spawn(e)
 if steppes_previous_spawn then local r=steppes_previous_spawn(e);if r and r~=0 then return r end end
 return require('achievement_quest_steppes').spawn(e)
end
local steppes_previous_despawn=event_despawn
function event_despawn(e)
 if steppes_previous_despawn then local r=steppes_previous_despawn(e);if r and r~=0 then return r end end
 return require('achievement_quest_steppes').despawn(e)
end
local steppes_previous_timer=event_timer
function event_timer(e)
 if steppes_previous_timer then local r=steppes_previous_timer(e);if r and r~=0 then return r end end
 return require('achievement_quest_steppes').timer(e)
end
local steppes_previous_killed_merit=event_killed_merit
function event_killed_merit(e)
 if steppes_previous_killed_merit then local r=steppes_previous_killed_merit(e);if r and r~=0 then return r end end
 return require('achievement_quest_steppes').killed_merit(e)
end
local steppes_previous_death_complete=event_death_complete
function event_death_complete(e)
 if steppes_previous_death_complete then local r=steppes_previous_death_complete(e);if r and r~=0 then return r end end
 return require('achievement_quest_steppes').death_complete(e)
end
