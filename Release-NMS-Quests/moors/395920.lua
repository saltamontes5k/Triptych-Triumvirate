local M=require('achievement_quest_blightfire_welcome')
function event_killed_merit(e)M.croc_kill(e)end
function event_timer(e)M.actor_timer(e)end
