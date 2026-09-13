-- Erollisi Day event mob
local ED = require("erollisiday")

function event_death(e)
	local c = ED.killer(e)
	if not c then return end
	ED.upd(c, ED.TASK.LURES, 3, 1)
	if e.corpse then
		e.corpse:AddItem(ED.ITEM.SARNAK_VOICEBOX, 1)
	end
end
