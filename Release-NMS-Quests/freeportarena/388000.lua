-- freeportarena/388000.lua - Knight Champion Eddard
-- Prophecy of Ro: "Arena Champion's Badge" (3403). Grants the badge and a task
-- to best the arena contestants.
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Think you have what it takes to be Arena Champion? The contestants are waiting. Prove it.");
		if not e.other:IsTaskActive(por.tasks.arena_champions_badge) and not e.other:IsTaskCompleted(por.tasks.arena_champions_badge) then
			e.other:AssignTask(por.tasks.arena_champions_badge);
			if not e.other:HasItem(39198) then
				e.other:SummonFixedItem(39198); -- Arena Champion's Badge
			end
		end
	elseif t:find("champion") or t:find("badge") or t:find("arena") then
		if e.other:IsTaskCompleted(por.tasks.arena_champions_badge) then
			e.self:Say("Well fought. You have earned the title, champion. Wear the badge with pride.");
		else
			e.self:Say("Defeat the arena contestants, then return to me to claim your place.");
		end
	end
end
