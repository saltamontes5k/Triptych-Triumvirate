function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings. " .. e.other:GetName() .. ".  My wares are few but valuable. including books of research into the less widely known arts of necromancy.  Perhaps you should have a look.");
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
