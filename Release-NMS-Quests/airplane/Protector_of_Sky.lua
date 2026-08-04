function event_death_complete(e)
	local instance_id = eq.get_zone_instance_id() or 0;
	eq.set_data("airplane-sirran-" .. instance_id, "2", tostring(eq.seconds("24h")));
	eq.spawn2(71058,0,0,-531,-214,-322,256); -- NPC: Sirran_the_Lunatic
end

-------------------------------------------------------------------------------------------------
-- Converted to .lua using MATLAB converter written by Stryd
-- Find/replace data for .pl --> .lua conversions provided by Speedz, Stryd, Sorvani and Robregen
-------------------------------------------------------------------------------------------------
