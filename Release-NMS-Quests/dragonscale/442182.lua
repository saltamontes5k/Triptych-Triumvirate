-- Agilica (442182) -- SoF faction task "The Rescue" (300205).
-- Hand-written: summons two brownie guards when a player on the guard
-- step of the task hails her (live behavior; do not hail while invisible).

local TASK_RESCUE = 300205
local GUARD = 57044

function guards_present()
	local count = 0
	local list = eq.get_entity_list():GetNPCList()
	for npc in list.entries do
		if npc:GetNPCTypeID() == GUARD then
			count = count + 1
		end
	end
	return count
end

function event_say(e)
	if e.other:IsTaskActive(TASK_RESCUE) and e.other:IsTaskActivityActive(TASK_RESCUE, 1) then
		if guards_present() >= 2 then
			e.self:Say("My guards are already dealing with you!")
		else
			e.self:Say("You would harm me? Guards! Guards! To me!")
			for _ = 1, 2 do
				local guard = eq.spawn2(GUARD, 0, 0,
					e.self:GetX() + math.random(-10, 10),
					e.self:GetY() + math.random(-10, 10),
					e.self:GetZ(), e.self:GetHeading())
				if guard.valid then
					guard:Attack(e.other)
				end
			end
		end
	else
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". The encampment presses in around us. Kaerra coordinates our efforts if you come seeking work.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
