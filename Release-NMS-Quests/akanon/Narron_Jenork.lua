-- Quest edited by mrsmystic
-- Quest further edited by Qadar for compatibility with Watchman Boots quest (Watchman_Dexlin in northkarana)
-- Converted to .lua by Speedz
-- items: 17255, 22610, 22611, 22613, 22612, 22614, 22615, 22616, 9111, 9112, 9113, 9114, 9115, 12378, 12379

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Pleased to meet you, " .. e.other:GetName() .. "! I am Narron Jenork, High Watchman of Ak'anon. I am one of the most skilled Watchmans in all of Ak'anon.");
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 12378})) then -- Box of Undead Brownies
		e.self:Say("Wonderful!! Watchman Dexlin sent word that you would be returning these specimens. I shall see that the Eldritch Collective gets them.  For you there is a reward. Manik has donated a pair of Watchman Boots!!");
		e.other:Faction(255,15,0); 	-- Gem Choppers better
		e.other:Faction(288,15,0); 	-- Merchants of Ak'Anon better
		e.other:Faction(333,15,0); 	-- King Ak'Anon better
		e.other:Faction(238,-15,0); 	-- Dark Reflection worse
		e.other:AddEXP(10000);
		e.other:Ding();
		e.other:SummonItem(12379);	-- Watchman Boots
		e.other:GiveCash(0,0,0,4);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
end