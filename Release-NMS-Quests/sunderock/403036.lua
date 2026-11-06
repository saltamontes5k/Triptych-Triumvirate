local sunderock_previous_say=event_say
function event_say(e)
 if sunderock_previous_say then local r=sunderock_previous_say(e);if r and r~=0 then return r end end
 return require('achievement_quest_sunderock').say(e)
end
local sunderock_previous_trade=event_trade
function event_trade(e)
 -- An existing hand-in callback retains custody ownership. Preflight rejects
 -- unreviewed existing trade owners rather than consuming an item twice.
 if sunderock_previous_trade then return sunderock_previous_trade(e)end
 require('achievement_quest_sunderock').trade(e)
end
