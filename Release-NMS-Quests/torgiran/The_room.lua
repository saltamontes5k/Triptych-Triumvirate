local wave_counter = 0;

function event_spawn(e)
	wave_counter = 0;
end

function event_signal(e)
	if e.signal == 1 then
		wave_counter = wave_counter + 1;
		eq.debug("[DEBUG] wave counter kill count = [".. wave_counter .."]");
		-- eq.debug("wave counter kill count: " ..  wave_counter);

		if wave_counter == 25 then
			e.self:Emote("is filled with the grunts of trolls hard at work.");
			eq.spawn2(226210,0,0,-422,1748,-49,264);							-- NPC: a_Broken_Skull_hoarder (226210)
			eq.spawn2(226210,0,0,-518,1728,-49,132);							-- NPC: a_Broken_Skull_hoarder (226210)
			eq.spawn2(eq.ChooseRandom(226210,226208),0,0,-456,1770,-49,272);	-- NPC: a_Broken_Skull_hoarder (226210) / #a_Broken_Skull_treasurer (226208)
			eq.set_timer("depop", 3 * 1000);
		end
	end
end

function event_timer(e)
	eq.depop_with_timer();
end
