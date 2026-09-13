-- theater/380059.lua - Valik the Cruel (Theater of Blood raid)
function event_death_complete(e)
	local dz = eq.get_expedition();
	if dz.valid then
		dz:AddReplayLockout(eq.seconds("3d"));
	end
	eq.zone_emote(MT.Yellow, "Valik the Cruel falls, and the cruel music of the Theater falters.");
end
