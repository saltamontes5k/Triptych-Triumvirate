-- Marnia McMensen - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("Well met, friend! A kind word on a cold day warms the heart.")
	ED.upd(e.other, ED.TASK.PERFECT, 1, 1)
end
