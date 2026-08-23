function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ahhhahahaha! The terror that lays over this city like a blanket tingles my bones with vigor. I seek a fellow apostle of Cazic-Thule to assist me in the [summoning of Terror].");
	elseif e.message:findi("summoning of terror") then
		e.self:Say("It will be a frightfully fulfilling summons. To do this, I need an eye of urd, some basalt drake scales, the lens of Lord Soptyvr, and a lock of widowmistress hair.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if e.other:GetFaction(e.self) < 5 and item_lib.check_turn_in(e.trade, {item1 = 10523, item2 = 19032, item3 = 14110, item4 = 14109}) then -- Items: Eye of Urd, Basalt Drake Scales, Lens of Lord Soptyvr, Widowmistress Hair
		e.self:Emote("begins speaking an incantation. 'Take this mask as your reward for helping me.'");

		e.other:Faction(265,400);	-- Faction: Heretics
		e.other:Faction(254,-400);	-- Faction: Gate Callers
		e.other:Faction(242,-400);	-- Faction: Deepwater Knights
		e.other:Faction(231,-400);	-- Faction: Craftkeepers
		e.other:Faction(233,-400);	-- Faction: Crimson Hands
		e.other:QuestReward(e.self,{exp = 5000, Copper = math.random(9), Silver = math.random(9), Gold = math.random(9), Platinum = math.random(2)});
		e.other:SummonItem(14106);	-- Item: Mundane Mask
		eq.unique_spawn(75195,0,0,421,1182,-37,256); -- NPC: avatar_of_terror
	else
		e.self:Say("I require all four reagents, anything less is useless. Incompetence will get you nowhere amongst the faithful of Cazic-Thule!");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
