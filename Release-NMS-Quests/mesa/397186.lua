-- rof2b port: actor dispatch for 397186 (generated).
-- Replaces the upstream composed global_npc handler chain; the
-- module filters internally by spawn identity.
local M=require('achievement_quest_mesa_corruption')
function event_spawn(e)M.actor_spawn(e)end
