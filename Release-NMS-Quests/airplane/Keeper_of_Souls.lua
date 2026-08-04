-- Epic NPC -- Keeper_of_Souls

function event_spawn(e)
	eq.set_timer("summit",1800000);
end

function event_timer(e)
	if(e.timer == "summit") then
		eq.stop_timer("summit");
		eq.depop();
	end
end

function event_death_complete(e)
	local instance_id = eq.get_zone_instance_id() or 0;
	eq.set_data("airplane-sirran-" .. instance_id, "4", tostring(eq.seconds("24h")));
	eq.spawn2(71058,0,0,-543,767,174,128); -- NPC: Sirran_the_Lunatic
end

--Quest by: Solid11
-------------------------------------------------------------------------------------------------
-- Converted to .lua using MATLAB converter written by Stryd
-- Find/replace data for .pl --> .lua conversions provided by Speedz, Stryd, Sorvani and Robregen
-------------------------------------------------------------------------------------------------
