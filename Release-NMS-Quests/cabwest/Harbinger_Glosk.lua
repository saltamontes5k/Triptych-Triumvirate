function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18207) then -- Guild Summons
		e.other:Message(MT.Yellow,"As your reptilian eyes adjust to the darkness of the room, an imposing Iksar turns towards you, addressing you with a sharp hiss. 'I am Harbinger Glosk. The time has come young one. You have chosen the path of the Necromancer. Open your inventory and read the note within. Once you are ready to begin your training, hand the note to me and we will continue.'");
	end
end

function event_say(e)
	local faction = e.other:GetFaction(e.self) <= 4

	if e.message:findi("hail") then
		e.self:Emote("halts his chanting. 'You dare to interrupt me? You had best have a good reason. I care not for small talk.'");
	elseif e.message:findi("keepers grotto") then
		e.self:Say("Keepers Grotto is where you shall find the Keepers. They study and scribe the spells of our dark circle. The grotto is not far from here, near the arena called the Gauntlet.");
	end
	if faction then
		if e.other:GetBucket("Skull_Cap") == "6" then
			if e.message:findi("new revenant") then
				e.self:Emote("Harbinger Glosk ceases his chanting and gazes into your mind. 'Yes. You are. You shall do as I command. Take this. It is incomplete and must be ready for the emperor within the half season. You must find the [four missing gems]. When you have them, you will have to quest for the [" .. eq.say_link("forge of dalnir",false,"Grand Forge of Dalnir") .. "]. Within its fire, all shall combine. Return the sceptre to me with your revenant skullcap. Go.'")
				if not e.other:HasItem(12873) then	-- Don't allow hoarding
					e.other:SummonItem(12873);		-- Item: Unfinished Sceptre
				end
			elseif e.message:findi("four missing gems") then
				e.self:Say("The missing sceptre gems are: an Eye of Rokgus, a Gem of Yet to Come, a Heart of Torsis and the Crown Jewel of Ganak.");
			elseif e.message:findi("forge of dalnir") then
				e.self:Emote("scratches his chin. 'I know little of it other than that it once belonged to the ancient Haggle Baron, Dalnir. From what I have read, its fires require no skill, but will melt any common forge hammer used. Dalnir was said to have called upon the ancients for a hammer which could tolerate the magical flames.'");
			end
		elseif e.other:GetBucket("Skull_Cap") == "7" then
			if e.message:findi("hail") then
				e.self:Say("Welcome Sorcerer. There is nothing more we can do for you here. Perhaps you should seek an outcast who hides as a hermit.")
			end
		elseif e.other:GetBucket("Skull_Cap") == "8" then
			if e.message:findi("hail") then
				e.self:Say("Welcome Necromancer. I can do nothing more to advance your training in our order... Not since Ixpacan took our volumes from Charasis.");
			end
		elseif e.other:GetBucket("Skull_Cap") == "9" then
			if e.message:findi("gem of reflection") then
				e.self:Say("I have not been asked that in ages but I can recall the last person that asked me. If you are in league with that scoundrel Ixpacan, I will slay you where you stand! But if you are not, you will not mind ridding your kin of a [menace] as of late.");
			elseif e.message:findi("menace") then
				e.self:Say("It seems as though a rogue marauder in a jungle near here has attacked several of our trade suppliers. If you can bring me back his head I will gladly share the information you have asked for.");
			end
		end
	else
		e.self:Say("When you have shown more devotion to the Brood of Kotiz, we can discuss such things.");
	end
end

function event_trade(e)
	local item_lib	= require("items");
	local faction	= e.other:GetFaction(e.self) <= 4

	if item_lib.check_turn_in(e.trade, {item1 = 18207}) then -- Item: Guild Summons
		e.self:Say("Another apprentice has reached rebirth. You now have become one with the Brood of Kotiz. We study the ancient writing of Kotiz. Through his writing we have found the power of the dark circles. Listen well to the scholars within this tower and seek the [" .. eq.say_link("Keepers Grotto") .. "] for knowledge of our spells. This drape shall be the sign to all Iksar that you walk with the Brood. Now go speak with Xydoz.");
		e.other:QuestReward(e.self,{exp = 100});
		e.other:SummonItem(12407);	-- Item: Drape of the Brood
		e.other:Faction(443,100);	-- Faction: Brood of Kotiz
		e.other:Faction(441,25);	-- Faction: Legion of Cabilis
	elseif faction and e.other:GetBucket("Skull_Cap") == "6" and item_lib.check_turn_in(e.trade, {item1 = 12874, item2 = 4265}) then -- Items: Sceptre of Emperor Vekin and Revenant Skullcap
		e.self:Emote("presents to you a glowing skullcap. 'This is the treasured cap of the sorcerers of this tower. Let all gaze upon you in awe. You are what others aspire to be. I look forward to reading of your adventures, Sorceror " .. e.other:GetName() .. ".'");
		e.other:QuestReward(e.self,{exp = 10000, platinum = 2});
		e.other:SummonItem(4266);				-- Item: Sorcerer Skullcap
		e.other:Faction(443,10);				-- Faction: Brood of Kotiz
		e.other:Faction(441,2);					-- Faction: Legion of Cabilis
		e.other:SetBucket("Skull_Cap", "7");	-- Skullcap 7 is completed.
	elseif faction and e.other:GetBucket("Skull_Cap") == "9" and item_lib.check_turn_in(e.trade, {item1 = 48037}) then -- Item: Rogue Marauder's Head
		e.self:Say("You have done well in doing what I have asked. To make a gem of reflection you will need some Mt Death mineral salts, a green goblin skin, spiroc bone dust, essence of rathe, blue slumber fungus, and a vial of pure essence. Combine all of these in this container and you will have what it is you seek.");
		e.other:SummonItem(48039);	-- Item: Glosk's Sack
	elseif item_lib.check_turn_in(e.trade, {item1 = 14794}) then -- Item: Illegible Note: Boots
		e.self:Emote("hisses and says venomously, 'And I am disturbed yet again. I hope for your sake it is important.'");
		e.self:Emote("The gaunt necromancer looks down at the paper in his hands and after reading a few lines gasps, then falls into a violent coughing fit. After recovering he takes a deep breath, puffs his chest out and hands the paper back to you. With his head held high, he says in a raspy voice, 'Show this to Rixiz. He will test you.'");
		e.other:SummonItem(14794);	-- Item: Illegible Note: Boots
	elseif item_lib.check_turn_in(e.trade, {item1 = 14793}) then -- Item: Illegible Note: Greaves
		e.self:Emote("snatches the note out of your hands, obviously irritated. After reading a few lines, he glances up at you, his brow furrowed, then looks down again to continue reading. When he's finished, he hands the note back to you and takes a deep breath, shuddering slightly. He then says, 'Xydoz. Take this to Xydoz. He will test you.'");
		e.self:Emote("watches you carefully as you leave.");
		e.other:SummonItem(14793);	-- Item: Illegible Note: Greaves
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
