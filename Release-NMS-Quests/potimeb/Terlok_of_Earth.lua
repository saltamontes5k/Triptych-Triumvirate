--Terlok_of_Earth (223119)
--Phase 1 - Terlok of Earth Trial
--potimeb

function event_death_complete(e)
	-- send a signal to the #earth_trigger that I died
	eq.signal(223169,2);
	eq.signal(223097,223169); -- Add Loot Lockout for Phase 1 Wing
	eq.signal(223097,2); -- Increment Phase 1 Wing Counter
end