--Shaman Cudgel Quest 6
function event_death_complete(e)
	e.self:Shout("the river of Xinth...");
end

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if Shaman_Cudgel_Progress == "5" and item_lib.check_turn_in(e.trade, {item1 = 12752}) then -- Item: Potion of Swirling Liquid
		e.self:Shout("Go to where the pines have been smashed. Must reach great heights!");
		e.other:SetBucket("Shaman_Cudgel", "6.1");	-- Flag: Completed Cudgel Quest Step 6.1
		e.other:SummonItem(12750);					-- Item: Iksar Skull
		e.other:QuestReward(e.self,{exp = 50});
		eq.depop_with_timer();
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
