-- theater/380040.lua - Mad Mary-Anne (Theater of Blood raid)
function event_death_complete(e)
	local dz = eq.get_expedition();
	if dz.valid then
		dz:AddReplayLockout(eq.seconds("3d"));
	end
	eq.zone_emote(MT.Yellow, "Mad Mary-Anne's mad lullaby ends at last.");
end
