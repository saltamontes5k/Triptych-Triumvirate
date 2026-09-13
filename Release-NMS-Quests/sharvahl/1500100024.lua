-- Kalika - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("The spirits smile upon a kind heart. Walk in love.")
	ED.upd(e.other, ED.TASK.PERFECT, 15, 1)
end
