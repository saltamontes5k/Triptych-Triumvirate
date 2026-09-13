-- Myra Denghop - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("Ach, a friendly face! That is a gift all its own.")
	ED.upd(e.other, ED.TASK.PERFECT, 4, 1)
end
