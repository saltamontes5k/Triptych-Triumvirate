function event_signal(e)
	if e.signal == 7 then
		e.self:Shout("Violaters of this plane be banished from this domain!")
	end
end

function event_death_complete(e)
	eq.signal(216107, 5) -- #coirnav_controller
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only spawn in non-respawning dz
		local coirnav_bucket = tonumber(e.other:GetAccountBucket("pop.flags.coirnav")) or 0
		if coirnav_bucket == 0 then
			e.other:SummonItem(29163) -- Item: Sphere of Coalesced Water
			e.other:SetAccountBucket("pop.flags.coirnav", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
