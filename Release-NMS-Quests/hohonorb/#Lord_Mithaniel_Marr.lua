function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.spawn2(202368,0,0,2380,-2,444,387); -- NPC: A_Planar_Projection
	end
	eq.depop_with_timer(220016); -- depop the trigger
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local marr_bucket = tonumber(e.other:GetAccountBucket("pop.flags.marr")) or 0
		if marr_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.marr", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
