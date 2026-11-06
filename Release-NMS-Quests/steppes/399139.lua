
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
