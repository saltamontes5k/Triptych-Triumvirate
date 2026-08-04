function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail and well met. " .. e.other:GetName() .. ".  I am Keeshla Levlora. a resident necromancer of this beautiful city.  If you are a practitioner of the dark arts under our lord Cazic-Thule. know that you are welcome here.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
