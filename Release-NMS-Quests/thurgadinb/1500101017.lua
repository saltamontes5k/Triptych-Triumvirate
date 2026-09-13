-- Frostfell (2010 Operation Jolliness boss): Gezrazelm the Frostfell Dragon
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("None may disturb the Frostfell dragon's hoard!")
	end
end

function event_death(e)
	local c = FF.killer(e)
	if c and e.corpse then
		e.corpse:AddItem(87516, 1)
		c:Message(15, "Gezrazelm falls. The Spell of Hopeless Isolation can be claimed.")
	end
end
