-- Gorble - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("Pretty words. Gorble feel warm inside. Thank you.")
	ED.upd(e.other, ED.TASK.PERFECT, 14, 1)
end
