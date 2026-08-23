function event_enter_zone(e)
	if e.self:HasClassID(Class.CLERIC) and e.self:CountItem(52963) > 0 then -- Item: Sullied Gold Filigree
		local anthone_bucket = tonumber(e.self:GetBucket("anthone")) or 0
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(211047) and anthone_bucket == 1 then
			eq.spawn2(211047, 0, 0, -1853, 2479, -110, 40) -- NPC: ##Anthone_Chapin
		end
	end

	if e.self:HasClassID(Class.MAGICIAN) then
		local qglobals = eq.get_qglobals(e.self)
		if qglobals["mage_epic_hoh"] == nil and tonumber(qglobals["mage_epic"]) == 10 then
			e.self:Message(MT.Yellow, "You staff begins to glow.")
		end
	end
end

function event_click_door(e)
	local door_id = e.door:GetDoorID()
	if door_id == 19 or door_id == 20 then
		local flags = {
			"pop.flags.aerin",
			"pop.flags.faye",
			"pop.flags.garn",
			"pop.flags.mavuin",
			"pop.flags.trell",
			"pop.flags.tribunal",
			"pop.flags.valor"
		}

		local all_requirements_met = true
		for i, flag in ipairs(flags) do
			local current_bucket = tonumber(e.self:GetAccountBucket(flag)) or 0
			if current_bucket ~= 1 then
				all_requirements_met = false
			end
		end

		if all_requirements_met and not e.self:HasZoneFlag(Zone.hohonorb) then
			e.self:SetZoneFlag(Zone.hohonorb)
			e.self:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end

function event_loot(e)
	if e.self:HasClass(Class.MAGICIAN) and e.item:GetID() == 19547 then -- Item: Element of Order
		local qglobals = eq.get_qglobals(e.self)
		if tonumber(qglobals["mage_epic"]) == 10 and qglobals["mage_chest_hoh"] == nil then
			eq.set_global("mage_chest_hoh", "1", 5, "F")
			eq.spawn2(893, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0) -- NPC: a_chest
			return 0
		else
			return 1
		end
	end
end
