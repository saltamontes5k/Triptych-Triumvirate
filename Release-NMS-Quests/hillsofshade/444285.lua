-- Quartermaster Laeric (444285) -- Camp Valor, Hills of Shade. Delivery target for task 300513.
-- Tracked source: Release-NMS-Quests/hillsofshade/444285.lua. Copy into the server quests tree.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Valor endures, " .. e.other:GetCleanName() .. ". If you carry stores from Felwithe, hand them over. Otherwise keep your blade ready -- the dead walk these hills.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
