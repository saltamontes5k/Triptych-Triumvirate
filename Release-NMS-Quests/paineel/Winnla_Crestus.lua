function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("By Cazic-Thule. I am going to kill him!  If he keeps up that endless chatter.. Oh. hello there. " .. e.other:GetName() .. ".  Please feel free to peruse my wares.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
