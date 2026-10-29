local M=require('achievement_quest_blightfire_champion')
function event_spawn(e)M.defan_spawn(e)end
function event_say(e)M.say(e)end
function event_trade(e)M.defan_trade(e)end
function event_hp(e)M.defan_hp(e)end
function event_death(e)return M.defan_death(e)end
function event_killed_merit(e)M.defan_merit(e)end
function event_timer(e)M.tower_timer(e)end
