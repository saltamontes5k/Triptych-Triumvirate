function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 18904}) then -- Item: Faded Wedding Cloth
		e.self:Say("The slaves...thank you! Here, this will help defend you against those vile orcs.");
		e.other:QuestReward(e.self,{exp = 500});
		e.other:SummonItem(eq.ChooseRandom(2012,2004,2006,2005,2011)); -- Items: Leather Boots, Leather Tunic, Leather Cloak, Leather Shoulderpads, Leather Leggings
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
