-- Frostfell (2008 Frostcrypt Lair boss): Freezkorr
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You will never free Santug Claugg!")
	end
end

function event_death(e)
	local c = FF.killer(e)
	if c then
		c:Message(15, "The Frostclaw Ice Cage shatters and its prisoners are freed!")
	end
end
