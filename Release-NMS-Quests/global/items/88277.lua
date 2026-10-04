-- global/items/88277.lua -- Explosive Device (S.H.I.P Sabotage, 301111).
-- Click beside a boiler in the S.H.I.P. Workshop (zone 439) to plant it:
-- the device is consumed and the boiler fights back. The boiler-room
-- explore steps carry the task credit.

function event_item_click(e)
	if e.owner == nil then return end
	local owner = e.owner
	if not owner:IsTaskActive(301111) then
		owner:Message(15, "The device ticks patiently. Cledmire's job is not yours.")
		return
	end
	if eq.get_zone_id() ~= 439 then
		owner:Message(15, "The device wants boilers -- S.H.I.P. Workshop boilers.")
		return
	end
	if owner:CountItem(88277) == 0 and owner:CountItem(72200) == 0 then
		owner:Message(15, "You carry no devices to plant.")
		return
	end
	owner:Emote("plants an explosive device against a boiler and steps back.")
	if owner:CountItem(88277) > 0 then
		owner:DeleteItemInInventory(88277, 1)
	else
		owner:DeleteItemInInventory(72200, 1)
	end
	eq.zone_emote(15, "The boiler shrieks as its seams split!")
	if math.random(100) <= 35 then
		eq.zone_emote(15, "A Boilermaker erupts from the bilges!")
		eq.spawn2(439705, 0, 0, owner:GetX() + math.random(-25, 25),
			owner:GetY() + math.random(-25, 25), owner:GetZ(), 0)
	end
end
