-- Smarta Bragglethin - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("Hullo there! Fancy a chat? Erollisi would approve.")
	ED.upd(e.other, ED.TASK.PERFECT, 9, 1)
end
