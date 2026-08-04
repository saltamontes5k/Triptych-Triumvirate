local timedMode = false; -- Whether or not there is a time during which the first and last councilman must be killed
local timedModeDurationSeconds = 600; -- number of seconds between first and last Councilman killed
local timedModeFailureDelayMinutes = 5; -- How long the player has to wait to retry the event

function event_spawn(e)
      	eq.spawn_condition("poearthb",eq.get_zone_instance_id(),1,1); --Rathe Council pop
	-- Adding the ability to toggle timed rathe encounter via a bucket for test purposes, default behavior will be the non-timed encounter
	if (eq.get_data("timedrathe") == "1") then
		--Enabling timed mode because timedrathe bucket was set to 1.
		--Run the '#databuckets view timedrathe' GM command to view the key and delete the key if you want to run non timed rathe
		timedMode = true;
		
	else
		--Timed mode is disabled for this encounter.
		--Run 'i#databuckets edit timedrathe 0 0 0 1' to enable timed mode
		timedMode = false;
	end
end

function event_signal(e)
	if (e.signal == 1) then -- Rathe councilman died
		local anyCouncilUp = eq.is_npc_spawned({ 222013,222008 });
		if not anyCouncilUp and timedMode == true then
			eq.set_timer("timedKills",timedModeDurationSeconds*1000);
		elseif not anyCouncilUp then
			eq.spawn_condition("poearthb",eq.get_zone_instance_id(),1,0); -- Disable councilman pops
			eq.stop_timer("timedKills");
			eq.zone_emote(15,"The ground shakes as the last councilman falls.  The Avatar has awaken...");
			eq.spawn2(222014,0,0,2051.1,407.7,-219.2,0);
			e.self:Depop(true);
		end
	end
end

function event_timer(e)
	if (e.timer == "timedKills") then
		-- The player did not kill the mobs within the amount of time, despawn the councilman and emote the failure
		eq.stop_timer("timedKills");
		eq.zone_emote(15,"The challengers have failed to extinguish the Council in the time alotted.  The council will reconvene in "..timedModeFailureDelayMinutes.." minutes");
		eq.spawn_condition("poearthb",eq.get_zone_instance_id(),1,0);
		eq.set_timer("repop",timedModeFailureDelayMinutes*60*1000);
	elseif (e.timer == "repop") then
		eq.stop_timer("repop");
		eq.spawn_condition("poearthb",eq.get_zone_instance_id(),1,1);
	end
end
