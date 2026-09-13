-- Frostfell (2007): Gemmi Goodkin - Savior of Gemmi Goodkin
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Free at last! But look out, Father Frostheart is coming!")
		if e.other:IsTaskActive(FF.TASK.GEMMI) then
			FF.upd(e.other, FF.TASK.GEMMI, 1, 1)
			if e.other:GetTaskActivityDoneCount(FF.TASK.GEMMI, 2) < 1 then
				eq.spawn2(FF.NPC.FATHER, 0, 0, e.self:GetX() + 10, e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
			end
		end
	end
end
