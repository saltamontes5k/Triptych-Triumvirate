function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Lots to do! Many books to place and scrolls to file! Feel free to browse but. please. don't make a mess!");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
