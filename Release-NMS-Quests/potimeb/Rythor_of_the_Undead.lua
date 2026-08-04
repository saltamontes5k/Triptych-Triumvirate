--Rythor_of_the_Undead (223129)
--Phase 1 - Rythor of The Undead Trial
--potimeb

function event_death_complete(e)
	-- send a signal to the #undead_trigger that I died
	eq.signal(223171,2);
	eq.signal(223097,223171); -- Add Loot Lockout for Phase 1 Wing
	eq.signal(223097,2); -- Increment Phase 1 Wing Counter
end
