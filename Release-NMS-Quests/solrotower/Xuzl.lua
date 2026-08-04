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
		if e.self:GetY() < -918 then
			e.self:Emote("bellows in a deep voice, 'You shall not distract me from my conjurings!")
			e.self:GotoBind()
			e.self:WipeHateList()
		else
			eq.set_timer("Out of Bounds", 6 * 1000)
		end
	end
end

function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.unique_spawn(214105, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) --NPC: A_Planar_Projection
	end
	eq.spawn2(212078, 0, 0, 1836, -1040, 291, 256) --a_warder_of_Xuzl (212078)
	eq.spawn2(212078, 0, 0, 1800, -1090, 291, 125) --a_warder_of_Xuzl (212078)
	eq.spawn2(212078, 0, 0, 1879, -1090, 291, 385) --a_warder_of_Xuzl (212078)
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local xuzl_bucket = tonumber(e.other:GetAccountBucket("pop.flags.xuzl")) or 0
		if xuzl_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.xuzl", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
