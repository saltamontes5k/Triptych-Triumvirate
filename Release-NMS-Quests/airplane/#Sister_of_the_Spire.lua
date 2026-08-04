function event_death_complete(e)
	local instance_id = eq.get_zone_instance_id() or 0;
	eq.set_data("airplane-sirran-" .. instance_id, "7", tostring(eq.seconds("24h")));
	eq.spawn2(71058,0,0,-960,-1037,1093,128); -- NPC: Sirran_the_Lunatic
end

-------------------------------------------------------------------------------------------------
-- Converted to .lua using MATLAB converter written by Stryd
-- Find/replace data for .pl --> .lua conversions provided by Speedz, Stryd, Sorvani and Robregen
-------------------------------------------------------------------------------------------------
