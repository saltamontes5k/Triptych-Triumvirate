function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". You have come to me searching for tasks and tasks I have. Would you judge yourself an [experienced heretic] or one who has [much to learn]?");
	elseif e.message:findi("much to learn") then
		e.self:Say("Very well, " .. e.other:GetName() .. ". I do have a task for you. There is an old and frail Erudite male who now lives in Toxxulia named Aglthin Dasmore. He has left the ways of Cazic-Thule and no longer practices our craft. He has been stripped of his power and wealth, so he spends his time fishing by the river. Our great Lord of Fear has decreed that his life is forfeit. Slay him, and bring me proof of the deed.");
	elseif e.message:findi("experienced heretic") then
		e.self:Say("Ah. Excellent. I have just the task for you, " .. e.other:GetName() .. ". In Kerra Ridge, there is a particular cat named Kirran Mirrah that we have been using to gather information about, well, certain aspects of cat society. He is no longer providing information for us and we have something for him that may encourage him to assist again. Ha! Hand him this sealed bag for us. It may just change his point of view. Hahaha!");
		if not e.other:HasItem(9968) then
			e.other:SummonItem(9968); -- Item: Smelly Sealed Bag
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 9969}) then -- Item: Aglthin's Fishing Pole
		e.self:Say("Yes, this will do.");
		e.other:Faction(265,3);		-- Faction: Heretics
		e.other:Faction(254,-3);	-- Faction: Gate Callers
		e.other:Faction(242,-3);	-- Faction: Deepwater Knights
		e.other:Faction(231,-3);	-- Faction: Craftkeepers
		e.other:Faction(233,-3);	-- Faction: Crimson Hands
		e.other:QuestReward(e.self,{exp = 500, Copper = math.random(4), Silver = math.random(9), Gold = math.random(4)});
		e.other:SummonItem(13697);	-- Item: Staff of the Abattoir Initiate
	elseif item_lib.check_turn_in(e.trade, {item1 = 9967}) then -- Item: Karran's Head
		e.self:Say("I take it he got the message... Excellent work!");
		e.other:Faction(265,3);		-- Faction: Heretics
		e.other:Faction(254,-3);	-- Faction: Gate Callers
		e.other:Faction(242,-3);	-- Faction: Deepwater Knights
		e.other:Faction(231,-3);	-- Faction: Craftkeepers
		e.other:Faction(233,-3);	-- Faction: Crimson Hands
		e.other:QuestReward(e.self,{exp = 1000, Copper = math.random(4), Silver = math.random(9), Gold = math.random(4)});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
