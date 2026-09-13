-- Karon - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")

function event_say(e)
	if not e.message:findi("hail") then return end
	e.self:Say("Aye, good to see you. Erollisi's Day brings out the best in folks.")
	ED.upd(e.other, ED.TASK.PERFECT, 11, 1)
end
