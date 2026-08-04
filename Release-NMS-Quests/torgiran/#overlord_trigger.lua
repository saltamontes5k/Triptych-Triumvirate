-- Taskmaster Luga Event

local wave_counter = 0;

function event_spawn(e)
	eq.set_timer('event', 6 * 1000);
	wave_counter = 0;
end

function event_timer(e)
	eq.stop_timer(e.timer);
	if e.timer == "event" then
		eq.unique_spawn(226072,0,0,-1276,1085,-141.62,0);	-- NPC: #Taskmaster_Luga
		eq.unique_spawn(226071,0,0,-1316,1073,-144.1,0);	-- NPC: #Overlord_Ngrub
	elseif e.timer == "resetcounter" then
		wave_counter = 0;
	end
end

function event_signal(e)
	if e.signal == 1 then
		wave_counter = wave_counter + 1;
		if wave_counter == 21 and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(226207) and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(226206) then
    		eq.unique_spawn(226207,0,0,-1276,1085,-141.62,0);	-- NPC: Taskmaster_Lugald_Brokenskull
      		eq.depop(226072);									-- NPC: #Taskmaster_Luga
			if tostring(eq.get_zone_instance_version()) ~= eq.get_rule("Custom:StaticInstanceVersion") then		-- Check if we're in a non-respawning DZ. If so, disable reset timer otherwise allow it to run.
				eq.set_timer("resetcounter", 3 * 1000);
			end
   		end
	end
end
