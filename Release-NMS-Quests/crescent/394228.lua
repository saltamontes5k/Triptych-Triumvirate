local M=require('achievement_quest_mesa')
function event_say(e)M.cross_say(e)end
function event_trade(e)M.trade(e)end

-- Complete Mesa batch: preserve any previous NPC callbacks.
local mesa_remaining_before_say=event_say
function event_say(e)
 if require('achievement_quest_mesa_love').say(e)then return end
 if mesa_remaining_before_say then mesa_remaining_before_say(e)end
end
local mesa_remaining_before_trade=event_trade
function event_trade(e)
 if require('achievement_quest_mesa_love').trade(e)then return end
 if mesa_remaining_before_trade then mesa_remaining_before_trade(e)else e.self:ReturnHandinItems(e.other)end
end
