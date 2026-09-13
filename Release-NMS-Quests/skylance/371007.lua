-- skylance/371007.lua - Daosheen the Firstborn (raid)
-- Prophecy of Ro: marks the Deathknell access chain step that the Sullon Zek
-- raid checks (the Shard of Mana progression).
function event_death_complete(e)
	local dz = eq.get_expedition();
	if dz.valid then
		dz:AddReplayLockout(eq.seconds("3d"));
	end
	local entity_list = eq.get_entity_list();
	local client_list = entity_list:GetClientList();
	if client_list then
		for _, client in client_list.entries do
			if client.valid then
				if (tonumber(client:GetBucket("por.daosheen")) or 0) == 0 then
					client:SetBucket("por.daosheen", "1");
				end
				client:Message(15, "Daosheen the Firstborn has fallen. The corruption at the heart of Skylance is laid bare.");
			end
		end
	end
	eq.zone_emote(MT.Yellow, "The maddening whispers of Skylance fall silent as Daosheen the Firstborn is destroyed.");
end
