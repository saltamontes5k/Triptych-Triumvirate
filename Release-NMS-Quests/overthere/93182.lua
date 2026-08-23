-- Necromancer 5th Rank - Skullcap

function event_trade(e)
	local item_lib = require("items");
	if e.other:GetLevel() >= 20 and e.other:GetBucket("Skull_Cap") == "4" and item_lib.check_turn_in(e.trade, {item1 = 12848, item2 = 12850, item3 = 12851, item4 = 12610}) then
		e.self:Emote(" takes your hand and guides it into his ribcage. You feel something odd. It is a metal key!");
		e.other:QuestReward(e.self,{exp = 2000});
		e.other:SummonItem(12849);	-- Item: A metal key
	elseif e.other:GetBucket("Skull_Cap") == "4" and item_lib.check_turn_in(e.trade, {item1 = 12848}) then	-- Item: A Spectacle
		e.self:Emote(" stops working and begins to open his creaking jaw. 'I live to study and quench my thirst. I live to Bash the Faces of Pariah and entangle myself in the ivy of evergreen. I live. I want to remember.'");
		e.other:QuestReward(e.self,0,0,0,0,12848);	-- Item: A Spectacle
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
