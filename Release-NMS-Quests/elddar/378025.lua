-- elddar/378025.lua - Arch Druid Lilthill`yan
-- PoR theme completion: "Giant Problems" (303196) and "The Orcish Loggers" (303197).
local por = require("por_helper");

local function check_reward(e, task_id, bucket, caster_item, melee_item, text)
	local c = e.other;
	if c:IsTaskCompleted(task_id) and (tonumber(c:GetBucket(bucket)) or 0) == 0 then
		if por.grant_pair(c, caster_item, melee_item) > 0 then
			c:SetBucket(bucket, "1");
			e.self:Say(text);
		end
	end
end

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("The forest cries out, and I cannot answer it alone. The [giants] of Clan Vorzek thunder in the west, and the [loggers] strip the east bare. Will you help?");
	elseif t:find("giant") then
		if not e.other:IsTaskActive(por.tasks.giant_problems) and not e.other:IsTaskCompleted(por.tasks.giant_problems) then
			e.other:AssignTask(por.tasks.giant_problems);
			e.self:Say("Fifteen of the brutes, then we will speak of progress. They camp across the west of the forest.");
		else
			check_reward(e, por.tasks.giant_problems, "por.giant_problems_reward", 39687, 39688,
				"The thunder in the west has quieted. Accept this, with the forest's thanks.");
		end
	elseif t:find("logger") or t:find("hatchet") or t:find("nogdha") then
		if not e.other:IsTaskActive(por.tasks.the_orcish_loggers) and not e.other:IsTaskCompleted(por.tasks.the_orcish_loggers) then
			e.other:AssignTask(por.tasks.the_orcish_loggers);
			e.self:Say("Bring me eight of their hatchets, and put an end to High Chief Gahran`Gahn. The trees of the northeast will owe you their lives.");
		else
			check_reward(e, por.tasks.the_orcish_loggers, "por.orcish_loggers_reward", 39689, 39690,
				"The loggers are broken and their chief is dead. The trees will remember you. Take this.");
		end
	end
end
