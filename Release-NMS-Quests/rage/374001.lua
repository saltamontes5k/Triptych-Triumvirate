-- rage/374001.lua - a dark initiate (Sverag zone-in)
-- PoR theme completion: "The Rage Within" (303198), the alternate Plane of Rage
-- spell task. The collect trophies (88060-88068, minus the undead skull the
-- controlling army carries) drop from the marching armies in The Devastation.
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("So. You would walk the Stronghold of Rage with power worthy of it. The armies that march on Sverag carry tokens of their rage. Bring me four - from any race but the undead that holds the walls - and the rage will be yours.");
	elseif t:find("rage") or t:find("spell") or t:find("power") or t:find("trophy") then
		local c = e.other;
		if not c:IsTaskActive(por.tasks.the_rage_within) and not c:IsTaskCompleted(por.tasks.the_rage_within) then
			c:AssignTask(por.tasks.the_rage_within);
			e.self:Say("Ears, paws, heads, tentacles - whatever the armies of the Devastation carry. Four trophies. Go.");
		elseif c:IsTaskCompleted(por.tasks.the_rage_within) and (tonumber(c:GetBucket("por.rage_within_reward")) or 0) == 0 then
			if por.grant_rewards(c, "rage") > 0 then
				c:SetBucket("por.rage_within_reward", "1");
				e.self:Say("I feel it in you now. The rage recognizes its own. Wield it well.");
			end
		end
	end
end
