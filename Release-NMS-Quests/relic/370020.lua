-- relic/370020.lua - Borso
-- Prophecy of Ro: "The Needy" (3412) and "A Shopkeeper's Delight" (3396).
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Looking for something special? I craft fine jewelry, but I am short of materials. Tellen's supply runners carry what I need, though Tellen would [rather] I not have it.");
		if not e.other:IsTaskActive(por.tasks.the_needy) and not e.other:IsTaskCompleted(por.tasks.the_needy) then
			e.other:AssignTask(por.tasks.the_needy);
			e.other:AssignTask(por.tasks.a_shopkeepers_delight);
		end
	elseif t:find("needy") or t:find("supplies") then
		e.self:Say("Bring me Tellen's Trinket Chest and one of his Supply Crates, and I will make it worth your while.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	if item_lib.check_turn_in(e.trade, { item1 = 36123 }) then
		c:UpdateTaskActivity(por.tasks.the_needy, 0, 1);
		if (tonumber(c:GetBucket("por.borso_ring")) or 0) == 0 then
			c:SummonFixedItem(39708); -- Borso's Prized Ring
			c:SetBucket("por.borso_ring", "1");
		end
		e.self:Say("Tellen's trinkets! Excellent. Here, a ring I fashioned from the finest stones.");
		return;
	end

	if item_lib.check_turn_in(e.trade, { item1 = 36124 }) then
		c:UpdateTaskActivity(por.tasks.a_shopkeepers_delight, 0, 1);
		if (tonumber(c:GetBucket("por.borso_earring")) or 0) == 0 then
			c:SummonFixedItem(39707); -- Borso's Prized Earring
			c:SetBucket("por.borso_earring", "1");
		end
		e.self:Say("A supply crate! You have done me a great favor. Take this earring for your trouble.");
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
