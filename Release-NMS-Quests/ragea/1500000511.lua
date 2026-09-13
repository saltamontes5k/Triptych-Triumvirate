-- ragea/1500000511.lua - Sullon Zek, Mistress of Rage (raid)
-- Prophecy of Ro: on death, characters who have felled Daosheen (por.daosheen)
-- have their Shard of Mana (84164) turned into a Glowing Shard of Mana (84165).
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
				if (tonumber(c:GetBucket("por.daosheen")) or 0) == 1 and c:HasItem(84164) then
					c:NukeItem(84164);
					c:SummonFixedItem(84165);
					c:Message(15, "As Sullon Zek falls, your Shard of Mana burns with a cold and steady glow.");
				end
				if (tonumber(c:GetBucket("por.sullon")) or 0) == 0 then
					c:SetBucket("por.sullon", "1");
				end
			end
		end
	end
	eq.zone_emote(MT.Yellow, "Sullon Zek, Mistress of Rage, is undone. The fury of the tower falls silent.");
end
