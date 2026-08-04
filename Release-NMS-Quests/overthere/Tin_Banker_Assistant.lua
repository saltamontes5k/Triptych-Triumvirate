-- Necromancer 5th Rank - Skullcap

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Insert Metal Key *whirrrr*.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if e.other:GetBucket("Skull_Cap") == "4" and item_lib.check_turn_in(e.trade, {item1 = 12849}) then -- Item: A Metal Key
		e.self:Emote(" shudders and begins to clang. You hear the sound of an ocean of coins. A small door pops open and a book pops out. A few coins also manage to escape.");
		e.other:QuestReward(e.self,0,0,0,0,18065); -- Item: Journal
	end
end
