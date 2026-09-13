-- items: 52525
-- Demi-Plane of Blood curse blocker: Sister's Handkerchief (25% of Aura of Crimson Mists).
local dodh = require("dodh_helper");

function event_say(e)
	if(e.message:findi("hail") and e.other:HasItem(52525)) then
		e.self:Emote("her eyes flick to the handkerchief and then away. 'So the Sisters are finally at rest. Give it here, quietly, and I will see that their grief does not linger in your blood.'");
	elseif(e.message:findi("hail")) then
		e.self:Emote("holds an index finger to her pursed lips. 'Shhh... Silence is golden, " .. e.other:GetName() .. ".  You are welcome to look around and peruse our selection so long as you remain quiet and do not bother the other guests.  I would also advise against speaking to the Quartet, for your sake and not theirs.  They will bore you to tears.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if (item_lib.check_turn_in(e.trade, {item1 = 52525})) then	-- Sister's Handkerchief
		e.self:Emote("folds the handkerchief without looking at it and tucks it away. 'Their sorrow, then. Not yours. The mists will find less of you to hold onto.'");
		dodh.grant_blocker(e.other, 52525, "The Sister's Handkerchief");
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
