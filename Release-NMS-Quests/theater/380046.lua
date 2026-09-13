-- theater/380046.lua - Anastasia the Thought Drinker (Theater of Blood raid)
function event_death_complete(e)
	local dz = eq.get_expedition();
	if dz.valid then
		dz:AddReplayLockout(eq.seconds("3d"));
	end
	eq.zone_emote(MT.Yellow, "Anastasia the Thought Drinker is undone, and the stolen thoughts of the Theater are released.");
end
