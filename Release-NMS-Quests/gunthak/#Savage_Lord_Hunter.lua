-- Beastlord 1.5
-- No Pre-Req

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 22503, item2 = 22503, item3 = 22503}) then -- Items: 3x Blue Diamonds
		e.other:SummonItem(57004); -- Item: Taut Leather Swatch
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
