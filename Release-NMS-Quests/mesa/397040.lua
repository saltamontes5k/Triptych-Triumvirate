local F=require('achievement_quest_mesa_friends')
function event_say(e)F.say(e)end
-- No trade callback: native task delivery consumes exactly the credited count
-- and the core returns unrelated items/coins. Elder Vasile's existing Roost
-- callback already delegates to the common native task-hand-in adapter.
