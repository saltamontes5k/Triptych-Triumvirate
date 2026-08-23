function event_spawn(e)
	eq.set_timer("timecheck", 10 * 1000);
end

function event_timer(e)
	local zone_time = eq.get_zone_time();

	if(zone_time["zone_hour"] >= 4 and zone_time["zone_hour"] <= 6) then
		--check between 4am - 6am

		if (eq.get_spawn_condition("yxtta", 0, 1) == 1) then
			--if spawn condition is already on, do nothing

		else
			eq.spawn_condition("yxtta", 0, 1, 1);
			--set caridwi spawn condition to on
		end

	else
		-- if time is not between 4am-6am turn off spawn condition
		eq.spawn_condition("yxtta", 0, 1, 0);
	end
end
