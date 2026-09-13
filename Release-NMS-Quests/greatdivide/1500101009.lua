-- Frostfell (2007): Hailie Biggeyes - Rescue Hailie Biggeyes
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You found me! Tell Zoog I am safe and sound.")
		FF.upd(e.other, FF.TASK.HAILIE, 2, 1)
	end
end
