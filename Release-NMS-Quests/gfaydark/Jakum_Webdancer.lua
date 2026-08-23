function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail. " .. e.other:GetName() .. " - If you are interested in helping the League of Antonican Bards by delivering some mail then you should talk to Idia.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 18161}) then -- Item: Bardic Letter (Kelethin)
		e.self:Say("Incoming mail - very good!  Please take this gold for your troubles.");
		e.other:QuestReward(e.self,{exp = 1550, gold = eq.ChooseRandom(3,4,5,6)});
		e.other:Faction(284,5);		-- Faction: league of antonican bards
		e.other:Faction(281,1);		-- Faction: knights of truth
		e.other:Faction(262,1);		-- Faction: guards of qeynos
		e.other:Faction(304,-1);	-- Faction: ring of scale
		e.other:Faction(285,-1);	-- Faction: mayong mistmoore
	elseif item_lib.check_turn_in(e.trade, {item1 = 18160}) or item_lib.check_turn_in(e.trade, {item1 = 18162}) or item_lib.check_turn_in(e.trade, {item1 = 18163}) then -- Item: Bardic Letter (Kelethin) (Various)
		e.self:Say("Incoming mail - very good!  Please take this gold for your troubles.");
		e.other:QuestReward(e.self,{exp = 1550, gold = eq.ChooseRandom(6,7,8,9)});
		e.other:Faction(284,5);		-- Faction: league of antonican bards
		e.other:Faction(281,1);		-- Faction: knights of truth
		e.other:Faction(262,1);		-- Faction: guards of qeynos
		e.other:Faction(304,-1);	-- Faction: ring of scale
		e.other:Faction(285,-1);	-- Faction: mayong mistmoore
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
