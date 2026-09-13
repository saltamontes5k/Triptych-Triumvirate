-- arcstone/369000.lua - Spirit Hunter Azmaro
-- Prophecy of Ro: "Exploring Arcstone" (3430). Short exploration task.
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Another wanderer. The spirits of this isle do not take kindly to strangers, yet here you stand. Perhaps you can help me map the dangers here.");
		if not e.other:IsTaskActive(por.tasks.exploring_arcstone) and not e.other:IsTaskCompleted(por.tasks.exploring_arcstone) then
			e.other:AssignTask(por.tasks.exploring_arcstone);
		end
	elseif t:find("explore") or t:find("help") or t:find("report") then
		if e.other:IsTaskCompleted(por.tasks.exploring_arcstone) then
			e.self:Say("You have seen the isle and survived. That is knowledge enough. Walk with the spirits' favor.");
		else
			e.self:Say("Walk the isle, observe the spirits, and return to me. Do not linger where the air turns cold.");
		end
	end
end
