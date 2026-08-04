function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Oh. hello there. and welcome to my humble store.  We have everything you might need here. for just about anywhere you'd want to go.  Matter of fact. a party supplied themselves for a trip into Old Paineel just moments ago!");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
