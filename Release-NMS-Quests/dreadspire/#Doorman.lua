-- dreadspire/#Doorman.lua
-- Depths of Darkhollow: task 505761 "Memories Lost" (NMS-authored reconstruction
-- of the live doorman task). Completing it is required before Margaret Hill will
-- arrange the Master Vule expedition (dreadspire v2).
local dodh = require("dodh_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Hello, most honored guest. I hope all is going well with you and that everything here is to your satisfaction. Forgive my wandering mind - I have stood this door so long that I have [lost] nearly all of my memories.");
	elseif t:find("lost") or t:find("memor") then
		if e.other:IsTaskCompleted(dodh.tasks.memories_lost) then
			e.self:Say("It is all coming back to me now. The dinners, the guests... and the way down to Master Vule's chamber. Margaret Hill can arrange your descent whenever you are ready.");
		elseif not e.other:IsTaskActive(dodh.tasks.memories_lost) then
			e.other:AssignTask(dodh.tasks.memories_lost, e.self:GetID());
			e.self:Say("I was not always a doorman, you know. What is left of me lingers in the bats of the keep, and the Funerary Curate hoards the rest among his rites. Silence them, and I will remember the way down.");
		else
			e.self:Say("The bats still cry with my memories, and the Curate still mutters over his rites. Finish what you began, and I will remember.");
		end
	end
end
