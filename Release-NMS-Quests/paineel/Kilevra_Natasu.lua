function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Have you spoken with Danus?  If not. I suggest you do. so that I will not waste my breath further.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
