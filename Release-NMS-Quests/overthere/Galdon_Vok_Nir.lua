function event_say(e)
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.message:findi("Hail") then
		e.self:Say("Please do not harm me.  I am not the one who brought the outsiders to our land.  I am innocent and deserve to return to my people.");
	elseif e.other:GetLevel() >= 30 and Shaman_Cudgel_Progress == "4" then
		if e.message:findi("di nozok") then
			e.self:Emote("opens his eyes wide. 'Oh! You found one of my family's fine canopics. That particular one was made for the legendary mystic, Di Nozok. If you think you're going to open it, think again. I know how, and will gladly [open the Nozok canopic], for a price. I heard the second was stolen by a sarnak shaman.");
		elseif e.message:findi("open.* canopic") then
			e.self:Say("Want it opened? I will need the two [keys of Dai], the Dai skull canopic, and my fee, 400 gold coins.");
		elseif e.message:findi("sealed") then
			e.self:Say("I have heard of such things. You must have stumbled upon an ancient jar devised by one of my long-dead ancestors. They were fine craftsmen. I do not share their gift, but I do know the secret of the locks. If you have one of the ancient Vok Nir canopics, allow me to open it for you.");
		elseif e.message:findi("key") then
			e.self:Say("There are two keys of Dai. They were made of ceramic and were also crafted to look like warrior totems. I once broke one as a child and my grandfather got very angry. He lashed me good! I do not know what the big fuss was about; he easily put them back together using some sort of clay.");
		end
	end
end

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if Shaman_Cudgel_Progress == "4" and e.other:GetLevel() >= 30 and item_lib.check_turn_in(e.trade, {item1 = 12743, item2 = 12744, item3 = 12742, gold = 400}) then -- Items: Ton Warrior Totem, Ton Warrior Totem, Dai Nozok skull canopic and 400 Gold
		e.self:Say("A deal is a deal I suppose, many have attempt to do what I have asked, but fallen to the Overseer.");
		e.other:SummonItem(12740); -- Item: Iksar Skull
		e.other:QuestReward(e.self,{exp = 50});
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
