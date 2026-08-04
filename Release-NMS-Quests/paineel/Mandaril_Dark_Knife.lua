function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18017) then -- Item: Fell Blade Guild Note
		e.other:Message(MT.Yellow,"Mandaril Dark Knife glances at you with obvious scorn. 'Are you here to seek the ways of the Dark Truth? If that is the case, then read the note in your inventory and then hand it to me. If you are not here for such a purpose, I suggest you leave at once lest you anger me further.'");
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Desist in your prattle.  If you want idle chitchat. talk to someone else.");
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

	if item_lib.check_turn_in(e.trade, {item1 = 18017}) then -- Item: Fell Blade Guild Note
		e.self:Say("You are welcomed into the fold.  Now go out, and prove yourself, young one.  You have much to learn about the Dark Truth. Once you are ready to begin your training please make sure that you see Faratain, he can assist you in developing your hunting and gathering skills. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		e.other:Faction(265,100);	-- Faction: Heretics
		e.other:Faction(254,-100);	-- Faction: Gate Callers
		e.other:Faction(242,-100);	-- Faction: Deepwater Knights
		e.other:Faction(231,-100);	-- Faction: Craftkeepers
		e.other:Faction(233,-100);	-- Faction: Crimson Hands
		e.other:SummonItem(13573);	-- Item: Blood Splattered Tunic
		e.other:QuestReward(e.self,{exp = 100});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
