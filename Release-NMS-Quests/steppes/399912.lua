-- rof2b port: actor dispatch for 399901 (generated).
-- Replaces the upstream composed global_npc handler chain; the
-- module filters internally by spawn identity.
local M=require('achievement_quest_steppes')
function event_killed_merit(e)M.killed_merit(e)end
function event_death_complete(e)M.death_complete(e)end
function event_despawn(e)M.despawn(e)end
function event_timer(e)if M.timer(e)then return end end
