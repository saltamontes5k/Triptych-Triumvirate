--Shaman Cudgel Quest 7

function event_say(e)
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.message:findi("Hail") then
		e.self:Say("Leave me in peace " .. e.other:GetCleanName() .. ", I have little desire for company now. The Faceless sends visions to me that may hold the fate of our race in sway.");
	elseif e.other:GetFaction(e.self) <= 4 then
		if e.other:GetLevel() >= 48 then
			if e.message:findi("visions") and Shaman_Cudgel_Progress == "6" then
				e.self:Say("The spirits tell me of strange happenings around the ancient city of Charasis. None of the mystics that have been sent to investigate have returned. Something is surely happening in the ancient tombs of that city. I pray to our lord for some way to calm the tortured spirits of our fallen brothers that haunt the Howling Stones.");
			elseif e.message:findi("dreams") and Shaman_Cudgel_Progress == "7" then
				if e.other:GetLevel() >= 50 then
					e.self:Say("I see much darkness...darkness and death. A void of life...the cold grip of death. An Ancient pact...with forces too terrible to describe...A great Leader...a fall, and a second coming. I see...a symbol of...an ancient city...Kaesora. I would begin there young Mystic. The spirits of that fallen city may hold a key to our future.");
				else
					e.self:Say("Come back when you are more experienced and you can assist us.");
				end
			end
		else
			e.self:Say("Come back when you are more experienced and you can assist us.");
		end
	else
		e.self:Say("Who are you to be talking to me?");
	end
end

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:GetFaction(e.self) <= 4 and e.other:GetLevel() >= 48 then
		if Shaman_Cudgel_Progress == "6" and item_lib.check_turn_in(e.trade, {item1 = 30984}) then -- Item: A Dusty Iksar Skull
			e.self:Emote("peers at the skull intently. 'There is strange magic in this skull Cradossk, whatever necromancer animated this skeleton was a powerful warlock indeed. I sense the power of several ancients in this relic. Take this skull to Oracle Qulin in the field of bone, he may be able to perform the ritual which will free this ancient's spirit from the mortal realm.'");
			e.other:SetBucket("Shaman_Cudgel", "7.1");	-- Flag: Completed Cudgel Quest Step 7.1
			e.other:Message(MT.Yellow, "You have received a quest flag.");
			e.other:SummonItem(30984);					-- Item: Dusty Iksar Skull
			e.other:QuestReward(e.self,{exp = 2000});
		elseif Shaman_Cudgel_Progress == "7.2" and item_lib.check_turn_in(e.trade, {item1 = 30986}) then -- Item: Note to Granix
			e.self:Say("It is as I feared, the mark of the warlock has surely driven these ancient spirits mad. We can not allow these spirits to roam free in our world " .. e.other:GetName() .. ". Take this case and place the glowing skulls of other ancients inside of it. Return it to me with your Cudgel of the Heirophant so that we may remove these cursed spirits from our world forcefully.");
			e.other:SetBucket("Shaman_Cudgel", "7.3");	-- Flag: Completed Cudgel Quest Step 7.3
			e.other:Message(MT.Yellow, "You have received a quest flag.");
			e.other:SummonItem(17134);					-- Item: Ornate Skull Case
			e.other:QuestReward(e.self,{exp = 500});
		elseif Shaman_Cudgel_Progress == "7.3" and item_lib.check_turn_in(e.trade, {item1 = 30988, item2 = 5146}) then -- Items: Filled Ornate Skull Case, Iron Cudgel of the Hierophant
			e.self:Say("You have done well " .. e.other:GetName() .. ". Perhaps you can help clear these troubling dreams from my tired aging mind. Commune with the spirits of our Ancestors and learn from them. Never forget that the ultimate power comes from knowledge. The ancients are privy to much knowledge that mortals will never see. Should you be granted enlightenment from our ancestors, share your knowledge with me so that we may use this knowledge for the benefit of our brethren. I will continue to study the [dreams] that cloud my mind.");
			e.other:SetBucket("Shaman_Cudgel", "7");	-- Flag: SkyIron Cudgel of the Arisen
			e.other:Message(MT.Yellow, "You have received a quest flag.");
			e.other:SummonItem(5148)
			e.other:QuestReward(e.self,{exp = 10000});
		end
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
