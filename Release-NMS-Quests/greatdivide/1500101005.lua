-- Frostfell (2007): Zott - Search for Bram Bandyboot
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Bram went northeast to look for toys. Please find him!")
		FF.upd(e.other, FF.TASK.BRAM, 1, 1)
	end
end
