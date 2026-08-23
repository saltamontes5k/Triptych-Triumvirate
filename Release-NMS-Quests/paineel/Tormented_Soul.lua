--Quest: Azraxs' Legacy

function event_spawn(e)
	e.self:Say("Was oonncee... aliiive...");
end

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Whaaat foool does seek counsel with this spirit?");
	elseif e.message:findi("counsel") then
		e.self:Say("Yes, counsel. It means to meet and converse, fool. Waste my time with definitions of words any dullard would know and taste my anger.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if e.other:GetFaction(e.self) <= 3 and item_lib.check_turn_in(e.trade, {item1 = 7114}) then -- Kindly faction and Soul Trap
		e.self:Say("Ahhh. Sweet release. Wait... What is this? No! Do not bind me to this filthy bit of leather! Release! Curse you and curse Azrax to damnation!");
		e.other:Faction(265,15);	-- Faction: Heretics
		e.other:Faction(242,-15);	-- Faction: Deepwater Knights
		e.other:Faction(254,-15);	-- Faction: Gate Callers
		e.other:Faction(231,-15);	-- Faction: Craftkeepers
		e.other:Faction(233,-15);	-- Faction: Crimson Hands
		e.other:SummonItem(7105);	-- Item: Mantle of Souls
		e.other:QuestReward(e.self,{exp = 100});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
