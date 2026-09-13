-- Veintana - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("In this grim place, a kind word is a rare treasure.")
	ED.upd(e.other, ED.TASK.PERFECT, 5, 1)
end
