-- Alleana - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("The forest sings of love today. And now, so do you.")
	ED.upd(e.other, ED.TASK.PERFECT, 16, 1)
end
