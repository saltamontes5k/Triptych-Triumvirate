function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18782) then -- Recruitment Letter
		e.other:Message(MT.Yellow,"A stern looking man turns to greet you as you get your bearings. 'Come, young recruit. I am Regren, Guild Master of the Emerald Warriors. Read the note in your inventory and then hand it to me to begin your training as a proud Warrior. Unless you would rather prance about with the pixies and such. The choice is yours.'");
	end
end

function event_say(e)
	if e.message:findi("hail") then
		if e.other:GetFaction(e.self) < 5 then -- requires amiable faction
			e.self:Say("Welcome, warrior! Show the Emerald Warriors your mettle and bring me a ruined wolf pelt, some bat fur, some bone chips, and a spiderling eye from the depths of Greater Faydark. If you succeed, my admiration and a reward will be yours. To battle!");
		else
			e.self:Say("Come back to me when you have proven your loyalty to the Emerald Warriors.");
		end
	elseif e.message:findi("trades") then
		e.self:Say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		e.other:SummonItem(51121); -- Item: Tradeskill Basics : Volume I
	elseif e.message:findi("second book") then
		e.self:Say("Here is the second volume of the book you requested, may it serve you well!");
		e.other:SummonItem(51122); -- Item: Tradeskill Basics : Volume II
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 18782}) then -- Item: Recruitment Letter
		e.self:Say("Welcome to the Emerald Warriors. Hmmm, you have a lot of training to do, so let's get started right away. Here's our guild tunic, represent us well, young $name. Once you are ready to begin your training please make sure that you see Josylyn Greenblade, she can assist you in developing your hunting and gathering skills. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		e.other:QuestReward(e.self,{exp = 100});
		e.other:SummonItem(13533);	-- Item: Old Green Tunic
		e.other:Faction(326,100);	-- Faction: Emerald Warriors
		e.other:Faction(270,-15);	-- Faction: Indigo Brotherhood
		e.other:Faction(325,10);	-- Faction: Merchants of Felwithe
		e.other:Faction(276,10);	-- Faction: Kelethin Merchants
	elseif e.other:GetFaction(e.self) < 5 then -- requires amiable faction
		if item_lib.check_turn_in(e.trade, {item1 = 13073,item2 = 13782,item3 = 13253,item4 = 13069}) then
			e.other:QuestReward(e.self,{exp = 500});
			e.other:SummonItem(eq.ChooseRandom(5013,5014,5015,5016,5019,5020,5021,5022,5023,5024,5025,5042,5043,5044,5045,5046,5047,5048,5049,5070,5071,6011,6013,6014,6015,6016,6030,6031,6032,6033,7007,7008,7009,7010,7021,7022,7023,7024));	-- Items: Random
			e.other:Faction(326,1);		-- Faction: Emerald Warriors
			e.other:Faction(270,-1);	-- Faction: Indigo Brotherhood
			e.other:Faction(325,1);		-- Faction: Merchants of Felwithe
			e.other:Faction(276,1);		-- Faction: Kelethin Merchants
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
