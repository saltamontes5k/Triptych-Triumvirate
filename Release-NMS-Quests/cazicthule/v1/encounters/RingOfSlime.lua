function AcidicMassSpawnEvent(e)
	eq.set_timer("depop", 1800000);
	eq.set_timer("add", 180000);
	eq.spawn2(1500000159, 0, 0, -333, 148, -272, 0); -- an_acidic_ooze
end

function AcidicMassTimerEvent(e)
	if ( e.timer == "add" ) then
		eq.spawn2(1500000159, 0, 0, -333, 148, -272, 0);
	elseif ( e.timer == "depop" ) then
		eq.depop();
	end
end

function AcidicMassCombatEvent(e)
	if ( e.joined ) then
		eq.pause_timer("depop");
	else
		eq.resume_timer("depop");
	end
end

function event_encounter_load(e)
	eq.register_npc_event("RingOfSlime", Event.death, 1500000006, function(e)		-- a_swirling_ooze (level 56, rooted)
		eq.spawn2(1500000143, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0);
	end);
	eq.register_npc_event("RingOfSlime", Event.death, 1500000143, function(e) 		-- a_bubbling_ooze
		eq.spawn2(1500000142, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0);
	end);
	eq.register_npc_event("RingOfSlime", Event.death, 1500000142, function(e)		-- a_boiling_ooze
		eq.spawn2(1500000158, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0);
	end);
	
	-- an_acidic_mass
	eq.register_npc_event("RingOfSlime", Event.spawn, 1500000158, AcidicMassSpawnEvent);
	eq.register_npc_event("RingOfSlime", Event.timer, 1500000158, AcidicMassTimerEvent);
	eq.register_npc_event("RingOfSlime", Event.combat, 1500000158, AcidicMassCombatEvent);
	
	-- an_acidic_ooze
	eq.register_npc_event("RingOfSlime", Event.spawn, 1500000159, function(e) eq.set_timer("depop", 1800000); end);
	eq.register_npc_event("RingOfSlime", Event.timer, 1500000159, AcidicMassTimerEvent);
	eq.register_npc_event("RingOfSlime", Event.combat, 1500000159, AcidicMassCombatEvent);
end
