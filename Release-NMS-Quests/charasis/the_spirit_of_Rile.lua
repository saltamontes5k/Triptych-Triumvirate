--Shaman Cudgel Quest 8

function event_trade(e)
	local item_lib					= require("items");
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:GetLevel() >= 50 and Shaman_Cudgel_Progress == "8.2" and item_lib.check_turn_in(e.trade, {item1 = 30995, item2 = 5148}) then	-- Item: The Skull of Rile, SkyIron Cudgel of the Arisen
		e.self:Say("Use your cudgel to unite my soul with my body " .. e.other:GetName() .. "");
		e.self:Emote("begins to shudder and shake, the bones fly from your hands to meet their rightful soul. The spirit and bones being to glow and meld into one another, forming a swirling mass of ethereal energy. Abani begins to mouth incantations in an unfamiliar tongue. Their voice rises ever higher as mystic energy surges through the room. Then, in a suddenly flash, the spirit and corpse disappear without a trace, leaving only " .. e.other:GetName() .. " holding a Faintly glowing Cudgel in his hand.");
		e.other:DeleteBucket("Shaman_Cudgel");	-- Flag: Can start quest over from 1st step
		e.other:Message(MT.Yellow, "You have completed this quest chain and it has been reset.");
		e.other:SummonItem(5149);				-- Item: Skyiron Cudgel of the Ancients
		e.other:QuestReward(e.self,{exp = 10000});
		eq.depop();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
