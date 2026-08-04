function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18018) then -- Item: Dark Truth Guild Note
		e.other:Message(MT.Yellow,"The cold voice of a female echoes in your mind, 'Come to me, young Necromancer. I am Coriante Verisue. Read the note in your inventory and hand it to me so that you may begin on the path of the Necromancer. True power can be yours should you have the will to train in the necromantic arts.'");
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, young one! There are many tasks to be performed aside from your studies to truly harness the powers passed down to us by our ancestor [Miragul]. The most basic of these tasks is the gathering of bat wings and snake fangs from the yard outside our city. I will reward you for every two bat wings and two snake fangs you bring to me.");
	elseif e.message:findi("miragul") then
		e.self:Say("You do not know of Miragul?!! You have more to learn of the heritage of the Dark Truth than at first I thought. Miragul was the first High Man to unlock the secrets of necromancy and is the founder of our city as well as the creator of the treacherous Hole.");
	elseif e.message:findi("trades") then
		e.self:Say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		if e.other:HasItem(51121) then
			e.other:SummonItem(51121); -- Item: Tradeskill Basics : Volume I
		end
	elseif e.message:findi("second book") then
		e.self:Say("Here is the second volume of the book you requested, may it serve you well!")
		if e.other:HasItem(51122) then
			e.other:SummonItem(51122); -- Item: Tradeskill Basics : Volume II
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 18018}) then -- Item: Dark Truth Guild Note
		e.self:Say("You are welcomed into the fold.  Now go out, and prove yourself, young one.  You have much to learn about the Dark Truth, as well as in some of the various [trades] you will have available to you.");
		e.other:Faction(265,100);	-- Faction: Heretics
		e.other:Faction(254,-100);	-- Faction: Gate Callers
		e.other:Faction(242,-100);	-- Faction: Deepwater Knights
		e.other:Faction(231,-100);	-- Faction: Craftkeepers
		e.other:Faction(233,-100);	-- Faction: Crimson Hands
		e.other:SummonItem(13551);	-- Item: Dirt Soiled Robe*
		e.other:QuestReward(e.self,{exp = 100});
	elseif item_lib.check_turn_in(e.trade, {item1 = 13068, item2 = 13068, item3 = 13067, item4 = 13067}) then -- Items: Bat Wing x 2, Snake Fang x 2
		e.self:Say("Very good, young acolyte. Maintain your diligence in your duties and you will quickly learn the secrets of the Dark Truth.");
		e.other:Faction(265,1);		-- Faction: Heretics
		e.other:Faction(254,-1);	-- Faction: Gate Callers
		e.other:Faction(242,-1);	-- Faction: Deepwater Knights
		e.other:Faction(231,-1);	-- Faction: Craftkeepers
		e.other:Faction(233,-1);	-- Faction: Crimson Hands
		e.other:SummonItem(15338);	-- Item: Spell: Cavorting Bones
		e.other:QuestReward(e.self,{exp = 100});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
