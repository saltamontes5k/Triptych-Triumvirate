function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- only pop for non-respawning
		eq.spawn2(222015, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()); -- #Essence_of_Earth
	end
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- only give flag in non-respawning
		local rathe_bucket = tonumber(e.other:GetAccountBucket("pop.flags.rathe")) or 0
		if rathe_bucket == 0 then
			e.other:SummonItem(29146) -- Item: Mound of Living Stone
			e.other:SetAccountBucket("pop.flags.rathe", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
