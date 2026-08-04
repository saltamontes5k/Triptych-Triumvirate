function event_say(e)
	local faction = e.other:GetFaction(e.self) <= 4
	local bucket = tonumber(e.other:GetBucket("Skull_Cap")) or 0

	if faction and bucket == 2 then
		if e.message:findi("hail") then
			e.self:Say("You are on the grounds of the Brood of Kotiz. If you do not belong, you must leave at once. There shall be no [third rank skullcap] for you.");
		elseif e.message:findi("third rank skullcap") then
			e.self:Say("I offer the third rank apprentice skullcap to those who wear the second. If that is you, then you will do the [bidding of the tower].");
		elseif e.message:findi("bidding of the tower") then
			e.self:Say("Take this glass canopic. Within it you shall place a brain for me. The brain I seek is that of a sarnak crypt raider. Any shall do. The ones we seek should be near the Lake of Ill Omen. When you obtain the brain, you must quickly put it into the glass canopic with [embalming fluid]. When these are combined, the canopic shall seal and if you return it to me with your second rank skullcap, I shall hand you the next and final skullcap.");
			if not e.other:HasItem(17023) then	-- Don't allow hoarding
				e.other:SummonItem(17023);		-- Item: Brood Canopic
			end
			e.self:Say("You shall get no skullcap until I have the preserved raider brain and your second circle apprentice skullcap.");
		elseif e.message:findi("embalming fluid") then
			e.self:Say("Embalming fluid is created through brewing, but do not drink it!! You can learn about the process of brewing on our grounds.");
		elseif e.message:findi("speak to the dead") then
			e.self:Say("How dare you ask of such a thing! I am a Master of the Necromantic Arts. If you wish to have me conjure this spirit you must first seek out a traitor to our cause. His name is Ixzec. He can be found roaming with a group of renegades in a jungle not far from here. Return with his head and some items from the soul you want summoned and I will aid you in your request.");
		end
	elseif faction then
		if bucket == 1 or bucket == 0 then
			if e.message:findi("hail") then
				e.self:Say("Quite busy!! Quite busy!! Things must be done. See Master Xydox if you wish to help!!")
			end
		elseif bucket >= 3 then
			if e.message:findi("hail") then
				e.self:Say("I did not expect you to return. You have made me lose a bet with one of the other apprentices. Seeing as you have completed my tasks, I direct you to Master Kyvix.")
			end
		else
			if e.message:findi("hail") then
				e.self:Say("You are on the grounds of the Brood of Kotiz. You do not belong. Leave while you can.");
			end
		end
	end
end

function event_trade(e)
	local item_lib	= require("items");
	local faction	= e.other:GetFaction(e.self) <= 4

	if faction and e.other:GetBucket("Skull_Cap") == "2" and item_lib.check_turn_in(e.trade, {item1 = 12411, item2 = 4261}) then -- Items: Preserved Sarnak Brain and Apprentice Skullcap - 2nd Rank
		e.self:Say("You have done well. Here is your final apprentice skullcap.");
		e.other:QuestReward(e.self,{exp = 150, gold = 10});
		e.other:SummonItem(4262);				-- Item: Apprentice Skullcap - 3rd Rank
		e.other:Faction(441,2);					-- Faction: Legion of Cabilis
		e.other:Faction(443,10);				-- Faction: Brood of Kotiz
		e.other:SetBucket("Skull_Cap", "3");	-- Skullcap 3 is completed.
	elseif item_lib.check_turn_in(e.trade, {item1 = 14794}) then -- Item: Illegible Note: Boots
		e.self:Emote("takes the note and after reading a few lines opens his eyes wide in astonishment. He looks up at you and stares at you a while before he says,");
		e.self:Say("You spoke to the Brothers? A common soldier such as yourself interested in silly stories to frighten broodlings? Fine, then. You shall know confidence, if you live. If you have the strength to stride into a lair, go before the owner, and kill that thing in its own home, you will acquire a small part of the virtue we as necromancers must master to ply our art. In the Frontier Mountains lives a unit of the troublesome burynai. Invade their home and destroy their leader. Bring me proof and two fire emeralds.");
	elseif item_lib.check_turn_in(e.trade, {item1 = 14810, item2 = 10033, item3 = 10033}) then -- Items: Snaorfs Medallion, 2x Fire Emerald
		e.self:Say("Well done, here is your reference.");
		e.other:QuestReward(e.self,{exp = 10000});
		e.other:SummonItem(14813);	-- Item: Glosk's Reference: Boots
	elseif item_lib.check_turn_in(e.trade, {item1 = 48021, item2 = 48015}) then -- Items: Head of a Traitor, Xyzith's Belongings
		e.other:QuestReward(e.self,0,0,0,0,0,eq.ExpHelper(45)); -- 2-4% of lvl 45 exp
		e.self:Say("Ah, this brings me great joy. Now I shall have full control over this fool in his death. As for your request, here is what you asked for. . .");
		eq.zone_emote(MT.NPCQuestSay,"As you hand Master Rixiz Xyzith's belongings, you can see black smoke begin to arise from the cracks in the floor. In a bright flash of light, the spirit of Xyzith appears in front of you and attacks! ");
		eq.spawn2(82049,0,0,791.93,308.59,45,287);  -- NPC: #Warlord Xyzith -- TODO QUEST BROKEN
	elseif item_lib.check_turn_in(e.trade, {item1 = 5136}) then -- Item: Xyzith's Destroyed Belongings
		e.self:Say("You should return back to your brethren and give them the news of what has happened here young one. To make sure War Baron Eator recognizes the truth I shall give you my seal.");
		e.other:SummonItem(48020); -- Items: Seal of Rixiz
		e.other:Ding();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
