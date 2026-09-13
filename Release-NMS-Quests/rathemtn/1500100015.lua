-- Gilbina - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("The hills are lonely, but not today. Thank you.")
	ED.upd(e.other, ED.TASK.PERFECT, 6, 1)
end
