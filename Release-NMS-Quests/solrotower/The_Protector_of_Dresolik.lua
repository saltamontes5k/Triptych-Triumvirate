function event_spawn(e)
	eq.set_timer("Depop", 30 * 60 * 1000) -- 30 Minutes
end

function event_combat(e)
	if e.joined then
		eq.set_timer("Out of Bounds", 6 * 1000) -- 6 Seconds
		eq.stop_timer("Depop")
	else
		eq.stop_timer("Out of Bounds")
		eq.set_timer("Depop", 30 * 60 * 1000) -- 30 Minutes
	end
end


function event_timer(e)
	if e.timer == "Out of Bounds" then
		eq.stop_timer("Out of Bounds")
		if e.self:GetX() < 546 or e.self:GetX() > 994 then
			e.self:Say("Dresolik must not be disturbed!")
			e.self:CastSpell(2830, e.self:GetID())
			e.self:SetHP(e.self:GetMaxHP())
			e.self:GotoBind()
			e.self:WipeHateList()
		else
			eq.set_timer("Out of Bounds", 6 * 1000) -- 6 Seconds
		end
	elseif e.timer == "Depop" then
		eq.stop_timer("Depop")
		eq.depop()
	end
end

function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.unique_spawn(202366, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: A_Planar_Projection
	end
	eq.spawn2(212075, 0, 0, 972, 1918, -164, 126) --a_warder_of_Dresolik (212075)
	eq.spawn2(212075, 0, 0, 1043, 1918, -164, 382) --a_warder_of_Dresolik (212075)
	eq.spawn2(212075, 0, 0, 1007, 1980, -164, 0) --a_warder_of_Dresolik (212075)
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local dresolik_bucket = tonumber(e.other:GetAccountBucket("pop.flags.dresolik")) or 0
		if dresolik_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.dresolik", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
