-- takishruins/376056.lua - Lilthill`yan`s Ghost
-- Prophecy of Ro: "The Chalice of Life" (55th level aura task, quest 3378).
local por = require("por_helper");

local lifestones = { 85641, 85642, 85643, 85644 }
local lifestone_activity = { [85641] = 4, [85642] = 5, [85643] = 6, [85644] = 7 }

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("The seasons turn, and I am bound to their stones. Four guardians keep me from my rest. Lay them to peace and bring me their Lifestones, and I will share what the old groves taught me.");
		if not e.other:IsTaskActive(por.tasks.chalice_of_life) and not e.other:IsTaskCompleted(por.tasks.chalice_of_life) then
			e.other:AssignTask(por.tasks.chalice_of_life);
		end
	elseif t:find("lifestone") or t:find("guardian") then
		e.self:Say("The Guardians of Spring, Summer, Autumn, and Winter each hold a Lifestone. Free them, and return the stones to me.");
	elseif t:find("chalice") then
		e.self:Say("The Chalice of Life is not a thing of metal or gem. It is the cycle itself, and I would see it mended before I pass on.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	for _, id in ipairs(lifestones) do
		if item_lib.check_turn_in(e.trade, { item1 = id }) then
			local act = lifestone_activity[id];
			if act then
				c:UpdateTaskActivity(por.tasks.chalice_of_life, act, 1);
			end
			local n = (tonumber(c:GetBucket("por.lifestones")) or 0) + 1;
			c:SetBucket("por.lifestones", tostring(n));
			e.self:Say("Another season's burden is lifted. Thank you.");
			if n >= 4 and (tonumber(c:GetBucket("por.aura55_reward")) or 0) == 0 then
				if por.grant_rewards(c, "aura55") > 0 then
					c:SetBucket("por.aura55_reward", "1");
				end
				e.self:Say("All four guardians rest. The cycle is whole again. Take this knowledge of the grove, and remember us when the seasons turn.");
			end
			return;
		end
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
