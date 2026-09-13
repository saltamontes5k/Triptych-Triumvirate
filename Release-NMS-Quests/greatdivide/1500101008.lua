-- Frostfell (2007): Bram Bandyboot - Search for Bram Bandyboot
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Thank you for driving off those snowmen! Tell Zoog I am safe.")
		FF.upd(e.other, FF.TASK.BRAM, 2, 1)
	end
end
