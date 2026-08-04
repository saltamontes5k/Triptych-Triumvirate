function event_spawn(e)
	eq.set_timer("follow", 1);
end

function event_timer(e)
	eq.stop_timer(e.timer);
	if e.timer == "follow" then
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(115101) then
			eq.follow(eq.get_entity_list():GetMobByNpcTypeID(115101):GetID());
		end
	end
end
