--Qeynos Research Badge Quest
--Quest script for tiles on Enchanted Rat Minigame

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 2584}) then -- Item: Live Enchanted Rat: Jar 1
		e.other:SummonItem(2587); -- Item: Empty Enchanted Jar 1
		eq.spawn2(2181, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0); -- NPC: #Enchanted_Rat
		eq.signal(2052,1); -- NPC: Velarte_Selire
		eq.depop();
	elseif item_lib.check_turn_in(e.trade, {item1 = 2585}) then -- Item: Live Enchanted Rat: Jar 2
		e.other:SummonItem(2588); -- Item: Empty Enchanted Jar 2
		eq.spawn2(2181, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0); -- NPC: #Enchanted_Rat
		eq.signal(2052,1); -- NPC: Velarte_Selire
		eq.depop();
	elseif item_lib.check_turn_in(e.trade, {item1 = 2586}) then -- Item: Live Enchanted Rat: Jar 3
		e.other:SummonItem(2589);-- Item: Empty Enchanted Jar 3
		eq.spawn2(2181, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0); -- NPC: #Enchanted_Rat
		eq.signal(2052,1); -- NPC: Velarte_Selire
		eq.depop();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
