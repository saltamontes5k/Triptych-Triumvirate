local wave_counter = 0;

function event_spawn(e)
	wave_counter = 0;
end

function event_signal(e)
	if e.signal == 1 then
    	wave_counter = wave_counter + 1;
	end

	if wave_counter == 5 then
    	e.self:Emote("stands over the glowing pool of magical power.");
    	eq.unique_spawn(226098,0,0,-726,1448,-73,131); -- NPC: a_water_spirit (226098)
		eq.set_timer("depop", 3 * 1000);
  	end
end

function event_timer(e)
	eq.depop_with_timer();
end
