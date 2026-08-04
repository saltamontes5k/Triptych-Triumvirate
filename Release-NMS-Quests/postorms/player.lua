function event_click_door(e)
	local door_id = e.door:GetDoorID()
	if door_id == 4 then
		local askr_bucket = tonumber(e.self:GetAccountBucket("pop.flags.askr")) or 0
		local mavuin_bucket = tonumber(e.self:GetAccountBucket("pop.flags.mavuin")) or 0
		local tribunal_bucket = tonumber(e.self:GetAccountBucket("pop.flags.tribunal")) or 0
		local valor_bucket = tonumber(e.self:GetAccountBucket("pop.flags.valor")) or 0
		if (
			(
				askr_bucket == 4 and
				mavuin_bucket == 1 and
				tribunal_bucket == 1 and
				valor_bucket == 1
			)
		) then
			if not e.self:HasZoneFlag(Zone.bothunder) then
				e.self:SetZoneFlag(Zone.bothunder)
				e.self:Message(MT.LightBlue, "You receive a character flag!")
			end
		end
	end
end