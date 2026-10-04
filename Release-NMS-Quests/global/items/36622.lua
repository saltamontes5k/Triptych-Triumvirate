-- global/items/36622.lua -- Tainted Crystal (Stopping Production, 300032).
-- Click inside the manufacturing room (Steam Factory, ~400, -1800) to
-- sabotage a crate: the crystal is consumed and quality control responds.

function event_item_click(e)
	if e.owner == nil then return end
	local owner = e.owner
	if not owner:IsTaskActive(300032) then
		owner:Message(15, "The crystal itches faintly. Nothing happens.")
		return
	end
	if eq.get_zone_id() ~= 438
		or owner:CalculateDistance(400, -1800, owner:GetZ()) > 100 then
		owner:Message(15, "The crystal pulses, uninterested. It wants the manufacturing room -- central span of the Steam Factory.")
		return
	end
	if owner:CountItem(36622) > 0 then
		owner:DeleteItemInInventory(36622, 1)
		owner:Emote("presses the tainted crystal against a manufacturing crate. It hisses and cracks.")
		eq.zone_emote(15, "A quality control bot drops from the overhead rails!")
		eq.spawn2(436727, 0, 0, owner:GetX() + math.random(-30, 30),
			owner:GetY() + math.random(-30, 30), owner:GetZ(), 0)
	else
		owner:Message(15, "You are out of tainted crystals. Tavik has no more -- finish or fail.")
	end
end
