-- Grenda - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("You not run away! You nice. Grenda like you.")
	ED.upd(e.other, ED.TASK.PERFECT, 13, 1)
end
