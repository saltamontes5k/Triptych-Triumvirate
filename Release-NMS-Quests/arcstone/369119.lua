-- arcstone/369119.lua - a Colossus shard
-- The Colossus of Skylance (369070) shatters into six shards at ~12% health.
-- The shards can be rooted and slowed. Only when the last one falls does its
-- corpse yield one of the Colossus' prizes.
local SHARD = 369119;
local PRIZES = { 39213, 39214, 39215 }; -- Bindings / Bands of the Scrykin Architect / Shard Earring

local function shards_alive(except_id)
	local n = 0;
	local list = eq.get_entity_list():GetNPCList();
	if list ~= nil then
		for mob in list.entries do
			if mob:GetNPCTypeID() == SHARD and mob:GetID() ~= except_id and mob:GetHPRatio() > 0 then
				n = n + 1;
			end
		end
	end
	return n;
end

function event_death(e)
	if shards_alive(e.self:GetID()) == 0 then
		if e.corpse then
			e.corpse:AddItem(PRIZES[math.random(#PRIZES)], 1);
		end
		eq.zone_emote(MT.Yellow, "The last of the Colossus' shards crumbles to dust, leaving its prizes behind.");
	end
end
