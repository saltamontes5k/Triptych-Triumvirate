-- relic/370080.lua - Tenaro the Arcane
-- PoR theme completion: "Lost Brother" (303187) and "Tipped Balance" (303188).
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
		e.self:Say("Another traveler come to the Artifact City. I have lost my [brother] to these streets, and the [balance] of the courtyard grows worse by the day.");
	elseif t:find("brother") then
		if not e.other:IsTaskActive(por.tasks.lost_brother) and not e.other:IsTaskCompleted(por.tasks.lost_brother) then
			e.other:AssignTask(por.tasks.lost_brother);
			e.self:Say("He was last seen heading into the upper city. Fight your way through the scrykin and the elementals of the platforms, then return to me.");
		else
			check_reward(e, por.tasks.lost_brother, "por.lost_brother_reward", 39696, 39695,
				"You found where he walked, even if you found him not. Take this, crafted from his notes.");
		end
	elseif t:find("balance") or t:find("elements") then
		if not e.other:IsTaskActive(por.tasks.tipped_balance) and not e.other:IsTaskCompleted(por.tasks.tipped_balance) then
			e.other:AssignTask(por.tasks.tipped_balance);
			e.self:Say("The elements crowd the courtyard: earth piles, water spouts, living vortices, and stray spiritlights. Cut down three of each and the balance will hold.");
		else
			check_reward(e, por.tasks.tipped_balance, "por.tipped_balance_reward", 39698, 39697,
				"The courtyard breathes easier. My thanks - take this for your trouble.");
		end
	end
end
