-- theater/380052.lua - Maestro Tan`lor (Theater of Blood raid)
function event_death_complete(e)
	local dz = eq.get_expedition();
	if dz.valid then
		dz:AddReplayLockout(eq.seconds("3d"));
	end
	eq.zone_emote(MT.Yellow, "The Maestro's baton clatters to the stage as his final, discordant note fades.");
end
