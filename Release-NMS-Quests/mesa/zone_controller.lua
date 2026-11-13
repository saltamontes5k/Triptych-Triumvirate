local C=require('achievement_quest_mesa_corruption')
local F=require('achievement_quest_mesa_friends_scenes')
function event_spawn(e)C.controller_spawn(e);F.controller_spawn(e)end
function event_timer(e)C.controller_timer(e);F.controller_timer(e)end
