function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello. " .. e.other:GetName() .. ".  I have some of the finest baked goods in Paineel.  It's the best home cooking you have had. ever.  That be my word.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
