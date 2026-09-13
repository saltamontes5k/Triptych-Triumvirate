-- Frostfell (2007): Zobb - Rescue Hailie Biggeyes
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hailie is trapped in the northeast corner of the zone. Please rescue her!")
		FF.upd(e.other, FF.TASK.HAILIE, 1, 1)
	end
end
