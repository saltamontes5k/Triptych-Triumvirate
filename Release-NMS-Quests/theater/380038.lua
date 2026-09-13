-- theater/380038.lua - Vasella Fireblood (Theater of Blood raid)
function event_death_complete(e)
	local dz = eq.get_expedition();
	if dz.valid then
		dz:AddReplayLockout(eq.seconds("3d"));
	end
	eq.zone_emote(MT.Yellow, "Vasella Fireblood is extinguished, her searing aria gone silent.");
end
