function event_say(e)
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:GetFaction(e.self) <= 4 and Shaman_Cudgel_Progress == "3" and e.message:findi("Rok Nilok") then
		if e.other:GetLevel() >= 18 then
			e.self:Say("Take this chest. Inside you shall combine the skull of their leader and at least five of the caste members. You must then go to the swamp garrison and deliver the full chest along with your Iron Cudgel of the Mystic to Mystic Dovan. Go to him now and inquire of the Crusaders of Rok Nolok.");
			if not e.other:HasItem(17035) then
				e.other:SummonItem(17035); -- Item: Skull Chest
			end
		else
			e.self:Say("Come back when you are more experienced and you can assist us.");
		end
	end
end

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:GetLevel() >= 14 then
		if e.other:GetFaction(e.self) <= 4 and Shaman_Cudgel_Progress == "3.1" and item_lib.check_turn_in(e.trade, {item1 = 18054}) then -- Item: The Bone Garrison
			e.self:Say("Ah, i see you have proven yourself to Zand and he wishes to see more of your prowess.  go to the Tower of Kurn and bring him the Skulls of the Caste of Bone Brethren, a caste of powerful shamans who perished fighting undead in the Field of Bone several decades ago.");
			e.other:SetBucket("Shaman_Cudgel", "3.2");	-- Flag: Completed Cudgel Quest Step 3.2
			e.other:Message(MT.Yellow, "You have received a quest flag.");
			e.other:Faction(445, 10);					-- Faction: Scaled Mystics
			e.other:Faction(441, 10);					-- Faction: Legion of Cabilis
			e.other:SummonItem(17034);					-- Item: Skull Chest
			e.other:QuestReward(e.self,{exp = 10000});
		elseif e.other:GetFaction(e.self) <= 4 and Shaman_Cudgel_Progress == "3.2" and item_lib.check_turn_in(e.trade, {item1 = 12735, item2 = 5142}) then -- Items: Full C.O.B.B. Chest and Iron Cudgel of the Seer
			e.self:Say("The temple shall be pleased. As instructed by the Hierophants, here is your Iron Cudgel of the Mystic. You have done well that I must ask you to [collect the Crusaders of Rok Nilok]. Take this chest. Inside you shall combine the skull of their leader and at least five of the caste members. You then will go to the Swamp Garrison and deliver the full chest and your Iron Cudgel of the Mystic to Mystic Dovan. Go to him now and inquire of the Crusaders of Rok Nolok.");
			e.other:SetBucket("Shaman_Cudgel", "3");	-- Flag: Completed all of Cudgel Quest 3
			e.other:Message(MT.Yellow, "You have received a quest flag.");
			e.other:Faction(445, 10);					-- Faction: Scaled Mystics
			e.other:Faction(441, 10);					-- Faction: Legion of Cabilis
			e.other:SummonItem(5143);					-- Item: Iron Cudgel of the Mystic
			e.other:QuestReward(e.self,{exp = 10000});
		end
	else
		e.self:Say("Come back when you are more experienced and you can assist us.");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
