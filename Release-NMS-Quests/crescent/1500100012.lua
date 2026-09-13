-- Tilliki - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("Even here, far from home, love finds a way. Thank you for stopping.")
	ED.upd(e.other, ED.TASK.PERFECT, 3, 1)
end
