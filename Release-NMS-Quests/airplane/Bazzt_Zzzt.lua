function event_death_complete(e)
	local instance_id = eq.get_zone_instance_id() or 0;
	eq.set_data("airplane-sirran-" .. instance_id, "6", tostring(eq.seconds("24h")));
	eq.spawn2(71058,0,0,234,-1078,812,384); --Sirran the Lunatic
end
