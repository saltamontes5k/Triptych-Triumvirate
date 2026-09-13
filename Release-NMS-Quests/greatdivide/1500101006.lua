-- Frostfell (2007): Zipp - Freedom of Kanf Shadowhands
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Kanf was carried off to the Tizmak Caves. Please free him!")
		FF.upd(e.other, FF.TASK.KANF, 1, 1)
	end
end
