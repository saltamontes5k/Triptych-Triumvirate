-- arcstone/369004.lua - Scribe Luritem
-- Prophecy of Ro: minor faction quest; unlocks his port-spell merchant stock.
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Go away. I am busy. Unless you want to [help] me, leave me alone.");
	elseif t:find("help") then
		e.self:Say("I am always short of paper. Bring me three pieces of parchment and a quill for my work, and I will sell you some books that I have copied.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	if item_lib.check_turn_in(e.trade, { item1 = 13063, item2 = 13063, item3 = 13063, item4 = 13051 }) then
		c:SetBucket("por.luritem", "1");
		e.self:Say("Ok, thanks. I guess I have to sell to you now. Go ahead and look at my inventory.");
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
