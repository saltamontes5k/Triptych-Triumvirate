function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to Kelethin, " .. e.other:GetName() .. "! I am Maesyn Trueshot, commander of Faydark's Champions. We are the finest marksmen in all of Norrath. With our trusty [Trueshot longbows] we can miss no target regardless of the distance or the conditions.");
	elseif e.message:findi("trueshot longbows") then
		e.self:Say("The Trueshot Longbow was created by my famed father. Eldin Trueshot. It is quite accurate and takes a ranger's skill to wield. We use our new recruits to [gather materials] needed by my father.  We shall soon begin to release the formula to good elves so all may fletch such a bow.");
	elseif e.message:findi("correct component") then
		e.self:Say("Now that I have crafted the Treant Bow Staff, you shall need one Planing Tool, one Treant Bow Staff, one Micro Servo and one spool of Dwarven Wire. These items will be used with your Fletching Kit as all other bows. Be forewarned, only a Master Fletcher can create such a bow and even a master fails from time to time. Good Luck.");
	elseif e.message:findi("next incarnation") then
		e.self:Say("The Trueshot Longbow was once enchanted by the Koada'Dal enchanters.  Once it was enchanted now it is no more.  I am sure if you were ask the Koada'Dal [where the enchanted bows] are you will get an answer.");
	elseif e.message:findi("gather material") and e.other:HasClass(Class.RANGER) then
		if e.other:GetFaction(e.self) < 5 then -- Needs better than indifferent
			e.self:Say("Take this pack. Go to Kaladim, find Trantor Everhot and ask for dwarven wire. Then go to Freeport to meet Jyle Windshot. Search the inns for him and ask him for treant wood. Then, collect some spiderling silk from spiderlings and finally, in Steamfont, we have the permission of the gnomes to use any micro servos we find while destroying rogue spiders. Combine them all and return the pack to me.");
			e.other:SummonItem(17951); -- Item: Material Pack
		else
			e.self:Say("Faydark's Champions cannot call you foe, but you have yet to earn our trust.");
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
	if item_lib.check_turn_in(e.trade, {item1 = 12112}) then -- Item: Pack of Materials
		e.self:Say("I shall see that my father gets the materials. I hope this can be of use to you. It will serve as your starting point toward fletching a Trueshot longbow. It is unfortunate that we are unable to enchant the bow to its [next incarnation], but it is still a fine weapon. You do know the [correct components] needed for fletching such a bow, do you not?");
		e.other:QuestReward(e.self,{exp = 500});
		e.other:Faction(246,5);		-- Faction: Faydark's Champions
		e.other:Faction(279,1);		-- Faction: King Tearis Thex
		e.other:Faction(226,1);		-- Faction: Clerics of Tunare
		e.other:Faction(310,1);		-- Faction: Soldiers of Tunare
		e.other:Faction(234,-1);	-- Faction: Crushbone Orcs
		e.other:SummonItem(8091);	-- Item: Treant Bow Staff
	elseif item_lib.check_turn_in(e.trade, {item1 = 18785}) then -- Item: A tattered note
		e.self:Say("Hail, " .. e.other:GetName() .. ", and welcome.. I am Maesyn Trueshot, leader of Faydark's Champions. I will teach and train you, as I have done for many others. Let's get started.. Here, put this on.. it'll help protect you from the elements. Once you are ready to begin your training please make sure that you see Samatansyn Flamecaller, he can assist you in developing your hunting and gathering skills. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		e.other:QuestReward(e.self,{exp = 100});
		e.other:Faction(246,100);	-- Faction: Faydark's Champions
		e.other:Faction(279,25);	-- Faction: King Tearis Thex
		e.other:Faction(226,25);	-- Faction: Clerics of Tunare
		e.other:Faction(310,25);	-- Faction: Soldiers of Tunare
		e.other:Faction(234,-25);	-- Faction: Crushbone Orcs
		e.other:SummonItem(13536);	-- Item: Dirty Green Tunic*
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
