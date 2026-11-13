local timedMode = false; -- Whether or not there is a time during which the first and last councilman must be killed
local timedModeDurationSeconds = 600; -- number of seconds between first and last Councilman killed
local timedModeFailureDelayMinutes = 5; -- How long the player has to wait to retry the event

-- every A Rathe Councilman variant the pop condition can spawn; each one reports its own death
local councilIds = { 222008, 222013, 222025 };
local timedClockRunning = false;
local eventOver = false;

local function council_standing()
	return eq.is_npc_spawned(councilIds);
end

-- Wakes the Avatar once the last councilman is down. Returns true when the event is finished.
local function complete_if_council_fell(e)
	if eventOver or council_standing() then
		return false;
	end

	eventOver = true;
	eq.spawn_condition("poearthb",eq.get_zone_instance_id(),1,0); -- Disable councilman pops
	eq.stop_timer("timedKills");
	eq.stop_timer("council_check");
	timedClockRunning = false;
	eq.zone_emote(15,"The ground shakes as the last councilman falls.  The Avatar has awaken...");
	eq.spawn2(222014,0,0,2051.1,407.7,-219.2,0);
	e.self:Depop(true);
	return true;
end

function event_spawn(e)
	-- A spawn point only (re)pops when condition 1 *changes* (on_change = DoRepop), and a dead
	-- councilman keeps an instance-long respawn timer under Custom:StaticInstanceVersion, so a
	-- restart can otherwise leave the council dead and the event unplayable. Force a clean pop on
	-- a fresh boot; a resumed (suspended) zone keeps whatever was already standing.
	if not e.self:IsResumedFromZoneSuspend() then
		eq.spawn_condition("poearthb",eq.get_zone_instance_id(),1,0);
	end
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
	timedClockRunning = false;
	eventOver = false;
end

function event_signal(e)
	if (e.signal == 1) then -- Rathe councilman died
		if (timedMode and not timedClockRunning) then
			-- the clock runs from the first councilman to fall, not from the last
			timedClockRunning = true;
			eq.set_timer("timedKills",timedModeDurationSeconds*1000);
		end

		if (complete_if_council_fell(e)) then
			return;
		end

		-- a councilman killed by something other than a client is still in the entity list
		-- while its death event runs; look again once it has left
		eq.set_timer("council_check", 2000);
	end
end

function event_timer(e)
	if (e.timer == "council_check") then
		eq.stop_timer("council_check");
		complete_if_council_fell(e);
	elseif (e.timer == "timedKills") then
		-- The player did not kill the mobs within the amount of time, despawn the councilman and emote the failure
		eq.stop_timer("timedKills");
		timedClockRunning = false;
		eventOver = true;
		eq.stop_timer("council_check");
		eq.zone_emote(15,"The challengers have failed to extinguish the Council in the time alotted.  The council will reconvene in "..timedModeFailureDelayMinutes.." minutes");
		eq.spawn_condition("poearthb",eq.get_zone_instance_id(),1,0);
		eq.set_timer("repop",timedModeFailureDelayMinutes*60*1000);
	elseif (e.timer == "repop") then
		eq.stop_timer("repop");
		eventOver = false;
		eq.spawn_condition("poearthb",eq.get_zone_instance_id(),1,1);
	end
end
