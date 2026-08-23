function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I'm not in any mood for conversation. My favorite hat was torn right from my head by a gigantic bat the other night and I am quite upset.");
	elseif e.message:findi("other tasks?") then
		e.self:Say("I will sew you your own personal dreadful cap if you bring me the necessary components. I will need the pelt of a feared beast, some gold thread, and an imbued amber.");
	elseif e.message:findi("hat") then
		e.self:Say("It is a marvelous cap sewn from the finest textiles and imbued with the divine power of our lord of fear. Cazic Thule!");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 1528}) then -- Item: Azzar's Dreadful Hat
		e.self:Emote("gasps in astonishment 'You...you..found my [hat]!! This is the most I can repay you but perhaps I can reward you further for some [other tasks]?'");
		e.other:Faction(265,1);		-- Faction: Heretics
		e.other:Faction(254,-1);	-- Faction: Gate Callers
		e.other:Faction(242,-1);	-- Faction: Deepwater Knights
		e.other:Faction(231,-1);	-- Faction: Craftkeepers
		e.other:Faction(233,-1);	-- Faction: Crimson Hands
		e.other:SummonItem(1530);	-- Item: Black Lace Sash
		e.other:QuestReward(e.self,{exp = 500});
	elseif item_lib.check_turn_in(e.trade, {item1 = 19076, item2 = 12096, item3 = 22502}) then -- Items: Mighty Bear Paw's Belt Gold Thread and Imbued Amber
		e.self:Say("Well done " .. e.other:GetName() .. ", here is your new hat wear it with pride"); --couldnt find the text
		e.other:Faction(265,3);		-- Faction: Heretics
		e.other:Faction(254,-3);	-- Faction: Gate Callers
		e.other:Faction(242,-3);	-- Faction: Deepwater Knights
		e.other:Faction(231,-3);	-- Faction: Craftkeepers
		e.other:Faction(233,-3);	-- Faction: Crimson Hands
		e.other:SummonItem(1529);	-- Item: Dreadful Cap
		e.other:QuestReward(e.self,{exp = 500});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
