function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hail. " .. e.other:GetName() .. "!  I thought I heard the clink of coins and now. here you stand!  Please feel free to browse through my stock.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
