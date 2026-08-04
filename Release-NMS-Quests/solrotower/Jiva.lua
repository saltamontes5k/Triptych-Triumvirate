function event_combat(e)
	if e.joined then
		eq.set_timer("Adds", 30 * 1000) -- 30 Seconds
	else
		eq.stop_timer("Adds")
	end
end

function event_timer(e)
	if timer == "Adds" then
		local random = math.random(1, 10)
		if random == 0 then
			eq.spawn2(212067, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: an_efreeti_makin
		elseif random == 1 then
			eq.spawn2(212068, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: an_efreeti_adeel
		elseif random == 2 then
			eq.spawn2(212069, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: an_efreeti_jiri
		elseif random == 3 then
			eq.spawn2(212070, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: an_efreeti_seif
		elseif random == 4 then
			eq.spawn2(212071, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: an_efreeti_nabil
		end
	end
end

function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.spawn2(202365, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: A_Planar_Projection
	end
	eq.spawn2(212077, 0, 0, -2301, -787, -1100, 257) -- a warder of jiva
	eq.spawn2(212077, 0, 0, -2255, -787, -1100, 257) -- a warder of jiva
	eq.spawn2(212077, 0, 0, -2210, -787, -1100, 257) -- a warder of jiva
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local jiva_bucket = tonumber(e.other:GetAccountBucket("pop.flags.jiva")) or 0
		if jiva_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.jiva", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
