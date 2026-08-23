function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18783) then -- Item: Tattered Note
		e.other:Message(MT.Yellow,"As you orient yourself amongst the peacefulness of the treetop city of Kelethin, a melodic, peaceful voice breaks the silence. 'I am the Heartwood Master. Read the note in your inventory and when you wish to begin your training, hand it to me. We must pledge our lives to protect the great forest, Faydark against all those who would wish it harm!'");
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Salutations! The Song Weavers are always glad to add a new voice to the choir.  In addition to your voice. will you also [fetch spiderling silk]?  We need some to replace our worn lute strings.  Carry out this task in high tempo and we will show our gratitude.");
	elseif e.message:findi("spiderling silk") then
		e.self:Say("Very spirited of you!!  Gather four spiderling silk and return them to me.  Good hunting. my friend!!");
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

	if item_lib.check_turn_in(e.trade, {item1 = 18783}) then -- Item: Tattered Note
		e.self:Say("Greetings. friend. I am Sylia.  I see that you wish to join our humble guild.  Good.  Here is a gift for you - your guild tunic.  Let's get started with your training, shall we?");
		e.other:QuestReward(e.self,{exp = 100});
		e.other:SummonItem(13534);	-- Item: Faded Brown Tunic*
		e.other:Faction(401,100);	-- Faction: Song Weavers
	elseif item_lib.check_turn_in(e.trade, {item1 = 13099,item2 = 13099,item3 = 13099,item4 = 13099}) then -- Items: 4x Spiderling Silk
		e.self:Say("Splendid job! Now if you can just keep a tune, you'll be a fine bard.");
		e.other:QuestReward(e.self,{exp = 100, gold = 1});
		e.other:SummonItem(13000);	-- Item: Hand Drum
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
