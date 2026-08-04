function event_say(e)
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:HasClass(Class.SHAMAN) then
		if e.message:findi("hail") then
			e.self:Say("Welcome to the Temple of Terror, young one. May the pain of the ancients guide you. Have you lost your Iron Cudgel of the Petitioner?");
		elseif e.message:findi("Lost") then
			e.self:Emote("shakes his head and growls. 'That is not good, broodling... Not good at all. You will need to take this note and seek out the Toilmaster immediately. Read it on the way and hope that your incompetence can be overcome. The Crusaders of Greenmist have a pit meant for you, should this prove to be impossible.");
			if not e.other:HasItem(18271) then
				e.other:SummonItem(18271); -- Item: Ragged Book
			end
		elseif e.other:GetFaction(e.self) <= 4 then
			if Shaman_Cudgel_Progress == "2" and e.message:findi("chosen savior") then
				if e.other:GetLevel() >= 14 then
					e.self:Emote("closes his eyes and bows before you. 'I am honored to meet the one who shall pledge his life to the return of the Skulls of the Ancients. However, I must see proof of our prowess as of yet. Go to the outlands and retrieve one Froglok Hexdoll, and no, they are not found on Frogloks. They are shaman dolls made by the goblin tribe.");
				else
					e.self:Say("Come back when you are more experienced and you can assist us.");
				end
			elseif Shaman_Cudgel_Progress == "4" and e.message:findi("Di Nozok") then
				if e.other:GetLevel() >= 30 then
					e.self:Say("What?!! I have read of them, but that is all I know of the legendary mystic, err, mystics... whatever!! Where their remains rest is a mystery but those filthy goblins always seem to get ahold of things that are lost, all that infernal digging you see.");
				else
					e.self:Say("Come back when you are more experienced and you can assist us.");
				end
			end
		end
	end
end

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if item_lib.check_turn_in(e.trade, {item1 = 18272, item2 = 24770}) then -- Items: Rites of Exoneration and Filled Penance Bag
		e.self:Emote("takes the bag and tome from you and in return gives you the item that you have been thinking of all of this time. 'Lucky you. You have earned a second chance. Praise Cazic-Thule!'");
		e.other:Faction(445, 100);	-- Faction: Scaled Mystics
		e.other:Faction(441, 25);	-- Faction: Legion of Cabilis
		e.other:SummonItem(5140);	-- Item: Iron Cudgel of the Petitioner
		e.other:QuestReward(e.self,{exp = 50});
	end

	if e.other:GetFaction(e.self) <= 4 and e.other:HasClass(Class.SHAMAN) then
		if Shaman_Cudgel_Progress == "2" and e.other:GetLevel() >= 14 and item_lib.check_turn_in(e.trade, {item1 = 12734}) then -- Item: A Froglok Hex Doll
			e.self:Say("Fine work! I hope for your sake, you did not purchase it from a brave adventurer. Take this note to the one for whom it is written. This lizard has knowledge of a large number of skulls.");
			e.other:SetBucket("Shaman_Cudgel", "3.1");	-- Flag: Completed Cudgel Quest Step 3.1
			e.other:Message(MT.Yellow, "You have received a quest flag.");
			e.other:Faction(445, 10);					-- Faction: Scaled Mystics
			e.other:Faction(441, 10);					-- Faction: Legion of Cabilis
			e.other:SummonItem(18054);					-- Item: The Bone Garrison
			e.other:QuestReward(e.self,{exp = 80000, copper = math.random(9), silver = math.random(9), gold = math.random(9), platinum = math.random(5)});
		elseif Shaman_Cudgel_Progress == "4" and e.other:GetLevel() >= 30 and item_lib.check_turn_in(e.trade, {item1 = 12741, item2 = 5144, item3 = 12740}) then -- Items: Iksar Skull Helm, Iron Cudgel of the Prophet and Iksar Skull
			e.self:Emote("seems to black out, and then recover. He speaks with the voice of an ancient. 'We are Dai and Die and we await our skulls and your iron cudgel of the prophet. Become a channeler.'Hierophand Zand closes his eyes and reopens them. They have no pupils. He speaks and you hear his voice echo. 'We are Di Nozok. You have earned the weapon of a channeler. We hope to fill your thoughts with ours some day. Go and seek out Dexl. We send you to him. Farewell , Channeler of Cabilis.'");
			e.other:SetBucket("Shaman_Cudgel", "5");	-- Flag: Completed all of Cudgel Quest 5
			e.other:Message(MT.Yellow, "You have received a quest flag.");
			e.other:Faction(445, 20);					-- Faction: Scaled Mystics
			e.other:Faction(441, 5);					-- Faction: Legion of Cabilis
			e.other:SummonItem(5145);					-- Item: Iron Cudgel of the Channeler
			e.other:QuestReward(e.self,{exp = 120000, copper = math.random(9), silver = math.random(9), gold = math.random(9), platinum = math.random(5)});
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
