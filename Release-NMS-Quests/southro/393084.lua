-- southro/393084.lua - Dimbwicket Middifoodle
-- Prophecy of Ro: "The Great Caiman Issue" (quest 3417).
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Oh, thank goodness, a brave sort! The caimans have taken over the beach and I can't get a moment's peace. Would you clear them out for me?");
		if not e.other:IsTaskActive(por.tasks.great_caiman_issue) and not e.other:IsTaskCompleted(por.tasks.great_caiman_issue) then
			e.other:AssignTask(por.tasks.great_caiman_issue);
		end
	elseif t:find("caiman") then
		e.self:Say("Fifteen of the toothy brutes ought to do it. Mind your ankles!");
	elseif t:find("done") or t:find("finished") then
		e.self:Say("You did it! The beach is safe again. You're a hero, you are.");
	end
end
