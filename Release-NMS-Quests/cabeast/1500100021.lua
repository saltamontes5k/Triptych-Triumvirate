-- Zarkys - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("Even in Cabilis, the heart knows love. Thank you, stranger.")
	ED.upd(e.other, ED.TASK.PERFECT, 12, 1)
end
