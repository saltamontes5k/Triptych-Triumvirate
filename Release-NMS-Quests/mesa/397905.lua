local S=require('achievement_quest_mesa_friends_scenes')
function event_killed_merit(e)S.merit(e)end
function event_death_complete(e)S.death_complete(e)end
