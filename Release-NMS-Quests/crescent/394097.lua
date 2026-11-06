
-- Roost achievement routes: preserve other NPC quest callbacks.
local roost_previous_say=event_say
function event_say(e)
 if roost_previous_say then roost_previous_say(e)end
 require('achievement_quest_roost').say(e)
end
local roost_previous_trade=event_trade
function event_trade(e)
 if roost_previous_trade then roost_previous_trade(e)else require('achievement_quest_roost').trade(e)end
end
