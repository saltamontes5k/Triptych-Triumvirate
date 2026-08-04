function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Good day. " .. e.other:GetName() .. ".  Feel free to look through my inventory of spells. but if you touch anything without first buying it I. will have your skin pulled from your flesh. Slowly.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
