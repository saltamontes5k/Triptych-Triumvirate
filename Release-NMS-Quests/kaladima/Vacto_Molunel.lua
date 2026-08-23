function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Well met, " .. e.other:GetName() .. "!  I am Vacto Molunel.  If you are seeking to outfit yourself with the finest weapons in all of Kaladim. I am the one to see.  I also posses a [rare talent] you might find useful.");
	elseif e.other:GetFaction(e.self) < 6 then --requires indifferent faction
		if e.message:findi("rare talent") then
			e.self:Say("Piqued your interest, did I?  Well, you see, I am one of the few dwarves who possess the knowledge and talent to craft a unique type of armor entirely out of scarab carapaces.  While my specialty is making [scarab helms]. I have also been convinced to make [scarab breastplates] from time to time.  All of the pieces I craft are to dwarven proportions, but I have had some gnomish and halfling customers as well.  They come from all over for my armor.");
		elseif e.message:findi("scarab helms") then
			e.self:Say("Interested in a scarab helm, are you?  Well, because my talent is so unique and my time is so valuable, I am afraid I could only make you a helm if you were to provide me with the two scarab carapaces necessary to accommodate a head such as yours.  I will also need a payment of 5 gold pieces.  The Butcherblocks are crawling with worker scarabs that have just the right size carapaces for our needs.");
		elseif e.message:findi("scarab breastplates") then
			e.self:Say("Ah..  A  scarab breastplate.. hmm.  Well, if you want to convince me to go though the trouble of crafting one of those, not only will you have to pay my fee of 23 gold pieces, you must provide me with a pristine giant scarab carapace.  I refuse to make a breastplate with cracked carapaces.");
		elseif e.message:findi("scarab boots") then
			e.self:Say("Ah..  Scarab Boots.. hmm.  Well, if you want to convince me to go though the trouble of crafting a pair of those, not only will you have to pay my fee of 17 gold pieces, you must provide me with a cracked giant scarab shell and 2 scarab legs.");
		end
	elseif e.other:GetFaction(e.self) > 5 then -- less than indifferent faction
		e.self:Say("Sorry, you must not be an ally of the Storm Guard."); --based off player comment, close to correct
	end
end

function event_trade(e)
	local item_lib = require("items");
	if e.other:GetFaction(e.self) < 6 then --requires indifferent faction
		if item_lib.check_turn_in(e.trade, {item1 = 13849, item2 = 13849, gold = 5}) then -- Items and Coin: 2x Scarab Carapace and 5 gold
			e.self:Say("Excellent. Here is your helm. Wear it with pride! And be sure to occasionally wipe out the insulating mucus that tends to build up on its underside. It will make your hair fall out. One more thing, would you be interested in [scarab boots] to match your helm?");
			e.other:QuestReward(e.self,{exp = 100});
			e.other:Faction(312,5);		-- Faction: Storm Guard
			e.other:Faction(274,1);		-- Faction: Kazon Stormhammer
			e.other:Faction(293,1);		-- Faction: Miners Guild 249
			e.other:Faction(290,1);		-- Faction: Merchants of Kaladim
			e.other:Faction(232,-1);	-- Faction: Craknek Warrior
			e.other:SummonItem(2175);	-- Item: Small Scarab Helm
		elseif item_lib.check_turn_in(e.trade, {item1 = 13132, item2 = 13848, item3 = 13848, gold = 17}) then -- Items and Coin: Cracked Giant Scarab Carapace, 2x Scarab Legs and 17 gold
			e.self:Say("Very good! Let me see here. Thread the legs around like this and... There you go. Wear them with pride!");
			e.other:QuestReward(e.self,{exp = 100});
			e.other:Faction(312,5);		-- Faction: Storm Guard
			e.other:Faction(274,1);		-- Faction: Kazon Stormhammer
			e.other:Faction(293,1);		-- Faction: Miners Guild 249
			e.other:Faction(290,1);		-- Faction: Merchants of Kaladim
			e.other:Faction(232,-1);	-- Faction: Craknek Warrior
			e.other:SummonItem(2177);	-- Item: Small Scarab Boots			
		elseif e.other:GetFaction(e.self) < 5 then --requires amiable faction
			if item_lib.check_turn_in(e.trade, {item1 = 13133, gold = 23}) then -- Item and Coin: Pristine Giant Scarab Carapace and 23 gold
				e.self:Say("'If I do say so myself, this is one of the finest breastplates in all of Norrath. I am truly a master at my craft. You might want to wipe out some of the excess scarab goo before wearing it, though.");
				e.other:QuestReward(e.self,{exp = 100});
				e.other:Faction(312,5);		-- Faction: Storm Guard
				e.other:Faction(274,1);		-- Faction: Kazon Stormhammer
				e.other:Faction(293,1);		-- Faction: Miners Guild 249
				e.other:Faction(290,1);		-- Faction: Merchants of Kaladim
				e.other:Faction(232,-1);	-- Faction: Craknek Warrior
				e.other:SummonItem(2176);	-- Item: Small Scarab Breastplate
			end
		end
	else
		e.self:Say("Don't take this personally, but I can't quite trust you with such matters.");
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
