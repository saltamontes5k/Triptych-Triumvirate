function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail to yourself fool. Leave me be. I have [matters of importance] to ponder.");
	elseif e.message:findi("matters of importance") then
		e.self:Say("If you are so greatly interested in my affairs then so be it. I have lost my skeleten servant. He now wanders the yard, taking his pain out on the new apprentices of our guild. I cannot return to my guild without ridding the yard of that menace for my mistake will cost me dearly if it is brought to the attention of my masters. Hrm. Perhaps you could destroy my pet for me and bring me proof of his removal. If you do I may even grace you with a [reward].");
	elseif e.message:findi("reward") then
		e.self:Say("Speak not of reward when you have not even finished this simple task! Now leave me be.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if e.other:GetLevel() >= 15 and item_lib.check_turn_in(e.trade, {item1 = 7107}) then -- Item: Rotting Femur
		e.self:Say("Ah! You found him and obviously removed his presence from the yard. You have my thanks, small as it is for such a menial task. Here. Keep this worthless bit of bone for your labors.");
		e.other:Faction(265,1);		-- Faction: Heretics
		e.other:Faction(242,-1);	-- Faction: Deepwater Knights
		e.other:Faction(254,-1);	-- Faction: Gate Callers
		e.other:Faction(231,-1);	-- Faction: Craftkeepers
		e.other:Faction(233,-1);	-- Faction: Crimson Hands
		e.other:SummonItem(7106);	-- Item: Noclin's Femur
        e.other:QuestReward(e.self,{exp = 250});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
