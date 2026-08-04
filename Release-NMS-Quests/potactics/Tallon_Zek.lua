local x_max = -445
local x_min = -770
local y_max = -1761
local y_min = -2158
local z_const = 207.7

function event_combat(e)
	if e.joined then
		eq.set_timer("shadowstep", 20000)
		eq.stop_timer("reset")
		eq.set_timer("barb", math.random(1, 4) * 1000)
	else
		eq.stop_timer("shadowstep")
		eq.stop_timer("barb")
		eq.set_timer("reset", 30000)
	end
end

function event_timer(e)
	if e.timer == "shadowstep" then
		local new_x = math.floor(math.random() * (x_max - x_min + 1)) + x_min
		local new_y = math.floor(math.random() * (y_max - y_min + 1)) + y_min
		local new_z = z_const
		e.self:Emote("steps into the shadows.")
		e.self:GMMove(new_x, new_y, new_z)
	elseif e.timer == "barb" then
		e.self:CastSpell(eq.ChooseRandom(2449, 2450, 2451, 2452), e.self:GetTarget():GetID())
		eq.set_timer("barb", math.random(2, 6) * 1000)
	elseif e.timer == "reset" then
		e.self:GMMove(-620, -1959, 207.7)
		eq.stop_timer(e.timer)
	end
end

function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.spawn2(218068, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- NPC: A_Planar_Projection
	end
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local tallon_bucket = tonumber(e.other:GetAccountBucket("pop.flags.tallon")) or 0
		if tallon_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.tallon", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
