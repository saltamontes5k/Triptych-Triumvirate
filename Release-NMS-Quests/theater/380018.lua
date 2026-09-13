-- theater/380018.lua - Gnarlibramble (Theater of Blood raid)
function event_death_complete(e)
	local dz = eq.get_expedition();
	if dz.valid then
		dz:AddReplayLockout(eq.seconds("3d"));
	end
	eq.zone_emote(MT.Yellow, "Gnarlibramble shrieks its last and collapses into a heap of thorned vines.");
end
