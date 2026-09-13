-- Frostfell (2006): a grimp - clue / list / gift dropper
local FF = require("frostfell")

function event_death(e)
	local c = FF.killer(e)
	if not c or not e.corpse then return end
	if c:IsTaskActive(FF.TASK.CLUES) then
		e.corpse:AddItem(FF.CLUES[math.random(#FF.CLUES)], 1)
	end
	if c:IsTaskActive(FF.TASK.LIST) then
		e.corpse:AddItem(87531 + math.random(0, 9), 1)
		FF.upd(c, FF.TASK.LIST, 0, 1)
	end
	if c:IsTaskActive(FF.TASK.SANTUG) then
		e.corpse:AddItem(FF.ITEM.SANTUG_GIFT, 1)
		FF.upd(c, FF.TASK.SANTUG, 0, 1)
	end
end
