-- Emissary Korshan (114492) -- Crusaders of Veeshan, Skyshrine. Delivery target for task 300514.
-- Tracked source: Release-NMS-Quests/skyshrine/114492.lua. Copy into the server quests tree.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("The Circle speaks through me, softfoot. If you carry the Crusaders' word from the Dragonscale hills, deliver it.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
