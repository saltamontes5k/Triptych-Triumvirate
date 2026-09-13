-- Frostfell (2012): #Santug_Claugg`s_Helper - Braxi Roundup
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Happy Frostfell! The Braxi have escaped again. I wudd help if you will help me.")
	elseif e.message:findi("wudd") or e.message:findi("help") then
		FF.assign(e.other, FF.TASK.BRAXI)
		e.self:Say("The Braxi fled into Beasts' Domain. Speak with the harrowed Gigglegibber Goblin there.")
	end
end
