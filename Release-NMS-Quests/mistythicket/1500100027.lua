-- Erollisi Day event mob
local ED = require("erollisiday")

function event_death(e)
	local c = ED.killer(e)
	if not c then return end
	ED.upd(c, ED.TASK.FINDME, 1, 1)
	if e.corpse then
		e.corpse:AddItem(ED.ITEM.TORN_FLYER, 1)
	end
end
