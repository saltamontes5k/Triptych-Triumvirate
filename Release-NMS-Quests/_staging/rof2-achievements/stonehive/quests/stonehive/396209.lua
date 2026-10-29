local M=require('achievement_quest_stonehive_scenes')
function event_spawn(e)M.queen_spawn(e)end
function event_combat(e)M.queen_combat(e)end
function event_hp(e)M.queen_hp(e)end
function event_timer(e)M.queen_timer(e)end
function event_death_complete(e)M.queen_end(e)end
