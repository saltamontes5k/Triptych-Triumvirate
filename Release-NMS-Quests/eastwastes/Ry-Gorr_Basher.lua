function event_spawn(e)
	eq.set_timer("depop", 10 * 60 * 1000);
end

function event_timer(e)
	if e.timer == "depop" then
		eq.depop()
	end
end

function event_signal(e)
    if e.signal == 1 then
        eq.attack_npc_type(116009); -- NPC: Corbin Blackwell
    end
end