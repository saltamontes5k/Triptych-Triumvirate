-- Kirilin - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("The light of Erollisi shines even here. Bless you.")
	ED.upd(e.other, ED.TASK.PERFECT, 8, 1)
end
