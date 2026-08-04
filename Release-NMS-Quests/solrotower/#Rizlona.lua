function event_combat(e)
	if e.joined then
		eq.set_timer("Out of Bounds", 6 * 1000) -- 6 Seconds
		eq.stop_timer("Depop")
	else
		eq.set_timer("Depop", 30 * 60 * 1000) -- 30 Minutes
		eq.stop_timer("Out of Bounds")
	end
end


function event_timer(e)
	if e.timer == "Out of Bounds" then
		eq.stop_timer("Out of Bounds")
		if e.self:GetY() < 2076 then
			e.self:Say("If you wish to challenge me, you must do it on my terms!")
			e.self:CastSpell(2830, e.self:GetID())
			e.self:SetHP(e.self:GetMaxHP())
			e.self:GMMove(-1104, 2384, -905, 256)
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
		eq.unique_spawn(202368, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: A_Planar_Projection
	end
	eq.spawn2(212076, 0, 0, -1118, 2024, -908, 258) --a_warder_of_Rizlona (212076)
	eq.spawn2(212076, 0, 0, -1101, 1978, -920, 258) --a_warder_of_Rizlona (212076)
	eq.spawn2(212076, 0, 0, -1086, 2024, -908, 258) --a_warder_of_Rizlona (212076)
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local rizlona_bucket = tonumber(e.other:GetAccountBucket("pop.flags.rizlona")) or 0
		if rizlona_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.rizlona", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
