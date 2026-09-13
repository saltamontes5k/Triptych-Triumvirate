-- Frostfell (2007): a frostheart snowman - Great Divide trash
local FF = require("frostfell")

function event_death(e)
	local c = FF.killer(e)
	if not c or not e.corpse then return end
	e.corpse:AddItem(FF.SNOWMAN_LOOT[math.random(#FF.SNOWMAN_LOOT)], 1)
end
