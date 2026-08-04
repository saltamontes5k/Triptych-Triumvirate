function event_zone(e)
	if e.zone_id == Zone.codecay then
		local adler_bucket = tonumber(e.self:GetAccountBucket("pop.flags.adler")) or 0
		local grummus_bucket = tonumber(e.self:GetAccountBucket("pop.flags.grummus")) or 0
		if (
			not e.self:HasZoneFlag(Zone.codecay) and
			(
				(
					adler_bucket == 1 and
					grummus_bucket == 1
				)
			)
		) then
			e.self:SetZoneFlag(Zone.codecay)
			e.self:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end