function event_combat(e)
	if e.joined then
		eq.set_timer("Out of Bounds", 60 * 1000) -- 60 Seconds
		eq.set_timer("Heal", 125 * 60 * 1000) -- 2 Hours and 5 Minutes
	else
		eq.stop_timer("Out of Bounds")
		eq.stop_timer("Heal")
	end
end

function event_timer(e)
	if e.timer == "Out of Bounds" then
		eq.stop_timer("Out of Bounds")
		if e.self:GetY() < 1240 then
			e.self:CastSpell(2830, e.self:GetID())
			e.self:SetHP(e.self:GetMaxHP())
			e.self:GotoBind()
			e.self:WipeHateList()
		else
			eq.set_timer("Out of Bounds", 6 * 10000)
		end
	elseif e.timer == "Heal" then
		e.self:Emote("is immolated in flames, and is reborn!")
		e.self:Heal()
		e.self:CastSpell(1281, e.self:GetTarget():GetID()) -- Searing Flames
	end
end

function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.unique_spawn(202367, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: A_Planar_Projection
	end
	eq.spawn2(212074, 0, 0, 1713, 1206, 627, 264) -- a_warder_of_Arlyxir (212074)
	eq.spawn2(212074, 0, 0, 1738, 1206, 627, 264) -- a_warder_of_Arlyxir (212074)
	eq.spawn2(212074, 0, 0, 1726, 1146, 612, 264) -- a_warder_of_Arlyxir (212074)
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local arlyxir_bucket = tonumber(e.other:GetAccountBucket("pop.flags.arlyxir")) or 0
		if arlyxir_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.arlyxir", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
