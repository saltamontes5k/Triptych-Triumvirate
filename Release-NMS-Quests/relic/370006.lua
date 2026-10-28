-- relic/370006.lua - G`kil Zon
-- PoR theme completion: "Crossfire" (303191).
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("A supplier! Or a marksman? Either will do. My [suppliers] on Arcstone have not reported in, and I am running short of everything.");
	elseif t:find("supplier") or t:find("arcstone") or t:find("crossfire") then
		if not e.other:IsTaskActive(por.tasks.crossfire) and not e.other:IsTaskCompleted(por.tasks.crossfire) then
			e.other:AssignTask(por.tasks.crossfire);
			e.self:Say("Four measures of spirit dust from the fallen spirits, four stag hooves, and the Master of the Herd himself put down - his herd tramples my caravan routes.");
		elseif e.other:IsTaskCompleted(por.tasks.crossfire) and (tonumber(e.other:GetBucket("por.crossfire_reward")) or 0) == 0 then
			e.other:SummonFixedItem(39710); -- Relic Shopkeeper's Charm
			e.other:SetBucket("por.crossfire_reward", "1");
			e.self:Say("Dust, hooves, and a dead master of herds - the caravan roads are yours to share. Take this charm; it has brought me luck, and now it is yours.");
		end
	end
end
