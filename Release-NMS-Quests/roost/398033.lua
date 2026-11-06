
-- Bind only an original Roost nest before its first spawn packet.
local roost_nest_previous_spawn=event_spawn
function event_spawn(e)
 require('achievement_quest_roost_nests').spawn(e)
 if roost_nest_previous_spawn then return roost_nest_previous_spawn(e)end
end
