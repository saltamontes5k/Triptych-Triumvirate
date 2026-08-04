local seedling
local councilDead = 0

function event_spawn(e)
	seedling=e.self

	-- Check to see if any of the councilmen are up
	councilmanMob1 = eq.get_entity_list():GetMobByNpcTypeID(222008);
	councilmanMob2 = eq.get_entity_list():GetMobByNpcTypeID(222013);
	if ((councilmanMob1 ~= nil and councilmanMob1.valid) or (councilmanMob2 ~= nil and councilmanMob2.valid)) then
		seedling:SetTargetable(false) -- at least 1 councilman was found
	else
		wakeSeed(); -- No councilmen were found so this must be a repop on zone state load
	end
end

function event_death_complete(e) 
	eq.spawn2(222014,0,0,2051.1,407.7,-219.2,0) --Avatar of Earth pop
end

function event_signal(e)
	if (e.signal == 1) then -- rathe councilman slain
		councilDead = councilDead+1
		if (councilDead == 12) then
			controllerMob = eq.get_entity_list():GetMobByNpcTypeID(222012); -- rathe controller mob
			if (controllerMob ~= nil and controllerMob.valid) then
				controllerMob:Depop(true); -- Depop the controller mob so the councilmen don't respawn again.
			end
			wakeSeed()
		end
	end
end

function wakeSeed()
	eq.zone_emote(MT.Yellow,"The massive branches crack and stretch toward the sky as the Rathe Seedling awakens...")
	seedling:SetTargetable(true)
end
