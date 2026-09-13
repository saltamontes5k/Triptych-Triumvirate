-- Sylnyk T`Vok - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("You... speak to me? Few do. Erollisi's blessing upon you.")
	ED.upd(e.other, ED.TASK.PERFECT, 2, 1)
end
