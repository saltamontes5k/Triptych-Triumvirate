-- Prophecy of Ro: Etched Drachnid Carapace
local por = require("por_helper");

function event_loot(e)
	local c = e.self;
	if not c:IsTaskActive(por.tasks.saga_skins) and not c:IsTaskCompleted(por.tasks.saga_skins) then
		c:AssignTask(por.tasks.saga_skins);
		c:Message(15, "The strange markings on the skin intrigue you. Grand Librarian Maelin in the Plane of Knowledge may be able to translate them.");
	end
end
