-- Owned Simu escort ambusher. No scripted kill-objective credit.
local M=require('achievement_quest_mesa_escort')
function event_timer(e) M.actor_timer(e) end
function event_death_complete(e) M.death_complete(e) end
