-- elddara/1500000523.lua - Guardian of the High Priest
-- Prophecy of Ro: "The Corruption of Ro" (task 3398). When the Guardian falls
-- Brazlin escapes deeper into the shrine.
local por = require("por_helper");

function event_death_complete(e)
	local brazlin = eq.get_entity_list():GetNPCByNPCTypeID(por.npcs.brazlin);
	if brazlin and brazlin.valid then
		brazlin:Depop();
	end
	eq.zone_emote(MT.Yellow, "Guardian of the High Priest's corpse falls to the ground no longer able to serve its master. The tree shakes as Brazlin escapes once again.");
end
