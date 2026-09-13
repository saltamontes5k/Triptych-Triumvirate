-- takishruinsa/1500000512.lua - Suchun, Blood Warden of Solusek (raid)
-- Prophecy of Ro: on death, characters with a Glowing Shard of Mana (84165) have
-- it blackened into a Black Shard of Mana (84167).
function event_death_complete(e)
	local dz = eq.get_expedition();
	if dz.valid then
		dz:AddReplayLockout(eq.seconds("3d"));
	end
	local el = eq.get_entity_list();
	local cl = el:GetClientList();
	if cl then
		for _, c in cl.entries do
			if c.valid then
				if (tonumber(c:GetBucket("por.sullon")) or 0) == 1 and c:HasItem(84165) then
					c:NukeItem(84165);
					c:SummonFixedItem(84167);
					c:Message(15, "Suchun's dying curse blackens your Glowing Shard of Mana until it drinks the light.");
				end
				if (tonumber(c:GetBucket("por.suchun")) or 0) == 0 then
					c:SetBucket("por.suchun", "1");
				end
			end
		end
	end
	eq.zone_emote(MT.Yellow, "Suchun, the Blood Warden of Solusek, collapses. The gateways of flame sputter and die.");
end
