local count = 0;

function event_spawn(e)
	eq.set_timer("shout",17 * 1000);
end

function event_timer(e)
	if e.timer == "shout" then
		count = count + 1;
	end

	if count then
		e.self:Shout("Grrrraaaaarrrrrg! The stench of fear permeates the walls of this city! I will forge one item for the faithful of our Lord Cazic-Thule! Make haste!  My time here is short!");
	end

	if count == 10 then
		eq.depop();
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 14106}) then -- Item: Mundane Mask
		e.self:Say("Wear this mask imbued with my very essence. Wear it in honor of your great services to our Lord Cazic-Thule!");
		e.other:Faction(265,50);	-- Faction: Heretics
		e.other:Faction(254,-50);	-- Faction: Gate Callers
		e.other:Faction(242,-50);	-- Faction: Deepwater Knights
		e.other:Faction(231,-50);	-- Faction: Craftkeepers
		e.other:Faction(233,-50);	-- Faction: Crimson Hands
		e.other:SummonItem(14108);	-- Item: Terror Forged Mask
		e.other:QuestReward(e.self,{exp = 5000});
		eq.depop();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
