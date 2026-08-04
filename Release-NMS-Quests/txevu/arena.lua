function event_spawn(e)
	eq.set_timer("spawncondition", 60 * 60 * 1000); --in 1 hour turn on arena spawn condition
end

function event_timer(e)
	local instance_id = eq.get_zone_instance_id();
	eq.stop_timer("spawncondition");
	eq.spawn_condition("txevu", instance_id, 6, 1);
	--set arena trash spawn condition to on
	eq.depop(297034); -- depop Champion if he is still up
end