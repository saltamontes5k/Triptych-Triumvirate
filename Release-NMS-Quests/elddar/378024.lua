-- elddar/378024.lua - Speaker Grayleaf
-- Prophecy of Ro: "Tree Heaven" (3527). Gives the Pouch of Treant Spirit Seeds.
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("A [curse] is settling in on these woods. Nothing can be done to stop this.");
	elseif t:find("curse") then
		e.self:Say("Although it has not yet come to pass, I have heard of this curse whispered by the wind and the river. Our roots are too deep to leave. I understand you are from another time? Maybe you will be able to give our spirits [rest] after these woods are enveloped by sand.");
	elseif t:find("rest") then
		e.self:Say("Our spirits must be returned to the source. Take these seeds to the Dryad of Tunare in the Plane of Growth. She lives high in the ancient tree that towers above the rest. Look for it in the northeast. She will reward you for your journey.");
		if not e.other:IsTaskActive(por.tasks.tree_heaven) and not e.other:IsTaskCompleted(por.tasks.tree_heaven) then
			e.other:AssignTask(por.tasks.tree_heaven);
		end
		if not e.other:HasItem(85645) then
			e.other:SummonFixedItem(85645); -- Pouch of Treant Spirit Seeds
		end
	end
end
