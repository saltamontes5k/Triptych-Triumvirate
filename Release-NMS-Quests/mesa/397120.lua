
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

local mesa_escort_before_timer=event_timer
function event_timer(e)
 if require('achievement_quest_mesa_escort').actor_timer(e)then return end
 if mesa_escort_before_timer then mesa_escort_before_timer(e)end
end
local mesa_escort_before_death=event_death_complete
function event_death_complete(e)
 if mesa_escort_before_death then mesa_escort_before_death(e)end
 require('achievement_quest_mesa_escort').death_complete(e)
end
