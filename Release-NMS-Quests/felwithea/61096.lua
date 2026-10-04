-- Quartermaster Entag (61096) -- Camp Valor Quick Errand supplies (task 300513).
-- Tracked source: Release-NMS-Quests/felwithea/61096.lua. Copy into the server quests tree.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". Camp Valor holds the pass into the Hills of Shade, and our stores run thin. Are you here about the [supplies]?")
	elseif e.message:findi("supplies") then
		if e.other:CountItem(79841) == 0 then
			e.self:Say("Take these stores to Quartermaster Laeric at Camp Valor before the rot takes them. And tell Fenden Helter his errand is remembered.")
			e.other:SummonItem(79841, 1)
			e.other:Message(15, "Quartermaster Entag gives you the Camp Valor Supplies.")
		else
			e.self:Say("You already carry the supplies. See them safely to Laeric.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
