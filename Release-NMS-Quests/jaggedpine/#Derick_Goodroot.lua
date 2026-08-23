-- Druid Epic

-- Bucket Name: Epic-Druid-CharacterID

-- Field 1 = Epic 1.5 Prequest Status - Completed = 6
-- Field 2 = Epic 1.5 Status - Completed = 40
-- Field 3 = Epic 2.0 Status - Completed = 
-- Field 4 = Epic 2.5 Status - Completed = 1

-- Epic 1.5 Prequest Details - Subfield 1 (INT)
---- SubField - 1 - Completed Initial Dialog
---- SubField - 2 - Give Redwood Seed to Derick
---- SubField - 3 - Give Unkempt Seed to Derick
---- SubField - 4 - Speak with Bittrik
---- SubField - 5 - Give Storm Giant Head to Derick
---- SubField - 6 - Give Seed of Wrath to Derick

-- Epic 1.5 Details - Subfield 2 (INT)
---- SubField - 1 - Completed Initial Dialog
---- SubField - 2 - Give Sickly Maiden's Hair to Athele
---- SubField - 3 - Give Hair to Niera
---- SubField - 4 - Speak with Finrin
---- SubField - 5 - Start the Goblin Contest
---- SubField - 6 - Loot Diseased Maiden's Hair from Goblin Hider's corpse
---- SubField - 7 - Speak with Blumblumb
---- SubField - 8 - Give Carved Prexus Totem to BlumBlum
---- SubField - 9 - Speak with Bouncer Flerb (Wolf Form to get item and flag)
---- SubField - 10 - Give Scales to Niera
---- SubField - 11 - Loot Digested Maiden's Hair
---- SubField - 12 - Give Seasled Collection Bag to Niera
---- SubField - 13 - Give Wrapped Mangled Head to Niera
---- SubField - 14 - Speak with Gravelady
---- SubField - 15 - Speak with Pathfinder Arelat
---- SubField - 16 - Give books to Gravelady Beddia
---- SubField - 17 - Give Healing Plants to Niera
---- SubField - 18 - Speak with Soulbinder Grunson
---- SubField - 19 - Speak with Caskin Marsheart
---- SubField - 20 - Speak with Madman
---- SubField - 21 - Complete A Skeletons dialog
---- SubField - 22 - Speak to Abandoned heretic Pet
---- SubField - 23 - Combine Mangeled Head in Feerott
---- SubField - 24 - Speak with Compelled Spirit
---- SubField - 25 - Combined Runed Skull
---- SubField - 26 - Speak with Compelled Spirit
---- SubField - 27 - Give Skull and Notes to Niera
---- SubField - 28 - Give Notes to Great Bear
---- SubField - 29 - Give seeds to Niera
---- SubField - 30 - Loot Hasty Notes
---- SubField - 31 - Give crystals to Shana
---- SubField - 32 - Give Full padded bag to Shana
---- SubField - 33 - Speak with Silanda
---- SubField - 34 - Give Silanda Mind Crystal
---- SubField - 35 - Loot Energized Noc Blood (Chest)
---- SubField - 36 - Give Clear Mind Crystal to Silanda
---- SubField - 37 - Loot Chunk of Energized Clay (Chest)
---- SubField - 38 - Tradeskill - Reinforced Aerated Pot
---- SubField - 39 - Loot Blackened Earth (Chest)
---- SubField - 40 - Combine all items in Reinforced Aerated Pot - Staff of Living Brambles - AA - Title - 1.5 Complete

-- Epic 2.0 Details - Subfield 3 (INT)
---- SubField - 1 - Completed Initial Dialog
---- SubField - 2 - Speak with a broken ritesdancer (Subquest if you don't have the faction)
---- SubField - 3 - Speak with Reyfin
---- SubField - 4 - Give Wrapped Cloth Bag to Reyfin
---- SubField - 5 - Give rune to Finrazel
---- SubField - 6 - Speak with Finrazel
---- SubField - 7 - Loot Rain Shard (Chest - Track Sep as can be done out of order)
---- SubField - 8 - Loot Spirit Shard (Chest - Track Sep)
---- SubField - 9 - Combine into Synched Leather Bag
---- SubField - 10 - Give to Finrazel
---- SubField - 11 - Give bag to Reyfin
---- SubField - 12 - Give bag to Silanda
---- SubField - 13 - Combine Stuffs in the Insulated Container in Anguish Only
---- SubField - 14 - Speak to Yuisaha
---- SubField - 15 - Final Combine - Staff of Everliving Brambles - AA - Title - 2.0 Complete

-- Epic 2.5 Details - Subfield 4 (INT)
---- SubField - 1 = Completed Epic 2.5


local epic_disabled = true; -- Disabling for omens (epics) cannot reference perl expansion vars from lua.

function event_say(e)
	if not epic_disabled then
		if e.other:HasClass(Class.DRUID) then

			local data_bucket = ("Epic-Druid-"..e.other:CharacterID());

			local epic_pre_onefive	= nil;	-- Epic 1.5 Pre Quest Status
			local epic_onefive		= nil;	-- Epic 1.5 Status
			local epic_two			= nil;	-- Epic 2.0 Status
			local epic_twofive		= nil;	-- Epic 2.5 Status
			local s					= nil;	-- Status Array

			if eq.get_data(data_bucket) ~= "" then -- Has Started
				local temp = eq.get_data(data_bucket);
				s = eq.split(temp, ',');
		
				epic_pre_onefive	= tonumber(s[1]);
				epic_onefive		= tonumber(s[2]);		
				epic_two			= tonumber(s[3]);
				epic_twofive		= tonumber(s[4]);
			else -- Set variables to 0 and update databuckets
				epic_pre_onefive = 0;
				epic_onefive = 0;
				epic_two = 0;
				epic_twofive = 0;
				update_druid_epic_databucket(e,epic_pre_onefive,epic_onefive,epic_two,epic_twofive);
			end

			if epic_pre_onefive == 0 and not e.other:HasItem(20490) then -- Doesn't have Nature Walkers Scimitar (Epic 1.0)
				if e.message:findi("hail") then
					e.other:Message(MT.NPCQuestSay, "Derick Goodroot says 'No I don't have anything for sale and no I don't want any of your filthy 'money', can't you see I have important [work] to do? Why don't you go talk to that banker and give it to him. There has been nothing but trouble since you all arrived. I'm sick and tired of you people traipsing through here like you own the place. Before you know it, this place will be a smelly den of inequity like Qeynos. I'd like to take that Banker Mardalson and all the rest and feed them to the [river]!'");
				elseif e.message:findi("work") then
					e.other:Message(MT.NPCQuestSay, "Derick Goodroot says 'I prepare seeds for planting to replace the ruin that those accursed Wayfarers have made of the forest. What would you know about it? I don't suppose you have any viable seeds in your pocket? I didn't think so. Just once I'd like to find some new seeds.' Derick looks lost in thought for a moment before barking, 'Go off to your adventures and leave me be. If you have to speak to me again then bring me a good seed or I'll not tolerate you in my home.'");
				elseif e.message:findi("river") then
					e.other:Message(MT.NPCQuestSay, "Derick Goodroot says 'Yeah, go have yourself a nice walk and visit the river. Say hello to the [Potameids] while you're there. They'll be as happy as I am to see you.'");
				elseif e.message:findi("Potameids") then
					e.other:Message(MT.NPCQuestSay, "Derick Goodroot says 'Yes, Potameids. Water Nymphs. They guard the river. Legend has it that long ago the Unkempt asked their queen to prevent intruders from crossing the river and entering the Unkempt Woods. The Queen agreed and now to this day everyone that gets close to the river is seldom heard from again. Why don't you go take a look already and leave me alone!'");
					update_druid_epic_databucket(e,1,epic_onefive,epic_two,epic_twofive);
				end
			elseif epic_pre_onefive == 2 and e.message:findi("seed") then
				e.other:Message(MT.NPCQuestSay, "Derick Goodroot says 'If you can find the text for the ritual, I'll help you with it. Bring it to me and I think we can make it work. It's unlikely that any such text exists, though, so don't get your hopes up.'");
			end
		end
	end
end

function update_druid_epic_databucket(e,pre_one_five,one_five,two,two_five)
	eq.set_data("Epic-Druid-"..e.other:CharacterID(), pre_one_five..","..one_five..","..two..","..two_five);
	e.other:Message(MT.Yellow, "Your quest has been advanced");
end

function event_trade(e)
	local item_lib = require("items");

	if not epic_disabled then
		if e.other:HasClass(Class.DRUID) then
			local data_bucket = ("Epic-Druid-"..e.other:CharacterID());

			if eq.get_data(data_bucket) ~= "" then
				local temp = eq.get_data(data_bucket);
				s = eq.split(temp, ',');

				local epic_pre_onefive	= tonumber(s[1]);
				local epic_onefive		= tonumber(s[2]);		
				local epic_two			= tonumber(s[3]);
				local epic_twofive		= tonumber(s[4]);

				if epic_pre_onefive == 1 and item_lib.check_turn_in(e.trade, {item1 = 62800}) then -- Items: Redwood Seed
					e.other:Message(MT.NPCQuestSay, "Derick Goodroot says 'This is a wonderful specimen, unblemished and healthy. You know, if I had a seed like this I might just try one of those Unkempt [seed rituals], that is if they hadn't been lost along with the Unkempt so many years ago. It's unlikely that any record of them exists these days. Why, there was one ritual that they say could evolve a redwood seed into something new and powerful.'");
					e.other:SummonItem(62800); -- Item: Redwood Seed
					update_druid_epic_databucket(e,2,epic_onefive,epic_two,epic_twofive);
				elseif epic_pre_onefive == 2 and item_lib.check_turn_in(e.trade, {item1 = 62801}) then -- Items: Unkempt Seed Rituals
					e.other:Message(MT.NPCQuestSay, "Derick Goodroot says 'Well you actually found it. It has a new cover, but most of the original pages seem to be here. I can't read all of this very well. Nobody reads this language anymore, but I think I understand the basics. You will need some high quality loam and some magic earth. Marshes are a good place to find loam. Magical soil might be a problem, but certainly you can find some that will work. These two items are used to create the cleansing loam. It's the third item that I don't like. I know the Unkempt were different than we are, but I find this hard to believe. The ritual seems to say that you must take the seed and insert it into the heart of a noble creature to give it strength, then rest that in the loam and earth. I don't like the idea of killing anything noble for such a ritual. I'm not sure what I think of this whole thing now. I'll leave that up to you. Here is a pot that you can use for the ritual. If you still want to do this and you find a heart that might work, bring it to me and I'll see if I can help.'");
					e.other:SummonItem(62802); -- Item: Aerated Pot
					update_druid_epic_databucket(e,3,epic_onefive,epic_two,epic_twofive);
				elseif epic_pre_onefive == 4 and item_lib.check_turn_in(e.trade, {item1 = 62805}) then -- Items: Corrupted Storm Giant Heart
					e.other:Message(MT.NPCQuestSay, "Derick Goodroot sighs. 'I suppose you had no option if he was corrupt. I might even be able to help you purify it for use. I'm not sure how well it will work with the seed ritual. I'm certain that the original intent was to rip the heart from an honorable foe. Here, take this bowl. You'll need to go back to the Plane of Storms and find some pure rain water to cleanse the hart. Pouring the water over the heart while in the bowl, should purify it, though it might also destroy the bowl. Never mind that, though. If it works you should be able to use the heart for the ritual. Please bring me the seed when you are done. I'd like to see it.'");
					e.other:SummonItem(62805); -- Item: Corrupted Storm Giant Heart
					e.other:SummonItem(62807); -- Item: Cleansing Bowl
					update_druid_epic_databucket(e,5,epic_onefive,epic_two,epic_twofive);
				elseif epic_pre_onefive == 5 and item_lib.check_turn_in(e.trade, {item1 = 62809}) then -- Items: Seed of Wrath
					e.other:Message(MT.NPCQuestSay, "Derick Goodroot says, 'Wonderful! This is an amazing seed. It has a resonance of the power of life that seems familiar. It reminds me very much of the feeling I get when one of the Storm Wardens come through here with their Nature Walkers Scimitars. It's a thrill to be able to examine it, thank you.'");
					e.other:SummonItem(62809); -- Items: Seed of Wrath
					update_druid_epic_databucket(e,6,epic_onefive,epic_two,epic_twofive);
				end
			end
		end
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
