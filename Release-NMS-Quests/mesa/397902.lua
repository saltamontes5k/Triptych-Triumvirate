-- Owned Kathryn defense attacker; never a generic zone kill-credit hook.
local M=require('achievement_quest_mesa_defense')
function event_timer(e) M.actor_timer(e) end
function event_killed_merit(e) M.merit(e) end
function event_death_complete(e) M.death_complete(e) end
