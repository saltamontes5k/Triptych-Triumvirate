function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hello there. " .. e.other:GetName() .. ".  Fear not for your valuables.  I have known Marsa for many years and she has not once taken anyone's property.  She is. perhaps. the last honest person in this city.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
