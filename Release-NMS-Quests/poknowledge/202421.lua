-- Frostfell (2010): #Kuutas_Gigglegibber - Gathering Holiday Cheer giver
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Happy Frostfell! Care to make an [agreement] and [start] gathering holiday cheer?")
	elseif e.message:findi("agreement") or e.message:findi("start") then
		FF.assign(e.other, FF.TASK.CHEER)
		e.self:Say("Gather five Convivial Gorilla Brainstems in The Feerrott for Dorik Gigglegibber.")
	end
end
