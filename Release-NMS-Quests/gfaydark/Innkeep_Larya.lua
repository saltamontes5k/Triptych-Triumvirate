function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome! Why don't you browse through my selection of fine goods and pick out some things you like " .. e.other:GetName() .. "?");
	end
end

function event_trade(e)
	local item_lib = require("items");
	item_lib.return_items(e.self, e.other, e.trade)
end
