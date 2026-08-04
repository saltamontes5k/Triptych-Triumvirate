function event_click_door(e)
	local door_id = e.door:GetDoorID()
	if door_id == 59 then
		local construct_bucket = tonumber(e.self:GetAccountBucket("pop.flags.construct")) or 0
		local hedge_bucket = tonumber(e.self:GetAccountBucket("pop.flags.hedge")) or 0
		if construct_bucket == 1 and hedge_bucket == 1 then
			if not e.self:HasZoneFlag(Zone.nightmareb) then
				e.self:SetZoneFlag(Zone.nightmareb)
				e.self:Message(MT.LightBlue, "You receive a character flag!")
			end
		end
	end
end

function event_loot(e)
	local item_id = e.item:GetID()
	if e.self:HasClassID(Class.PALADIN) and item_id == 69951 then
		local qglobals = eq.get_qglobals(e.self)
		local paladin_epic_qglobal = tonumber(qglobals["paladin_epic"]) or 0
		if paladin_epic >= 5 then
			local paladin_epic_pon_qglobal = tonumber(qglobals["paladin_epic_pon"]) or 0
			if paladen_epic_pon_qglobal == 0 then
				eq.set_global("paladin_epic_pon", "1", 5, "F")
				eq.spawn2(283157, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0) -- NPC: a_chest
			end
			return 0
		else
			return 1
		end
	elseif e.self:HasClassID(Class.WIZARD) and item_id == 11474 then
		local qglobals = eq.get_qglobals(e.self)
		local wizard_epic_qglobal = tonumber(qglobals["wiz_epic"]) or 0
		if wizard_epic_qglobal == 1 then
			local wizard_pon_chest_qglobal = tonumber(qglobals["wizard_pon_chest"]) or 0
			if wizard_pon_chest_qglobal == 0 then
				eq.set_global("wizard_pon_chest", "1", 5, "F")
				eq.spawn2(283157, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0) -- NPC: a_chest
			end
			return 0
		else
			return 1
		end
	end
end