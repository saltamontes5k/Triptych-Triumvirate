-- Cledmire Drysproket (439704) -- S.H.I.P Sabotage (301111) quartermaster.
-- Trade the three parts (Power Crystal, 3 Microcogs, Metrognome) for three
-- Explosive Devices. Boilermaker may crash the party on the first bomb.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("*psst* You Gurtrude's runner? Good. The boilers need "
			.. "killing and I need parts. Crystal, cogs, and the "
			.. "metrognome -- you know the list.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local t = e.trade
	if t.click1 == 9920008 and t.click2 == 88274 and t.click3 == 88275 then
		e.other:DeleteItemInInventory(9920008, 1)
		e.other:DeleteItemInInventory(88274, 1)
		e.other:DeleteItemInInventory(88275, 3)
		e.other:SummonItem(88277, 3)
		e.self:Say("Three devices. Click one beside a boiler and step back "
			.. "-- whoever holds the wheel lights the fuse, and the boilers "
			.. "bit back last time.")
		if math.random(100) <= 40 then
			eq.zone_emote(15, "Something huge heaves up from the boiler bilges!")
			eq.spawn2(439705, 0, 0, e.self:GetX() + 25, e.self:GetY(), e.self:GetZ(), 0)
		end
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
