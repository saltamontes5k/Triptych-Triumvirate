function event_spawn(e)
	eq.set_next_hp_event(98)
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("Reset")
		eq.set_timer("Adds", 120 * 1000)
	else
		eq.set_timer("Reset", 300 * 1000)
		eq.stop_timer("Adds")
	end
end

function event_timer(e)
	if e.timer == "Reset" then
		e.self:SetHP(e.self:GetMaxHP())
		eq.set_next_hp_event(98)
		eq.stop_timer("Reset")
	elseif e.timer == "Help" then
		help_agnarr(e)
		eq.stop_timer("Help")
	elseif e.timer == "Adds" then
		eq.zone_emote(0, "Agnarr strikes his staff to the ground, causing great ripples of energy to rage across the room.")
		eq.signal(209033,1) -- NPC: A_storm_portal
	end
end

function event_hp(e)
	if e.hp_event == 98 then
		eq.unique_spawn(209115, 0, 0, -1082, -1740,  2251,  127) -- NPC: Jolur_Sandstorm
		eq.set_timer("Help", 1 * 1000) -- 1 Second
		eq.set_next_hp_event(75)
	elseif e.hp_event == 75 then
		eq.unique_spawn(209104, 0, 0, -1082, -1740,  2251,  127) -- NPC: Hibdin_Cyclone
		eq.set_timer("Help", 1 * 1000) -- 1 Second
		eq.set_next_hp_event(50)
	elseif e.hp_event == 50 then
		eq.unique_spawn(209105, 0, 0, -1082, -1740,  2251,  127) -- NPC: Ekil_Thundercall
		eq.set_timer("Help", 1 * 1000) -- 1 Second
		eq.set_next_hp_event(25)
	elseif e.hp_event == 25 then
		eq.unique_spawn(209106, 0, 0, -1082, -1740,  2251,  127) -- NPC: Oljin_Stormtide
		eq.set_timer("Help", 1 * 1000) -- 1 Second
	end
end

function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.unique_spawn(209114, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) --planar projection
		eq.unique_spawn(209108, 0, 0, -469, -1754, 2351.2, 395.2) -- Karana upstairs
	end
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local agnarr_bucket = tonumber(e.other:GetAccountBucket("pop.flags.agnarr")) or 0
		if agnarr_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.agnarr", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end

function help_agnarr(e)
	local npc_list =  eq.get_entity_list():GetNPCList()
	for npc in npc_list.entries do
		if (
			npc.valid and
			(
				npc:GetNPCTypeID() == 209104 or
				npc:GetNPCTypeID() == 209105 or
				npc:GetNPCTypeID() == 209106 or
				npc:GetNPCTypeID() == 209107 or
				npc:GetNPCTypeID() == 209115 or
				npc:GetNPCTypeID() == 209124 or
				npc:GetNPCTypeID() == 209125 or
				npc:GetNPCTypeID() == 209126
			)
		) then
		npc:CastToNPC():SetRunning(true)
		npc:CastToNPC():MoveTo(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0, false)
		end
	end
end


function event_signal(e)
	if (e.signal==1) then
		eq.set_timer("Help", 1 * 1000)
	end
end
