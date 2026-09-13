-- Lalanis - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("You have a gentle spirit. May love follow you always.")
	ED.upd(e.other, ED.TASK.PERFECT, 10, 1)
end
