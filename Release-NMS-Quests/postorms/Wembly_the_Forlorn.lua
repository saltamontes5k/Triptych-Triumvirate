function event_say(e)
	if e.message:findi("Hail") then
		e.self:Emote("grumbles under his breath, 'Yes, yes, I see you there. No need for you to shout I can see you just fine! Now get lost!'")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end