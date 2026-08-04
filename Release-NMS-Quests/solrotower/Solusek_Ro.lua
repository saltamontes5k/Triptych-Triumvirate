function event_combat(e)
	if e.joined then
		eq.set_timer("Out of Bounds", 6 * 1000) -- 6 Seconds
	else
		eq.stop_timer("Out of Bounds")
	end
end


function event_timer(e)
	if e.timer == "Out of Bounds" then
		eq.stop_timer("Out of Bounds")
		if e.self:GetZ() < 200 then
			e.self:Say("If you wish to challenge me, you must do it on my terms!")
			e.self:GotoBind()
			e.self:WipeHateList()
		else
			eq.set_timer("Out of Bounds", 6 * 1000) -- 6 Seconds
		end
	end
end

function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.spawn2(218068, 0, 0, 0, -823, 243, 255)	--A_Planar_Projection
	end
	eq.get_entity_list():FindDoor(38):SetLockPick(0) --unlock fire chute
	eq.get_entity_list():FindDoor(39):SetLockPick(0) --unlock fire chute
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local solusek_bucket = tonumber(e.other:GetAccountBucket("pop.flags.solusek")) or 0
		if solusek_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.solusek", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
