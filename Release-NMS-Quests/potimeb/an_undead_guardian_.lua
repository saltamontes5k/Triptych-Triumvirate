--an_undead_guardian
--Phase 2 Undead
--potimeb

function event_death_complete(e)
	--signal phase_two_controller (spawned as 2231731 by zone_status; 223242
	--is only the npc_type in the header comment and nothing spawns it)
	eq.signal(2231731,2);
end
