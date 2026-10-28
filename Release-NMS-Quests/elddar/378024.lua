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
	elseif t:find("seeds") or t:find("tree spirit") or t:find("grayleaf") then
		-- PoR theme completion: "Tree Spirits" (303195)
		if not e.other:IsTaskActive(por.tasks.tree_spirits) and not e.other:IsTaskCompleted(por.tasks.tree_spirits) then
			e.other:AssignTask(por.tasks.tree_spirits);
			e.self:Say("There is another way our spirits may rest. Grayleaf the Fallen walks the ruins of Takish-Hiz still, with four Treants of the Ancient Grove at his side. Gather their spirit seeds - five in all - and return to me.");
		elseif e.other:IsTaskCompleted(por.tasks.tree_spirits) then
			if (tonumber(e.other:GetBucket("por.tree_spirits_reward")) or 0) == 0 then
				if por.grant_pair(e.other, 39665, 39666) > 0 then -- Glittering Cloak of the Ruins / Jeweled Belt of the Lost
					e.other:SetBucket("por.tree_spirits_reward", "1");
				end
				e.self:Say("The seeds return to the source, and our spirits may rest at last. Take this keepsake of the old groves.");
			end
		end
	end
end
