-- Erollisi Day event mob
local ED = require("erollisiday")

function event_death(e)
	local c = ED.killer(e)
	if not c then return end
	ED.upd(c, ED.TASK.LURES, 1, 1)
	if e.corpse then
		e.corpse:AddItem(ED.ITEM.IKSAR_TAILBONE, 1)
	end
end
