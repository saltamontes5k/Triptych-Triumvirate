function event_say(e)
	local faction = e.other:GetFaction(e.self) <= 4

	if faction and e.other:GetBucket("Skull_Cap") == "7" then
		if e.message:findi("Hail") then
			e.self:Say("I am looking for a [great sorcerer]. Are you such a person?");
		elseif e.message:findi("great sorcerer") and e.other:HasItem(4266) and e.other:GetLevel() > 34 then
			e.self:Say("Are we now? Well then take this. See if you can finish this project that I started so many years ago. It still requires a [whip], a [tassel], and a [lock]. Go and find these items and return to me with what you have already learned and I shall reward you.");
			if not e.other:HasItem(17195) then	-- Don't allow hoarding
				e.other:SummonItem(17195);		-- Item: A Flaxen Hilt
			end
		elseif e.message:findi("whip") then
			e.self:Say("Many years ago in Dreadlans a drovarg came and ravaged my camp and stole a whip that was given to me by my master. With the loss of the whip I became an outcast to the dark arts.");
		elseif e.message:findi("tassel") then
			e.self:Say("You should find a large ghostly tassel, I was on my way to Kaesora to learn about this tassel but my age has hindered this adventure. You should go there and see what you can find.");
		elseif e.message:findi("lock") then
			e.self:Say("Only a goblins hair is strong enough to hold this together. Go and slay them till you find a lock of hair strong enough for this.");
		end
	else
		e.self:Say("You have many more deeds yet to accomplish.");
	end
end

function event_trade(e)
	local item_lib	= require("items");
	local faction	= e.other:GetFaction(e.self) <= 4
	if faction and e.other:GetBucket("Skull_Cap") == "7" and item_lib.check_turn_in(e.trade, {item1 = 12886, item2 = 4266}) then -- Items: Barbed Scaled Whip and Sorcerer Skullcap
		e.self:Emote("takes the flail and vanishes with a brilliant flash!! Within your hands appears a skullcap. You hear a voice echo through the cave. Well done. You are a formidable necromancer. We thank you.");
		e.other:QuestReward(e.self,{exp = 10000, platinum = 2});
		e.other:SummonItem(4267);				-- Item: Necromancer Skullcap
		e.other:Faction(443,10);				-- Faction: Brood of Kotiz
		e.other:Faction(441,2);					-- Faction: Legion of Cabilis
		e.other:SetBucket("Skull_Cap", "8");	-- Skullcap 8 is completed.
		eq.depop_with_timer();
	else
		e.self:Say("All is not complete. A cap and the rest, which was asked for, is required.");
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
