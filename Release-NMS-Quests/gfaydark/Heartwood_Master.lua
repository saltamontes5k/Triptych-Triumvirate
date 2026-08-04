function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18786) then -- Tattered Note
		e.other:Message(MT.Yellow,"As you orient yourself amongst the peacefulness of the treetop city of Kelethin, a melodic, peaceful voice breaks the silence. 'I am the Heartwood Master. Read the note in your inventory and when you wish to begin your training, hand it to me. We must pledge our lives to protect the great forest, Faydark against all those who would wish it harm!'");
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, child of Tunare. As druids of the Mother of all, we may only use blunt weapons and the scimitar, all other blades are forbidden. Prove your devotion by bringing me a rusty short sword, a rusty long sword, a rusty broad sword, and a rusty bastard sword. I will destroy them and reward your faith.");
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
	if item_lib.check_turn_in(e.trade, {item1 = 18786}) then -- Item: Tattered Note
		e.self:Say("Welcome! We are the Soldiers of Tunare, the sworn protectors of Faydark. I thank you for joining our cause, we can always use the help. Once you are ready to begin your training please make sure that you see Aliafya Mistrunner, she can assist you in developing your hunting and gathering skills. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		e.other:QuestReward(e.self,{exp = 200});
		e.other:SummonItem(13537);	-- Item: Green and Tan Tunic*
		e.other:Faction(310,100);	-- Faction: Soldier of Tunare
		e.other:Faction(279,15);	-- Faction: King Tearis Thex
		e.other:Faction(246,15); 	-- Faction: Faydark's Champions
	elseif item_lib.check_turn_in(e.trade, {item1 = 5013,item2 = 5016,item3 = 5019,item4 = 5022}) then
		e.self:Say("You have done well, child! Take this as a blessing from Tunare for doing her will.");
		e.other:QuestReward(e.self,{exp = 250, copper = math.random(9), silver = math.random(9)});
		e.other:SummonItem(eq.ChooseRandom(5047,6012));	-- Item(s): Tarnished Scimitar, Worn Great Staff
		e.other:Faction(310,1);	-- Faction: Soldier of Tunare
		e.other:Faction(279,1);	-- Faction: King Tearis Thex
		e.other:Faction(246,1); -- Faction: Faydark's Champions
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
