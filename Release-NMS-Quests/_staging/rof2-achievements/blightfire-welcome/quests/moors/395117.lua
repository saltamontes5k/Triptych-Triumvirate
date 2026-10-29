
local welcome=require('achievement_quest_blightfire_welcome')
local prior_welcome_say=event_say
function event_say(e)if prior_welcome_say then prior_welcome_say(e)end;welcome.say(e)end
function event_trade(e)welcome.trade(e)end
