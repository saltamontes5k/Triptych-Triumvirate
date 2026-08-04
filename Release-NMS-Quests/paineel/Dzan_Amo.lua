function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the Tabernacle of Terror. Perhaps you can control your fear long enough to be of [service] to us.");
	elseif e.message:findi("service") then
		e.self:Say("I need some things fetched from the creatures just outside our city for some ritual experimentation. Bring me two tufts of bat fur and two fire beetle legs and I will school you in the ways of terror.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 13069, item2 = 13069, item3 = 13250, item4 = 13250}) then -- Items: Bat Fur x 2, Fire Beetle Leg x 2
		e.self:Say("Very good young one. Here is something to assist in your studies of the principles of terror.");
		e.other:Faction(265,5);		-- Faction: Heretics
		e.other:Faction(254,-5);	-- Faction: Gate Callers
		e.other:Faction(242,-5);	-- Faction: Deepwater Knights
		e.other:Faction(231,-5);	-- Faction: Craftkeepers
		e.other:Faction(233,-5);	-- Faction: Crimson Hands
		e.other:SummonItem(15209);	-- Item: Spell: Spook the Dead
		e.other:QuestReward(e.self,{exp = 1000});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
