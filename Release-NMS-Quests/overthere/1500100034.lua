-- Erollisi Day event mob (Crazy Little Thing)
local ED = require("erollisiday")

function event_death(e)
	local c = ED.killer(e)
	if c then ED.upd(c, ED.TASK.CRAZY, 1, 1) end
end
