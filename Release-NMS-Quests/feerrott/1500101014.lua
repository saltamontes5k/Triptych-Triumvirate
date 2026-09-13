-- Frostfell (2010): a convivial gorilla - Gathering Holiday Cheer
local FF = require("frostfell")

function event_death(e)
	local c = FF.killer(e)
	if not c or not e.corpse then return end
	if c:IsTaskActive(FF.TASK.CHEER) then
		e.corpse:AddItem(FF.ITEM.BRAINSTEM, 1)
		FF.upd(c, FF.TASK.CHEER, 0, 1)
	end
end
