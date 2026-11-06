-- rof2b port: actor dispatch for 404902 (generated).
-- Replaces the upstream composed global_npc handler chain; the
-- module filters internally by spawn identity.
local M=require('vergalid_scene_native')
function event_spawn(e)M.actor_spawn(e)end
function event_death_complete(e)M.death(e)end
function event_timer(e)if M.actor_timer(e)then return end end
