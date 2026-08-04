function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Welcome to the Fortune's Fancy. " .. e.other:GetName() .. "!  I carry only the finest jewels and jewelry in all the land.  All of the [charges and accusations] made against me are obviously false. as you can see by my beautiful wares.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
