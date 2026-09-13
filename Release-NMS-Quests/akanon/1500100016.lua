-- Mekinti - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("Fascinating! Social contact improves morale by 12 percent. Thank you.")
	ED.upd(e.other, ED.TASK.PERFECT, 7, 1)
end
