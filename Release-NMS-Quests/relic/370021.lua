-- relic/370021.lua - Arena Overseer
-- Prophecy of Ro: "Challenge of the Circle" (quest 3410).
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("You wish to test yourself in the Circle? The champions of the Circle await. Defeat them and I will reward you as a champion yourself.");
		if not e.other:IsTaskActive(por.tasks.challenge_of_the_circle) and not e.other:IsTaskCompleted(por.tasks.challenge_of_the_circle) then
			e.other:AssignTask(por.tasks.challenge_of_the_circle);
		end
	elseif t:find("challenge") or t:find("circle") then
		if e.other:IsTaskCompleted(por.tasks.challenge_of_the_circle) then
			if (tonumber(e.other:GetBucket("por.circle_reward")) or 0) == 0 then
				if por.grant_circle_reward(e.other) > 0 then
					e.other:SetBucket("por.circle_reward", "1");
				end
			end
			e.self:Say("You have bested the champions of the Circle. Take your reward, champion.");
		else
			e.self:Say("Arkon of the Sixth, Hurlinor of the Fifth, and KaChnt of the Fourth still stand. Best all three and return to me.");
		end
	end
end
