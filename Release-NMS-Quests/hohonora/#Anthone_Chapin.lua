function event_say(e)
	if e.message:findi("Hail") and e.other:CountItem(54286) > 0 then -- Item: Assembling the Staff
		e.self:Say("Mithaniel Marr himself has entrusted me with the power to purge taint from the most desecrated of objects.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	-- Items: Assembling the Staff, Sullied Gold Filigree
	if item_lib.check_turn_in(e.trade, {item1 = 54286, item2 = 52963}) then
		e.self:Say("This filigree now shines from within with the holy light of Marr.")
		e.other:SummonItem(52953) -- Item: Purified Gold Filigree
		e.other:SetBucket("anthone", "1")
		eq.depop()
	end

	item_lib.return_items(e.self, e.other, e.trade)
end