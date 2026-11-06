-- rof2b port: actor dispatch for 397238 (generated).
-- Replaces the upstream composed global_npc handler chain; the
-- module filters internally by spawn identity.
local M=require('achievement_quest_mesa_queen')
function event_spawn(e)M.npc_spawn(e)end
function event_timer(e)if M.npc_timer(e)then return end end
