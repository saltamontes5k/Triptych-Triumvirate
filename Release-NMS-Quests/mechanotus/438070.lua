-- a deactivated steamwork (438070) -- Spy Reports (300036) hand-in.
-- In the Fortress (mechanotus) it is inert until handed the Miscalibrated
-- Clockwork Driveshaft, then it activates and draws Head Engineer Gearwhir
-- and his crew. In the S.H.I.P. it stays decorative.
local fort = require("sof_fortress")

function event_spawn(e)
	if eq.get_zone_id() == 436 then
		e.self:SetEntityVariable("assembly", "1")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.self:GetEntityVariable("assembly") == "1"
		and e.other:IsTaskActive(fort.TASK_SPY_REPORTS)
		and e.trade and e.trade.click1 == fort.ITEM.mis_driveshaft then
		e.self:Emote("lurches upright, driveshaft screaming to speed!")
		eq.zone_emote(15, "The assembly floor wakes. Head Engineer Gearwhir storms in with his crew!")
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		eq.spawn2(fort.NPC.gearwhir, 0, 0, x + 20, y + 10, z, 0)
		fort.spawn_add(fort.NPC.skitter, x - 25, y, z, e.other)
		fort.spawn_add(fort.NPC.skitter, x, y - 25, z, e.other)
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
