-- rof2b port: actor dispatch for 403199 (generated 2026-11-05).
-- Replaces the upstream composed global_npc handler chain; the module
-- filters internally by spawn identity.
local M = require('achievement_quest_sunderock')
function event_spawn(e) M.actor_spawn(e) end
function event_death_complete(e) M.pod_death(e) end
function event_timer(e) if M.actor_timer(e) then return end end
