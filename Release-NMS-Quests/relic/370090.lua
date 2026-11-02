-- relic/370090.lua - Head Servant Hithorin
-- PoR theme completion: "Alley of the Damned" (303189) and "Trouble with Dirt" (303190).
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
		e.self:Say("Welcome to my alley, such as it is. The [damned] scrykin wail night and day, and now the [dirt] itself rises against us. Can you help?");
	elseif t:find("damned") or t:find("alley") then
		if not e.other:IsTaskActive(por.tasks.alley_of_the_damned) and not e.other:IsTaskCompleted(por.tasks.alley_of_the_damned) then
			e.other:AssignTask(por.tasks.alley_of_the_damned);
			e.self:Say("Fight the mad scrykin down - eight of them - and they will find their senses, or their rest. Either suits me.");
		else
			check_reward(e, por.tasks.alley_of_the_damned, "por.alley_reward", 39701, 39702,
				"The alley is quiet at last. Take this, from the servants' stores.");
		end
	elseif t:find("dirt") or t:find("earth") or t:find("elemental") then
		if not e.other:IsTaskActive(por.tasks.trouble_with_dirt) and not e.other:IsTaskCompleted(por.tasks.trouble_with_dirt) then
			e.other:AssignTask(por.tasks.trouble_with_dirt);
			e.self:Say("The earthen mages and their constructs stir in the deep strata. Ten of the things, and their ringleader Xanthrin with them.");
		else
			check_reward(e, por.tasks.trouble_with_dirt, "por.dirt_reward", 39703, 39704,
				"The city stands on firmer ground now. This is yours, with my thanks.");
		end
	end
end
