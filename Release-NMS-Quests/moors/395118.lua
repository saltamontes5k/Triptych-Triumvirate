local M=require("achievement_quest_blightfire")
function event_say(e)M.say(e)end
function event_trade(e)M.trade(e)end

local welcome=require('achievement_quest_blightfire_welcome')
local prior_welcome_say=event_say
function event_say(e)if prior_welcome_say then prior_welcome_say(e)end;welcome.say(e)end
local prior_welcome_trade=event_trade
function event_trade(e)if prior_welcome_trade then prior_welcome_trade(e)end;welcome.player_event({self=e.other})end
