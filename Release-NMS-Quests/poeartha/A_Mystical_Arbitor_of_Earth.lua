function event_killed_merit(e)
	local arbitor_bucket = tonumber(e.other:GetAccountBucket("pop.flags.arbitor")) or 0
	if arbitor_bucket == 0 then
		e.other:SetZoneFlag(222)
		e.other:SetAccountBucket("pop.flags.arbitor", "1")
		e.other:Message(MT.LightBlue, "You receive a character flag!")
	end
end