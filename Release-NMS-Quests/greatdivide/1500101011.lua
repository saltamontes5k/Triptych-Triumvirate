-- Frostfell (2007): Kanf Shadowhands - Freedom of Kanf Shadowhands
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You killed the snowmen and freed me! Tell Zoog I am safe.")
		FF.upd(e.other, FF.TASK.KANF, 2, 1)
	end
end
