--Neimon_of_Air (223120)
--Phase 1 - Neimon of Air Trial
--potimeb

function event_death_complete(e)
	-- send a signal to the #air_trigger that I died
	eq.signal(223170,2);
	eq.signal(223097,223170); -- Add Loot Lockout for Phase 1 Wing
	eq.signal(223097,2); -- Increment Phase 1 Wing Counter
end
