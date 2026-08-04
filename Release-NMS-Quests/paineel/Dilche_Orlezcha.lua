function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Ah. hello young adventurer!  A mind is a powerful tool indeed but it never hurts to have a strong weapon by your side to cleave through the skulls of your enemies.  Feel free to look at my selection of weapons.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
