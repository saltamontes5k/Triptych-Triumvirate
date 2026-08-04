function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only spawn in non-respawning dz
		eq.spawn2(218068, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ() + 10, e.self:GetHeading()) -- A Planar Projection
	end
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local bertox_bucket = tonumber(e.other:GetAccountBucket("pop.flags.bertox")) or 0
		if bertox_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.bertox", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
