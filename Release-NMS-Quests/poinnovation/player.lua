function event_click_door(e)
	local door_id = e.door:GetDoorID()
	if door_id == 7 then
		local xanamech_bucket = tonumber(e.self:GetAccountBucket("pop.flags.xanamech")) or 0
		if xanamech_bucket == 1 then
			e.self:Message(MT.Yellow, "You remember Nitram's words - 'three small turns to the right on the bottommost rivet should open the door'.")
			e.door:ForceOpen(e.self)
		end
	elseif door_id == 145 then
		local maelin_bucket = tonumber(e.self:GetAccountBucket("pop.flags.maelin")) or 0
		if maelin_bucket == 1 then
			e.self:SetZoneFlag(Zone.potimea)
			e.self:SetZoneFlag(Zone.potimeb)
			e.self:Message(MT.LightBlue, "You receive a character flag!")
			e.self:Message(MT.Yellow, "The ages begin to tear through your body. You wake to find yourself in another time.")
			e.self:MovePC(Zone.potimea, 130, 0, 182, 383)
		end
	end
end
